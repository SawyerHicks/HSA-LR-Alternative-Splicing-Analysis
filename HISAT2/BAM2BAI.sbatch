#!/bin/bash
#SBATCH --job-name="index-bam"
#SBATCH --output=BAM2BAI_%J.log
#SBATCH --error=BAM2BAI_%J.err
#SBATCH --time=48:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G
  
filename=$1

source ~/.bashrc
conda activate custom-environment
  
samtools index ${filename}.bam ${filename}.bam.bai