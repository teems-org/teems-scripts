require(teems)
require(data.table)

model_specs <- teems_model(tab_file = "GTAPv6.2")

set_specs <- teems_sets(set_har = "~/dat/GTAP/v9/2011/gdset.har",
                        region_mapping = "AR5",
                        sector_mapping = "macro_sector",
                        endowment_mapping = "labor_agg")

param_specs <- teems_param(par_har = "~/dat/GTAP/v9/2011/gdpar.har")

base_specs <- teems_base(base_har = "~/dat/GTAP/v9/2011/gddat.har")

model_name <- "GTAP-v6.2_v9"
base_dir <- "~/teems_runs/shocks/custom/dim2"

# partial set (NSAV_COMM)
dim2_shk <- teems_shock(var = "qo",
                        type = "custom",
                        file = "~/src/teems/teems-examples/shock_variations/custom/shocks/qo_NSAV_2d_part.csv")

# full set (ENDW_COMM)
# dim2_shk <- teems_shock(var = "qo",
#                         type = "custom",
#                         file = "~/src/teems/teems-examples/shock_variations/custom/shocks/qo_ENDW_2d_full.csv")

closure_specs <- teems_closure(shock = dim2_shk)

cmf_path <- teems_deploy(model_config = model_specs,
                         set_config = set_specs,
                         param_config = param_specs,
                         base_config = base_specs,
                         closure_config = closure_specs,
                         model_name = model_name,
                         base_dir = base_dir,
                         .testing = F)

teems_solve(cmf_path = cmf_path,
            n_tasks = 1,
            n_subintervals = 1,
            matrix_method = "LU",
            solution_method = "mod_midpoint")

qo <- teems_parse(cmf_path = cmf_path,
                  type = "variable",
                  name = "qo")

qo[NSAV_COMMi %in% c("capital", "labor", "land", "natlres")]
