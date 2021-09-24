#!/bin/bash

### This script discovers species names that contain non-alphanumeric characters

## See all the species names that contain non-alphabetic characters
# awk 'BEGIN {FS="\t"}; {print $1}' FTPs.tsv | sort | uniq | grep '[^a-zA-Z ]'

## See all the species that contain any non-alphanumeric characters
awk 'BEGIN {FS="\t"}; {print $1}' FTPs.tsv | sort | uniq | grep '[^a-zA-Z0-9 ]' > non-alphanumeric.txt

## More symbols in order of more common to least common:
# .-()[]:_'/

## All symbols accounted for here:
# cat t | grep -P "[^a-zA-Z0-9 \.\[\]\(\)\-\_\:\'\/]"

## How many times do certain symbols persist?
# For each symbol, find number of species names that has it:
chars=".\n-\n(\n)\n[\n]\n:\n_\n'\n/"
echo -e "${chars}" | while read symbol; do
	n_sp=$(grep -F "${symbol}" "non-alphanumeric.txt" | wc -l)
	echo -e "$symbol\t$n_sp"
done
