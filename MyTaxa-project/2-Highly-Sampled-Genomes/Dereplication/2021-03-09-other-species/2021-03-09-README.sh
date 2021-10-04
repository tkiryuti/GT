#!/bin/bash

## E. coli dereplication at 99.9 % to avoid sequencing the same clone (remove clones)

cd ~/MyTaxa/dereplication
## Study differences of the dereplication script when running the most recent E. coli and S. enterica
diff 2021-01-15-derep-E-coli/bin/dereplication.pbs 2021-01-16-derep-S-enterica/bin/dereplication.pbs
< #PBS -l nodes=10:ppn=24
> #PBS -l nodes=20:ppn=24

## Copy it to bin
cp 2021-01-15-derep-E-coli/bin/dereplication.pbs bin

## Make the script more flexible and run in on E. coli with 99.9 % dereplication
cd experiments/2021-03-09
mkdir E-coli-derep-99.9
cd E-coli-derep-99.9/

## Run dereplication
cd ~/MyTaxa/dereplication/experiments/2021-03-09/E-coli-derep-99.9
input_genomes=~/MyTaxa/dereplication/2021-01-15-derep-E-coli/genome-lists/genomes-4-sorted-paths.txt
qsub -N "E-coli-99.9" -l nodes=10:ppn=24 -v "input_genomes=$input_genomes" ~/MyTaxa/dereplication/bin/dereplication-99.9.pbs

###--------------------------------------------------------------------------------------------------------------------------
### 3/12/2021 ###
cd ~/MyTaxa/dereplication/experiments/2021-03-09
## Run my dereplication program on some species with 2,000-3,000 genomes to test Galah.

## Think about number of nodes (24 proc each) to run
# E. coli genomes / procs = 86244 / 240 = 359.35 genomes per run
# 2000 / 24 = 83.33 genomes per run
# 3000 / 24 = 125 genomes per run
# So use only 1 node and 24 proc for all parallel runs with my program

## What is the number of sorted genomes?
wc -l ../2021-03-05/sorted-genomes/* | sort -nr
# Run the following (since under 2000):
	...
    1975 ../2021-03-05/sorted-genomes/Enterococcus_faecalis.txt
    1931 ../2021-03-05/sorted-genomes/Streptococcus_suis.txt
    1908 ../2021-03-05/sorted-genomes/Neisseria_meningitidis.txt

mkdir Derep-99
cd Derep-99

run() {
	sp=$1
	input_genomes=~/MyTaxa/dereplication/experiments/2021-03-05/sorted-genomes/${sp}.txt
	wc -l "$input_genomes"
	mkdir "$sp"
	cd "$sp"
	qsub -N "$sp" -l nodes=1:ppn=24 -v "input_genomes=$input_genomes" ~/MyTaxa/dereplication/bin/dereplication.pbs
	cd ..
}

sp="Enterococcus_faecalis"
run $sp

sp="Streptococcus_suis"
run $sp

sp="Neisseria_meningitidis"
run $sp

## Next day: done. Run final-dereplication (updated) on these species
run-final() {
	sp=$1
	input_genomes=~/MyTaxa/dereplication/experiments/2021-03-05/sorted-genomes/${sp}.txt
	wc -l "$input_genomes"
	cd "$sp"
	qsub -N "$sp" -v "input_genomes=$input_genomes" ~/MyTaxa/dereplication/bin/final-dereplication.pbs
	cd ..
}

sp="Enterococcus_faecalis"
run-final $sp
sp="Streptococcus_suis"
run-final $sp
sp="Neisseria_meningitidis"
run-final $sp

## Results:
# Streptococcus_suis has warning files with a lot of warnings:
# Warning: empty .tsv file in fastANI-results with query:
# This means somehow the genome didn't even compare to itself when running FastANI I think.

## Combine running first dereplication then final

run() {
	sp=$1
	rsrc=$2
	if [[ -d "$sp" ]]; then
		echo "Species directory already exists"
		return 0
	else
		echo "Running $sp on $rsrc"	
	fi
	# Find input genomes and go to species directory to run jobs
	input_genomes=~/MyTaxa/dereplication/experiments/2021-03-05/sorted-genomes/${sp}.txt
	wc -l "$input_genomes"
	mkdir "$sp"
	cd "$sp"
	# Run first iteration of dereplication. nodes and ppn must be specified.
	job_submitted=$(qsub -N "$sp" -l "$rsrc" -v "input_genomes=$input_genomes" ~/MyTaxa/dereplication/bin/dereplication.pbs)
	echo $job_submitted
	job_id=$(echo $job_submitted | sed 's/\..*//')
	# Run final dereplication
	qsub -W depend=afterok:"${job_id}" -N "$sp" -v "input_genomes=$input_genomes" ~/MyTaxa/dereplication/bin/final-dereplication.pbs
	# Go back at the end
	cd ..
}

# Check/view function code
type run

## Run more dereplication with my tool:
wc -l ~/MyTaxa/dereplication/experiments/2021-03-05/sorted-genomes/* | sort -nr | sed 's/\/storage.*genomes\///'
    # 3020 Clostridioides_difficile.txt
    # 2794 Streptococcus_pyogenes.txt
    # 2324 Enterococcus_faecium.txt
    # 2276 Staphylococcus_epidermidis.txt
    # 2048 Helicobacter_pylori.txt

rsrc="nodes=1:ppn=24"
sp=Clostridioides_difficile
run "$sp" "$rsrc"
sp=Streptococcus_pyogenes
run "$sp" "$rsrc"
sp=Enterococcus_faecium
run "$sp" "$rsrc"
sp=Staphylococcus_epidermidis
run "$sp" "$rsrc"
sp=Helicobacter_pylori
run "$sp" "$rsrc"

    # 7492 Shigella_sonnei.txt
    # 6701 Mycobacterium_tuberculosis.txt
    # 5953 Pseudomonas_aeruginosa.txt
    # 5374 Acinetobacter_baumannii.txt
    # 4869 Shigella_flexneri.txt

# 5000 / 24 = 208.33
# 8000 / 24 = 333.33

sp=Shigella_sonnei
run "$sp" "$rsrc"
sp=Mycobacterium_tuberculosis
run "$sp" "$rsrc"
sp=Pseudomonas_aeruginosa
run "$sp" "$rsrc"
sp=Acinetobacter_baumannii
run "$sp" "$rsrc"
sp=Shigella_flexneri
run "$sp" "$rsrc"

###____________________________________________ over 10 k ____________________________________________###
## Note: made mistake and had to delete, make sure refGenomes.txt is not overwritten, and restart jobs
cd ~/MyTaxa/dereplication/experiments/2021-03-09/Derep-99

run-10k() {
	sp=$1
	rsrc=$2
	if [[ -d "$sp" ]]; then
		echo "Species directory already exists"
		return 0
	else
		echo "Running $sp on $rsrc"	
	fi
	# Find input genomes and go to species directory to run jobs
	input_genomes=~/MyTaxa/dereplication/experiments/2021-03-05/sorted-genomes/${sp}.txt
	wc -l "$input_genomes"
	mkdir "$sp"
	cd "$sp"
	# Run first iteration of dereplication. nodes and ppn must be specified.
	job_submitted=$(qsub -N "$sp" -l "$rsrc" -v "input_genomes=$input_genomes" ~/MyTaxa/dereplication/bin/dereplication.pbs)
	echo $job_submitted; job_id=$(echo $job_submitted | sed 's/\..*//')
	# Run second iteration
	job_submitted=$(qsub -W depend=afterok:"${job_id}" -N "$sp" -l "nodes=1:ppn=24" -v "input_genomes=$input_genomes" ~/MyTaxa/dereplication/bin/dereplication.pbs)
	echo $job_submitted; job_id=$(echo $job_submitted | sed 's/\..*//')
	# Run final dereplication
	qsub -W depend=afterok:"${job_id}" -N "$sp" -v "input_genomes=$input_genomes" ~/MyTaxa/dereplication/bin/final-dereplication.pbs
	# Go back at the end
	cd ..
}

   # 16650 Staphylococcus_aureus.txt
   # 12725 Campylobacter_coli.txt
   # 10722 Klebsiella_pneumoniae.txt

# 10000 / (24*2) = 208.33
# 20000 / (24*2) = 416.66

rsrc="nodes=2:ppn=24"

sp="Staphylococcus_aureus"
run-10k "$sp" "$rsrc"
sp="Campylobacter_coli"
run-10k "$sp" "$rsrc"
sp="Klebsiella_pneumoniae"
run-10k "$sp" "$rsrc"

   # 31559 Campylobacter_jejuni.txt
   # 23079 Listeria_monocytogenes.txt
   # 22182 Streptococcus_pneumoniae.txt

# 30000 / (24*3) = 416.66

rsrc="nodes=3:ppn=24"

sp="Campylobacter_jejuni"
run-10k "$sp" "$rsrc"
sp="Listeria_monocytogenes"
run-10k "$sp" "$rsrc"
sp="Streptococcus_pneumoniae"
run-10k "$sp" "$rsrc"

###_________________________________________________________________________________________________###
## Stop and continue running E-coli dereplication
cd ~/MyTaxa/dereplication/experiments/2021-03-09/E-coli-derep-99.9
input_genomes=~/MyTaxa/dereplication/2021-01-15-derep-E-coli/genome-lists/genomes-4-sorted-paths.txt
qsub -N "E-coli-99.9" -l nodes=30:ppn=24 -v "input_genomes=$input_genomes" ~/MyTaxa/dereplication/bin/dereplication-99.9.pbs

###_________________________________________________________________________________________________###
### 3/18/2021 ###
## Checking warnings from dereplication
cd ~/MyTaxa/dereplication/experiments/2021-03-09

cat Derep-99/Streptococcus_suis/Warning.1128376
# Warning: empty .tsv file in fastANI-results with query: GCA_002760285.1_ASM276028v1
# Removed this genome path from the reference genomes input file: /storage/home/hcoda1/7/tkiryutina3/MyTaxa/dereplication/data/genomes/Streptococcus_suis/GCA_002760285.1_ASM276028v1_genomic.fna.gz

genome=/storage/home/hcoda1/7/tkiryutina3/MyTaxa/dereplication/data/genomes/Streptococcus_suis/GCA_002760285.1_ASM276028v1_genomic.fna.gz
~/data/Tools/fastANI --query "${genome}" --ref "${genome}" --minFraction "0.5" --output test.txt 

## Collect all the failed genomes
mkdir genomes-failed

for spdir in Derep-99/*; do 
	sp=${spdir/Derep-99\//};
	if ls $spdir/Warning.* &> /dev/null; then
	for genome in $(cat $spdir/Warning.* | grep 'Removed' | sed 's/Removed this genome path from the reference genomes input file: //'); do
	ls "$genome"
	filename="${sp}-$(basename $genome)"
	cp "$genome" "genomes-failed/$filename"
	done
	fi
done

## Run fastANI on each genome vs. itself
mkdir test-genomes
for genome in $(ls genomes-failed); do
	~/data/Tools/fastANI --query "genomes-failed/${genome}" --ref "genomes-failed/${genome}" --minFraction "0.5" --output "test-genomes/${genome/.fna.gz/.txt}"
done
## As expected, ALL the fastANI outputs are blank!!!

## Try a different fraction
mkdir test-genomes-0.4
for genome in $(ls genomes-failed); do
	~/data/Tools/fastANI --query "genomes-failed/${genome}" --ref "genomes-failed/${genome}" --minFraction "0.4" --output "test-genomes-0.4/${genome/.fna.gz/.txt}"
done
cat test-genomes-0.4/* | wc -l
# 10 results appear this time lowering the min fraction

# There were 81 genomes in total that are NOT able to aligned vs. themselves even with fastANI ... 
# I am not sure why that is. Why wouldn't genoems be able to be aligned vs. themselves?
# This happens for the following for this many genomes:
     # 26 Streptococcus_suis
     # 16 Klebsiella_pneumoniae
     # 11 Campylobacter_jejuni
     #  9 Mycobacterium_tuberculosis
     #  6 Staphylococcus_aureus
     #  5 Acinetobacter_baumannii
     #  3 Streptococcus_pneumoniae
     #  3 Pseudomonas_aeruginosa
     #  1 Listeria_monocytogenes
     #  1 Campylobacter_coli

###_________________________________________________________________________________________________###
### 2/23/2021 ### 
## Cluster analysis

## Adopted cluster-analysis.sh from previous (E. coli / S. enterica) dereplication results.
# cluster-analysis.pbs runs the .sh in a loop for each Derep-99 result

###_________________________________________________________________________________________________###
### 2/25/2021 ### 
## FastANI histogram plots
cd ~/MyTaxa/dereplication/experiments/2021-03-09/Derep-99/Acinetobacter_baumannii/cluster-analysis

## Created jupyter notebook to figure out code ("reps-histogram.ipynb")
## Saved it as a python script and added argument options
## Example that works:
python3 reps-histogram.py -g "../genome-lists/original-list.txt" -s "Acinetobacter_baumannii" -o "plot.png"
# Original number of genomes = 5374
# ANI-between-reps.tsv = 24693
# Number of 99-dereplication representatives = 224
# min = 87.5079
# max = 98.9993
# ... plotting outupt: plot.png

## Run this script in a loop for all plots
cd ~/MyTaxa/dereplication/experiments/2021-03-09
cp Derep-99/Acinetobacter_baumannii/cluster-analysis/reps-histogram.py .
# Make shortcuts for E. coli and S. enterica
cd Derep-99
ln -s ~/MyTaxa/dereplication/2021-01-16-derep-S-enterica "Salmonella_enterica"
ln -s ~/MyTaxa/dereplication/2021-01-15-derep-E-coli "Escherichia_coli"
# Copy original genome lists
cd Escherichia_coli/genome-lists/
ln -s genomes-4-sorted-paths.txt original-list.txt
cd ../..
cd Salmonella_enterica/genome-lists/
ln -s genomes-4-sorted-paths.txt original-list.txt
cd ../../..

# Run for each species
for species in $(ls Derep-99/); do 
	echo '----------------------------------------'
	echo "$species | $(date)"
	ani_data="Derep-99/$species/cluster-analysis/ANI-between-reps.tsv"
	input_genomes="Derep-99/$species/genome-lists/original-list.txt"
	output_png="plots/${species}.png"
	python3 reps-histogram.py -s "$species" -a "$ani_data" -g "$input_genomes" -o "$output_png"
	echo ''
done | tee reps-histogram.log

## Update "reps-histogram.py" to generate statistics in third subplot
## Re-run the above loop

## Missing plots:

# ----------------------------------------
# Mycobacterium_tuberculosis | Thu Mar 25 18:35:47 EDT 2021
# Original number of genomes = 6701
# ANI-between-reps.tsv = 0
# Number of 99-dereplication representatives = 0
# ----------------------------------------
cd Derep-99/Mycobacterium_tuberculosis
# This one got a cluster size of 6692
# There is one representative and the rest are over 99 % close to it (checked manually in:)
awk '{print $3}' fastANI-results/GCA_003383395.1_ASM338339v1.clstr | sort -nr | uniq | less
# In the final run there were 9 remaining genomes and they had warnings (didn't even cluster vs. themselves)
# Since there is only 1 ANI rep, it makes sense that there are 0 ANIs between reps (0 lines in ANI-between-reps.tsv)

# ----------------------------------------
# Shigella_sonnei | Thu Mar 25 18:36:17 EDT 2021
# Original number of genomes = 7492
# ANI-between-reps.tsv = 0
# Number of 99-dereplication representatives = 0
# ----------------------------------------
cd ../Shigella_sonnei/
# This one got a cluster size of 7492
# There is one representative and the rest are over 99 % close to it (checked manually in:)
awk '{print $3}' fastANI-results/GCA_008727295.1_ASM872729v1.clstr | sort -nr | uniq | less
# There are no warnings in this case. Otherwise same case as above (only 1 rep)

cd ~/MyTaxa/dereplication/experiments/2021-03-09
cat Derep-99/Mycobacterium_tuberculosis/genome-lists/original-list.txt | wc -l
6701
cat Derep-99/Shigella_sonnei/genome-lists/original-list.txt | wc -l
7492

## SEE WRITE-UP ABOUT PLOTS IN LAB NOTEBOOK

## Look at Streptococcus_suis
cd ~/MyTaxa/dereplication/experiments/2021-03-09/Derep-99/Streptococcus_suis/cluster-analysis
## Number of pairs in 85.5-89.5 range:
awk '$3 > 85.5 {print $0}' ANI-between-reps.tsv | awk '$3 < 89.5' | wc -l 
# 1975
## Number of pairs in 80-81 range:
awk '$3 > 80 {print $0}' ANI-between-reps.tsv | awk '$3 < 81' | wc -l
# 64
## 
awk '$3 > 80 {print $0}' ANI-between-reps.tsv | awk '$3 < 81' | awk '{print $2}' | sort | uniq -c
#     63 GCA_002759445.1_ASM275944v1_genomic.fna.gz
#      1 GCA_003933285.1_ASM393328v1_genomic.fna.gz
awk '$3 > 80 {print $0}' ANI-between-reps.tsv | awk '$3 < 81' | grep 'GCA_003933285.1_ASM393328v1_genomic.fna.gz'
# GCA_002759445.1_ASM275944v1_genomic.fna.gz      GCA_003933285.1_ASM393328v1_genomic.fna.gz      80.8222 322     636

## Investigate this problematic genomes which is in all of these pairs:
# GCA_003933285.1_ASM393328v1_genomic
cd /storage/home/hcoda1/7/tkiryutina3/MyTaxa/DB-TypeMat
grep 'GCA_003933285.1_ASM393328v1' FTPs.tsv
# Streptococcus suis      ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/003/933/285/GCA_003933285.1_ASM393328v1

## Look at 
cd ~/MyTaxa/dereplication/experiments/2021-03-09/Derep-99/Campylobacter_jejuni/cluster-analysis/
awk '$3 < 82 {print $0}' ANI-between-reps.tsv  | wc -l
# 80
awk '$3 < 79.6 {print $0}' ANI-between-reps.tsv | awk '$3 > 78.6 {print $0}' | wc -l
# 80
## Equivalent to ~78.6-79.6%
# Find problematic genomes
awk '$3 < 80 {print $2}' ANI-between-reps.tsv | sort | uniq -c
      1 GCA_002177345.1_ASM217734v1_genomic.fna.gz
     56 GCA_002177675.1_ASM217767v1_genomic.fna.gz
     23 GCA_004986625.1_PDT000267911.2_genomic.fna.gz
# Get their links
cat ~/MyTaxa/DB-TypeMat/FTPs.tsv | grep 'GCA_002177675.1_ASM217767v1'
# Campylobacter jejuni    ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/002/177/675/GCA_002177675.1_ASM217767v1
cat ~/MyTaxa/DB-TypeMat/FTPs.tsv | grep 'GCA_004986625.1_PDT000267911.2'
cat ~/MyTaxa/DB-TypeMat/FTPs.tsv | grep 'GCA_004986625.1_PDT000267911.2'
# Campylobacter jejuni    ftp://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/004/986/625/GCA_004986625.1_PDT000267911.2

###_________________________________________________________________________________________________###
## E-coli-derep-99.9 finished with 1505 genomes remaining (98.25 % clustered)
## Run next iteration
cd ~/MyTaxa/dereplication/experiments/2021-03-09/E-coli-derep-99.9
input_genomes=~/MyTaxa/dereplication/2021-01-15-derep-E-coli/genome-lists/genomes-4-sorted-paths.txt
qsub -N "E-coli-99.9" -l nodes=5:ppn=24 -v "input_genomes=$input_genomes" ~/MyTaxa/dereplication/bin/dereplication-99.9.pbs
qsub -W depend=afterok:1504523 -N "E-coli-99.9" -l nodes=1:ppn=24 -v "input_genomes=$input_genomes" ~/MyTaxa/dereplication/bin/dereplication-99.9.pbs
qsub -W depend=afterok:1504588 -N "E-coli-99.9-final" -v "input_genomes=$input_genomes" ~/MyTaxa/dereplication/bin/final-dereplication-99.9.pbs

## Final didn't run ... run again ... 
cd ~/MyTaxa/dereplication/experiments/2021-03-09/E-coli-derep-99.9
input_genomes=~/MyTaxa/dereplication/2021-01-15-derep-E-coli/genome-lists/genomes-4-sorted-paths.txt
qsub -N "E-coli-99.9-final" -v "input_genomes=$input_genomes" ~/MyTaxa/dereplication/bin/final-dereplication-99.9.pbs

## E-coli-derep-99.9 DONE!!!

## Run cluster analysis
cd ~/MyTaxa/dereplication/experiments/2021-03-09/E-coli-derep-99.9
qsub cluster-analysis.pbs
## UPDATE: TAKING VERY LONG - deleted job and doing this in scratch now. 
# The files that are being created in cluster-analysis.pbs are taking a lot of space so far
## ___ HOW MUCH SPACE DOES THIS WHOLE PROCESS TAKE ?? ___ ## 
# <(O_O)>[E-coli-derep-99.9]-> du -hs *
# 4.0K    2021-03-22-status.html
# 175G    cluster-analysis
# 4.0K    cluster-analysis.o1508269
# 4.0K    cluster-analysis.pbs
# 48K     E-coli-99.9-final.o1507834
# 864K    E-coli-99.9.o1111737
# 3.2M    E-coli-99.9.o1135377
# 4.5M    E-coli-99.9.o1192694
# 11M     E-coli-99.9.o1241750
# 14M     E-coli-99.9.o1414616
# 1.2M    E-coli-99.9.o1504523
# 220K    E-coli-99.9.o1504588
# 9.4G    fastANI-results
# 40M     genome-lists
# 362M    launcher-logs
# 12K     nodes.1111737
# 28K     nodes.1135377
# 28K     nodes.1192694
# 28K     nodes.1241750
# 28K     nodes.1414616
# 8.0K    nodes.1504523
# 4.0K    nodes.1504588
# 4.5G    subjob-logs
# 200K    tmp-ANI-logs
# 36K     tmp-ANI-outputs
# 40K     tmp-ref-genomes
# 4.0K    Warning.1504523
# 4.0K    Warning.1504588
## __ HOW MANY FILES DID THIS WHOLE PROCESS PRODUCE ?? __ ##
# find . -type f | wc -l
# 96386

## Create a cluster-analysis directory in scratch and link to it
ln -s ~/scratch/MyTaxa/dereplication/experiments/2021-03-09/E-coli-derep-99.9/cluster-analysis/
qsub cluster-analysis.pbs

## Run the FastANI histogram plot
# See code above: 2/25/2021

###--------------------------------------------------------------------------------------------###
### Look at E. coli 99.9 data

cd ~/scratch/MyTaxa/dereplication/experiments/2021-03-09/E-coli-derep-99.9/cluster-analysis

## File too big so need to just get ANIs
# 29G     ANI-between-reps.tsv

awk '{print $3}' ANI-between-reps.tsv > ANI-list.txt
du -hs ANI-list.txt
# 2.2G    ANI-list.txt
# much better

### Get cluster sizes
# Go through each .clstr file in fastANI results
# Count number of lines (that's number of members including representative)
# Print number of members and name of representative (tab-delimited)
for cluster in $(find ~/MyTaxa/dereplication/experiments/2021-03-09/E-coli-derep-99.9/fastANI-results -name "*.clstr"); do  
	rep=$(echo "$cluster" | sed 's/.*fastANI-results\///; s/\.clstr//')
	n_members=$(cat "$cluster" | wc -l)
	echo -e "${n_members}\t${rep}"
done > "n_members.tsv"

###--------------------------------------------------------------------------------------------###
### 4/15/2021
## Look at low ANI in E. coli and Salmonella. Find paper that published it. Run through MiGA with MyTaxa.

##___E coli___##
cd Derep-99/Escherichia_coli/cluster-analysis/
# Number of ANI comparisons between all reps
cat ANI-between-reps.tsv | wc -l
318,801
# Number of those ANI comparisons under 93.25 (= under 94)
cat ANI-between-reps.tsv | awk '$3 < 93.25' | wc -l
33,881
# Get rep counts for the comparisons under 94
cat ANI-between-reps.tsv | awk '$3 < 94 {print $1 "\n" $2}' | sort | uniq -c | sort -nr | sed 's/^[ ]*//' | awk '{print $1 "\t" $2}' > tmp-lt-93.25.txt
# Check number of representatives (correct)
cat tmp-lt-93.25.txt | wc -l; cat reps.txt | wc -l
799
799
## Studying rep counts
# Category 1: 755 reps each appear exactly 44 times
cat tmp-lt-93.25.txt | awk '$1 == 44' | wc -l
755
# Category 2: 44 reps appear over 780 times
cat tmp-lt-93.25.txt | awk '$1 > 780' | wc -l
44
## Downloading examples
# Get ftp links of a few genomes and download to my PC to run through MiGA
cat tmp-lt-93.25.txt | awk '$1 > 780' | head -5 | awk '{print $2}' | sed 's/_genomic.fna.gz//' \
| xargs -I {} grep "{}$" ~/MyTaxa/TypeMat_2020-08-17/Genomes/FTPs/FTPs.tsv \
| awk -F '\t' '{print $2}' | xargs -I {} sh -c 'echo {}/$(basename {})_genomic.fna.gz'

##___S enterica___##
cd ../../Salmonella_enterica/
cd cluster-analysis/
# Number of ANI comparisons between all reps
cat ANI-between-reps.tsv | wc -l
369,617
# Number of those ANI comparisons under 96.5
cat ANI-between-reps.tsv | awk '$3 < 96.5' | wc -l
28,457
# Number of those ANI comparisons under 91.05
cat ANI-between-reps.tsv | awk '$3 < 91.05' | wc -l
2571
# Get rep counts for the comparisons under 91.05
cat ANI-between-reps.tsv | awk '$3 < 91.05 {print $1 "\n" $2}' | sort | uniq -c | sort -nr | sed 's/^[ ]*//' | awk '{print $1 "\t" $2}' > tmp-lt-91.txt
# Check number of representatives (very close)
cat tmp-lt-91.txt | wc -l; cat reps.txt | wc -l
860
861
## Studying rep counts
# Category 1: 857 reps appear exactly 3 times
cat tmp-lt-91.txt | awk '$1 == 3' | wc -l
857
# Category 2: 3 reps appear exactly 857 times
cat tmp-lt-91.txt | awk '$1 == 857' | wc -l
3
## Downloading examples
# Get ftp links of a few genomes and download to my PC to run through MiGA
cat tmp-lt-91.txt | awk '$1 == 857' | awk '{print $2}' | sed 's/_genomic.fna.gz//' \
| xargs -I {} grep "{}$" ~/MyTaxa/TypeMat_2020-08-17/Genomes/FTPs/FTPs.tsv \
| awk -F '\t' '{print $2}' | xargs -I {} sh -c 'echo {}/$(basename {})_genomic.fna.gz'
