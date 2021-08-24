library(tidyverse)
library(rvest)
library(polite)
library(glue)
# Pesquisa: exchange rate | debt
# Passo 1: Analise o arquivo robots.txt e veja se você pode utilizar
#o site
bow('https://www.cardinali.com.br/pesquisa-de-imoveis/locacao_venda=L&id_cidade[]=190&id_tipo_imovel[]=8&id_bairro[]=190&id_bairro[]=478&finalidade=residencial&dormitorio=2&garagem=1&vmi=1.000%2C00&vma=2.000%2C00&&pag=1', force = T)
# Passo 2: Analise o site buscando as principais tags e atributos

# Passo 3: Criação dos códigos
url <- 'https://www.cardinali.com.br/pesquisa-de-imoveis/locacao_venda=L&id_cidade[]=190&id_tipo_imovel[]=8&id_bairro[]=190&id_bairro[]=478&finalidade=residencial&dormitorio=2&garagem=1&vmi=1.000%2C00&vma=2.000%2C00&&pag=2'
html <- read_html(url)
href.dos.imoveis <- html %>% html_elements('.row .item .imagem-imovel .owl-theme a') %>% html_attr('href')
href.dos.imoveis <- as.matrix(unique(href.dos.imoveis))
urls.completos <- apply(href.dos.imoveis, MARGIN = 1, FUN = function(href) glue('https://www.cardinali.com.br/{href}'))

obter.urls.completos <- function(url){

  html <- read_html(url)
  href.dos.imoveis <- html %>% html_elements('.row .item .imagem-imovel .owl-theme a') %>% html_attr('href')
  href.dos.imoveis <- as.matrix(unique(href.dos.imoveis))
  urls.completos <- apply(href.dos.imoveis, MARGIN = 1, FUN = function(href) glue('https://www.cardinali.com.br/{href}'))

  return(urls.completos)
}
obter.urls.completos(url)
# Dado para coleta
dados <- data.frame(InfoPrecos = NaN, sinopse = NaN,
                    itens = NaN, link = NaN, codigo = NaN)

# Preparando funções para obter dados da pagina do imovel
html <- read_html(urls.completos[1])

informacao.de.precos <- html %>% html_elements('.row #prices ') %>% html_text2()
strsplit(informacao.de.precos, '\n')

sinopse.do.imovel <- html %>% html_elements('.row .main .col-md-6') %>% html_text2()
sinopse.do.imovel <- glue('{sinopse.do.imovel}')
strsplit(sinopse.do.imovel, ': ')

itens.do.imovel <- html %>% html_elements('.row .main .col-md-12') %>% html_text2()
itens.do.imovel <- glue(itens.do.imovel)

codigo <- html %>% html_elements('.row #property-id') %>% html_text2()
codigo <- strsplit(codigo, ': ')[[1]][2]

obtendo.informacoes.de.imoveis <- function(url){

  html <- read_html(url)

  informacao.de.precos <- html %>% html_elements('.row #prices ') %>% html_text2()

  sinopse.do.imovel <- html %>% html_elements('.row .main .col-md-6') %>% html_text2()
  sinopse.do.imovel <- glue(toString(sinopse.do.imovel))

  itens.do.imovel <- html %>% html_elements('.row .main .col-md-12') %>% html_text2()
  itens.do.imovel <- glue(toString(itens.do.imovel))

  codigo <- html %>% html_elements('.row #property-id') %>% html_text2()
  codigo <- strsplit(codigo, ': ')[[1]][2]


  resultado <- data.frame(InfoPrecos = informacao.de.precos,
                          sinopse = sinopse.do.imovel,
                          itens = itens.do.imovel,
                          link = url, codigo = codigo)
  return(resultado)
}
View(obtendo.informacoes.de.imoveis(urls.completos[1]))

# Criando o web crawler
indice <- 1
paginas <- 1:4
for (pagina in paginas){
  print(glue('Estou na página: {pagina}'))
  pagina.de.imoveis <- glue('https://www.cardinali.com.br/pesquisa-de-imoveis/locacao_venda=L&id_cidade[]=190&id_tipo_imovel[]=8&id_bairro[]=190&id_bairro[]=478&finalidade=residencial&dormitorio=2&garagem=1&vmi=1.000%2C00&vma=2.000%2C00&&pag={pagina}')
  urls.completos <- obter.urls.completos(pagina.de.imoveis)
  for (url in urls.completos){
    print(glue('Estou adicionando dados na linha: {indice}'))
    dados[indice,] <- obtendo.informacoes.de.imoveis(url)
    indice <- indice + 1
    Sys.sleep(10)
  }
  Sys.sleep(10)
}
View(dados)
# Preparando os dados para futuras análises
#dados <- read.csv('cardinali.csv', sep = ';')
precos <- dados$InfoPrecos
precos.de.locacao <- apply(as.matrix(precos), MARGIN = 1, FUN = function(precos){
  precos.separados <- strsplit(precos, '\n')[[1]]
  numero.de.precos <- length(precos.separados)
  print(precos.separados)
  if (numero.de.precos ==1){
    locacao <- strsplit(precos.separados, ': ')[[1]][2]
  }
  else{
    precos.separados.novamente <- strsplit(precos.separados[1], ': ')[[1]]
    numero.de.precos.separados.novamente <- length(precos.separados.novamente)
    if (numero.de.precos.separados.novamente == 4){
      locacao <- strsplit(precos.separados[1], ': ')[[1]][4]
    }
    else{
      locacao <- strsplit(precos.separados[1], ': ')[[1]][2]
    }
  }
  return(locacao)
})
precos.de.locacao
valor <- strsplit(precos.de.locacao[1][[1]], ',')[[1]][1]
strsplit(valor, '.')
valor.separado <- strsplit(valor, '')[[1]]
paste0(valor.separado[-2], collapse = '')
#strsplit(precos.de.locacao[1], ' ')[1]
dados.prontos <- apply(as.matrix(precos.de.locacao), MARGIN = 1, FUN = function(preco){
  preco.separado <- strsplit(preco, ' ')[1]
  valor <- strsplit(preco[[1]], ',')[[1]][1]
  valor.separado <- strsplit(valor, '')[[1]]
  valor.numerico <- as.numeric(paste0(valor.separado[-2], collapse = ''))

  return(valor.numerico)
})
dados$preco <- dados.prontos
View(dados)
plot(dados$preco)
