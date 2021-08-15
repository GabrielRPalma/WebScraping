library(tidyverse)
library(rvest)
library(glue)
# Passo 1: Analise o arquivo robots.txt e veja se você pode utilizar
#o site 'https://ssearch.oreilly.com/?all=0;i=1;q=economy&act=pg_viewall' para o projeto

# Passo 2: Analise o site buscando as principais tags e atributos

# Passo 3: Criação dos códigos
## Utilizando informações de API
setwd('/home/gabriel/Desktop/WebSpraping/code/ProjetosWebScraping/escolas/')
dados <- read.csv('dados.csv', sep = ';')
dados.de.portoVelho <- dados[dados$UF=='RO' & dados$Município=='Porto Velho',]
dados.de.portoVelho <- dados.de.portoVelho[is.na(dados.de.portoVelho$Latitude) == F,]

View(dados.de.portoVelho)
codigos <- dados.de.portoVelho$Código.INEP

## Análisando uma página e apresentando limitações
url <- 'http://idebescola.inep.gov.br/ideb/escola/dadosEscola/12015946'
html <- read_html(url)
div.de.complexidade <-html %>% html_elements('.detalhes-escola') %>% html_elements('#collapseOne')
div.de.complexidade %>% html_children()
html %>% html_elements('#collapseOne') %>% html_children()

html %>% html_element('.divRenderContainer') %>% html_table()

## Criando um novo banco de dados com rvest
dados <- data.frame(codigo = NaN, endereco = NaN,
                    bairro = NaN, cep = NaN,
                    Municipio = NaN, uf = NaN,
                    dependencia = NaN, localizacao = NaN,
                    localizacao.diferenciada = NaN)

## Preparando o web crawler
for (codigo in codigos[100:110]){
  print(glue('http://idebescola.inep.gov.br/ideb/escola/dadosEscola/{codigo}'))
}
html <- read_html('http://idebescola.inep.gov.br/ideb/escola/dadosEscola/12015946')
condicao <- html %>% html_elements('.btn-voltar') %>% html_text2()

## Preparando a função que irá obter os dados de interesse
obter.dados.da.tabela.disponivel <- function(html){
    tabela <- html %>% html_element('.divRenderContainer') %>% html_table()
    dataset <- as.data.frame(tabela)

    resultado <- list()
    resultado$dataset <- dataset$X2
    return(resultado)
}
obter.dados.da.tabela.disponivel(html)
index <- 1
for (codigo in codigos[100:110]){
  pagina.da.escola <- glue('http://idebescola.inep.gov.br/ideb/escola/dadosEscola/{codigo}')
  html <- read_html(pagina.da.escola)
  botoes.de.voltar <- html %>% html_elements('.btn-voltar') %>% html_text2()
  numero.de.botoes.de.voltar <- length(botoes.de.voltar)
  if (numero.de.botoes.de.voltar == 1){
    dados.da.escola <- obter.dados.da.tabela.disponivel(html)
    dados[index,] <- dados.da.escola$dataset
    index <- index + 1
  }
  else{
    print('Código não encontrado')
  }

  Sys.sleep(10)

}
View(dados)
