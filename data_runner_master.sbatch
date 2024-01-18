#!/bin/bash
#SBATCH --job-name="launch"      		# Job name
#SBATCH --mail-type=END,FAIL         		# Mail events (NONE, BEGIN, END, FAIL, ALL)
#SBATCH --mail-user=smhicks@albany.edu    	# Where to send mail
#SBATCH --ntasks=1                   		# Run a single task
#SBATCH --mem=10gb                     	# Job memory request
#SBATCH --cpus-per-task=1            		# Number of CPU cores per task
#SBATCH --time=100:00:00              		# Time limit hrs:min:sec
#SBATCH --output=launch-runner-%J.log     		# Standard output and error log
date;hostname;pwd

source ~/.bashrc

# makes child directories

# Run HISAT2 alignment on Klein 2019 data
echo "Alignment Start: $(date) ----------------------------------"
cd HISAT2
#./data_runner_Align.sh
echo "Alignment Stop: $(date) ----------------------------------"

# Run STRINGTIE
echo "STRINGTIE Start: $(date) ----------------------------------"
cd ../STRINGTIE
#./data_runner_STRINGTIE.sh
echo "STRINGTIE Stop: $(date) ----------------------------------"

# Run PREP-DE
# You must create an input list of the gtf files and the sample names. 
echo "STRINGTIE Start: $(date) ----------------------------------"
cd ../PREP-DE
#./data_runner_PREP-DE.sh
echo "STRINGTIE Stop: $(date) ----------------------------------"

# Run rMATS splicing estimation 
# You must create the .bam list files for each condition and customize the rMATS script to point to the correct files.
echo "rMATS Start: $(date) ----------------------------------"
cd ../RMATS
./data_runner_rMATS.sh
echo "rMATS Stop: $(date) ----------------------------------"

# Run SPLICING 
echo "SPLICING Start: $(date) ----------------------------------"
cd ../SPLICING
./run-splicing-data-generation.sbatch
echo "SPLICING Stop: $(date) ----------------------------------"

# Run DESeq2
#echo "DESeq2 Start: $(date) ----------------------------------"

#echo "DESeq2 Stop: $(date) ----------------------------------"

# Run RMATS 2 Sashimi code
#

#