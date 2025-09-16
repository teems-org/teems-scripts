library(teems)

data <- ems_data(dat_input = "~/dat/GTAP/v10A/flexagg10AY14/gsddat.har",
                 par_input = "~/dat/GTAP/v10A/flexagg10AY14/gsdpar.har",
                 set_input = "~/dat/GTAP/v10A/flexagg10AY14/gsdset.har",
                 REG = "AR5",
                 TRAD_COMM = "macro_sector",
                 ENDW_COMM = "labor_agg",
                 time_steps = c(0, 1, 2, 3, 4, 6, 8, 10, 12, 14, 16))

model <- ems_model(
  tab_file = "GTAP-INTv1"
)

uni_shock <- ems_shock(var = "pop",
                       type = "uniform",
                       value = 1,
                       REGr = "asia",
                       Year = 2020)

cmf_path <- ems_deploy(data = data,
                       model = model,
                       shock = uni_shock)

outputs <- ems_solve(cmf_path = cmf_path,
                     n_tasks = 1,
                     n_subintervals = 1,
                     matrix_method = "SBBD",
                     solution_method = "mod_midpoint")

all(outputs$dat$pop[REGr == "asia" & Year == 2020]$Value == 1,
    outputs$dat$pop[REGr == "asia" & Year != 2020]$Value == 0,
    outputs$dat$pop[REGr != "asia"]$Value == 0)
