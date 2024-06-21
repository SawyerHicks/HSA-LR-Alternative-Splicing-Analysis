#!/bin/bash
#SBATCH --job-name="deseq2-runner"      		# Job name
#SBATCH --ntasks=1                   		# Run a single task
#SBATCH --mem=10gb                     	# Job memory request
#SBATCH --cpus-per-task=1            		# Number of CPU cores per task
#SBATCH --time=48:00:00              		# Time limit hrs:min:sec
#SBATCH --output=output-%J.log     		# Standard output and error log
date;hostname;pwd

source ~/.bashrc
conda activate custom-environment

R < deseq2_analysis.R --no-save  
