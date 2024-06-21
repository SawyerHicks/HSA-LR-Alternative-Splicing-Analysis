#!/bin/bash

# data_runner_STRINGTIE.sh

# import file paths
annotation_gtf="/PATH/TO/GTF.gtf"

# for loop submitting bam to gtf using stringtie
echo "Submitting bam files for gtf construction"
last_job1_id="" # this will store the last job id submitted
for dir in ../HISAT2/map_*; do 
  
  filename=$(basename ${dir}/*.bam .bam)
  echo "Submitting ${dir}/${filename}.bam"

  job_id=$(sbatch stringtie_assemble_transcripts.sbatch "${filename}" "${dir}" "${annotation_gtf}" | awk '{print $NF}')

  # Update the last job ID
  last_job1_id="${job_id}"
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
    echo "Waiting 3 minutes for ${last_job1_id} to complete before checking again."
    sleep 180
done


# create a mergelist
echo "Creating mergelist.txt"
ls -1 *.gtf > mergelist.txt


last_job2_id=""
# merge stringtie output gtfs with stringtie --merge
last_job2_id=$(sbatch stringtie_merge.sbatch "${annotation_gtf}" mergelist.txt | awk '{print $NF}')

# Wait for the last job to complete
while true; do
    job_status=$(scontrol show job "${last_job2_id}" | grep -oP "JobState=\K\w+")
    if [[ "${job_status}" == "COMPLETED" ]] || [[ "${job_status}" == "FAILED" ]] || [[ "${job_status}" == "CANCELLED" ]]; then
        echo "Last job submitted ${last_job2_id} has been completed, failed, or cancelled."
        break
    fi
    echo "Waiting 3 minutes for ${last_job2_id} to complete before checking again."
    sleep 180
done

# compare our list of transcripts to our known GTF list
gffcompare -r ${annotation_gtf} -G -o merged stringtie_merged.gtf
