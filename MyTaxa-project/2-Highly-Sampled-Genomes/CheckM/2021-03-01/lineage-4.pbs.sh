## Runs CheckM lineage-specific workflow on Clostridioides_difficile
# This script runs step 4 (qa):
# Produces different tables summarizing the quality of each genome bin.

#PBS -N lineage-4
#PBS -A GT-ktk3-biocluster
#PBS -q inferno
#PBS -l nodes=1:ppn=24
#PBS -l pmem=7gb
#PBS -l walltime=5:00:00:00
#PBS -j oe
#PBS -m abe
#PBS -M tkiryuti@gatech.edu

cd $PBS_O_WORKDIR

module load anaconda3 &> /dev/null
conda activate CheckM

checkm qa "Clostridioides_difficile.ms" "out" -t 24
