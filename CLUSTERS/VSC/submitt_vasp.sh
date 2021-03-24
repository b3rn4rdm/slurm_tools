#!/bin/sh
#SBATCH -J jobname
#SBATCH --mail-type=BEGIN
#SBATCH --mail-user=janweinreich286@googlemail.com
#SBATCH -N 1
#SBATCH --ntasks-per-core=1
#SBATCH --ntasks-per-node=96

# Problem we have 96 CPU but want to start smaller
# subjobs with say 24 CPUs for each subjob!
# This works with processor pinning only!


# https://wiki.vsc.ac.at/doku.php?id=doku:vsc3_pinning


module purge
module load intel-mpi/2019 intel-mkl/2019.6 intel/19.0.3
export PATH=$PATH:/home/fs71537/jweinreich/executables/VASP/vasp.6.2.0/bin
export PATH=$PATH:/home/fs71537/jweinreich/miniconda3/bin


# random Magic spells

export SLURM_STEP_GRES=none
NUMBER_OF_MPI_PROCESSES=96
export I_MPI_PIN_PROCESSOR_LIST=0-95

i=1
for folder in Mn1Ti2 Lu1W2;
do
	j=$(($i+24))
	j=$(($j-1))
	cd $folder
    # Pin process to processors i to j
    # You may also select single processors and seperate them by a , instead of -
	mpirun -env I_MPI_PIN_PROCESSOR_LIST $i-$j -np 24 vasp_std &
	echo $i $j
	i=$(($i+24))
	cd ..
done

