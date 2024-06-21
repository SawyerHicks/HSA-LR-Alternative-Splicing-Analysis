library(tidyverse)
library(matrixStats)
library(DESeq2)

setwd("/PATH/TO/DESEQ2/")
data_path = c("/PATH/TO/PREP-DE/")

# Load gene(/transcript) count matrix and labels
countData = as.matrix(read.csv(paste(data_path, "gene_count_matrix.csv", sep = ""), row.names="gene_id"))
# Sample_Name	Mouse	Condition	Mouse_Condition
colData = read.csv("pheno_data.csv", sep=",", row.names = 1)

# Check all sample IDs in colData are also in CountData and match their orders
all(rownames(colData) %in% colnames(countData)) # output should be true
countData <- countData[, rownames(colData)]

## Optional code to convert row names from this:
## ENSG00000227232|WASH7P
## to this
## WASH7P
# bignames <- rownames(countData)
# genes <- lapply(bignames, function(x) {
#   strsplit(x, "\\|")[[1]][-1]  
# })
# genes <- lapply(genes, function(x) unlist(x))  # Flatten the list of lists
# rownames(countData) <- genes

all(rownames(colData) == colnames(countData)) # output should be true

# use 'relevel' to set the base-line control sample group as the reference level
colData$Mouse_Condition_Drug <- relevel(colData$Mouse_Condition_Drug, ref = "WT_C_C")

# Mouse_Condition_Drug is an example of how to set up comparisons based on the pheno_data.csv table
#   See DESEQ2 documentation and Michael Love's comments (DESEQ2 creator) to get more background on this topic.
# Create a DESeqDataSet from count matrix and labels
dds = DESeqDataSetFromMatrix(countData = countData,
                             colData = colData, 
                             design = ~Mouse_Condition_Drug)

# Run the default analysis for DESeq2 and generate results table
dds <- DESeq(dds)

# pulls results for given comparisons 
# contrast must be formatted as "Design", "variable condition", "reference condition/base line"
res_WT_v_DM = as.data.frame(results(dds, contrast = c("Mouse_Condition_Drug", "DM_C_C", "WT_C_C")))
res_DM_v_Combo = as.data.frame(results(dds, contrast = c("Mouse_Condition_Drug", "DM_T_Combo", "DM_C_C")))

# pulls the counts for all genes 
counts_df = as.data.frame(counts(dds, normalized = TRUE))
counts_WT_v_DM = counts_df %>% select(contains("FVB"), contains("HSALR_NT"))
counts_DM_v_Combo = counts_df %>% select(contains("HSALR_NT"), contains("HSALR_Combo"))

# build results() and counts() table by joining counts_df to each results tables
WT_v_DM = merge(res_WT_v_DM, counts_WT_v_DM, by = "row.names")
DM_v_combo = merge(res_DM_v_Combo, counts_DM_v_Combo, by = "row.names")

# write the results to a csv file
write.csv(file = "WT_v_DM.csv", WT_v_DM)
write.csv(file = "DM_v_combo.csv", DM_v_combo)

## Optional volcano plot
library(EnhancedVolcano)
library(magrittr)
volcano_res = results(dds, (contrast = c("Mouse_Condition_Drug", "DM_C_C", "WT_C_C")))

# get row names from DESeq2 object
res = lfcShrink(dds, contrast = c("Mouse_Condition_Drug", "DM_C_C", "WT_C_C"), res = volcano_res, type = "normal")

# plot volcano
EnhancedVolcano(res,
                lab = rownames(res), 
                title = 'Wild Type vs HSA-LR',
                x = 'log2FoldChange',
                y = 'pvalue',
                FCcutoff = 2, 
                pCutoff = 10e-14,
                legendLabels = c('Not sig', 'Log (base 2) FC', 'p-adj value', 'p-adj value & Log (base 2) FC'),
                legendPosition = 'right')
