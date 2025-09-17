# BRMS Models on Remote Cluster

A simple, reproducible system for running Bayesian Regression Models using Stan (BRMS) on a remote cluster using Singularity images and SLURM.

## Overview

This system provides a straightforward approach to:
- Write R scripts for your BRMS models
- Run models using Singularity containers
- Submit jobs to SLURM for cluster computing
- Manage multiple model analyses efficiently

## Directory Structure

```
brms_models/
├── scripts/                    # R analysis scripts and helper tools
│   ├── analysis_template.R     # Example R script (optional reference)
│   ├── submit_job.sh          # Submit jobs to SLURM
│   └── check_jobs.sh          # Check job status
├── slurm_jobs/                # Generated SLURM job scripts
├── outputs/                   # Analysis outputs
│   ├── fitted_models/         # Saved BRMS model objects
│   └── logs/                  # Analysis and SLURM logs
├── data/                      # Data files (place your .RData files here)
└── README.md                  # This file
```

## Quick Start

### 1. Create Your R Script

Create your own R script (e.g., `scripts/my_analysis.R`) with your BRMS model:

```r
#!/usr/bin/env Rscript

library(brms)

# Load your data
load("data/your_dataset.RData")
dat <- your_data_object

# Define your model
model_name <- "my_analysis"

# Your BRMS model specification
bfit <- brm(
  y ~ x + (1|group),           # Your formula
  data = dat,
  family = gaussian(),         # Your family
  iter = 4000,
  warmup = 2000,
  chains = 4,
  cores = 4,
  seed = 123
)

# Save the fitted model
save(bfit, file = paste0("outputs/fitted_models/", model_name, ".RData"))
```

### 2. Submit the Job

```bash
# Submit with default settings
./scripts/submit_job.sh scripts/my_analysis.R

# Submit with custom resources
./scripts/submit_job.sh scripts/my_analysis.R my_analysis 48:00:00 32G 8
```

### 4. Monitor Jobs

```bash
# Check job status
./scripts/check_jobs.sh

# Check specific job
squeue -j <job_id>
```

## R Script Template

The `scripts/analysis_template.R` provides a starting point for your analyses:

```r
#!/usr/bin/env Rscript

library(brms)

# Set up logging
log_file <- paste0("outputs/logs/", Sys.Date(), "_analysis.log")
dir.create("outputs/logs", showWarnings = FALSE, recursive = TRUE)
sink(log_file, append = TRUE, type = "output")
sink(log_file, append = TRUE, type = "message")

# Load your data
load("data/your_dataset.RData")
dat <- your_data_object

# Define your model
model_name <- "your_model_name"

# Your BRMS model specification
bfit <- brm(
  y ~ x + (1|group),           # Your formula
  data = dat,
  family = gaussian(),         # Your family
  iter = 4000,
  warmup = 2000,
  chains = 4,
  cores = 4,
  seed = 123
)

# Save the fitted model
save(bfit, file = paste0("outputs/fitted_models/", model_name, ".RData"))
```

## Complex Models

The system supports any BRMS model type, including complex models like hurdle-lognormal:

```r
# Hurdle-lognormal model
bfit <- brm(
  bf(y ~ x + (1|item), hu ~ z + (1|item)),
  data = dat,
  family = hurdle_lognormal(),
  iter = 4000,
  warmup = 2000,
  chains = 4,
  cores = 4,
  seed = 123
)
```

## Helper Scripts

### `submit_job.sh`
Submits a BRMS analysis job to SLURM.

**Usage:**
```bash
./scripts/submit_job.sh <r_script> [job_name] [time_limit] [memory] [cpus]
```

**Examples:**
```bash
# Basic usage
./scripts/submit_job.sh scripts/my_analysis.R

# With custom resources
./scripts/submit_job.sh scripts/my_analysis.R my_analysis 48:00:00 32G 8
```

### `check_jobs.sh`
Checks the status of your BRMS model jobs.

**Usage:**
```bash
./scripts/check_jobs.sh [user]
```

## SLURM Integration

The system automatically generates SLURM job scripts with appropriate resource allocation:

- **Default resources:** 4 CPUs, 16GB RAM, 24 hours
- **Customizable:** Time, memory, and CPU requirements
- **Logging:** Automatic log file generation
- **Error handling:** Proper exit codes and error reporting

## Output Files

### Fitted Models
- Location: `outputs/fitted_models/`
- Format: `.RData` files containing BRMS model objects
- Naming: `{model_name}.RData`

### Model Summaries
- Location: `outputs/fitted_models/`
- Format: Text files with model summaries
- Naming: `{model_name}_summary.txt`

### Log Files
- Location: `outputs/logs/`
- Format: Text files with analysis logs
- Naming: `{date}_analysis.log`

### SLURM Logs
- Location: `outputs/logs/`
- Format: SLURM output and error files
- Naming: `slurm_{job_id}.out` and `slurm_{job_id}.err`

## Requirements

### Software
- R with `brms` package
- Singularity container with R and required packages
- SLURM job scheduler

### File Paths
Update the following paths in the scripts for your environment:
- Singularity image path in `scripts/submit_job.sh`

## Example Workflow

1. **Prepare your data:**
   ```bash
   # Place your .RData file in the data/ directory
   cp /path/to/your/data.RData data/my_dataset.RData
   ```

2. **Create your R script:**
   ```bash
   # Create your analysis script
   nano scripts/my_analysis.R
   # Write your BRMS model code
   ```

3. **Submit job:**
   ```bash
   ./scripts/submit_job.sh scripts/my_analysis.R
   ```

5. **Monitor progress:**
   ```bash
   ./scripts/check_jobs.sh
   ```

6. **Check results:**
   ```bash
   ls outputs/fitted_models/
   ls outputs/logs/
   ```

## Troubleshooting

### Common Issues

1. **Singularity image not found:**
   - Update the `SINGULARITY_IMAGE` path in `scripts/submit_job.sh`

2. **Data file not found:**
   - Check the data loading code in your R script
   - Ensure the path is accessible from the cluster

3. **Job fails with memory error:**
   - Increase memory allocation: `./scripts/submit_job.sh scripts/my_analysis.R my_job 24:00:00 32G 4`

4. **Job times out:**
   - Increase time limit: `./scripts/submit_job.sh scripts/my_analysis.R my_job 48:00:00 16G 4`

### Getting Help

- Check SLURM logs: `cat outputs/logs/slurm_*.err`
- Check analysis logs: `cat outputs/logs/*.log`
- Use `squeue` to check job status
- Use `scancel <job_id>` to cancel jobs

## Contributing

To add new features or improve the system:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is open source. Please check with your institution for any specific licensing requirements.