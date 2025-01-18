a=0.3 #percentage of outsample data
alpha = 0.85
b=0.15 #percentage of in sample observations
k=50
generated_data_set <- gen_data(k,0,1.5,0,1,0.9)
DT <- generated_data_set[[1]]
outsample_pos <- sort(sample(1:k,k*a))
outsample_dt <- DT[outsample_pos,]
insample_dt <- DT[-outsample_pos,]
dt <- insample_dt

#----------------------------------------------------------------------------------------------------------------------------------------------------------
#Part 4: Comparing Results for SVR model, CVaR Error Model Performances Before and After Removing Outliers.
#1. Removing Outliers From In-Sample Data Using the SR/SVR Model:
matrix_scenario <- data.matrix(cbind(dt[,3],dt[,1]))
colnames(matrix_scenario) <- c('x1','Scenario_Benchmark')
svr.model <- list()
svr.model$matrix_scenario <- matrix_scenario
svr.model$problem_statement <- sprintf (
  "
minimize
0.05*cvar_risk(0.95,abs(matrix_scenario))

  "
)
results <- rpsg_solver(svr.model)
svr_op <- results$point_problem_1
svr_regression <- svr_op[1]
abs_Z <- abs(as.numeric(dt[,1]) - svr_regression*as.numeric(dt[,3]))
Z <- data.matrix(abs_Z)
y0 <- rep(0,length(abs_Z))
colnames(Z) <- c('z1')
point_b <- c(1)
names(point_b) <- c('z1')
M0 <- data.matrix(cbind(-Z,y0))
colnames(M0) <- c('z1',"scenario_benchmark")
matrix_scenarios <- M0
VaR <- rpsg_getfunctionvalue("var_risk(0.95,matrix_scenarios)",point_b)
svr_dectected_outliers <- svr_outlier_dector(abs_Z,VaR,as.numeric(dt[,1])) #SVR detected outliers y values and position
x <- dt[,3][-c(svr_dectected_outliers[,1])]
y <- dt[,1][-c(svr_dectected_outliers[,1])]

#2. Removing Outliers From In-Sample Data Using the CVaR Error Model:
cvarerr.model <- list()
cvarerr.model$risk <- "cvar2_err"
cvarerr.model$w <- 0.95
cvarerr.model$H <- loading_factor
cvarerr.model$c <- ScenBench
resultserr <- rpsg_riskprog(cvarerr.model)
cvarerr_op <- resultserr$optimal.point
cvar_regression <- cvarerr_op[2]
abs_Zerr <- abs(as.numeric(dt[,1]) - cvar_regression*as.numeric(dt[,3]))
Zerr <- data.matrix(abs_Zerr)
y0 <- rep(0,length(abs_Zerr))
colnames(Z) <- c('z1')
point_b <- c(1)
names(point_b) <- c('z1')
Merr <- data.matrix(cbind(-Zerr,y0))
colnames(Merr) <- c('z1',"scenario_benchmark")
matrix_scenarios <- Merr
VaRerr <- rpsg_getfunctionvalue("var_risk(0.95,matrix_scenarios)",point_b)
cvar_dectected_outliers <- svr_outlier_dector(abs_Zerr,VaRerr,as.numeric(dt[,1])) #CVaR Error Model detected outliers y values and positions
x_err <- dt[,3][-c(cvar_dectected_outliers[,1])]
y_err <- dt[,1][-c(cvar_dectected_outliers[,1])]

#3. Fitting SR/SVR Again for the Cleaned Dataset to Obtain Optimal Coefficients
matrix_scenario <- data.matrix(cbind(x,y))
colnames(matrix_scenario) <- c('x1','Scenario_Benchmark')
svr.model1 <- list()
svr.model1$matrix_scenario <- matrix_scenario
svr.model1$problem_statement <- sprintf (
  "
minimize
0.8*cvar_risk(0.2,abs(matrix_scenario))

  "
)
results1 <- rpsg_solver(svr.model1)
svr_op1 <- results1$point_problem_1
svr_regression_new1 <- svr_op1[1]

matrix_scenario <- data.matrix(cbind(x_err,y_err))
colnames(matrix_scenario) <- c('x1','Scenario_Benchmark')
svr.model2 <- list()
svr.model2$matrix_scenario <- matrix_scenario
svr.model2$problem_statement <- sprintf (
  "
minimize
0.8*cvar_risk(0.2,abs(matrix_scenario))

  "
)
results2 <- rpsg_solver(svr.model2)
svr_op2 <- results2$point_problem_1
svr_regression_new2 <- svr_op2[1]

#4. Calculate Out-of-Sample MAE
mae1 <- sum(abs(outsample_dt[,1]-svr_regression_new1*outsample_dt[,3]))/length(outsample_dt[,3])
mae2 <- sum(abs(outsample_dt[,1]-svr_regression_new2*outsample_dt[,3]))/length(outsample_dt[,3])

#5.Fitting SR/SVR to DataSet With Outliers and Obtain Out-of-Sample MAE
matrix_scenario <- data.matrix(cbind(dt[,3],dt[,1]))
colnames(matrix_scenario) <- c('x1','Scenario_Benchmark')
svr.model3 <- list()
svr.model3$matrix_scenario <- matrix_scenario
svr.model3$problem_statement <- sprintf (
  "
minimize
0.8*cvar_risk(0.2,abs(matrix_scenario))

  "
)
results3 <- rpsg_solver(svr.model3)
svr_op3 <- results3$point_problem_1
svr_regression_new3 <- svr_op3[1]
mae3 <- sum(abs(outsample_dt[,1]-svr_regression_new3*outsample_dt[,3]))/length(outsample_dt[,3])


plot(dt[,3],dt[,1])
points(dt[,3],svr_regression_new2*dt[,3],col='red')
points(dt[,3],svr_regression_new1*dt[,3],col='blue')
points(dt[,3],svr_regression_new3*dt[,3],col='purple')


