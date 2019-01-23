#!/bin/bash

#SBATCH --partition=ultrasound
#SBATCH --mem=32000
#SBATCH --cpus-per-task=8
#SBATCH --array=1-10%10
#SBATCH --exclude=dcc-ultrasound-01

date
hostname

module load Matlab/R2017b
matlab -nojvm -nodisplay -nosplash -r "cd('/datacommons/ultrasound/jc500/GIT/ooFullwave/benchmarking/');tic;benchmark_blur($SLURM_ARRAY_TASK_ID);toc;exit;"