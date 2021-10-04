#!/bin/bash

### Processing MAGs
## The MAGs from the collection were taxonomically classified and quality-checked by running MiGA on the command line 
## (Rodriguez-R et al. 2018). A MiGA project was created first, then each MAG was added separately as a dataset. 
## The taxonomy for each MAG was obtained using the type material (TypeMat) database as a reference.

## Directory: ##
cd ~/data2/HMP-MAGs-MiGA-projects_Almeida-et-al

## Script: "miga_prj_start_TypeMat.sh"
# Creates new MiGA projects, specifies TypeMat as taxonomy db
# Adds each "dataset" (MAG) using a loop
cat miga_prj_start_TypeMat.sh

## Script: "miga_create_all.sh"
# Extremely similar to above script, but this one was run in a pbs project "miga_create.pbs"
# Created MiGA project "MiGA-Proj_HMP-MAG-collection" in the subdirectory "MIGA_TypeMat"
# Specified TypeMat as the reference database for taxonomy
# Added each dataset (MAG) via loop
cat miga_create_all.sh

## File: "paths_random.txt"
wc -l paths_random.txt
# 92143 paths_random.txt
# All paths to MAGs from the 2019 Almeida et al collection


