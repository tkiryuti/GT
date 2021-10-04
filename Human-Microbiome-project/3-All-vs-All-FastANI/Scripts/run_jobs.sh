#!/bin/bash -x -v

# cat jobs_PBS.left | grep -ve "47" -ve "46" -ve "45" -ve "44" > jobs_PBS.left2
cat jobs_PBS.left2 | grep -v "9" > jobs_PBS.left3

for i in $(cat jobs_PBS.left3 | grep "15"); do
qsub PBS_jobs_all_0527/$i
done

