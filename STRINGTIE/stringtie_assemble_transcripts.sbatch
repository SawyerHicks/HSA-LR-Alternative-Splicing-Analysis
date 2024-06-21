#!/bin/bash
#SBATCH --job-name="stringtie"
#SBATCH --output=STRINGTIE_Assemble_%J.log
#SBATCH --error=STRINGTIE_Assemble_%J.err
#SBATCH --time=48:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=50G
  
filename=$1
dir=$2
annotation_gtf=$3

stringtie ${dir}/${filename}.bam -e -l ${filename} -p 16 -G ${annotation_gtf} -o ${filename}.gtf