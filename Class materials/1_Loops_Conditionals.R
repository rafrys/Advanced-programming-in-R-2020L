#---------------------------------------------------------#
#                Advanced Programming in R                #
#          Laboratory 1: loops and if statement           #
#                 Academic year 2019/2020                 #
#             Piotr Ćwiakowski, Piotr Wójcik              #
#---------------------------------------------------------# 

## 1. If statement: ---------------------------

# One of the core aspects of programming (in any language) is the use of
# the if statements. Depending on what logical value we want to get, we want
# our program to do one or another set of instructions.

## 1.1 The if instruction,
# Syntax: if ( condition ) { what if YES } else { what if NO }
# Syntax for if statement with multiple conditions :
# if ( CONDITION1 ) { what if YES } else if ( CONDITION2 ) { what if YES} else if ... else 
# { what in this case }

### Relational and logical expressions - reminder:
# ==
# !=
# <=
# <
# >=
# >
# &
# |

# Let's remind that in R we use | symbol for disjunction (fot vectors)
# or || (for single values), and & adn && for conjunction. Of course,
# we can use these symbols alternatively for one-element vectors.
# We can also use the all() and any() function meaning respectively
# conjunction and disjunction for more than two conditions.

c(TRUE, FALSE) | c(FALSE, FALSE) # vectorized (each element in A is compared to each in B)
c(TRUE, FALSE) & c(FALSE, TRUE)

c(TRUE, FALSE) || c(FALSE, FALSE)  # not vectorized (all elements must match each other to return T)
c(TRUE, FALSE) && c(FALSE, TRUE)
c(TRUE, FALSE) && c(TRUE, TRUE)

all(any(1 + 2 == 3, 2 + 3 == 4, 3 + 4 == 5), 2 + 3 == 5, 3 + 4 == 7)


if (2 + 2 == 4 | 1 + 3 == 5) "Hello" else "World"
if (2 + 2 == 4 & 1 + 3 == 5) "Hello" else "World"

# Other examples
a <- 3
b <- 1
c <- 4

matrix1 <- matrix(0, nrow = 5, ncol = 2)
matrix1

if (a == 3) {
  matrix1[a, 1] <- 100
  }
matrix1

if (a == 3) matrix1[a, 1] <- 100

if (a == 3) 
  matrix1[a, 1] <- 500

if (b != 2) {
  matrix1[a, 1] <- 101
}
matrix1

if (a == 4 | (b == 1 & c == 4)) {
  matrix1[a, 1] <- 105
}
matrix1


## Exercise 1 ##

# Write if statement, which will return sum of a and b variables (if they are 
# numbers), or their concatenation (if they are strings) and "error" in other 
# cases.
# Tip: concatenation function is paste0()

a = "foo"
b = "xd"

if (is.numeric(a) & is.numeric(b)) {
print(sum(a,b))
} else if (is.character(a) & is.character(b)) {
  print(paste0(a,b))
} else  {
  print("error")
}



## 1.2. ifelse function - vectorised equivalent
# ifelse({condition}, {what if YES}, {what if NO})
# Result is a vector with the same dimensions as the one in the condition.

# Example:
ifelse(c(1:5) %% 2 == 1, "odd", "even")
# Symbol x %% y = x mod y:
8 %% 2
7 %% 3


## 2. For loop -----------------------------------------------------------------

# Syntax:
# for (i in {set of indices}){ COMMAND }

# Literally: for i = 1 to 10 make operations inside the loop (limited by brackets)
vector <- 1:10

for(i in 1:10) {
  # vector
  # commands in loop, for example:
  print(vector)
}

for(i in 1:10) {
  print(vector[i])
}

wek <- 1:20
wek
for(i in 1:25) {
  print(wek[i])
}

# we can limit our condition so it will work the way we want it to work
interesting_numbers <- c(2, 8, 14, 20)

# We can iterate over value of vector
for(i in interesting_numbers) {
  print(wek[i])
}

# or along the vector
for(i in seq_along(interesting_numbers)) {
  print(wek[i])
}

# we can select values manually
for(i in c(2, 8, 14, 20)) {
  print(wek[i])
}


# or increase by 2
for(i in seq(1, length(wek), by = 2)){ 
  print(wek[i])
}

# or iterate with characters
for(i in letters){ 
  print(paste0('section_',i))
}

# break instruction breaks loop:
for(i in 1:25) {
  
  if (i > 10) {
    print('Loop is broken!')
    break
  }
  print(wek[i])
  
}

# next instruction skip the rest of the code and move to the next iteration:
for(i in 1:25) {
  
  if (i > 10) {
    print('move to the next iteration')
    next
  }
  print(wek[i])
  
}

# Loops can be nested:
matrix1 <- matrix(0, 10, 2)
number <- 1

for(i in 1:10){
  for(j in 1:2){
    matrix1[i,j] <- number
    number <- number + 1
  }
}
matrix1

# in loops is very covienient to use placeholders:
#install.packages('stringr')
library(stringr)

for (i in 1:10){
  print(str_interp('This is placeholder: ${i}'))
}

## Exercise 2 ## 
# Write a loop, which will work with any dataset (which is a data.frame object) 
# and for each integer variable in the database create a boxplot, for numeric 
# variable histogram, and for factor variables barplot. For testing process you 
# can use Cars93 database.
library(MASS)
library(tidyverse)
data <- Cars93

for (i in 1:ncol(data)) {
  if (is.integer(data[,i])) {
    boxplot(data[,i])
  } else if (is.numeric(data[,i])) {
    hist(data[,i])
  } else if (is.factor(data[,i])) {
    barplot(table(data[,i]))
  }
}

# Or 

for (i in names(data)) {
  x <- data[,i]
  if (is.integer(x)) {
    boxplot(data[,i],main=i)
  } else if (is.numeric(x)) {
    hist(data[,i],main=i)
  } else if (is.factor(x)) {
    barplot(table(x),main=i)
  }
}




# 3. While loop ----------------------------------------------------------------
# Syntax:
# while( CONDITION ){ COMMAND }
# Literally: do COMMAND while CONDITION is TRUE.
# While loop, in order to be finite, has to have some fragment of code in the COMMAND section, 
# which influences the CONDITION. Otherwise we will get a infinite loop 
# (if the initial CONDITION was meet).

# Example:

n <- 0
while(n < 10) {
   print(n)
   n <- n + 1
}

# Example if inifinte loop:
while(TRUE) {print("click ESC")}



# 4. Repeat loop ------------------------------------------------------------------

# infinite loop

repeat{
  print('Infinite loop, press ESC')
}

# 5. Family of apply functions 
# 
# In statistical programming, loops are usually over elements of certain objects: 
# matrixes or data.frames. To iterate over rows, columns or elements of object we 
# can use apply function. They are faster and offer shorter syntax (albeit less 
# intuitive).

# Apply functions forms family of functions, starting from basic apply to more
# specialised. The most prevalent functions are:

# 1. apply
# 2. lapply
# 3. sapply
# 4. vapply
# 5. tapply
# 6. mapply

# Let's see examples of each and 

# 4.1. apply
# Loop which applies a function to rows or columns of a table.

# Usage:
# apply(X, MARGIN, FUN, ...)

# X - object with margins - rows and columns
# margin - types of margin - rows (1) or columns (2)
# FUN - function to be performed on each element of given dimention (margin)
# ... - aditional arguments of function

# Example:
table <- cbind(c(1:8),c(10:17),c(15:8))

apply(table, 1, mean) # mean of each row
apply(table, 2, max)  # max of each column

# Very often in apply is umpelemented anonymous function - written 'on the run'.
table2 <- apply(table, 1:2, function(x) x^2-x/exp(x)) 

# Print results
table2

# Of course we could use vectorised operations:
table3 <- table^2-table/exp(table)

# But this is not always the case. LEt's compare objects.
table2 == table3
identical(table2, table3)

# Let's examine a function which returns a vector:
apply(table,1,range)


# 4.2. lapply function
# lapply() function works with lists, applying to each element a uer-defined or
# built-in function. The return object is a list

# Usage:
# lapply(list, FUN,...)

# Arguments:
# list - an object which is list (so data.frame can be used!!)
#  ... additional parameters of a function

# Example.
# Let's define a list:
L <- list(a = c(1, 2), 
          b = c(3, 5, 7)
)
# Apply sinus function to list elements:
L2 <- lapply(L, sin)

# Investigating result
L2

# Another example with anonymuos function:
L3 <- lapply(L, function(x) {x^2}) 
L3

# And even with function return one value... 
L4 <- lapply(L,mean)
#... result is still a list 
L4 

# Here a magical function:
unlist(L4)

# In the end let's look at the function with additional arguments:
lapply(1:4, runif, min = 0, max = 10) 

#######################################################
# 4.3. sapply
# Sapply is simplified lapply function. Function returns:
# 1. Vector, if all elements of the result are single values
# 2. Matrix if all elements of the result have the number of values.
# 3. List otherwise.

# Objects for examples:
L0 <- list(a = 1, b = 3)
L1 <- list(a = c(1, 2), b = c(5, 6))
L2 <- list(a = c(1, 2, 3), b = c(5, 6))

# Examples
W0 <- sapply(L0, function(x) { x^3 })
W1 <- sapply(L1, function(x) { x^3 })
W2 <- sapply(L2, function(x) { x^3 })

# Let's analize results:
is.vector(W0);W0
is.matrix(W1);W1
is.list(W2);W2

# If we want ordinary lapply() we can set simplify = F 
W <- sapply(L, function(x){x^3}, simplify = F); W # list
W1 <- sapply(L1, function(x){x^3}, simplify = F); W1 # list
W2 <- sapply(L2, function(x){x^3}, simplify = F); W2 # list


################################################################################
# Exercise. 
# 
# 1. Based on state.x77 dataset find average, median, max i min for each column. 
# Present results in one matrix.


# 2. Use lapply function to log every numeric variable in iris dataset. Save the 
# result (transformed and non-transformed variables) in:
# a. list
# b. data.frame


# 3. Used split() and interaction function to split diamonds dataset with respect to
# two categorical variables: color and cut. Then:
library(ggplot2)
data(diamonds)
head(diamonds)

data.list <- split(diamonds, interaction(diamonds$cut, diamonds$color))
# a. for each element perform a regression: price ~ carat. Save the results in the list

# b. for each model generate summary and save result in another lists.

# c. for each model generate histogram of residuals, or any other graph.

# d. extract coefficients from each model and save it in one big matrix.


# 4. Suppose, you have dataset with information about height and sex of a person.
# Compute conditional mean, median, var and sd for each sex.. 

# Examplary data:
Height <- rnorm(100, mean=170, sd=10)
Woman <- factor(floor(2*runif(100)))
d <- data.frame(Woman, Height)



# 4b. Use different function and repeat exercises for each Species in iris dataset.


# 5. Generate a list of 100 vectors: c(1), c(1,2), c(1,2,3), ... , c(1,...,100)

