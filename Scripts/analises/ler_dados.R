# -----------------------------------------------------------------------------
# Integração e Processamento Analítico de Informação
#
#   André Oliveira - 45648
#   Maria Móteiro - 43178
#   Tânia Maldonado - 44745
#
# Projecto Audiências Televisivas
# 	Importar dados
# -----------------------------------------------------------------------------

# install.packages("dplyr")
# install.packages("tidyr")

library(tools)
library(dplyr)
library(tidyr)

# Limpar ambiente
rm(list=ls(all=TRUE))


setwd("./Dados");


# -----------------------------------------------------------------------------
# Ler dados de audiencias

# Carregamento de ficheiro de dados para memória
audiencias_original  <-
  read.table(file = "./audiencias.csv", # Ficheiro da fonte de dados
             header = FALSE,          # Primeira linha tem dados
             sep = ",",               # Valores separados por vírgulas
             dec = ".",               # Separador decimal é um ponto
             comment.char = "");      # Cada linha só tem dados

# Atribuição de nomes inteligíveis a cada variável de dados.
names(audiencias_original) <- c("ID", "Data", "Canal", "Duracao", "HoraInicio", "HoraFim")

# Cópia da variável sem correção de valores
audiencias <- audiencias_original

# Processamento dos dados:

# Corrigir a interpretação de valores de datas e horas nas variáveis data, 
# horaInicio e horaFim. Notar a eliminação automática do símbolo “#” 
# antes e depois das datas.
audiencias$Data <- as.Date(audiencias$Data, "#%Y-%m-%d#");
audiencias$Canal <- factor(audiencias$Canal);


# audiencias$HoraInicio <-  strptime(audiencias$HoraInicio, format=#%Y-%m-%d %H:%M:%S#")
# audiencias$DataFim <-  strptime(audiencias$DataFim, format="#%Y-%m-%d %H:%M:%S#")


# Alteração do tipo da variável canal, de contínua para discreta. Apesar de 
# guardar apenas valores numéricos, eles representam identificadores de canais.
audiencias$ID <- factor(audiencias$ID);


audiencias_new <- audiencias[,  !(colnames(audiencias) %in% c("DataInicio", "HoraInicio", "DataFim", "HoraFim"))]
audiencias_new$DataHoraInicio <- strptime(paste(audiencias$DataInicio, audiencias$HoraInicio), format="%Y-%m-%d  %H:%M:%S")
audiencias_new$DataHoraFim <- strptime(paste(audiencias$DataFim, audiencias$HoraFim), format="%Y-%m-%d  %H:%M:%S")


# -----------------------------------------------------------------------------
# Ler dados de espetadores

# Carregamento de ficheiro de dados para memória
espetadores_original <-
  read.table(file = "./espetadores.csv", # Ficheiro da fonte de dados
             header = FALSE,          # Primeira linha tem dados
             sep = ",",               # Valores separados por vírgulas
             dec = ".",               # Separador decimal é um ponto
             comment.char = "");      # Cada linha só tem dados

# Atribuição de nomes inteligíveis a cada variável de dados.
names(espetadores_original) <- c("ID", "Codigo", "Regiao", "Sexo", "DonaDeCasa", "EscalaoEtario", "Classe", "Data")

# Cópia da variável sem correção de valores
espetadores <- espetadores_original


# Corrigir a interpretação de valores de datas na variável data.
# Notar a eliminação automática do símbolo # antes e depois das datas.
espetadores$Data <- as.Date(espetadores$Data, "#%Y-%m-%d#");

# Alteração de váriaveis discretas
espetadores$ID <- factor(espetadores$ID);
espetadores$Codigo <- factor(espetadores$Codigo);
espetadores$Regiao <- factor(espetadores$Regiao);
espetadores$Sexo <- factor(espetadores$Sexo);
espetadores$DonaDeCasa <- factor(espetadores$DonaDeCasa);
espetadores$EscalaoEtario <- factor(espetadores$EscalaoEtario);
espetadores$Classe <- factor(espetadores$Classe);


# -----------------------------------------------------------------------------
# Ler dados de Classes de espetadores

# Carregamento de ficheiro de dados para memória
classes <-
  read.table(file = "./classes.tsv",
             header = TRUE,
             sep = "\t");

# Atribuição de nomes inteligíveis a cada variável de dados.
names(classes) <- c("Classe", "Estatuto", "Ocupacao")


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
               fill = TRUE);
  
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
todos.dados.pet_original <- todos.dados.pet

# Alteração do tipo das variáveis ParteTodo e Canal, de contínuas para discretas.
todos.dados.pet$Canal <- factor(todos.dados.pet$Canal);
todos.dados.pet$ParteTodo <- factor(todos.dados.pet$ParteTodo);
todos.dados.pet$HoraInicio <- format(strptime(sprintf("%06.0f", todos.dados.pet$HoraInicio), format="%H%M%S"), format="%H:%M:%S")

# Alternative. to show full date:
# hora <- sprintf("%06.0f", todos.dados.pet$HoraInicio);
# todos.dados.pet$HoraInicio <- strptime(paste(todos.dados.pet$Data, hora), format="%Y-%m-%d %H%M%S")


# Mudar para a pasta original e gravar todos os dados PET num único ficheiro:
setwd("..");

write.table(todos.dados.pet,
	file = "todos-dados-pet.tsv",
	sep = "\t",                   # Campos separados por tabulações.
	row.names = FALSE,            # Não mostrar números de linhas.
	col.names = TRUE);            # Nomes dos campos na primeira linha.

setwd("..");

# -----------------------------------------------------------------------------


