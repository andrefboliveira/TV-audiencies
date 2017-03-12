rm(list=ls(all=TRUE))


audiencias <-
  read.table(file = "./Data/audiencias.csv",      # Ficheiro da fonte de dados
             header = FALSE,          # Primeira linha tem dados
             sep = ",",               # Valores separados por vírgulas
             dec = ".",               # Separador decimal é um ponto
             comment.char = "");      # Cada linha só tem dados

espetadores <-
  read.table(file = "./Data/espetadores.csv",      # Ficheiro da fonte de dados
             header = FALSE,          # Primeira linha tem dados
             sep = ",",               # Valores separados por vírgulas
             dec = ".",               # Separador decimal é um ponto
             comment.char = "");      # Cada linha só tem dados

classes <-
  read.table(file = "./Data/classes.tsv",
             header = TRUE,
             sep = "\t");

tipologia <-
  read.table(file = "./Data/tipologia.tsv",
             header = TRUE,
             sep = "\t")