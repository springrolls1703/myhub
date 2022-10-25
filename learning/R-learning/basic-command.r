--cmd
getwd() - get current directory
ls()
list.files()/ dir() - List all the files in your working directory using list.files() or dir().
args() - Using the args() function on a function name is also a handy way to see what arguments a
| function can take.
dir.create("testdir") - create new directory called testdir
setwd("testdir") - set current directory to testdir
file.create(mytest.R)
class({{object_name}})

--Number
seq(1,20)/ 1:20
seq(0,10, by=0.5): increment by 0.5
seq(5,10,length=30)
seq(along.with = my_seq)
seq_along(my_seq)
rep(0,times=40)

-- vector
paste(my_char, collapse = " ")
x[is.na(x)]
x[c(-2,-10)]/x[-c(2,10)]: getting everything except 2, and 10th value
vect <- c(foo = 11, bar = 2, norf = NA)
names(vect)
names(vect2) <- c("foo", "bar", "norf")
identical(vect,vect2): vect and vect2 are the same by passing them as arguments to the identical()
dim(my_vector) <- c(4,5): create vector of 4 rows and 5 collumns.

--DataFrame
my_matrix2 <- matrix(data = seq(1,20), nrow = 4, ncol = 5)
cbind(patients,my_matrix)
my_data <- data.frame(patients, my_matrix)
cnames <- c("patient","age","weight","bp","rating","test")
colnames(my_data) <- cnames
install.packages("dplyr")
library(dplyr)
control <- filter(df, Diet == "chow")
select(df, Bodyweight)
unlist(df)
--Logic
The `|` version of OR evaluates OR across an entire vector, while the `||` version of OR only evaluates the first member of a vector.
isTRUE(6>4)
xor(5==6,!FALSE)
which(ints > 7)
any(ints > 0) - return TRUE if any of the elements in ints vector > 0 
all()

--function
Sys.Date()
mean(c(2,4,5))
remainder <- function(num, divisor = 2) {
    num %% divisor
}
evaluate <- function(func, dat){
 func(dat)
}

evaluate(function(x){x[1]},c(8,4,0)): function is an anonymous function
library(downloader) 
url <- "https://raw.githubusercontent.com/genomicsclass/dagdata/master/inst/extdata/femaleMiceWeights.csv"
filename <- "femaleMiceWeights.csv" 
download(url, destfile=filename)


