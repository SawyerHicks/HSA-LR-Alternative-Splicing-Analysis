#!/bin/bash
#SBATCH --job-name="rmatsturbo"      		# Job name
#SBATCH --ntasks=1                  		# Run a single task
#SBATCH --mem=10gb                     	# Job memory request
#SBATCH --cpus-per-task=1           		# Number of CPU cores per task
#SBATCH --time=48:00:00              		# Time limit hrs:min:sec
#SBATCH --output=rmats-launch-%J.log     		# Standard output and error log
date;hostname;pwd

source ~/.bashrc

conda activate custom-environment

gtfFile="/network/rit/lab/berglundlab_rit/common/Sequencing_Data/genomes/m39-HSA-LR-hisat2-reference-build/Mus_musculus.GRCm39.106.ACTA1.gtf"

# --- bam files contained in these files ---
# COMBO.txt
# HSALR.txt
# WT.txt

start=`date +%s`

# WT vs. HSALR
sbatch --job-name="rmats" --ntasks=4 --mem=48gb --cpus-per-task=4 --time=48:00:00 --output=%J.log --wrap="rmats.py --b1 WT.txt --b2 HSALR.txt --gtf $gtfFile -t paired --readLength 75 --nthread 8 --od rmats-WT-vs-HSALR --tmp rmats-tmp-WT-vs-HSALR --allow-clipping --variable-read-length"
sleep 0.1

# HSALR vs. COMBO
sbatch --job-name="rmats" --ntasks=4 --mem=48gb --cpus-per-task=4 --time=48:00:00 --output=%J.log --wrap="rmats.py --b1 HSALR.txt --b2 COMBO.txt --gtf $gtfFile -t paired --readLength 75 --nthread 8 --od rmats-HSALR-vs-COMBO --tmp rmats-tmp-HSALR-vs-COMBO --allow-clipping --variable-read-length"
sleep 0.1

end=`date +%s`

runtime=$((end-start))
echo $runtime
