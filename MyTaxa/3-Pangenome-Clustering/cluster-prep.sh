#!/bin/bash

## Clustering pangenome for one species
## This script prepares an input file for clustering

## Usage:
# bash cluster-prep.sh "$species" "$reps"

# Directory with all species/genomes
genome_dir=~/MyTaxa/DB-TypeMat/genomes

# Input argument is species name (with underscores - same as directory name for it in genome_dir)
species="$1"
if [[ -z "$species" ]]; then
	echo "Error: please provide species name (with underscores instead of spaces and forward slashes)"
	exit 1
fi

# Full path to the species directory that contains amino acid genomes from NCBI
species_dir="${genome_dir}/${species}"

# Check if species directory exists
if [[ ! -d "$species_dir" ]]; then
	echo "Error: species directory does not exist. Attempted the following path:"
	echo "$species_dir"
	exit 1
fi

# Full path to the list of representatives (probably "genomeID_genomic.fna.gz" in cluster-analysis/reps.txt)
reps="$2"
if [[ ! -f "$reps" ]]; then
	echo "Error: list of representatives does not exist. Attempted the following path:"
	echo "$reps"
	exit 1
fi

# Indicate which species the script is working on
echo ''
echo '-----------------------------------------------------------------'
echo "Species: ${species}"

## Create target directory
target_dir="tmp-genomes/${species}"
mkdir -p "${target_dir}"

## Set up file where all the genomes will be appended to for clustering
fasta_in="${target_dir}/${species}.fasta"
# If tmp file already exists AND IS NOT EMPTY, remove it
if [[ -s "${fasta_in}" ]]; then rm "${fasta_in}"; fi
# Create empty instance of target tmp file to append to
touch "${fasta_in}"

## Loop through DEREPLICATION REPRESENTATIVES
## For each one, add species and genome names and append genome to file
for representative in $(cat "$reps"); do
	# faa file path
	faa_file="${species_dir}/${representative/_genomic.fna.gz/_protein.faa}"
	# Make sure faa file exists to continue loop
	if [[ ! -f "$faa_file" ]]; then
		echo 'Warning! File does not exist in current protein collection:'
		echo "$faa_file"
		continue
	fi
	# Genome name to add to faa file
	genome=$(basename "$faa_file" | sed 's/_protein.faa//')
	# Add species and genome name at the beginning of summary line
	# before protein accession and separated by "|" (pipe)
	cat "$faa_file" | sed "s/^>/>${genome}|/; s/^>/>${species}|/" >> "${fasta_in}"
done

# Original number of genomes
n=$(ls "$species_dir" | wc -l)
echo -e "Original number of genomes:\t${n}\t${species}"
# Number of representatives
n=$(cat "$reps" | wc -l)
echo -e "Number of representatives:\t${n}\t${species}"
