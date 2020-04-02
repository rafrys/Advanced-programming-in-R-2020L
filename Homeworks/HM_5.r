#-------------------------------------------------------------#
#                  Advanced Programming in R                  #
#     Homework for Laboratory 5: Object oriented programming  #
#                  Academic year 2019/2020                    #
#                  Rafal Rysiejko, 423827                     #
#-------------------------------------------------------------# 

#--------------------------------------------------------------
# Exercise 5.1
# Check which method are defined for 
# a generic function predict()?

methods(predict)
#--------------------------------------------------------------
# Exercise 5.2
# Create a generic function add_all(), then the
# defaults method and two additional methods:
# - add_all.numeric() returning the sum of all elements
#   if argument is numeric - use the function sum()
# - add_all.character() returning concatenation of all elements
#   if argument is character - use the function paste()

add_all <- function(x) {
  UseMethod("add_all")
}

add_all.default <- function(x) {
  cat("This is a generic function")
}

add_all.numeric <- function(x) {
  result = sum(x)
  structure(result, class = "numeric")
}

add_all.character <- function(x) {
  result = cat(x,"\n")
  structure(result, class = "character")
}

methods(class = "add_all")

x <- c(1,2,3)
y <- c("x","d")

add_all(x)
add_all(y)
#--------------------------------------------------------------
# Exercise 5.3
# Create a new class "student" and two sample objects of this class.
# Let objects of class "student" have the following fields:
# first_name, last_name, student_id, year, grades (numeric vector)
# and seminar (logical value).
# Define methods:
# - average - calculating the average grade,
# - information - displaying first name, last name 
#   and student IS number (in the parentheses)

student <- function(first_name, last_name, student_id, year, grades,seminar) {
  new_object <- list(first_name = first_name,
                     last_name = last_name,
                     student_id = student_id, 
                     year = year,
                     grades = grades,
                     seminar,seminar)
  # assign a class attribute by calling the structure function
  structure(new_object, class = "student")
}

v1 <- student("John",
              "Doe",
              123,
              4,
              c(4,4,4.5,5),
              TRUE)

v2 <- student("Jone",
              "Doe",
              321,
              3,
              c(4,5,5,5),
              FALSE)
class(v1)
class(v2)

average <- function (x) {
  UseMethod("average")
}

average.student <- function(x) {
  result = round(mean(x$grades,na.rm = T),2)
  structure(result, class = "student")
}

average(v2)
##############
information <- function (x) {
  UseMethod("information")
}

information.student <- function(x) {
  cat("Full name:", x$first_name, x$last_name,"\n")
  cat("Student ID:", paste0("(",x$student_id,")"),"\n")
}

information(v2)

 #--------------------------------------------------------------