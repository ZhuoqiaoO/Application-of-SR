#1. Function that Generates Sythnthetic Dataset of Size k and 1 Independent Variable with (alpha*100%) Outliers:
gen_data <- function(k,mn_x,sd_x,mn_noise,sd_noise,alpha) {
  rand_num_X <- rnorm(k, mean = mn_x, sd = sd_x)
  rand_num_noise <- rnorm(k, mean = mn_noise, sd = sd_noise)
  Noise_true <- rand_num_noise #copy of true noise
  lb <- runif(1,min=-200,max=200) 
  up <- abs(lb*1.5)
  true_reg <- runif(k,min=lb,max=up) 
  Y_syn <- true_reg*rand_num_X + rand_num_noise
  Y_true <- Y_syn #copy of true Y
  true_model <- data.matrix(cbind(Y_true,Noise_true, rand_num_X )) 
  y_out_pos <- sample(1:k,ceiling(k*(1-alpha)),replace=FALSE)
  y_nout_pos <- rep(0,k-ceiling(k*(1-alpha)))
  Outlier_Position <- c(sort(y_out_pos),y_nout_pos) #outlier positions: if i=0, then Y_i is not an outlier
  for (i in y_out_pos) {
    a <- runif(1,min=-5,max=5)
    b <- runif(1,min=-6,max=-2)
    Y_syn[i] <- Y_syn[i]*runif(1,min=9,max=10)+sample(c(min(Y_true)*a,max(Y_true)*b),1)
    rand_num_noise[i] <- Y_syn[i]-true_reg[i]*rand_num_X[i]
  }
  synthetic_matrix <- data.matrix(cbind(Y_syn,rand_num_noise,rand_num_X,Outlier_Position))
  M <- list(synthetic_matrix,true_model)
  return(M)
}


#2.function for Detecting Outliers Based on Training Set Selected by SVR/SR Model
svr_outlier_dector <- function(abs_loss,var,syn_y){
  pos <- rep(0,length(abs_loss))
  out <- rep(0,length(abs_loss))
  for (i in 1:length(abs_loss)) {
    if (abs_loss[i]>=var) {
      pos[i] = i
      out[i] = syn_y[i]
    } else {
      pos[i] = 0
      out[i] = 0 
    }
  }
  M <- data.matrix(cbind(pos,out))
  outlier_matrix <- M[rowSums(M[])!=0,]
  return(outlier_matrix)
}


#3. Function for Extracting Outliers in Generated Dataset
syn_y_out <- function(synthetic_matrix) {
  out_pos <- synthetic_matrix[,4]
  out_pos <- out_pos[out_pos>0]
  out_pos <- sort(out_pos)
  outliers <- synthetic_matrix[,1][out_pos]
  return(cbind(out_pos,outliers))
}


