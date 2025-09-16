library(teems)

data <- ems_data(
  dat_input = "~/dat/GTAP/v10A/flexagg10AY14/gsddat.har",
  par_input = "~/dat/GTAP/v10A/flexagg10AY14/gsdpar.har",
  set_input = "~/dat/GTAP/v10A/flexagg10AY14/gsdset.har",
  REG = "AR5",
  TRAD_COMM = "macro_sector",
  ENDW_COMM = "labor_agg"
)

model <- ems_model(
  tab_file = "GTAPv6.2"
)

REGr <- c("asia", "eit", "lam", "maf", "oecd")
ENDW_COMMi <- c("labor", "capital", "natlres", "land")
TRAD_COMMi <- c("svces", "food", "crops", "mnfcs", "livestock")
PROD_COMMj <- c("svces", "food", "crops", "mnfcs", "livestock", "zcgds")
MARG_COMMm <- "svces"

# 1D
pop <- data.frame(
  REGr = REGr,
  Value = runif(length(REGr))
)

# 2D
aoall <- expand.grid(
  PROD_COMMj = PROD_COMMj,
  REGr = REGr,
  stringsAsFactors = FALSE
)

aoall <- aoall[do.call(order, aoall), ]
aoall$Value <- runif(nrow(aoall))

# 3D
afeall <- expand.grid(
  ENDW_COMMi = ENDW_COMMi,
  PROD_COMMj = PROD_COMMj,
  REGr = REGr,
  stringsAsFactors = FALSE
)

afeall <- afeall[do.call(order, afeall), ]
afeall$Value <- runif(nrow(afeall))

# 4D
atall <- expand.grid(
  MARG_COMMm = MARG_COMMm,
  TRAD_COMMi = TRAD_COMMi,
  REGr = REGr,
  REGs = REGr,
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
  matrix_method = "LU",
  solution_method = "mod_midpoint"
)

all(
  all.equal(pop,
    outputs$dat$pop,
    check.attributes = FALSE,
    tolerance = 1e-6
  ),
  all.equal(aoall,
    outputs$dat$aoall,
    check.attributes = FALSE,
    tolerance = 1e-6
  ),
  all.equal(afeall,
    outputs$dat$afeall,
    check.attributes = FALSE,
    tolerance = 1e-6
  ),
  all.equal(atall,
    outputs$dat$atall,
    check.attributes = FALSE,
    tolerance = 1e-6
  )
)
