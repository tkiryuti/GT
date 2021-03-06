## Usage:
# qsub -N "$job_name" -v "input_genomes=$input_genomes" ~/MyTaxa/dereplication/bin/dereplication.pbs

#PBS -A GT-ktk3-biocluster
#PBS -l nodes=1:ppn=1
#PBS -l walltime=7:00:00:00
#PBS -l pmem=16gb
#PBS -j oe
#PBS -m abe
#PBS -M tkiryuti@gatech.edu

#---------------------------------------------------------------------------------------------------------------------------
# Last steps of dereplication: a little number of sequences left so not parallelized
# The parallelized script "dereplication.pbs" has been slighlty modified to run the same process but with 1 database
#---------------------------------------------------------------------------------------------------------------------------
# Dereplication of genomes with FastANI-based clustering for highly sampled species.
# Runs greedy incremental clustering by length with FastANI as a similarity measure.
# The input genome list must be sorted in descending order by genome size (base pairs).
# The longest sequence becomes the first cluster representative.
# FastANI is used to compute pairwise ANI between between representative (query) and the rest of the sequences (references).
# Sequences with ≥ 99.9% ANI and ≥ 50% of the genome shared become members.
# The longest sequence of the remaining is the next representative. FastANI step is repeated.
#---------------------------------------------------------------------------------------------------------------------------

## Go to directory where this job was submitted from/working directory
cd "${PBS_O_WORKDIR}"

## Time stamp the start of initial pre-processing and variables
echo "Initializing variables | $(date) | $(hostname)"

## Collect the numerical portion of the PBS Job ID
jobid=$(echo "${PBS_JOBID}" | sed 's/.sched-torque.pace.gatech.edu//')

## Store the total number of processors that will be used (should be = 1)
n_proc=$(cat "${PBS_NODEFILE}" | wc -l)

## Input genome paths list
# The input genome list must be sorted in descending order by genome size (base pairs).
# This list changes at every iteration - the paths of clustered genomes are removed.
genomes_list="${PBS_O_WORKDIR}/genome-lists/refGenomes.txt"

## Total number of genomes:
total_genomes=$(cat "$input_genomes" | wc -l)
echo "Total number of genomes: ${total_genomes}"

## Previously, this is where the "fastANI_para" function was initialized.
# Now, it is a script "fastANI_para.sh" that is used in the loop below.

#____________________________________________________________________________________#
### BEGIN ITERATIONS ###
echo "Starting first iteration | $(date) | $(hostname)"

## Run FastANI-based clustering.
while true; do
	
	echo '__________________________________________'

	#____________________________________________________________________________________#
	### PREPARE REFERENCE GENOME DATABASE ###
	echo "... preparing inputs | $(date) | $(hostname)"

	## Clear out any termporary inputs and outputs from previous iteration.
	rm tmp-ANI-logs/*     2> /dev/null
	rm tmp-ANI-outputs/*  2> /dev/null 
	rm tmp-ref-genomes/*  2> /dev/null

	## Copy reference genome database (to use the same fastANI_para.sh script)
	cp "${genomes_list}" tmp-ref-genomes/000

	#____________________________________________________________________________________#
	### DEFINE VARIABLES ###
	echo "... defining variables for iteration | $(date) | $(hostname)"

	## Define current query genome.
	# This is the first genome in the unclustered genomes list.
	# It should be the longest genome in the list (in base pairs).
	query_genome=$(head -1 "${genomes_list}")

	## Check if this query genome is empty. If it is, the script finished clustering all the reference genomes!
	if [[ -z "$query_genome" ]]; then
		echo 'Completed. There are no more database chunks to process. :)'
		exit 0
	fi

	## Extract the genome name/ID of query to name the iteration output files.
	tmp=$(basename $query_genome)
	genome_ID=${tmp/_genomic.fna.gz/}

	## Define subjob log directory.
	# These logs record the FastANI start and end times on each processor from within "fastANI_para.sh".
	subjob_log="${PBS_O_WORKDIR}/subjob-logs/${genome_ID}.log"

	## Remove subjob log if already exists (for example, if re-running this iteration)
	rm "${subjob_log}" 2> /dev/null

	## Show the query genome name/ID for this iteration.
	echo "___ ${genome_ID} ___"

	#____________________________________________________________________________________#
	### RUN FASTANI ###
	echo "Starting FastANI | $(date) | $(hostname)"

	db_chunk="000"
	bash ~/MyTaxa/dereplication/bin/fastANI_para.sh "${genome_ID}" "${query_genome}" "${db_chunk}"

	echo "Completed FastANI | $(date) | $(hostname)"

	#____________________________________________________________________________________#
	### CHECK SUCCESS OF ALL FASTANI RUN ###
	echo "... checking success of FastANI run | $(date) | $(hostname)"

	## Double check expected outputs before moving on to clustering process.
	# If at least one fastANI failure is found in status file, exit script (cancels job).
	# grep -q   Quit; Exit immediately with zero status if any match is found.
	if grep -q '^FastANI failure | ' "${subjob_log}"; then
		echo 'Error: at least one FastANI run failed.'
		echo "Subjob log: ${subjob_log}"
		echo 'Exiting program.'
		exit 1
	# If expected number of lines starting with "FastANI success" in subjob log is incorrect, exit script and cancel job.
	elif [[ $(grep '^FastANI success' "${subjob_log}" | wc -l) -ne "${n_proc}" ]]; then
		echo "Error: do not have expected number of FastANI successes (${n_proc})."
		echo "Subjob log: ${subjob_log}"
		echo 'Exiting program.'
		exit 1
	# If expected number of lines starting with "... starting fastANI" in subjob log is incorrect, exit script and cancel job.
	elif [[ $(grep '^... starting FastANI' "${subjob_log}" | wc -l) -ne "${n_proc}" ]]; then
		echo "Error: do not have expected number of fastANI starts (${n_proc})."
		echo "Subjob log: ${subjob_log}"
		echo 'Exiting program.'
		exit 1
	fi

	#____________________________________________________________________________________#
	### PROCESS RESULTS AND CREATE CLUSTERS ###
	echo "... processing FastANI results | $(date) | $(hostname)"

	## Once the FastANI process and checks are successfully completed, combine outputs.
	cat tmp-ANI-outputs/* > "fastANI-results/${genome_ID}.tsv"

	## Inputs become previous inputs (before creating new ones).
	cp "genome-lists/refGenomes.txt" "genome-lists/refGenomes_previous.txt"

	## Compress all fastANI results. Also check if they are empty - produce a warning and skip in that case.
	# If the resulting tsv file with FastANI comparisons is zero size, print out a warning and create Warning file.
	if [[ ! -s "fastANI-results/${genome_ID}.tsv" ]]; then
		# Print and save warning to a warning file
		echo "Warning: empty .tsv file in fastANI-results with query: ${genome_ID}" | tee --append "Warning.${jobid}"
		# Remove this genome path from the reference genomes file
		sed -i "/${genome_ID}/d" "genome-lists/refGenomes.txt"
		# Find the full path for removed genome
		removed_path=$(diff genome-lists/refGenomes.txt genome-lists/refGenomes_previous.txt | grep '\/' | sed 's/^[<>] //')
		# Print path of removed genome to check it out later
		echo "Removed this genome path from the reference genomes input file: ${removed_path}" | tee --append "Warning.${jobid}"
		# Skip the rest of the loop
		continue
	# If file is not zero size, do the normal procedure (compressing all fastANI results for this query).
	else
		gzip "fastANI-results/${genome_ID}.tsv"
	fi

	## Once combined, go into results and get clusters/next runs.
	echo "... creating clusters | $(date) | $(hostname)"
	gzip -cd "fastANI-results/${genome_ID}.tsv.gz" | awk '{ if ($3 >= 99.9) {print} }' > "fastANI-results/${genome_ID}.clstr"
	
	## Sort unclustered genomes by genome size
	echo "... removing clutered genomes from reference genomes paths file | $(date) | $(hostname)"

	## Collect clustered genome paths.
	awk '{print $2}' "fastANI-results/${genome_ID}.clstr" > "genome-lists/tmp-clustered-genomes"

	## Remove clutered genomes from reference genomes paths file.
	# grep -Fvxf <lines-to-remove> <all-lines> 
		# -F, --fixed-strings,
		# -v, --invert-match
		# -x, --line-regexp
		# -f FILE, Obtain patterns from FILE, one per line.
	grep -Fvxf "genome-lists/tmp-clustered-genomes" "genome-lists/refGenomes_previous.txt" > "genome-lists/refGenomes.txt"

	## Make a copy of reference genomes that depends on this specific job once it ends.
	cp "genome-lists/refGenomes.txt" "genome-lists/refGenomes.${jobid}"

	#____________________________________________________________________________________#
	### ITERATION INFO ###
	echo "... collecting results to summarize this iteration | $(date) | $(hostname)"

	## Print cluster size and representative genome name/ID.
	clustered_size=$(cat "fastANI-results/${genome_ID}.clstr" | wc -l)
	echo -e "Cluster_size:\t${clustered_size}\t${genome_ID}"

	## Find the database chunk sizes.
	range=$(wc -l tmp-ref-genomes/* | awk '{print $1}' | sort -n | uniq -c | awk '{print $2}' | tr '\n' ',' | sed 's/,$//')
	echo -e "DB_sizes:\t${range}"

	## Calculate and print overall progress.
	# Total number of genomes is calculated at the top.
	remaining_size=$(cat "genome-lists/refGenomes.txt" | wc -l)
	echo -e "Remaining:\t${remaining_size}"
	total_clustered=$(python -c "print(${total_genomes} - ${remaining_size})")
	percent_clustered=$(python -c "print(round(100*${total_clustered}/${total_genomes},2))")
	echo -e "%_clustered:\t${percent_clustered}"

	## Last sanity check - do we the expected number of unclustered genomes?
	# Does remaining_size + clustered_size = previous_clustered_size
	previous_clustered_size=$(cat "genome-lists/refGenomes_previous.txt" | wc -l)
	if [[ $(( ${clustered_size} + ${remaining_size} )) -ne ${previous_clustered_size} ]]; then
		echo "Error: remaining size + clustered size does not equal previous clustered size."
		exit 1
	fi

	echo "Iteration completed | $(date) | $(hostname)"

done
