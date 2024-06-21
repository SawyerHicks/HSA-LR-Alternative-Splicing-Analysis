import os
import sys
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages

def read_data_and_create_directory(input_file):
    df = pd.read_csv(input_file, sep='\t')
    file_name_without_extension, file_extension = os.path.splitext(input_file)
    file_parts = file_name_without_extension.split("_")
    FDR = file_parts[3]
    AbsIncLevelDiff = file_parts[5]
    new_directory = f"Skipped-exon-stripplots-FDR_{FDR}_AbsIncLevelDiff_{AbsIncLevelDiff}"
    os.makedirs(new_directory, exist_ok=True)
    
    return df, new_directory

def create_stripplot_and_save(row, new_directory):
    # Prepare the data for the stripplot
    inc_level1_values = [row['IncLevel1_1'] * 100, row['IncLevel1_2'] * 100, row['IncLevel1_3'] * 100]
    inc_level2_values = [row['IncLevel2_1'] * 100, row['IncLevel2_2'] * 100, row['IncLevel2_3'] * 100]
    plot_data = pd.DataFrame({
        'Group': ['Group1'] * 3 + ['Group2'] * 3,
        'IncLevel': inc_level1_values + inc_level2_values,
    })

    # Gather meta data to add to plot
    fdr = row['FDR']
    diff = row['AbsIncLevelDifference']
    geneName = row['geneSymbol']
    ncbi_key = row['chr'] + ':' + str(row['exonStart_0base']) + '-' + str(row['exonEnd'])

    # Create the stripplot using seaborn
    ax = sns.stripplot(x='Group', y='IncLevel', data=plot_data, size=10, jitter=0.2)

    # Add mean value bars
    mean1 = plot_data.loc[plot_data['Group'] == 'Group1', 'IncLevel'].mean()
    mean2 = plot_data.loc[plot_data['Group'] == 'Group2', 'IncLevel'].mean()

    mean_line1 = ax.axhline(y=mean1, xmin=0.125, xmax=0.375, color='black', linestyle='--', label='Group 1 Mean')
    mean_line2 = ax.axhline(y=mean2, xmin=0.625, xmax=0.875, color='black', linestyle='--', label='Group 2 Mean')

    # Set the y-axis range from -5 to 115
    plt.ylim(-10, 115)

    # Add meta data to plot
    plt.suptitle(geneName)
    plt.title(ncbi_key)

    # Add FDR and dPSI to plot
    # Check if any data points are in the area where the p-value text will be displayed
    data_points_in_data_area = plot_data[(plot_data['IncLevel'] < 20) & (plot_data['Group'] == 'Group2')]
    if data_points_in_data_area.empty:
        fdr_value_position = (0.95, 0.1)  # Bottom right corner
        dPSI_value_position = (0.95, 0.05)
    else:
        fdr_value_position = (0.95, 0.90)  # Top right corner
        dPSI_value_position = (0.95, 0.95)

    # Display the FDR and dPSI text
    fdr_value_text = f"FDR: {fdr:.4f}"
    dPSI_value_text = f"dPSI: {diff:.4f}"

    plt.annotate(fdr_value_text, xy=fdr_value_position, xycoords='axes fraction', ha='right')
    plt.annotate(dPSI_value_text, xy=dPSI_value_position, xycoords='axes fraction', ha='right')

    # Change the y-axis label to "Percent Spliced In"
    ax.set_ylabel("Percent Spliced In", fontsize=12)

    # Change the x-axis label to "Mouse"
    ax.set_xlabel("Mouse", fontsize=12)

    # Adjust the layout to prevent overlapping and clipping
    plt.tight_layout()

    # Save the plot as a PDF with the specified naming convention
    file_name = f"{row['geneSymbol']}_{row['chr']}_{row['exonStart_0base']}_{row['exonEnd']}_FDR{row['FDR']}_AbsIncLevelDifference{row['AbsIncLevelDifference']}.pdf"
    with PdfPages(os.path.join(new_directory, file_name)) as pdf:
        pdf.savefig()

    # Clear the figure for the next plot
    plt.clf()


def main():
    input_file = sys.argv[1]
    df, new_directory = read_data_and_create_directory(input_file)

    for index, row in df.iterrows():
        create_stripplot_and_save(row, new_directory)

if __name__ == "__main__":
    main()
