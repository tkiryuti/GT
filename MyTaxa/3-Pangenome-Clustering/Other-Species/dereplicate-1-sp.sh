## Clustering at 90 % identity within a species

# Activate environment for mmseqs2
module load anaconda3/2019.10 &> /dev/null
conda activate bio

# Get the species input file name
species="$1"
# Exit with error if input argument not provided
if [[ -z "$species" ]]; then
	echo "Error: please provide species name (with underscores instead of species and forward slashes)"
	exit 1
fi
DB_fasta="${species}.fasta"

# Get number of threads to use
threads="$2"
# Exit with error if threads not provided 
if [[ -z "$threads" ]]; then
	echo "Error: please provide number of threads to run mmseqs linclust"
	exit 1
fi

# Get the output directory names
reps_dir="/nv/hmicro1/tkiryutina3/scratch/MyTaxa/Pangenomes/Reps-at-90"
clusters_dir="/nv/hmicro1/tkiryutina3/scratch/MyTaxa/Pangenomes/Clusters-at-90"

# Setup the directory for logging the MMseqs2 standard output
log_dir="/nv/hmicro1/tkiryutina3/scratch/MyTaxa/Pangenomes/logs/${species}"
mkdir "${log_dir}"

# Convert FASTA database into the MMseqs2 database (DB) format
# https://github.com/soedinglab/mmseqs2/wiki#clustering
echo 'Creating database ...'
time mmseqs createdb "$DB_fasta" DB --dbtype 1 \
> "${log_dir}/0-createdb.log"

echo ''
# Run clustering of database.
# https://github.com/soedinglab/MMseqs2/wiki#clustering-modes
# https://github.com/soedinglab/mmseqs2/wiki#how-to-set-the-right-alignment-coverage-to-cluster
echo 'Clustering with linclust ...'
time mmseqs linclust DB DB_clu tmp --min-seq-id 0.99 --cluster-mode 2 --cov-mode 1 -c 0.9 --threads "$threads" \
> "${log_dir}/1-linclust.log"

echo ''
# tsv-formatted output - list of representatives and cluster members
# https://github.com/soedinglab/mmseqs2/wiki#cluster-tsv-format
echo 'Creating tsv list of represetatives and cluster members ...'
time mmseqs createtsv DB DB DB_clu "${clusters_dir}/${species}.tsv" \
> "${log_dir}/2-members.log"

echo ''
# Extract representative sequences
# https://github.com/soedinglab/mmseqs2/wiki#extract-representative-sequence
echo 'Extracting representative sequences ...'
mmseqs createsubdb DB_clu DB DB_clu_rep \
> "${log_dir}/3-reps.log"
mmseqs convert2fasta DB_clu_rep "${reps_dir}/${species}.faa" \
>> "${log_dir}/3-reps.log"

# Zip the results
gzip "${clusters_dir}/${species}.tsv"
gzip "${reps_dir}/${species}.faa"

# # Zip the logs
# gzip "${log_dir}"/*


