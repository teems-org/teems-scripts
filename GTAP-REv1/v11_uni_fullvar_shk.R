library(teems)

data <- ems_data(dat_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfdat.har",
                 par_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfpar.har",
                 set_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfset.har",
                 REG = "AR5",
                 COMM = "macro_sector",
                 ACTS = "macro_sector",
                 ENDW = "labor_agg",
                 time_steps = c(0, 1, 2, 3, 4, 6, 8, 10, 12, 14, 16))

model <- ems_model(
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

pop_shk <- ems_shock(var = "pop",
                     type = "uniform",
                     value = 1)

cmf_path <- ems_deploy(data = data,
                       model = model,
                       shock = pop_shk)

outputs <- ems_solve(cmf_path = cmf_path,
                     n_tasks = 1,
                     n_subintervals = 1,
                     matrix_method = "SBBD",
                     solution_method = "mod_midpoint")

all(outputs$dat$pop$Value == 1)
