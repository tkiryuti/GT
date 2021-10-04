#!/bin/bash -vx

# This script just creates the jobs I need.

date=0527
jobdir=PBS\_jobs\_all\_$date
mkdir $jobdir

for dir in $(ls . | grep "mags_"); do
        echo $dir >> job.ongoing
done

for input1 in $(ls . | grep "mags_"); do
        n1=$(echo $input1 | sed 's/mags\_//') # Ex: "1"

        for input2 in $(cat job.ongoing); do
                n2=$(echo $input2 | sed 's/mags\_//') # Ex: "2"
                job=$n1\_vs\_$n2

                echo "#PBS -N $job" >> $jobdir/$job.pbs
                echo "#PBS -l mem=20gb" >> $jobdir/$job.pbs 
                echo "#PBS -e PBS_oe_$date/$job.e" >> $jobdir/$job.pbs
                echo "#PBS -o PBS_oe_$date/$job.o" >> $jobdir/$job.pbs
                echo "#PBS -l walltime=00:24:00:00" >> $jobdir/$job.pbs
                echo "#PBS -q microcluster" >> $jobdir/$job.pbs
                echo 'cd $PBS_O_WORKDIR' >> $jobdir/$job.pbs
                echo 'echo "Started on `/bin/hostname`"' >> $jobdir/$job.pbs
                echo " " >> $jobdir/$job.pbs

                echo '~/shared3/for-chirag/Tanya_FastANI/fastANI \' >> $jobdir/$job.pbs
                echo '--ql paths/'"$input1"'.txt \' >> $jobdir/$job.pbs
                echo '--rl paths/'"$input2"'.txt \' >> $jobdir/$job.pbs
                echo '-o Results/'$n1\_vs\_$n2 >> $jobdir/$job.pbs

        done

echo $input1 >> job.finished
cat job.ongoing | grep -v -w $input1 > job.ongoing.temp
rm job.ongoing
mv job.ongoing.temp job.ongoing

done

rm job.ongoing
rm job.finished

