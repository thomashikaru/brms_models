library(brms)

rstan::rstan_options(auto_write = TRUE)

dat <- readRDS("/om2/user/thclark/brms_models/data/ncgp2_data_20251110.rds")

# Define priors for Bayesian models
priors <- c(
    prior(normal(0, 0.1), class = "b"),
    prior(normal(0, 0.1), class = "b", dpar = "hu"),
    prior(normal(0, 1), class = "Intercept")
)

model_name <- "ncgp2_prereg_total_minus_gaze"

if (file.exists(paste0("/om2/user/thclark/brms_models/outputs/fitted_models/", model_name, ".rds"))) {
    cat("Model already exists.")
} else {
    m <- brm(
        bf(
            rt_total_minus_gaze ~ log_freq + word_nchar + surprisal_nc + word_num_in_sent + pos_tag + Region * cond_id +
                (log_freq + word_nchar + surprisal_nc + word_num_in_sent || submission_id) +
                (1 || Item),
            hu ~ log_freq + word_nchar + surprisal_nc + word_num_in_sent + pos_tag
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

    saveRDS(m, file = paste0("/om2/user/thclark/brms_models/outputs/fitted_models/", model_name, ".rds"))
}
