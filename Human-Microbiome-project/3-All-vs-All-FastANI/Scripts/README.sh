#!/bin/bash

##-----------------------------------------------------##
## Directory & shortcut: ##
cd ~/data/projects-HMP_MAGs/Almeida_et_al_2019/MAGs_92143/MAGs
cd ~/data/MAGs

## Script: "all_vs_all.sh"
# Created 1128 jobs in subdirectory "PBS_jobs_all_0527"
cat all_vs_all.sh
# Example job that it generates:
cat PBS_jobs_all_0527/10_vs_10.pbs
# Runs FastANI on 2000-MAG directory vs. another

## There are 47 MAG directories
# All vs. all with 47 vs. 47 directories = 1128 (correct):
# 47*47/2 + 47/2 = 1128

## Subdirectory: "PBS_jobs_all_0527"
# All jobs that jun FastANI on 2000-MAG directory vs. another
ls PBS_jobs_all_0527 | wc -l
# 1128

## Subdirectory: "paths"
# Files with path per line to run FastANI with; example: 
cat paths/mags_10.txt | wc -l
# 2000

## Subdirectory: "Results"
# Contains results for each FastANI run (of 2000 vs. 2000 MAGs)
ls Results | wc -l
# 1128

## Script: "paths.sh"
# Creates the files of MAG paths in "paths" sub-directory
cat paths.sh

## Scripts/outputs: "run_jobs."*
# Ran the jobs in the subdirectory "PBS_jobs_all_0527"
ls "run_jobs."*

### Subdirectories
ls | grep -e '^19' -e '^20'
## 190626_Intermediate_ANI_85_to_95
## 190730_Intermediate_ANI
## 1907_Statistics
## 1908_Chi_Squared
## 1909_Recruitment
## 1910_Chi_Squared
## 1910_fastANI_Plot
## 1912_analysis
## 2001_gene-content

