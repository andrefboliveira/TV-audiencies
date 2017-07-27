# -----------------------------------------------------------------------------
# Integração e Processamento Analítico de Informação
#
#   André Oliveira - 45648
#   Maria Móteiro - 43178
#   Tânia Maldonado - 44745
#
# Projecto Audiências Televisivas
# 	Cria a tabela de factos com base nas audiências
# -----------------------------------------------------------------------------

rm(list=ls(all=TRUE))

library("tidyr")
library("sqldf");


setwd("./Dados");

# -----------------------------------------------------------------------------
# Correspondias com Dimensão

# Espectador
espetadores <-
  read.table(file = "./Dimensoes/correspondencia_espetador.tsv",
             header = TRUE,
             sep = "\t");

names(espetadores) <- c("ID", "Codigo", "ChaveSubstituta", "ChaveSuperNatural", "DataInicio", "DataFim", "EmVigor")

espetadores <- espetadores[, c("ID", "ChaveSubstituta")]

# Programa
programas <-
  read.table(file = "./Dimensoes/correspondencia_programa.tsv",
             header = TRUE,
             sep = "\t");

names(programas)[1] <- "ChaveSubstituta"

programas$DataHoraInicio<- as.POSIXct(programas$DataHoraInicio, "GMT", "%Y-%m-%d %H:%M:%S")
programas$DataHoraFim<- as.POSIXct(programas$DataHoraFim, "GMT", "%Y-%m-%d %H:%M:%S")

# -----------------------------------------------------------------------------
# Ler dados de audiencias

# Carregamento de ficheiro de dados para memória
audiencias  <-
  read.table(file = "./audiencias.csv", # Ficheiro da fonte de dados
             header = FALSE,          # Primeira linha tem dados
             sep = ",",               # Valores separados por vírgulas
             dec = ".",               # Separador decimal é um ponto
             comment.char = "");      # Cada linha só tem dados

# Atribuição de nomes inteligíveis a cada variável de dados.
names(audiencias) <- c("ID", "Data", "Canal", "Duracao", "HoraInicio", "HoraFim")

audiencias <- audiencias[audiencias$ID %in% espetadores$ID, ]

# Adiciona o campo meia noite às horas quando este falta
audiencias$Data <- as.Date(audiencias$Data, "#%Y-%m-%d#");
audiencias <- separate(audiencias, "HoraInicio", c("DataInicio", "HoraInicio"), " ")
audiencias$DataInicio <- gsub("#", "", audiencias$DataInicio)
audiencias$HoraInicio <- gsub("#", "", audiencias$HoraInicio)
audiencias$HoraInicio[is.na(audiencias$HoraInicio)] <- "00:00:00"

audiencias <- separate(audiencias, "HoraFim", c("DataFim", "HoraFim"), " ")
audiencias$DataFim <- gsub("#", "", audiencias$DataFim)
audiencias$HoraFim <- gsub("#", "", audiencias$HoraFim)
audiencias$HoraFim[is.na(audiencias$HoraFim)] <- "00:00:00"


audiencias$DataHoraInicio<- as.POSIXct(paste(audiencias$DataInicio, audiencias$HoraInicio), "GMT", "%Y-%m-%d %H:%M:%S")
audiencias$DataHoraFim<- as.POSIXct(paste(audiencias$DataFim, audiencias$HoraFim), "GMT", "%Y-%m-%d %H:%M:%S")
audiencias <- audiencias[,  !(colnames(audiencias) %in% c("DataInicio", "HoraInicio", "DataFim", "HoraFim"))]

# Juntas as informações das audiências com espetadores e programas
sqldf("CREATE INDEX e_ID_Chave ON espetadores(ID, ChaveSubstituta); CREATE INDEX prog ON programas(Canal, DataHoraInicio, DataHoraFim, ChaveSubstituta); CREATE INDEX a_ID ON audiencias(ID);")
factos <- sqldf("SELECT e.ChaveSubstituta as Espetador, a.Canal, a.DataHoraInicio, a.DataHoraFim, a.Duracao FROM audiencias as a, espetadores as e WHERE (a.ID = e.ID);");
sqldf("CREATE INDEX fact ON factos(Canal, DataHoraInicio, DataHoraFim);")
factos <- sqldf("SELECT * FROM factos as f, programas as p WHERE (p.Canal = f.Canal AND p.DataHoraInicio < f.DataHoraFim AND p.DataHoraFim > f.DataHoraInicio);");

names(factos) <- c("Espetador", "Canal", "EspetadorInicio", "EspetadorFim", "Duracao", "Programa", "PCanal", "ProgramaInicio", "ProgramaFim");


factos$Inicio <- ifelse(factos$ProgramaInicio > factos$EspetadorInicio, as.character(factos$ProgramaInicio), as.character(factos$EspetadorInicio));
factos$Inicio<- as.POSIXct(factos$Inicio, "GMT", "%Y-%m-%d %H:%M:%S");
factos$Fim <- ifelse(factos$EspetadorFim > factos$ProgramaFim, as.character(factos$ProgramaFim), as.character(factos$EspetadorFim));
factos$Fim<- as.POSIXct(factos$Fim, "GMT", "%Y-%m-%d %H:%M:%S");
factos$Dur <- (factos$Fim - factos$Inicio);

factos <- factos[factos$Dur >= 60,];

# Transforma as datas nas chaves correspondentes
factos <- separate(factos, "Inicio", c("DataInicio", "HoraInicio"), " ")
factos$DataInicio <- gsub("-", "", factos$DataInicio)
factos$DataInicio <- as.numeric(factos$DataInicio);
factos$HoraInicio <- gsub(":", "", factos$HoraInicio)
factos$HoraInicio <- as.numeric(factos$HoraInicio);
factos <- separate(factos, "Fim",  c("DataFim", "HoraFim"), " ")
factos$DataFim <- gsub("-", "", factos$DataFim)
factos$DataFim <- as.numeric(factos$DataFim);
factos$HoraFim <- gsub(":", "", factos$HoraFim)
factos$HoraFim <- as.numeric(factos$HoraFim);

factos <- factos[, !(colnames(factos) %in% c("Canal", "EspetadorInicio", "EspetadorFim", "Duracao" , "PCanal", "ProgramaInicio", "ProgramaFim", "DataFim", "HoraFim"))]

names(factos) <- c("Espetador", "Programa", "Data Início", "Hora Início", "Duração");

write.table(factos,
            file = "./Dimensoes/factosAudiencias.tsv",
            sep = "\t",                   # Campos separados por tabulações.
            row.names = FALSE,            # Não mostrar números de linhas.
            col.names = TRUE)            # Nomes dos campos na primeira linha.

setwd("..")