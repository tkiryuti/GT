#!/bin/bash

## Run fastANI on one query vs. a database chunk
# launcher will run this script in parallel at every iteration

## Usage
# fastANI_para "$genome_ID" "$query_genome" "$db_chunk"

## Define inputs
genome_ID="${1}"
query_genome="${2}"
db_chunk="${3}"

## Define outputs
fastANI_stout="tmp-ANI-logs/${genome_ID}-${db_chunk}.log"
subjob_log="subjob-logs/${genome_ID}.log"

## Output when function was submitted
echo "... starting FastANI | $(date) | $(hostname) | Query: ${genome_ID} | DB_chunk: ${db_chunk}" >> "${subjob_log}"

## Run FastANI tool
if ~/data/Tools/fastANI \
	--query "${query_genome}" \
	--refList "tmp-ref-genomes/${db_chunk}" \
	--output "tmp-ANI-outputs/${db_chunk}" \
	--minFraction "0.5" --threads "1" \
	2> "${fastANI_stout}"
then
	# If fastANI command works, gzip the standard output in "tmp-ANI-logs" and print success in subjob log
	gzip "${fastANI_stout}"
	echo "FastANI success | $(date) | $(hostname) | Query: ${genome_ID} | DB_chunk: ${db_chunk}" >> "${subjob_log}"
	exit 0
else
	# If fastANI command does not work, print that there was a fastANI failure and indicate non-zero exit status
	echo "FastANI failure | $(date) | $(hostname) | Query: ${genome_ID} | DB_chunk: ${db_chunk}" >> "${subjob_log}"
	exit 1
fi

