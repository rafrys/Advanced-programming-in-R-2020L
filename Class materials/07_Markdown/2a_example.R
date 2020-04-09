require(dplyr)
require(ggplot2)
# require(ggrepel)
data(starwars)
starwars <- starwars

w2 <- ggplot(data = starwars, aes(x = height, y = mass, label = name)) + 
  geom_point() + labs(title = 'Who is the haviest character in Star Wars Universum') +
  geom_text(data = starwars[starwars$mass == max(starwars$mass, na.rm = T),])
w2

save(w2, file = '2a_example.Rdata')
