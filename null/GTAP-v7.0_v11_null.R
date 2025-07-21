require(teems)
require(data.table)

model_specs <- teems_model(tab_file = "GTAPv7.0",
                           var_omit = c("atall",
                                        "avaall",
                                        "tfe",
                                        "tfd",
                                        "tfm",
                                        "tgd",
                                        "tgm",
                                        "tpdall",
                                        "tpmall",
                                        "tid",
                                        "tim"))

set_specs <- teems_sets(REG = "AR5",
                        COMM = "macro_sector",
                        ACTS = "macro_sector",
                        ENDW = "labor_agg",
                        set_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfset.har")

data_specs <- teems_data(dat_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfdat.har",
                         par_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfpar.har")

model_name <- "GTAP-v7.0_v11"

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
            matrix_method = "DBBD",
            solution_method = "mod_midpoint")

inputdata <- teems_compose(cmf_path = cmf_path, type = "inputdata")
variables <- teems_compose(cmf_path = cmf_path, type = "variable")
coefficients <- teems_compose(cmf_path = cmf_path, type = "coefficient")
sets <- teems_compose(cmf_path = cmf_path, type = "set")

invisible(lapply(inputdata[["coefficient"]], function(h) {
  dt <- inputdata[["dat"]][[h]]
  y_col <- unique(dt$Year)
  dt <- data.table::dcast.data.table(dt,
                                     formula = ... ~ Year,
                                     value.var = "Value")
  
  dt[, abs_diff := apply(dt[, y_col, with = FALSE], 1, diff)]
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
}))
