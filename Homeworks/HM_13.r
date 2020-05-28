#---------------------------------------------------------#
#                Advanced Programming in R                #
#              13. RCpp2: advanced usage of Rcpp          #
#                 Academic year 2019/2020                 #
#                 Rafal Rysiejko, 423827                  #
#---------------------------------------------------------# 


#-----------------------------------------------------
# Exercises 13.


# Exercise 13.1
# Write an R and two variants of C++ function 
# (without and with sugar approach):
# rootCpp(x, n) that will
# calculate the root of order n (integer) from the value
# of x (double) - hint: use the C++ function pow(x, n) 
# Let the default value of n be 2.
# Apply the function(s) to sample values and compare 
# their results and efficiency.

cppFunction("double rootCpp(double x,double n=2) {
              double result = x*(1/n);
              return result;
             }")


cppFunction("double rootCppR(double x,double n=2) {
              return pow(x, (1/n));
             }")

rootR <- function(x,n=2){
  x**(1/n)
}


r <- rnorm(1) # "real" values
n <- 2

benchmark("rootR" = rootR(r, n),
          "rootCpp" = rootCpp(r, n),
          "rootCppR" = rootCppR(r, n),
          replications = 50000)[, 1:4]

identical(rootR(r, n),rootCpp(r, n))
identical(rootR(r, n),rootCppR(r, n))
identical(rootCpp(r, n),rootCppR(r, n))

# Exercise 13.2
# Write a version of colCVsCpp() handling missing values 
# using Rcpp sugar


cppFunction('NumericVector colCVsCppSugar(NumericMatrix x) {
               int n = x.nrow(), ncol = x.ncol();
               // matrix for squared values of x
               NumericMatrix x2(n, ncol);
               NumericVector means_x(ncol), means_x2(ncol), 
                             sds(ncol), colCVs(ncol);
               // raise all elements of matrix x to power 2
               // loop over columns, but pow() works on vectors now
               for (int j = 0; j < ncol; j++) {
                  // how to refer to a single column/row from a matrix
                  x2( _ , j ) = pow(na_omit(x( _ , j )), 2);
              }
               // then sugar function colMeans() used
               means_x = colMeans(x);
               means_x2 = colMeans(x2);
               sds = sqrt( double(n)/(n-1) * (means_x2 - pow(means_x, 2.0)));
               colCVs = 100 * sds/means_x;
              
               return(colCVs);
            }')

m <- matrix(rnorm(5e5),
                     ncol = 10)

m[c(3, 5, 9)] <- NA

colCVsCppSugar(m)

# Exercise 13.3
# Using Rcpp sugar write a function any_naCpp(v)
# returning a logical value "true" if a numeric 
# vector (the only input) contains any missings
# and "false" otherwise.

cppFunction('LogicalVector any_naCpp(NumericVector x) {
                return any(is_na(x));
             }')

val <- rnorm(10)
any_naCpp(val)

val[c(3, 5, 9)] <- NA
any_naCpp(val)

# Exercise 13.4
# Write a cpp function basicStatsCpp(df) that based 
# on a data frame calculates for each column 
# (assuming for simplicity that each column is numeric)
# basic statistical measures:
# min, mean, n_nonmiss, max, sd
# and returns them as a list or a data.frame



cppFunction('DataFrame basicStatsCpp(NumericMatrix x) {
                             int n = x.nrow(), ncol = x.ncol();
                             NumericMatrix x2(n, ncol);
                             NumericVector means_x(ncol), means_x2(ncol), 
                                           sds(ncol), colCVs(ncol),mins(ncol),
                                           maxs(ncol),n_nonmiss(ncol);
                             // raise all elements of matrix x to power 2
                             // loop over columns
                             for (int j = 0; j < ncol; j++) {
                          	   x2( _ , j ) = pow(x( _ , j ), 2);
                                mins(j)=min(x(_,j));
                                maxs(j)=max(x(_,j));
                                n_nonmiss(j)= sum(!is_na(x(_,j)));
                          	   }
                             means_x = colMeans(x);
                             means_x2 = colMeans(x2);
                             sds = sqrt( double(n)/(n-1) * (means_x2 - pow(means_x, 2.0)) );
                             colCVs = 100 * sds/means_x;
                             
                             DataFrame result = DataFrame::create(Named("means") = means_x,
                                                                  _["sds"] = sds,
                                                                  _["min"] = mins,
                                                                  _["max"] = maxs,
                                                                  _["n_nonmiss"] = n_nonmiss);
                             return(result);
            }')

#---

basicStatsCpp(m)

