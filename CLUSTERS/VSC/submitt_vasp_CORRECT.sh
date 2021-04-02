#!/bin/bash
#SBATCH -J many
#SBATCH -N 1
#SBATCH --mail-type=BEGIN
#SBATCH --mail-user=janweinreich286@googlemail.com

module purge
module load intel-mpi/2019 intel-mkl/2019.6 intel/19.0.3
export PATH=$PATH:/home/fs71537/jweinreich/executables/VASP/vasp.6.2.0/bin
export PATH=$PATH:/home/fs71537/jweinreich/miniconda3/bin

export SLURM_STEP_GRES=none

#mytasks=4
mem_per_task=20G

for folder in Mn1Ti2 Lu1W2 Os2Ta1
do
	cd $folder
	srun --mem=$mem_per_task --cpus-per-task=24 --ntasks=1 vasp_std &
	cd ..
done
wait

