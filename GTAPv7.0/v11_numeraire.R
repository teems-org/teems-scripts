library(teems)

data <- ems_data(dat_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfdat.har",
                 par_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfpar.har",
                 set_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfset.har",
                 REG = "big3",
                 COMM = "macro_sector",
                 ACTS = "macro_sector",
                 ENDW = "labor_agg")

model <- ems_model(
  tab_file = "GTAPv7.0",
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
               "tim")
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
                     matrix_method = "LU",
                     solution_method = "Johansen")

ems_solve(cmf_path = cmf_path,
          n_tasks = 2,
          n_subintervals = 2,
          steps = c(2, 4, 8),
          matrix_method = "DBBD",
          solution_method = "mod_midpoint",
          suppress_outputs = TRUE)

ems_check(check = "baseline",
          outputs = outputs,
          data = data,
          model = model,
          max_tolerance = 5)
