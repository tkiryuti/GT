#PBS -N MiGA_Clades
#PBS -A GT-ktk3
#PBS -q embers
#PBS -l nodes=1:ppn=1
#PBS -l pmem=3gb
#PBS -l walltime=8:00:00
#PBS -j oe

cd "$PBS_O_WORKDIR"

cd /storage/home/hcoda1/7/tkiryutina3/shared3/projects/MiGA_Clades
du . > "${PBS_O_WORKDIR}/MiGA_Clades.txt"

cd "$PBS_O_WORKDIR"
file="MiGA_Clades.txt"

total=$(tail -1 $file | awk '{print $1}')
echo "$((total/1073741824)) TB"
echo "$((total/1048576)) GB"
echo "$((total/1024)) MB"
echo "${total} KB"
