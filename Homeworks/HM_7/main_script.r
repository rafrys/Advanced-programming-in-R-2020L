## Loading the libraries
library(factoextra)
library(corrplot)
library(clusterSim)
library(smacof)
library(labdsv)
library(tidyverse)
library(corrplot)

#Installing and loading packages

requiredPackages = c("tidyverse","factoextra","stats","clustertend","flexclust","ggforce"
                     ,"fpc","cluster","ClusterR","knitr","kableExtra","DataExplorer",
                     "reshape2","corrplot","labdsv","smacof","clusterSim","pastecs","psych",
                     "pca3d","pls","caret") 
for(i in requiredPackages){if(!require(i,character.only = TRUE)) install.packages(i)} 
for(i in requiredPackages){library(i,character.only = TRUE)} 

# Loading up the data
data_full <- read.csv("top50.csv",stringsAsFactors = F)
data_full <- data_full[,2:14]

data_init <- data_full

# Creating aggregate genre
data_init$aggregate.genre <- NA
data_init$aggregate.genre <- ifelse(data_init$Genre  %in% c("canadian pop","pop","dance pop",
                                                  "electropop","panamanian pop","pop house","australian pop"),"pop",
                               ifelse(data_init$Genre  %in% c("dfw rap","country rap","canadian hip hop","atl hip hop"),"hip hop",
                                      ifelse(data_init$Genre  %in% c("r&b en espanol","latin"),"latin",
                                             ifelse(data_init$Genre  %in% c("reggaeton flow","reggeaeton"),"reggaeton",
                                                    ifelse(data_init$Genre  %in% c("edm","trap music","brostep"),"electronic",
                                                           ifelse(data_init$Genre  %in% c("escape room","boy band","big room"),"other",data_init$Genre))))))

data_init$aggregate.genre <- as.factor(data_init$aggregate.genre)
unique(data_init$aggregate.genre)

typeof(data)

# Distribution of genres and aggregate genres
data_init %>% count(Genre) %>%
  ggplot(aes(reorder(Genre, n), n)) + geom_col(fill="cyan3") + coord_flip() +
  ggtitle("Top genre") + xlab("Genre") + ylab("Count")

data_init %>% count(aggregate.genre) %>%
  ggplot(aes(reorder(aggregate.genre, n), n)) + geom_col(fill="cyan3") + coord_flip() +
  ggtitle("Top aggregated genre") + xlab("Genre") + ylab("Count")


# Summary statistics of the data
x1 <- t(round(stat.desc(data_init[,c(4:13)]),2))
x1 <- x1[,c(4:6,8:13)]

kable(x1,caption = "Table 1. Summary statistics of the dataset")%>% 
  kable_styling(latex_options="scale_down",bootstrap_options = c("striped", "hover"))
#################################

# Distribution of the variables
gather(data_init[,c(4:13)]) %>% 
  ggplot(., aes(value)) + 
  geom_histogram(aes(y =..density..), 
                 col="black", 
                 fill="lightblue", 
                 alpha=.2) + 
  geom_density(col="cyan3")+
  labs(title="Graph 2. Histograms of variables")+
  facet_wrap(~key, scales = 'free')

# Log transformation of variables Liveness and Speechiness
transformed_var <- c("Liveness", "Speechiness.")
data_init <- data_init %>% mutate_at(vars(transformed_var), log)

gather(data_init[,c("Liveness", "Speechiness.")]) %>% 
  ggplot(., aes(value)) + 
  geom_histogram(aes(y =..density..), 
                 col="black", 
                 fill="lightblue", 
                 alpha=.2) + 
  geom_density(col="cyan3")+
  labs(title="Graph 2. Histograms of variables")+
  facet_wrap(~key, scales = 'free')

#################################
# Box plots for outlier detection


# Correlation analysis
data_corr<- select_if(data_init, is.numeric)
corrplot(cor(data_corr), type="lower", method="number",order ="alphabet")