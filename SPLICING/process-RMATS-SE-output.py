# This script processes the output of the RMATS SE analysis. Specifically from SE.MATS.JC.txt or SE.MATS.JCEC.txt
# First it reads in the txt file as a pandas DataFrame and splits columns by tab and by comma.
# It uses the function separate_and_rename_columns to split the columns and rename them.
# Then it calculates the absolute value of the IncLevelDifference column and creates a new column AbsIncLevelDifference.
# Then it removes the ID column from the table.
# Then it creates a new 'Unify' column and appends it to the beginning of the table.
# Finally it saves the processed DataFrame to a new file.

import sys
import pandas as pd

def separate_and_rename_columns(df, col_name):
    max_col_split = df[col_name].apply(lambda x: len(x.split(','))).max()
    for i in range(max_col_split):
        new_col_name = f'{col_name}_{i+1}'
        df[new_col_name] = df[col_name].apply(lambda x: x.split(',')[i] if len(x.split(',')) > i else None)
    df.drop(col_name, axis=1, inplace=True)

def main(input_file):
    df = pd.read_csv(input_file, sep='\t')

    columns_to_split = ['IJC_SAMPLE_1', 'SJC_SAMPLE_1', 'IJC_SAMPLE_2', 'SJC_SAMPLE_2', 'IncLevel1', 'IncLevel2']
    for col in columns_to_split:
        separate_and_rename_columns(df, col)

    # Calculate the absolute value of the IncLevelDifference column and create a new column AbsIncLevelDifference
    df['AbsIncLevelDifference'] = df['IncLevelDifference'].apply(abs)

    # Remove the ID column from the table
    df.drop('ID', axis=1, inplace=True)

    # Create a new 'Unify' column and append it to the beginning of the table
    df['Unify'] = df['GeneID'].astype(str) + '_' + df['chr'] + '_' + df['strand'] + '_' + df['exonStart_0base'].astype(str) + '_' + df['exonEnd'].astype(str)
    df = df[['Unify'] + [col for col in df.columns if col != 'Unify']]

    # Save the processed DataFrame to a new file
    output_file = input_file.split('.')[0] + '_processed.tsv'
    df.to_csv(output_file, sep='\t', index=False)

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Please provide an input file as the first argument.")
        sys.exit(1)
    main(sys.argv[1])
