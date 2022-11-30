#!/bin/bash

NTASKS=16

cat > rng_print.py << EOF
import random, sys, os

seed=os.environ["SLURM_LOCALID"]

random.seed()
output=open(os.path.dirname(os.path.realpath(__file__))+"/rng_"+str(seed), "w")
for _ in range(1000):
    print(random.random(), file=output)
output.close()
EOF

job_name="srun_example"

cat > submitter.sh << EOF
#!/bin/bash
#SBATCH -J $job_name
#SBATCH -o $job_name.stdout_%j
#SBATCH -e $job_name.stderr_%j
#SBATCH --ntasks=$NTASKS
#SBATCH --cpus-per-task=1

srun python $(pwd)/rng_print.py 

EOF

sbatch submitter.sh
