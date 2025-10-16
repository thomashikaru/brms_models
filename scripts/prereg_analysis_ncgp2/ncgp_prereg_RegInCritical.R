library(brms)

rstan::rstan_options(auto_write = TRUE)

dat <- readRDS("/om2/user/thclark/brms_models/data/ncgp_data_20251015.rds")

# filter data for only rows with Region == "CriticalWord"
dat <- dat[dat$Region == "CriticalWord", ]

# Define priors for Bayesian models
priors <- c(
    prior(normal(0, 0.1), class = "b"),
    prior(normal(0, 1), class = "Intercept")
)

model_name <- "ncgp2_prereg_RegInCritical"

if (file.exists(paste0("/om2/user/thclark/brms_models/outputs/fitted_models/", model_name, ".rds"))) {
    cat("Model already exists.")
} else {
    m <- brm(
        RegIn_excl ~ has_error_posterior + log_freq + word_nchar + surprisal + word_num_in_sent + pos_tag +
            (has_error_posterior + log_freq + word_nchar + surprisal + word_num_in_sent || submission_id) +
            (1 || Item),
        data = dat,
        family = bernoulli(),
        backend = "rstan",
        prior = priors,
        chains = 4,
        cores = 4,
        seed = 123,
        refresh = 1
    )

    saveRDS(m, file = paste0("/om2/user/thclark/brms_models/outputs/fitted_models/", model_name, ".rds"))
}
