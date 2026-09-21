# R Analysis of the outputted results to make volcano plot

# Loading relevant libraries 
library(tidyverse) # includes ggplot2, for data visualisation. dplyr, for data manipulation.
library(RColorBrewer) # for a colourful plot

#Assign the command line args
args <- commandArgs(trailingOnly = TRUE)
csv_file <- args[1]
Title <- args[2]
output <- args[3]

df <- read.csv(csv_file)

# Add a column to the data frame to specify if they are UP- or DOWN- regulated (log2fc respectively positive or negative)<br /><br /><br />
df$diffexpressed <- "NO"
df$diffexpressed[df$log2FoldChange > 1.0 & df$pvalue < 0.05] <- "UP"
df$diffexpressed[df$log2FoldChange < -1.0 & df$pvalue < 0.05] <- "DOWN"
head(df[order(df$padj) & df$diffexpressed == 'DOWN', ])
df$delabel <- ifelse(df$Geneid %in% head(df[order(df$padj), "Geneid"], 30), df$Geneid, NA)

theme_set(
  theme_classic(base_size = 20) +
    theme(
      axis.title.y = element_text(face = "bold", margin = margin(0,20,0,0), size = rel(1.0), color = 'black'),
      axis.title.x = element_text(hjust = 0.5, face = "bold", margin = margin(20,0,0,0), size = rel(1.0), color = 'black'),
      plot.title = element_text(hjust = 0.5),
      legend.key.size = unit(3, 'lines')
    )
)


p1 <- ggplot(data = df, aes(x = log2FoldChange, y = -log10(padj), col = diffexpressed, label=delabel)) +
  geom_point() +
  scale_color_manual(values = c("#003058", "grey", "#BA1C21"),
                     labels = c("Downregulated", "Not Significant", "Upregulated")) +
	  # Enter Title Here
  ggtitle(Title) +
  labs(color = 'Differential Expression') +
  geom_vline(xintercept = c(-0.6, 0.6), col = "black", linetype = 'dashed') +
  geom_hline(yintercept = -log10(0.08), col = "black", linetype = 'dashed') +
  # Spreads out the name of the significant genes
  geom_text(data = subset(df, diffexpressed != "NO"), aes(label = delabel), size = 5) +
  # Puts in ticks on x and y axis
  scale_x_continuous(breaks = seq(-20, 20, by = 2)) +
  scale_y_continuous(breaks = seq(0, 20, by = 20))

# Make sure you rename the pdf to your desired file name.
ggsave(output,p1, width=5, height=5, units="in", scale=3)