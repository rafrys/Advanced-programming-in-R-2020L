#---------------------------------------------------------#
#                 Advanced Programming in R               #
#              5. Object oriented programming             #
#                 classes and methods, S3 system          #
#                  Academic year 2019/2020                #
#               Piotr Wójcik, Piotr Ćwiakowski            #
#---------------------------------------------------------# 

# A useful tool that we will use for checking
# object classes is the pryr package 

install.packages('pryr')
library(pryr)

# Object-oriented programming (OOP) is a technique
# that allows you to control complex IT projects.

# Most analysts will not work alone on such solutions, 
# but this knowledge is definitely useful,
# e.g. when creating own package in R
# or generally understanding how different functions work

# The concept of object-oriented programming allows for
# a holistic view on the process of data collection and processing. 
# It involves defining new types of objects (so-called classes) 
# and functions or activities assigned to them (so-called methods).

# Objects in this approach are specific representatives of classes, while
# classes are a way to organize objects into groups of units with common
# characteristics. For each class we can define a list of characteristics,
# and then assign each object specific values of those characteristics.

# Using classes allows us to organize our knowledge more
# effectively and map real world objects in computer programs.

# Lets explain this using a simple example

# Salmon and giant shark are both representatives of the class
# "fish" (although they differ significantly).

# If we say "Nemo is a fish", then even people who don't know
# the famous Disney movie can easily list selected characteristics 
# of this "object":
# - has fins,
# - breathes with bronchi
# - has no voice.

# If we want to create a database storing information about 
# different fishes, we can create a new class of objects "fish"
# and define what characteristics these objects should have.

# Then for the class "fish" we can define different so called
# methods (in fact - functions), that can be used to retrieve
# a particular feature of a selected object (e.g. length(fish1))
# or perform some more complex analysis:, e.g.:
# - compare(fish1, fish2)
# - trace(fish1)
# - do_they_ever_meet_in_real_life(fish1, fish2)
# - how_to_cook(fish1)

# The above example is purely theoretical, but this
# approach can be applied for example to create 
# large databases storing information about
# clients, students, etc.


# Most programming languages have one class system.

# R has four independent class systems available:
# S3, S4, reference class (RC or R5) and the recently
# introduced R6.

# We also have a "base" system that contains the most basic
# object classes in R: numeric, character, factor, list, etc.

# These systems exist side by side, they have different
# characteristics and properties that we will discuss below.

# Features of the programming language that are important from
# the point of view of object oriented programming (OOP):
# - polymorphism - the ability to create methods (functions) which
#   behavior (result) may depend on the type (class) of the object
#   being her argument - they are called GENERIC functions,
#   or polymorphic functions
# - inheritance (the possibility of creating a new one)
#   classes based on an existing one by specifying that new
#   class is a special case of an existing class
#   (this will not be defined in details in the course)


# In summary, an object in object-oriented programming has two
# types of attributes:
# - fields (features, information, data it stores)
# - methods (functions that can be performed on it)

# Each object must also have a type called CLASS.
# All objects of the same class will have the same methods,
# and child classes will inherit fields and methods of the 
# general parent classes.
 

#----------------------------------------------------
# S3 Classes

# The S3 system of classes in the simplest
# way of defining own classes in R.

# S3 classes do not require formal definition, and the object,
# representing this class can be created simply by
# assigning it the appropriate attribute class.

# each S3 object is in fact a LIST with the CLASS attribute assigned.

# Because of the radical simplicity, the S3 classes 
# are widely used in R. 
# Still most classes in R are created in S3 system.

# To check which class system the object belongs to
# we can use the otype() function from the pryr package

dframe <- data.frame(x = 1:10,
                     y = letters[1:10])

class(dframe)

otype(dframe) 

# data.frame() is therefore an class defined in S3 system

# How to define own S3 class and create new objects of this class?

# lets create a sample list
# including elements of different type

k <- list(fname = "John",
          lname = "Smith",
          age = 35,
          gender = "M",
          married = TRUE)

class(k)

otype(k) 

# list is an object defined in the base system of classes

# we can use the function class() to assign
# a new value of this attribute (class)

class(k) <- "client"

class(k)

otype(k) 

# we just created a new class of S3 system!

# This may look strange to programmers with experience
# with C++, Python or other language where formal definitions 
# of classes ar erequired and the objects have clearly defined 
# attributes and methods.

# In S3 system we refer to individual fields of the object
# using the $ symbol (same as for the list, which this object 
# in fact is)

str(k)

k$fname

k$lname

k$married

# You can see that in S3 system classes are defined ad hoc.

# Simplicity is an advantage, but also a disadvantage of this system,
# because  the consistency of the objects in a given class is not verified 
# at all here.

# You can freely assign a class to an object, and thus assign 
# the same class to objects with completely different structure
# (fields).

class(dframe) <- "client"

class(dframe)

otype(dframe) 

# here, changing the class will change the way the data frame 
# is displayed (which as we remember is an example of a list)

dframe

# let's change the class of the dframe object back to data.frame
# - we can also do it with the structure() function
# from the base package

dframe <- structure(dframe, # object
                    class = "data.frame") # class

# structure() is worth using when creating your own
# functions to make sure the resulting object will be
# assigned the appropriate class

class(dframe)

otype(dframe)

dframe

# we can also add our class as an additional  
# one using the append() function

class(dframe) <- append(class(dframe), "klient")

class(dframe)

# an object might have miltiple classes and 
# their order matters - we will refer to than later

#-------------------------------
# Methods and generic functions in S3

# If we call the object name in R as a command,
# it will be displayed in the console.

k

# by default R calls the print() function
# on the object

# In loops or inside functions
# the automatic printing is off. 
# In such case, one has to use
# directly the print() command

print(k)

# One can use different arguments of the print() 
# function: a vector, matrix, data frame, model result, etc. 
# and the result will be displayed differently, 
# DEPENDING ON THE CLASS of the object being the argument

print(dframe)

print(1:10)

print(lm(1:10~rnorm(10)))

# How does the print() function know what
# result to show depending on the type of object?

# The answer is: print() is a GENERIC function
# (also called POLYMORPHIC function)

# In fact, it is a collection of many METHODS 
# appropriate for objects of different CLASSES.

# The only task of the generic function is to recognize
# the class (type) of input object and transfer
# the execution to the appropriate method.

# When we call the generic function print() on an object
# of class "data.frame", the execution is forwarded to 
# print.data.frame() method,
# for the object of class "lm" the print.lm() method is used, etc.

# So in the S3 system the name of the method consists of
# the name of the generic function and (after a dot!)
# the name of the class to which it is applied.

# To find out if a function is a generic function,
# one can display its source code (invoke the command
# being the name of this function).

print

# If the displayed source code includes a command
# UseMethod(), with the appropriate method as an argument,
# then the function being analyzed is a generic function.

# we can also use the ftype() function from the pryr package

ftype(print)

# it is a generic function from S3 system

ftype(print.data.frame)

# method in S3 system for
# generic function print() and
# objects of class "data.frame"

# lets check all the methods available for
# the generic function print()

methods(print)

# methods with an asterisk at the end of their name
# are "invisible" - their source code is not
# automatically displayed

print.ts

# but one can display them knowing the package 
# they come from and using ::: (THREE colons!)

stats:::print.ts

# or without having to know the package

c

# you can also view all available methods
# for the selected class

methods(class = "data.frame")

methods(class = "client")

# no methods for our new class...

# what happens when we apply the generic function print()
# on the object of class client?

print(k)

# the object was displayed despite no method assigned

# Here the default method was used: print.default()
# This is a method that is called, if no match was found 
# (if there is no method defined for the class
# of the object being the argument of the generic function).

# Each generic function has a default method.

# R has a lot of generic functions defined in S3 system.
# You can display them all using the command:

methods(class = "default")


#------------------------------------
# How to create your own method 
# for an existing generic function?

# just write the appropriate function whose name will be
# a combination of generic function name and object class

# Let's create the function print.client()

# function cat() displays the resulting object as 
# a concatenation of the text arguments - works
# like the combination of print(paste()). 

# In addition the cat() function interprets 
# special characters (e.g., "\n" which means
# going to the next line, while
# print() treats them as plain text).

print.client <- function(x) {
  # print first name and last name
  # and go to the new line 
  cat(x$fname, x$lname, "\n")
  # print age and go to the new line 
  cat("age:", x$age, "years\n")
  # print gender and go to the new line 
  cat("gender:", x$gender, "\n")
  # print if married and go to the new line 
  cat("married:", ifelse(x$married, "Yes", "No"), "\n")
}

# Now this method will be called every time
# when we display an object of the class "client".

# let's check how it works

print(k)

k

# let's create another object of this class 
# - it is convenient to create a function for that
#   with the same name as the name of the class

client <- function(fname, lname, age, gender, married) {
  new_object <- list(fname = fname,
                     lname = lname,
                     age = age, 
                     gender = gender,
                     married = married)
  # it is convenient to assign a class 
  # attribute by calling the structure function
  structure(new_object, class = "client")
}


k2 <- client("Joan",
             "Warren",
             24,
             "F",
             FALSE)

# lets apply the print method

print(k2)

# add the method mean.klient() simply
# returning client's age

mean.client <- function(x) x$age

mean(k)

# let's check the list of methods defined
# for the class client

methods(class = "client")

# In the S3 system, methods do NOT belong to an object
# or class, but to generic functions.

# The method will work as long as 
# the appropriate object class is set.

# deleting the class attribute will 
# cause the use of the default method

unclass(k)

# now printed as a list

#------------------------------------
# Creating own generic function

# One can also create own generic function, 
# such as print(), plot() or mean().

# Let's first see how these functions are constructed.

print

plot

mean

# Each of them contains only a reference to the command
# UseMethod() with the name of the same generic function.

# This is a so called transfer function (dispatcher),
# which will handle all references.


# These examples also show how easy it is
# to create your own generic function.


# For the purposes of our example, 
# let's create the generic function age().

age <- function(x) {
  UseMethod("age")
}

# The generic function is useless without any methods defined.

age(k)

# Let's create a default method
# just printing some information

age.default <- function(x) {
  cat("This is a generic function")
}

age(k)

# then let's create a method for the class "client"

age.client <- function(x) x$age

# Sample use:

age(k)

# The way of creating method names in the S3 system
# (generic_function.class) causes that methods
# in this system can only have one argument
# - i.e. operate only on one object of selected class.

# We will come back to this when discussing the classes 
# of the S4 system.


#----------------------------------------------------------------
# Exercises 5

# Exercise 5.1
# Check which method are defined for 
# a generic function predict()?

methods(predict)

# Exercise 5.2
# Create a generic function add_all(), then the
# defaults method and two additional methods:
# - add_all.numeric() returning the sum of all elements
#   if argument is numeric - use the function sum()
# - add_all.character() returning concatenation of all elements
#   if argument is character - use the function paste()




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

#--------------------------------------------------------------
# Sources and more information

# https://www.datamentor.io/r-programming/S3-class