#!/bin/bash

#SBATCH --partition=ultrasound
#SBATCH --mem=32000
#SBATCH --cpus-per-task=4
#SBATCH --mail-user=jc500@duke.edu
#SBATCH --mail-type=END
#SBATCH --exclude=dcc-ultrasound-02,dcc-ultrasound-03,dcc-ultrasound-04,dcc-ultrasound-05,dcc-ultrasound-06,dcc-ultrasound-07,dcc-ultrasound-08,dcc-ultrasound-09,dcc-ultrasound-10,dcc-ultrasound-11

date
hostname

module load Matlab/R2017b
matlab -nojvm -nodisplay -nosplash -r "cd('/datacommons/ultrasound/jc500/GIT/ooFullwave/');tic;benchmark_test_v1;toc;exit;"