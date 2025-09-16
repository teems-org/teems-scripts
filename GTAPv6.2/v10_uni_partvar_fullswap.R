library(teems)

data <- ems_data(dat_input = "~/dat/GTAP/v10A/flexagg10AY14/gsddat.har",
                 par_input = "~/dat/GTAP/v10A/flexagg10AY14/gsdpar.har",
                 set_input = "~/dat/GTAP/v10A/flexagg10AY14/gsdset.har",
                 REG = "AR5",
                 TRAD_COMM = "macro_sector",
                 ENDW_COMM = "labor_agg")

model <- ems_model(
  tab_file = "GTAPv6.2"
)

uni_shock <- ems_shock(var = "qfd",
                       type = "uniform",
                       value = -3,
                       REGs = "lam",
                       PROD_COMMj = "crops")

cmf_path <- ems_deploy(data = data,
                       model = model,
                       swap_in = "qfd",
                       swap_out = "tfd",
                       shock = uni_shock)

outputs <- ems_solve(cmf_path = cmf_path,
                     n_tasks = 1,
                     n_subintervals = 1,
                     matrix_method = "LU",
                     solution_method = "Johansen")

all(outputs$dat$qfd[REGs == "lam" & PROD_COMMj == "crops"]$Value == -3,
    outputs$dat$qfd[REGs != "lam" & PROD_COMMj != "crops"]$Value == 0)
