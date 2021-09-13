#!/bin/bash

## Interactive Compute Session
# https://docs.pace.gatech.edu/interactiveJobs/interactive_cmd/

# Modify if needed, copy-paste, and run this in the terminal to request an interactive session:
qsub -A GT-ktk3 -l walltime=05:00:00 -l nodes=1:ppn=24 -l pmem=7gb -q inferno -I
