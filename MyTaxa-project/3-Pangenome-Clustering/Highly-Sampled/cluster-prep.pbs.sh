#!/bin/bash
## Runs cluster-prep.sh

#PBS -N cluster-prep
#PBS -A GT-ktk3
#PBS -q embers
#PBS -l nodes=1:ppn=1
#PBS -l pmem=7gb
#PBS -l walltime=8:00:00
#PBS -j oe

cd "$PBS_O_WORKDIR"

for reps in ~/MyTaxa/dereplication/experiments/2021-03-09/Derep-99/*/cluster-analysis/reps.txt; do 
	species=$(basename $(echo $reps | sed 's/\/cluster-analysis\/reps.txt//'))
	bash cluster-prep.sh "$species" "$reps"
done
