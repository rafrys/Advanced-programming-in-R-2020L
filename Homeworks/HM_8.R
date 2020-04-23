#--------------------------------------------------------------#
#                  Advanced Programming in R                   #
#  Homework for Laboratory 8: Benchmarking and code profiling  #
#                  Academic year 2019/2020                     #
#                  Rafal Rysiejko, 423827                      #
#--------------------------------------------------------------# 

library(rbenchmark)
library(microbenchmark)
library(profvis)
library(compiler)
library(multcomp)
library(ggplot2)

#--------------------------------------------------------------------------
# Exercises 8

# Exercise 8.1
# Check the time efficiency of various formulas calculating
# a square root from a vector of values. 
# Compare results for vectors of various lengths and types 
# (integer vs double).
# Check whether different formulas give exactly the same result.

# Sample methods for calculating the square root



sqrt(x)
x**(0.5)
exp(log(x) / 2)

# some other?
#Newtom method

# First 10 000 elements 
x <- 1:10000
benchmark("sqrt1" = {m1 <- sqrt(x)},
          "sqrt2" = {m2 <- x**(0.5)},
          "sqrt3" = {m3 <- exp(log(x)/2)})

identical(m1, m2)
identical(m1, m3)
identical(m2, m3)


x <- as.numeric(1:10000)
benchmark("sqrt1" = {m1 <- sqrt(x)},
          "sqrt2" = {m2 <- x**(0.5)},
          "sqrt3" = {m3 <- exp(log(x)/2)})

identical(m1, m2)
identical(m1, m3)
identical(m2, m3)

# First 1 000 000 elements 
x <- 1:1000000
benchmark("sqrt1" = {m1 <- sqrt(x)},
          "sqrt2" = {m2 <- x**(0.5)},
          "sqrt3" = {m3 <- exp(log(x)/2)})
identical(m1, m2)
identical(m1, m3)
identical(m2, m3)

x <- as.numeric(1:1000000)
benchmark("sqrt1" = {m1 <- sqrt(x)},
          "sqrt2" = {m2 <- x**(0.5)},
          "sqrt3" = {m3 <- exp(log(x)/2)})

identical(m1, m2)
identical(m1, m3)
identical(m2, m3)

#Conclusion, base formula sqrt(x), provides the most efficient result in terms of compilation-time, using double type of arguments yield better results than using integer types.

# Exercise 8.2.
# a) Compare the time efficiency of different variants 
#    of referrencing to a single element of a data.frame 
#    (see below)
#    https://stat.ethz.ch/R-manual/R-devel/library/base/html/base-internal.html

myData <- data.frame(x = rnorm(1e5))

myData$x[10000]
myData[10000, 1]
myData[10000, "x"]
myData[[c(1, 10000)]]
myData[[1]][10000]
.subset2(myData, select = 1)[10000]

# some other?
myData[['x']][10000]
myData['10000', "x"]

(compare_reference<- microbenchmark("m1" = {m1 <- myData$x[10000]},
                                  "m2" = {m2 <- myData[10000, 1]},
                                  "m3" = {m3 <- myData[10000, "x"]},
                                  "m4" = {m4 <- myData[[c(1, 10000)]]},
                                  "m5" = {m5 <- myData[[1]][10000]},
                                  "m6" = {m6 <- .subset2(myData, select = 1)[10000]},
                                  "m7" = {m7 <- myData[['x']][10000]},
                                  "m8" = {m8 <- myData['10000', "x"]},
                                  times = 100, 
                                  unit = "relative"
)
)

#Conclusion: Method using .subset2() function is the most time efficient solution out of considered variants.


# b) rewrite the above code checked by the profvis()
#    function using the most efficient type of referncing
#    to a single element from a data.frame().
#   Is it much faster? Faster than using a matrix?

### Data.frame
profvis(
  {
    x <- data.frame(matrix(rnorm(1e6), 
                           ncol = 5))
    result <- rep(NA, 5)
    n <- nrow(x)
    for(j in 1:5){
      for (i in 1:n) {
        result[j] <- sum(result[j], x[i,j], 
                         na.rm = TRUE)
      }
      result[j] <- result[j]/n
      hist(x[,j])
      boxplot(x[,j])
    }
  }
)

### Matrix
profvis(
  {
    x <- matrix(rnorm(1e6), ncol = 5)
    result <- rep(NA, 5)
    n <- nrow(x)
    for(j in 1:5){
      for (i in 1:n) {
        result[j] <- sum(result[j], x[i,j], 
                         na.rm = TRUE)
      }
      result[j] <- result[j]/n
      hist(x[,j])
      boxplot(x[,j])
    }
  }
)


## Data.frame + more efficient subseting
profvis(
  {
    x <- data.frame(matrix(rnorm(1e6), 
                           ncol = 5))
    result <- rep(NA, 5)
    n <- nrow(x)
    for(j in 1:5){
      for (i in 1:n) {
        result[j] <- sum(result[j], .subset2(x, select = j)[i], 
                         na.rm = TRUE)
      }
      result[j] <- result[j]/n
      hist(x[,j])
      boxplot(x[,j])
    }
  }
)


# Matrix + more efficient subseting
profvis(
  {
    x <- matrix(rnorm(1e6), ncol = 5)
    result <- rep(NA, 5)
    n <- nrow(x)
    for(j in 1:5){
      for (i in 1:n) {
        result[j] <- sum(result[j], .subset2(x, select = j)[i], 
                         na.rm = TRUE)
      }
      result[j] <- result[j]/n
      hist(x[,j])
      boxplot(x[,j])
    }
  }
)

#Conclusion: Using the most efficient type of referncing yields signifacantly better result than using x[i,j] method of referencing.
# But stil this is not more time efficient than using a matrix instead of a data.frame.

#-----
# Exercise 8.3
# Write two (or more) variants of the function finding and displaying
# all prime numbers from the interval [2, n], where n will be
# the only argument of the function.

primeNumbersLoops <- function(n) {
  if (n >= 2) {
    x = seq(2, n)
    prime_nums = c()
    for (i in seq(2, n)) {
      if (any(x == i)) {
        prime_nums = c(prime_nums, i)
        x = c(x[(x %% i) != 0], i)
      }
    }
    return(prime_nums)
  }
  else 
  {
    stop("Input number should be at least 2.")
  }
} 


#--
sieveOfEratosthenes <- function(n){
  values <- rep(TRUE, n)
  values[1] <- FALSE
  prev.prime <- 2
  for(i in prev.prime:sqrt(n)){
    values[seq.int(2 * prev.prime, n, prev.prime)] <- FALSE
    prev.prime <- prev.prime + min(which(values[(prev.prime + 1) : n]))
  }
  return(which(values))
}

primeNumbersLoops_cmp <- cmpfun(primeNumbersLoops)
sieveOfEratosthenes_cmp <- cmpfun(sieveOfEratosthenes)

# In one variant, use loops all over the vector,
# in the second you can use the algorithm known 
# as the Sieve of Eratosthenes - its pseudocode
# can be found here:
# https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes

# Compare the time efficiency of both functions 
# BEFORE and AFTER precompilation to bytecode. 
# Check if the results from both functions are identical.

### Before-precompilation 
enableJIT(0)
benchmark("primeNumbersLoops" = {m1 <- primeNumbersLoops(10000)},
          "primeNumbersLoops_cmp" = {m2 <- primeNumbersLoops_cmp(10000)},
          "sieveOfEratosthenes" = {m3 <- sieveOfEratosthenes(10000)},
          "sieveOfEratosthenes_cmp" = {m4 <- sieveOfEratosthenes_cmp(10000)})[, 1:6]
identical(m1,m3)
identical(m2,m4)

# After pre-compilation
enableJIT(3)
benchmark("primeNumbersLoops" = {m1 <- primeNumbersLoops(10000)},
          "primeNumbersLoops_cmp" = {m2 <- primeNumbersLoops_cmp(10000)},
          "sieveOfEratosthenes" = {m3 <- sieveOfEratosthenes(10000)},
          "sieveOfEratosthenes_cmp" = {m4 <- sieveOfEratosthenes_cmp(10000)})[, 1:6]
identical(m1,m3)
identical(m2,m4)

# Exercise 8.4.
# Perform code profiling of both functions from
# exercise 8.3 Which parts of them take the most time?

# primeNumbersLoops
profvis(
  {n=10000
  if (n >= 2) {
    x = seq(2, n)
    prime_nums = c()
    for (i in seq(2, n)) {
      if (any(x == i)) {
        prime_nums = c(prime_nums, i)
        x = c(x[(x %% i) != 0], i)
      }
    }
  }
  }
)
# Most time is  spent on the {if (any(x == i))} comparison

#--
# sieveOfEratosthenes
profvis(
  {n=10000
  values <- rep(TRUE, n)
  values[1] <- FALSE
  prev.prime <- 2
  for(i in prev.prime:sqrt(n)){
    values[seq.int(2 * prev.prime, n, prev.prime)] <- FALSE
    prev.prime <- prev.prime + min(which(values[(prev.prime + 1) : n]))
  }
  }
)

# Equal amount of time is spent on the {for(i in prev.prime:sqrt(n))} iteration and on the {prev.prime <- prev.prime + min(which(values[(prev.prime + 1) : n]))} assignment operation

