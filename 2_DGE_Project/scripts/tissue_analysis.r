library("DESeq2")

args <- commandArgs(trailingOnly = TRUE)

counts_file <- args[1]
sample_csv <- args[2]

raw_counts <- read.delim(counts_file, header = TRUE, skip = 1, row.names = "Geneid")

counts <- raw_counts[, 6:ncol(raw_counts)]

colnames(counts) <- gsub(".*/", "", colnames(counts))
colnames(counts) <- gsub("\\.bam$", "", colnames(counts))

sample_info <- read.csv(sample_csv)

rownames(sample_info) <- sample_info$SampleID

sample_info <- sample_info[colnames(counts), ]

dds <- DESeqDataSetFromMatrix(
    countData = counts,
    colData = sample_info,
    design = ~ tissue
)

dds <- dds[rowSums(counts(dds)) >= 10, ]

dds <- DESeq(dds)

res <- results(dds, contrast = c("TISSUE", "L", "SM"))
res <- res[order(res$padj), ]
summary(res)