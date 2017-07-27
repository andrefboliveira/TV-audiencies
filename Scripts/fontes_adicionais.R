# -----------------------------------------------------------------------------
# Integração e Processamento Analítico de Informação
#
#   André Oliveira - 45648
#   Maria Móteiro - 43178
#   Tânia Maldonado - 44745
#
# Projecto Audiências Televisivas
# 	Importar fontes adicionais
# -----------------------------------------------------------------------------

rm(list=ls(all=TRUE))


setwd("./Dados/Adicionais");


feriados <-
  read.table(file = "./feriados.tsv",
             header = TRUE,
             sep = "\t",
             fileEncoding = "UTF-8");

names(feriados) <- c("Data", "Feriado", "Descrição");
feriados$Data <- as.Date(feriados$Data, "%d/%m/%Y");

summary(feriados);

setwd("..");