#!/bin/bash                                                                                      
#SBATCH --job-name=GPU           #This is the name of your job
#SBATCH --ntasks=1            # number of mpi tasks
#SBATCH --cpus-per-task=1                  #This is the number of cores reserved
#SBATCH --nodes=1              # number of compute nodes
#SBATCH --time=3:30:00        #This is the time that your task will run
#SBATCH --partition=pascal
#SBATCH --gres=gpu:1
# Paths to STDOUT or STDERR files should be absolute or relative to current working directory
#SBATCH --output=./slurm/myrun.o%j     #These are the STDOUT and STDERR files
#SBATCH --error=./slurm/myrun.e%j
source ~/.bashrc
module load CUDA
conda activate your_env_name
curr=`pwd`
resdir="${curr}/results_GPU"
cd $TMPDIR
cp stuff .


python3 -u my_sample.py  > sample_0.out
#my_sample.py
mkdir -p ${resdir}/${c} 
cp * ${resdir}/${c}
#$TMPDIR is an automatic scratch dir that gets allocated whenever ur job gets on the queue
