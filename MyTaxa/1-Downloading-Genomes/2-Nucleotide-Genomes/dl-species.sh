#!/bin/bash

## Downloads genomes (nucleotide sequences) from ftp link list
	## if download doesn't already exist in working directory.

## Usage: ./dl-species.sh "$ftp_links_list" "$logs_directory"
## Input: list of ftp links
	## Example link from Staphylococcus_aureus.txt:
	## ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/000/009/005/GCA_000009005.1_ASM900v1

if [[ -z "$1" ]]; then
	echo "Error: did not provide input (list of ftp links)."
	exit 1
fi

if [[ -z "$2" ]]; then
	echo "Error: did not provide log file directory (to save standard output and error)."
	exit 1
fi

cat "$1" | while read ftp_link; do

	## Show ftp link (based on FtpPath_GenBank from entrez search)
	echo Link: "${ftp_link}"

	## Get fna file from ftp link
	fna_file="$(basename $ftp_link)_genomic.fna.gz"

	## If fna file exists already, skip rest of loop (if not then download it)
	# This is especially useful for updates
	if [[ -s "$fna_file" ]]; then
		echo File already exists: "$fna_file"
		continue
	else
		echo Downloading: "$ftp_link/$fna_file"
		# Attempt download or store for retry later
		# If doesn't work, tell to retry
		if ! curl -O "$ftp_link/$fna_file"; then
		echo Retry: "$line"
		fi
	fi

done &> "$2/$(basename $1)"
