library(dplyr)
library(DESeq2)

#Assign the command line args
args <- commandArgs(trailingOnly = TRUE)
counts_file <- args[1]
sample_csv <- args[2]
output <- args[3]

#read in the featurecounts files
raw_counts <- read.delim(counts_file, header = TRUE, skip = 1)

raw_counts <- raw_counts |>
    rename_with(~ sub("\\..*$", "", basename(.x)), .cols = 7:ncol(raw_counts))

#read in the csv with sample data
sample_data <- read.csv(sample_csv, stringsAsFactors = FALSE) |>
    rename(SampleID = 1, Sample = 2, Tissue = 3, State = 4, County = 5)


#get just skeletal muscle data
sm_info <- sample_data |>
    filter(Tissue == "SM") |>
    mutate(County = relevel(factor(County), ref = "Culberson")) |>
    arrange(match(SampleID, colnames(raw_counts)))

count_matrix <- raw_counts |>
    select(Geneid, all_of(sm_info$SampleID)) |>
    tibble::column_to_rownames("Geneid") |>
    as.matrix()

sm_info <- sm_info |>
    slice(match(colnames(count_matrix), SampleID)) |>
    tibble::column_to_rownames("SampleID")

dds_sm <- DESeqDataSetFromMatrix(
    countData = count_matrix,
    colData = sm_info,
    design = ~ County
)
dds_sm <- DESeq(dds_sm)

dds_lrt <- DESeq(dds_sm, test = "LRT", reduced = ~ 1)
res_lrt <- results(dds_lrt)

res_lrt_df <- as.data.frame(res_lrt) |>
    tibble::rownames_to_column("Geneid") |>
    arrange(padj)

write.csv(res_lrt_df, output, row.names = FALSE)
