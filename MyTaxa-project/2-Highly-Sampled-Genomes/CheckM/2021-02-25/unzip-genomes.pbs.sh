#!/bin/bash

## Copy genomes into scratch, then unzip. Use job arrays.
## Usage:
# cd outputs-unzip-genomes
# qsub -N "$sp" -t "1-${n}" -v "sp=$sp" unzip-genomes.pbs

#PBS -A GT-ktk3-biocluster
# #PBS -q embers
#PBS -l nodes=1:ppn=1
#PBS -l pmem=7gb
#PBS -l walltime=7:59:59
#PBS -j oe

echo "Species: $sp"

# Go to directory in scratch where genomes will be pasted and unzipped
workdir=~/scratch/genomes-unzipped/${sp}/bins-${PBS_ARRAYID}
cd $workdir
echo "Workdir: $workdir"

# Store list of genomes (filenames)
genomes_list=~/MyTaxa/dereplication/experiments/2021-02-25-CheckM/genome-paths-split/${sp}/${PBS_ARRAYID}
echo "Split size: $(cat $genomes_list | wc -l)"

# For each genome, copy the full genome here (into scratch) and unzip it
for genome in $(cat $genomes_list); do
	cp ~/MyTaxa/dereplication/data/genomes/$sp/$genome .
	gunzip $genome
done

# Count number of genomes downloaded
echo "Downloaded: $(ls * | wc -l)"
echo "Fna files: $(ls *.fna | wc -l)"
