import numpy as np
import os


class SlurmBatchScript:

    
    def __init__(self, path):
        self.path = path
        return


    def open_file(self):
        self.f = open(self.path, 'w')
        return


    def close_file(self):
        self.f.write('\n'.join(self.text))
        self.f.close()
        return


    def initialize(self, slurm_job_name, input_dir, input_file_name, extra_input_files, 
                   output_dir, output_file_name, extra_output_files, scratch_dir, program, args, 
                   time='2:00:00', slurm_job_partition='normal',
                   slurm_cpus_per_task=1, add_slurm_id2input=False):
        self.text = []
        self.slurm_job_name = slurm_job_name
        self.input_dir = input_dir
        self.input_file_name = input_file_name
        self.extra_input_files = extra_input_files
        self.output_dir = output_dir
        self.output_file_name = output_file_name
        self.extra_output_files = extra_output_files
        self.scratch_dir = f'{scratch_dir}{slurm_job_name}/'
        self.program = program
        self.args = args
        self.time = time
        self.slurm_job_partition = slurm_job_partition
        self.slurm_cpus_per_task = slurm_cpus_per_task
        self.comment_lines = []
        self.add_slurm_id2input = add_slurm_id2input
        return


    def add_comment_line(self, comment):
        self.comment_lines.append(f'\n# {comment}')
        return
    
    
    def write_sbatch_lines(self):
        self.text.append(fr'#SBATCH --job-name="{self.slurm_job_name}"')
        self.text.append(fr'#SBATCH --time={self.time}')
        self.text.append(fr'#SBATCH --partition={self.slurm_job_partition}')
        self.text.append(fr'#SBATCH --cpus-per-task={self.slurm_cpus_per_task}')
        self.text.append(fr'#SBATCH --output={self.output_dir}%j.out')
        self.text.append(fr'#SBATCH --error={self.output_dir}%j.err')
        self.text.append('\n')
        return


    def write_comment_lines(self):
        for line in self.comment_lines:
            self.text.append(line)
        self.text.append('\n')
        return


    def write_text(self):
        # beginning of batch script
        self.text.append(r'#!/bin/bash')
        self.write_sbatch_lines()

        # adds the job id to the input file to link to the correct std out and err files
        if self.add_slurm_id2input:
            self.text.append('# add job id to link std out and err files\n')
            self.text.append(fr'sed -i "1s/^/# slurm job id : $SLURM_JOB_ID\n/" {self.slurm_job_name}.inp')

        # add as many comments as you like
        self.write_comment_lines()

        # this never hurts
        self.text.append('# specify number of cores for the job\n')
        self.text.append('export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK')
        self.text.append('export PARNODES=$SLURM_CPUS_PER_TASK\n')

        # create scratch directory and move input files over there
        self.text.append('# create scratch dir and move input files over there\n')
        self.text.append(f'mkdir -p {self.scratch_dir}')
        self.text.append(f'cp {self.input_dir}{self.input_file_name} {self.scratch_dir}')
        for fi in self.extra_input_files:
            self.text.append(f'cp {self.input_dir}{fi} {self.scratch_dir}')
        self.text.append('\n')

        # run your code
        self.text.append('# run the code\n')
        self.text.append(f'{self.program} {self.scratch_dir}{self.input_file_name} > {self.scratch_dir}{self.output_file_name} {self.args}\n')

        # fetch output files
        self.text.append('# fetch the output files back\n')
        self.text.append(f'cp {self.scratch_dir}{self.output_file_name} {self.output_dir}')
        for f in self.extra_output_files:
            self.text.append(f'cp {self.scratch_dir}{f} {self.output_dir}')
        self.text.append('\n')

        # clean scratch directory
        self.text.append('# clean up the scratch dir')
        self.text.append(f'rm -r {self.scratch_dir}\n')

        return
        
        
