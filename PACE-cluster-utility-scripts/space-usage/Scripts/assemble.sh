#!/bin/bash

## Assemble space usage results
# Prints the following sorted from greatest space to least
# KB, MB, GB, TB, category, path

# #PBS -N assembled
# #PBS -A GT-ktk3
# #PBS -q embers
# #PBS -l nodes=1:ppn=1
# #PBS -l pmem=3gb
# #PBS -l walltime=5:00
# #PBS -j oe

for usage_results_file in cluo31-data.txt enveomics.txt HMP_MAGs.txt home.txt Human-Microbiome.txt konstantinidis.txt MiGA_Clades.txt MyTaxa.txt scratch.txt; do
	category=${usage_results_file/.txt/}
	sort -nr "$usage_results_file" | awk -v "category=$category" -v OFMT='%.3f' '{print $1,$1/1024,$1/1048576,$1/1073741824,category,$2}' >> All.tmp
done

sort -nr All.tmp > All.txt
rm All.tmp

# Define date & time dependent output file
# outfile="Totals/$(echo $(date) | sed 's/[^ ]* //; s/ /_/g; s/:/h/; s/:.*EDT/m/').txt"
year="$(echo $(date) | awk '{print $6}')"
month="$(echo $(date) | awk '{print $2}')"
day="$(echo $(date) | awk '{print $3}')"
time="$(echo $(date) | awk '{print $4}' | sed 's/:/h/; s/:.*/m/')"

if [[ "$month" == "Mar" ]]; then
	month="03"
fi

outfile="Totals/${year}-${month}-${day}-${time}.txt"

# View totals
echo '_____TOTALS_____' >> $outfile
{ echo 'KB MB GB TB dir .' & grep '\ .$' All.txt; } | column -t >> $outfile

# Calculate total (TB)
echo '_____SUM (TB)_____' >> $outfile
grep '\ .$' All.txt | awk -v OFMT='%.2f' '{SUM+=$4}END{print SUM}' >> $outfile

echo '' >> $outfile

cp $outfile tmp-current-total.txt
