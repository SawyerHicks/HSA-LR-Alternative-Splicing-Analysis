#!/bin/bash
#SBATCH --job-name="hisat2"
#SBATCH --output=HISAT2_%J.log
#SBATCH --error=HISAT2_%J.err
#SBATCH --time=48:00:00
#SBATCH --ntasks=2
#SBATCH --cpus-per-task=8
#SBATCH --mem=16gb

source ~/.bashrc
conda activate custom-environment

genome_dir=$1
fq_dir=$2
filename=$3

# User should ensure fasta file name suffix match's their own files.
echo "hisat2 -p 8 --dta -x ${genome_dir} -1 ${fq_dir}/${filename}.sra_1.fastq -2 ${fq_dir}/${filename}.sra_2.fastq -S ${filename}.sam"
    
hisat2 -p 8 --dta -x ${genome_dir} -1 ${fq_dir}/${filename}.sra_1.fastq -2 ${fq_dir}/${filename}.sra_2.fastq -S ${filename}.sam