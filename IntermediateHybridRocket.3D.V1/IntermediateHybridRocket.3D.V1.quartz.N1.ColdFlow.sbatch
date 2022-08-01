#!/bin/bash
#### See https://hpc.llnl.gov/training/tutorials/slurm-and-moab#LC

##### These lines are for Slurm
#SBATCH -N 1
#SBATCH -J 3dMotorCasing_N1_T3678_S1000_ColdFlow
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

##### Launch parallel job using srun
srun -n36 /g/g20/arnav/ablateOpt/ablate \
	--input /p/lustre1/arnav/ablateInputs/IntermediateHybridRocket.3D.V1/IntermediateHybridRocket.3D.V1.yaml \
	-yaml::environment::title 3dMotorCasing_N1_T3678_ColdFlow \
	-yaml::timestepper::arguments::ts_max_step 1000 \
	-yaml::timestepper::io::interval 10 \
	-yaml::timestepper::domain::fields::[0]::conservedFieldOptions::petscfv_type upwind \
	-yaml::timestepper::initialization::[0]::state::temperature::insideValues [298.15] \
	-yaml::timestepper::initialization::[0]::state::temperature::center [0.0,0.0,20] \


	
echo 'Done'
