library(tidyverse)
library(rvest)
library(glue)
library(polite)
# Passo 1: Analise o arquivo robots.txt e veja se você pode utilizar
#o site 'https://ssearch.oreilly.com/?all=0;i=1;q=economy&act=pg_viewall' para o projeto

# Passo 2: Analise o site buscando as principais tags e atributos

# Passo 3: Criação dos códigos
## Outras funções uteis para a raspagem de dados

session <- bow("https://lista.mercadolivre.com.br/mac-book-air#D[A:mac%20book%20air]", force = TRUE)
html <- read_html('https://lista.mercadolivre.com.br/mac-book-air#D[A:mac%20book%20air]')
links.de.macbooks <- html %>% html_elements('.ui-search-results--without-disclaimer .ui-search-layout__item .ui-search-link') %>% html_attr('href')

# Filtrando urls com a função strsplit

link.separado <- strsplit(links.de.macbooks[1],'/')[[1]]

macbooks.mercadolivre <- array(NA)
macbooks.produto.mercadolivre <- array(NA)
indice.m <- 1
indice.p <- 1
for (link in links.de.macbooks){
  link.separado <- strsplit(link,'/')[[1]]
  if (link.separado[3] =="www.mercadolivre.com.br"){
    macbooks.mercadolivre[indice.m] <- link
    indice.m <- indice.m + 1
  }
  else{
    macbooks.produto.mercadolivre[indice.p] <- link
    indice.p <-  indice.p + 1

  }

}
## Trabalhando com as páginas referentes aos links do mercadolivre
## Criando funções para obter dados de interesse
html <- read_html(macbooks.mercadolivre[5])
### Título
html %>% html_elements('.mr-32 .ui-pdp-title')
### Preço
html %>% html_elements('.mr-32 .price-tag-text-sr-only') %>% html_text2()
### Processamento
html %>% html_elements('.mr-32 .ui-vpp-highlighted-specs__features-list') %>% html_children()

obter.informacoes.do.link.mercadolivre <- function(html){
  produto <- html %>% html_elements('.mr-32 .ui-pdp-title') %>% html_text2()
  preco <- html %>% html_elements('.mr-32 .price-tag-text-sr-only') %>% html_text2()
  caracteristicas <- html %>% html_elements('.mr-32 .ui-vpp-highlighted-specs__features-list') %>% html_text2()

  dataset <- data.frame(produto = produto, preco = preco[1],
                        sobre = glue(caracteristicas))
  return(dataset)
}

dados <- data.frame(produto = NaN, preco = NaN, sobre = NaN)

indice <- 1
for (link in macbooks.mercadolivre){
  html <- read_html(link)
  informacoes.do.produto <- obter.informacoes.do.link.mercadolivre(html)
  dados[indice,] <- informacoes.do.produto
  Sys.sleep(10)
  indice <- indice + 1
}
View(dados)
dados$preco
