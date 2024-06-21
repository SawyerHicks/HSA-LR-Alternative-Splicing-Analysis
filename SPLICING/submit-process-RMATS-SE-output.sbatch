#!/bin/bash
#SBATCH --job-name="process"      		# Job name
#SBATCH --ntasks=1                   		# Run a single task
#SBATCH --mem=20gb                     	# Job memory request
#SBATCH --cpus-per-task=1            		# Number of CPU cores per task
#SBATCH --time=48:00:00              		# Time limit hrs:min:sec
#SBATCH --output=process-RMATS-output-%J.log     		# Standard output and error log
date;hostname;pwd

source ~/.bashrc
conda activate custom-environment

echo $PWD

python ../process-RMATS-SE-output.py $1
