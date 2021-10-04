#!/bin/bash

###-------------------------------------------------------------------------------------------------------------------------------------
### 2/25/2021 ###
## CheckM filtering set-up for highly sampled species

## Go to directory with genomes
cd ~/MyTaxa/dereplication/data

## Calculating how many processors or subjobs I would like to use for each species
# From checkM-install-usage.sh in 2020 weekly reports in 2020-09-fall:
# Assume about 10 minutes per genome
echo -e "n_genomes\tspecies\tminutes\thours\tdays\tprocs\ttot_procs\tgenomes_per_proc" > ~/MyTaxa/dereplication/experiments/2021-02-25-CheckM/n_subjobs.txt
tot_procs=0; for sp in $(ls genomes); do 
	n_genomes=$(cat ftp-lists/$sp.txt | wc -l);
	min=$((n_genomes*10))
	hr=$((min/60))
	days=$((hr/24))
	procs=$((days/3))
	tot_procs=$((tot_procs+procs)) # culumative total procs
	genomes_per_proc=$((n_genomes/procs))
	echo -e "$n_genomes\t$sp\t$min\t$hr\t$days\t$procs\t$tot_procs\t$genomes_per_proc";
done >> ~/MyTaxa/dereplication/experiments/2021-02-25-CheckM/n_subjobs.txt
# If number of subjobs = # of days estimated runtime / 3
# then it would run in about less than 3 days each
# and the total number of jobs running would be 427
# There are 400-500 genomes per proc

## Make lists of full paths to the genome sequences and split them into these numbers
# Go to current experiment directory
cd ~/MyTaxa/dereplication/experiments/2021-02-25-CheckM
# Make a new directory that will contain lists for each genome
mkdir genome-paths

## For each species, get all the full paths to the genomes
genomes_dir=~/MyTaxa/dereplication/data/genomes
for sp in $(ls "$genomes_dir"); do
	ls "$genomes_dir/$sp" > "genome-paths/$sp.txt"
done

## Split the paths
mkdir genome-paths-split
# Make each species directory
for sp in $(ls "$genomes_dir"); do
	mkdir "genome-paths-split/$sp"
done

# Rename the directory that contains all paths because it's easier 
mv genome-paths genome-paths-all

# For each spcies, split the paths into desired number of files
for sp in $(ls genome-paths-split); do
	# Number of procs for each:
	n=$(grep -P "\t$sp\t" n_subjobs.txt | awk '{print $6}')
	cd "genome-paths-split/$sp"
	split --numeric-suffixes --suffix-length 2 --number l/${n} "../../genome-paths-all/${sp}.txt"
	cd ../..
done

## CheckM tests to see if it works and how to run it
# Generate the table indicating all taxa for which a marker set can be produced
conda activate CheckM
checkm
# -bash: /storage/home/hcoda1/7/tkiryutina3/.conda/envs/CheckM/bin/checkm: /nv/hmicro1/tkiryutina3/.conda/envs/CheckM/bin/python: bad interpreter: No such file or directory
## ERROR: based on old shebang line:
head -1 /storage/home/hcoda1/7/tkiryutina3/.conda/envs/CheckM/bin/checkm
#!/nv/hmicro1/tkiryutina3/.conda/envs/CheckM/bin/python

## Delete CheckM environment
conda env remove --name CheckM
# Create it again, activate, and install CheckM
conda create --name CheckM
conda activate CheckM
conda install -c bioconda checkm-genome
# Test if CheckM works with a help command
checkm qa -h # works!

# Generate the table indicating all taxa for which a marker set can be produced
checkm taxon_list --rank "species" > checkm_species_list.txt
## For each species, search speices list for line containing speices
# otherwise, just print species
for sp in $(awk '{print $2}' n_subjobs.txt | tail -n +2); do 
	sp=$(echo $sp | sed 's/_/ /'); 
	grep "$sp" checkm_species_list.txt || echo $sp; 
done
#   species   Acinetobacter baumannii                                20           1018             298
#   species   Campylobacter coli                                     20           955              188
#   species   Campylobacter jejuni                                   20           903              161
# Clostridioides difficile
#   species   Enterococcus faecalis                                  20           792              298
#   species   Enterococcus faecium                                   20           885              257
#   species   Helicobacter pylori                                    20           773              143
#   species   Klebsiella pneumoniae                                  20           1598             383
#   species   Listeria monocytogenes                                 20           1262             179
#   species   Mycobacterium tuberculosis                             20           1077             383
#   species   Neisseria meningitidis                                 20           997              216
#   species   Pseudomonas aeruginosa                                 19           1617             469
#   species   Shigella flexneri                                      18           1512             333
#   species   Shigella sonnei                                        5            1936             302
#   species   Staphylococcus aureus                                  20           1169             170
#   species   Staphylococcus epidermidis                             20           933              208
#   species   Streptococcus pneumoniae                               20           845              160
#   species   Streptococcus pyogenes                                 20           885              150
#   species   Streptococcus suis                                     14           852              161

## "Clostridioides difficile" does not have a marker set

## Read CheckM GitHub for review and usage:
# See the word doc "CheckM-notes" in 2021 weekly reports, spring

## While reading the CheckM notes, decompress the collection of highly-sampled genomes
du -hs ~/MyTaxa/dereplication/data/genomes/
154G    genomes/

###-------------------------------------------------------------
### 2/26/2021 ###
cd ~/scratch
# Make a directory for each species in "genomes-unzipped"
for sp in $(ls ~/MyTaxa/dereplication/data/genomes/); do
	mkdir genomes-unzipped/$sp
done
# Count how many splits there are and make that many directories, numbered: (bins-1, bins-2, ...)
for sp in $(ls ~/MyTaxa/dereplication/data/genomes/); do
	n=$(ls ~/MyTaxa/dereplication/experiments/2021-02-25-CheckM/genome-paths-split/$sp/ | wc -l)
	cd genomes-unzipped/$sp
	seq 1 $n | xargs -I {} mkdir bins-{}
	cd ../..
done

# # Copy the genomes of one species
# sp=Streptococcus_suis
# cd $sp
# i=1
# for paths in $(ls ~/MyTaxa/dereplication/experiments/2021-02-25-CheckM/genome-paths-split/$sp/*); do
# 	echo "Copying $paths"
# 	echo "    to bins-${i} ..."
# 	for path in $(cat $paths); do
# 		cp ~/MyTaxa/dereplication/data/genomes/$sp/$path "bins-${i}/${path}"
# 	done
# 	# gunzip "bins-${i}"/*
# 	let "i+=1"
# done
# cd ..
# ## Note: realized this will take too long and should submit job arrays to copy and decomppress the stuff

## Rename the split genome paths to run job arrays
cd ~/MyTaxa/dereplication/experiments/2021-02-25-CheckM/genome-paths-split
for sp in *; do
	i=1
	for xfile in $sp/*; do
	mv $xfile $sp/$i
	echo "$(basename $xfile) -> $i"
	let "i+=1"
	done
done

## Created "unzip-genomes.pbs" which runs a job array for a given species and number of subjobs to
# Copy to scratch and unzip each genome. There are about 400-500 genomes each.
cd ~/MyTaxa/dereplication/experiments/2021-02-25-CheckM/outputs-unzip-genomes 

# Run only one as a test (worked)
sp=Streptococcus_suis
n=4
qsub -N "$sp" -t "1-${n}" -v "sp=$sp" ../unzip-genomes.pbs

# Run the rest except that one
for sp in $(ls ../genome-paths-split/ | head -n -1); do 
	echo $sp;
	n=$(ls ../genome-paths-split/$sp | wc -l)
	qsub -N "$sp" -t "1-${n}" -v "sp=$sp" ../unzip-genomes.pbs
done

# Many did not run because reached "Maximum number of jobs already in queue for user" in embers
# I commented out that line and submitted the yet unsubmitted ones - was able to submit this time!
for sp in $(cat ../sp-2-run.txt); do 
	echo $sp;
	n=$(ls ../genome-paths-split/$sp | wc -l)
	qsub -N "$sp" -t "1-${n}" -v "sp=$sp" ../unzip-genomes.pbs
done

## Start using the CheckM pipeline
cd ~/scratch
conda activate CheckM

## Run a taxonomy workflow for a supported species
checkm taxonomy_wf -h

## Batch job test "run-A.pbs" where main command is:
# checkm taxonomy_wf <rank> <taxon> <bin folder> <output folder>
checkm taxonomy_wf "species" "Acinetobacter baumannii" "Acinetobacter_baumannii-5-genomes" "results-A"

## Run a linege workflow for unsupported species

## Batch job test "run-C.pbs" where main command is:
# checkm lineage_wf <bin folder> <output folder>
checkm lineage_wf "Clostridioides_difficile-5-genomes" "results-C"
## Results: this didn't work so check it out later ...

## First double check the copy/unzip process
cd ~/MyTaxa/dereplication/experiments/2021-02-25-CheckM
cat outputs-unzip-genomes/* | grep -e 'Species:' -e 'Split size:' -e 'Downloaded:' -e 'Fna files:' > check.txt
# Look at "check.txt" in excel
# The ONLY difference is Streptococcus_suis. Check this one:
cat outputs-unzip-genomes/Streptococcus_suis.o952043-1
# Compare genomes that were supposed to be copied and actually copied
ls ~/scratch/genomes-unzipped/Streptococcus_suis/bins-1 > 1
cat genome-paths-split/Streptococcus_suis/1 | sed 's/\.gz//' > 2
diff 1 2
< GCA_000937295.1_Velvet_assembly_genomic.fna.gz
# This is the extra genome
grep 'GCA_000937295.1_Velvet_assembly_genomic.fna.gz' genome-paths-split/Streptococcus_suis/1
# GCA_000937295.1_Velvet_assembly_genomic.fna.gz
ls ~/scratch/genomes-unzipped/Streptococcus_suis/bins-1/ | grep 'GCA_000937295.1_Velvet_assembly_genomic.fna'
# Has both fna and gz so just remove the gz
rm ~/scratch/genomes-unzipped/Streptococcus_suis/bins-1/GCA_000937295.1_Velvet_assembly_genomic.fna.gz

## Run CheckM taxonomy workflow on a full species
cd ~/scratch/CheckM-job-outputs
sp="Streptococcus_suis"
n="$(ls ../genomes-unzipped/$sp | wc -l)"
qsub -N "$sp" -t "1-${n}" -v "sp=$sp" ../run-sp.pbs

# Generate list of all species and manually remove those that I can't or don't need to run
for sp in $(ls ../genomes-unzipped/); do echo $sp; done > sp-2-run.txt

# Submit for all the remaining species
for sp in $(cat sp-2-run.txt); do 
	echo $sp; 
	n=$(ls ../genomes-unzipped/$sp/ | wc -l); 
	qsub -N "$sp" -t "1-${n}" -v "sp=$sp" ../run-sp.pbs
done
