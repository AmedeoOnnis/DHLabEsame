# UDPipe permette di tokenizzare un testo per effettuare la sentiment analysis
# basandosi su un dizionario di riferimento

# si installa e si chiama il pacchetto di UDPipe, si richiama anche Tidyverse
install.packages("udpipe")
library(udpipe)

library(tidyverse)

# si carica il file delle recensioni
load("CorporaEsame/GoodreadsRecensioni.RData")

# si carica un modello di riferimento nella lingua delle analisi (inglese)
list.files(path = "Materiali", pattern = "english", full.names = T)

udmodel <- udpipe_load_model(file = "Materiali/english-ewt-ud-2.4-190531.udpipe")

# si processa infine il testo per rintracciare le recensioni
testoAnnotato <- udpipe(object = udmodel, x = dfGoodreads$recensione, doc_id = rownames(dfGoodreads), trace = T)
View(testoAnnotato)

# una volta processato il testo, si carica un dizionario inglese
dizionario <- read.csv("Materiali/SentiArt_eng.csv", stringsAsFactors = F)

# si verifica il corretto caricamento
View(dizionario)

# si tokenizza il testo
testoAnnotato$token_lower <- tolower(testoAnnotato$token)

# si selezionano alcune categorie di parole piene, per evitare le 'stopwords'
POS_sel <- c("NOUN", "VERB", "ADV", "ADJ", "INTJ") # see more details here: https://universaldependencies.org/u/pos/
testoAnnotato$token_lower[which(!testoAnnotato$upos %in% POS_sel)] <- NA

testoAnnotato <- left_join(testoAnnotato, dizionario, by = c("token_lower" = "word")) 
testoAnnotato <- testoAnnotato[c(1,19:length(testoAnnotato))]
testoAnnotato$doc_id <- as.numeric(testoAnnotato$doc_id)

# si eliminano definitivamente, assegnando loro un valore 0, le stopwords
testoAnnotato <- mutate(testoAnnotato, across(everything(), ~replace_na(.x, 0)))

View(testoAnnotato)

# si ottengono le frasi correttamente tokenizzate
frasiAnnotate <- testoAnnotato %>%
  group_by(doc_id) %>%
  summarise_all(list(mean = mean))

# si riordinano le frasi annotate
frasiAnnotate <- frasiAnnotate[order(as.numeric(frasiAnnotate$doc_id)),]

# infine, si uniscono i valori delle frasi annotate con le rispettive frasi nel
# dataframe di partenza

dfGoodreadsAnnotato <- cbind(dfGoodreads, frasiAnnotate[,2:length(frasiAnnotate)])

# si visualizza il file: a ogni frase corrispondono valori per ciascuna emozione
View(dfGoodreadsAnnotato)
