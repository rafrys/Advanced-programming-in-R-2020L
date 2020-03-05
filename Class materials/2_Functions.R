#---------------------------------------------------------#
#                 Advanced Programming in R               #
#                 2. Functional programming               #
#                  Academic year 2019/2020                #
#               Piotr Ćwiakowski, Piotr Wójcik            #
#---------------------------------------------------------# 

### 1. Introduction ------------------------------------------------------------

# Functions are very useful tool in programming. They help to:
# * organise your code, (by clustering repeating parts of code in blocks, 
#   distinguish parameters from algorithm, etc.)
# * DRY (Don't repeat yourself)
# * simplify it (by shortening the main source file and export given block 
#   of code to designated section or even another file)
# * make it easier to interpret (function can have names which should tell the 
#   developer what they do)

# Basic syntax:

# name_of_function <- function(arguments) {
#   >> do the math here <<
# return(result_of_doing_math_back_there)
# }

# If we skip the "return" part, function will return the 
# last value from the calculations. See Examples:

value1 <- function(n) {
  return(n)
  2
}
value1(3)

value2 <- function(n) {
  n
  2
}
value2(3)


my.function <- function(a, b, c) {
  a + b + c
}

my.function(1, 2, 3)

# We can assign result to some variable
result <- my.function(1, 2, 3)
result

# But what happen if arguments are not numbers? Let's try it:
my.function(1, 2, '3')

# Obviously we need defense programming here. We will go back to this later on,
# now below we present some very basic example:
my.function2 <- function(a, b, c) {
  if(class(a) == "numeric" & class(b) == "numeric" & class(c) == "numeric") {
    a * b + c
  }
  else {
    print("arguments of the function aren't all numeric")
  }
}

# Now let's run some tests:
my.function2(2, 2, 2)
my.function2(2, 2, "2")

# Let's notice, that our functions is vectorized
vector1 <- 1:5
vector2 <- 1:5
vector3 <- 1:5

# And test:
my.function3(vector1, vector2, vector3)

# Remember that arguments do have names:
f.example <- function(a1, a2, a3) {
  print(a2)
  print(a3)
}

# That they can have default values...
f.example <- function(a1 = 1, a2 = 5, a3 = 7) {
  print(a2)
  print(a3)
  print(a1)
}
f.example()


# We can also declare some argument optional:
f.example <- function(a1, a2, a3 = NULL){
  if(is.null(a3)){
    a1 + a2
  } else {
    a1 + a2 + a3
  } 
}

f.example(1, 2)
f.example(1, 2, 4)

# without it...
f.example <- function(a1, a2, a3){
  if(is.null(a3)){
    a1 + a2
  } else {
    a1 + a2 + a3
  } 
}
f.example(1, 2)

# however...
f.example <- function(a1, a2, a3){
  a1 + a2
}
f.example(1, 2)

# This is called lazy evaluation.

# Example of lazy evaluation in ggplot2:
library(ggplot2)

# This works:
ggplot(data = iris, aes(x = Sepal.Length, y = Sepal.Width, color = Species)) +
  geom_point()

# let's misspell name of one variable (on purpose) 
ggplot(data = iris, aes(x = Sepal.Length2, y = Sepal.Width, color = Species)) +
  geom_point()

# Former code result in error, but belowed does not:
p <- ggplot(data = iris, aes(x = Sepal.Length2, y = Sepal.Width, color = Species)) +
  geom_point()

# And now error is raised:
p

# You can check arguments of the function with args():
args(lm)
args(f.example)

# It's also possible to create generic functions:

# Let's study the example
x <- 1:100
y <- x^2

plot(x, y)
plot(x, y, type = 'l')

# We want line type to be default:
myplot <- function(x, y, type = "l") {
  plot(x, y, type = type, ...) # pass "..." to "plot" function
}

# Let's call the function
myplot(x, y)

# however, new function has a lot of limitation...
myplot(x, y, lwd = 4)

# ..which does not have original function
plot(x, y, lwd = 4, type = 'l') 

# Let's allow to have unlimited list of arguments
myplot <- function(x, y, type = "l", ...) {
  plot(x, y, type = type, ...) 
}

# now we can call myplot with argument lwd.
myplot(x, y, lwd = 2, col = 'red')

# Another application of '...'
sum1 <- function(...) {
  s <- 0
  arguments <- list(...) # arguments for the list
  for (i in 1:length(arguments)) {
    s = s + arguments[[i]]
  }
  return(s)
}

sum1(1, 2)
sum1(1, 2, 3)


# Problems

# 1. Write a function which computes for a given vector of numbers mean absolute
# deviation: https://en.wikipedia.org/wiki/Median_absolute_deviation

# 2. Write a function which computes coefficient of variation:
# https://en.wikipedia.org/wiki/Coefficient_of_variation

# For test use following data:
library(MASS)
data(survey)

# 3. Review the code of the previous function. Include following functionalities:
# a) parameter, which allows user to decide, wheter result will be printed as 
#    fraction or in percentages points.
# b) ability to control, whether NA's are included in computations.
# c) write to versions of the function:
#     c1) first should work with vectors, thus:
      cv_user(survey$Age)
#     c2) second should work with dataframe, thus
      cv_user(survey, 'Age')

# 4. Consider further extension of the function. Write a procedure, which will
# computes coefficient of variation of given continuous variable in subsamples 
# divided with respect to some given nominal variable. 
cv.user(survey, 'Age', 'Sex')

# Variant 1.
# Use for loop and function unique()


# Variant 2.
# Use split() function and for loop


# 4. Write a function, which will work with any dataset (let’s say a data.frame object) and for each integer
# variable in the database create a boxplot, for numeric variable histogram, and for factor variables barplot.
# For testing process you can use Cars93 database.
library(MASS)
data <- Cars93



# 5. Write a function, which will divide dataset with respect to some
# nominal variable and run regression with given formula for each subset.
# Function should return a list with a results of regression for each subset
