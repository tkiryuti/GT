#!/bin/bash

### Downloading MAGs
## The 92,143 MAGs assembled by Almeida et al. with a CheckM quality score above 50 were retrieved using the wget command.

## Directory: ##
cd ~/data/projects-HMP_MAGs/Almeida_et_al_2019/MAGs_92143

## Script: "retrieve.pbs"
# Retrieves MAGs from Almeida et al. (nature, 2019)
# Downloads the 92,143 metagenome-assembled genomes (MAGs) with a quality score above 50
# (NOTE: includes CheckM analysis results of the 92,143 MAGs)
# Output: "ftp.ebi.ac.uk"
cat retrieve.pbs


