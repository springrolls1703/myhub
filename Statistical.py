--01PDF: probability density function #đồ thị hình núi
--02PMF: probability mass function
--03Control Factors and Uncontrolled Factors: 
--04general linear model: Y = B + B1*X1 + B2*X2 + B12*X1*X2 + e
#B1, B2: main effect
#B12: interaction term
#B: linear
#e: residuals
--05Design of a study:
----0Hypothesistest: Compare two or more groups, or one group to a fixed value
----1Screening investigation:Identify which factors/effects that are important
----2Optimizationproblem Maximize a response(variability, distance to target,robustness)
----3statisticalmodelling Develop a regression model to quantify the dependence of a response variable on the process input
--06Samplesize: Power analysis
----What is the variance of the param under investigation
----What is the magnitude of the  ex
--07Bias:
----Selection of subjects
----The structure of the experiment
----The measurement device
----The analysis of the data
--08CDF: Cumulative Distribution Function #đồ thị hình lũy tiến
--095percentile: 50th percentile is the median
--10variance and std: variance from the mean,#cho biết độ biến thiên squared root of var is s.
--11confidence error: 
--11-1discrete: can only take integer value
--11-2continous: observation are float
--12the_percent_interval(CI): reports the range that contains the true value for the parameter with a likelihood of apha percentile
--13.1Binominaldistribution: is discrete, have an inherent upper limit (throw a dice 5 times, each side can come up a maximum of 5)
--13.2Poissondistribution: is discrete, does not have an inherent upper limit (how many people you know)
--14.1Normaldistribution/Gaussian distribution: is continous, data that are drawn has a normal distribution
--14.2CentralLimitTheorem: the mean of a sufficiently large number identical distributed random variates will be approximately normally distributed
--14.3t-Distribution: The sample of mean values for samples from normally distributed population
--14.5x-Square distribution: For describing variability of normally distributed data
--14.6F-distribution: For comparing two sets of data
--14.7Sample: If the average man is 175 cm tall with a standard deviation of 6 cm, what is the
probability that a man selected at random will be 183 cm tall?
--14.8ANOVA: ANalysis Of VAriance
--15.0Hypothesis:
--15.1EDA: Data Screening and Outliers
--15.2.1Probability-plots: QQ-plots, PP-plots(CDF), Probability Plots:
if the two distributions being compared
are similar, the points will approximately lie on the line y = x. If the distributions
are linearly related, the points will approximately lie on a line, but not necessarily
on the line y = x
--15.2.2Test for normality: stats.normaltest(x) #test phân phối chuẩn
--16.1TestSignificance