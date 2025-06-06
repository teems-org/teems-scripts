library(teems)
library(data.table)

model_specs <- teems_model(tab_file = "GTAPv6.2")

set_specs <- teems_sets(set_har = "~/dat/GTAP/v11c/flexAgg11c17/gsdfset.har",
                        region_mapping = "AR5",
                        sector_mapping = "macro_sector",
                        endowment_mapping = "labor_agg")

param_specs <- teems_param(par_har = "~/dat/GTAP/v11c/flexAgg11c17/gsdfpar.har")

base_specs <- teems_base(base_har = "~/dat/GTAP/v11c/flexAgg11c17/gsdfdat.har")

model_name <- "GTAP-v6.2_v11"

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
                         base_dir = "~/teems_runs/shocks/uniform/full_var")

teems_solve(cmf_path = cmf_path,
            n_tasks = 1,
            n_subintervals = 2,
            matrix_method = "LU",
            solution_method = "mod_midpoint")

aoall <- teems_parse(cmf_path = cmf_path,
                     type = "variable",
                     name = "aoall")

aoall