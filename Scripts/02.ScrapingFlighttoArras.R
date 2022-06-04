# si esegue lo stesso processo del primo scraping, stavolta con un
# altro libro, che ci servirà per il confronto nella sentiment analysis

# install.packages("rvest") = il pacchetto è già installato,
# basta chiamarlo
library('rvest')

link_FtA <- "https://www.goodreads.com/book/show/157996.Flight_to_Arras"

FtAdoc <- read_html(link_FtA)

FtAdoc %>% html_nodes(xpath = "//div[@class='friendReviews elementListBrown']")

recensioniCompleteFtA <- FtAdoc %>% html_nodes(xpath = "//div[@class='friendReviews elementListBrown']")

recensioniFtA <- character()
autoriFtA <- character()
dateFtA <- character()
stelleFtA <- character()

for(i in 1:length(recensioniCompleteFtA)){
  
  recensioniFtA[i] <- recensioniCompleteFtA[[i]] %>% html_node(css = "[style='display:none']") %>% html_text()
  autoriFtA[i] <- recensioniCompleteFtA[[i]] %>% html_node(css = "[class='user']") %>% html_text()
  dateFtA[i] <- recensioniCompleteFtA[[i]] %>% html_node(css = "[class='reviewDate createdAt right']") %>% html_text()
  stelleFtA[i] <- recensioniCompleteFtA[[i]] %>% html_node(css = "[class='staticStar p10']") %>% html_text()
  
}

testoFtA <- gsub(pattern = "https://www.goodreads.com/book/show/", replacement = "", link_FtA, fixed = T)

dfRecensioniCompleteFtA <- data.frame(libro = testoFtA, autore = autoriFtA, data = dateFtA, recensione = recensioniFtA, stelle = stelleFtA)

autoriFtA[2]

write.csv(dfRecensioniCompleteFtA, file = paste("CorporaEsame/Recensioni_", testoFtA, ".csv", sep = ""))
