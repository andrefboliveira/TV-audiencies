# -----------------------------------------------------------------------------
# Integração e Processamento Analítico de Informação
#
#   André Oliveira - 45648
#   Maria Móteiro - 43178
#   Tânia Maldonado - 44745
#
# Projecto Audiências Televisivas
# 	Processa as dimensões data e horário criadas no Excel, corrigindo a formatação conforme os tipos
# -----------------------------------------------------------------------------


rm(list=ls(all=TRUE))

setwd("./Dados/Dimensoes/");

# Data
data <-
  read.table(file = "./data.tsv",
             header = TRUE,
             sep = "\t");
# names(data) <- c("Chave Data", "Data Completa", "Ano", "Mês", "Dia", "Nome do Mês", "Semana do Ano", "Dia da Semana", "Fim de Semana", "Indicador Feriado", "Indicador Data Comemorativa", "Nome da Data Comemorativa")
names(data) <- c("Chave Data", "Data Completa", "Ano", "Mês", "Dia", "Nome do Mês", "Semana do Ano", "Nome do Dia da Semana", "Número do Dia da Semana", "Fim de Semana", "Indicador Feriado", "Indicador Data Comemorativa", "Nome da Data Comemorativa", "Dia da Semana")
data$`Data Completa` <-  as.Date(data$`Data Completa`, "%Y-%m-%d");

horario <-
  read.table(file = "./horario.tsv",
             header = TRUE,
             sep = "\t");
names(horario) <- c("Chave Horário", "Horario Completo", "Hora", "Minutos", "Segundos", "Período do Dia")

write.table(data,
            file = "./dimData.tsv",
            sep = "\t",                   # Campos separados por tabulações.
            row.names = FALSE,            # Não mostrar números de linhas.
            col.names = TRUE)            # Nomes dos campos na primeira linha.

write.table(horario,
            file = "./dimHorario.tsv",
            sep = "\t",                   # Campos separados por tabulações.
            row.names = FALSE,            # Não mostrar números de linhas.
            col.names = TRUE)            # Nomes dos campos na primeira linha.


setwd("./../../");