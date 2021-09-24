#!/bin/bash

### Runs all analysis of clusters in directory "cluster-analysis" of a dereplication run
echo "... starting cluster analysis | $(date)"
mkdir -p "cluster-analysis"
cd "cluster-analysis"

## Collect all fastANI results into one file
# First, remove results file if already exists since appending to it
echo "... collecting all FastANI results | $(date)"
rm "ANI-results.tsv" &> /dev/null
for results in ../fastANI-results/*.tsv.gz; do gzip -cd "$results" >> ANI-results.tsv; done 

## Simplify ANI-results file
# Remove the long paths and only leave genome file names for both genomes in each pair
# Find the path to replace and add backslashes:
echo "... simplifying all FastANI results | $(date)"
path_to_replace=$(head -1 "ANI-results.tsv" | awk '{print $1}' | xargs dirname | sed 's/\//\\\//g')
sed "s/${path_to_replace}\///g" ANI-results.tsv > ANI-results-short.tsv

## Much longer (~ 5 min runtime) alternative to remove long paths but doesn't require species name
# sed -r 's/\/.+\/(.+)\t\/.+\/(.+)\t(.+)\t(.+)\t(.+)/\1\t\2\t\3\t\4\t\5/' ANI-results.tsv > ANI-results-short.tsv

## Double check all numbers
echo "... calculating number of clusters and fastANI results"
echo "... correct if # .clstr = # .tsv.gz = # representatives"
echo "Number of .clstr files = $(ls ../fastANI-results/*.clstr | wc -l)"
echo "Number of .tsv.gz files = $(ls ../fastANI-results/*.tsv.gz | wc -l)"
echo "... searching for result files without any fastANI outputs"
echo "Number of .tsv files = $(ls ../fastANI-results/*.tsv | wc -l)"
ls ../fastANI-results/*.tsv 2> /dev/null

## Calculate number of self-matches, fastANI of representative vs. itself (optional, should be = # .clstr = # .tsv.gz)
echo "Number of self-matches:"
for file in ../fastANI-results/*.clstr; do rep=${file/.clstr/_genomic.fna.gz}; rep=$(echo $rep | sed 's/^..\/fastANI-results\///'); grep "${rep}.*${rep}" $file; done | wc -l

## Collect a list of representatives
ls ../fastANI-results/*.clstr | sed 's/^..\/fastANI-results\///; s/.clstr$/_genomic.fna.gz/' > reps.txt
echo "Number of representatives in list:"
wc -l reps.txt

## Collect ANI data between representatives
# Expected to run for a few minutes
echo "... collecting ANI data between representatives | $(date)"
python3 ~/MyTaxa/dereplication/bin/collect-rep-pairs.py > ANI-between-reps.tsv

if [ $? -eq 0 ]; then
	echo "Done! Next step is to create an ANI histogram for representatives."
fi

## ANI histogram
# Copy "E-coli-reps-ANI-histogram.ipynb" here and edit it manually in an interactive PACE jupyter notebook session
