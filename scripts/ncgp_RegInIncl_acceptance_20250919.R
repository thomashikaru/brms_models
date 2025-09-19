library(brms)

rstan::rstan_options(auto_write = TRUE)

dat <- readRDS("/om2/user/thclark/brms_models/data/ncgp_data_20250917.rds")

# Define priors for Bayesian models
priors <- c(
    prior(normal(0, 0.1), class = "b"),
    prior(normal(0, 1), class = "Intercept")
)

if (file.exists("/om2/user/thclark/brms_models/outputs/fitted_models/ncgp_RegInIncl_acceptance_20250919.rds")) {
    cat("Model already exists.")
} else {
    m <- brm(
        RegIn_incl ~ log_freq + word_nchar + surprisal + word_num_in_sent + accepted + pos_tag + Region * plausibility +
            (log_freq + word_nchar + surprisal + word_num_in_sent + accepted || submission_id) +
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

    saveRDS(m, file = "/om2/user/thclark/brms_models/outputs/fitted_models/ncgp_RegInIncl_acceptance_20250919.rds")
}
