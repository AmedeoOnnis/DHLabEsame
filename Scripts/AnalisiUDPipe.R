install.packages("udpipe")
library(udpipe)

library(tidyverse)

load("CorporaEsame/GoodreadsRecensioni.RData")

# find models in the resources folder
list.files(path = "Materiali", pattern = "english", full.names = T)

# load the (english) model
udmodel <- udpipe_load_model(file = "Materiali/english-ewt-ud-2.4-190531.udpipe")

# then process the text
testoAnnotato <- udpipe(object = udmodel, x = dfGoodreads$recensione, doc_id = rownames(dfGoodreads), trace = T)
View(testoAnnotato)

# now everything is ready to perform (multi-language) SA!

# Example: multi-dimensional SA with SentiArt
# info: https://github.com/matinho13/SentiArt

# read SentiArt from resources folder
dizionario <- read.csv("Materiali/SentiArt_eng.csv", stringsAsFactors = F)
View(dizionario)

# note: Sentiart includes values per word (not lemma) in lowercase, so we need to lowercase the tokens in our text and perform the analysis on them
testoAnnotato$token_lower <- tolower(testoAnnotato$token)

# to avoid annotating stopwords, limit the analysis to meaningful content words
POS_sel <- c("NOUN", "VERB", "ADV", "ADJ", "INTJ") # see more details here: https://universaldependencies.org/u/pos/
testoAnnotato$token_lower[which(!testoAnnotato$upos %in% POS_sel)] <- NA

# use left_join to add multiple annotations at once
testoAnnotato <- left_join(testoAnnotato, dizionario, by = c("token_lower" = "word")) 

# now that the sentiment annotation is done, let's keep just the useful info 
testoAnnotato <- testoAnnotato[c(1,19:length(testoAnnotato))]
testoAnnotato$doc_id <- as.numeric(testoAnnotato$doc_id)

# replace NAs with zeros
testoAnnotato <- mutate(testoAnnotato, across(everything(), ~replace_na(.x, 0)))

View(testoAnnotato)

# get overall values per review
frasiAnnotate <- testoAnnotato %>%
  group_by(doc_id) %>%
  summarise_all(list(mean = mean))

# let's order the reviews by number
frasiAnnotate <- frasiAnnotate[order(as.numeric(frasiAnnotate$doc_id)),]

# now we can join the annotations to the original dataframe 
dfGoodreadsAnnotato <- cbind(dfGoodreads, frasiAnnotate[,2:length(frasiAnnotate)])
View(dfGoodreadsAnnotato)
