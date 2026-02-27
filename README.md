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
