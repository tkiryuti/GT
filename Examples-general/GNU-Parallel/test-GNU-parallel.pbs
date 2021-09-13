#PBS -N test-GNU-parallel
#PBS -A GT-ktk3
#PBS -q embers
#PBS -l nodes=2:ppn=4
#PBS -l pmem=1gb
#PBS -l walltime=15:00
#PBS -j oe

# Go to current directory and load PACE's GNU parallel module
cd "$PBS_O_WORKDIR"
module load parallel

# Determine the number of CPUs and CPU cores on the system
echo "Number of cpus = $(parallel --number-of-cpus)"
echo "Number of cores = $(parallel --number-of-cores)"

# See the names of all nodes assigned to this job
echo -e "\nNODES ASSIGNED:"
echo "---------------------------------------"
cat "$PBS_NODEFILE"
echo ''

# Define input file
input_file="test-inputs.txt"

# Create function that does some task with inputs
a_function() {
    echo "Running a_function on ${1} | $(date)"
    sleep 5
}

# Export function to the environment
export -f a_function

# Create a function in which a few tasks fail
fail_function() {
	echo "${1} | $(date)"
	sleep 5
	exit ${1}
}

# Export function to the environment
export -f fail_function

## Improvement: Adding a termination condition
# --keep-order      force output in same order as arguments
# --jobs N          number of jobs per machine (node). Default is 100% which will run one job per CPU on each machine.
# --delay t         wait at least t seconds before each start
# --joblog F        generate a log file with jobs completed so far
# --sshloginfile F  use when more than one node is requested for the job
# --workdir DIR     specify where to execute commands on remote computers (changes working directory from the default: ~)
# --env var         copy exported environment variable or Bash function 
# --halt now,fail=1 exit when the first job fails. Kill running jobs.

# Run a_function in parallel (should work)
echo '___ Running a_function ___'
if parallel --keep-order --env a_function --joblog "test-GNU-parallel.log-1" --sshloginfile "$PBS_NODEFILE" --workdir "$PBS_O_WORKDIR" a_function :::: "$input_file"
then
	echo "Successful parallelization"
else
	echo "Error: one sub-job in GNU parallel failed"
	exit 1
fi
echo ''

# Run fail_function in parallel (should fail)
echo '___ Running fail_function ___'
if parallel --keep-order --env fail_function --halt now,fail=1 --joblog "test-GNU-parallel.log-2" --sshloginfile "$PBS_NODEFILE" --workdir "$PBS_O_WORKDIR" fail_function ::: 0 0 0 0 1 2 3 3
then
	echo "Successful parallelization"
else
	echo "Error: one sub-job in GNU parallel failed"
	exit 1
fi
echo ''

sleep 5
echo "SCRIPT COMPLETED | $(date)" 

# ## Improvement: leave out --jobs flag to let one job run per CPU on each machine
# parallel --env a_function --joblog "test-GNU-parallel.log" --sshloginfile "$PBS_NODEFILE" --workdir "$PBS_O_WORKDIR" a_function :::: "$input_file"
# # Two different batch jobs worked as expected. One was on 2 nodes (ppn=4) and one was on 1 node (ppn=8). 
# # For both job submissions, functions ran at exactly the same time (within the same second) on all available processors.

# ## Test 4: Adding the --env flag to copy the exported Bash function
# parallel --env a_function --jobs 4 --joblog "test-GNU-parallel.log" --sshloginfile "$PBS_NODEFILE" --workdir "$PBS_O_WORKDIR" a_function :::: "$input_file"
# # The message in the function was printed successfully with each input.
# # However, this time only one node was assigned (8 processors) and because of this the number of parallel jobs was limited to 4.

# ## Test 3: using env_parallel to test "a_function"
# env_parallel --jobs 4 --joblog "test-GNU-parallel.log" --sshloginfile "$PBS_NODEFILE" --workdir "$PBS_O_WORKDIR" a_function :::: "$input_file"
# # Error message: the "env_parallel" function needs to be added to the .bashrc

# ## Test 2: try running "echo" on inputs in parallel
# parallel --jobs 4 --joblog "test-GNU-parallel.log" --sshloginfile "$PBS_NODEFILE" --workdir "$PBS_O_WORKDIR" echo :::: "$input_file"
# # The "echo" command was successfully run on all requested processors and on 2 different nodes

# ## Test 1: try running "a_function" on inputs in parallel
# parallel --jobs 4 --joblog "test-GNU-parallel.log" --sshloginfile "$PBS_NODEFILE" --workdir "$PBS_O_WORKDIR" a_function :::: "$input_file"
# # All 8 processors have the error "bash: a_function: command not found"
