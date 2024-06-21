#!/bin/bash
#SBATCH --job-name="merge"
#SBATCH --output=MERGE_%J.log
#SBATCH --error=MERGE_%J.err
#SBATCH --time=48:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=16
#SBATCH --mem=100G
  
annotation_gtf=$1
merge_list=$2

stringtie --merge -p 16 -G ${annotation_gtf} -o stringtie_merged.gtf ${merge_list}
