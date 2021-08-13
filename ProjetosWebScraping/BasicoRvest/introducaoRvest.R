# Carregando os pacotes necessários
library(tidyverse)
library(rvest)

# Estrutura mínima de uma página HTML
html <- minimal_html(
  "<html>
    <body>
      <section id = 'Quarto'>
        <div class = 'Guarda-roupa'>
          <h1>Itens do Guarda-roupa<h1>
          <p>Camisas</p>
          <p>Camisetas</p>
          <p>Camisetas</p>
          <div class = 'Caixa-de-joias'>
            <h1>Itens da Caixa-de-joia</h1>
            <p>Diamantes</p>
            <p>Pérolas</p>
            <p>Colares</p>
          </div>
        </div>

        <div class= 'Cama'>
          <h1> Itens da Cama</h1>
          <p>Cochão</p>
          <p>Lençol</p>
          <p>Cobertor</p>
        </div>
      </section>

      <section id = 'Cozinha'>
        <div class = 'Pia'>
          <h1>Itens da pia</h1>
          <p>Pratos</p>
          <p>Colheres</p>
          <a href ='www.facas.com.br'>Facas</a>
        </div>

        <div class = 'Geladeira'>
          <h1>Itens da Geladeira</h1>
          <p>Sorvete</p>
          <p>Queijo</p>
          <p>Leite</p>
        </div>
      </section>

      <section id = 'Sala'>
        <div class = 'Moveis'>
          <h1>Moveis da sala</h1>
          <p class = 'Azul'>Sofa</p>
          <p class = 'Preto'>Sofa</p>
          <p>Poltrona</p>
        </div>
      </section>

      <section id = 'Varanda'>
        <h1>Itens da Varanda</h1>
        <p> Churrasqueira</p>
        <p>  Bancos</p>
        <p>   Rede</p>
      </section>
    </body>
  </html>")

# Extraindo dados do HTML
## Obtendo atributos das tags
atributos.das.divs.do.html <- html %>% html_elements('div') %>% html_attrs()
atributos.das.sections.do.html <- html %>% html_elements('section') %>% html_attrs()
atributo.da.cozinha <- html %>% html_elements('#Cozinha a') %>% html_attr('href')


## Obtendo textos e selecionando tags através de ids e classes
nomes.dos.elementos.da.varanda.com.espaco <- html %>% html_elements('#Varanda p') %>% html_text()
nomes.dos.elementos.da.varanda.sem.espaco <- html %>% html_elements('#Varanda p') %>% html_text(trim = T)
nomes.dos.elementos.da.sala <- html %>% html_elements('#Sala p') %>% html_text()
nomes.dos.elementos.da.varanda <- html %>% html_elements('#Varanda p') %>% html_text2()

## Obtendo textos utilizando a função children
nomes.dos.elementos.do.quarto <- html %>% html_elements('#Sala') %>% html_children()
elemento.unico.do.html <- html %>% html_elements('#Cozinha') %>% html_element('h1')

## Obtendo nome
nome.da.tag <- html %>% html_elements('#Sala') %>% html_children() %>% html_name()

# Enconding (Exemplo documentação Rvest)
path <- system.file("html-ex", "bad-encoding.html", package = "rvest")
x <- read_html(path)
x %>% html_elements("p") %>% html_text()
html_encoding_guess(x)
read_html(path, encoding = "ISO-8859-1") %>% html_elements("p") %>% html_text()
read_html(path, encoding = "ISO-8859-2") %>% html_elements("p") %>% html_text()

# Trabalhando com tabelas
tabela.de.precos <- minimal_html("
  <table>
    <tr><th>Produtos</th><th>Preço</th></tr>
    <tr><td>Refrigerante</td><td>10</td></tr>
    <tr><td>Leite</td><td>4</td></tr>
    <tr><td>Frios</td><td>2.80</td></tr>
  </table>")

dados <- as.data.frame(tabela.de.precos %>% html_element("table") %>% html_table())
dados$Produtos
mean(dados$Preço)

# Sessões
s <- session("http://hadley.nz")
s %>% session_jump_to("hadley-wickham.jpg") %>% session_jump_to("/") %>% session_history()
s %>% read_html() %>% html_elements('a')
s %>% session_follow_link(css = "p a") %>% html_elements("p")

# Trabalhando com formulários (Códigos baseados na documentação do Rvest)

html <- read_html("http://www.google.com")
search <- html_form(html)[[1]]
search <- search %>% html_form_set(q = "My little pony", hl = "en")
if (FALSE) {
  resp <- html_form_submit(search)
  read_html(resp)
}
