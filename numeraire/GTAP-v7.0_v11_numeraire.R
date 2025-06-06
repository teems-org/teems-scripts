library(teems)
library(data.table)

model_specs <- teems_model(tab_file = "GTAPv7.0")

set_specs <- teems_sets(set_har = "~/dat/GTAP/v11a/flexAgg11a17/gsdfset.har",
                        region_mapping = "AR5",
                        sector_mapping = "macro_sector",
                        endowment_mapping = "labor_agg")

param_specs <- teems_param(par_har = "~/dat/GTAP/v11a/flexAgg11a17/gsdfpar.har")

base_specs <- teems_base(base_har = "~/dat/GTAP/v11a/flexAgg11a17/gsdfdat.har")

model_name <- "GTAP-v7.0_v11"

numeraire <- teems_shock(var = "pfactwld",
                         type = "uniform",
                         value = 5)

closure_specs <- teems_closure(shock = numeraire)

cmf_path <- teems_deploy(model_config = model_specs,
                         set_config = set_specs,
                         param_config = param_specs,
                         base_config = base_specs,
                         closure_config = closure_specs,
                         model_name = model_name,
                         base_dir = "~/teems_runs/numeraire")

teems_solve(cmf_path = cmf_path,
            n_tasks = 1,
            n_subintervals = 1,
            matrix_method = "LU",
            solution_method = "Johansen")

outputs <- teems_parse(cmf_path = cmf_path, type = "basedata")

invisible(lapply(outputs[["name"]], function(h) {
  dt <- outputs[["dat"]][[h]]
  y_col <- unique(dt$Year)
  dt <- data.table::dcast.data.table(dt,
                                     formula = ... ~ Year,
                                     value.var = "Value")
  
  dt[, abs_diff := apply(dt[, y_col, with = FALSE], 1, diff)]
  dt[, delta := apply(dt[, y_col, with = FALSE], 1, function(x) {((x[2] - x[1]) / x[1]) * 100})]
  
  diff_range <- range(dt$abs_diff)
  delta_range <- sprintf("%1.2f%%", range(dt$delta, finite = TRUE))
  return(cat("header:", h, "\nabs_diff_range:", diff_range, "\ndelta_range:", delta_range, "\n\n"))
}))

