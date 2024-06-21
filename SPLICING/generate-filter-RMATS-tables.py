# Author - Sawyer Hicks
# Date - 2023-04-18
# Description:
# This script reads in files produced by process-RMATS-SE-output.py
# First, it reads in the file as a pandas DataFrame.
# Then it creates a list of FDR values and a list of AbsIncLevelDifference values.
# Then it creates a list of lists to store the summary data.
# Then it loops through the FDR values and the AbsIncLevelDifference values.
# For each combination of FDR and AbsIncLevelDifference, it filters the DataFrame to only include rows that meet the criteria.
# Then it saves the filtered DataFrame to a new csv file.
# Then it appends the FDR, AbsIncLevelDifference, and number of remaining events to the summary data list.
# Then it creates a DataFrame from the summary data list.
# Then it creates a PDF file and saves the summary table to it.
# Usage:
# python generate-filter-RMATS-tables.py SE.MATS.JCEC_processed.tsv
# Output:
# SE.MATS.JCEC_processed_FDR_X_AbsIncLevelDiff_X.tsv 

import sys
import pandas as pd
from matplotlib.backends.backend_pdf import PdfPages
import matplotlib.pyplot as plt

def generate_filtered_files(input_file, df):
    FDR_values = [0.1, 0.05, 0.01]
    AbsIncLevelDifference_values = [0.05, 0.1, 0.2]
    summary_data = []
    
    for fdr in FDR_values:
        for aild in AbsIncLevelDifference_values:
            filtered_df = df[(df['FDR'] <= fdr) & (df['AbsIncLevelDifference'] >= aild)]
            output_file = f"{input_file.split('.')[0]}_FDR_{fdr}_AbsIncLevelDiff_{aild}.tsv"
            filtered_df.to_csv(output_file, sep='\t', index=False)
            summary_data.append([fdr, aild, len(filtered_df)])

    return summary_data


def create_summary_table(summary_data):
    summary_df = pd.DataFrame(summary_data, columns=['FDR', 'AbsIncLevelDifference', 'RemainingEvents'])
    return summary_df

def export_summary_table_to_pdf(summary_df, pdf_file_name, font_size=8):
    with PdfPages(pdf_file_name) as pdf:
        fig, ax = plt.subplots()
        ax.axis('tight')
        ax.axis('off')
        table = ax.table(cellText=summary_df.values, colLabels=summary_df.columns, cellLoc='center', loc='center')
        table.auto_set_font_size(False)
        table.set_fontsize(font_size)
        table.auto_set_column_width(col=list(range(len(summary_df.columns))))
        pdf.savefig(fig, bbox_inches='tight')

def main(input_file):
    df = pd.read_csv(input_file, sep='\t')
    summary_data = generate_filtered_files(input_file, df)
    summary_df = create_summary_table(summary_data)
    pdf_file_name = f"{input_file.split('.')[0]}_SummaryTable.pdf"
    export_summary_table_to_pdf(summary_df, pdf_file_name)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Please provide an input file as the first argument.")
        sys.exit(1)
    main(sys.argv[1])
