library(teems)

years <- c(2011, 2012, 2013, 2014, 2015, 2017, 2019, 2021, 2023, 2025)
data <- ems_data(
  dat_input = "~/dat/GTAP/v9/2011/gddat.har",
  par_input = "~/dat/GTAP/v9/2011/gdpar.har",
  set_input = "~/dat/GTAP/v9/2011/gdset.har",
  REG = "AR5",
  TRAD_COMM = "macro_sector",
  ENDW_COMM = "labor_agg",
  time_steps = years
)

model <- ems_model(
  tab_file = "GTAP-INTv1"
)

REGr <- c("asia", "eit", "lam", "maf", "oecd")
ENDW_COMMi <- c("labor", "capital", "natlres", "land")
TRAD_COMMi <- c("svces", "food", "crops", "mnfcs", "livestock")
PROD_COMMj <- c("svces", "food", "crops", "mnfcs", "livestock", "zcgds")
MARG_COMMm <- "svces"

# 2D
pop <- expand.grid(
  REGr = REGr,
  Year = years,
  stringsAsFactors = FALSE
)

pop <- pop[do.call(order, pop), ]
pop$Value <- runif(nrow(pop))

# 3D
aoall <- expand.grid(
  PROD_COMMj = PROD_COMMj,
  REGr = REGr,
  Year = years,
  stringsAsFactors = FALSE
)

aoall <- aoall[do.call(order, aoall), ]
aoall$Value <- runif(nrow(aoall))

# 4D
afeall <- expand.grid(
  ENDW_COMMi = ENDW_COMMi,
  PROD_COMMj = PROD_COMMj,
  REGr = REGr,
  Year = years,
  stringsAsFactors = FALSE
)

afeall <- afeall[do.call(order, afeall), ]
afeall$Value <- runif(nrow(afeall))

# 5D
atall <- expand.grid(
  MARG_COMMm = MARG_COMMm,
  TRAD_COMMi = TRAD_COMMi,
  REGr = REGr,
  REGs = REGr,
  Year = years,
  stringsAsFactors = FALSE
)

atall <- atall[do.call(order, atall), ]
atall$Value <- runif(nrow(atall))

pop_shk <- ems_shock(
  var = "pop",
  type = "custom",
  input = pop
)

aoall_shk <- ems_shock(
  var = "aoall",
  type = "custom",
  input = aoall
)

afeall_shk <- ems_shock(
  var = "afeall",
  type = "custom",
  input = afeall
)

atall_shk <- ems_shock(
  var = "atall",
  type = "custom",
  input = atall
)

cmf_path <- ems_deploy(
  data = data,
  model = model,
  shock = list(pop_shk, aoall_shk, afeall_shk, atall_shk)
)

outputs <- ems_solve(
  cmf_path = cmf_path,
  n_tasks = 1,
  n_subintervals = 1,
  steps = c(2, 4, 8),
  matrix_method = "SBBD",
  solution_method = "mod_midpoint"
)

all(
  all.equal(pop,
    outputs$dat$pop[, c(1, 4, 3)],
    check.attributes = FALSE,
    tolerance = 1e-6
  ),
  all.equal(aoall,
    outputs$dat$aoall[, c(1, 2, 5, 4)],
    check.attributes = FALSE,
    tolerance = 1e-6
  ),
  all.equal(afeall,
    outputs$dat$afeall[, c(1, 2, 3, 6, 5)],
    check.attributes = FALSE,
    tolerance = 1e-6
  ),
  all.equal(atall,
    outputs$dat$atall[, c(1, 2, 3, 4, 7, 6)],
    check.attributes = FALSE,
    tolerance = 1e-6
  )
)
