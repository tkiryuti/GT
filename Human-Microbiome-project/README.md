## Human Microbiome project introduction

In 2019, Almeida et al. reconstructed about 92,000 metagenome-assembled genomes (MAGs) from human gut microbiomes collected from 75 different studies, and identified nearly 2,000 uncultured candidate bacterial species (Almeida et al. 2019). By running all vs. all FastANI on this full MAG collection, we found that there is a genetic discontinuity akin to what Jain et al. showed with isolate genomes (Jain et al. 2018). The pairs containing a MAG from a richer country compared to a poorer country were enriched in the intermediate range (85 – 95 % FastANI), specifically with MAGs from Bangladesh, Tanzania, and Peru compared richer countries. We hypothesize that these intermediate entities represent evolving species, and are investigating gene content differences between samples from rich and poor locations to find corresponding lifestyle and diet differences.

## Methods
* Downloading MAGs (wget)
* Processing MAGs (<a href="http://microbial-genomes.org/">MiGA</a> on command line)
* All vs. All <a href="https://github.com/ParBLiSS/FastANI">FastANI<a/>
* Retrieving and parsing geographical metadata (<a href="https://www.ncbi.nlm.nih.gov/books/NBK179288/">Entrez Direct</a> & Bash)
* Fisher's Exact Tests on geographical origin pairs
* Sample selection (selecting metagenomes to compare based on community information found in publications)
* Comparative metagenomics (SRA Toolkit, Simka)
* Gene content diversity analysis
