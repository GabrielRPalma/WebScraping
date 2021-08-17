#install.packages("jsonlite")
library("jsonlite")
# https://httpstatusdogs.com
# API do GitHub "https://github.com/GabrielRPalma.png"
dados.gabriel <-fromJSON('https://api.github.com/users/GabrielRPalma')
dados.gabriel$avatar_url
# Uso desse tipo de arquivo em sites
url <- 'https://projects.fivethirtyeight.com/election-2016/national-primary-polls/USA.json'
data <- fromJSON(url)
model <- data$D$model
View(model)

# Json

url <- 'https://www.tradingview.com/chart/?symbol=IBOV'
data <- fromJSON(url)
