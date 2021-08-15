# Operações básicas
1+1
1*2
2/2
sqrt(200)

vetor <- c(1, 2, 3, 4)
vetor*vetor
vetor%*%vetor
sum(vetor*vetor)
vetor <- 1:100
elemento.selecionado <- 10
vetor[elemento.selecionado]
mean(vetor)
sd(vetor)
var(vetor)
round(2.333, 2)

# Criando funções

tags <- c("p", "p", "div", rep("section", 10),
          rep("h2", 200), rep("form", 12), rep("h1", 50))
extrair.informacoes.do.html <- function(tags){

  tags.unicas <- unique(tags)
  frequencia.de.cada.tag <- table(tags)
  numero.de.tags <- sum(frequencia.de.cada.tag)

  resultado <- list()
  resultado$tags.unicas <- tags.unicas
  resultado$frequencia.de.cada.tag <- frequencia.de.cada.tag
  resultado$numero.de.tags <- numero.de.tags

  return(resultado)
}
informacoes <- extrair.informacoes.do.html(tags)
informacoes$frequencia.de.cada.tag

# Sintaxes e declarações importantes
numero.de.tags <- length(tags)
for (tag in 1:numero.de.tags){
  print(tags[tag])
}

tag <- 1
while (tag < 20){
  print(tags[tag])
  tag <- tag + 1
}
tag <- 1
while (tag < 40){
  if (tags[tag]=="p"){
    print(tags[tag])
  }
  else{

  }
  tag <- tag + 1
}

# Lendo e criando arquivos
dataset <- data.frame(tags = tags, index = 1:informacoes$numero.de.tags)
View(dataset)
getwd()
setwd('DiretorioDeInteresse')
sink("arquivo.csv")
write.csv(dataset)
sink()
