
---EDA 

http://genomicsclass.github.io/book/pages/exploratory_data_analysis_1.html
# histogram and ecdf
hist(x,breaks = seq(floor(min(x)),ceiling(max(x))),main = "height historgram", xlab = "Height in inches")
xs <- seq(floor(min(x)),ceiling(max(x)),0.1)
plot(xs, ecdf(x)(xs), type = "l", xlab = "Height in inches", ylab = "F(x)")

# pnorm & qnorm
ps <- seq(0.01, 0.99, 0.1)
qs <- quantile(x, ps)
normalqs <- qnorm(ps,mean(x),sd(x))
plot(normalqs, qs, xlab = "Normal percentiles", ylab = "Height")
abline(0,1)

#qqnorm

install.packages("UsingR")
library(UsingR)
load("skew.RData")
class(dat)
par(mfrow = c(1,1))

qqnorm(dat[1:1000,4])

# boxplot
boxplot(exec.pay,ylab="10,000s of dollars",ylim=c(0,400))
boxplot(InsectSprays$count ~ InsectSprays$spray)












