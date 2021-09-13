#!/bin/bash

## Example of running an R script from the command line.
# In this example we are running "R-cmd-args.R" which takes the input arguments, adds file extensions, and prints them.

infile="R-cmd-args.R"

Rscript --vanilla "$infile" hello world

# Note: --vanilla tells Rscript to run without saving or restoring anything in the process.
