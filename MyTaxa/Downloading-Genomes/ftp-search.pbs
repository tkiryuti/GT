## Search for ftp links using Entrez Direct. Etracts associated species name and GenBank FTP link of search result.
## After this script, the next step is for the duplicate search results to be removed.

#PBS -N ftp-search
#PBS -j oe
#PBS -l nodes=1:ppn=1
#PBS -l walltime=10:00:00
#PBS -l pmem=5gb
#PBS -q biocluster-6
# #PBS -m abe
# #PBS -M tkiryuti@gatech.edu
cd $PBS_O_WORKDIR
echo "Started on `/bin/hostname`"

# Get species list
awk '{print $2}' ~/shared3/projects/MyTaxa/TypeMat_2020-08-17/Counts/s.tsv > spList

# Function to search a species on NCBI
# Input: species name
# Output: SpeciesName, FtpPath_GenBank (tab-separated)
function searchNCBI {
	sp=$1
	query=$(echo $sp | sed 's/_/ /g' | sed 's/\[//g' | sed 's/\]//g' | sed 's/(//g' | sed 's/)//g')
	esearch -db assembly -query "$query" < /dev/null | efetch -format docsum | xtract -pattern DocumentSummary -element SpeciesName FtpPath_GenBank
}

# Run function in a loop for each species
while read sp; do
	## Prep output file ...
	outFile="./searches/$sp"
	# If it exists, remove it
	[ -f "$outFile" ] && rm "$outFile"
	# Create anew
	touch "$outFile"
	# Apply search NCBI function
	searchNCBI $sp >> $outFile
done < spList

