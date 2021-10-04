#!/bin/bash
# Small cluster prep is for running with 1 thread for species with small number of genomes

## Clustering pangenome for one species
## This script prepares an input file for clustering

# Number of threads
threads=1

# Directory with all species/genomes
genome_dir="/nv/hmicro1/tkiryutina3/shared3/projects/MyTaxa/TypeMat_2020-08-17/Genomes/FTPs/genomes"

# Input argument is species name (with underscores - same as directory name for it in genome_dir)
species="$1"
if [[ -z "$species" ]]; then
	echo "Error: please provide species name (with underscores instead of species and forward slashes)"
	exit 1
fi

# Full path to the species directory that contains amino acid genomes from NCBI
species_dir="${genome_dir}/${species}"

# Indicate which species the script is working on
echo ''
echo '-----------------------------------------------------------------'
echo "Species: ${species}"

# Create target directory
target_dir="tmp-genomes/${species}"
if mkdir "${target_dir}"; then

	## Set up file where all the genomes will be appended to for clustering
	fasta_in="${target_dir}/${species}.fasta"
	# If tmp file already exists AND IS NOT EMPTY, remove it
	if [[ -s "${fasta_in}" ]]; then rm "${fasta_in}"; fi
	# Create empty instance of target tmp file to append to
	touch "${fasta_in}"

	# In a loop, add species and genome names and append each genome to file
	for faa_file_path in "${species_dir}/"*; do
		faa_file=$(basename "$faa_file_path")
		# Genomes name
		genome="${faa_file/_protein.faa.gz/}"
		# Add species and genome name at the beginning of summary line
		# Before protein accession and separated by "|" (pipe)
		gzip -cd "$faa_file_path" | sed "s/^>/>${genome}|/; s/^>/>${species}|/" >> "${fasta_in}"
	done

else
	echo "Directory for this species already exists: ${species}"
fi

# Print upon completion the number of genomes of that species
n=$(ls "$species_dir" | wc -l)
echo -e "Combined genomes: ${n}\t${species}"

### Running MMseqs2 (or not if one genome)
## Result directories
# Directory for representative sequences
reps_dir="/nv/hmicro1/tkiryutina3/scratch/MyTaxa/Pangenomes/Reps-at-90"
clusters_dir="/nv/hmicro1/tkiryutina3/scratch/MyTaxa/Pangenomes/Clusters-at-90"
# Go to target directory
cd "$target_dir"
# If only one genome, keep as is send it to representative sequences
# If more than one genome, run MMseqs2 script
if [[ "$n" -eq 1 ]]; then
	echo "One genome of ${species}: sending straight to representative sequences directory"
	# Compress the fasta file, and if works
	# clean up this temporary species directory from "tmp-genomes"
	gzip -c "${species}.fasta" > "${reps_dir}/${species}.faa.gz" && { cd .. ; rm -r "$species" ; }
else
	echo "More than one genome of ${species}: running MMseqs2 to cluster at 90 % id."
	# Run the MMseqs2 clustering script, and if works then 
	# clean up this temporary species directory from "tmp-genomes"
	cluster_sp="/nv/hmicro1/tkiryutina3/scratch/MyTaxa/Pangenomes/cluster-1-sp.sh"
	bash "$cluster_sp" "$species" "$threads" && { cd .. ; rm -r "$species" ; }
fi

