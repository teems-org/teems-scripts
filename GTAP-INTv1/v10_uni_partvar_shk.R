library(teems)

main_dat <- ems_data(dat_input = "~/dat/GTAP/v10A/flexagg10AY14/gsddat.har",
                     par_input = "~/dat/GTAP/v10A/flexagg10AY14/gsdpar.har",
                     set_input = "~/dat/GTAP/v10A/flexagg10AY14/gsdset.har",
                     tab_file = "GTAP-INTv1",
                     time_steps = c(0, 1, 2, 3, 4, 6, 8, 10, 12, 14, 16))

ao_shk <- ems_shock(var = "aoall",
                    type = "uniform",
                    input = -3,
                    REGr = "asia",
                    PROD_COMMj = "crops")

model_specs <- ems_model(tab_file = "GTAP-INTv1",
                         var_omit = c("atall", "tfd", "avaall", "tf", "tfm",
                                      "tgd", "tgm", "tpd", "tpm"),
                         shock = ao_shk)

load_specs <- ems_load(ems_input = main_dat,
                       REG = "AR5",
                       TRAD_COMM = "macro_sector",
                       ENDW_COMM = "labor_agg")

model_name <- "v10_uni_partvar_shk"

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

all(variables$dat$aoall[REGr == "asia" & PROD_COMMj == "crops"]$Value == -3)
