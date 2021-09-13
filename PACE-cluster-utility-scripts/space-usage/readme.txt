Space management:
Set of hard-coded .pbs scripts that find space usage of each file in each specific large main directory (in the PACE cluster).
assemble.sh combines resuts into a summary of space usage.

___SCRIPTS___

PBS Job outputs:
> The Job outputs (*.o*) contain job start/resources/end info as well as the total space directory takes up (in TB, GB, MB, and KB).
> The other output is a .txt file with the job name prefix that contains the output of "du" (disk usage of each file)

Running assemble.sh:
> After all the jobs are completed, run this to create a summary of space usage
> The resulting .txt file is titled based on the date and time you run assemble.sh
> It contains the KB, MB, GB, TB, category, and path sorted from greatest space to least

___TOTALS___
> Contains outputs from assemble.sh that show the progress of data cleaning overtime (from 11.4 TB to 3.7 TB).

