#!/bin/bash
#SBATCH --job-name="runner"      		# Job name
#SBATCH --ntasks=1                   		# Run a single task
#SBATCH --mem=30gb                     	# Job memory request
#SBATCH --cpus-per-task=1            		# Number of CPU cores per task
#SBATCH --time=48:00:00              		# Time limit hrs:min:sec
#SBATCH --output=output-%J.log     		# Standard output and error log
date;hostname;pwd

source ~/.bashrc
conda activate custom-environment

# Make variables for the scripts you will use
process_script="$PWD/submit-process-RMATS-SE-output.sbatch"
tables_script="$PWD/submit-generate-filter-RMATS-tables.sbatch"
two_group_plots_script="$PWD/submit-create-two-group-PSI-plots.sbatch"

# Iterate over the RMATS/ folder and create a new folder of the same name in the SPLICING/ folder
# Then copy the SE.MATS.JCEC.txt file to the new folder
# Then go back to the parent directory to avoid generating a nested folder strucutre
for folder in ../RMATS/*/
do
    # Skip folders with "tmp" in the name
    if [[ "${folder}" != *"tmp"* ]]
    then
        # Extract the folder name without the path
        folder_name=$(basename "${folder}")

        # Create a new directory with the same name as the folder
        mkdir -p "${folder_name}"
        cd "${folder_name}"
        echo "created ${folder_name}"

        # Copy the file SE.MATS.JCEC.txt to the new folder
        cp "../${folder}SE.MATS.JCEC.txt" .
        echo "copied SE.MATS.JCEC.txt from ../${folder} to $PWD"
        # Go back to the parent directory
        cd ..

    fi
done

# Iterate across the new folders and submit the SE.MATS.JCEC.txt file to the process_script
echo "Iterate across the new folders and submit the SE.MATS.JCEC.txt file to the process_script"
last_job1_id=""
for new_folder in ./*/
do
    if [[ "${new_folder}" != *"tmp"* ]]
    then
        cd "${new_folder}"

        # Submit the SE.MATS.JCEC.txt file to the script
        last_job1_id=$(sbatch ${process_script} "SE.MATS.JCEC.txt" | awk '{print $NF}')
        echo "Submit skipped-exon files for processing"
        # Go back to the parent directory
        cd ..
        echo "done"
    fi
done
sleep 10

# Wait for the last job to complete
while true; do
    job_status=$(scontrol show job "${last_job1_id}" | grep -oP "JobState=\K\w+")
    if [[ "${job_status}" == "COMPLETED" ]] || [[ "${job_status}" == "FAILED" ]] || [[ "${job_status}" == "CANCELLED" ]]; then
        echo "Last job submitted ${last_job1_id} has been completed, failed, or cancelled."
        break
    fi
    echo "Checking if last_job1_id: ${last_job1_id} is finished" 
    sleep 60
done

# Use the processed data as input and generate filtered tables
echo "Use the processed data as input and generate filtered tables"
last_job2_id=""
for new_folder in ./*/
do
    if [[ "${new_folder}" != *"tmp"* ]]
    then
        cd "${new_folder}"

        # Submit the SE.MATS.JCEC.txt file to the script
        last_job2_id=$(sbatch ${tables_script} SE_processed.tsv | awk '{print $NF}')
        echo "Submit SE_processed.tsv to generate tables"
        # Go back to the parent directory
        cd ..
    fi
done
sleep 10

# Wait for the last job to complete
while true; do
    job_status=$(scontrol show job "${last_job2_id}" | grep -oP "JobState=\K\w+")
    if [[ "${job_status}" == "COMPLETED" ]] || [[ "${job_status}" == "FAILED" ]] || [[ "${job_status}" == "CANCELLED" ]]; then
        echo "Last job submitted ${last_job2_id} has been completed, failed, or cancelled."
        break
    fi
    echo "Checking if last_job1_id: ${last_job2_id} is finished" 
    sleep 60
done

# Iterate over each table, create a new directory, cd into it, and creates plots
echo "Iterate over each table, create a new directory, cd into it, and create plots" 
echo "Starting directory: "
echo "$PWD"
last_job3_id=""
for new_folder in ./*/
do
    echo "cd into new folder: "
    echo "${new_folder}"
    if [[ "${new_folder}" != *"tmp"* ]]
    then
        cd "${new_folder}"
        for tsv_files in *.tsv; do
            # Check if the file exists to avoid issues with no matching files
            if [ -e "${tsv_files}" ]; then
                last_job3_id=$(sbatch ${two_group_plots_script} "${tsv_files}" | awk '{print $NF}')
                echo "Submit ${tsv_files} to plot script"
            fi
            echo "finished submitting tsv files from ${new_folder}"
        done
        echo "Changing directory to... "
        cd ..
        echo "$PWD"
    fi
done

# Wait for the last job to complete
while true; do
    job_status=$(scontrol show job "${last_job3_id}" | grep -oP "JobState=\K\w+")
    if [[ "${job_status}" == "COMPLETED" ]] || [[ "${job_status}" == "FAILED" ]] || [[ "${job_status}" == "CANCELLED" ]]; then
        echo "Last job submitted ${last_job3_id} has been completed, failed, or cancelled."
        break
    fi
    echo "Checking if last_job1_id: ${last_job3_id} is finished" 
    sleep 60
done

echo "Data Processing Completed"