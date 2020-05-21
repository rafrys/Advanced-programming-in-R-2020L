#---------------------------------------------------------#
#                 Advanced Programming in R               #
#                  12. Rcpp: using C++ in R               #
#                  Academic year 2019/2020                #
#               Piotr Wójcik, Piotr Ćwiakowski            #
#---------------------------------------------------------#    

# Today, we'll find out how to improve the performance
# of R code by writing selected functions in C++.

# It may happen that after profiling the R code we find
# bottlenecks and even if we do everything to optimize 
# the R code - it will still be slow.

# Typical bottlenecks of programs in R:
# - loops that can not easily be vectorized, because
#   calculations in a given iteration depend on the 
#   results from the previous iterations.
# - recursive functions or problems that require multiple
#   calling the same function

# C++ can help to solve these problems
# C++ is a modern, fast and very well supported 
# programming language with numerous additional 
# libraries allowing to perform various types
# of computational tasks.

# Thanks to the Rcpp package written by Dirk Eddelbuettel
# and Romain Francois combining C++ with R is very easy.

# Below we will discuss only the basic aspects 
# of C++ and Rcpp on simple examples that will
# help you easily replace the R code with
# often significantly faster counterparts in C++.

# An earlier knowledge of C++ is NOT required,
# but it will probably be helpful.

# People interested in deepening knowledge of Rcpp 
# or C ++ will find many very good tutorials on the web
# - we recommend it at the end of these materials


# Preparation of the environment

# The use of C ++ in R programs is facilitated by
# the Rcpp package - let's install it and load into memory:

install.packages("Rcpp")

library(Rcpp)

# lets also load the package rbenchmark

library(rbenchmark)

# The use of C++ in R requires installation
# of a C++ compiler.

# To make it available, please:
# - on Windows: install the latest version of Rtools.
# - on Mac: install the Xcode application from the AppStore
# - on Linux: sudo apt-get install r-base-dev or similar.


# It's worth checking with the find_rtools() function
# from the package pkgbuild, whether Rtools are already installed.

# install.packages("pkgbuild")

pkgbuild::find_rtools()

# The result TRUE means that these tools have been
# already installed and are ready to use.


# If they are not installed or there is a need to update them,
# one can install them manually downloading a source file
# from the website:
# https://cran.r-project.org/bin/windows/Rtools/history.html
# (!!!! there are some news for R 4.0.0 and newer:
# https://cran.r-project.org/bin/windows/Rtools/)

# One can also install Rtools automatically using 
# the function install.Rtools() from the installr package.

install.packages ("installr")
library (installr)

# !!!! DO NOT RUN below line if 
# pkgbuild::find_rtools() showed TRUE !!!

install.Rtools()



#------------------------------------------
# First steps with C ++

# cppFunction() function from Rcpp allows 
# you to write functions in C++ from the level of R

# The C++ function is similar to the R function:
# - we give a set of input data to the function
#   (function arguments),
# - we run some code on them,
# - we return a single object.

# There are, however, several important DIFFERENCES:
# - in C++ function every command must be terminated with a semicolon;
#   (In R, we only use it when we have many instructions on the same line)
# - in C++ function, we must declare types of objects on which we work,
#   in particular types of function arguments, type of returned value
#   and any intermediate objects that we create inside the function.
# - C++ function must have a clear return statement, similar to the R function
#   There may be many return commands in the function, but the function 
#   will exit, when it encounters the first return statement.
# - when creating C++ function we do NOT use the assignment operator.
# - assignment operator in C++ is =. The operator ->, <- is incorrect in C++.
# - comments in C++ will be written as follows:
#    - one-line comment can be created using // ...
#    - multiline comments are created using /*...*/
# - To find the length of a vector in C++, we use the .size() method,
#    which returns an integer.
# - the for() statement has different syntax in C++: 
#   for (init; check; increment).
#   After each iteration we have to increase the value of init 
#   (usually by one),
# - C++ provides operators modifying a value in place: 
#   eg i++ increases the value of i by 1.
#   Similar modifying operators in place are -=, *=, /=.
# - in C++ indexing vectors starts with 0 (similarly to python).
#   Let's write it once again: in C++ INDEXING VECTORS STARTS FROM 0!
#   This is a source of very frequent errors when converting 
#   functions from R to C++.

# C++ classes for the most popular types of R vectors are:
# - NumericVector - vector of numerical values (floating point)
# - IntegerVector - vector of integer values
# - CharacterVector - vector of character (text) values
# - LogicalVector - vector of logical values

# C++ equivalents of individual values (scalar):
# R numeric -> double
# R integer -> int
# R character -> String
# R logical -> bool

# simple example

cppFunction("int multiplyBy2(int x) {
            int result = x * 2;
            return result;
            }")

# of course, it would be more universal to use
# double as input type, but let's see how the function 
# will work for the int (integer) type

# Rcpp will compile the C++ code and create a function that
# will be available in the R workspace

# resulting function cane be used like a normal R function

multiplyBy2(5)
multiplyBy2(-12)

# for non-integer numbers it will work too, but 
# it will take of them integer part from them

multiplyBy2(4.00001)
multiplyBy2(4.99999)

# function cppFunction() is an extension of the function
# cxxfunction() from the inline package, but it is
# much easier to use

# the following examples will show how to build functions
# using Rcpp for sample combinations
# of input types and resulting types

#----------------------------- 
# 1 function without input data,
# result - single value (scalar)
  
# function without arguments always returning
# integer of 10:

# in R
tenR <- function() {
  10L
  }

# C++ equivalent
cppFunction('int tenC() {
            return 10;
            }')

# In this simple example, you can see some important differences 
# between R and C++:
# - in C++, we do not use the assignment operator to create functions
# - in C++ one has to declare the type of function result
#    - before the function name
# - in C++ one must use the return statement directly
# - each C++ statement ends with a semicolon;

# the result of both functions will be the same:

tenR()

tenC()

#-----------------------------
# 2 argument and result are single values (scalars)
  
# we create a function that returns a sign of a number
# (equivalent to the standard sign() function)
  
# code in R

signR <- function(x) {
  if (x > 0) 1 else 
    if (x == 0) 0 else -1
  }

# let's write it in a way similar to the below C++ code

signR <- function(x) {
  if (x > 0) {
    1
    } else if (x == 0) {
      0
      } else {
        -1
      }
}

# C++ equivalent will look very similar

cppFunction('int signC(double x) {
            if (x > 0) {
            return 1;
            } else if (x == 0) {
            return 0;
            } else {
            return -1;
            }
            }')

# in the C++ version:
# - we declare the type of each argument and result type 
#    - thanks to this the function is more readable - it 
#    is known what type of argument is required.
# - the syntax of the if() command is IDENTICAL in R and C++
#   C++ also has a while() loop that also works the same as R.
#   As in R, in C++ you can use the break command to exit the loop,
#   but the equivalent of the R command "next" (move to the next iteration)
#   is the "continue" command in C++
# - comparison operator == is identical in C++ and R (similarly !=)

# see how the function works

z <- rnorm(20)

# default R function

sign(z)

# our R function
signR(z)

# as we used if() function inide, the result is based only
# on the first argument of the input vector.
# we will use the function for each value of the vector 
# separately with the help of sapply()

sapply(z, signR)

# the same for signC:

signC(z)

# returns an error 

# the function expects a single input value
# - scalar of typ double 

sapply(z, signC)

#-----------------------------
# 3. Vector as the function argument 
#    and single value (scalar) as a result

# The big difference between R and C++ is that there is 
# time overhead of a loop in R is very large, and 
# in C++ much smaller

# lets write the function that calculates the average 
# of the numeric vector (equivalent to the built-in
# mean() function - VERY fast and efficient)

myMeanR = function(x) {
  sum = 0
  n = length(x)
  for(i in 1:n)
    sum = sum + x[i]
  sum/n
}

# C++ equivalent

cppFunction('double myMeanC(NumericVector x) {
  int i;
  int n = x.size();
  double sum = 0;

  for(i=0; i<n; i++) {
    sum = sum + x[i];
  }
  return sum/n;
}')

# the type of the loop indexing variable 
# can be also defined directly in for() command

cppFunction('double myMeanC(NumericVector x) {
  int n = x.size();
  double sum = 0;

  for(int i=0; i<n; i++) {
    sum = sum + x[i];
  }
  return sum/n;
}')

# The function version in C++ is similar to R, but:
# - in C++ we find the length of the vector using the .size() method
# - the for() loop has a different syntax in C++:
#   for(init; check; increment).
#    - in C++, INDEXING VECTORS STARTS FROM 0!
#    - the loop is initiated by creating an index variable
#      init (in our case: i) with the value 0
#    - before each iteration we check if i<n, and finish the loop,
#      if condition is NOT met.
#    - after each iteration the value of i is increased by 1 using
#      special increment operator i++, which increases the value by 1.
# - i++ is the operator that modifies the value of i "in place":
# - similarly we can rewrite part of the loop as: sum += x[i] ;.
# - other in place modifying operators: -=, *= and /=
# - for the assignment operation in C++ we use 
#   the equality sign = , not <-

# The myMeanC function is a good example of where C++
# is much more efficient than R.

# lets compare the calculation speed of myMeanR(), 
# myMeanC(), and the built-in R: mean() function

# first we generate a vector of one million random
# values from the normal distribution

x <- rnorm(1e6)

benchmark("mean" = mean(x),
          "myMeanR" = myMeanR(x),
          "myMeanC" = myMeanC(x)
          )[, 1:4]

# function in C++ is much better than the function in R,
# and even slightly better than the built-in mean() function


#--------------------------------------
# example of a function with a recursive call

# Consider the Fibonacci sequence - a sequence of natural numbers
# specified recursively as follows:
# - the first word is equal to 0, the second is equal to 1,
# - each next is the sum of the previous two:

# F(n) = n for n <= 1
#      = F(n-1) + F(n-2) for n > 1

# implementation in R

fiboR <- function(n) {
  if (n <= 1) n else
    fiboR(n-1) + fiboR(n-2)
}

# lets apply the function for the first eleven
# natural numbers

sapply(0:10, fiboR)

# see how the time efficiency changes
# with an increase in the number of recursive calls

benchmark(fiboR(10), 
          fiboR(15), 
          fiboR(20), 
          replications = 500)[, 1:4]

# C++ equivalent

cppFunction('int fiboC(int n) {
            if (n <= 1) return(n); else
            return(fiboC(n-1) + fiboC(n-2)); }')

# lets apply the function for the first eleven
# natural numbers

sapply(0:10, fiboC)

# comparison of efficiency betweeb C++ and R

benchmark(fiboR(25), fiboC(25))[, 1:4]

# nice acceleration...

# lets check if for C++ function computational 
# complexity grows as fast as in R

benchmark(fiboC(10), 
          fiboC(15), 
          fiboC(20), 
          replications = 10000)[, 1:4]

# NO!!!

#-----------------------------
# 4. Vector as the function argument and its result
  
# Assume that we are to assess the quality of forecasts
# obtained from many models for one observation 
# with a single real value
  
# we will calculate a relative forecast error for
# vector predictions and one real value:

# function in R
relerrorR <- function(real, forecasts) {
  abs(real - forecasts)/real
  }

# it is not obvious here that the function
# expects a real argument as a scalar (single value)

# in R should be explained in the documentation 
# for the function.

# in the C++ version we must clearly declare the types of arguments:

cppFunction('NumericVector relerrorC(double real, 
                                     NumericVector forecasts) {      
             int n = forecasts.size();
             NumericVector relerror(n);
              
             for(int i = 0; i < n; i++) {
              relerror[i] = fabs(real - forecasts[i])/real;
              }
              return relerror;
              }')

# This function introduces two new elements:
# - we create a new numeric vector with the length of n
#   using the constructor: NumericVector relerror(n);
#   Another convenient way to create a vector is copying
#   existing vector: NumericVector new = clone(existing).
# - if we want to calculate the absolute value in C++ and 
#   get the result of class double, we must use fabs() or
#   std::abs().
#   Using just abs() returns the value of the int type
#   - rounded to integer!
#   (in C++ there are several different functions for 
#   calculating the absolute value for different types 
#   of input data)

# see how functions work on artificially generated data

set.seed(1234556789)

r <- rnorm(1) # "real" value

f <- rnorm(100) # results of 100 "forecasts"

# lets check if result is the same

relerrorR(r, f)
relerrorC(r, f)  

identical(relerrorR(r, f),
          relerrorC(r, f))

# it is the same
  
benchmark("R" = relerrorR(rnorm(1), rnorm(100)),
          "C" = relerrorC(rnorm(1), rnorm(100)),
          replications = 50000
          )

# So, not always a function written in C++ will work
# (much) faster than its R equivalent.
# Even if it works several times faster, one needs
# to take into account tha writing a counterpart in C++
# also takes some time.

#-----------------------------  
# 5. matrix as a function argument

# Each vector type has its matrix equivalent:
# - NumericMatrix
# - IntegerMatrix
# - CharacterMatrix
# - LogicalMatrix

# let's create a C++ version of the colMeans(x) function, 
# which calculates mean separately for each column
# of a matrix or table
  
  cppFunction('NumericVector colMeansC(NumericMatrix x) {
              int nrow = x.nrow(), ncol = x.ncol();
              NumericVector colMeans(ncol);
              
              for (int j = 0; j < ncol; j++) {
                double total = 0;
                for (int i = 0; i < nrow; i++) {
                  total += x(i, j);
                  }
                colMeans[j] = total/nrow;
              }
              return colMeans;
              }')

# New elements in the above example:
# - in C++, we reference to the element/subset 
#    of a MATRIX with () and not [].
# - in C++, we use the .nrow() and .ncol() methods
#    to get dimensions of the matrix.

# check how the function works in C++ compared to R

# create a large matrix with 10 columns

x <- matrix(rnorm(5e6),
            ncol = 10)

colMeans(x)

colMeansC(x)

# results seem to be the same

identical(colMeans(x), colMeansC(x))

# but it is not the same - why?
# check the differences

colMeans(x) - colMeansC(x)

# there are differences, but only on the 17th place 
# after the comma which results from the differences 
# in rounding values in R and C++ (precision of storing
#  double values) - it's always worth checking when
# converting code between programming languages

benchmark("R" = colMeans(x),
          "C" = colMeansC(x),
          replications = 1000
          )

# here also the use of C++ does not help much - because
# the colMeans() function is already written in C++

#--------------------------------------------------------------------
# Using sourceCpp()

# Up to now we've created functions in C++ using cppFunction()
# This gives the C++ code presentation simplicity, but in practice 
# it also has disadvantages - eg lack of C++ syntax highlighting, 
# which would make the work easier.

# In practice, to define functions in R using C++ more conveniently
# one can save them in separate files (*.cpp) and compile
# "remotely" using the sourceCpp() function.


# CAUTION!
# to edit *.cpp files one can use RStudio !!!!
# choose File/New File/C++ File
# and look at the example script created
# (it is not saved yet, so there is no .cpp extension)

# we can also look into the file "myMeanC2.cpp"

# In the *.cpp file we have to put several lines of headings:

# #include <Rcpp.h>
# this command gives us access to the Rcpp functions.
# The "Rcpp.h" file contains a list of function and 
# class definitions provided by Rcpp.
# To refer to functions from the Rcpp package we can
# use the syntax: Rcpp::function_name

# using namespace Rcpp;
# this command loads the namespace of the Rcpp package,
# which allows avoid using Rcpp:: when referencing
# to the functions from this package 
#  - just the function_name will be enough

# Above EVERY function that we want to export
# / use in R, we add a tag:
# // [[Rcpp::export]]
# WARNING! space after // is NECESSARY!

# You can also embed the R code in special comment blocks
# inside the *.cpp file


# /*** R
# # This is R code
# */

# It is very convenient if after compiling the function
# and trensfering it to R we want to run the test code.


# lets load a function that calculates the average 
# and handles missing data using the vector function 
# is_na() from "sugar" Rcpp;
# is_na() takes the vector as its argument and returns 
# the logical vector (LogicalVector).

sourceCpp("myMeanC2.cpp")

# check how previously defined myMeanC() works 
# on missing data 

myMeanC(c(1:10, NA))

# returns a missing value

myMeanC2(c(1:10, NA))

# and this correctly handles missing values


##########################################################
# Exercises 12

# Exercise 12.1.
# For each function included in the file "Exercise1_functionsC.cpp":
# - try to recognize what are the equivalents of the following 
#   functions in base R
# - compare their time efficiency with base R functions
#  (Do not worry if you do not understand all the elements of the code)

setwd("/Users/rafalr/R Projects/Advanced-programming-in-R-2020L/Class materials/12_C++ in R")

sourceCpp("Exercise1_functionsC.cpp")

# f1() is an equivalent of R mean()

test <- c(1,3,4,5,6)

vector <- rnorm(n=10000)

benchmark(f1(vector),mean(vector), 
          replications = 10000)[, 1:4]

# f2() is an equivalent of R sum()
benchmark(f2(vector),mean(vector), 
          replications = 10000)[, 1:4]

# f2() is an equivalent of R sum()
benchmark(f2(vector),mean(vector), 
          replications = 10000)[, 1:4]

f3(c(1,2,5))

# Exercise 12.2.
# Convert the following R functions into equivalents written in C++.
# For simplicity, you can assume that the input data does not contain
# missing values.
# - min()
# - cummax().
# - range()

#min()
cppFunction(
  'double minC(NumericVector x){
  int n = x.size();
  double out = x[0];

  for (int i = 0; i < n; i++){
    out = std::min(out, x[i]);
  }

  return out;}
')


#cummax()
cppFunction(
  'NumericVector cummaxC(NumericVector x) {
  int n = x.size();
  NumericVector out(n);

  out[0] = x[0];
  for(int i = 1; i < n; ++i) {
    out[i]  = std::max(out[i - 1], x[i]);
  }
return out;
}'
)

#Range()
cppFunction(
  'NumericVector rangeC(NumericVector x){
  double omin, omax;
  int n = x.size();
  NumericVector out(2);

  omin = x[0];
  omax = x[0];

  for(int i = 1; i < n; i++){
      omin = std::min(x[i], omin);
      omax = std::max(x[i], omax);
  }

  out[0] = omin;
  out[1] = omax;
  return out;'
)

# Exercise 12.3.
# Write functions in R and C++ that calculate:
# - kurtosis based on the value vector: 
#   https://en.wikipedia.org/wiki/Kurtosis
# - factorial based on an argument being a natural number
#   https://en.wikipedia.org/wiki/Factorial


#factorial R
factoR <- function(n) {
  if( n <= 1) {
    return(1)
  } else {
    return(n * factoR(n-1))
  }
}
factoR(10)

# factorial in C

cppFunction(
  'int factoC(int n) { 
   if ((n==0)||(n==1))
      return 1; 
   else
      return n*factoC(n-1);
};'
)

#------------------------------------------------------------------------------
# Sources and additional materials:
# - official Rcpp website: http://www.rcpp.org/
# - Rcpp gallery: http://gallery.rcpp.org/
# - website of Dirk Edelbuettel: http://dirk.eddelbuettel.com/
# - Hadley Wickham "Advanced R": http://adv-r.had.co.nz/Rcpp.html
# - Masaki E. Tsuda "Rcpp for evertyone": https://teuder.github.io/rcpp4everyone_en/
# - Colin Gillespie, Robin Lovelace "Efficient R programming"
#   https://csgillespie.github.io/efficientR/rcpp.html
# - Rcpp intro: http://www.mjdenny.com/Rcpp_Intro.html
# - Dirk Eddelbuettel "Seamless R and C++, Integration" (2013)
#   https://github.com/jpneto/Markdowns/blob/master/benchmarking/Eddelbuettel%20-%20Seamless%20R%20and%20C++,%20Integration%20w.Rcpp%20(2013).pdf
# - stackoverflow: https://stackoverflow.com/questions/tagged/rcpp

# self-learning of C++
# - http://www.learncpp.com/ 
# - http://www.cplusplus.com/.
# - https://www.sololearn.com/Course/CPlusPlus/
