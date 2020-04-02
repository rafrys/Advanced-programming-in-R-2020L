#---------------------------------------------------------#
#                Advanced Programming in R                #
#              6. Object oriented programming             #
#                 Academic year 2019/2020                 #
#                 Rafal Rysiejko, 423827                  #
#---------------------------------------------------------# 
library(pryr)
# Exercises 6

# Exercise 6.1
# (partial equivalent of the Exercise 5.3 from previous lab)
# Create a new class "student4" and two sample objects of this class.
# Let objects of this class have fields describing: 
# first_name, last_name, student_id, year, grades (numeric vector)
# and seminar (logical value).
# WARNING! DO NOT verify the correctness of the data.

student4 <- setClass("student4",
                    slots = list(first_name = "character",
                                 last_name = "character",
                                 student_id = "numeric", 
                                 year = "numeric",
                                 grades = "numeric",
                                 seminar="logical"))

s1 <- student4(first_name = "Jon",
               last_name = "Snow",
               student_id = 123, 
               year = 4,
               grades = c(4,5,4,3),
               seminar=T)

s2 <- student4(first_name = "Harry",
               last_name = "Potter",
               student_id = 321, 
               year = 3,
               grades = c(5,5,3,4),
               seminar=F)


# Exercise 6.2 
# Modify the class definition for "student4" adding the check of validity:
# - year - should be integer number from the range 1-5
# - student_id - should be a character string of exactly 6 characters
# - grades - should be a numeric vector of length 10 with
#            possible values: 2, 2.5, 3, 3.5, 4, 4.5, 5, NA

student4 <- setClass("student4",
                     slots = list(first_name = "character",
                                  last_name = "character",
                                  student_id = "character", 
                                  year = "integer",
                                  grades = "numeric",
                                  seminar="logical"),
                     validity = function(object)
                     {
                       if(object@year < 0 || object@year > 5) return("Age should be in range from 1 to 5 ")
                       if(!nchar(object@student_id)==6) return("Student ID should have exactly 6 characters")
                       if(!all(object@grades %in% c(2, 2.5, 3, 3.5, 4, 4.5, 5, NA))) return('Incorrect grades. Possible values: 2, 2.5, 3, 3.5, 4, 4.5, 5, NA')
                       if(!length(object@grades)==10) return ("Student should have exactly 10 grades")
                       return(TRUE)
                     })

s1 <- student4(first_name = "Jon",
               last_name = "Snow",
               student_id = 123, 
               year = 4,
               grades = c(4,5,4,3),
               seminar=T)

s1 <- student4(first_name = "Jon",
               last_name = "Snow",
               student_id = "123456", 
               year = 4L,
               grades = c(4,5,4,3,2,4,5,3,2,5),
               seminar=T)

s2 <- student4(first_name = "Harry",
               last_name = "Potter",
               student_id = "654321", 
               year = 3L,
               grades = c(5,5,4,3,2,4,5,3,5,5),
               seminar=F)


# Exercise 6.3
# For objects of student4 class define methods:
# - average - calculating the average grade,
# - information - displaying first name, last name 
#   and student ID number (in the parentheses)

setGeneric(name = "average",
           def = function(x) {
             standardGeneric("average")
           })

average

showMethods(average)

setMethod("average",
          signature = "student4",
          definition = function(x) mean(x@grades,na.rm = T)
)
average(s1)
###################
setGeneric(name = "information",
           def = function(x) {
             standardGeneric("information")
           })

information

showMethods(information)

setMethod("information",
          signature = "student4",
          definition = function(object) {
            cat("Full name:", object@first_name, object@last_name,"\n")
            cat("Student ID:", paste0("(",object@student_id,")"),"\n")
          }
)
information(s2)

# Exercise 6.4
# Define a generic function compare_averages() and an appropriate
# method for objects of class `student4` that will show
# information which of the two compared students 
# (first_name, last_name and student_id) has higher average.

setGeneric("compare", 
           # lets define two arguments
           # (objects for comparison)
           function(x, y) standardGeneric("compare"))

compare

# and the method for two clients

setMethod("compare", 
          # here classes of required input objects are defined
          signature = c("student4", "student4"),
          definition = function(x, y) {
            cat(x@first_name, x@last_name,paste0("(",x@student_id,")"), "has",
                ifelse(mean(x@grades,na.rm = T) == mean(y@grades,na.rm = T),"the same GPA as", 
                       ifelse(mean(x@grades,na.rm = T) > mean(y@grades,na.rm = T), "higher GPA","lower GPA")),
                y@first_name, y@last_name,paste0("(",y@student_id,")"), "\n")
          })
compare(s1, s2)

