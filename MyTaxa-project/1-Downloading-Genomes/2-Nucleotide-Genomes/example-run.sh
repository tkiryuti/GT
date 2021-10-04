#!/bin/bash

SPECIES=Acinetobacter_baumannii
qsub -N "dl-${SPECIES}" -v SPECIES="${SPECIES}" dl-species.pbs
