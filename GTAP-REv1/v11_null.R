library(teems)

main_dat <- ems_data(dat_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfdat.har",
                     par_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfpar.har",
                     set_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfset.har",
                     tab_file = "GTAP-REv1",
                     time_steps = c(0, 1, 2, 3, 4, 6, 8, 10, 12, 14, 16))

model_specs <- ems_model(
  tab_file = "GTAP-REv1",
  var_omit = c(
    "atall",
    "avaall",
    "tfe",
    "tfd",
    "tfm",
    "tgd",
    "tgm",
    "tid",
    "tim"
  )
)

load_specs <- ems_load(ems_input = main_dat,
                       REG = "AR5",
                       COMM = "macro_sector",
                       ACTS = "macro_sector",
                       ENDW = "labor_agg")

model_name <- "v11_null"

cmf_path <- ems_deploy(model_config = model_specs,
                       load_config = load_specs,
                       model_name = model_name)

ems_solve(cmf_path = cmf_path,
          n_tasks = 1,
          n_subintervals = 1,
          matrix_method = "LU",
          solution_method = "Johansen")

ems_solve(cmf_path = cmf_path,
          n_tasks = 2,
          n_subintervals = 2,
          steps = c(2, 4, 8),
          matrix_method = "SBBD",
          solution_method = "mod_midpoint")

ems_solve(cmf_path = cmf_path,
          n_tasks = 2,
          n_subintervals = 2,
          matrix_method = "NDBBD",
          n_timesteps = 11,
          solution_method = "mod_midpoint")

inputdata <- ems_compose(cmf_path = cmf_path, type = "inputdata")
variables <- ems_compose(cmf_path = cmf_path, type = "variable")
coefficients <- ems_compose(cmf_path = cmf_path, type = "coefficient")
sets <- ems_compose(cmf_path = cmf_path, type = "set")

library(data.table)
invisible(lapply(inputdata$coefficient, function(h) {
  dt <- inputdata$dat[[h]]
  if ("ALLTIMEt" %in% colnames(dt)) {
    y_col <- range(dt$ALLTIMEt)
    dt <- dt[ALLTIMEt %in% y_col]
    dt <- data.table::dcast.data.table(dt[, !("Year"), with = F],
      formula = ... ~ ALLTIMEt,
      value.var = "Value"
    )

    dt[, abs_diff := apply(dt[, as.character(y_col), with = FALSE], 1, diff)]
    dt[, delta := apply(dt[, as.character(y_col), with = FALSE], 1, function(x) {
      if (x[1] != 0 && x[2] != 0) {
        ((x[2] - x[1]) / x[1]) * 100
      } else {
        return(0)
      }
    })]

    diff_range <- range(dt$abs_diff)
    delta_range <- sprintf("%1.3f%%", range(dt$delta, finite = TRUE))
    return(cat("header:", h, "\nabs_diff_range:", diff_range, "\ndelta_range:", delta_range, "\n\n"))
  }
}))
