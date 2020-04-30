#---------------------------------------------------------#
#                 Advanced Programming in R               #
#           8. Benchmarking and code profiling            #
#                  Academic year 2019/2020                #
#               Piotr Wójcik, Piotr Ćwiakowski            #
#---------------------------------------------------------# 

# Benchmarking is a process of repeated testing
# performance of specific operations

# The same thing (analysis, data processing) can usually 
# be done in R in diffeerent ways - some are faster,
# other slower

# We will learn how to check and compare
# speed of code execution in R.

# Tools that we will learn will allow to compare 
# time efficiency of different ways to do the same task.

# new packages that we will use

install.packages("rbenchmark")
install.packages("microbenchmark")
install.packages("profvis")
install.packages("multcomp")

library(rbenchmark)
library(microbenchmark)
library(profvis)
library(compiler) # compile is a base package installed by default
library(multcomp)

# needed for some plots
library(ggplot2)

#-------------------------------------------------------------------------------
# system.time()

# The command execution time or the entire block of R code 
# can be measured using the system.time() function

system.time(runif(1e7))

# function returns three values
# uzytkownik / user - the time that the processor executes the R code
# system - duration of additional system operations
#   (eg file access, memory allocation, etc.)
# uplynelo / elapsed - the sum of both above times

# with system.time() one can also measure the duration 
# of a longer code - then the argument must be taken in braces {}

system.time({
  x <- runif(1e6)
  y <- ifelse(x > 0.5, 1, 0)
  layout(matrix(1:2, nrow = 2, ncol = 1))
    hist(x)
    hist(y, breaks = c(0, 0.5, 1))
  layout(matrix(1))
  print(summary(as.factor(y)))
  rm(x, y)
  })

# Let's try to compare the time of calculating the average
# of a numeric vector in several ways

# Let's create a data frame with an "x" column with
# numeric values:

myData <- data.frame(x = rnorm(1e7))

# and two functions calculating the average:

my_mean1 <- function(x) {
  result <- sum(x) / length(x)
  return(result)
}

my_mean2 <- function(x) {
  result <- NA
  n <- length(x)
  for(i in 1:n)
   result <- sum(result, x[i], na.rm = TRUE)
  result <- result/n
  return(result)
}

# and then compare the time of their operation, as well
# of the standard mean() function applied to the column
# from the data frame and to the numeric vector (simpler
# data structure):

system.time(m1 <- my_mean1(myData$x))

system.time(m2 <- my_mean2(myData$x))

system.time(m3 <- mean(myData$x))

system.time(m4 <- mean(as.numeric(myData$x)))

# one can see that the loop has the worst performance
# but for the other approaches - times are comparable.

# each calculation was done only once, which might not
# be reliable

# it is also worth checking whether different approaches 
# give the same result

# assume that our benchmark is m3 - the result 
# of the mean() function

identical(m1, m3)
identical(m2, m3)
identical(m4, m3)

# lets see the results
m1
m2
m3
m4

# they seem to be the same, but...
m1 - m3
m2 - m3
m4 - m3

# not all are the same - why? 

# It's a matter of extremely small differences due to rounding
# the results  - one needs to be aware of that and
# not require exact equality, but acceptable level of accuracy

(m1 == m3)
(abs(m1 - m3) < 1e-15)


# comparison of different execution times is more reliable,
# when we repeat them more than once

# here come the rbenchmark and microbenchmark packages

#-------------------------------------------------------------------------------
# benchmark() function from rbenchmark package

# lets choose the first 100 000 observations from the data frame
# (the whole comparison would be too long)
# and compare times of four ways of calculating the mean.
# In the benchmark() function, the compared codes are given as
# its arguments.

benchmark(m1 <- my_mean1(myData$x[1:100000]),
          m2 <- my_mean2(myData$x[1:100000]),
          m3 <- mean(myData$x[1:100000]),
          m4 <- mean(as.numeric(myData$x[1:100000]))
          )

# to make the labels (column called "test") more readable, 
# one can define them when calling a function ("label" = {code})
# let's also save the comparison result as a new object

(compare_mean <- benchmark("my_mean1" = {m1 <- my_mean1(myData$x[1:100000])},
                           "my_mean2" = {m2 <- my_mean2(myData$x[1:100000])},
                           "mean" = {m3 <- mean(myData$x[1:100000])},
                           "mean_on_num" = {m4 <- mean(as.numeric(myData$x[1:100000]))}
                           )
  )

# the meaning of elapsed, user.self and sys.self is identical
# as described above for the system.time() function - this is
# TOTAL time (in seconds) based on all retests.

# Additionally, we have columns called:
# relative - the ratio of time of a particular variant
#            in relation to the fastest one
# replications - number of replications (100 by default)
# user.child and system.child apply to derived processes,
# which did not occur here

# function with the loop is about 30-40 times slower than the others...

# With the help of appropriate arguments we can change, for example:
# - number of replication - replications =
# - list of columns returned - columns =
# - column, based on which the result is sorted - order =

# we'll do 500 repeats for 10 000 observations

(compare_mean1a <- benchmark("my_mean1" = {m1 <- my_mean1(myData$x[1:10000])},
                              "my_mean2" = {m2 <- my_mean2(myData$x[1:10000])},
                              "mean" = {m3 <- mean(myData$x[1:10000])},
                              "mean_on_num" = {m4 <- mean(as.numeric(myData$x[1:10000]))},
                              columns = c("test", "replications", "elapsed", "relative"),
                              order = "relative",
                              replications = 500
                              )
  )

# Even more options are offered by the microbenchmark package


#-------------------------------------------------------------------------------
# microbenchmark() function from the microbenchmark package

# function is very similar to the one discussed above - also
# allows you to compare the time it takes to execute several 
# different codes for specified number of replications
# (default 100, as before)

# again, lets select the first 100 000 observations from the
# myData frame (the whole comparison would take too long)

(compare_mean2 <- microbenchmark("my_mean1" = {m1 <- my_mean1(myData$x[1:10000])},
                                  "my_mean2" = {m2 <- my_mean2(myData$x[1:10000])},
                                  "mean" = {m3 <- mean(myData$x[1:10000])},
                                  "mean_on_num" = {m4 <- mean(as.numeric(myData$x[1:10000]))}
                                  )
 )

# the results include not only the average code execution time,
# but also a set of descriptive statistics:
# - min is the minimum time
# - lq is the lower quartile of time
# - mean is the average time
# - median is the median of time
# - uq is the upper quartile of time
# - max is the maximum time

# expr - tested expression
# neval - number of evaluations (default 100)
# cld - statistical ranking (significance of differences marked
#       by letters, if the multcomp package is installed) - just
#       like in multiple comparison tests - rows with the same 
#       letter are NOT statistically different

# times are presented in units fitting to profiled code
# (microseconds here).

# We can change the number of repetitions (times =) 
# and use relative times instead of absolute (unit = "relative").

(compare_mean2a <- microbenchmark("my_mean1" = {m1 <- my_mean1(myData$x[1:1000])},
                                  "my_mean2" = {m2 <- my_mean2(myData$x[1:1000])},
                                  "mean" = {m3 <- mean(myData$x[1:1000])},
                                  "mean_on_num" = {m4 <- mean(as.numeric(myData$x[1:1000]))},
                                  times = 500, 
                                  unit = "relative" # other possible: ns, us, ms, s
                                  )
  )


# the result of microbenchmark() can be used to plot the graph
# (ggplot2 package has to be installed and loaded)

autoplot(compare_mean2a)

# by default the time axis has a logarithmic scale
# which can be changed

autoplot(compare_mean2a, log = FALSE)

# but the graph does not become more readable...

# we can also draw boxplot - also by default
# the time axis has a logarithmic scale

boxplot(compare_mean2a)



#-------------------------------------------------------------------------------
# byte compiler

# From version 2.13.0, the compiler package is included in 
# the R environment allowing for pre-compilation of source 
# code into so called byte code

# This results in faster execution of precompiled code.
# https://en.wikipedia.org/wiki/Bytecode

# From R 2.14.0, all standard functions and packages with 
# base R are automatically compiled to bytecode.

# see this on the example of the median() function

median

# The third line contains information about the byte code
# of the function.
# This means that the compiler package translated the source
# code of median() from R into another language that
# can be understood by a very fast interpreter.

# Not always the increase in efficiency is significant, but
# precompilation is a simple way to accelerate performance
# of functions - especially those containing processing
# in loops.

# package compiler allows you to compile packages during
# installation and individual R functions on request.
# It can also compile loops and functions during their 
# execution (just-in-time).

# More details:
# https://channel9.msdn.com/Events/useR-international-R-User-conferences/useR-International-R-User-2017-Conference/Taking-Advantage-of-the-Byte-Code-Compiler
# http://www.divms.uiowa.edu/~luke/R/compiler/compiler.pdf

# useful functions from the compiler package: 
# cmpfun() and cmpfile()

# cmpfun() allows to pre-compile functions

# lets define my_mean2() once again

my_mean2 <- function(x) {
  result <- NA
  n <- length(x)
  for(i in 1:n)
    result <- sum(result, x[i], na.rm = T)
  result <- result/n
  return(result)
}

# and see its code

my_mean2

# lets apply pre-compilation

my_mean2_cmp <- cmpfun(my_mean2)

# and see the code of the pre-compiled function

my_mean2_cmp

# it includes the bytecode !

# currently R precompiles ALL functions during 
# their first use (just-in-time, JIT)

# lets turn it off for a moment using the function enableJIT(),
# its only argument is the level of compilation
# 0 - no JIT precompilation
# 1, 2, 3 - level of compilation (default = 3 highest)

enableJIT(0)

# calling the function displays the previous compilation level

benchmark("my_mean2" = {m1 <- my_mean2(myData$x[1:10000])},
          "my_mean2_cmp" = {m2 <- my_mean2_cmp(myData$x[1:10000])}
          )[, 1:6]

# you can see that after compiling the function is twice as fast

# switch back to the default precompilations

enableJIT(3)

# and compare the efficieny once again

benchmark("my_mean2" = {m1 <- my_mean2(myData$x[1:10000])},
          "my_mean2_cmp" = {m2 <- my_mean2_cmp(myData$x[1:10000])}
          )[, 1:6]

# this time there is not a big difference, because 
# the function my_mean2() was automatically precompiled 
# during the first call


# the cmpfile() function is used to precompile the code
# saved in an external file. The precompiled code can be
# then loaded into R by the loadcmp() functions

# Eg. file "my_mean2.R" includes the NON-compiled code
# getwd()
# setwd('/Users/rafalelpassion/Advanced-programming-in-R-2020L/Class materials')

cmpfile(infile = "my_mean2.R",  # source file
        outfile = "my_mean2_cmp.R") # destination file


# lets look into "my_mean2_cmp.R"

# lets delete my_mean2() function from our workspace

rm(my_mean2)

# and read it from the file

source("my_mean2.R")

my_mean2

# it is a NON-compiled version

rm(my_mean2)

# lets load the compiled version with loadcmp()

loadcmp("my_mean2_cmp.R")

my_mean2


#---------------------------------------------------------------
# code profiling

# profvis() function from the profvis package

# In RStudio we can use the profvis() function to code profiling

# The function and package name is an abbreviation 
# of the expression PROFiling VISualisation.

# it displays a summary of profiling in a graphical form.

# The basic argument of the profvis() function
# is the profiled expression.

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

# The result is shown in two tabs: "Flame Graph" and "Data".

# The "Flame graph" tab is divided into 2 panels

# The top panel shows the profiled code with a clear summary
# indicating how long it took for each of its parts to be made
# and how much memory was busy / released in the next steps.

# The bottom panel on the horizontal axis has time in milliseconds,
# and the vertical dimension represents the call stack, showing
# whether the referenced functions have called other functions (which).

# Visualization is interactive - clicking on individual
# elements displays additional information.

# In our case, looping took the longest

# The "Data" tab shows the execution time of each function called
# (first level) - we can expand the list of subsequent calls
# levels and see the execution time of individual functions
# on a given stack.


# In the Data tab you can see that the longest reference
# was made to individual cells of the data frame

# let's do the same code as above, but WITHOUT
# saving matrix x as a data frame

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

# !!! The code executes several times faster!

# Conclusion: in repetitive operations it is worth operating 
# on the simplest data structures (matrices or vectors)


# OR - use effective methods of referring
# to elements of more complex objects (see exercise 8.2)



# WARNING!
# In the case of very fast code, profiling should be limited
# to analysis using the microbenchmark package, discussed
# before.


#--------------------------------------------------------------------------
# Exercises 8

# Exercise 8.1
# Check the time efficiency of various formulas calculating
# a square root from a vector of values. 
# Compare results for vectors of various lengths and types 
# (integer vs double).
# Check whether different formulas give exactly the same result.

# Sample methods for calculating the square root

x <- 1:10

sqrt(x)
x**(0.5)
exp(log(x) / 2)

# some other?



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

# b) rewrite the above code checked by the profvis()
#    function using the most efficient type of referncing
#    to a single element from a data.frame().
#   Is it much faster? Faster than using a matrix?





# Exercise 8.3
# Write two (or more) variants of the function finding and displaying
# all prime numbers from the interval [2, n], where n will be
# the only argument of the function.

# In one variant, use loops all over the vector,
# in the second you can use the algorithm known 
# as the Sieve of Eratosthenes - its pseudocode
# can be found here:
# https://en.wikipedia.org/wiki/Sieve_of_Eratosthenes

# Compare the time efficiency of both functions 
# BEFORE and AFTER precompilation to bytecode. 
# Check if the results from both functions are identical.




# Exercise 8.4.
# Perform code profiling of both functions from
# exercise 8.3 Which parts of them take the most time?



