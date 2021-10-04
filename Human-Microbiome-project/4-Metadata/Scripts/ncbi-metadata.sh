#!/bin/bash

### NCBI Retrieve Metadata (ncbi-metadata.sh)

### INPUT: 

### REQUIREMENT: "ncbi-metadata.py"

usage() {
	echo "Usage: ${0} [-h] [-i input] [-o output]"
	echo "Example: ${0} -i input.tsv -o output.tsv"

	echo "Required:"
	echo " 	-i 	input file (path): "
	echo " 		tab-separated result from \"ncbi-extract-acc.sh\" with"
	echo "		accessions from SRA, BioSample, and BioProject databases"
	echo " 	-o 	output file name: "
	echo " 		tab-separated file with BioSample accession,"
	echo " 		geographic location, latitude, and longitude"
	
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

mkdir "tmp-met"

echo -e "BioSample\tgeoloc\tlatitude\tlongitude" > "$output"

for biosample in $(awk 'NR>1 {print $2}' "$input" | sort | uniq); do

	esearch -db biosample -query $biosample | efetch -format "native" > "tmp-met/metadata.tmp"

	python ncbi-metadata.py "$biosample" >> "$output"

done

rm -r "tmp-met"

