# il 'corpus' è stato creato, si possono svolgere le analisi

# si installano due pacchetti e si richiama il già installato tidyverse
install.packages("reshape2")
library(reshape2)

install.packages("syuzhet")
library(syuzhet)

library(tidyverse)

# si carica il corpus
load("CorporaEsame/GoodreadsRecensioni.RData")

# prima prova: quali sono le emozioni associate a una recensione?
get_nrc_sentiment(dfGoodreads$recensione[7])

# si aggiungono le emozioni di riferimento a tutte le recensioni
emotion_values <- data.frame()

for(i in 1:length(dfGoodreads$recensione)){
  
  emotion_values <- rbind(emotion_values, get_nrc_sentiment(dfGoodreads$recensione[i]))
  
}

dfGoodreads$length <- lengths(strsplit(dfGoodreads$recensione, "\\W"))

for(i in 1:length(dfGoodreads$recensione)){
  
  emotion_values[i,] <- emotion_values[i,]/dfGoodreads$length[i]
  
}

# si uniscono i due dataframe creati (recensioni e emozioni)
emozioniGoodreads <- cbind(dfGoodreads, emotion_values)

# facciamo il confronto tra i due libri
unique(dfGoodreads$libro)

libri <- unique(dfGoodreads$libro)[c(1,2)]
libri

dfGoodreads_red <- dfGoodreads %>% filter(libro %in% libri)
dfGoodreads$recensione <- NULL
dfGoodreads_red$length <- NULL

# primo grafico
dfGoodreads_red_mean <- dfGoodreads_red %>%
  group_by(libro) %>%
  summarise_all(list(mean = mean))

dfGoodreads_red_mean <- melt(dfGoodreads_red_mean)

# si visualizza il primo grafico
grafico1 <- ggplot(dfGoodreads_red_mean, aes(x=variable, y=value, fill=libro))+
  geom_bar(stat="identity", position = "dodge")
grafico1

# si salva il primo grafico
ggsave(grafico1, filename = "Grafici/GoodreadsGrafico1.png", height = 12, width = 18)

# secondo grafico
grafico2 <- ggplot(dfGoodreads_red_mean, aes(x=variable, y=value, fill=libro))+
  geom_bar(stat="identity", position = "dodge")+
  theme(axis.text.x = element_text(angle = 90, hjust=1))
grafico2

# si salva il grafico
ggsave(grafico2, filename = "Grafici/GoodreadsGrafico2.png", height = 12, width = 18, scale = 0.5)

dfGoodreads_red_mean <- melt(dfGoodreads_red)

# terzo grafico
grafico3 <- ggplot(dfGoodreads_red_mean, aes(x=variable, y=value, fill=libro))+
  geom_boxplot(position = "dodge")+
  theme(axis.text.x = element_text(angle = 90, hjust=1))
grafico3

# si salva il terzo grafico
ggsave(grafico3, filename = "Grafici/GoodreadsGrafico3.png", height = 12, width = 18, scale = 0.5)
