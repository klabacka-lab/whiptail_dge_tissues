library(DESeq2)
library(dplyr)

#Assign the command line args
args <- commandArgs(trailingOnly = TRUE)
counts_file <- args[1]
sample_csv <- args[2]
output <- args[3]

#read in the featurecounts files
raw_counts <- read.delim(counts_file, header = TRUE, skip = 1, check.names = FALSE)

raw_counts <- raw_counts |>
    rename_with(~ sub("\\..*$", "", basename(.x)), .cols = 7:ncol(raw_counts))

#read in the csv with sample data
sample_data <- read.csv(sample_csv, stringsAsFactors = FALSE) |>
    rename(SampleID = 1, Sample = 2, Tissue = 3, State = 4, County = 5)


#get just skeletal muscle data
sm_info <- sample_data |>
    filter(County == "Culberson") |>
    mutate(Tissue = relevel(factor(Tissue), ref = "SM")) |>
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
    design = ~ Tissue
)
dds_sm <- DESeq(dds_sm)

tissue_levels <- levels(sm_info$Tissue)
pairs <- combn(tissue_levels, 2, simplify = FALSE)

for (pair in pairs) {
    level_A <- pair[2]
    level_B <- pair[1]

    res <- results(dds_sm, contrast = c("Tissue", level_A, level_B))

    res_df <- as.data.frame(res) |>
        tibble::rownames_to_column("Geneid") |>
        arrange(padj)

    label <- paste0(gsub(" ", "", level_A), "_vs_", gsub(" ", "", level_B))
    out_file <- paste0(output, "_", label, ".csv")

    write.csv(res_df, out_file, row.names = FALSE)
}