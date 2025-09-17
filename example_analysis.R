library(brms)

load("/om2/user/thclark/brms_models/data/dataset_name.RData")

if (file.exists("fitted_models/model_name.RData")) {
  cat("Model already exists.")
} else {
  bfit_multivariate <- brm(
    bf(
      mvbind(duration, max_F0, max_intensity) ~ corrected * dominant + gender +
        (corrected * dominant|participant) + (corrected * dominant|word)
    ) + 
      set_rescor(TRUE),
    data = dat,
    family = gaussian(),
    iter = 4000,
    warmup = 2000,
    chains = 4,
    cores = 4,
    seed = 123
  )
  
  save(bfit_multivariate, file="/om2/user/thclark/brms_models/fitted_models/model_name.RData")
}
