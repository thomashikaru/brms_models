#!/usr/bin/env Rscript

# BRMS Analysis Template
# This is a simple template for running BRMS models
# Users can copy this file and modify it for their specific analysis

library(brms)

# Set up logging
log_file <- paste0("outputs/logs/", Sys.Date(), "_analysis.log")
dir.create("outputs/logs", showWarnings = FALSE, recursive = TRUE)
sink(log_file, append = TRUE, type = "output")
sink(log_file, append = TRUE, type = "message")

cat("Starting BRMS analysis\n")
cat("Timestamp:", as.character(Sys.time()), "\n")

# Load your data
# Replace this with your actual data loading code
cat("Loading data...\n")
# load("data/your_dataset.RData")  # Uncomment and modify as needed
# dat <- your_data_object           # Uncomment and modify as needed

# For this template, we'll create some example data
set.seed(123)
dat <- data.frame(
    y = rnorm(100),
    x = rnorm(100),
    w = rnorm(100),
    participant = rep(1:20, each = 5)
)

# Define your model
# Replace this with your actual model specification
cat("Defining model...\n")
model_name <- "example_model"

# Check if model already exists
model_file <- paste0("outputs/fitted_models/", model_name, ".RData")
dir.create("outputs/fitted_models", showWarnings = FALSE, recursive = TRUE)

if (file.exists(model_file)) {
    cat("Model already exists at:", model_file, "\n")
    cat("Skipping model fitting.\n")
} else {
    cat("Fitting model:", model_name, "\n")

    # Your BRMS model specification
    # Replace this with your actual model
    bfit <- brm(
        y ~ w + x + (w + x | participant),
        data = dat,
        family = gaussian(),
        iter = 4000,
        warmup = 2000,
        chains = 4,
        cores = 4,
        seed = 123
    )

    # Save the fitted model
    cat("Saving model to:", model_file, "\n")
    save(bfit, file = model_file)

    # Save model summary
    summary_file <- paste0("outputs/fitted_models/", model_name, "_summary.txt")
    sink(summary_file)
    print(summary(bfit))
    sink()

    cat("Model summary saved to:", summary_file, "\n")
}

cat("Analysis completed successfully\n")
cat("Timestamp:", as.character(Sys.time()), "\n")

# Close logging
sink(type = "message")
sink(type = "output")
