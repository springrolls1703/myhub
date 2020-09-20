# #D01: bernouli distribution
# #D02: binominal distribution
# #D03: normal distribution
# #D04: t-distribution
# #D05: chi-square distribution

# --
# #D01: bernouli distribution
# from scipy import stats
# p = 0.5
# bernoulliDist = stats.bernouli(p)
# --
# #D02: binominal distribution
# from scipy import stats
# import numpy as np
# (p,num) = (0.5,4)
# binomDist = stats.binom(num, p)
# t = binomDist.pmf(np.arange(5))
# print(t)
# --
# #D03: normal distribution
# #np.nanmean: computing mean ignoring mean
# import numpy as np
# from scipy import stats
# mu = -2 #mean
# sigma = 0.7 #standard deviation
# myDistribution = stats.norm(mu,sigma)
# significanceLevel = 0.05
# t = myDistribution.ppf([significanceLevel/2,1-significanceLevel/2])
# print(t)
# #example of calculate the interval of the PDF containing 95% of the data
# --
# #D03: normal distribution
# from scipy import stats
# nd = stats.norm(3.5,0.76)
# t = nd.cdf(2.6)
# print(t)
# --
# #D04: t-distribution
# import numpy as np
# from scipy import stats
# n = 20
# df = n - 1
# alpha = 0.05
# stats.t(df).isf(alpha/2) #isf: inverse survival function
# --
# #D05: chi-square distribution
# import numpy as np
# from scipy import stats
# data = np.r_[3.04, 2.94, 3.01, 3.00, 2.94, 2.91, 3.02,3.04, 3.09, 2.95, 2.99, 3.10, 3.02]
# sigma = 0.05
# chi2Dist = stats.chi2(len(data)-1)
# statistic = sum(((data - np.mean(data))/sigma)**2)
# chi2Dist.sf(statistic)
# --
# #D06: F-Distribution
# import numpy as np
# from scipy import stats
# method1 = np.array([20.7, 20.3, 20.3, 20.3, 20.7, 19.9,
# 19.9, 19.9, 20.3, 20.3, 19.7, 20.3])
# method2 = np.array([ 19.7, 19.4, 20.1, 18.6, 18.8, 20.2,
# 18.7, 19. ])
# fval = np.var(method1, ddof=1)/np.var(method2, ddof=1)
# fd = stats.f(len(method1)-1,len(method2)-1)
# p_oneTail = fd.cdf(fval) # -> 0.019
# --
# #stat probplot 
# stats.probplot(data, plot=plt)
# --
# normality test
# from scipy import stats
# import numpy as np
# method1 = np.array([20.7, 20.3, 20.3, 20.3, 20.7, 19.9,
# 19.9, 19.9, 20.3, 20.3, 19.7, 20.3,20.7, 20.3, 20.3, 20.3, 20.7, 19.9,
# 19.9, 19.9, 20.3, 20.3, 19.7, 20.3])
# print(stats.normaltest(method1))
# --
#t-distribution #test significance
import numpy as np
from scipy import stats
import matplotlib.pyplot as plt
scores = np.array([109.4,76.4,128.7, 93.7, 85.6, 117.7, 117.2, 87.3, 100.3, 55.1])
tval = (110-np.mean(scores))/stats.sem(scores) #normalize the sample error
td = stats.t(len(scores)-1)
p = 2*td.sf(tval)
print(p)