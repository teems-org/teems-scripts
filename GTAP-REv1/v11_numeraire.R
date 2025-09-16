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

numeraire <- ems_shock(var = "pfactwld",
                       type = "uniform",
                       value = 5)

cmf_path <- ems_deploy(data = data,
                       model = model,
                       shock = numeraire)

outputs <- ems_solve(cmf_path = cmf_path,
                     n_tasks = 1,
                     n_subintervals = 1,
                     matrix_method = "SBBD",
                     solution_method = "mod_midpoint")

ems_solve(cmf_path = cmf_path,
          n_tasks = 1,
          n_subintervals = 1,
          matrix_method = "LU",
          solution_method = "Johansen",
          suppress_outputs = TRUE)

ems_solve(cmf_path = cmf_path,
          n_tasks = 1,
          n_subintervals = 1,
          steps = c(2, 4, 8),
          matrix_method = "SBBD",
          solution_method = "mod_midpoint",
          suppress_outputs = TRUE)

ems_solve(cmf_path = cmf_path,
          n_tasks = 1,
          n_subintervals = 1,
          matrix_method = "NDBBD",
          n_timesteps = 11,
          solution_method = "mod_midpoint",
          suppress_outputs = TRUE)

all(outputs$dat$pfactwld$Value == 5)
