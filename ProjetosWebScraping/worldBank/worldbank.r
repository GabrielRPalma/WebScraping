library(tidyverse)
library(rvest)
library(glue)
library(polite)
# Pesquisa: exchange rate | debt
# Passo 1: Analise o arquivo robots.txt e veja se você pode utilizar
#o site
bow('https://datacatalog.worldbank.org/search?search_api_views_fulltext_op=AND&query=debt&f%5B0%5D=field_license_wbddh%3A1335&sort_by=search_api_relevance&q=search&page=1%2C0', force =F)
# Passo 2: Analise o site buscando as principais tags e atributos

# Passo 3: Criação dos códigos
html <- read_html('https://datacatalog.worldbank.org/search?search_api_views_fulltext_op=AND&query=Debt&f%5B0%5D=field_license_wbddh%3A1335&sort_by=search_api_relevance&q=search&page=1%2C0')
hrefs.das.publicacoes <- html %>% html_elements('.view-content .node-dataset .node-title a') %>% html_attr('href')
urls.das.publicacoes <- apply(as.matrix(hrefs.das.publicacoes), MARGIN = 1, FUN = function(href) glue('https://datacatalog.worldbank.org{href}'))

obter.urls.das.paginas <- function(html){

  hrefs.das.publicacoes <- html %>% html_elements('.view-content .node-dataset .node-title a') %>% html_attr('href')
  urls.das.publicacoes <- apply(as.matrix(hrefs.das.publicacoes), MARGIN = 1, FUN = function(href) glue('https://datacatalog.worldbank.org{href}'))

  return(urls.das.publicacoes)
}
urls.de.paginas <- obter.urls.das.paginas(html)
# Dado para coleta
dados <- data.frame(tipo = NaN, lingua = NaN,
                    topicos = NaN, granularidade = NaN,
                    coberturaTemporal = NaN, Acesso = NaN,
                    link = NaN)

url <- urls.de.paginas[1]

checar.objeto.vazio <- function(objeto){
  if(identical(objeto, character(0))){
    objeto <- 'Sem dado'
  }
  else{
    objeto <- objeto
  }
  return(objeto)
}
obter.dados.da.pagina <- function(url){

  html <- read_html(url)
  tipo <- checar.objeto.vazio(html %>% html_elements('.tab-content #tab1 .pane-node-field-wbddh-data-type .field-items') %>% html_text2())
  lingua <- checar.objeto.vazio(html %>% html_elements('.tab-content #tab1 .pane-node-field-wbddh-languages-supported .field-items') %>% html_text2())
  topics <- checar.objeto.vazio(html %>% html_elements('.tab-content #tab1 .pane-node-field-topic .field-items') %>% html_text2())
  granularidade <- checar.objeto.vazio(html %>% html_elements('.tab-content #tab1 .pane-node-field-granularity-list .field-items') %>% html_text2())
  coberturaTemporal <- checar.objeto.vazio(html %>% html_elements('.tab-content #tab1 .pane-node-field-temporal-coverage .field-items') %>% html_text2())
  acesso <- checar.objeto.vazio(html %>% html_elements('.tab-content #tab1 .pane-ddh-dataset-list .field-items') %>% html_text2())

  resultado <- data.frame(tipo = tipo, lingua = lingua,
                          topicos = topics, granularidade = granularidade,
                          coberturaTemporal = coberturaTemporal, Acesso = acesso,
                          link = url)
  return(resultado)
}
View(obter.dados.da.pagina(url))
# Preparando a função para visitar várias páginas do site dada a pesquisa
## 1%2C0 1%2C1 1%2C2 1%2C3 1%2C4 1%2C5
# Para mais de uma palavra na pesquisa utilize o "+", por exemplo: debt + money
pesquisar.e.alterar.de.pagina <- function(pesquisa, pagina){
  url <- glue('https://datacatalog.worldbank.org/search?search_api_views_fulltext_op=AND&query={pesquisa}&f%5B0%5D=field_license_wbddh%3A1335&sort_by=search_api_relevance&q=search&page=1%2C{pagina}')

  return(url)
}
pesquisar.e.alterar.de.pagina(pesquisa = 'debt', pagina=0)

## Criando o web Crawler
indice <- 1
paginas <- c(0, 1, 2, 3, 4)
for (pagina in paginas){

  url <- pesquisar.e.alterar.de.pagina(pesquisa = 'debt', pagina=pagina)
  html <- read_html(url)
  urls.da.pagina <- obter.urls.das.paginas(html)
  Sys.sleep(10)
  print('Página escaneada e urls armazenados')
  print('Acessando cada conjunto de dados ...')

  for (url in urls.da.pagina){
    informacoes <- obter.dados.da.pagina(url)
    dados[indice,] <- informacoes
    Sys.sleep(10)
    indice <- indice + 1
  }


}
View(dados)
