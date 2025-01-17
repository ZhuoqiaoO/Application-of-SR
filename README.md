# Approaching Outliers in Dataset with Stable Regression and Minimization of CVaR Error

When training a linear regression model, cross-validation is often implemented to optimize out-of-sample performance, typically measured by the sum of errors. Commonly, dataset partitioning for training and validation involves randomization and this raises the question of how to optimally and efficiently partition the dataset to achieve the best out-of-sample performance. In the paper *Stable Regression: On the Power of Optimization over Randomization in Training Regression Problems*, Bertsimas et al. introduced a methodology that combines dataset partitioning and linear model training into a single linear optimization problem called Stable Regression (SR). In this approach, the training set is chosen based on the hardest-to-fit points, defined as those lying farthest from the line of best fit.

While this approach is powerful, it can become problematic when the dataset contains outliers, especially when the training set is small. Since outliers also lie far from the line of best fit, they are more likely to be included in the training set, which can negatively impact model accuracy. This observation motivates the exploration of whether SR’s property of selecting hard-to-fit points can be leveraged to identify outliers.

The algorithm for solving the SR minimization problem, as proposed by Bertsimas et al., involves introducing dual variables. In this project, instead of solving SR directly, we solve its equivalent problem, Nu Support Vector Regression (SVR), as introduced in *Support Vector Regression: Risk Quadrangle Framework* by Malandii and Uryasev (2023). Similar to SR, SVR is a linear optimization problem that minimizes the Conditional Value at Risk (CVaR) of absolute residuals — the risk measurement of the quantile-based quadrangle. This problem can be efficiently solved using the Portfolio Safeguard package in a single line of code.

For the numerical experiments, we generate synthetic datasets of sizes 50, 100, 500, and 1,000, each containing 5% outliers. We solve the SVR optimization problem with an intended training set size of 5% and test whether the selected training set corresponds to the set of outliers. Results show that the SVR/SR methodology correctly identifies outliers 85% of the time, with accuracy increasing and stabilizing as the dataset size grows.

During these experiments, we also observe that solving the linear optimization problem that minimizes the CVaR error — the error measurement of the quantile-based quadrangleof residuals and applying a training set selection process similar to SR consistently identifies the set of outliers. The CVaR model achieves a 92% accuracy rate in outlier extraction across datasets of all sizes.

Finally, we compare the out-of-sample performance of the SR model and the CVaR model, both fitted to datasets after outlier removal, against the SR model applied to datasets containing outliers. The results demonstrate that the SR and CVaR models trained on cleaned datasets outperform the SR model trained on uncleaned data, highlighting the effectiveness of outlier extraction in improving model accuracy.

**References**:
D. Bertsimas and I. Paskov. Stable regression: On the power of optimization over randomization. Journal of Machine Learning Research, 21(230):1–25, 2020. URL http://jmlr.org/papers/v21/19-408.html. ​

Malandii, A. and S. Uryasev. Support Vector Regression: Risk Quadrangle Framework, Jan 2023, arXiv:2212.09178​

R. T. Rockafellar and S. Uryasev. The Fundamental Risk Quadrangle in Risk Management, Optimization and Statistical Estimation. Surveys in Operations Research and Management Science, 18(1):33––53, 2013 ​

PSG Help Manual https://aorda.com/ ​

Case Study: Support Vector Regression: Risk Quadrangle Framework. https://uryasev.ams.stonybrook.edu/wp-content/uploads/2022/12/Case_Study__SVR.pdf ​
