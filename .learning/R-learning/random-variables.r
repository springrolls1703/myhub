---Random Variables

http://genomicsclass.github.io/book/pages/random_variables.html

# Random Variables Exercises
install.packages("downloader")
library(downloader) 
url <- "https://raw.githubusercontent.com/genomicsclass/dagdata/master/inst/extdata/femaleControlsPopulation.csv"
filename <- basename(url)
download(url, destfile=filename)
x <- unlist( read.csv(filename) )
RNGkind("Mersenne-Twister", "Inversion", "Rejection")
set.seed(1)
mean(x)
abs(mean(sample(x,5)) - mean(x))
set.seed(5)
abs(mean(sample(x,5)) - mean(x))

# P-values, null-hypothesis
library(downloader) 
url <- "https://raw.githubusercontent.com/genomicsclass/dagdata/master/inst/extdata/femaleControlsPopulation.csv"
filename <- basename(url)
download(url, destfile=filename)
x <- unlist( read.csv(filename) )

set.seed(1)
n <- 10000
null <- vector("numeric", n)

for (i in 1:n) {
  null[i] <- mean(sample(x,5))
}
# what is the percentage of the values in null that higher than 1 gram
mean(abs(null - mean(x))  > 1)

install.packages("gapminder")
library(gapminder)
data(gapminder)
head(gapminder)
x <- filter(gapminder, year == 1952)$lifeExp
hist(x)
mean(x <= 40)

#ecdf
prop = function(q) {
  mean(x <= q)
}
qs = seq(from=min(x), to=max(x), length=20)
props = sapply(qs, prop)
plot(qs, props)
props = sapply(qs, function(q) mean(x <= q))
plot(ecdf(x))


# Normal distribution

library(downloader) 
url <- "https://raw.githubusercontent.com/genomicsclass/dagdata/master/inst/extdata/femaleControlsPopulation.csv"
filename <- basename(url)
download(url, destfile=filename)
x <- unlist( read.csv(filename) )

# make averages5
set.seed(1)
n <- 1000
averages5 <- vector("numeric",n)
for(i in 1:n){
  X <- sample(x,5)
  averages5[i] <- mean(X)
}
# make averages50
set.seed(1)
n <- 1000
averages50 <- vector("numeric",n)
for(i in 1:n){
  X <- sample(x,50)
  averages50[i] <- mean(X)
}

# histogram of sample of 5 and sample of 50
par(mfrow = c(2,2))
hist(averages5)
hist(averages50)

#what is the proportion are between 23 and 25
pnorm(25,mean(averages50),sd(averages50)) - pnorm(23,mean(averages50),sd(averages50)) 
pnorm(25,23.9,0.43) - pnorm(23,23.9,0.43)