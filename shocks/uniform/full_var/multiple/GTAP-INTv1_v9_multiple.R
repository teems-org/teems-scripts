require(teems)
require(data.table)

model_specs <- teems_model(tab_file = "GTAP-INTv1")

set_specs <- teems_sets(set_har = "~/dat/GTAP/v9/2011/gdset.har",
                        region_mapping = "big3",
                        sector_mapping = "macro_sector",
                        endowment_mapping = "labor_agg",
                        time_steps = c(rep(1, 4), rep(2,6)),
                        interval_switch = TRUE)

param_specs <- teems_param("~/src/teems/teems-GTAP-INT/GTAP-INTv1/v9/GTAP-INTv1_v9par.qs2",
                           par_har = "~/dat/GTAP/v9/2011/gdpar.har")

base_specs <- teems_base("~/src/teems/teems-GTAP-INT/GTAP-INTv1/v9/GTAP-INTv1_dat.qs2",
                         base_har = "~/dat/GTAP/v9/2011/gddat.har")

model_name <- "GTAP-INTv1_v9"

shock_one <- teems_shock(var = "tfd",
                         type = "uniform",
                         value = 1.5)

shock_two <- teems_shock(var = "txs",
                         type = "uniform",
                         value = 1.5)

closure_specs <- teems_closure(shock = list(shock_one, shock_two))

cmf_path <- teems_deploy(model_config = model_specs,
                         set_config = set_specs,
                         param_config = param_specs,
                         base_config = base_specs,
                         closure_config = closure_specs,
                         model_name = model_name,
                         base_dir = "~/teems_runs/shocks/uniform/full_var/multiple")

teems_solve(cmf_path = cmf_path,
            n_tasks = 1,
            n_subintervals = 2,
            matrix_method = "LU",
            solution_method = "mod_midpoint")

tfd_txs <- teems_parse(cmf_path = cmf_path,
                       type = "variable",
                       name = c("tfd", "txs"))

tfd_txs[["dat"]]