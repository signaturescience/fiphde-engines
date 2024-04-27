################################################################################
library(dplyr)
library(purrr)
library(readr)
library(ggplot2)
library(fiphde)

submission_dir <- "/submission/"

## retrieval hospitalization data
## NOTE: need fiphde >= v2.0.0 to use shift_back argument
hosp <- get_hdgov_hosp(limitcols = TRUE, shift_back = FALSE)

options(nwarnings = 10000)

fhorizons <- as.numeric(Sys.getenv("run_params_horizons"))

################################################################################
## SigSci-TSENS

## prep and make a tsibble
## NOTE: uses hosp from above
prepped_hosp <-
  hosp %>%
  prep_hdgov_hosp(statesonly=TRUE, min_per_week = 0, remove_incomplete = FALSE) %>%
  dplyr::filter(abbreviation != "DC")

prepped_hosp_tsibble <- make_tsibble(prepped_hosp,
                                     epiyear = epiyear,
                                     epiweek=epiweek,
                                     key=location)
## fit the model and forecast
hosp_fitfor <- ts_fit_forecast(prepped_hosp_tsibble,
                               # horizon=5L,
                               horizon=fhorizons,
                               outcome="flu.admits",
                               covariates=TRUE)


## format for submission
shift_for_horizons <- fhorizons-3

formatted_list <- format_for_submission(hosp_fitfor$tsfor, method = "ts", format = "hubverse", horizon_shift = shift_for_horizons)

## ARIMA

pdf(paste0(submission_dir, "SigSci-TSENS/artifacts/plots/", this_saturday(), "-SigSci-TSENS-ARIMA.pdf"), width=11.5, height=8)
for(loc in unique(formatted_list$arima$location)) {
  p <- plot_forecast(prepped_hosp, formatted_list$arima, location = loc, format = "hubverse")
  print(p)
}
dev.off()

## ETS

pdf(paste0(submission_dir, "SigSci-TSENS/artifacts/plots/", this_saturday(), "-SigSci-TSENS-ETS.pdf"), width=11.5, height=8)
for(loc in unique(formatted_list$ets$location)) {
  p <- plot_forecast(prepped_hosp, formatted_list$ets, location = loc, format = "hubverse")
  print(p)
}
dev.off()

## ensemble

pdf(paste0(submission_dir, "SigSci-TSENS/artifacts/plots/", this_saturday(), "-SigSci-TSENS-ensemble.pdf"), width=11.5, height=8)
for(loc in unique(formatted_list$ensemble$location)) {
  p <- plot_forecast(prepped_hosp, formatted_list$ensemble, location = loc, format = "hubverse")
  print(p)
}
dev.off()

################################################################################
## save model formulas / arima params / objects for posterity

hosp_arima_params <-
  map(hosp_fitfor$tsfit$arima, "fit") %>%
  map_df("spec") %>%
  mutate(location = hosp_fitfor$tsfit$location, .before = "p") %>%
  mutate(forecast_date = this_saturday())

hosp_ets_formula <- hosp_fitfor$formulas$ets

## save tsens component forecasts
hosp_ets_forc <- formatted_list$ets
hosp_arima_forc <- formatted_list$arima

## save locations/models which were null
hosp_tsens_null_models <- hosp_fitfor$nullmodels

save(hosp_arima_params, hosp_ets_formula, hosp_ets_forc, hosp_arima_forc, hosp_tsens_null_models, file = paste0(submission_dir, "SigSci-TSENS/artifacts/params/", this_saturday(), "-SigSci-TSENS-model-info.rda"))


################################################################################
## categorical forecast prep
tsens_quant_prepped <- formatted_list$ensemble

tsens_cat_prepped <- forecast_categorical(tsens_quant_prepped, prepped_hosp, method = "density", format = "hubverse", horizon = fhorizons)

## combine prepped quant and categorical forecasts
tsens <- bind_rows(tsens_cat_prepped, tsens_quant_prepped)
tsens_cat_plot <- plot_forecast_categorical(tsens)
ggsave(tsens_cat_plot, filename = paste0(submission_dir, "/SigSci-TSENS/artifacts/plots/", this_saturday(), "-tsens-cat-plot.pdf"), width=12, height=15)

################################################################################
## write out the forecast file
write_csv(tsens, paste0(submission_dir, "SigSci-TSENS/", this_saturday(), "-SigSci-TSENS.candidate.csv"))

