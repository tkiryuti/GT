#!/bin/bash
## Running MMseqs2 (or not if one genome)
## Runs cluster-sp.sh for all the species I need to run it for

#PBS -N cluster-sp
#PBS -A GT-ktk3-biocluster
#PBS -q embers
#PBS -l nodes=1:ppn=24
#PBS -l pmem=7gb
#PBS -l walltime=8:00:00
#PBS -j oe

cd "$PBS_O_WORKDIR"
threads=24

# Activate environment for mmseqs2
module load anaconda3/2019.10 &> /dev/null
conda activate bio

## Result directories
# Directory for representative sequences
reps_dir="$(pwd)/Reps-at-90"; mkdir -p "$reps_dir"
clusters_dir="$(pwd)/Clusters-at-90"; mkdir -p "$clusters_dir"
log_dir="$(pwd)/Logs"; mkdir -p "$log_dir"

for species in $(ls tmp-genomes/); do

	# Go to target directory
	target_dir="tmp-genomes/${species}"; mkdir -p "$target_dir"
	cd "$target_dir"
	# If only one genome, keep as is send it to representative sequences
	# If more than one genome, run MMseqs2 script
	if [[ "$n" -eq 1 ]]; then
		echo "One genome of ${species}: sending straight to representative sequences directory"
		# Compress the fasta file, and if works
		# clean up this temporary species directory from "tmp-genomes"
		gzip -c "${species}.fasta" > "${reps_dir}/${species}.faa.gz" && gzip "${species}.fasta" # { cd .. ; rm -r "$species" ; }
	else
		echo "More than one genome of ${species}: running MMseqs2 to cluster at 90 % id."
		# Run the MMseqs2 clustering script, and if works then 
		# clean up this temporary species directory from "tmp-genomes"
		cluster_sp=~/MyTaxa/dereplication/experiments/2021-03-22/cluster-sp.sh
		bash "$cluster_sp" "$species" "$threads" "$reps_dir" "$clusters_dir" "$log_dir" && gzip "${species}.fasta" # { cd .. ; rm -r "$species" ; }
	fi

	cd "$PBS_O_WORKDIR"

done
