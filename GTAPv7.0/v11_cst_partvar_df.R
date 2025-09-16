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

qfd_in <- ems_swap(
  var = "qfd",
  REGr = "lam",
  ACTSa = "crops"
)

qfd_in2 <- ems_swap(
  var = "qfd",
  COMMc = "food",
  REGr = "oecd",
  ACTSa = "crops"
)

tfd_out <- ems_swap(
  var = "tfd",
  REGr = "lam",
  ACTSa = "crops"
)

tfd_out2 <- ems_swap(
  var = "tfd",
  COMMc = "food",
  REGr = "oecd",
  ACTSa = "crops"
)

qfd_shk <- expand.grid(
  COMMc = c("svces", "food", "crops", "mnfcs", "livestock"),
  REGr = "lam",
  ACTSa = "crops",
  stringsAsFactors = FALSE
)

qfd_shk <- rbind(qfd_shk, data.frame(
  COMMc = "food",
  REGr = "oecd",
  ACTSa = "crops"
))
qfd_shk$Value <- runif(nrow(qfd_shk))
qfd_shk <- qfd_shk[do.call(order, qfd_shk), ]

cst_shk <- ems_shock(
  var = "qfd",
  type = "custom",
  input = qfd_shk
)

cmf_path <- ems_deploy(
  data = data,
  model = model,
  swap_in = list(qfd_in, qfd_in2),
  swap_out = list(tfd_out, tfd_out2),
  shock = cst_shk
)

outputs <- ems_solve(
  cmf_path = cmf_path,
  n_tasks = 1,
  n_subintervals = 2,
  matrix_method = "DBBD",
  solution_method = "mod_midpoint"
)

all(
  all.equal(qfd_shk[qfd_shk$REGr == "lam" & qfd_shk$ACTSa == "crops", ],
    outputs$dat$qfd[REGr == "lam" & ACTSa == "crops"],
    check.attributes = FALSE,
    tolerance = 1e-5
  ),
  all.equal(qfd_shk[qfd_shk$COMMc == "food" & qfd_shk$REGr == "oecd" & qfd_shk$ACTSa == "crops", ],
    outputs$dat$qfd[COMMc == "food" & REGr == "oecd" & ACTSa == "crops"],
    check.attributes = FALSE,
    tolerance = 1e-6
  ),
  outputs$dat$qfd[REGr != "lam" & ACTSa != "crops"]$Value != 0
)
