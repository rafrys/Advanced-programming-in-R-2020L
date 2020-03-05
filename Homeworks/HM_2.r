#---------------------------------------------------------#
#                Advanced Programming in R                #
#     Homework for Laboratory 2. Functional programming   #
#                 Academic year 2019/2020                 #
#                 Rafal Rysiejko, 423827                  #
#---------------------------------------------------------# 



# Problems

# 1. Write a function which computes for a given vector of numbers mean absolute
# deviation: https://en.wikipedia.org/wiki/Median_absolute_deviation

mad <- function(vector) {
  if (is.numeric(vector)) {
    med <- median(vector)
    res <- c()
    for (i in 1:length(vector)) {
      res <- c(res, abs(vector[i] - median(vector)))
    } 
    return(median(res))
  } else {
    print("Supplied vecotor need to be of a numeric type!")
  }
}

vec <- c(7, 3, 10, 10, 8, 8, 15)
mad(vec)


# 2. Write a function which computes coefficient of variation:
# https://en.wikipedia.org/wiki/Coefficient_of_variation

coeff <- function(vector,i) {
  if (is.vector(vector)) {
    return(round(sd(vector)/mean(vector),i))
  } else {
    print("Supplied vecotor need to be of a numeric type!")
  }
}

vec <- c(7, 3, 10, 10, 8, 10, 15)
coeff(vec,2)

# For test use following data:
library(MASS)
data(survey)

# 3. Review the code of the previous function. Include following functionalities:
# a) parameter, which allows user to decide, wheter result will be printed as 
#    fraction or in percentages points.
# b) ability to control, whether NA's are included in computations.
# c) write two versions of the function:
#     c1) first should work with vectors, thus:

cv_user<- function(x,na.rm=FALSE,output="fraction"){
  if (is.vector(vector)) {
    res <- sqrt(var(x, na.rm = na.rm))/mean(x, na.rm = na.rm)
  } else {
    print("Supplied vecotor need to be of a numeric type!")
  }
  if (output == "fraction") {
    return(MASS::fractions(res))
  }else if (output=="percentage") {
    return(round(res,2)*100)
  }else {
    return("Incorect output parameter specified")
  }
}  

cv_user<- function(x,na.rm=FALSE,output="fraction"){
if(is.vector(x)) {
  res <- sqrt(var(x, na.rm = na.rm))/mean(x, na.rm = na.rm)
  if(output == "fraction") {     
    return(fractions(res))
  } else if(output=="percentage"){            
    return(paste0(round(res,4)*100,"%"))
  }
} else {            
  print("Supplied data needs to be of a vector type!")
  }
}

cv_user(survey$Age)
cv_user(survey$Age,output = "percentage")

#     c2) second should work with dataframe, thus
cv_user<- function(x,column="Age",na.rm=FALSE,output="fraction"){
  if(is.data.frame(x))  {
    res <- sapply(x[column], sd, na.rm = na.rm)/sapply(x[column], mean, na.rm = na.rm)
    if(output == "fraction") {     
      return(fractions(res))
    } else if(output=="percentage"){            
      return(paste0(round(res,4)*100,"%"))
    }
  } else {            
    print("Supplied data needs to be of a data.frame type!")
  }
}

cv_user(survey, 'Age')
cv_user(survey, 'Age',output = "percentage")


# 4. Consider further extension of the function. Write a procedure, which will
# computes coefficient of variation of given continuous variable in subsamples 
# divided with respect to some given nominal variable. 
cv.user<- function(x,column="Age",subset="Sex",na.rm=FALSE,output="fraction"){
  if(is.data.frame(x))  {
    res <- c()
    for (i in unique(survey[subset])) {
      res <- c(res,mean(filter(survey[column], survey[subset]==i)))
    }
    if(output == "fraction") {     
      return(fractions(res))
    } else if(output=="percentage"){            
      return(paste0(round(res,4)*100,"%"))
    }
  } else {            
    print("Supplied data needs to be of a data.frame type!")
  }
}



mean(filter(survey["Age"], survey["Sex"]=="Female"))

survey["Sex"]==temp[1,]
temp <- unique(survey["Sex"])
temp <- data.frame(temp,stringsAsFactors = F)
typeof(temp)
temp[1,]

cv.user(survey, 'Age', 'Sex')

# Variant 1.
# Use for loop and function unique()


# Variant 2.
# Use split() function and for loop


# 4. Write a function, which will work with any dataset (let’s say a data.frame object) and for each integer
# variable in the database create a boxplot, for numeric variable histogram, and for factor variables barplot.
# For testing process you can use Cars93 database.

library(tidyverse)
x <- Cars93

plotly <- function(data){
for (i in 1:ncol(data)) {
  if (is.integer(data[,i])) {
    boxplot(data[,i])
  } else if (is.numeric(data[,i])) {
    hist(data[,i])
  } else if (is.factor(data[,i])) {
    barplot(table(data[,i]))
  }
}
}

plotly(x)

# 5. Write a function, which will divide dataset with respect to some
# nominal variable and run regression with given formula for each subset.
# Function should return a list with a results of regression for each subset
