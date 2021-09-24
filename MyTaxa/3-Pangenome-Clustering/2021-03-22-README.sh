#!/bin/bash

## Pangenome creation
## Clustering at 90 % identity within each species

## Copy code that will be adopted 
cp ~/MyTaxa/Pangenomes/cluster-1-sp.sh .

## Adopting these scripts:
# cluster-prep.sh
# cluster-1-sp.sh

## Run cluster-prep.sh on Derep-99 result species
# cluster-prep.pbs

## Check E. coli and S. enterica results and run cluster-prep on them

species="Escherichia_coli"
reps=~/MyTaxa/dereplication/2021-01-15-derep-E-coli/cluster-analysis/reps.txt
bash cluster-prep.sh "$species" "$reps" > cluster-prep.o2

species="Salmonella_enterica"
reps=~/MyTaxa/dereplication/2021-01-16-derep-S-enterica/cluster-analysis/reps.txt
bash cluster-prep.sh "$species" "$reps" >> cluster-prep.o2

###__________________________________________________________________________________________###
### 3/24/2021 ###
## Replace old representative Pangenomes with new ones (post-dereplicaiton)
cd ~/MyTaxa/Pangenomes
mkdir tmp-Highly-Sampled
mkdir tmp-Highly-Sampled/Clusters-at-90
mkdir tmp-Highly-Sampled/Reps-at-90
dir=~/MyTaxa/dereplication/experiments/2021-03-22

## Move out old results for each results type
type="Clusters-at-90"
type="Reps-at-90"

# Look at the paths (while they exist)
for path in $dir/$type/*; do 
	res=$(basename $path)
	ls ./$type/$res
done

# Move the results
for path in $dir/$type/*; do 
	res=$(basename $path)
	if ls ./$type/$res; then
	mv ./$type/$res tmp-Highly-Sampled/$type
	fi
done

# Copy new results to ~/MyTaxa/Pangenomes
for path in $dir/$type/*; do 
	res=$(basename $path)
	cp $path $type
	ls $type/$res
done

## Run protein family clustering

## See starting proteins vs. number of representatives
for clusters in $(ls Clusters-at-90/); do 
	sp=${clusters/.tsv.gz}; 
	# ls Clusters-at-90/$sp.tsv.gz; 
	# ls Reps-at-90/$sp.faa.gz;
	n_clusters=$(gzip -cd Clusters-at-90/$sp.tsv.gz | wc -l)
	n_reps=$(gzip -cd Reps-at-90/$sp.faa.gz | grep '^>' | wc -l)
	echo -e "${sp}\t${n_clusters}\t${n_reps}" 
done | tee tmp-info.txt

echo 'species n_proteins n_reps percent_reps' > tmp-info-2.txt
awk '{print $0,100*$3/$2}' tmp-info.txt | sort -nr -k2,2 >> tmp-info-2.txt
column -t tmp-info-2.txt > info.txt
echo ''; cat info.txt; echo ''
