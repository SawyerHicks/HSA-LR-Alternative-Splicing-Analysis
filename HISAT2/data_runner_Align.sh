#!/bin/bash

# import paths needed to call files
fq_dir="/PATH/TO/FASTQ"
genome_dir="PATH/TO/HISAT2-GENOME-BUILD"
annotation_gtf="/PATH/TO/GENOME-GTF-FILE"

# establish working environment
source ~/.bashrc

### Submit HISAT2 alignment jobs ################################
# for loop submitting unique fastq ID to batch scheduler
echo "Submitting fastq files to batch scheduler for HISAT2 alignment"
last_job1_id="" # this will store the last job id submitted
for sample in ${fq_dir}/*.sra_1.fastq; do ## should ensure the filename suffix matches user's file name scheme
  filename=$(basename ${sample} .sra_1.fastq); # pull basename 

  echo "Submitting ${filename}"

  # align with HISAT2
  if [ ! -d map_${filename} ]; then # create directory to run alignment in
    mkdir map_${filename}
    cd map_${filename}

    job_id=$(sbatch ../HISAT2_align.sbatch "${genome_dir}" "${fq_dir}" "${filename}" | awk '{print $NF}')
  
    # Update the last job ID
    last_job1_id="${job_id}"
    cd ..
  fi
  sleep 1
done;

echo "Last job submitted is ${last_job1_id}"

# Wait for the last job to complete
while true; do
    job_status=$(scontrol show job "${last_job1_id}" | grep -oP "JobState=\K\w+")
    if [[ "${job_status}" == "COMPLETED" ]] || [[ "${job_status}" == "FAILED" ]] || [[ "${job_status}" == "CANCELLED" ]]; then
        echo "Last job submitted ${last_job1_id} has been completed, failed, or cancelled."
        break
    fi
    sleep 150
done

### Run SAM to BAM with samtools ################################
echo "Submitting sam files to batch scheduler for conversion to bam"
last_job2_id="" #this will store the last job id submitted
for dir in map_*/; do # for all directories starting with map
  cd ${dir} # change into that directory
  filename=$(basename *.sam .sam); #pull basename of the .sam filetype
  
  echo "Submitting ${filename}.sam for conversion"
  job_id=$(sbatch ../SAM2BAM.sbatch "${filename}" | awk '{print $NF}')
    
  # Update the last job ID
  last_job2_id="${job_id}"
  cd ..
done; 

echo "Last job submitted is ${last_job2_id}"


# Wait for the last job to complete
while true; do
    job_status=$(scontrol show job "${last_job2_id}" | grep -oP "JobState=\K\w+")
    if [[ "${job_status}" == "COMPLETED" ]] || [[ "${job_status}" == "FAILED" ]] || [[ "${job_status}" == "CANCELLED" ]]; then
        echo "Last job submitted ${last_job2_id} has been completed, failed, or cancelled."
        break
    fi
    sleep 150
done


### Index BAM with samtools ################################
last_job3_id="" #this will store the last job id submitted
date
for dir in map_*/; do # for all directories starting with map
  cd ${dir} # change into that directory
  filename=$(basename *.bam .bam); #pull basename of the .sam filetype
  echo "Submitting ${filename}.bam for indexing"

  job_id=$(sbatch ../BAM2BAI.sbatch "${filename}" | awk '{print $NF}')
    # Update the last job ID
    last_job3_id="${job_id}"
  cd ..
done; 


# Wait for the last job to complete
while true; do
    job_status=$(scontrol show job "${last_job3_id}" | grep -oP "JobState=\K\w+")
    if [[ "${job_status}" == "COMPLETED" ]] || [[ "${job_status}" == "FAILED" ]] || [[ "${job_status}" == "CANCELLED" ]]; then
        echo "Last job submitted ${last_job3_id} has been completed, failed, or cancelled."
        break
    fi
    sleep 150
done


### Move SAM files to SAM folder ################################
if [ ! -d SAM ]; then
  mkdir SAM
  for dir in map_*/; do # for all directories starting with map
    cd ${dir} # change into that directory
    filename=$(basename *.sam .sam); #pull basename of the .sam filetype
    mv ${filename}.sam ../SAM
    cd ..
  done; 
fi;
