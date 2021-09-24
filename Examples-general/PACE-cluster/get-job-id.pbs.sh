## PACE Cluster job submission example
# Here, the job ID is captured, then the job is deleted prematurely from within the job

## Job info & resource requests:
#PBS -N get-job-id
#PBS -A GT-ktk3
#PBS -q embers
#PBS -l nodes=1:ppn=1
#PBS -l pmem=1gb
#PBS -l walltime=1:00
#PBS -j oe
## Optional: enter email to get job updates
# #PBS -m abe
# #PBS -M <email>

# Enter directory from which the job was submitted.
cd "$PBS_O_WORKDIR"

# Show job ID in the output.
echo "$PBS_JOBID"
sleep 10

# Delete the job
qdel $PBS_JOBID

# Example commands that do not run because the job was deleted prematurely.
sleep 10
echo 'job was not deleted'
