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

qfd_shk <- ems_shock(
  var = "qfd",
  type = "uniform",
  REGr = "lam",
  ACTSa = "crops",
  value = 0.1
)

yp_in <- ems_swap(var = "yp")
dppriv_out <- ems_swap(var = "dppriv")

yp_shk <- ems_shock(
  var = "yp",
  type = "uniform",
  value = 0.1
)

cmf_path <- ems_deploy(
  data = data,
  model = model,
  shock = list(qfd_shk, yp_shk),
  swap_in = list("qfd", yp_in),
  swap_out = list("tfd", dppriv_out)
)

outputs <- ems_solve(
  cmf_path = cmf_path,
  n_tasks = 1,
  n_subintervals = 2,
  matrix_method = "DBBD",
  solution_method = "mod_midpoint"
)

all(
  outputs$dat$qfd[REGr == "lam" & ACTSa == "crops"]$Value == 0.1,
  outputs$dat$qfd[REGr != "lam" & ACTSa != "crops"]$Value == 0,
  outputs$dat$tfd$Value != 0,
  outputs$dat$dppriv$Value != 0,
  outputs$dat$yp$Value == 0.1
)

