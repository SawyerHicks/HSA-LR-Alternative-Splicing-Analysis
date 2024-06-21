#!/bin/bash
#SBATCH --job-name="samtools"
#SBATCH --output=SAM2BAM_%J.log
#SBATCH --error=SAM2BAM_%J.err
#SBATCH --time=48:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G

filename=$1

source ~/.bashrc
conda activate custom-environment

samtools sort -@ 4 -o ${filename}.bam ${filename}.sam