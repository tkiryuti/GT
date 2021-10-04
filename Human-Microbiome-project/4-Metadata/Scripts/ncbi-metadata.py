#!/usr/bin/env python3

file="tmp-met/metadata.tmp"

import re

# Store biosample accession argument
import sys
biosample = str(sys.argv[1])

# Function to get next biosample search result
# Output is the next entry in form of a list
def get_next_entry(fh, entry):
	# fh: 		file handle
	# entry: 	input needs to be empty list
	for line in fh:
		if line is '\n':
			break
		line = line.strip('\n')
		match = re.search('\s/', line)
		if match:
			line = line.split('=')
			line[1] = line[1].strip('"')
			line[0] = line[0].strip(' ').strip('/')
			entry.append(line)
		else:
			entry.append(line)
	return(entry)

# Function to get geographic location data
# Output is a list of strings [geoloc, latitude, longitude]
def get_geo_loc(entry, geoloc, latitude, longitude):
	# entry: 	list that stores the search result of interest
	for line in entry:
		if line[0] == 'geographic location':
			geoloc = line[1]
		elif line[0] == 'geographic location (latitude)':
			latitude = line[1]
		elif line[0] == 'geographic location (longitude)':
			longitude = line[1]
	return( [geoloc, latitude, longitude] )

# Determine and store the right result
with open(file,"r") as fh:
	entry = get_next_entry(fh, [])
	looking = 'true'
	while looking == 'true':
		# Get description for checking - specific to Almeida et al. HMP MAG project
		for index, line in enumerate(entry):
			description = ''
			if line[0] == 'description':
				description = line[1]
				break
			elif line == 'Description:':
				description = entry[ index+1 ]
				break
		match = re.search("This sample represents a MAG from the metagenomic run ", description)
		# If description matches, check if it has geographical location metadata 
		if match:
			[geoloc, latitude, longitude] = get_geo_loc(entry, '', '', '')
			if geoloc == '':
				entry = get_next_entry(fh, [])
			else:
				looking = 'false'
		else:
			entry = get_next_entry(fh, [])
		# Check if finished going through file - then get out of this loop...
		if entry == []:
			geoloc, latitude, longitude = '', '', ''
			break

print(biosample, geoloc, latitude, longitude, sep='\t')

