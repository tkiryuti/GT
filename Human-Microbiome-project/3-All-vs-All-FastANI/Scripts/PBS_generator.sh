#!/bin/bash

# PBS_generator.sh
# PBS script generator

job_name=$1
walltime=$2
queue="microcluster"
# queue="iw-shared-6"

if [[ ! -z $job_name && $walltime ]]; then
# If length of "STRING" is NOT zero. (http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_01.html)

	echo '# '"$job_name"'.pbs'
	echo ' '
	echo '#PBS -N '"$job_name"'         # Job name'
	echo '#PBS -e '"$job_name"'.e       # Standard error stream path'
	echo '#PBS -o '"$job_name"'.o       # Standard output stream path'
	echo ' '
	echo '#PBS -l nodes=1:ppn=24              # Allocate nodes, processors per node (cores)'
	echo '#PBS -l mem=200gb                   # Allocate total memory (GB)'
	echo '#PBS -l walltime='"$walltime"'        # Allow DD:HH:MM:SS of running'
	echo '#PBS -q '"$queue"'                # For jobs of > 12 h'
	echo '#PBS -m abe                         # Send email for start, finish, error'
	echo '#PBS -M tkiryuti@gatech.edu'
	echo 'cd $PBS_O_WORKDIR                   # Change to directory of pbs script'
	echo 'echo "Started on `/bin/hostname`"   # Show where job begins execution'

elif [[ -z $walltime && ! -z $job_name ]]; then
	echo 'Please provide the walltime (DD:HH:MM:SS)!'
	echo 'USAGE: bash PBS_generator.sh [JOB_NAME] [WALLTIME]'

else
	echo 'Please provide the name of your PBS job and the walltime (DD:HH:MM:SS)!'
	echo 'USAGE: bash PBS_generator.sh [JOB_NAME] [WALLTIME]'

fi

