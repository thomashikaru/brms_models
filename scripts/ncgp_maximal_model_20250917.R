library(brms)

dat <- load("/om2/user/thclark/brms_models/data/ncgp_data_20250917.RData")

# Define priors for Bayesian models
priors <- c(
    prior(normal(0, 0.1), class = "b"),
    prior(normal(0, 10.0), class = "Intercept")
)

if (file.exists("fitted_models/ncgp_maximal_model_20250917.RData")) {
    cat("Model already exists.")
} else {
    m <- brm(
        bf(
            total_duration ~ log_freq + word_nchar + surprisal + word_num_in_sent + has_error_posterior + pos_tag + Region * plausibility +
                (log_freq + word_nchar + surprisal + word_num_in_sent + has_error_posterior + pos_tag | submission_id) +
                (log_freq + word_nchar + surprisal + word_num_in_sent + has_error_posterior + pos_tag | Item),
            hu ~ log_freq + word_nchar + surprisal + word_num_in_sent + has_error_posterior + pos_tag
        ),
        data = dat,
        family = hurdle_lognormal(),
        prior = priors,
        cores = 4,
        seed = 123
    )

    save(m, file = "/om2/user/thclark/brms_models/fitted_models/ncgp_maximal_model_20250917.RData")
}
