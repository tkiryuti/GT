## Runs CheckM lineage-specific workflow on Clostridioides_difficile
# This script runs step 3 (analyze):
# Identifies marker genes within each genome bin and estimates completeness and contamination.

#PBS -N lineage-3
#PBS -A GT-ktk3-biocluster
#PBS -q inferno
#PBS -l nodes=1:ppn=24
#PBS -l pmem=7gb
#PBS -l walltime=10:00:00:00
#PBS -j oe
#PBS -m abe
#PBS -M tkiryuti@gatech.edu

cd $PBS_O_WORKDIR

module load anaconda3 &> /dev/null
conda activate CheckM

bin_dir=~/scratch/Clostridioides_difficile/
checkm analyze "Clostridioides_difficile.ms" "$bin_dir" "out" -t 24
