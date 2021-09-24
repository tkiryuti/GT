#!/bin/bash

## Double check and filter CheckM results for one species.
# Usage:
# bash filter-CheckM.sh $sp

## Define species variable. Exit if it is empty.
sp=$1
[[ -z "$sp" ]] && { echo "Error: please provide the species (example: Helicobacter_pylori)." ; exit 1; }
echo "Species: $sp"

## Define some paths
# Path to collection of compressed genomes of this species:
genome_collection=~/MyTaxa/dereplication/data/genomes/${sp}/
# Path to raw CheckM results
checkm_results=~/scratch/tmp-results/${sp}/

## Double check that expected number of genomes ran through CheckM.
echo "... Double checking some numbers ..."

echo "___ Expected genomes: ___"
ls "$genome_collection" | wc -l
echo "___ CheckM processed: ___"	
cat ~/scratch/tmp-job-outputs/${sp}.o* | grep '^Genome:' | wc -l

## Collect all results
# header='Bin_Id Marker_lineage #_genomes #_markers #_marker_sets 0 1 2 3 4 5+ Completeness Contamination Strain_heterogeneity'
echo "... Collecting CheckM results ..."
mkdir -p tmp
cat "$checkm_results"* | grep -ve 'INFO:' -ve '---------' -ve 'Contamination' | tr -s ' ' | sed 's/^ //' > tmp/${sp}.all
# !!! #  check columns $2, $3, and $4 (should all be "Marker_lineage") to get the right columns later
# For example: should be "Helicobacter_pylori_(6)"
echo "___ Columns 2, 3, and 4: ___"
cat tmp/${sp}.all | awk '{print $2, $3, $4}' | sort | uniq

## Collect only quality metrics from the results
# header='Genome Completeness Contamination Quality'
echo "... Extracting quality data from results ..."
mkdir -p quality-data
awk '{print $1, $14, $15, $14-5*$15 }' tmp/${sp}.all > quality-data/${sp}.txt
rm tmp/${sp}.all

## Filter quality data based on these metrics
# Completeness > 80%
# Contamination < 4%
# Quality > 80%
echo "... Filtering genomes by Completeness > 80 %, Contamination < 4 %, and Quality > 80 % ..."
awk '{ if(($2 > 80) && ($3 < 4) && ($4 > 80)) { print } }' quality-data/${sp}.txt > tmp/${sp}.quality
echo "High_q Total"
echo "$(cat tmp/${sp}.quality | wc -l) $(cat quality-data/${sp}.txt| wc -l)"

## Get full paths of the high quality genomes for next step (dereplication)
echo "... Getting full paths of high-quality genomes ..."
mkdir -p quality-paths
sed_path=$(echo $genome_collection | sed 's/\//\\\//g')
awk '{print $1}' tmp/${sp}.quality | sed "s/^/$sed_path/; s/$/.fna.gz/" > quality-paths/${sp}.txt



