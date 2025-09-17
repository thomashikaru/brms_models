#!/bin/bash
#SBATCH --job-name=brms_model
#SBATCH --output=outputs/logs/slurm_%j.out
#SBATCH --error=outputs/logs/slurm_%j.err
#SBATCH --time=24:00:00
#SBATCH --partition=normal
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

# BRMS Model SLURM Job Template
# Usage: sbatch slurm_template.sh <r_script>

# Check if R script is provided
if [ $# -eq 0 ]; then
    echo "Error: No R script provided"
    echo "Usage: sbatch slurm_template.sh <r_script>"
    exit 1
fi

R_SCRIPT=$1
MODEL_NAME=$(basename "$R_SCRIPT" .R)

# Load required modules
module load openmind8/apptainer/1.1.7

# Set up environment
export SINGULARITY_BIND="$PWD:$PWD"
export SINGULARITY_PWD="$PWD"

# Path to your Singularity image
SINGULARITY_IMAGE="/om2/user/thclark/brms_models/brms_240807.sif"

# Check if Singularity image exists
if [ ! -f "$SINGULARITY_IMAGE" ]; then
    echo "Error: Singularity image not found at $SINGULARITY_IMAGE"
    exit 1
fi

# Check if R script exists
if [ ! -f "$R_SCRIPT" ]; then
    echo "Error: R script not found: $R_SCRIPT"
    exit 1
fi

echo "Starting BRMS analysis job"
echo "Job ID: $SLURM_JOB_ID"
echo "Model: $MODEL_NAME"
echo "R Script: $R_SCRIPT"
echo "Timestamp: $(date)"
echo "Working directory: $PWD"

# Create output directories if they don't exist
mkdir -p outputs/fitted_models
mkdir -p outputs/logs

# Run the analysis
echo "Running analysis with Apptainer..."
apptainer exec \
    --bind "$PWD:$PWD" \
    --pwd "$PWD" \
    "$SINGULARITY_IMAGE" \
    Rscript "$R_SCRIPT"

# Check if the job completed successfully
if [ $? -eq 0 ]; then
    echo "Analysis completed successfully"
    echo "Timestamp: $(date)"
else
    echo "Analysis failed with exit code $?"
    echo "Timestamp: $(date)"
    exit 1
fi