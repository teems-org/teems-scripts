library(teems)

model_specs <- teems_model(tab_file = "GTAP-INTv1")

set_specs <- teems_sets(set_har = "~/dat/GTAP/v11c/flexAgg11c17/gsdfset.har",
                        region_mapping = "AR5",
                        sector_mapping = "macro_sector",
                        endowment_mapping = "labor_agg",
                        time_steps = c(rep(1, 3), rep(2, 5), rep(5, 2)),
                        interval_switch = TRUE)

param_specs <- teems_param("~/src/teems/teems-GTAP-INT/GTAP-INTv1/v11/GTAP-INTv1_v11par.qs2",
                           par_har = "~/dat/GTAP/v11c/flexAgg11c17/gsdfpar.har")

base_specs <- teems_base("~/src/teems/teems-GTAP-INT/GTAP-INTv1/v11/GTAP-INTv1_dat.qs2",
                         base_har = "~/dat/GTAP/v11c/flexAgg11c17/gsdfdat.har")

model_name <- "GTAP-INTv1_v11"

base_dir = "~/teems_runs/shocks/uniform/full_var/single"

single_shock <- teems_shock(var = "aoall",
                            type = "uniform",
                            value = 2)

closure_specs <- teems_closure(shock = single_shock)

cmf_path <- teems_deploy(model_config = model_specs,
                         set_config = set_specs,
                         param_config = param_specs,
                         base_config = base_specs,
                         closure_config = closure_specs,
                         model_name = model_name,
                         base_dir = base_dir)

teems_solve(cmf_path = cmf_path,
            n_tasks = 1,
            n_subintervals = 2,
            matrix_method = "LU",
            solution_method = "mod_midpoint")

aoall <- teems_parse(cmf_path = cmf_path,
                     type = "variable",
                     name = "aoall")

aoall