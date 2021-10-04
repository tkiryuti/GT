#!/bin/bash

# Creates list of absolute paths for fastANI

for dir in $(ls . | grep "mags_"); do
	for mag in $(ls $dir); do
		echo $(pwd)/$dir/$mag >> ./paths/$dir.txt
	done
done

