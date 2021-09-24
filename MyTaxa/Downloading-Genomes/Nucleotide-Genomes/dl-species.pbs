## Download nucleotide genomes for a given species based on input FTP links
## Runs the script "dl-species.sh"
## qsub -N "dl-${SPECIES}" -v SPECIES="${SPECIES}" dl-species.pbs

#PBS -A GT-ktk3-biocluster
#PBS -l nodes=1:ppn=2
#PBS -l walltime=7:59:59
#PBS -l pmem=7gb
#PBS -j oe
#PBS -q embers

## Enter directory where this pbs script was started from
cd "${PBS_O_WORKDIR}"

## Store the total number of processors that will be used in parallelization
n_proc=$(cat "${PBS_NODEFILE}" | wc -l)

## Load the launcher module
module load launcher
export LAUNCHER_SCHED='interleaved'

## Go to the "data" directory of the "dereplication" project where genomes will be downloaded
cd ~/MyTaxa/dereplication/data

## Create the species directory if does not exist
mkdir -p "genomes/${SPECIES}"
echo "Species: ${SPECIES}"

## Set the species directory in "genomes" as the working directory for launcher
export LAUNCHER_WORKDIR=~/MyTaxa/dereplication/data/genomes/${SPECIES}

## Set up input file of ftp links
ftp_links="$(pwd)/ftp-lists/${SPECIES}.txt"

## Split the input
echo "Preparing inputs | $(date) | $(hostname)"
mkdir -p "tmp-inputs/${SPECIES}"
cd "tmp-inputs/${SPECIES}"
# Clear out previous inputs in case doing a new downloading iteration
rm xa* &> /dev/null
split -n l/${n_proc} "$ftp_links" 
cd ../..

## Prepare the variables

# Set up launcher job file
export LAUNCHER_JOB_FILE=~/MyTaxa/dereplication/data/tmp-jobs/${SPECIES}-${PBS_JOBID/.sched-torque.pace.gatech.edu/}
echo "Launcher Job File: ${LAUNCHER_JOB_FILE}"
## Clear out any previous auto-generated launcher job files for this species
rm tmp-jobs/${SPECIES}-* &> /dev/null

# Indicate script that launcher will run
script=~/MyTaxa/dereplication/bin-2/dl-species.sh
echo "Script: ${script}"

# Set up path for log files for downloads	
mkdir -p "tmp-logs/${SPECIES}"
log_file_dir=~/MyTaxa/dereplication/data/tmp-logs/${SPECIES}
echo "Log files directory: ${log_file_dir}"

# Create commands in launcher job file
for input in ~/MyTaxa/dereplication/data/tmp-inputs/${SPECIES}/*; do
	echo "bash ${script} ${input} ${log_file_dir}"
done > "${LAUNCHER_JOB_FILE}"

## Start the jobs (start launcher)
echo "Starting downloads | $(date) | $(hostname)"
paramrun 
echo "Completed downloads | $(date) | $(hostname)"

## Concatenate the resulting logs

