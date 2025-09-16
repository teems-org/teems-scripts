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

qfd_shk <- ems_shock(var = "qfd",
                     type = "uniform",
                     value = 1,
                     REGs = "lam",
                     PROD_COMMj = "crops")

yp_shk <- ems_shock(var = "yp",
                    type = "uniform",
                    value = 1)

qfd_in <- ems_swap(var = "qfd",
                   REGs = "lam",
                   PROD_COMMj = "crops")

tfd_out <- ems_swap(var = "tfd",
                    REGr = "lam",
                    PROD_COMMj = "crops")

cmf_path <- ems_deploy(data = data,
                       model = model,
                       swap_in = list(qfd_in, "yp"),
                       swap_out = list(tfd_out, "dppriv"),
                       shock = list(qfd_shk, yp_shk))

outputs <- ems_solve(cmf_path = cmf_path,
                     n_tasks = 1,
                     n_subintervals = 1,
                     matrix_method = "LU",
                     solution_method = "mod_midpoint")

all(outputs$dat$qfd[REGs == "lam" & PROD_COMMj == "crops"]$Value == 1,
    outputs$dat$qfd[REGs != "lam" & PROD_COMMj != "crops"]$Value != 0,
    outputs$dat$tfd[REGr == "lam" & PROD_COMMj == "crops"]$Value != 0,
    outputs$dat$tfd[REGr != "lam" & PROD_COMMj != "crops"]$Value == 0,
    outputs$dat$yp$Value == 1)
