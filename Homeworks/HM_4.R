#---------------------------------------------------------------#
#                Advanced Programming in R                      #
# Homework for Laboratory 4. Vectorization and purrr functions  #
#                 Academic year 2019/2020                       #
#                 Rafal Rysiejko, 423827                        #
#---------------------------------------------------------------# 




# 2. Exercises (part 1.) -------------------------------------------------------

# 2.1. Use nest() function to split diamonds dataset with respect to two categorical 
# variables: color and cut. Then:
# a. for each element perform a regression: price ~ carat. Save the results in 
# the data.frame
# b. for each model generate summary and save result in the data.frame
# c. for each model compute coefficients and r_square and store it in the data.frames
data(diamonds)
diamonds <- data.frame(diamonds)

price_vs_carat <- function(df) {
  lm(price ~ carat, data = df)
}

diamonds2 <- diamonds %>% 
  group_by(color,cut) %>% 
  nest() %>% 
  mutate(fit = map(data,price_vs_carat))%>% 
  mutate(fit_sum = map(fit,summary),
         r_sq = map_dbl(fit_sum, "r.squared"),
         coeff = map(fit_sum, "coefficients"))

diamonds2[['coeff']][[1]]

# 2.2. Load dataset about starwars characters. Then:
# Compute in how many episodes each character played,
# a. paste all starships into one value and return to the same cell.
# b. unnest films columns.
# c. nest observation by eyecolor and sample data from each row
data(starwars)


#---------------------------------------------------------------------------------------------------------------------------------------------------------------------

# 5. Exercises (part 2.) ---------------------------

# 5.1. Read chapter Imporving performance from book Advanced R by Hadley Wickham:
# https://adv-r.hadley.nz/perf-improve.html#more-techniques


# 5.2. Please vectorize this code (source: https://www.datacamp.com/community/tutorials/tutorial-on-loops-in-r)


# Create matrix of normal random numbers
mymat <- replicate(m, rnorm(n))

# Transform into data frame
mydframe <- data.frame(mymat)

for (i in 1:m) {
  for (j in 1:n) {
    mydframe[i,j]<-mydframe[i,j] + 10*sin(0.75*pi)
    print(mydframe)
  }
}

# 5.3. Vectorize this code:
numbers = floor(runif(100, 0, 100))
odd = numeric()

for (k in numbers) {
  if (!k %% 2)
    next
  odd <- c(odd,k)
}
odd