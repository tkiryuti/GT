#!/bin/bash

## CheckM failed over the weekend for two reasons
# 1) scratch ran out of space before so many outptus were produced over the weekend
# 2) the setup for using job-arrays was wrong and outputs over-wrote each other

## What I will do today
# 1) run testing with CheckM taxonomy workflow (step by step, not the whole workflows)
# 2) setup job arrays right
# 3) setup so that intermediate files get deleted

## Testing CheckM
cd ~/scratch
conda activate CheckM
# Produce marker set for specific speies (4 sec)
time checkm taxon_set "species" "Acinetobacter baumannii" "Acinetobacter_baumannii.ms"
# Create bins and output directories
mkdir bins
mkdir out
# Copy one example genome to bins directory
cp Acinetobacter_baumannii-5-genomes/GCA_000015425.1_ASM1542v1_genomic.fna bins
# Identify marker genes within each genome bin and estimate completeness and contamination
time checkm analyze "Acinetobacter_baumannii.ms" "bins" "out"
# Compare space
du -hs bins out
3.9M    bins
7.1M    out
# Produce different tables summarizing the quality of each genome bin.
time checkm qa "Acinetobacter_baumannii.ms" "out"

## Produce a marker file for each species in a loop
mkdir CheckM-marker-files
for sp in $(ls genomes-unzipped); do 
	echo $sp;
	checkm taxon_set "species" "${sp/_/ }" "CheckM-marker-files/${sp}.ms"
done
## Error for this species as expected:
# Clostridioides_difficile
# [2021-03-01 13:41:22] ERROR: Unrecognized taxon: Clostridioides difficile (in rank species):

## Produce all directories required for parallelized bins and outputs
# Use same directory architecture as unzipped genomes
for sp in $(ls genomes-unzipped); do
	mkdir -p tmp-bin/$sp
	mkdir -p tmp-out/$sp
done
# Create bins directories
for sp in $(ls genomes-unzipped); do
	echo $sp
	for dir in $(ls genomes-unzipped/$sp); do
		mkdir -p "tmp-bin/${sp}/${dir/bins-/}"
		mkdir -p "tmp-out/${sp}/${dir/bins-/}"
	done
done
# Remove the unrunnable one
rm -r tmp-bin/Clostridioides_difficile/
rm -r tmp-out/Clostridioides_difficile/

## Test species that doesn't have markers available
cd ~/scratch/test-Clostridioides_difficile
mkdir bin out
# Put one genome in bin
cp 5-genomes/GCA_000003215.1_ASM321v1_genomic.fna bin
# Place genome bins into a reference genome tree (5 min)
time checkm tree "bin" "out"
# Create a marker file indicating lineage-specific marker sets suitable for evaluating each genome. (17 sec)
time checkm lineage_set "out" "Clostridioides_difficile.ms"
# Identify marker genes within each genome bin and estimate completeness and contamination (2 min)
time checkm analyze "Clostridioides_difficile.ms" "bin" "out"
# Produce different tables summarizing the quality of each genome bin
time checkm qa "Clostridioides_difficile.ms" "out"

## Time to run CheckM
# Make results dir and each species dir in it
mkdir tmp-results
for sp in $(ls tmp-bin); do mkdir tmp-results/$sp; done

## Create and produce "run-CheckM.pbs"

## Start CheckM run for all species
cd ~/scratch/tmp-job-outputs

## Run job array for each species in a loop
for sp in $(ls ../tmp-bin); do 
	echo $sp; 
	n=$(ls ../tmp-bin/${sp} | wc -l)
	qsub -N "$sp" -t "1-${n}" -v "sp=$sp" ../run-CheckM.pbs
done

## Copy script to "run-CheckM-lineage.pbs" to run lineage-specific workflow
cd ~/scratch
sp="Clostridioides_difficile"
n=$(ls genomes-unzipped/$sp | wc -l)
# Create directories for results in ~/scratch/$sp
mkdir -p $sp/tmp-bin $sp/tmp-job-outputs $sp/tmp-out $sp/tmp-results
for dir in $(ls genomes-unzipped/$sp); do
	mkdir -p "${sp}/tmp-bin/${dir/bins-/}"
	mkdir -p "${sp}/tmp-out/${dir/bins-/}"
done

## Nevermind, try to run first step of lineage workflow on ALL C. difficile genomes
# Copy all genomes into one bin in a new batch job
# Here are the main commands in batch job:
cd ~/scratch
for genome in genomes-unzipped/Clostridioides_difficile/bins-*/*; do cp $genome Clostridioides_difficile/; done

cd ~/MyTaxa/dereplication/experiments/2021-03-01
mkdir Clostridioides_difficile
cd Clostridioides_difficile
mkdir out

# Run script that runs first step (checkm tree)
qsub ../lineage-1.pbs

###------------------------------------------------------------------------------------------------------------------------------
###------------------------------------------------------------------------------------------------------------------------------
###------------------------------------------------------------------------------------------------------------------------------
### 3/2/2021 ###

## lineage-1.pbs completed in 1 hours 20 min. run next step, lineage-2.pbs.
# lineage-2.pbs completed, lineage-3.pbs created and running, and lineage-4.pbs created and ready

## Checking CheckM results for one completed species
# Currently, half of the job arrays completed and half are still running
# I will test results for "Helicobacter_pylori" (arbitrarily chosen except having genomes split into 4 files)

## First, test Helicobacter_pylori outputs
cd ~/scratch
mkdir test
# Check completion runtimes (look ok, all 17-18 hours)
for out in tmp-job-outputs/Helicobacter_pylori.o985075-*; do tail $out; done

## Initial check: are the number of genomes the same? (yes!)
# Number of genomes that were processed in CheckM job output
cat tmp-job-outputs/Helicobacter_pylori.o985075-* | grep '^Genome:' | wc -l
2094
# Number of genomes downloaded
for dir in genomes-unzipped/Helicobacter_pylori/*; do ls $dir; done | wc -l
2094

## Genome check: are the genome names exactly the same? (yes!)
cat tmp-job-outputs/Helicobacter_pylori.o985075-* | grep '^Genome:' | sed 's/Genome: //' | sort > test/1
for dir in genomes-unzipped/Helicobacter_pylori/*; do ls $dir; done | sort > test/2
diff test/1 test/2 # Exactly the same genome names!
rm test/1 test/2
rmdir test

## Check the results tables
mkdir process-results
sp=Helicobacter_pylori
# Collect all table headings (filter out run info and separators)
cat tmp-results/${sp}/* | grep -ve 'INFO:' -ve '---------' > process-results/tmp-${sp}.txt
# Check that all headers are the same
cat process-results/tmp-${sp}.txt | grep 'Contamination' | tr -s ' ' | sort | uniq -c
   2094  Bin Id Marker lineage # genomes # markers # marker sets 0 1 2 3 4 5+ Completeness Contamination Strain heterogeneity

# ## Create header in results directory
# header='Bin_Id Marker_lineage #_genomes #_markers #_marker_sets 0 1 2 3 4 5+ Completeness Contamination Strain_heterogeneity'
# echo $header > process-results/header.txt

# ## Collect and explore the results
# # Still temporary because want to replace spaces in "Helicobacter pylori (6)" with underscores
# cat process-results/tmp-${sp}.txt | grep -v 'Contamination' | tr -s ' ' | sed 's/^ //' > process-results/${sp}.tmp
# rm process-results/tmp-${sp}.txt
# # Add underscores between columns 2-4 to get "Helicobacter_pylori_(6)":
# awk '{print $1, $2"_"$3"_"$4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16}' process-results/${sp}.tmp > process-results/${sp}.txt

## Collect only completeness, contamination results
# Create header in results directory
header='Genome Completeness Contamination Quality'
echo $header > process-results/header.txt
# Collect results only (no header columns)
cat process-results/tmp-${sp}.txt | grep -v 'Contamination' | tr -s ' ' | sed 's/^ //' > process-results/${sp}.tmp
rm process-results/tmp-${sp}.txt
# !!! # at this point check columns $2, $3, and $4 (should all be "Marker_lineage") to get the right columns
cat process-results/${sp}.tmp | awk '{print $2, $3, $4}' | sort | uniq
# Collect only the three quality metrics
awk '{print $1, $14, $15, $14-5*$15 }' process-results/${sp}.tmp > process-results/${sp}.txt
rm process-results/${sp}.tmp

## Filter results
mkdir filtered-results

## Filter based on these metrics
# Completeness > 80%
# Contamination < 4%
# Quality > 80%
awk '{ if(($2 > 80) && ($3 < 4) && ($4 > 80)) { print } }' process-results/${sp}.txt > filtered-results/${sp}.txt
echo "High_q Total"
echo "$(cat filtered-results/${sp}.txt | wc -l) $(cat process-results/${sp}.txt | wc -l)"

## Get full paths of the high quality genomes for fastANI-based (or other) clustering
mkdir quality-filtered-paths
full_path="/storage/home/hcoda1/7/tkiryutina3/MyTaxa/dereplication/data/genomes/${sp}/"
sed_path=$(echo $full_path | sed 's/\//\\\//g')
awk '{print $1}' filtered-results/${sp}.txt | sed "s/^/$sed_path/; s/$/.fna.gz/" > quality-filtered-paths/${sp}.txt

## Create the above steps into a runnable pipeline in this experiment directory & run it on other completed species
## Created filter-CheckM.sh
## Check that this script produced the same result as running the pipeline above
sp=Helicobacter_pylori
./filter-CheckM.sh $sp
# Check if results are identical (yes they are!)
diff ~/scratch/quality-filtered-paths/Helicobacter_pylori.txt quality-paths/Helicobacter_pylori.txt
diff ~/scratch/process-results/Helicobacter_pylori.txt quality-data/Helicobacter_pylori.txt

## Generate list of species with completed CheckM runs and those still running
mkdir sp-lists
ls ~/scratch/tmp-results/ > sp-lists/tax_wf.txt
cd sp-lists
qstat -u $(whoami) | grep '_' | awk '{print $4, $10}' | grep ' C$' | awk '{print $1}' > tmp-C
qstat -u $(whoami) | grep '_' | awk '{print $4, $10}' | grep ' R$' | awk '{print $1}' > tmp-R
grep -f tmp-C tax_wf.txt > C
grep -f tmp-R tax_wf.txt > R
rm tmp-C tmp-R
cd ..

## Create temporary species list, run "filter-CheckM.sh" manually on each while reading results
# After running each species, remove it from that list "x"
cp sp-lists/C x

###------------------------------------------------------------------------------------------------------------------------------
###------------------------------------------------------------------------------------------------------------------------------
###------------------------------------------------------------------------------------------------------------------------------
### 3/3/2021 ###

## One one subjob of one speices still running! 
# Pseudomonas_aeruginosa
# Copy species and remove that one species
cp sp-lists/tax_wf.txt x

# Run this for each speies in a loop
for sp in $(cat x); do echo ''; ./filter-CheckM.sh $sp; done

# Get a table of number of genomes for each species, and how much are high-quality
# Copy/paste in excel and get more stuff
for sp in $(cat x); do echo -e "$sp $(cat quality-data/${sp}.txt | wc -l) $(cat quality-paths/${sp}.txt | wc -l)"; done

## Clostridioides_difficile results completed!!! :) Collect them
sp=Clostridioides_difficile
# Collect quality data
cat Clostridioides_difficile/lineage-4.o1012336 | grep -v 'Finished parsing' | tail -n +15 | head -n -14 |\
grep -v '\-\-\-\-\-\-\-\-\-\-' | grep -v 'Completeness' | awk '{print $1, $13, $14, $13-5*$14}' \
> quality-data/${sp}.txt
# Filter quality data
awk '{ if(($2 > 80) && ($3 < 4) && ($4 > 80)) { print } }' quality-data/${sp}.txt > tmp/${sp}.quality
genome_collection=~/MyTaxa/dereplication/data/genomes/${sp}/
sed_path=$(echo $genome_collection | sed 's/\//\\\//g')
awk '{print $1}' tmp/${sp}.quality | sed "s/^/$sed_path/; s/$/.fna.gz/" > quality-paths/${sp}.txt
# Compare amount of quality genomes to original genomes
echo -e "$sp $(cat quality-data/${sp}.txt | wc -l) $(cat quality-paths/${sp}.txt | wc -l)"
# 3064 3020
## Compare to number of genomes
ls ~/scratch/Clostridioides_difficile/ | wc -l
# 3071
## Why did 7 genomes not get completess or contamination values?
## Check the genomes

# Which genomes did not get quality values
ls ~/scratch/Clostridioides_difficile/ | sort  > 1
awk '{print $1}' quality-data/Clostridioides_difficile.txt | sed 's/$/.fna/' | sort > 2
diff 1 2 | grep '<' | sed 's/< //'
# GCA_000085225.1_ASM8522v1_genomic.fna
# GCA_000152665.1_ASM15266v1_genomic.fna
# GCA_000154645.1_ASM15464v1_genomic.fna
# GCA_000155025.1_cduab_genomic.fna
# GCA_000155065.1_ASM15506v1_genomic.fna
# GCA_000164175.1_ASM16417v1_genomic.fna
# GCA_000210415.1_ASM21041v1_genomic.fna
rm 1 2 

### RUN NEW PLOTTING SCRIPT "plot-CheckM.py"
## Create species list again with values for all species
for sp in $(ls quality-data/ | sed 's/.txt$//'); do 
	# Species, number of genomes in collection, number of genomes that passed quality thresholds
	echo -e "$sp $(cat quality-data/${sp}.txt | wc -l) $(cat quality-paths/${sp}.txt | wc -l)"; 
done | sort -nr -k"2,2" | awk '{print $1}' > x

## For each species run script to create plot in "plots"
# Rename the plot to be numbered (species ordered by number of genomes in decreasing order)
i=0
for sp in $(cat x); do
	((i++))
	echo $sp
	python3 plot-quality.py $sp
	cd plots
	file=${sp}.png
	mv "$file" "${i}-${file}"
	cd ..
done

## Create similar plots for E. coli and S. enterica (dig up some old data)
ls ~/MyTaxa/dereplication/Salmonella_enterica/ | wc -l
274982
cat ~/MyTaxa/dereplication/CheckM-Senterica/results/quality.txt | wc -l
274982
cat ~/MyTaxa/dereplication/CheckM-Senterica/results/quality-filtered.txt | wc -l
267954

ls ~/MyTaxa/dereplication/Escherichia_coli/ | wc -l
87277
cat ~/MyTaxa/dereplication/CheckM-Ecoli/results/quality.txt | wc -l
87277	
cat ~/MyTaxa/dereplication/CheckM-Ecoli/results/quality-filtered.txt | wc -l
86244

# Link quality data in "quality-data"
cd quality-data
ln -s ~/MyTaxa/dereplication/CheckM-Senterica/results/quality.txt Salmonella_enterica.txt
ln -s ~/MyTaxa/dereplication/CheckM-Ecoli/results/quality.txt Escherichia_coli.txt
cd ..

python3 plot-quality.py "Escherichia_coli"
python3 plot-quality.py "Salmonella_enterica"

## Remove clear outlier from Salmonella enterica
# "plot-Senterica.ipynb"



