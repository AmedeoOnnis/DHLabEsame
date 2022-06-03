# una volta effettuato lo scraping, si crea un file R che coinvolga 
# i file csv precedentemente creati

install.packages("cld2")
library(cld2)

install.packages("tidyverse")
library(tidyverse)

# si definisce dove cercare i file
fileGR <- list.files(path = "CorporaEsame", pattern = "Recensioni_", full.names = T)

# si fa una lettura di prova per verificare la corretta acquisizione
# dei file csv
dfGoodreads <- read.csv(fileGR[1], row.names = 1, stringsAsFactors = F)

# si prendono due delle categorie utili all'analisi, titolo e recensione
dfGoodreads <- dfGoodreads[,c("libro", "recensione")]

if(length(fileGR) > 1){
  
  for(i in 2:length(fileGR)){
    
    tempdfGR <- read.csv(fileGR[i], row.names = 1, stringsAsFactors = F)
    tempdfGR <- tempdfGR[,c("libro", "recensione")]
    
    dfGoodreads <- rbind(dfGoodreads, tempdfGR)
    
  }
  
}

# si escludono le recensioni vuote
dfGoodreads <- dfGoodreads[!is.na(dfGoodreads$recensione),]

# si aggiunge una lingua (in questo modo si potrà imporre solo quella
# che interessa)
dfGoodreads$language <- sapply(dfGoodreads$recensione, function(x) detect_language(text = x))

# si verifica la presenza di errori prima di procedere
rlang::last_error()

# queste statistiche sono utili per decidere quale lingua scegliere
dfGoodreads %>% count(language)

# si stringe il campo alle sole recensioni in inglese
dfGoodreads <- dfGoodreads %>% filter(language == "en")

dfGoodreads$language <- NULL

# salviamo il file R
save(dfGoodreads, file = "CorporaEsame/GoodreadsRecensioni.RData")
