library(teems)

data <- ems_data(dat_input = "~/dat/GTAP/v9/2011/gddat.har",
                 par_input = "~/dat/GTAP/v9/2011/gdpar.har",
                 set_input = "~/dat/GTAP/v9/2011/gdset.har",
                 REG = "AR5",
                 TRAD_COMM = "macro_sector",
                 ENDW_COMM = "labor_agg")

model <- ems_model(
  tab_file = "GTAPv6.2",
  var_omit = c(
    "atall",
    "tfd",
    "avaall",
    "tf",
    "tfm",
    "tgd",
    "tgm",
    "tpd",
    "tpm"
  )
)

uni_shock <- ems_shock(var = "pop",
                       type = "uniform",
                       value = 1,
                       REGr = "asia")

cmf_path <- ems_deploy(data = data,
                       model = model,
                       shock = uni_shock)

outputs <- ems_solve(cmf_path = cmf_path,
                     n_tasks = 1,
                     n_subintervals = 1,
                     matrix_method = "LU",
                     solution_method = "Johansen")

all(outputs$dat$pop[REGr == "asia"]$Value == 1,
    outputs$dat$pop[REGr != "asia"]$Value == 0)
