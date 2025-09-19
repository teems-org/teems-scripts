library(teems)

time_steps <- c(0, 1, 2, 3, 4, 6, 8, 10, 12, 14, 16)
data <- ems_data(
  dat_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfdat.har",
  par_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfpar.har",
  set_input = "~/dat/GTAP/v11c/flexAgg11c17/gsdfset.har",
  REG = "AR5",
  COMM = "macro_sector",
  ACTS = "macro_sector",
  ENDW = "labor_agg",
  time_steps = time_steps
)

model <- ems_model(
  tab_file = "GTAP-REv1"
)

REGr <- c("asia", "eit", "lam", "maf", "oecd")
ENDWe <- c("labor", "capital", "natlres", "land")
COMMc <- c("svces", "food", "crops", "mnfcs", "livestock")
ACTSa <- c("svces", "food", "crops", "mnfcs", "livestock")
MARGm <- "svces"
ALLTIMEt <- seq(0, length(time_steps) - 1)

# 2D
pop <- expand.grid(
  REGr = REGr,
  ALLTIMEt = ALLTIMEt,
  stringsAsFactors = FALSE
)

pop <- pop[do.call(order, pop), ]
pop$Value <- runif(nrow(pop))

# 3D
aoall <- expand.grid(
  ACTSa = ACTSa,
  REGr = REGr,
  ALLTIMEt = ALLTIMEt,
  stringsAsFactors = FALSE
)

aoall <- aoall[do.call(order, aoall), ]
aoall$Value <- runif(nrow(aoall))

# 4D
afeall <- expand.grid(
  ENDWe = ENDWe,
  ACTSa = ACTSa,
  REGr = REGr,
  ALLTIMEt = ALLTIMEt,
  stringsAsFactors = FALSE
)

afeall <- afeall[do.call(order, afeall), ]
afeall$Value <- runif(nrow(afeall))

# 5D
atall <- expand.grid(
  MARGm = MARGm,
  COMMc = COMMc,
  REGs = REGr,
  REGd = REGr,
  ALLTIMEt = ALLTIMEt,
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
            outputs$dat$pop[, !"Year"],
            check.attributes = FALSE,
            tolerance = 1e-6
  ),
  all.equal(aoall,
            outputs$dat$aoall[, !"Year"],
            check.attributes = FALSE,
            tolerance = 1e-6
  ),
  all.equal(afeall,
            outputs$dat$afeall[, !"Year"],
            check.attributes = FALSE,
            tolerance = 1e-6
  ),
  all.equal(atall,
            outputs$dat$atall[, !"Year"],
            check.attributes = FALSE,
            tolerance = 1e-6
  )
)
