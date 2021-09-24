## List clusters and get representatives
## Usage:
# jobid=#######
# qsub -W depend=afterok:"${jobid}" 3-reps-clusters.pbs

#PBS -N 3-reps-clusters
#PBS -l nodes=1:ppn=1
#PBS -l walltime=2:00:00
#PBS -l pmem=7gb
#PBS -q embers
#PBS -j oe
#PBS -A GT-ktk3-biocluster

cd "$PBS_O_WORKDIR"

# Activate environment for mmseqs2
module load anaconda3/2019.10 &> /dev/null
conda activate bio

## List clusters
# tsv-formatted output - list of representatives and cluster members
# https://github.com/soedinglab/mmseqs2/wiki#cluster-tsv-format
echo ''; echo "... creating tsv of clusters | $(date)"
mmseqs createtsv DB DB DB_clu Clusters.tsv

echo ''; echo "... calculating space usage and compressing | $(date)"
du -h Clusters.tsv
gzip Clusters.tsv
du -h Clusters.tsv.gz

## Get Reps
# Extract representative sequences
# https://github.com/soedinglab/mmseqs2/wiki#extract-representative-sequence
echo ''; echo "... getting faa of representatives | $(date)"
mmseqs createsubdb DB_clu DB DB_clu_rep; echo ''
mmseqs convert2fasta DB_clu_rep Reps.faa

echo ''; echo "... calculating space usage and compressing | $(date)"
du -h Reps.faa
gzip Reps.faa
du -h Reps.faa.gz
