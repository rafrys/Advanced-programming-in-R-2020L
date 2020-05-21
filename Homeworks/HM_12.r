#---------------------------------------------------------#
#                Advanced Programming in R                #
#              12. C++ in R                               #
#                 Academic year 2019/2020                 #
#                 Rafal Rysiejko, 423827                  #
#---------------------------------------------------------# 

# Exercises 12

# Exercise 12.1.
# For each function included in the file "Exercise1_functionsC.cpp":
# - try to recognize what are the equivalents of the following 
#   functions in base R
# - compare their time efficiency with base R functions
#  (Do not worry if you do not understand all the elements of the code)

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
