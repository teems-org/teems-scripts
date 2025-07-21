library(teems)

main_dat <- ems_data(dat_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfdat.har",
                     par_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfpar.har",
                     set_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfset.har",
                     tab_file = "GTAP-INTv1",
                     target_format = "v6.2",
                     time_steps = c(0, 1, 2, 3, 4, 6, 8, 10, 12, 14, 16))

qfd_shk <- ems_shock(var = "qfd",
                     type = "uniform",
                     input = -0.75,
                     REGs = "lam",
                     PROD_COMMj = "crops")

y_in <- ems_swap(var = "y")
incomeslack_out <- ems_swap(var = "incomeslack")

y_shk <- ems_shock(var = "y",
                   type = "uniform",
                   input = 0.5,
                   REGr = "oecd",
                   ALLTIMEt = "3")

model_specs <- ems_model(tab_file = "GTAP-INTv1",
                         var_omit = c("atall", "avaall"),
                         shock = list(qfd_shk, y_shk),
                         swap_in = list("qfd", y_in),
                         swap_out = list("tfd", incomeslack_out))

load_specs <- ems_load(ems_input = main_dat,
                       REG = "AR5",
                       TRAD_COMM = "macro_sector",
                       ENDW_COMM = "labor_agg")

model_name <- "v11_uni_swap_mixed_multishk"

cmf_path <- ems_deploy(model_config = model_specs,
                       load_config = load_specs,
                       model_name = model_name)

ems_solve(cmf_path = cmf_path,
          n_tasks = 1,
          n_subintervals = 1,
          matrix_method = "LU",
          solution_method = "Johansen")

ems_solve(cmf_path = cmf_path,
          n_tasks = 2,
          n_subintervals = 2,
          steps = c(2, 4, 8),
          matrix_method = "SBBD",
          solution_method = "mod_midpoint")

ems_solve(cmf_path = cmf_path,
          n_tasks = 2,
          n_subintervals = 2,
          matrix_method = "NDBBD",
          n_timesteps = 11,
          solution_method = "mod_midpoint")

inputdata <- ems_compose(cmf_path = cmf_path, type = "inputdata")
variables <- ems_compose(cmf_path = cmf_path, type = "variable")
coefficients <- ems_compose(cmf_path = cmf_path, type = "coefficient")
sets <- ems_compose(cmf_path = cmf_path, type = "set")

all(variables$dat$qfd[REGs == "lam" & PROD_COMMj == "crops"]$Value == -0.75,
    variables$dat$incomeslack$Value != 0,
    variables$dat$y[REGr == "oecd" & ALLTIMEt == 3]$Value == 0.5)

