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

