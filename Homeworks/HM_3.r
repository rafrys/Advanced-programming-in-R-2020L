#---------------------------------------------------------#
#                Advanced Programming in R                #
# Homework for Laboratory 3. Functional programming part 2#
#                 Academic year 2019/2020                 #
#                 Rafal Rysiejko, 423827                  #
#---------------------------------------------------------# 




# Exercise 1.
# In below function formula for RMSLE  is implemented:

my_rmsle <- function(y, pred) {
  # Formula available here:
  # https://www.kaggle.com/c/ashrae-energy-prediction/discussion/113064
  sqrt(sum((log(pred + 1)-log(y + 1))**2)/length(y))
}

# - add assertions checking the correctness of type and class of input data,
# - add assertions checking the correctness of values (should be greater than zero)
# - add handling of missing data (display information about the number
#   of missing observations, eliminate them from the calculation),
# - display a warning if the number of non-missings is greater than 5.
# - add assertions checking equal length of vectors before and after eliminating missing data


my_rmsle <- function(y, pred) {
  assert_that(is.numeric(y) & is.numeric(pred), msg = 'Supplied arguments need to be of a numeric type')
  assert_that(all(y > 0 & pred > 0),msg='Values should be greater than 0')
  assert_that(length(y) == length(pred), msg = 'Unequal number of actual and predicted values')
  message("Number of missing observations: ", sum(is.na(y),is.na(pred)))
  y <- y[!is.na(y)]
  pred <- pred[!is.na(pred)]
  assert_that(length(y) == length(pred), msg = 'Unequal number of actual and predicted values')
  if (length(y) + length(pred) > 5) {
    warning('Number of non-missings is greater than 5.')
  }
  sqrt(sum((log(pred + 1) - log(y + 1)) ** 2) / length(y))
}

y <- c(2,4,1,NA,1,5,2.4,8,9,NA)
pred <- c(1,3,0.4,NA,2,6,3,10,11,NA)
my_rmsle(y, pred)


y <- c('2',4,1,1,5,2.4,8,9)
pred <- c(1,3,0.4,2,6,3,10,11)
my_rmsle(y, pred)

y <- c(2,4,1,1,5,2.4,8,9)
pred <- c(1,3,0.4,2,6,3,10,11)
my_rmsle(y, pred)

# Exercise 2.
# Write a function which computes glm logistic model, prints summary of the model and
# returns invisibe object of the model. 

mydata <- mtcars

glm_fun <- function(formula, data) {
  model <- glm(formula, data=data)
  invisible(model)
  print(summary(model))
}

glm_fun(mpg ~ cyl+disp+hp, mydata)

output <- glm_fun(mpg ~ cyl+disp+hp, mtcars)
output

#Cstack_info()