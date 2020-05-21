#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
double myMeanC2(NumericVector x) {
  int n = x.size(), nonmiss = 0;
  // is_na() is a sugar function, which takes 
  // a vector and returns a logical vector
  LogicalVector x_nonmiss = is_na(x);
  double total = 0;
  
  for(int i = 0; i < n; i++) {
	  if(!x_nonmiss[i]) {
		  nonmiss++;
		  total += x[i];}
  }
  return total / nonmiss;
}

/*** R
library(rbenchmark)
x <- runif(1e6)
benchmark("R" = mean(x),
          "C" = myMeanC2(x),
		  replications = 500
)
*/
