#---------------------------------------------------------#
#                 Advanced Programming in R               #
# 9. Advanced data processing with dplyr, dtplyr, tidyr   #
#                  Academic year 2019/2020                #
#               Piotr Wójcik, Piotr Ćwiakowski            #
#---------------------------------------------------------#    

# lets install and load all needed packages

# install.packages("dplyr")
# install.packages("readr")
# install.packages("tidyr")
# install.packages("data.table")
# install.packages("dtplyr")

library(dplyr)
library(readr)
library(tidyr)
library(data.table)
library(dtplyr)
library(microbenchmark)


# The package dplyr contains functions for efficient processing
# of data in R - they work very fast also on large datasets

# That's why the package is currently a standard in the R-world
# and is a part of "tidyverse" - the universe of packages 
# developed by RStudio (for more information https://www.tidyverse.org/).

# The dplyr package tries to follow SQL language scheme.

# Let's get to some basic functions:
# - filter() - is used to select observations that meet
#               the specified conditions,
# - select() - select columns,
#    inside filter() one can use:
#         contains()
#         starts_with()
#         ends_with()
# - rename() - allows you to rename columns,
# - arrange() - is used to sort data,
# - mutate() - is used to create new variables.
# - glimpse() - show structure of the data (alternative to str())
# - group_by() - is used to split data into groups using
#                selected columns (allows analysis in subgroups)
# summarise() - summarizes data
#   inside sumarize one can use for example:
#       n() - number of observations
#       n_distinct() - number of unique values
#       sample_n() - random sample (w/o replacement) - n elements
#       sample_frac() - random sample (w/o replacement) - fraction


# Each of these functions as the first argument expects 
# a data frame. Further arguments often require providing
# column names, which in these functions are NOT put in quotes.

# for more details see here:
# https://cran.r-project.org/web/packages/dplyr/vignettes/dplyr.html
# http://dplyr.tidyverse.org/


#-------------------------------------------------------
# data
# medical.csv

# The file includes socio-demographic data, including health 
# insurance and various aspects of health care touchpoints 
# for the respondent group of a survey conducted in the USA.


# read_csv() from the readr package
medical <- read_csv("data/medical.csv")

# we can turn off printing messages
# with the use of suppressMessages()

medical <- suppressMessages(read_csv("data/medical.csv"))


# data structure can be checked alternatively
# using the glimpse() function from the dplyr package

microbenchmark("read.csv" = {read.csv("data/medical.csv")},
               "read_csv" = {suppressMessages(read_csv("data/medical.csv"))},
               times = 10)


glimpse(medical)

# read_csv() does not convert strings to factors

# The dataset includes 35072 observations and 28 variables:

# UMARSTAT – Marital status recode
# UCUREMP – Currently has employer coverage:
# UCURNINS – Currently uninsured:
# USATMED – Satisfied with quality of medical care:
# URELATE – Number of relatives in household,
# REGION_STATE – region and US state code (separated by _)
# HHID – Household identification number,
# FHOSP – In hospital overnight last year:
# FDENT – Dental visits last year,
# FEMER – Number of emergency room visits last year,
# FDOCT – Number of doctor visits last year,
# UIMMSTAT – Immigration status
# U_USBORN – U.S.- or foreign-born:
# UAGE – Age topcoded,
# U_FTPT – Full-time or part-time worker this year:
# U_WKSLY – Weeks worked last year,
# U_HRSLY – Hours worked per week last year,
# U_USHRS – Hours worked per week this year,
# HEARNVAL – Earnings amount last year - Household,
# HOTHVAL – Household income, total exc. earnings,
# HRETVAL – Retirement amount – Household,
# HSSVAL – Social Security amount - Household,
# HWSVAL – Wages and salaries amount – Household,
# UBRACE – race:
# gender – gender
# UEDUC3 – education level, 3 codes:
# CEYES_CHAIR – color of eyes and color of hair (separated by _)
# BIRTHDATE – date of birth formatted as MM/DD/YYYY


# dplyr uses a special form of a data.frame - tibble

class(medical)

# one of the advantages is printing only
# a part of the dataset when referring to it's name
# - first tem observations and only as many columns
# as fit to the size of the console window

medical

# example of using filter() function from dplyr

filter(medical, # data
       gender == "Male") # condition

# there can be several conditions - ALL should be met

filter(medical, # data
       gender == "Female", # condition 1
       URELATE < 2, # condition 2
       between(U_WKSLY, 38, 40)) # condition 3

# example of using select() function from dplyr

select(medical, # data
       HHID, UMARSTAT, UAGE, gender, UBRACE) # columns selected

# one can use the colon to select adjacent columns
# and indicate only the first and last.

select(medical, URELATE:FDOCT)

# or the dplyr contains() function to identify the columns
# by name content

select(medical, contains("VAL"))

# One can also use starts_with() or ends_with()
# and also list several criteria to meet
# (all columns that meet AT LEAST ONE of them
# will be selected )

select(medical,
       starts_with("U_"), # columns starting with "U"
       ends_with("3"), # columns ending in "3"
       UBRACE:gender # column of given range
       )

# example of using rename() function from dplyr

# change gender variable name to GENDER so that 
# it is capitalized as all other variables here
# new_name = old_name

names(medical)

medical <- rename(medical,
                  GENDER = gender)

names(medical)

# all are now capitalized

# example of using the mutate() function from the dplyr

# lets add two new variables informing:
# - how many more hours per week a person is working in the
#   current year when compared to the previous year
# - what proportion of household income comes from social benefits

medical <- mutate(medical, # data
                  # new variables definitions
                  DIFF_HOURS = U_USHRS - U_HRSLY,
                  SHARE_SOCIAL = HSSVAL / (HEARNVAL + HOTHVAL))

# let's see in which US state the average increase 
# in the number of hours worked weekly was the highest

# lets start with the average for the whole sample

mean(medical$DIFF_HOURS)

# we can also use the summarize() function of the dplyr package

summarize(medical,
          mean(DIFF_HOURS))

# the resulting column can be labeled

summarize(medical,
          mean = mean(DIFF_HOURS))

# at the first sight the use of this function seems 
# to be more complex than using the usual mean() function

# However, lets count the average of the DIFF_HOURS 
# separately for each state.

# We can easily do this using the group_by() function
# and then summarize() from the dplyr package

medical_states <- group_by(medical, # data
                           REGION_STATE) # grouping variable (may be more than 1)

# the use of group_by() creates a grouped_df object

class(medical_states)

# now lets apply the summarize() function to a grouped object

summarize(medical_states,
          my_mean = mean(DIFF_HOURS))

# this results in the mean calculated in defined subgroups.

# we can also sort the states in descending order 
# of the resulting variable

# example use arrange() function from dplyr
# the previous function is now nested inside arrange()

arrange(
  summarize(medical_states,
            my_mean = mean(DIFF_HOURS)),
  my_mean) # variable used in sorting

# desc() for arranging in descending order

arrange(
  summarize(medical_states,
            my_mean = mean(DIFF_HOURS)),
  desc(my_mean)) 

# lets also count the minimum and maximum share of income
# from social benefits in each state

summarize(medical_states, # this is our grouped data frame
          min_share = min(SHARE_SOCIAL),
          max_share = max(SHARE_SOCIAL)
          )

# SHARE_SOCIAL column may contain missing values 
# (not all households receive social benefits)

# How much observations are missing in this column?
sum(is.na(medical$SHARE_SOCIAL))

# we need to ingnore missings in calculations (na.rm = T)

# Let's count how many observations are in the column,
# and how many of them are missing.
# And finally sort the result by a share of non-missing values

arrange(
  mutate(
    summarise(medical_states,
              min_share = min(SHARE_SOCIAL, na.rm = TRUE),
              max_share = max(SHARE_SOCIAL, na.rm = TRUE),
              n_all = n(),
              n_nonmissing = sum(!is.na(SHARE_SOCIAL))
    ),
    share_nonmissing = 100*n_nonmissing/n_all),
  share_nonmissing
)

# this code becomes hardly readable ...


# Lets introduce the pipe operator %>%
# from the magnittr package loaded 
# by default also in dplyr package

# This operator will allow us to write the above code
# in a much easier way.

# It is used in case when many operations are nested
# in one another and the next function uses the result
# of the previous as its first argument

# Example
# Calculation of the average age for the first 100 people
# from the medical dataset can be performed classically

mean(head(medical$UAGE, 100), na.rm = TRUE)

# with the pipe operator it changes to

medical$UAGE %>% head(100) %>% mean(na.rm = TRUE)

# we can read it as follows:
# Take the UAGE column from the medical data frame,
# then extract just the first 100 elements,
# then calculate the average, ignoring missing values

# function AFTER the pipe operator takes as the first argument
# the result of the previous function - therefore we only
# provide values of the remaining arguments (if needed,
# if not we put just the function name with empty parentheses).


# If the result of the previous function should be used 
# in the next function as an argument other than the first, 
# the place of its insertion is indicated by a dot, eg.

# lets randomly select 10 points from 0-1 range and then
# show them on the plot by putting the point number 
# on the horizontal axis (x =), and the generated value
# on the vertical (y =)

runif(10) %>% 
  plot(x = 1:10, y = .)

# the mean of age for first 100 obs once again

medical %>% 
  .[["UAGE"]] %>% 
  head(100) %>% 
  mean(na.rm = TRUE)

# CAUTION!
# for tibbles selecting columns in this way requires 
# putting their names in double brackets.

# Then the resulting object will be a vector,
# not a tibble!

# compare the results

medical %>% .["UAGE"] # tibble object
medical %>% .[["UAGE"]] # vector

# the function mean() will not work
# on the data frame (or tibble object)

mean(medical %>% .["UAGE"] )

# but works for a vector (numeric or logical)

mean(medical %>% .[["UAGE"]] )


# Using a pipe operator makes complex
# operations on the data much clearer

# Lets go back to the example of calculating the average 
# increase of the number of working hours between years
# by states

arrange(
  summarize(medical_states,
            my_mean = mean(DIFF_HOURS)),
  desc(my_mean))

# do the same with the pipe operator

medical_states %>% 
  summarise(my_mean = mean(DIFF_HOURS)) %>%
  arrange(desc(my_mean))

# Using a pipe operator often allows to avoid
# creating intermediate data objects (eg. grouped data)

# expand the above code by grouping our data by state

medical %>%
  group_by(REGION_STATE) %>%
  summarise(my_mean = mean(DIFF_HOURS)) %>%
  arrange(desc(my_mean))

# we also do not need to add DIFF_HOURS
# to the data permanently

# Remove it from the data

medical$DIFF_HOURS <- NULL

# and do the calculations "on the fly"
medical %>% 
  mutate(DIFF_HOURS = U_USHRS - U_HRSLY) %>%
  group_by(REGION_STATE) %>%
  summarise(my_mean = mean(DIFF_HOURS)) %>%
  arrange(desc(my_mean))

# the result is identical

# if the same function is applied on several columns
# one can use summarize_all(funs())

medical %>% 
 select(UMARSTAT, ends_with("VAL")) %>% 
  group_by(UMARSTAT) %>%
  # apply the functions to all (non-grouping) columns
  summarise_all(mean)

# One can also apply multiple types of summarization

medical %>% 
  select(UMARSTAT, ends_with("VAL")) %>% 
  group_by(UMARSTAT) %>%
  # apply the functions to all (non-grouping) columns
  summarise_all(list(minimum = min,
                     average = mean,
                     maximum = max)) -> medical_summary

# the result is assigned to medical_summary

head(data.frame(medical_summary))

# if you expect missing values in the data
# then anonymous function has to be used

medical %>% 
  select(UMARSTAT, ends_with("VAL")) %>% 
  group_by(UMARSTAT) %>%
  # giving a name allows to control the suffix
  # of resulting columns
  summarise_all(list(minimum = function(x) min(x, na.rm = TRUE),
                     average = function(x) mean(x, na.rm = TRUE),
                     maximum = function(x) max(x, na.rm = TRUE))) -> medical_summary

head(data.frame(medical_summary))


#------------------------------------------------------
# dtplyr
# an alternative to dplyr is the data.table package, which is
# even faster, especially on VERY large data sets,
# but has much less intuitive command syntax.
# Compare here: https://atrebas.github.io/post/2019-03-03-datatable-dplyr/

# The only thing one needs to do is to create a “lazy” 
# data table that tracks the operations performed on it.
# This is done with lazy_dt()

medical_dt <- lazy_dt(medical)

class(medical_dt)

# Then one just applies a dplyr syntax on it
# which is translated on the fly into data.table
# syntax and applied on the dataset

medical_dt %>% 
  select(UMARSTAT, ends_with("VAL")) %>% 
  group_by(UMARSTAT) %>%
  # giving a name allows to control the suffix
  # of resulting columns
  summarise_all(list(minimum = function(x) min(x, na.rm = TRUE),
                     average = function(x) mean(x, na.rm = TRUE),
                     maximum = function(x) max(x, na.rm = TRUE))) -> medical_dt_summary

# When printing the result one can also see
# the generated data.table code

medical_dt_summary

# To access the final results the object should
# be transformed into the data.frame or tibble with
# as.data.table(), as.data.frame(), or as_tibble() 
# as indicated in the comment at the bottom of
# theresults of the previous command

medical_dt %>% 
  select(UMARSTAT, ends_with("VAL")) %>% 
  group_by(UMARSTAT) %>%
  # giving a name allows to control the suffix
  # of resulting columns
  summarise_all(list(minimum = function(x) min(x, na.rm = TRUE),
                     average = function(x) mean(x, na.rm = TRUE),
                     maximum = function(x) max(x, na.rm = TRUE))) %>% 
  as_tibble() -> medical_dt_summary


# lets compare its time efficiency with the basic dplyr

microbenchmark(
  # the first code with dtplyr used
  "dtplyr" = {medical_dt %>% 
      select(UMARSTAT, ends_with("VAL")) %>% 
      group_by(UMARSTAT) %>%
      # giving a name allows to control the suffix
      # of resulting columns
      summarise_all(list(minimum = function(x) min(x, na.rm = TRUE),
                         average = function(x) mean(x, na.rm = TRUE),
                         maximum = function(x) max(x, na.rm = TRUE)))  %>% 
    as_tibble() -> medical_dt_summary},
  
  # the second code with dplyr used
    "dplyr" = {medical %>% 
        select(UMARSTAT, ends_with("VAL")) %>% 
        group_by(UMARSTAT) %>%
        # giving a name allows to control the suffix
        # of resulting columns
        summarise_all(list(minimum = function(x) min(x, na.rm = TRUE),
                           average = function(x) mean(x, na.rm = TRUE),
                           maximum = function(x) max(x, na.rm = TRUE))) -> medical_summary
    })

# here there is no advantage of using dtplyr.
# Pure data.table could be faster - however, more complex


# check "Why is dtplyr slower than data.table?" here:
# https://github.com/tidyverse/dtplyr



#------------------------------------------------------
# tidyr 

# Abother package useful for preparing data
# for analysis is tidyr (part of tidyverse).

# Here we will use two of it's functions:

# separate() - to split a value from the selected column
#              into several new columns
# unite() - to collect values from several columns 
#           into one new column

# Let's start by dividing the values 
# from the selected column into pieces

head(medical)

# to display all tibble columns let's 
# transform it on the fly into a data.frame

head(data.frame(medical))

# The CEYES_CHAIR column actually contains
# two variables - lets split them into two
# separate columns.

medical <- separate(medical, # original data
                    # col - variable name to parse (without quotation marks)
                    col = CEYES_CHAIR,
                    # into - text vector of new column names
                    into = c("CEYES", "CHAIR"),
                    # separator ("_" is default)
                    sep = "_") 

# There is also an additional option
# remove: whether to remove a split column 
# from the dataset (TRUE by default)

# lets see the result

head(data.frame(medical))

# instead of CEYES_CHAIR two new variables
# appeared - correctly separated

# let's see the cross frequency table for them

table(medical$CEYES, 
      medical$CHAIR)

# similarly, let's separate the data from 
# REGION_STATE column, which also contains 
# two variables
# we can use the pipe operator and omit 
# the names of arguments (if they are provided
# in the correct order)

medical <- medical %>% 
  separate(REGION_STATE,
           c("REGION", "STATE"))

head(data.frame(medical))

# variables have been separated

# it is a reversible operation - if one wants
# to combine data from several columns 
# into one, one can use the unite() function

medical <- unite(medical, # data frame to operate on
                 # col: new column name (with or without quotation marks)
                 col = REGION_STATE,
                 # names of variables to combine
                 REGION, STATE,
                 # separator that will separate values from
                 # source columns in the result (default "_")
                 sep = "-",
                 # should the original columns be removed
                 # (TRUE by default)
                 remove = FALSE)

head(data.frame(medical))

# variable was added BEFORE combined columns



#--------------------------------------------------------------------
# Exercises 9

# Exercise 9.1.
# Please rewrite the following code using the pipe operator,
# to avoid adding a new variable and creating 
# a new dataset medical_states.

arrange(
  mutate(
    summarise(medical_states,
              min_share = min(SHARE_SOCIAL, na.rm = TRUE),
              max_share = max(SHARE_SOCIAL, na.rm = TRUE),
              n_all = n(),
              n_nonmissing = sum(!is.na(SHARE_SOCIAL))
    ),
    share_nonmissing = 100*n_nonmissing/n_all),
  share_nonmissing
)




# Exercise 9.2.
# Using the pipe operator and summarizing in subgroups
# based on titanic dataset, calculate the percentage
# of passengers that survived by gender and travel class.

# titanic.csv
# Titanic passengers data – 1310 observations and 15 variables:
  
# passenger_id – Unique passenger id
# pclass – Ticket class (1 = 1st, 2 = 2nd, 3 = 3rd)
# survived – Survival (0 = No, 1 = Yes)
# name – Name and Surname
# sex – Sex (0 = Male, 1 = Female)
# age – Age in years
# sibsp – of siblings / spouses aboard the Titanic
# parch – of parents / children aboard the Titanic
# ticket – Ticket number
# fare – Passenger fare
# cabin – Cabin number
# embarked – Port of Embarkation (C = Cherbourg,
#               Q = Queenstown, S = Southampton)
# boat – Lifeboat (if survived)
# body – Body number (if did not survive and body was recovered)
# home.dest – Home/Destination




# Exercise 9.3.
# Using the pipe operator and summarizing in subgroups
# based on titanic dataset calculate the mean of, and 
# the minimum and maximum price of the ticket depending 
# on the port embarkation.




# Exercise 9.4.
# Using the pipe operator and summarizing in subgroups
# based on titanic dataset, identify cabins where
# only one passenger traveled.




# Exercise 9.5.
# Using the pipe operator and summarizing in subgroups
# based on titanic dataset, show the number of
# passengers rescued by each lifeboat in ascending order.




