# -----------------------------------------------------------------------------
# Integração e Processamento Analítico de Informação
#
#   André Oliveira - 45648
#   Jacek
#   Tomás
#
# TV audiences project - Aditional data sources
# -----------------------------------------------------------------------------

rm(list=ls(all=TRUE))


setwd("./Data");


holidays <-
  read.table(file = "./holidays.tsv",
             header = TRUE,
             sep = "\t",
             fileEncoding = "UTF-8");

names(holidays) <- c("Date", "Day off", "Description");
holidays$Date <- as.Date(holidays$Date, "%d/%m/%Y");

setwd("..");