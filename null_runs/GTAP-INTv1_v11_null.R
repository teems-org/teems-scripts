library(teems)

model_specs <- teems_model(tab_file = "GTAP-INTv1",
                           var_omit = c("atall", "tfd", "avaall", "tf", "tfm",
                                        "tgd", "tgm", "tpd", "tpm"))

main_dat <- GTAP_convert("~/dat/GTAP/v11c/flexAgg11c17/gsdfdat.har",
                         "~/dat/GTAP/v11c/flexAgg11c17/gsdfpar.har",
                         "~/dat/GTAP/v11c/flexAgg11c17/gsdfset.har",
                         tab_file = "GTAPv7.0",
                         target_format = "v6.2")

gtap_int <- teems_time(tab_file = "GTAP-INTv1",
                       set_input = main_dat$set,
                       time_steps = c(0, 1, 2, 3, 4, 6, 8, 10, 12, 14, 16),
                       time_format = "diff",
                       LRORG = 0.5,
                       INIDELTA = 0,
                       KAPPA = 0.5,
                       CPHI = 0.1)

data_specs <- teems_data(dat_input = main_dat$dat,
                         par_input = main_dat$par,
                         aux_input = gtap_int)

set_specs <- teems_sets(set_input = main_dat$set,
                        REG = "AR5",
                        TRAD_COMM = "macro_sector",
                        ENDW_COMM = "labor_agg")

model_name <- "GTAP-INTv1_v11"

cmf_path <- teems_deploy(model_config = model_specs,
                         set_config = set_specs,
                         data_config = data_specs,
                         model_name = model_name,
                         base_dir = "~/teems_runs/null")

teems_solve(cmf_path = cmf_path,
            n_tasks = 1,
            n_subintervals = 1,
            matrix_method = "LU",
            solution_method = "Johansen")

teems_solve(cmf_path = cmf_path,
            n_tasks = 2,
            n_subintervals = 2,
            matrix_method = "SBBD",
            solution_method = "mod_midpoint")

teems_solve(cmf_path = cmf_path,
            n_tasks = 2,
            n_subintervals = 2,
            matrix_method = "NDBBD",
            n_timesteps = 11,
            solution_method = "mod_midpoint")

inputdata <- teems_compose(cmf_path = cmf_path, type = "inputdata")
variables <- teems_compose(cmf_path = cmf_path, type = "variable")
coefficients <- teems_compose(cmf_path = cmf_path, type = "coefficient")
sets <- teems_compose(cmf_path = cmf_path, type = "set")

invisible(lapply(inputdata[["coefficient"]], function(h) {
  dt <- inputdata[["dat"]][[h]]
  if (is.element(el = "ALLTIMEt", set = colnames(dt))) {
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
