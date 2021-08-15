library(tidyverse)
library(rvest)
# Passo 1: Analise o arquivo robots.txt e veja se você pode utilizar
#o site 'http://pythonscraping.com' para o projeto

# Passo 2: Analise o site buscando as principais tags e atributos

# Passo 3: Criação dos códigos
## Trabalhando com uma página simples
url <- 'http://pythonscraping.com/pages/page1.html'
html <- read_html(url)
html %>% html_elements('body h1') %>% html_text2()
html %>% html_elements('#fakeLatin') %>% html_text(trim = T)

## Trabalhando com tabelas
url <- 'http://pythonscraping.com/pages/page3.html'
html <- read_html(url)
tabela.html <- html %>% html_elements('#giftList') %>% html_table()
dataset <- as.data.frame(tabela.html)
View(dataset)

## Trabalhando com CSS seletor
url <- 'http://pythonscraping.com/pages/warandpeace.html'
html <- read_html(url)
textos.vermelhos <- html %>% html_elements('.red') %>% html_text2()
textos.verdes <- html %>% html_elements('.green') %>% html_text2()


for (i in 1:length(textos.verdes)){
  print(textos.verdes[i])
}
