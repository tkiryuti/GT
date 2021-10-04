#!/usr/bin/env python3

## Filters fastANI-based clustering (dereplication) results to find ANI between representatives 
# If genome 1 and 2 in pair are both (different) reps, keep result
# If genome 1 and 2 in pair are the same, filter out result

representative_genomes_file="reps.txt"
ANI_results_file="ANI-results-short.tsv"


## Store all representative genome names in a list
reps_list = []
with open(representative_genomes_file, 'r') as fh:
	for line in fh:
		genome = line.strip('\n')
		reps_list.append(genome)

## Filter ANI results
# Go through ANI results line by line
# If line meets criteria, 
with open(ANI_results_file, 'r') as fh:
	for line in fh:
		# Convert line of data into a list
		ANI_pair_list = line.strip('\n').split('\t')
		# Store genomes from pair and the pairwise ANI value between them
		genome_1 = ANI_pair_list[0]
		genome_2 = ANI_pair_list[1]
		ANI_value = ANI_pair_list[2]
		# If first genome is not a representative, go to next line
		if genome_1 not in reps_list:
			continue
		# If second genome is not a representative, go to next line
		elif genome_2 not in reps_list:
			continue
		# If first and secnond genome are the same (self-comparison), go to next line
		elif genome_1 == genome_2:
			continue
		else:
			print(line.strip('\n'))
