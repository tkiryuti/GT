#!/bin/bash

# Combine fastANI results

n=1

for i in $(ls Results); do
	echo "Working on" $n'th result:' $i',' $(cat Results/$i | wc -l)
	echo "Working on" $n'th result:' $i',' $(cat Results/$i | wc -l) >> combine_results.log
	cat Results/$i >> Results_all/ALL.txt
	let n++
done

