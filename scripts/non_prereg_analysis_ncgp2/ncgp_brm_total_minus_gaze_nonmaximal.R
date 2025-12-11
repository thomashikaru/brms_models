library(brms)

rstan::rstan_options(auto_write = TRUE)

dat <- readRDS("/orcd/data/rplevy/001/om2/thclark/brms_models/data/ncgp2_data_20251110.rds")

# Standardize continuous predictors for better prior specification
# This allows us to use the same prior scale for all coefficients
# while maintaining interpretability through back-transformation
# Note: word_num_in_sent is left unstandardized as it's a position variable
# with meaningful scale (integer positions)
continuous_vars <- c("log_freq", "word_nchar", "surprisal_nc")
standardization_info <- list()

for (var in continuous_vars) {
    if (var %in% names(dat)) {
        mean_val <- mean(dat[[var]], na.rm = TRUE)
        sd_val <- sd(dat[[var]], na.rm = TRUE)
        dat[[paste0(var, "_z")]] <- (dat[[var]] - mean_val) / sd_val
        standardization_info[[var]] <- list(mean = mean_val, sd = sd_val)
    }
}

# Save standardization info for back-transforming effects later
saveRDS(standardization_info,
    file = paste0(
        "/orcd/data/rplevy/001/om2/thclark/brms_models/outputs/fitted_models/",
        "ncgp_total_minus_gaze_maximal_standardization_info.rds"
    )
)

# Define priors for Bayesian models
# Using normal(0, 1) for standardized predictors - weakly informative
# This prior is appropriate when predictors are on similar scales (after standardization)
# word_num_in_sent uses a separate prior on original scale
# Intercept prior: For hurdle_lognormal(), intercept is on log scale
# With RT values 0-1000ms, typical values (200-800ms) have log values ~5.3-6.7
# Using normal(6, 1) centers the prior around typical log RT values
priors <- c(
    prior(normal(0, 1), class = "b"),
    prior(normal(0, 1), class = "b", dpar = "hu"),
    prior(normal(6, 1), class = "Intercept"), # Log-scale intercept for typical RT values
    prior(normal(0, 1), class = "b", coef = "word_num_in_sent"),
    prior(normal(0, 1), class = "b", coef = "word_num_in_sent", dpar = "hu")
)

model_name <- "ncgp_total_minus_gaze_nonmaximal"

if (file.exists(paste0("/orcd/data/rplevy/001/om2/thclark/brms_models/outputs/fitted_models/", model_name, ".rds"))) {
    cat("Model already exists.")
} else {
    m <- brm(
        bf(
            rt_total_minus_gaze ~ log_freq_z + word_nchar_z + surprisal_nc_z + word_num_in_sent + pos_tag + Region * cond_id +
                (Region * cond_id || submission_id) +
                (Region * cond_id || Item),
            hu ~ log_freq_z + word_nchar_z + surprisal_nc_z + word_num_in_sent + pos_tag + Region * cond_id +
                (Region * cond_id || submission_id) +
                (Region * cond_id || Item)
        ),
        data = dat,
        family = hurdle_lognormal(),
        backend = "rstan",
        prior = priors,
        chains = 4,
        cores = 4,
        seed = 123,
        refresh = 1
    )

    saveRDS(m, file = paste0("/orcd/data/rplevy/001/om2/thclark/brms_models/outputs/fitted_models/", model_name, ".rds"))
}

# NOTE: To interpret effects in original units (not standardized):
# 1. Load the standardization info:
#    std_info <- readRDS("outputs/fitted_models/ncgp_total_minus_gaze_maximal_standardization_info.rds")
# 2. For a coefficient on standardized predictor X_z, the effect in original units is:
#    effect_original = coefficient * std_info$X$sd
#    This gives the change in rt_total_minus_gaze per 1-unit increase in X (original scale)
# 3. Alternatively, use posterior_epred() or conditional_effects() with data on original scale
#    to generate predictions and visualize effects in interpretable units
