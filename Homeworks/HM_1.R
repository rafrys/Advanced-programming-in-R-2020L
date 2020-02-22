#---------------------------------------------------------#
#                Advanced Programming in R                #
#     Homework for Laboratory 1: loops and if statement   #
#                 Academic year 2019/2020                 #
#             Rafal Rysiejko, 423827                      #
#---------------------------------------------------------# 

library(data.table)
library(tidyverse)
library(psych)
library(pastecs)

data <- as.data.frame(state.x77)
################################################################################
# Exercise. 
# 
# 1. Based on state.x77 dataset find average, median, max i min for each column. 
# Present results in one matrix.

psych::describe(data)[c(3,5,9,8)]

# 2. Use lapply function to log every numeric variable in iris dataset. Save the 
# result (transformed and non-transformed variables) in:
# a. list
# b. data.frame
iris <- iris

output_list <- c(iris,lapply(iris[,1:4], log))
output_df <- cbind(iris,lapply(iris[,1:4], log))


# 3. Used split() and interaction function to split diamonds dataset with respect to
# two categorical variables: color and cut. Then:
library(ggplot2)
data(diamonds)
head(diamonds)

data.list <- split(diamonds, interaction(diamonds$cut, diamonds$color))

models <- lapply(varlist, function(x) {
  lm(price ~ carat, data=data.frame(price=data.list[[x]][7], carat=data.list[[x]][1]))
})


# a. for each element perform a regression: price ~ carat. Save the results in the list

models <- lapply(varlist, function(x) {
  lm(price ~ carat, data=data.frame(price=data.list[[x]][7], carat=data.list[[x]][1]))
})

# b. for each model generate summary and save result in another lists.
summaries <- lapply(models, summary)

# c. for each model generate histogram of residuals, or any other graph.

lapply(lapply(models, resid), hist)
# d. extract coefficients from each model and save it in one big matrix.

coefmat <- lapply(summaries, '[[', 'coefficients')

# 4. Suppose, you have dataset with information about height and sex of a person.
# Compute conditional mean, median, var and sd for each sex.. 

# Examplary data:
Height <- rnorm(100, mean=170, sd=10)
Woman <- factor(floor(2*runif(100)))
d <- data.frame(Woman, Height)

condiitonal_summary <- function(data, sex){
  pastecs::stat.desc(d$Height[d$Woman == sex])[c(9, 8, 12, 13)]
  }

condiitonal_summary(d,1) # for women
condiitonal_summary(d,0) # for men

# 4b. Use different function and repeat exercises for each Species in iris dataset.
for (i in unique(iris$Species)){
  print(str_interp('Summary for: ${i}'))
  print(round(pastecs::stat.desc(iris[iris$Species == i,])[c(9, 8, 12, 13),c(1:4)],2))
  cat("\n")
}

# 5. Generate a list of 100 vectors: c(1), c(1,2), c(1,2,3), ... , c(1,...,100)
list <- lapply(1:100, seq)
 