#PBS -N 2-cluster
#PBS -l nodes=1:ppn=24
#PBS -l walltime=8:00:00
#PBS -l pmem=7gb
#PBS -q embers
#PBS -j oe
#PBS -A GT-ktk3-CODA20

cd "$PBS_O_WORKDIR"

# Activate environment for mmseqs2
module load anaconda3/2019.10 &> /dev/null
conda activate bio

# Run clustering of database.
# https://github.com/soedinglab/MMseqs2/wiki#clustering-modes
# https://github.com/soedinglab/mmseqs2/wiki#how-to-set-the-right-alignment-coverage-to-cluster
mmseqs linclust DB DB_clu tmp --min-seq-id 0.4 --cluster-mode 2 --cov-mode 1 -c 0.7 --threads 24 > 2-cluster.log

# Check the space usage of files created in this run
du -hs tmp
