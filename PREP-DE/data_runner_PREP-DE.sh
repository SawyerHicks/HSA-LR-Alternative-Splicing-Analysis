#!/bin/bash
#SBATCH --job-name="prep-DE"
#SBATCH --output=PREPDE_%J.log
#SBATCH --error=PREPDE_%J.err
#SBATCH --time=48:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=20G

# establish working environment
source ~/.bashrc
conda activate custom-environment

# create input file for prepDE.py
# sample_ID	PATH/TO/GTF
# name = input_list.txt

python prepDE.py3 -i input_list.txt