library(dplyr)

## Funções básicas do pacote dplyr: Um resumo da documentação
dados <- mtcars
View(dados)
dados %>% summarise(mean = mean(mpg))
dados %>% count()
dados %>% group_by(carb)

