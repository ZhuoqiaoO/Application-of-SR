#First download the problem 1 R dataset from the website https://uryasev.ams.stonybrook.edu/index.php/research/testproblems/financial_engineering/style-classification-with-quantile-regression/.
#Load the R workspace document from the downloaded file, then run the following codes. 
library(PSG)
#Data Preparation
k=1000
generated_data_set <- gen_data(k,0,1,0,1,0.95)
dt <- generated_data_set[[1]] #In Sample Data Set for Running SVR 
loading_factor <- cbind(rep(0,k),dt[,3])
colnames(loading_factor) <- c('intercept','x1')
ScenBench <- as.numeric(dt[,1])

#Section 1: Outliers Detecting Abilities of SR/SVR and CVaR Error Models--------------------------------------------------------------------------------------

#1 SVR Model Outliers Detecting Ability ---------------------------------------------------------------------------------------------------------------------

#Fitting SVR Model
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
cvar_op <- results$point_problem_1
svr_regression <- cvar_op[1]

#Obtaining VaR(|Z|):
abs_Z <- abs(ScenBench - svr_regression*as.numeric(dt[,3]))
Z <- data.matrix(abs_Z)
y0 <- rep(0,k)
colnames(Z) <- c('z1')
point_b <- c(1)
names(point_b) <- c('z1')
M0 <- data.matrix(cbind(-Z,y0))
colnames(M0) <- c('z1',"scenario_benchmark")
matrix_scenarios <- M0
VaR <- rpsg_getfunctionvalue("var_risk(0.95,matrix_scenarios)",point_b)

#Detecting Outliers Based on SVR Model
synthetic_outliers <- syn_y_out(dt)
x_out_true <- dt[,3][synthetic_outliers[,1]]
svr_dectected_outliers <- svr_outlier_dector(abs_Z,VaR,ScenBench)
x_out_svr <- dt[,3][svr_dectected_outliers[,1]]
common_out_pos <- intersect(synthetic_outliers[,1],svr_dectected_outliers[,1])
detecting_ability_svr <- length(common_out_pos)/length(synthetic_outliers[,1])

#2.CVaR Error Outliers Detecting Ability ---------------------------------------------------------------------------------------------------------------------------------------------------------
cvarerr.model <- list()
cvarerr.model$risk <- "cvar2_err"
cvarerr.model$w <- 0.95
cvarerr.model$H <- loading_factor
cvarerr.model$c <- ScenBench
resultserr <- rpsg_riskprog(cvarerr.model)
cvarerr_op <- resultserr$optimal.point
cvar_regression <- cvarerr_op[2]

#Obtaining VaR(|Z|):
abs_Zerr <- abs(ScenBench - cvar_regression*as.numeric(dt[,3]))
Zerr <- data.matrix(abs_Zerr)
y0 <- rep(0,k)
colnames(Z) <- c('z1')
point_b <- c(1)
names(point_b) <- c('z1')
Merr <- data.matrix(cbind(-Zerr,y0))
colnames(Merr) <- c('z1',"scenario_benchmark")
matrix_scenarios <- Merr
VaRerr <- rpsg_getfunctionvalue("var_risk(0.95,matrix_scenarios)",point_b)

#Detecting Outliers Based on CVaR Error Model
cvar_dectected_outliers <- svr_outlier_dector(abs_Zerr,VaRerr,ScenBench)
x_out_cvar <- dt[,3][cvar_dectected_outliers[,1]]
common_out_pos_err <- intersect(synthetic_outliers[,1],cvar_dectected_outliers[,1])
detecting_ability_cvar <- length(common_out_pos_err)/length(synthetic_outliers[,1])

#--------------------------------------------------------------------------------------------------------------------------------------------------------
# Section 2: MAE of true dataset, dataset with SVR detected outliers removed, and data set with CVaR Error detected outliers removed---------------------

#Removing SVR detected outliers from dt:
x <- dt[,3][-c(svr_dectected_outliers[,1])]
y <- dt[,1][-c(svr_dectected_outliers[,1])]

#Removing CVaR_err detected outliers from model with outliers:
x_err <- dt[,3][-c(cvar_dectected_outliers[,1])]
y_err <- dt[,1][-c(cvar_dectected_outliers[,1])]

#Removing true outliers from dt:
X <- dt[,3][-dt[,4]]
Y <- dt[,1][-dt[,4]]

#MAE for LINEAR MODEL OF DT WITH OUTLIERS REMOVED BY SVR: 
matrix_scenario <- data.matrix(cbind(x,y))
colnames(matrix_scenario) <- c('x1','Scenario_Benchmark')
input.linmodel1 <- list()
input.linmodel1$matrix_scenario <- matrix_scenario
input.linmodel1$problem_statement <- sprintf (
  "
minimize
Meanabs_err(matrix_scenario)

  "
)
results1 <- rpsg_solver(input.linmodel1)
mae1 <- results1$output[[4]]

#MAE for LINEAR MODEL OF DT WITH OUTLIERS REMOVED BY CVAR: 
matrix_scenario <- data.matrix(cbind(x_err,y_err))
colnames(matrix_scenario) <- c('x1','Scenario_Benchmark')
input.linmodel2 <- list()
input.linmodel2$matrix_scenario <- matrix_scenario
input.linmodel2$problem_statement <- sprintf (
  "
minimize
Meanabs_err(matrix_scenario)

  "
)
results2 <- rpsg_solver(input.linmodel2)
mae2 <- results2$output[[4]]

#MAE for LINEAR MODEL OF DATASET WITH TRUE OUTLIERS REMOVED: 
matrix_scenario <- data.matrix(cbind(X,Y))
colnames(matrix_scenario) <- c('x1','Scenario_Benchmark')
input.linmodel3 <- list()
input.linmodel3$matrix_scenario <- matrix_scenario
input.linmodel3$problem_statement <- sprintf (
  "
minimize
Meanabs_err(matrix_scenario)

Solver: car
  "
)
results3 <- rpsg_solver(input.linmodel3)
mae3 <- results3$output[[4]]

#MAE for LINEAR MODEL OF TRUE MODEL BEFORE ADDING OUTLIERS: 
tm <- generated_data_set[[2]]
matrix_scenario <- data.matrix(cbind(tm[,3],tm[,1]))
colnames(matrix_scenario) <- c('x1','Scenario_Benchmark')
input.linmodel4 <- list()
input.linmodel4$matrix_scenario <- matrix_scenario
input.linmodel4$problem_statement <- sprintf (
  "
minimize
Meanabs_err(matrix_scenario)

Solver: car
  "
)
results4 <- rpsg_solver(input.linmodel4)
mae4 <- results4$output[[4]]

#---------------------------------------------------------------------------------------------------------------------------------------------------------
#plots
plot(dt[,3],dt[,1],col='purple',ylim=c(-3000,3000),xlab = c('X'),ylab = c('Y'))
points(x_out_true,synthetic_outliers[,2],col='green')
points(x_out_svr,svr_dectected_outliers[,2],col='black')
points(dt[,3],dt[,3]*svr_regression,col="red")
points(dt[,3],dt[,3]*cvar_regression,col='blue')
legend(0, -1500, legend=c("SVR Model",'CVaR Error Model', "True Outliers Undetected","SVR detected outliers",'Original Model'),
       col=c("red", 'blue',"green",'black','purple'), lty=1:2, cex=0.8)


