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

qfd_in <- ems_swap(var = "qfd",
                   REGs = "lam",
                   PROD_COMMj = "crops")

qfd_in2 <- ems_swap(var = "qfd",
                    TRAD_COMMi = "food",
                    REGs = "oecd",
                    PROD_COMMj = "crops")

tfd_out <- ems_swap(var = "tfd",
                    REGr = "lam",
                    PROD_COMMj = "crops")

tfd_out2 <- ems_swap(var = "tfd",
                     TRAD_COMMi = "food",
                     REGr = "oecd",
                     PROD_COMMj = "crops")

qfd_shk <- expand.grid(TRAD_COMMi = c("svces", "food", "crops", "mnfcs", "livestock"),
                        REGs = "lam",
                        PROD_COMMj = "crops",
                        stringsAsFactors = FALSE)
qfd_shk <- rbind(qfd_shk, data.frame(TRAD_COMMi = "food",
                                     REGs = "oecd",
                                     PROD_COMMj = "crops"))
qfd_shk$Value <- runif(nrow(qfd_shk))
qfd_shk <- qfd_shk[do.call(order, qfd_shk),]

cst_shk <- ems_shock(var = "qfd",
                     type = "custom",
                     input = qfd_shk)

cmf_path <- ems_deploy(data = data,
                       model = model,
                       swap_in = list(qfd_in, qfd_in2),
                       swap_out = list(tfd_out, tfd_out2),
                       shock = cst_shk)

outputs <- ems_solve(cmf_path = cmf_path,
                     n_tasks = 1,
                     n_subintervals = 1,
                     matrix_method = "LU",
                     solution_method = "mod_midpoint")

all(
all.equal(qfd_shk[qfd_shk$REGs == "lam" & qfd_shk$PROD_COMMj == "crops",],
          outputs$dat$qfd[REGs == "lam" & PROD_COMMj == "crops"],
          check.attributes = FALSE,
          tolerance = 1e-5),

all.equal(qfd_shk[qfd_shk$TRAD_COMMi == "food" & qfd_shk$REGs == "oecd" & qfd_shk$PROD_COMMj == "crops",],
          outputs$dat$qfd[TRAD_COMMi == "food" & REGs == "oecd" & PROD_COMMj == "crops"],
          check.attributes = FALSE,
          tolerance = 1e-6),

outputs$dat$qfd[REGs != "lam" & PROD_COMMj != "crops"]$Value != 0
)
