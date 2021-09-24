#PBS -N 1-create-db
#PBS -l nodes=1:ppn=1
#PBS -l walltime=8:00:00
#PBS -l pmem=7gb
#PBS -q embers
#PBS -j oe
#PBS -A GT-ktk3-biocluster

cd "$PBS_O_WORKDIR"

# Activate environment for mmseqs2
module load anaconda3/2019.10 &> /dev/null
conda activate bio

# Convert FASTA database into the MMseqs2 database (DB) format
# https://github.com/soedinglab/mmseqs2/wiki#clustering

# Create sequence database from multiple FASTA files (can be zipped)
fastaFiles=~/MyTaxa/Pangenomes/Reps-at-90/*.faa.gz
mmseqs createdb $fastaFiles DB --dbtype 1 > 1-create-db.log

# How much space does the DB take up?
du -hs DB*
