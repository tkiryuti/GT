#!/bin/bash

### NCBI Extract Accessions (ncbi-extract-acc.sh)
# From Sequence Read Archive (SRA) accessions, extracts BioSample and BioProject accessions
# BioSample database stores metadata about each sample
# BioProject database stores information about research projects and links to data
# Data extraction based on Entrez Programming Utilities (https://www.ncbi.nlm.nih.gov/books/NBK179288/)

### INPUT: list of SRA accessions
# Note: DRR, ERR, and SRR prefixes means submitted to different databases:  SRR to NCBI, ERR to EBI and DRR to DDBJ

### OUTPUT: tab-separated file with SRA accession, corresponding BioSample accession, and corresponding BioProject accession

### REQUIREMENT: "ncbi-extract-acc.py"

usage() {
	echo "Usage: ${0} [-h] [-i input] [-o output]"
	echo "Example: ${0} -i input.txt -o output.tsv |& tee warning.txt"

	echo "Required:"
	echo " 	-i 	input file (path): "
	echo " 		list of SRA accessions with one accession per line"
	echo " 	-o 	output file name: "
	echo " 		tab-separated file with accessions from "
	echo " 		SRA, BioSample, and BioProject databases"
	
	echo "Optional:"
	echo " 	-h 	help, display this message"
}

while getopts ":i:o:h" option; do
	case ${option} in

		i) # Input file name
		input=$OPTARG;;

		o) # Output file name 
		output=$OPTARG;;
		
		h) # Print help
		usage
		exit 0;;
		
		?) # Print if invalid argument given
		echo "Error: an invalid flag was provided."
		echo "------------------------------------"
		usage
		exit 2;;

	esac
done

# Missing arguments
if [ $OPTIND == 1 ]; then 
	echo "Error: required flags are missing."
	echo "----------------------------------"
	usage
	exit 2
fi

shift $((OPTIND-1))

# Create output file with title
echo -e "SRA\tBioSample\tBioProject" > "$output"

mkdir "tmp-acc"

for query in $(cat "$input"); do

	biosample=''
	bioproject=''

	# Check counts for each query - for testing
	# for query in $(cat ACC-LIST.txt); do counts=$(esearch -db "sra" -query "$query" | xtract -pattern "ENTREZ_DIRECT" -element "Count"); echo "${counts}|${query}"; done

	# Store run info
	esearch -db "sra" -query "$query" | efetch -format "runinfo" | sed '/^$/d'> "tmp-acc/runinfo.tmp"

	# Convert run info into rows and colums
	python "ncbi-extract-acc.py" "$query" > "tmp-acc/runinfo-nice.tmp"

	# Get biosample and bioproject
	biosample="$(cat tmp-acc/runinfo-nice.tmp | grep -P "^BioSample\t" | awk '{print $2}')"
	bioproject="$(cat tmp-acc/runinfo-nice.tmp | grep -P "^BioProject\t" | awk '{print $2}')"

	echo -e "${query}\t${biosample}\t${bioproject}" >> "$output"

	rm "tmp-acc/runinfo.tmp" "tmp-acc/runinfo-nice.tmp"

	# Warn the biosample is missing
	if [ "$biosample" == '' ]; then
		echo "Warning: SRA ${query} missing BioSample accession. Retry or search manually on NCBI." >&2
	fi

	# Warn that bioproject is missing
	if [ "$bioproject" == '' ]; then
		echo "Warning: SRA ${query} missing BioProject accession. Retry or search manually NCBI." >&2
	fi

done

rm -r "tmp-acc"

### What to do in case of warnings:
# Retry can work for those accessions if connection timed out while running.
# Retry or search manually on NCBI.
# Command for finding entries with missing bioproject or biosample accession:
# cat output.tsv | sort -k2,2 | sort -k3,3 | head -13

### Future implementation plan:
# If search fails getting biosample or bioproject, retry the extraction a few times.

