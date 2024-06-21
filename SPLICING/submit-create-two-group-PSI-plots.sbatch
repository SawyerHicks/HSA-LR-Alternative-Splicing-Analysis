#!/bin/bash
#SBATCH --job-name="plots"      		# Job name
#SBATCH --ntasks=8                   		# Run a single task
#SBATCH --mem=200gb                     	# Job memory request
#SBATCH --cpus-per-task=8            		# Number of CPU cores per task
#SBATCH --time=48:00:00              		# Time limit hrs:min:sec
#SBATCH --output=create-plots-output-%J.log     		# Standard output and error log
date;hostname;pwd

source ~/.bashrc
conda activate custom-environment

echo $PWD

python ../create-two-group-PSI-plots.py $1