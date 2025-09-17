library(brms)

dat <- readRDS("/om2/user/thclark/brms_models/data/ncgp_data_20250917.rds")

# Define priors for Bayesian models
priors <- c(
    prior(normal(0, 1), class = "b"),
    prior(normal(0, 1), class = "b", dpar = "hu"),
    prior(normal(0, 1), class = "Intercept"),
    prior(exponential(1), class = "sd")
)

if (file.exists("fitted_models/ncgp_maximal_model_20250917.RData")) {
    cat("Model already exists.")
} else {
    m <- brm(
        bf(
            total_duration ~ log_freq + word_nchar + surprisal + word_num_in_sent + has_error_posterior + pos_tag + Region * plausibility +
                (log_freq + word_nchar + surprisal + word_num_in_sent + has_error_posterior || submission_id) +
                (1 || Item),
            hu ~ log_freq + word_nchar + surprisal + word_num_in_sent + has_error_posterior + pos_tag
        ),
        data = dat,
        family = hurdle_lognormal(),
        prior = priors,
        backend = "cmdstanr",
        threads = threading(4),
        chains = 4,
        cores = 4,
        seed = 123,
        center = TRUE,
        scale = TRUE,
        control = list(adapt_delta = 0.85, max_treedepth = 10),
        refresh = 1
    )

    save(m, file = "/om2/user/thclark/brms_models/fitted_models/ncgp_maximal_model_20250917.RData")
}
