# R Analysis of the outputted results to make volcano plot

# Loading relevant libraries 
library(tidyverse) # includes ggplot2, for data visualisation. dplyr, for data manipulation.
library(RColorBrewer) # for a colourful plot
library(ggrepel) # for nice annotations

# Enter the working directory where the csv files located
setwd("")
# Path name of file will change based on graph you are attempting to generate
path <- "TopDEgenes_LiverSkelMusc.csv"
df <- read.csv('TopDEgenes_LiverSkelMusc.csv')

# Add a column to the data frame to specify if they are UP- or DOWN- regulated (log2fc respectively positive or negative)<br /><br /><br />
df$diffexpressed <- "NO"
df$diffexpressed[df$logFC > 0.6 & df$P.Value < 0.05] <- "UP"
df$diffexpressed[df$logFC < -0.6 & df$P.Value < 0.05] <- "DOWN"
head(df[order(df$adj.P.Val) & df$diffexpressed == 'DOWN', ])
df$delabel <- ifelse(df$SYMBOL %in% head(df[order(df$adj.P.Val), "SYMBOL"], 30), df$SYMBOL, NA)

theme_set(
  theme_classic(base_size = 20) +
    theme(
      axis.title.y = element_text(face = "bold", margin = margin(0,20,0,0), size = rel(1.0), color = 'black'),
      axis.title.x = element_text(hjust = 0.5, face = "bold", margin = margin(20,0,0,0), size = rel(1.0), color = 'black'),
      plot.title = element_text(hjust = 0.5),
      legend.key.size = unit(3, 'lines')
    )
)


p1 <- ggplot(data = df, aes(x = logFC, y = -log10(adj.P.Val), col = diffexpressed, label=delabel)) +
  geom_point() +
  scale_color_manual(values = c("#003058", "grey", "#BA1C21"),
                     labels = c("Downregulated", "Not Significant", "Upregulated")) +
	  # Enter Title Here
  ggtitle('Gene expression differences between Skeletal and Liver Muscle') +
  labs(color = 'Differential Expression') +
  geom_vline(xintercept = c(-0.6, 0.6), col = "black", linetype = 'dashed') +
  geom_hline(yintercept = -log10(0.08), col = "black", linetype = 'dashed') +
  # Spreads out the name of the significant genes
  geom_text_repel(data = subset(df, diffexpressed != "NO"), aes(label = delabel), size = 5, max.overlaps = Inf, box.padding = .5, point.padding=.5)+
  # Puts in ticks on x and y axis
  scale_x_continuous(breaks = se(-20, 20, by = 2)) +
  scale_y_continuous(breaks = seq(0, 20, by = 20))

# Make sure you rename the pdf to your desired file name.
ggsave("LiverSkelMusc.pdf",p1, width=5, height=5, units="in", scale=3)

