#!/bin/bash
#SBATCH --job-name="tables"      		    # Job name
#SBATCH --ntasks=4                   		# Run a single task
#SBATCH --mem=100gb                     	# Job memory request
#SBATCH --cpus-per-task=4            		# Number of CPU cores per task
#SBATCH --time=48:00:00              		# Time limit hrs:min:sec
#SBATCH --output=filter-tables-output-%J.log     		# Standard output and error log
date;hostname;pwd

source ~/.bashrc
conda activate custom-environment

echo $PWD

python ../generate-filter-RMATS-tables.py $1