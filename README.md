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

# whiptail_dge_tissues

Project worked on between BIOL 4310 at Utah Tech University and Undergraduate Research at BYU
## Differential Gene Expression across localities and tissue types
Authors: Baylee Christensen, Syrus Miner, Seun Onileowo, Perry Van Wagoner

## Contents
- [Documentation] (#documentation)
- [Abstract] (#abstract)
- [Introduction] (#program_requirements)
- [Instructions] (#instructions)

## Documentation
### Project Objectives

1. Bioinformatic pipeline to understand differential gene expression
    - Set up file structure and EAGLE-RC
    - Trim and clean Raw Reads
    - Map cleaned reads to reference genomes
    - Merge paired end reads
    - Parental assignment (EAGLE-RC)
    - Perform feature counts
    - Create plots to visualize data

### Languages Used

Bash, R

### External Tools/Packages Used
1. fastp for trimming. We chose fastp for it's speed and it's accuracty in trimming. It also has an easy to understand user interface
2. fastqc for quality checking of reads
3. STAR for mapping, functioned more quickly than bwamem, which is what we initially started out using
4. samtools for merging mapped reads
5. subread -> featureCounts, to count the number of reads referenced to the genome in defined locations
6. ggplot2 (tidyverse), RColorBrewer, and ggrepel for creating plots in R

## Abstract
Understanding gene expression across different tissue types is a crucial step to unravel underlying physiological functions between tissues. This research addresses the unique gene expression profiles of heart, skeletal muscle, and lung tissues by accessing RNA-Seq data from a cohort of individuals of the species Aspidoscelis tesselatus. This species is particularly interesting to study due to their asexuality, reproducing through parthenogenesis. We utilized advanced bioinformatics tools such as fastp for trimming to extract quality reads, STAR for read mapping to Aspidoscelis marmoratus, and featureCounts to count the number of RNA transcripts mapped. The results of this analysis can help us identify and compare differential gene patterns among these tissues.


## Things to note
these scripts are designed for use with a cluster running SLURM.
Attempts to use this scripts not on said cluster will require modification.

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

### Step 2: Set up EAGLE-RC
This project requires the tool EAGLE-RC for use in parental assignment.
1. on a login node (can be done on a compute node if it has internet access) run
   the setup_eagle.sh script.
2. Confirm installation by viewing the tools directory, it should now have
   files for the tool EAGLE-RC

### Step 3: Directory setup
1. This project expects you to have your own directory containing all of your fastq files
2. create directories with the following path for reference fastas fastq/references/fastaName/file.fasta
4. This directory is what you will pass to the run_dge_pipeline.sh script with the option -d

### Step 3: Running the script
1. The script that you should use to run the sbatch is as follows:
```
sbatch run_dge_pipeline.sh -d path/to/your/fastq/directory
```
2. Ideally, this submits all of the jobs at once. It won't in this case, please view s.run.sh to see what line needs to be changed based off of your preferences.

# MITO Project - Mitochondrial Differential Gene Expression
This is an undergraduate research project for credit, and is part of the course
scripting for biologists in Fall 2024

## Mitochondrial Differential Gene Expression in A. tesselatus
Authors: Baylee Christensen, Syrus Miner

## Contents
- [Documentation] (#documentation)
- [Abstract] (#abstract)
- [Introduction] (#program_requirements)
- [Instructions] (#instructions)

## Documentation
### Project Objectives
1. Dissect the differences in mitochondrial gene expression from paternal and
   maternal lineages in the asexual species A. tesselatus.
2. Draft documented and reproducible bioinformatic pipeline to generate results
3. Present research in oral engagement, showcasing best practice techniques

### Project questions and Focus
How does mitochondrial gene expression in Aspidoscelis tesselatus differ in
paternal and maternal lineages?

We attempt to understand the mitochondrial respiration dynamics through gene
expression in the mitochondrial genome and the mitonuclear genome.

##### Interparental Incompatibility
In this scenario, we would predict to see a higher or equal amount of
paternal gene expression compared to maternal gene expression. A potential
mechanism that could explain this would be paternal gene products are
produced, but do not have the same compatibility with maternal gene
products, as the paternal lineage is a 'different species' and therefore
did not co-evolve with the maternal lineage of mitochondrial products.
##### Intraparental Incompatibility
In this scenario, we would predict to see a lower amount of gene expression in
the paternal lineage compared to the maternal lineage. There are many mechanisms
that could explain this scenario, one being that the maternal gene products that
interact with each other is present but not functioning ideally. More maternal
expression may be occurring in an attempt to accommodate for this insufficiency.

### Hypothesis
1. Lower mitonchondrial function is due to differing mitonuclear dynamics in the
   unisexual species compared to asexual species

### Abstract
Whiptail lizards exhibit a fascinating reproductive strategy known as parthenogenesis, where females reproduce asexually, producing genetically identical offspring without male contribution. This mode of reproduction has implications for mitochondrial function, as asexual species often display lower-quality mitochondrial activity compared to their sexually reproducing counterparts. In this study, we focus on the differential gene expression in mitochondrial genes among whiptail populations, aiming to uncover potential consequences of parthenogenesis on cellular function.

By sequencing multiple individuals, we define the paternal and maternal lineage boundaries within the mitochondrial genome, offering insight into how gene expression differs across these lineages. Our findings suggest that parthenogenetic species may experience compromised mitochondrial function due to a lack of genetic diversity, impacting energy production and overall fitness. This research sheds light on the evolutionary trade-offs of asexual reproduction and contributes to our understanding of mitochondrial dynamics in asexually reproducing organisms.
### Languages used
Bash, Python, R

### Number of Scripts

### External Tools/Packages Used

### Purpose of each Script


