# il primo passaggio da compiere è lo scraping, l'estrazione dei dati
# di cui abbiamo bisogno per l'analisi

# si installa il pacchetto rvest che consente lo scraping da pagine html
install.packages("rvest")

# se l'installazione va a buon fine, si chiama il pacchetto
library('rvest')

# si inserisce il link del primo libro da cui prendere i dati utili
link_NF <- "https://www.goodreads.com/book/show/8842.Night_Flight"

# si legge il file html come un file di R
NFdoc <- read_html(link_NF)

# si segnala dove trovare le informazioni all'interno del file
NFdoc %>% html_nodes(xpath = "//div[@class='friendReviews elementListBrown']")

# si identificano le categorie di dati che ci interessa raccogliere
recensioniCompleteNF <- NFdoc %>% html_nodes(xpath = "//div[@class='friendReviews elementListBrown']")

recensioniNF <- character()
autoriNF <- character()
dateNF <- character()
stelleNF <- character()

for(i in 1:length(recensioniCompleteNF)){
  
  recensioniNF[i] <- recensioniCompleteNF[[i]] %>% html_node(css = "[style='display:none']") %>% html_text()
  autoriNF[i] <- recensioniCompleteNF[[i]] %>% html_node(css = "[class='user']") %>% html_text()
  dateNF[i] <- recensioniCompleteNF[[i]] %>% html_node(css = "[class='reviewDate createdAt right']") %>% html_text()
  stelleNF[i] <- recensioniCompleteNF[[i]] %>% html_node(css = "[class='staticStar p10']") %>% html_text()
  
}

# si raggruppano i dati per le suddette categorie
testoNF <- gsub(pattern = "https://www.goodreads.com/book/show/", replacement = "", link_NF, fixed = T)

dfRecensioniCompleteNF <- data.frame(libro = testoNF, autore = autoriNF, data = dateNF, recensione = recensioniNF, stelle = stelleNF)

# si verifica il corretto inserimento delle categorie (e.g., autore)
autoriNF[3]

# si scrive un file csv con le recensioni
write.csv(dfRecensioniCompleteNF, file = paste("CorporaEsame/Recensioni_", testoNF, ".csv", sep = ""))
