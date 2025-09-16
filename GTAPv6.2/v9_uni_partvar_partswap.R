library(teems)

data <- ems_data(dat_input = "~/dat/GTAP/v9/2011/gddat.har",
                 par_input = "~/dat/GTAP/v9/2011/gdpar.har",
                 set_input = "~/dat/GTAP/v9/2011/gdset.har",
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

qfd_in <- ems_swap(var = "qfd",
                   REGs = "lam",
                   PROD_COMMj = "crops")

tfd_out <- ems_swap(var = "tfd",
                    REGr = "lam",
                    PROD_COMMj = "crops")

cmf_path <- ems_deploy(data = data,
                       model = model,
                       swap_in = qfd_in,
                       swap_out = tfd_out,
                       shock = uni_shock)

outputs <- ems_solve(cmf_path = cmf_path,
                     n_tasks = 1,
                     n_subintervals = 1,
                     matrix_method = "LU",
                     solution_method = "mod_midpoint")

all(outputs$dat$qfd[REGs == "lam" & PROD_COMMj == "crops"]$Value == -3,
    outputs$dat$qfd[REGs != "lam" & PROD_COMMj != "crops"]$Value != 0,
    outputs$dat$tfd[REGr == "lam" & PROD_COMMj == "crops"]$Value != 0,
    outputs$dat$tfd[REGr != "lam" & PROD_COMMj != "crops"]$Value == 0)
