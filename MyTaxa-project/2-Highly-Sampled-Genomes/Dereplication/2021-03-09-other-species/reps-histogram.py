#!/usr/bin/env python

## Set-up command line parser
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("-s", "--species", help="Species_name to show on plot.")
parser.add_argument("-a", "--ani_file", help="FastANI data between representatives only.")
parser.add_argument("-g", "--genomes", help="File: original genome list to count number of input genomes before dereplication (one genome per line).")
parser.add_argument("-o", "--output", help="Output file for plot (include .png extension)")
args = parser.parse_args()

species = args.species
original_list = args.genomes
output = args.output
ANI_pairs_file = args.ani_file

## More parameters that could potentially be varied
dpi=100
hist_color='blue'

## Count original number of genomes (after CheckM filtering for this case)
counter = 0
with open(original_list) as fh:
    for line in fh:
        counter += 1

n_genomes = counter
print(f'Original number of genomes = {n_genomes}')

# Read file line by line and store ANI value (and genome ID to get reps only)
ANI_values_list = []
Reps = []
with open (ANI_pairs_file, 'r') as fh:
    for line in fh:
        Reps.append(line.split('\t')[0])
        Reps.append(line.split('\t')[1])
        ANI_value = line.split('\t')[2]
        ANI_values_list.append( float(ANI_value) )

## Check number of ANI between representatives
print(f'ANI-between-reps.tsv = {len(ANI_values_list)}')

## Check number of ANI reps
Reps = list(set(Reps))
n_reps = len(Reps)
print(f'Number of 99-dereplication representatives = {n_reps}')

# Minimum and maximum values in list
print(f'min = {min(ANI_values_list)}')
print(f'max = {max(ANI_values_list)}')

## Start plotting
print(f'... plotting outupt: {output}')

# Import packages
import re
import numpy as np
import matplotlib.pyplot as plt

plt.rcParams.update({'font.size': 14})

## Create the figure
fig, ((ax1), (ax2)) = plt.subplots(2, 1, figsize=(10,8))

## Set up the figure title
# fig.suptitle(species, fontweight='bold', fontsize=20, y=0.95)
species_name = species.replace("_"," ")
percent = round( 100 * n_reps / n_genomes , 1 )
info = f'{n_reps} / {n_genomes} are representatives ({percent} %)'
_ = plt.figtext(0.5, 0.96, species_name, fontsize=20, fontweight='bold', style='italic', ha='center')
_ = plt.figtext(0.5, 0.91, info, fontsize=20, ha='center', color='m') # https://matplotlib.org/2.0.2/examples/color/named_colors.html

## Name the common x label
plt.xlabel('FastANI estimate between 99% dereplication representatives', labelpad=15, fontweight='bold')

## Name and align y labels
ax1.set_ylabel('Number of comparisons', labelpad=15, fontweight='bold')
ax2.set_ylabel('log10(# of comparisons)', labelpad=15, fontweight='bold')
ax1.get_yaxis().set_label_coords(-0.1,0.5)
ax2.get_yaxis().set_label_coords(-0.1,0.5)

## Plot the histograms
_ = ax1.hist(ANI_values_list, 300, color=hist_color)
_ = ax2.hist(ANI_values_list, 300, color='light'+hist_color)
ax2.set_yscale('log')

## Create desired x-axis
# Flip x-axis
ax1.set_xlim(ax1.get_xlim()[::-1])
ax2.set_xlim(ax2.get_xlim()[::-1])
# Truncate minimal x-value based on ANI list
min_x = int(str(min(ANI_values_list)).split('.')[0])
# Get a range of x-ticks from max to min decreasing by 1
x = np.arange(99, min_x-1, -1)
# Plot the new ticks
_ = ax1.set_xticks(x)
_ = ax2.set_xticks(x)

# Save figure as a png
plt.savefig(output, bbox_inches='tight', dpi=dpi)
