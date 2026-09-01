This directory is intentionally left empty in the repository.

Before submitting any SLURM jobs, run the setup step once from the login node
to clone and build EAGLE-RC here (do NOT run this via sbatch — it requires
internet access, which compute nodes do not have):

    bash ../../bash_scripts/setup_eagle.sh <WORKDIR>

This will populate this folder with the EAGLE source, the htslib dependency,
and the compiled eagle-rc binary. None of that is tracked in this repo —