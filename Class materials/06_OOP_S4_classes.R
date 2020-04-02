#---------------------------------------------------------#
#                 Advanced Programming in R               #
#              6. Object oriented programming             #
#                        S4 system                        #
#                  Academic year 2019/2020                #
#               Piotr Wójcik, Piotr Ćwiakowski            #
#---------------------------------------------------------# 

library(pryr)

#-----------------------------------------------------------------------
# S4 classes

# S4 classes are an improvement over S3 classes.
# They have a formally defined structure, which helps
# in creating objects of the same class that look 
# more or less similar.

# The classes of the S4 system are more rigorous, thanks 
# to this prevent the user from accidentally making simple 
# mistakes (e.g. "accidental" change of object class).

# Classes in the S4 system are defined using the setClass() function,
# and new objects are created using the new() function.

# Class attributes in the S4 system are called slots.

# When defining a class one has to provide its name and
# individual slots (class of the object in the particular slot
#  also has to be defined).

# Let's define the class called "client4" - equivalent to 
# the class "client" from the S3 system from previous topic 
# having analogous fields - this time we also have to define
# their type (class)

setClass("client4", 
         slots = list(fname = "character",
                      lname = "character",
                      age = "numeric", 
                      gender = "character",
                      married = "logical"))

# then let's create a new object of this class
# using the new() function

# we must provide the class name and values of individual slots

k4 <- new(Class = "client4",
          fname = "John",
          lname = "Smith",
          age = 35,
          gender = "M",
          married = TRUE)

otype(k4)

# isS4() function allows to check 
# if the object has the S4 class

isS4(k4)

isS4(data.frame(x = 1))

# in turn the function getClass() 
# shows the definition of a particular class

getClass("client4")

# one can also show the structure

str(k4)

# WARNING!
# in the case of S4 class objects one refers to individual
# fields (slots) of using the @ symbol (NOT $ as in S3)

k4$fname

k4@fname

k4@lname

k4@married

# storing the result of the setClass() function 
# to a new object will create a function that can be
# used to create new objects of this class 
# (it is called a generator function).

# It's convenient to give this function the same name
# as the name of the class whose objects it will create.

# WARNING!
# When defining the class in the S4 system one can 
# also include data (slots) validatiion rules !!
# using the validity= argument of the setClass() function

# The validity= argument should be a function,
# which returns `TRUE` when the object is valid (correct)
# and `FALSE` or the corresponding message when the object
# is not valid.

# the same name for the generator function as the class name

client4 <- setClass("client4",
                    slots = list(fname = "character",
                                 lname = "character",
                                 age = "numeric", 
                                 gender = "character",
                                 married = "logical"),
                    validity = function(object)
                    {
                      if(object@age < 0) return("Age cannot be negative!")
                      if(object@age > 100) return("Age is too large!")
                      if(!object@gender %in% c("F", "M")) 
                        return('Incorrect gender - use "F" or "M"!')
                      return(TRUE)
                    })

# now instead of the new() function we can use the client4()
# function to create new objects, although of it directly
# refers to the new() function - is just a kind of mask.

client4

# let's see how data validation works

k5 <- client4(fname = "Joan",
              lname = "Warren",
              age = 124, 
              gender = "F",
              married = FALSE)

k5 <-  client4(fname = "Joan",
               lname = "Warren",
               age = 24, 
               gender = "D",
               married = FALSE)

# lets supply correct values

k5 <- client4(fname = "Joan",
              lname = "Warren",
              age = 24, 
              gender = "F",
              married = FALSE)

# modification of particular slots
# is possible with direct references

k4@age <- 140

# unfortunately in this case the correctness
# of inserted data is not verified

# we can check if the object is valid with
# the validObject() function

validObject(k4)

# lets correct a "mistake"

k4@age <- 40

validObject(k4)

# alternatively to view and modify
# field values we can use the slot() function
# here also the correctness of the value is not
# automatically verified:

slot(k4, "age")

slot(k4, "age") <- 35

# the advantage of S4 system objects is automated checking
# of the the type of data entered into individual slots 
# - one cannot be enter values of a different type than
# the one assumed for this slot in the definition of the class

slot(k4, "age") <- "40"


#------------------------------------------------------
# Generic functions and methods for S4 system objects

# Similar to the S3 system classes, in the S4 system
# methods also belong to generic functions, not to
# object or class.

# That's why working with generic functions in S4 is very
# similar to solutions in the S3 system.

# the function show() on the S4 system is the equivalent
# to the generic function print() from the S3 system

ftype(print)

ftype(show)

# let's see what result they will show for object S4

print(k4)

show(k4)

# the result looks analogous, 

# if in interactive mode we will call the object name

k4

# then for S4 system objects the appropriate 
# show() method will be called, while for a object
# of S3 system - print() method

isS4(print)

isS4(show)

# let's see that show() is a generic function

show

# for generic functions of the S4 system one will see
# a line with:
# standardGeneric("generic_function_name")

# All methods currently available for the selected
# generic function can be displayed using the function
# showMethods("generic_function_name"), e.g.

showMethods("show")


# A method in the S4 system is created using the setMethod() function

# Let's define the method show() for our class client4 
# (the argument of the generic function show() is called "object"
# and let's keep this name for consistency, although there is no such
# formal requirement)

setMethod(f = "show", # method
          signature = "client4", # class which this method refers to
          # and the method itself (function)
          # analogous as in the method print.client
          # but with @ instead of $
          definition = function(object) {
            # and go to the new line 
            cat(object@fname,object @lname, "\n")
            # print age and go to the new line 
            cat("age:", object@age, "years\n")
            # print gender and go to the new line 
            cat("gender:", object@gender, "\n")
            # print if married and go to the new line 
            cat("married:", ifelse(object@married, "Yes", "No"), "\n")
          }
)


# If we now refer to the sample object of the class "client4"
# in interactive mode, the above code will be executed
# (R refers to the show() method for the class "client4").

k4

# returns the same as

show(k4)


#-------------------------------------
# Creating S4 generic functions

# Again, by analogy with the S3 system discussed earlier,
# let's create the generic function age() and the method 
# age() for the class client4.

# setGeneric() function is used in this case
# (let's use the name age4 to distinguish it 
# from the age() method for S3 client class objects)

setGeneric(name = "age4",
           def = function(x) {
             standardGeneric("age4")
           })

age4

showMethods(age4)

# Let's create an appropriate method for the class "client4"

setMethod("age4",
          signature = "client4",
          definition = function(x) x@age
          )

showMethods(age4)

# apply it to the sample object of class "client4"

age4(k4)

# of course it will not work on the objects
# of class client (in S3 system) defined last time


#----------------------------------
# Multi-argument methods

# An advantage of the S4 system, apart from the formal 
# definition of classes, it the possibility to define
# multi-argument methods, which is not possible with 
# the S3 system.


# Let's create a generic function compare()
# and an appropriate method for TWO objects
# of class client4 that will display information:
# - if both objects have the same gender,
# - if both objects have the same marital status,
# - if both objects have the same age or, if not, who is older.


# classes of all objects required by the function
# are defined in the signature of the method(s)

# generic function
setGeneric("compare", 
           # lets define two arguments
           # (objects for comparison)
           function(x, y) standardGeneric("compare"))

compare

# and the method for two clients

setMethod("compare", 
          # here classes of required input objects are defined
          signature = c("client4", "client4"),
          definition = function(x, y) {
            cat(x@fname, x@lname, "has",
                ifelse(x@gender == y@gender, 
                       "the same gender as", 
                       "different gender than"),
                y@fname, y@lname, "\n")
            cat(x@fname, x@lname, "has",
                ifelse(x@married == y@married, 
                       "the same marital status as", 
                       "different marital status than"),
                y@fname, y@lname, "\n")
            cat(x@fname, x@lname, "is",
                ifelse(x@age == y@age, 
                       "as old as", 
                       ifelse(x@age > y@age, 
                              "older than", 
                              "younger than")),
                y@fname, y@lname, "\n")
          })

# Lets check how it works

compare(k4, k5)

compare(k5, k4)

# lets use an incorrect input object

compare(k4, data.frame(x = 1))


# The newest, more and more frequently used class system
# in R is the R6 class system. They are most similar to 
# object-oriented programming known from other programming 
# languages. In classes R6, methods belong to a class, not 
# to a generic function.

# If you are interested in learning more about R6 classes,
# please refer to the source materials at the end.


# There is also a RC (Reference Class) system called
# unofficially R5. Objects in the RC system are
# simplified objects of the S4 class with an attached 
# environment.


#--------------------------------------------------------------------
# Exercises 6

# Exercise 6.1
# (partial equivalent of the Exercise 5.3 from previous lab)
# Create a new class "student4" and two sample objects of this class.
# Let objects of this class have fields describing: 
# first_name, last_name, student_id, year, grades (numeric vector)
# and seminar (logical value).
# WARNING! DO NOT verify the correctness of the data.



# Exercise 6.2 
# Modify the class definition for "student4" adding the check of validity:
# - year - should be integer number from the range 1-5
# - student_id - should be a character string of exactly 6 characters
# - grades - should be a numeric vector of length 10 with
#            possible values: 2, 2.5, 3, 3.5, 4, 4.5, 5, NA




# Exercise 6.3
# For objects of student4 class define methods:
# - average - calculating the average grade,
# - information - displaying first name, last name 
#   and student ID number (in the parentheses)





# Exercise 6.4
# Define a generic function compare_averages() and an appropriate
# method for objects of class `student4` that will show
# information which of the two compared students 
# (first_name, last_name and student_id) has higher average.




#---------------------------------------------------------------
# Sources and additional materials: 
# http://www.cyclismo.org/tutorial/R/s4Classes.html
# https://www.datamentor.io/r-programming/S4-class
# http://biecek.pl/R/RC/Jakub%20Derbisz%20R%20reference%20card%20classes.pdf

# System RC
# http://adv-r.had.co.nz/R5.html
# https://www.datamentor.io/r-programming/reference-class

# R6 Classes
# https://www.r-project.org/nosvn/pandoc/R6.html
# https://www.r-bloggers.com/the-r6-class-system/
# https://rstudio-pubs-static.s3.amazonaws.com/24456_042da2fcea0a405a9f07845a872ae7a6.html
# https://adv-r.hadley.nz/r6.html
