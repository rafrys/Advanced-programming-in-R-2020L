#--------------------------------------------------------------#
#                  Advanced Programming in R                   #
#  Homework for Laboratory 9:  Advanced data processing        #
#                  with dplyr, dtplyr, tidyr                   #
#                  Academic year 2019/2020                     #
#                  Rafal Rysiejko, 423827                      #
#--------------------------------------------------------------# 

library(dplyr)
library(readr)
library(tidyr)
library(data.table)
library(dtplyr)
library(microbenchmark)



#--------------------------------------------------------------------
# Exercises 9

# Exercise 9.1.
# Please rewrite the following code using the pipe operator,
# to avoid adding a new variable and creating 
# a new dataset medical_states.
medical <- read_csv("Class materials/09_Dplyr/data/medical.csv")

# medical <- mutate(medical,
#                   DIFF_HOURS = U_USHRS - U_HRSLY,
#                   SHARE_SOCIAL = HSSVAL / (HEARNVAL + HOTHVAL))
# 
# medical_states <- group_by(medical,REGION_STATE) 
# 
# arrange(
#   mutate(
#     summarise(medical_states,
#               min_share = min(SHARE_SOCIAL, na.rm = TRUE),
#               max_share = max(SHARE_SOCIAL, na.rm = TRUE),
#               n_all = n(),
#               n_nonmissing = sum(!is.na(SHARE_SOCIAL))
#     ),
#     share_nonmissing = 100*n_nonmissing/n_all),
#   share_nonmissing
# )

#Answer:
medical %>% mutate(DIFF_HOURS = U_USHRS - U_HRSLY,
                     SHARE_SOCIAL = HSSVAL / (HEARNVAL + HOTHVAL)) %>% group_by(REGION_STATE) %>% summarise(min_share = min(SHARE_SOCIAL, na.rm = TRUE),
                                                               max_share = max(SHARE_SOCIAL, na.rm = TRUE),
                                                               n_all = n(),
                                                               n_nonmissing = sum(!is.na(SHARE_SOCIAL))) %>% mutate(share_nonmissing = 100*n_nonmissing/n_all) %>% arrange(share_nonmissing)


# Exercise 9.2.
# Using the pipe operator and summarizing in subgroups
# based on titanic dataset, calculate the percentage
# of passengers that survived by gender and travel class.

titanic <- read_csv("Class materials/09_Dplyr/data/titanic.csv")

titanic %>% group_by(sex,pclass) %>% summarize(survived_sum=sum(survived,na.rm=T),
                                               n_all=n()) %>% mutate(share_survived = 100*survived_sum/n_all) %>% arrange(desc(share_survived))
  
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

titanic %>% group_by(embarked) %>% summarise(mean_price = mean(fare,na.rm = T),
                                             min_price = min(fare,na.rm = T),
                                             max_price = max(fare,na.rm = T))


# Exercise 9.4.
# Using the pipe operator and summarizing in subgroups
# based on titanic dataset, identify cabins where
# only one passenger traveled.

titanic %>% group_by(cabin) %>% filter(n()==1) %>% group_by(pclass)


# Exercise 9.5.
# Using the pipe operator and summarizing in subgroups
# based on titanic dataset, show the number of
# passengers rescued by each lifeboat in ascending order.

titanic %>% filter(!is.na(boat)) %>% group_by(boat) %>% summarise(number_of_rescued = n()) %>% arrange(number_of_rescued)
