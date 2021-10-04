## Runs CheckM lineage-specific workflow on Clostridioides_difficile
# This script runs step 2 (lineage_set):
# Create a marker file indicating lineage-specific marker sets suitable for evaluating each genome.

#PBS -N lineage-2
#PBS -A GT-ktk3-biocluster
#PBS -q inferno
#PBS -l nodes=1:ppn=1
#PBS -l pmem=7gb
#PBS -l walltime=10:00:00:00
#PBS -j oe
#PBS -m abe
#PBS -M tkiryuti@gatech.edu

cd $PBS_O_WORKDIR

module load anaconda3 &> /dev/null
conda activate CheckM

checkm lineage_set "out" "Clostridioides_difficile.ms"
