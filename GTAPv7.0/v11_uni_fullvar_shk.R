library(teems)

data <- ems_data(
  dat_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfdat.har",
  par_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfpar.har",
  set_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfset.har",
  REG = "AR5",
  COMM = "macro_sector",
  ACTS = "macro_sector",
  ENDW = "labor_agg"
)

model <- ems_model(
  tab_file = "GTAPv7.0"
)

pop_shk <- ems_shock(var = "pop",
                     type = "uniform",
                     value = 1)

cmf_path <- ems_deploy(data = data,
                       model = model,
                       shock = pop_shk)

outputs <- ems_solve(cmf_path = cmf_path,
                     n_tasks = 1,
                     n_subintervals = 1,
                     matrix_method = "LU",
                     solution_method = "mod_midpoint")

all(outputs$dat$pop$Value == 1)
