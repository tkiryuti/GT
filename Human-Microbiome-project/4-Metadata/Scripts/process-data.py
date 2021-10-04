#!/usr/bin/env python3

# Define file (accession, bioproject, location) data
accFile = "acc_prj_gl_edit.tsv"

# Create a {BioPrject: SRA Accessions} dictionary
Accessions = {}

# Initialize locations list
Locations = []

# Read line by line, polulate Accessinos dictionary and Locations
with open(accFile,"r") as accFH:
 for line in accFH:
  line = line.strip('\n').split('\t')
  if line[2] not in Locations:
   Locations.append(line[2])
  if line[1] not in Accessions:
   Accessions[line[1]] = [line[0]]
  else:
   Accessions[line[1]].append(line[0])






 
