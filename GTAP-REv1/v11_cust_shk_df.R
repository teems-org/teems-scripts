library(teems)

main_dat <- ems_data(dat_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfdat.har",
                     par_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfpar.har",
                     set_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfset.har",
                     tab_file = "GTAP-REv1",
                     time_steps = c(0, 1, 2, 3, 4, 6, 8, 10, 12, 14, 16))

afeall <- expand.grid(ENDWe = c("labor", "capital", "natlres", "land"),
                      ACTSa = c("svces", "food", "crops", "mnfcs", 
                                 "livestock"),
                      REGr = c("asia", "eit", "lam", "maf", "oecd"),
                      ALLTIMEt = seq(0, 10))

afeall$Value <- runif(nrow(afeall))

afeall_shk <- ems_shock(var = "afeall",
                        type = "custom",
                        input = afeall)

model_specs <- ems_model(
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
  ),
  shock = afeall_shk
)

load_specs <- ems_load(ems_input = main_dat,
                       REG = "AR5",
                       COMM = "macro_sector",
                       ACTS = "macro_sector",
                       ENDW = "labor_agg")

model_name <- "v11_cust_shk_df"

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

library(data.table)
afeall_shk_out <- variables$dat$afeall[, !"Year"]
afeall_merged <- merge(afeall, afeall_shk_out, by = colnames(afeall_shk_out[, !"Value"]))
setDT(afeall_merged)
afeall_merged[, delta := (Value.y - Value.x) / Value.x]

!any(abs(range(afeall_merged$delta)) > 0.01)

