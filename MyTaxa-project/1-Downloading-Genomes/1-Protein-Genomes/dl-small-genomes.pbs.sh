## An exceptional case of downloading genomes that were too small for Prodigal to predict
## There were 18 of these and eventually they were left out.
## This script is similar to the .fna download, but checks if the prodigal command works
## If the Prodigal command doesn't work, the .fna file is left for investigating later (and is not cleaned up)

#PBS -N small-genomes
#PBS -j oe
#PBS -l nodes=1:ppn=1
#PBS -l walltime=3:00:00
#PBS -l pmem=5gb
#PBS -q iw-shared-6
# #PBS -m abe
# #PBS -M tkiryuti@gatech.edu
cd $PBS_O_WORKDIR
echo "Started on `/bin/hostname`"

## Download genomes from NCBI (anew)
## To run this, indicate INFILE. Must be a full path!
# qsub -v INFILE=$full_path dl-genomes-v2.pbs

module load prodigal/2.6.1

# Go to main directory
mainDir=~/shared3/projects/MyTaxa/TypeMat_2020-08-17/Genomes/FTPs/small-genomes

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
		echo Downloading faa: "$ftpLink/$faa_file"
		# Attempt download (for the last time)
		if ! curl -O "$ftpLink/$faa_file"; then
			# If doesn't work, indicate that will try to get fna file
			echo Protein DNE: "$line"
		fi
	fi

	## If faa file doesn't exist, attempt to download fna file from ftp link
	if [[ ! -s "$faa_file" ]] ; then
		fna_file="$(basename $ftpLink)_genomic.fna.gz"
		if ! curl -O "$ftpLink/$fna_file"; then
			# If downloading genomic.fna doesn't work, indicate that need to retry
			echo Retry genomic: "$line"
		else
			# This is the case that if the download works
			echo Downloading fna: "$ftpLink/$fna_file"
			# Check that the file exists and use prodigal
			if [[ -s "$fna_file" ]]; then
				echo Running Prodigal: "$line" 
				faa_file_raw=$(basename "$faa_file" .gz)
				# Write output of zipped file without changing it and redirect to prodigal
				# If this command works, then remove the fna file. If not, leave for later
				if gzip -c -d "$fna_file" | prodigal -a "$faa_file_raw" -o /dev/null; then
					# Clean up the fna file
					rm "$fna_file"
				fi
				gzip "$faa_file_raw"
			fi
		fi
	fi

done < ${INFILE}

