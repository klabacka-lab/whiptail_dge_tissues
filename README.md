# whiptail_dge_tissues
This repository contains 3 different projects:
1. 1_GATK_Project: DGE using GATK
2. 2_DGE_Project: DGE using fastp
3. 3_MITO_DGE: Mitochondrial context of DGE

## Contents
- [Documentation] (#documentation)
- [Introduction] (#program_requirements)
- [Instructions] (#instructions)

## Things to note and program requirements
1. You must have access to the chpc supercomputer. Otherwise, you will have to manually install all of the python packages required to do the trimming.
2. You must have access to the Utah Tech scratch directory. This will vary for each individual during each year. Our directory appears like the following for this dataprocess:
```
/scratch/general/nfs1/utu_4310/whiptail_dge_working_directory
```
3. There must be data in the directories you are working with. You will need a reference genome, which we gathered from Dr. Klabacka, and also the tissue data we are doing the actual analysis on.
4. You must clone this GitHub repository, and instructions on how to do so are listed below

# Instructions

### Step 1: Cloning the Repository
1. Ensure you have git installed. Instructions on installing git can be found
[here](https://git-scm.com/downloads)
2. Open your terminal and navigate to the directory you wish to put the
   repository. This would look something like ```cd ~/GitHubRepositories```
3. Assuming you are reading this, you are on the page of the repository. Scroll up to click on the green clone button and copy
   the repository's URL for cloning. Then, on your terminal, use the command:
   ```
   git clone <repository URL>
   ```
4. Git then downloads the entire repository to your local device.  You'll see
   progress information as the cloning takes place.
5. Once cloning is complete, you'll have a copy of the repository on your local
   machine in the subdirectory with the same name as the repository. You now
   should navigate into this directory to use functions this repository has.

### Step 2: Set working directory
Where did you clone this github repository? That is now your working directory. From this working directory is where you will submit all of the functions required. The output files, AKA the RESULTS of these functions will be in:
```
/scratch/general/nfs1/utu_4310/whiptail_dge_working_directory
```
                                                              43,7          Bot
# 1. GATK Project
Gene expression in species varies across tissue types and in the same tissues across populations. In this dataset we have two sets of transcriptomic data:

Dataset 1: 17 individuals from three populations (skeletal muscle)

Dataset 2: six individuals from a single population (heart, liver, and skeletal muscle)

Each of these datasets require read cleaning, mapping to an annotated genome, and obtaining a read count matrix for each gene. Analyses of the two datasets diverge at this point, where gene expression differences between populations (Dataset 1) and differences between tissue types (Dataset 2) are examined. 43,7 Bot

# 2. DGE Project -- whiptail_dge_tissues

This is a project for the Advanced Bioinformatics course at Utah Tech University (BIOL 4310)
## Differential Gene Expression for Heart, Lung, and Skeletal Muscle 2024
Authors: Baylee Christensen, Syrus Miner, Seun Onileowo

Completed: April 2024
## Contents
- [Documentation] (#documentation)
- [Abstract] (#abstract)
- [Introduction] (#program_requirements)
- [Instructions] (#instructions)

## Documentation
### Project Objectives

1. Draft own Bioinformatic pipeline to understand differential gene expression
    - Set up file structure
    - Trim Raw Reads
    - Map cleaned reads to reference genome
    - Merge paired end reads and count to understand what is being expressed
    - Create plots to visualize data
2. Present poster in front of an audience describing what we learned


### Languages Used

Bash, R

### Number of scripts

Seven total scripts, including the batch script

0. s.run.sh (runs all the other scripts except for the R plot)
1. environment_setup.sh
2. new_trim_rna_reads.sh
3. map_reads_star.sh (preferred over map_reads_bwamem.sh)
4. merge_merged_and_unmerged_merges.sh (or s.merge.sh)
5. count_reads.sh
6. whiptail_dge_R_volcano_plot.R


### External Tools/Packages Used
1. fastp for trimming. We chose fastp for it's speed and it's accuracty in trimming. It also has an easy to understand user interface
2. fastqc for quality checking of reads
3. STAR for mapping, functioned more quickly than bwamem, which is what we initially started out using
4. samtools for merging mapped reads
5. subread -> featureCounts, to count the number of reads referenced to the genome in defined locations
6. ggplot2 (tidyverse), RColorBrewer, and ggrepel for creating plots in R

### Purpose of each script

0. s.run.sh (runs all the other scripts except for the R plot)
1. environment_setup.sh - Sets up filesystem for user to organize cleaned reads, mapped reads, merged/unmerged reads
2. new_trim_rna_reads.sh, trims the reads for quality
3. map_reads_star.sh (preferred over map_reads_bwamem.sh), mapped reads to reference genome
4. merge_merged_and_unmerged_merges.sh (or s.merge.sh), merges all reads, due to gaps that can be left over that occure through trimming
5. count_reads.sh - counting the reads mapped to genome in distinct locations
6. whiptail_dge_R_volcano_plot.R - to plot executed dataset

## Abstract
Understanding gene expression across different tissue types is a crucial step to unravel underlying physiological functions between tissues. This research addresses the unique gene expression profiles of heart, skeletal muscle, and lung tissues by accessing RNA-Seq data from a cohort of individuals of the species Aspidoscelis tesselatus. This species is particularly interesting to study due to their asexuality, reproducing through parthenogenesis. We utilized advanced bioinformatics tools such as fastp for trimming to extract quality reads, STAR for read mapping to Aspidoscelis marmoratus, and featureCounts to count the number of RNA transcripts mapped. The results of this analysis can help us identify and compare differential gene patterns among these tissues.


## Things to note and program requirements
1. You must have access to the chpc supercomputer. Otherwise, you will have to manually install all of the python packages required to do the trimming.
2. You must have access to the Utah Tech scratch directory. This will vary for each individual during each year. Our directory appears like the following for this dataprocess:
```
/scratch/general/nfs1/utu_4310/whiptail_dge_working_directory
```
3. There must be data in the directories you are working with. You will need a reference genome, which we gathered from Dr. Klabacka, and also the tissue data we are doing the actual analysis on.
4. You must clone this GitHub repository, and instructions on how to do so are listed below

# Instructions

### Step 1: Cloning the Repository
1. Ensure you have git installed. Instructions on installing git can be found
[here](https://git-scm.com/downloads)
2. Open your terminal and navigate to the directory you wish to put the
   repository. This would look something like ```cd ~/GitHubRepositories```
3. Assuming you are reading this, you are on the page of the repository. Scroll up to click on the green clone button and copy
   the repository's URL for cloning. Then, on your terminal, use the command:
   ```
   git clone <repository URL>
   ```
4. Git then downloads the entire repository to your local device.  You'll see
   progress information as the cloning takes place.
5. Once cloning is complete, you'll have a copy of the repository on your local
   machine in the subdirectory with the same name as the repository. You now
   should navigate into this directory to use functions this repository has.

### Step 2: Set working directory
Where did you clone this github repository? That is now your working directory. From this working directory is where you will submit all of the functions required. The output files, AKA the RESULTS of these functions will be in:
```
/scratch/general/nfs1/utu_4310/whiptail_dge_working_directory
```
### Step 3: Running the script
1. The script that you should use to run the sbatch is as follows:
```
sbatch s.run.sh -d /path/to/github/repository/clone/bash
```
2. Ideally, this submits all of the jobs at once. It won't in this case, please view s.run.sh to see what line needs to be changed based off of your preferences.

