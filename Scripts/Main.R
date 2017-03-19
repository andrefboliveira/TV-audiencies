#install.packages("sqldf");
library(tools)
library("sqldf");
#library("lattice");

rm(list=ls(all=TRUE))


setwd("./Data");

audiencias_original  <-
  read.table(file = "./audiencias.csv",      # Ficheiro da fonte de dados
             header = FALSE,          # Primeira linha tem dados
             sep = ",",               # Valores separados por vírgulas
             dec = ".",               # Separador decimal é um ponto
             comment.char = "");      # Cada linha só tem dados

names(audiencias_original) <- c("ID", "Data", "Canal", "Duracao", "HoraInicio", "HoraFim")
audiencias <- audiencias_original

audiencias$ID <- factor(audiencias$ID);
audiencias$Data <- as.Date(audiencias$Data, "#%Y-%m-%d#");
audiencias$Canal <- factor(audiencias$Canal);
audiencias$HoraInicio <- strptime(audiencias$HoraInicio, format="#%Y-%m-%d  %H:%M:%S#")
audiencias$HoraFim <- strptime(audiencias$HoraFim, format="#%Y-%m-%d  %H:%M:%S#")




espetadores_original <-
  read.table(file = "./espetadores.csv",      # Ficheiro da fonte de dados
             header = FALSE,          # Primeira linha tem dados
             sep = ",",               # Valores separados por vírgulas
             dec = ".",               # Separador decimal é um ponto
             comment.char = "");      # Cada linha só tem dados

names(espetadores_original) <- c("ID", "Codigo", "Regiao", "Sexo", "DonaDeCasa", "EscalaoEtario", "Classe", "Data")
espetadores <- espetadores_original

espetadores$ID <- factor(espetadores$ID);
espetadores$Codigo <- factor(espetadores$Codigo);
espetadores$Regiao <- factor(espetadores$Regiao);
espetadores$Sexo <- factor(espetadores$Sexo);
espetadores$DonaDeCasa <- factor(espetadores$DonaDeCasa);
espetadores$EscalaoEtario <- factor(espetadores$EscalaoEtario);
espetadores$Classe <- factor(espetadores$Classe);
espetadores$Data <- as.Date(espetadores$Data, "#%Y-%m-%d#");

classes <-
  read.table(file = "./classes.tsv",
             header = TRUE,
             sep = "\t");

names(classes) <- c("Classe", "Estatuto", "Ocupacao")


tipologia <-
  read.table(file = "./tipologia.tsv",
             header = TRUE,
             sep = "\t");

names(tipologia) <- c("Tipo", "Designacao")



# Mudar para a pasta com os ficheiros PET.
setwd("./pet-1s96");

# Obter lista ordenada de nomes de ficheiros PET referentes a janeiro de 1996.
ficheiros.pet <- sort(list.files(pattern = "1996[0-1][0-9][0-3][0-9].pet"),
                      decreasing = FALSE);

# Variável que vai guardar os dados provenientes dos ficheiros PET.
todos.dados.pet <- NA;

# Analisar todos os ficheiros PET em consideração.
for (pet.atual in ficheiros.pet) {
  
  # Mostrar o nome do ficheiro PET que vai ser processado.
  #print(pet.atual);
  
  # Ler os dados do ficheiro PET atual para uma variável própria.
  dados.pet.atual <-
    read.table(file = pet.atual,
               header = FALSE,
               sep = ",",
               quote = "\"",            # Retirar aspas de campos de texto.
               comment.char = ";",           # Ignorar ponto e vírgula no final.
               fill = TRUE);
  
  # Aqui pode ser conveniente acrescentar um campo extra a dados.pet.atual,
  # nomeadamente com a indicação do dia do ano em causa. Por exemplo, para
  # acrescentar um campo V10 com valor estático de 19960101 pode ser usado
  # dados.pet.atual <- cbind(dados.pet.atual, V10 = "19960101").
  dia <- as.Date(file_path_sans_ext(pet.atual), "%Y%m%d")
  dados.pet.atual <- cbind(dados.pet.atual, V10 = dia)
  # Adicionar dados do ficheiro PET atual aos que já haviam sido lidos.
  todos.dados.pet <- rbind(todos.dados.pet, dados.pet.atual);
}

# Apagar a primeira linha de dados, pois só contém valores NA (not available;
# ver inicialização de todos.dados.pet), e ajustar identificadores das linhas
# dos dados para que comecem em 1.
todos.dados.pet <- todos.dados.pet[-1, ];
rownames(todos.dados.pet) <- 1:nrow(todos.dados.pet);

# Aqui devem ser tornados mais inteligíveis os nomes dos campos de dados,
# conforme descrição no enunciado do projeto.
todos.dados.pet_original <- todos.dados.pet

names(todos.dados.pet) <- c("Canal", "HoraInicio", "Duracao", "Zero", "Nome1", "Nome2", "Classificacao", "Tipo", "ParteTodo", "Data")
todos.dados.pet$Canal <- factor(todos.dados.pet$Canal);
todos.dados.pet$ParteTodo <- factor(todos.dados.pet$ParteTodo);
#todos.dados.pet$HoraInicio <- format(strptime(sprintf("%06.0f", todos.dados.pet$HoraInicio), format="%H%M%S"), format="%H:%M:%S")
hora <- sprintf("%06.0f", todos.dados.pet$HoraInicio);

todos.dados.pet$HoraInicio <- strptime(paste(todos.dados.pet$Data, hora), format="%Y-%m-%d %H%M%S")
#### VERIFICAR


# Mudar para a pasta original.
setwd("..");

setwd("..")

# Pesquisa de linhas com dados sobre o canal 1 usando uma interrogação SQL.
dados <- sqldf("SELECT * FROM audiencias_original");

sqldf("SELECT * FROM audiencias_original AS a, espetadores AS e WHERE a.ID == e.ID")

full_table <- sqldf("SELECT * FROM espetadores_original AS e, tipologia AS t, audiencias_original AS a, classes AS c, todos.dados.pet_original AS pet WHERE a.ID == e.ID")