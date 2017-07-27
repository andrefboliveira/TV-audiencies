# -----------------------------------------------------------------------------
# Integração e Processamento Analítico de Informação
#
#   André Oliveira - 45648
#   Maria Móteiro - 43178
#   Tânia Maldonado - 44745
#
# Projecto Audiências Televisivas
# 	Cria a dimensão programa com base no ficheiros ficheiros pet e tipologia de programa
# -----------------------------------------------------------------------------

rm(list=ls(all=TRUE))

library("tools")
library("stringr")



setwd("./Dados");
# -----------------------------------------------------------------------------

# Ler dados de Tipologia de programas

# Carregamento de ficheiro de dados para memória
tipologia <-
  read.table(file = "./tipologia.tsv",
             header = TRUE,
             sep = "\t");

# Atribuição de nomes inteligíveis a cada variável de dados.
names(tipologia) <- c("Tipo", "Designacao")




# -----------------------------------------------------------------------------
# Ler dados de Programação Televisiva

# Mudar para a pasta com os ficheiros PET.
setwd("./pet-1s96");

# Obter lista ordenada de todos os nomes de ficheiros PET de 1996.
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
               fill = TRUE,
               na.strings= c("", " "));
  
  # Criar um campo referente ao dia do ano em causa.
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
names(todos.dados.pet) <- c("Canal", "HoraInicio", "Duracao", "Zero", "Nome1", "Nome2", "Classificacao", "Tipo", "ParteTodo", "Data")

setwd("..");

# -----------------------------------------------------------------------------

programa <- todos.dados.pet

programa <- programa[programa$ParteTodo == 0,]
programa <- programa[, !(colnames(programa) %in% c("ParteTodo", "Zero"))]

programa$Nome1 <- str_trim(programa$Nome1)
programa$Nome2 <- str_trim(programa$Nome2)
programa$Tipo <- str_trim(programa$Tipo)


programa$Classificacao <- str_trim(programa$Classificacao)
programa <- programa[programa$Classificacao == "P",]
programa <- programa[, !(colnames(programa) %in% c("Classificacao"))]


programa <- programa[!(programa$HoraInicio < 20000),]
programa <- programa[!is.na(programa$HoraInicio),]
programa$Data[programa$HoraInicio >= 240000] <- programa$Data[programa$HoraInicio >= 240000] + 1
programa$HoraInicio <- apply(programa[, "HoraInicio", drop=FALSE], 1, function(x) ifelse(x<240000, x, x-240000))
programa$HoraInicio <- format(strptime(sprintf("%06.0f", programa$HoraInicio), format="%H%M%S"), format="%H:%M:%S")


programa$Tipo_1 <- substr(programa$Tipo,1,1)
programa$Tipo_2 <- substr(programa$Tipo,1,2)
programa$Tipo_3 <- substr(programa$Tipo,1,3)

programa$Tipo_1[nchar(programa$Tipo_1) != 1] <- NA
programa$Tipo_2[nchar(programa$Tipo_) != 2] <- NA
programa$Tipo_3[nchar(programa$Tipo_3) != 3] <- NA

programa <- programa[, !(colnames(programa) %in% c("Tipo"))]

programa <- merge(programa, tipologia, by.x = "Tipo_1", by.y = "Tipo", all.x = T)
names(programa)[names(programa)=="Designacao"] <- "Tipo 1"

programa <- merge(programa, tipologia, by.x = "Tipo_2", by.y = "Tipo", all.x = T)
names(programa)[names(programa)=="Designacao"] <- "Tipo 2"

programa <- merge(programa, tipologia, by.x = "Tipo_3", by.y = "Tipo", all.x = T)
names(programa)[names(programa)=="Designacao"] <- "Tipo 3"

programa <- programa[, !(colnames(programa) %in% c("Tipo_1", "Tipo_2", "Tipo_3"))]


programa$DataHoraInicio <- paste(programa$Data, programa$HoraInicio)
programa$DataHoraInicio <- as.POSIXct(programa$DataHoraInicio, "GMT", "%Y-%m-%d %H:%M:%S")
programa$DataHoraFim <- programa$DataHoraInicio + programa$Duracao

programa$Nome1 <- programa$Nome1[!is.na(programa$Nome1)]



programa <- programa[order(programa$DataHoraInicio, programa$DataHoraFim),]
programa[,"Chave Substituta Programa"] <- 1:nrow(programa)

correspondencia_programa <- programa[, c("Chave Substituta Programa", "Canal",  "DataHoraInicio", "DataHoraFim")]

programa <- programa[, !(colnames(programa) %in% c("HoraInicio", "Duracao", "Data"))]
programa <- programa[, c(9, 2:3, 1, 4:6)]
names(programa) <- c("Chave Substituta Programa", "Nome Geral", "Nome Específico",  "Canal", "Tipo", "Categoria", "Género")

programa$`Nome Específico` <- as.character(programa$`Nome Específico` )
programa$`Nome Específico` [is.na(programa$`Nome Específico` )] <- "Nome Específico não definido"
programa$`Nome Específico`  <- factor(programa$`Nome Específico` )


programa$Tipo <- as.character(programa$Tipo )
programa$Tipo [is.na(programa$Tipo )] <- "Tipo não definido"
programa$Tipo  <- factor(programa$Tipo )

programa$Categoria <- as.character(programa$Categoria )
programa$Categoria [is.na(programa$Categoria )] <- "Categoria não definida"
programa$Categoria  <- factor(programa$Categoria )

programa$Género <- as.character(programa$Género )
programa$Género [is.na(programa$Género )] <- "Género não definido"
programa$Género  <- factor(programa$Género )

programa <- programa[order(programa$`Chave Substituta Programa`),]


write.table(programa,
            file = "./Dimensoes/dimPrograma.tsv",
            sep = "\t",                   # Campos separados por tabulações.
            row.names = FALSE,            # Não mostrar números de linhas.
            col.names = TRUE)            # Nomes dos campos na primeira linha.

write.table(correspondencia_programa,
            file = "./Dimensoes/correspondencia_programa.tsv",
            sep = "\t",                   # Campos separados por tabulações.
            row.names = FALSE,            # Não mostrar números de linhas.
            col.names = TRUE)            # Nomes dos campos na primeira linha.


setwd("..")