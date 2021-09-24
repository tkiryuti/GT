#!/bin/bash

## Run CheckM taxonomy workflow on a species for genomes in bins-1, bins-2 ...
## Usage:
# qsub -N "$sp" -t "1-${n}" -v "sp=$sp" run-sp.pbs

#PBS -A GT-ktk3-biocluster
#PBS -l nodes=1:ppn=1
#PBS -l pmem=7gb
#PBS -l walltime=7:00:00:00
#PBS -j oe

cd ~/scratch
module load anaconda3
conda activate CheckM

# Make required output directories
mkdir -p "CheckM-outputs/${sp}"

# checkm taxonomy_wf <rank> <taxon> <bin folder> <output folder>
checkm taxonomy_wf "species" "${sp/_/ }" "genomes-unzipped/${sp}/bins-${PBS_ARRAYID}" "CheckM-outputs/${sp}" >> "CheckM-results/${sp}.txt"


