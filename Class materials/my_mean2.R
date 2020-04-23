my_mean2 <- function(x) {
  result <- NA
  n <- length(x)
  for(i in 1:n)
    result <- sum(result, x[i], na.rm = TRUE)
  result <- result/n
  return(result)
}