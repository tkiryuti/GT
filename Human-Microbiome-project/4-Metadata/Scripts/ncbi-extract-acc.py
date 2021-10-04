#!/usr/bin/env python3

# Converts data format of SRA run info
file = "tmp-acc/runinfo.tmp"

# Store SRA accession argument
import sys
query = str(sys.argv[1])

# Store the headings in "titles" and run-specific information in "bodies"
with open(file,"r") as fh:
	titles = fh.readline().strip("\n").split(",")
	bodies = []
	for line in fh:
		line = line.strip("\n").split(",")
		bodies.append(line)

# Select which run information is directly from the SRA query
for info in bodies:
	if info[0] == query:
		correctInfo = info

# Print information in tab-separated format
for index,heading in enumerate(titles):
	print(heading, correctInfo[index], sep='\t')

