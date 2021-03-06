## First iteration of downloading genomes from NCBI
## Only downloads .faa links that exist
## Input file must be tab separated with species in column 1 and ftp link in column 2

#PBS -N dl-genomes
#PBS -j oe
#PBS -l nodes=1:ppn=1
#PBS -l walltime=10:00:00:00
#PBS -l pmem=5gb
#PBS -q biocluster-6
# #PBS -m abe
# #PBS -M tkiryuti@gatech.edu
cd $PBS_O_WORKDIR
echo "Started on `/bin/hostname`"

## Download genomes from NCBI (anew)
## To run this, indicate INFILE. Must be a full path!
# qsub -v INFILE=$full_path dl-genomes-v2.pbs

module load prodigal/2.6.1

# Go to main directory
mainDir=~/shared3/projects/MyTaxa/TypeMat_2020-08-17/Genomes/FTPs/genomes

while read line; do

	# Go back to main directory (absolute path)
	cd $mainDir

	# Show progress
	echo '------------------------------------------------------------------------------------------'
	echo Processing: "$line"

	# Species based on SpeciesName from entrez search
	species=$(echo "$line" | sed 's/\t.*//; s/ /_/g' | sed 's/\//_/')

	# Make species directory if it doesn't already exist
	if [[ ! -d "$species" ]]; then
		mkdir "$species"
		# Keep track of directories that are created
		echo Directory created: "$species"
	fi

	# Go to species directory
	cd "$species"

	# ftp link based on FtpPath_GenBank from entrez search
	ftpLink=$(echo "$line" | sed 's/.*\t//')
	echo Link: "$ftpLink"

	# faa file from ftp link
	faa_file="$(basename $ftpLink)_protein.faa.gz"

	## If faa file exists already, skip rest of loop (if not then download it)
	# This is especially useful for updates
	if [[ -s "$faa_file" ]]; then
		echo File already exists: "$faa_file"
		continue # Make sure to go back to main directory at the beiginning of the loop
	else
		echo Downloading: "$ftpLink/$faa_file"
		# Attempt download or store for retry later
		# If doesn't work, tell to retry
		if ! curl -O "$ftpLink/$faa_file"; then
			echo Retry: "$line"
		fi
	fi

done < ${INFILE}

