#---------------------------------------------------------#
#                 Advanced Programming in R               #
#              4. Purr package and vectorization          #
#                  Academic year 2019/2020                #
#               Piotr Ćwiakowski, Piotr Wójcik            #
#---------------------------------------------------------# 


# 1. purrr package -------------------------------------------------------------

# Purrr package is a part of tydyverse project and provides set of functions for
# funtional programming. More you can read about this package here:
# https://purrr.tidyverse.org/

# 1.1 Introduction 

# Packages
install.packages('purrr')
install.packages('wesanderson')
#install.packages('devtools')
devtools::install_github("jennybc/repurrrsive")

library(purrr)
library(wesanderson)
library(repurrrsive)
library(tidyverse)

# 1.2 Exploring object with data:
data('got_chars')
View(got_chars)

# Let's investigate elements
got_chars[[1]] # nested list
names(got_chars[[1]]) # names of fields
length(got_chars) # amount of nested fields 
str(got_chars) # list of characters
str(got_chars[[1]]) # list of attributes of first character
length(got_chars[[1]]) # number of attributes

# Summary and goals

# Object is a nested list. Characters from Game of Thrones (first layer, 30 el.) have 
# attributes (second later, 18 fields). With the support of purrr package, we will
# extract various information fromt his complex objected and store it in tabularized
# data structure - data.frame.

# Pipeline operator:

# %>% 
# forwards given object to the next function as the first argument
# (generally database or the result of some function)

select(diamonds, cut, color, price)
diamonds %>% select(., cut, color, price)
diamonds %>% select(cut, color, price)

# 1.3 Family of map functiona

# Map function is an extension of apply functions. The biggest advantage of the
# map functions is more control over type of output. There are several types of map
# functions, e.g.:
# 
# map() makes a list.
# map_lgl() makes a logical vector.
# map_int() makes an integer vector.
# map_dbl() makes a double vector.
# map_chr() makes a character vector.

# Syntax of map function:
# map(.x, .f, ...)
# map(VECTOR_OR_LIST_INPUT, FUNCTION_TO_APPLY, OPTIONAL_OTHER_STUFF)

# So the map does:
# .f(some_list[[1]])
# .f(some_list[[2]])
# ...
# .f(some_list[[last_item]])

# Map return a list 
map(got_chars, 'playedBy')
map(got_chars, 18)

# If we want an atomic vector, we have to use:
map_chr(got_chars, 'name')
map_int(got_chars, 'id')
map_dbl(got_chars, 'id')
map_lgl(got_chars, 'alive')

# We can retrieve many elements as well:
ex <- map(got_chars, `[`, c("name", "alive", "playedBy")) # instead of [ we can use also extract()
str(ex)

# Data.frame output is available
library(magrittr)
map_df(got_chars, extract, c("name", "alive", "playedBy")) # does not work
map_df(got_chars, extract, c("name", "alive"))

# We can also do it step by step:
got_chars %>% {data.frame( # create data.frame from a vector
    name = map_chr(., "name"), # extract name field and save it as a vector
    alive = map_int(., "alive"), # extract alive field and save it as a vector
    playedBy = map_chr(.,c(18, 1)) # extract playedBy field and save it as a vector
)} 

# We can extract spefic element of the field
got_chars %>%
  map_chr(c(16,1)) # 1st element of 16th field 

# Now we can try with column playedBy:
got_chars %>% {data.frame( # create data.frame from a vector
  name = map_chr(., "name"), # extract name field and save it as a vector
  alive = map_int(., "alive"), # extract alive field and save it as a vector
  playedBy = map_chr(.,c(18, 1)) # extract playedBy field and save it as a vector
)}

# Let's apply user function:
got_chars %>% 
  map('aliases') %>% # extract aliases field and save it as list
  set_names(map_chr(got_chars, 'name')) %>% # change names of the list to the same as in originally list
  map(function(x) paste(x, collapse = ", ")) # apply user function

# Or...
got_chars %>% 
  map('aliases') %>% # extract aliases field and save it as list
  set_names(map_chr(got_chars, 'name')) %>% # change names of the list to the same as in originally list
  map(paste, ', ') # without function function()

# Or....
got_chars %>% 
  map('aliases') %>% # extract aliases field and save it as list
  set_names(map_chr(got_chars, 'name')) %>% # change names of the list to the same as in originally list
  map(~ paste(.x, collapse = ", ")) # ~ is an allias of function, than .x is interpreted as placeholder where element of object should be placed

# End now to data.frame:
got_chars %>% 
  map('aliases') %>% # extract aliases field and save it as list
  set_names(map_chr(got_chars, 'name')) %>% # change names of the list to the same as in originally list
  map(~ paste(.x, collapse = ", ")) %>%  # ~ is an allias of function, than .x is interpreted as placeholder where element of object should be placed
  tibble::enframe(value = "aliases") # transform into data.frame

got_chars %>% 
  map('aliases') %>% # extract aliases field and save it as list
  set_names(map_chr(got_chars, 'name')) %>% # change names of the list to the same as in originally list
  map(~ paste(.x, collapse = ", ")) %>%  # ~ is an allias of function, than .x is interpreted as placeholder where element of object should be placed
  tibble::enframe(value = "aliases") %>% # transform into data.frame
  unnest(cols = c(aliases)) # we can unnest to vector

# Now we can try with column playedBy:
got_chars %>% {data.frame(
  name = map_chr(., "name"), # create character column with names
  alive = map_int(., "alive"), # create logical column dead-or-alive
  playedBy = map(got_chars, ~ paste(.x[18], collapse = ", ")) %>% unlist() # extract actors names as list and then simplified it as vector
  )}

# 1.4 List in data.frame

# We can use 
got_df <- got_chars %>%
  set_names(map_chr(., "name")) %>% # name the elements of the list after value stored name field
  tibble::enframe("name", 'data') # data.frame with columns name and data (nested list will be stored in cells of data.frame)

# Or through map_dfr, wit slightly different method
map_dfr(got_chars, extract, c('name', 'id')) # extraction only two columns: name and id

# We can work with this object via dplyr functions:
library(dplyr)
got_df %>% 
  mutate(id = map_int(data, 'id'))

# Let's extract more data from data column:
got_df %>% 
  mutate(more_info = data %>% 
           map(. %>% 
                 map_df(`[`, c('name', 'playedBy', 'books') # `[` is the same as extract
                        )
               )
         ) 

# 1.5 Parallel map.
# 
# Extremely useful tool. Parallel loop over two lists of values.
# 
# map2(.x, .y, .f, ...)
# map(INPUT_ONE, INPUT_TWO, FUNCTION_TO_APPLY, OPTIONAL_OTHER_STUFF)


map2_chr(got_chars %>% map_chr("name"), # first vector
         got_chars %>% map_chr("born"), # second vector
         function(x, y) paste(x, "was born", y) # function with two arguments 
          ) 

# And pmap only expand this functionality:

# Preparation of exemplary data:
df <- got_chars %>% {
  tibble::tibble(
    name = map_chr(., "name"),
    aliases = map(., "aliases"),
    allegiances = map(., "allegiances")
  )
}

# Function with three arguments to apply:
my_fun <- function(name, aliases, allegiances) {
  paste(name, "has", length(aliases), "aliases and",
        length(allegiances), "allegiances")
}

# Example:
df %>% 
  pmap_chr(my_fun) %>% 
  tail()

# 1.6 Working with subsamples within data.frame

# Sample size:
iris %>% 
  group_by(Species) %>% 
  nest() %>% 
  mutate(N = map(data, nrow)) %>% 
  unnest(N)

# Draw rows from subsamples:
iris %>% 
  group_by(Species) %>% # group by categorical variable
  nest() %>% # nest in subsamples with respect to categories
  ungroup() %>% # ungroup for futher opeations
  mutate(size = c(3, 2, 4), # sample size
         samples = map2(data, size, sample_n) # sample_n is a function
  )

# And unnesting:
iris %>% 
  group_by(Species) %>% # group by categorical variable
  nest() %>% # nest in subsamples with respect to categories
  ungroup() %>% # ungroup for futher opeations
  mutate(samples = map2(data, c(3, 2, 4), sample_n)) %>%  #draw random subsamples of different subsamples
  unnest(samples) # unnesting

# 1.7 Other functions:
`%+%` <- function(x, y) paste(x, y, sep = ', ')
got_df$name %>% accumulate(`%+%`) # returns subsequent results of iterated cummulation values with given operator.
got_df$name %>% reduce(`%+%`) # returns only the longest accumulated result

# More here:
# https://purrr.tidyverse.org/reference/accumulate.html

# Let's create a list of hyperparameter to test:
L1L2_grid <- list(alfa = seq(0, 1, by = .1),
                  lambda = sample(1:1000, 10))

L1L2_grid %>%
  cross() %>% # combination of each two between two columns
  map(lift(data.frame)) %>% # lift function allows data.frame to accept list as an argument. Then aplly lift(data.frame) to each element of the list L1L2_grid
  enframe %>% # transform into data.frame
  unnest(value) # unnest

# More here:
# https://purrr.tidyverse.org/reference/cross.html

# family of functions flatten() remove a level hierarchy from list:
map(got_chars, "books") %>% flatten()
map(got_chars, "books") %>% flatten_chr()

# unlist() works similary:s
map(got_chars, "books") %>% unlist()

# More info here:
# https://purrr.tidyverse.org/reference/flatten.html

# With list_modify() we can change content of the given field:
got_chars %>% 
  set_names(got_chars %>% map_chr('name')) %>% 
  list_modify(`Sansa Stark` = 'Azor Ahai')

# and with the list_merge we can add an element:
got_chars %>% 
  set_names(got_chars %>% map_chr('name')) %>% 
  list_modify(`Sansa Stark` = 'Azor Ahai') %>% 
  list_merge(`Sansa Stark` = 'Or not Azor Ahai')

# Or wth splice we can add something
splice(got_chars, JanKowalski = 'Azor Ahai')

# More info here:
# https://purrr.tidyverse.org/reference/list_modify.html

# Extremely powerful tool
test <- got_chars %>% 
  transpose() %>% # transposition of a list fields (first level becomes the second and vice versa)
  enframe() 


# More info:
# https://purrr.tidyverse.org/reference/transpose.html

# Sometimes very useful.

# 1.8 Text Mining case study.

# Additional functions:
# https://purrr.tidyverse.org/reference/index.html

# Text Mining case study
library(tidytext)
library(hunspell)

data_tm <- readLines('/Users/rafalelpassion/Advanced-programming-in-R-2020L/Class materials/1883_Theodore_Roosevelt.txt', encoding = 'UTF-8')  %>%  
  data_frame() %>% 
  dplyr::rename(text = '.') %>% # keeps all variables
  mutate(line = 1:25) %>% 
  unnest_tokens(word,text) %>% 
  head(50) %>% 
  mutate(check = hunspell_check(word),
         suggest = hunspell_suggest(word), 
         stem = hunspell_stem(word))

# Traditional apply:
sapply(data_tm[,'suggest'], function(x) x[[1]][1])
sapply(data_tm[,'stem'], function(x) x[[1]][1])

# How to use map?
map_chr(data_tm$suggest, 1)
map_chr(data_tm$stem, 1)

# 2. Exercises (part 1.) -------------------------------------------------------

# 2.1. Use nest() function to split diamonds dataset with respect to two categorical 
# variables: color and cut. Then:
# a. for each element perform a regression: price ~ carat. Save the results in 
# the data.frame
# b. for each model generate summary and save result in the data.frame
# c. for each model compute coefficients and r_square and store it in the data.frames
data(diamonds)

varlist <- names(data.list)
models <- lapply(varlist, function(x) {
  lm(price ~ carat, data=data.frame(price=data.list[[x]][7], carat=data.list[[x]][1]))
})





# 2.2. Load dataset about starwars characters. Then:
# Compute in how many episodes each character played,
# a. paste all starships into one value and return to the same cell.
# b. unnest films columns.
# c. nest observation by eyecolor and sample data from each row
data(starwars)



# 3. Vectorization in R. -------------------------------------------------------
# 
# Even though loops are very convenient, the best option will be always to vectorize
# operation.

# What does it mean exactly? Let's find out.

# 3.1 Sum

# Traditionaly:
x <- c(16, 5, 79, 18, 22, 33) 
sum = 0
for (i in 1:length(x)){
  sum = sum + x[i]
}
sum

# but we can also...:
sum(x)

# 3.2 Sum and product

# Let's consider some of product x and y:
x <- c(16, 5, 79, 18, 22, 33) 
y <- c(12, 3, 45, 67, 19, 2)

sum.i = 0
for (i in 1:length(y)){
  sum.i = sum.i + x[i]*y[i]
}
sum.i

# But what for, if we can do that:
sum(x*y)

# Vectorization is important for speed of computation:
# (source: http://alyssafrazee.com/2014/01/29/vectorization.html)

big.vector = runif(1000000, 10, 100)

# let's log each element separately:
log_iter <- function(n){
  result = rep(NA, length(n))
  for(i in seq_along(n)){
    result[i] = log(n[i])
  }
  return(result)
}

# Let's compute time of computation:
system.time(log_iter(big.vector))
system.time(log(big.vector))

# Let's check apply function:
system.time(sapply(big.vector, log))

# 3.3 Vectorize()

# In R most of the functions are vectorized - however few of them are not. We can 
# vectorize them with Vectorize() function. Let's look at the examples.

# Switch function:
centre <- function(x, type){
  switch(type,
         mean = mean(x),
         median = median(x)
  )
}

# Example:
vector <- rnorm(100, 10)

# We can change one value:
centre(vector, 'mean')
centre(vector, 'median')

# But no more...
centre(vector, c('mean','median'))

# Thus...
centrev <- Vectorize(centre, vectorize.args = 'type')
centrev(vector, c('mean','median'))

# 3.4 Optimization case study

# First, let's create an object:
col1 <- runif (10^5, 0, 2) 
col2 <- rnorm (10^5, 0, 2) 
col3 <- rpois (10^5, 3) 
col4 <- rchisq(10^5, 2) 
df <- data.frame (col1, col2, col3, col4)

# than, consider following code:
system.time({
  for (i in 1:nrow(df)) {
    # print(i)
    if ((df[i, 1] + df[i, 2] + df[i, 3] + df[i, 4]) > 4) {
      df[i, 5] <- "more than 4"
    } else {
      df[i, 5] <- "4 or less" 
    }
  }
})

# user     system   elapsed 
# 27.72    0.00      27.75

# how to optimize code via vectorization?
df <- data.frame (col1, col2, col3, col4)
system.time({
  result <- character(nrow(df)) # let's allocate memory for results
  condition <- (df[, 1] + df[, 2] + df[, 3] + df[, 4]) > 4 # let's VECTORIZE condition
  for (i in 1:nrow(df)) { 
    if (condition[i]) {
      result[i] <- "more than 4"
    } else {
      result[i] <- "4 or less"
    }
  }
  df$col5 <- result
})
# user     system   elapsed 
# 0.03       0.00       0.03 

# Let's vectorize whole computation:
df <- data.frame (col1, col2, col3, col4)
system.time({
  output <- ifelse ((df[, 1] + df[, 2] + df[, 3] + df[, 4]) > 4, "more than 4", "4 or less")
  df$col5 <- output
}) 

# user     system   elapsed
# 0.01       0.00       0.02 

# We can vectorize with faster functions:
df <- data.frame(col1, col2, col3, col4)
system.time({
  condition = which(rowSums(df) > 4) # which is extremely fast
  output = rep("4 or less", times = nrow(df))
  output[condition] = "more than 4"
  df$col5 <- output
})

# user     system   elapsed
#    0          0         0

# Apply will be faster than for, by slower than vectorization
f <- function(x) {
  if ((x[1] + x[2] + x[3] + x[4]) > 4) {
    "more than 4"
  } else {
    "4 or less"
  }
}

df <- data.frame(col1, col2, col3, col4)
system.time({
  df$col5 <- apply(df, 1, FUN = f)  
})

# user     system   elapsed
# 0.26       0.00       0.26

# 4. Extras --------------------------------------------------------------------

# 4.1 mapply
# mapply is a multivariate version of sapply. mapply applies FUN to the first 
# elements of each ... argument, the second elements, the third elements, and so on. 
# Arguments are recycled if necessary.

# mapply(FUN, ..., MoreArgs = NULL, SIMPLIFY = TRUE,
# USE.NAMES = TRUE)

# Examples:
mapply(rep, x = 1:4, times = 4:1)
mapply(rep, times = 1:4, x = 4:1)
mapply(rep, times = 1:4, MoreArgs = list(x = 42))
mapply(function(x, y) seq_len(x) + y,
       c(a =  1, b = 2, c = 3),
       c(A = 10, B = 0, C = -10))

# 4.2 do.call()

# Extremely useful loop. See an example:
example <- list(a = letters[1:10],
                b = letters[20:24],
                c = letters[5:22])

c(example$a, example$b, example$c)

do.call(c, example)

# Another example:
tmp <- expand.grid(letters[1:2], 1:3, c("+", "-"))
tmp

do.call("paste", c(tmp, sep = ""))

# 4.3. replicate()
# This function replicates result defineds by user number of times

library(ggplot2)
wykres <- ggplot(data = diamonds) + geom_point(aes(x = carat, y = price))

ex <- replicate(5, wykres, simplify = 'array')
ex
ex[1,1]
ex1 <- replicate(5, wykres, simplify = F)
ex1[[1]]$data
ex1[[1]]$layers


# 5. Exercises (part 2.) -------------------------------------------------------

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
