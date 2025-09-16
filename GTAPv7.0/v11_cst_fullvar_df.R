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

REGr <- c("asia", "eit", "lam", "maf", "oecd")
ENDWe <- c("labor", "capital", "natlres", "land")
COMMc <- c("svces", "food", "crops", "mnfcs", "livestock")
ACTSa <- c("svces", "food", "crops", "mnfcs", "livestock")
MARGm <- "svces"

# 1D
pop <- data.frame(
  REGr = REGr,
  stringsAsFactors = FALSE
)

pop$Value <- runif(nrow(pop))

# 2D
aoall <- expand.grid(
  ACTSa = ACTSa,
  REGr = REGr,
  stringsAsFactors = FALSE
)

aoall <- aoall[do.call(order, aoall), ]
aoall$Value <- runif(nrow(aoall))

# 3D
afeall <- expand.grid(
  ENDWe = ENDWe,
  ACTSa = ACTSa,
  REGr = REGr,
  stringsAsFactors = FALSE
)

afeall <- afeall[do.call(order, afeall), ]
afeall$Value <- runif(nrow(afeall))

# 4D
atall <- expand.grid(
  MARGm = MARGm,
  COMMc = COMMc,
  REGs = REGr,
  REGd = REGr,
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
  matrix_method = "DBBD",
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
