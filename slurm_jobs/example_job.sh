#!/bin/bash
#SBATCH --job-name=multivariate_example
#SBATCH --output=outputs/logs/slurm_%j.out
#SBATCH --error=outputs/logs/slurm_%j.err
#SBATCH --time=24:00:00
#SBATCH --partition=normal
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

# Example BRMS Model SLURM Job
# This job runs the example analysis script

# Load required modules
source /etc/profile.d/modules.sh
module load openmind8/apptainer/1.1.7

# Set up environment
export SINGULARITY_BIND="$PWD:$PWD"
export SINGULARITY_PWD="$PWD"

# Path to your Singularity image
SINGULARITY_IMAGE="/om2/user/thclark/brms_models/brms_240807.sif"

# R script to run
R_SCRIPT="scripts/analysis_template.R"

echo "Starting BRMS analysis job"
echo "Job ID: $SLURM_JOB_ID"
echo "Model: example_analysis"
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