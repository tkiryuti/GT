#!/usr/bin/env Rscript

## 7/10/2020
## Example for how to pass arguments to an R script from command line 
# https://www.r-bloggers.com/passing-arguments-to-an-r-script-from-command-lines/

## Run in the command line:
# Rscript --vanilla sillyScript.R iris.txt out.txt

# Pass arguments from the command line by scanning supplied arguments
args = commandArgs(trailingOnly=TRUE)

v1 = args[1]
v2 = args[2]

file1 = paste(v1,".txt",sep='')
file2 = paste(v2,".rdata",sep='')

print(file1)
print(file2)
