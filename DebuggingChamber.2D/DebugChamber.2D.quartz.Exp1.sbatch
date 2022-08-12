#!/bin/bash
#### See https://hpc.llnl.gov/training/tutorials/slurm-and-moab#LC

##### These lines are for Slurm
#SBATCH -N 1
#SBATCH -J 2DDebugChamber_N1_S10000_Exp1
#SBATCH -t 24:00:00
#SBATCH -p pbatch
#SBATCH --mail-type=ALL
#SBATCH -A sunyb

##### Load Required modules
# gcc
module load mkl/2019.0
module load valgrind/3.16.1
module load gcc/10.2.1
module load  cmake/3.21.1 

# Load PETSC ENV
export PETSC_DIR="/g/g20/arnav/petsc"
export PETSC_ARCH="arch-ablate-opt-gcc" # arch-ablate-debug or arch-ablate-opt
export PKG_CONFIG_PATH="${PETSC_DIR}/${PETSC_ARCH}/lib/pkgconfig:$PKG_CONFIG_PATH"
export HDF5_ROOT="${PETSC_DIR}/${PETSC_ARCH}"  
# Include the bin directory to access mpi commands
export PATH="${PETSC_DIR}/${PETSC_ARCH}/bin:$PATH"

# Make a temp directory so that tchem has a place to vomit its files
mkdir tmp_$SLURM_JOBID
cd tmp_$SLURM_JOBID

##### Experiment1
# Cold flow
# Turn off Hot spheres
# Turn off grain preheat
# Disable additional heat flux

##### Launch parallel job using srun
srun -n36 /g/g20/arnav/ablateOpt/ablate \
	--input /p/lustre1/arnav/ablateInputs/DebuggingChamber.2D/DebugChamber.2D.yaml \
	-yaml::environment::title 2DDebugChamber_N1_S10000_Exp1 \
	-yaml::timestepper::arguments::ts_max_step 10000 \
	-yaml::timestepper::io::interval 50 \
	-yaml::timestepper::domain::fields::[0]::conservedFieldOptions::petscfv_type upwind \

# Experimental modifiers
    -yaml::timestepper::domain::path ../geom/DebugChamberProfile.t14855.msh \
    -yaml::solvers::[1]::processes::velocity "min(50, t*50/0.025), 0" \
    -yaml::initialization::[0]::state:temperature::insideValues [298.15] \
    -yaml::initialization::[4]::state:temperature 298.15 \
    -yaml::solvers::[4]::processes::[0]::additionalHeatFlux::insideValues 0

	
echo 'Done'
