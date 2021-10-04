#!/bin/bash

## Run CheckM taxonomy workflow on a species for genomes in {bins-1, bins-2, ...} using a job array for each set of bins
## Usage:
# qsub -N "$sp" -t "1-${n}" -v "sp=$sp" run-CheckM.pbs

#PBS -A GT-ktk3-biocluster
#PBS -l nodes=1:ppn=1
#PBS -l pmem=7gb
#PBS -l walltime=7:00:00:00
#PBS -j oe

cd ~/scratch
module load anaconda3 &> /dev/null
conda activate CheckM

## Make required directories (see 2021-03-01-README.sh in ~/MyTaxa/dereplication/experiments/2021-03-01)

## Store taxonomy-based marker set (produced in advance using "checkm taxon_set")
marker_file="CheckM-marker-files/${sp}.ms"

## Which set of genomes is the subjob analyzing?
genome_set="genomes-unzipped/${sp}/bins-${PBS_ARRAYID}"

## Define CheckM bin and output folders
bin_dir="tmp-bin/${sp}/${PBS_ARRAYID}"
out_dir="tmp-out/${sp}/${PBS_ARRAYID}"

## Define results file where summary table will be appended
results_file="tmp-results/${sp}/${PBS_ARRAYID}.txt"

## For each genome out of the set the sub-job is analyzing:
for genome in $(ls "$genome_set"); do
	
	echo '-----------------------------------------------------------------------------------'
	echo "Genome: $genome"

	# Copy current genome to checkm bin directory
	cp "${genome_set}/${genome}" "${bin_dir}/${genome}"

	# Identify marker genes within genome
	checkm analyze "$marker_file" "$bin_dir" "$out_dir"

	# Produce summary table for genome with Completeness, Contamination, Strain heterogeneity, etc.
	checkm qa "$marker_file" "$out_dir" >> "$results_file"

	# Clear out the temporary bin and output folders used in this loop for this subjob
	rm "$bin_dir"/*
	rm -r "$out_dir"/*

done

