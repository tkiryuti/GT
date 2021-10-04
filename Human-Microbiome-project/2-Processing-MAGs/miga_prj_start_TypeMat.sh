#!/bin/bash

# miga_prj_start.sh
MIGA_DIR="MIGA_TypeMat"

# If directory does not exist, make directory
# http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_01.html
[[ ! -d $MIGA_DIR ]] && mkdir $MIGA_DIR

cd $MIGA_DIR

# Specify variables
n1=$1; n2=$2
prj=$n1'_'$n2

# Create new miga project
miga new -P $prj -t genomes
cd $prj
# Specify reference database for taxonomy
miga edit -P . -m ref_project=/gpfs/pace2/project/bio-enveomics/MiGA/TypeMat
# miga edit -P . -m ref_project=/gpfs/pace2/project/bio-konstantinidis/eomics3/MiGA/NCBI_Prok
# Check project at any time:
miga about -P . 

# Add the datasets using a loop
file='../../paths_random.txt'
for path in $(awk -v i="$n1" -v j="$n2" 'NR==i, NR==j' $file); do
	echo " "
	echo "Path: $path"
	name=$(basename $path | sed 's/\.fa//g' | sed 's/\./_/g')

	# Add dataset to existing miga project
	# run_step ; Boolean ; Forces running or not step
		# https://manual.microbial-genomes.org/part5/metadata#datasets
		# https://manual.microbial-genomes.org/part5/workflow
	miga add -P . -D $name -t popgenome --assembly $path \
	-m run_mytaxa_scan=false,run_distances=false

	echo "Dataset added: $name"
done

echo " "
echo "-----------------------------------------------------------------"
echo "About project"
echo "-----------------------------------------------------------------"
miga about -P . 
echo "-----------------------------------------------------------------"
echo " "

~/shared3/miga-conf/start-me .

