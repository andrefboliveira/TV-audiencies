# -----------------------------------------------------------------------------
# Integração e Processamento Analítico de Informação
#
#   André Oliveira - 45648
#   Maria Móteiro - 43178
#   Tânia Maldonado - 44745
#
# Projecto Audiências Televisivas
# 	Cria a dimensão espectador com base no ficheiro de espetadores e classes
# -----------------------------------------------------------------------------


rm(list=ls(all=TRUE))

library("tidyr")
library("sqldf");


setwd("./Dados");

# -----------------------------------------------------------------------------
# Ler dados de espetadores

# Carregamento de ficheiro de dados para memória
espetadores <-
  read.table(file = "./espetadores.csv", # Ficheiro da fonte de dados
             header = FALSE,          # Primeira linha tem dados
             sep = ",",               # Valores separados por vírgulas
             dec = ".",               # Separador decimal é um ponto
             comment.char = "",
             na.strings= c("", " "));      # Cada linha só tem dados

# Atribuição de nomes inteligíveis a cada variável de dados.
names(espetadores) <- c("ID", "Codigo", "Regiao", "Sexo", "DonaDeCasa", "EscalaoEtario", "Classe", "Data")

# Corrigir a interpretação de valores de datas na variável data.
# Notar a eliminação automática do símbolo # antes e depois das datas.
espetadores$Data <- as.Date(espetadores$Data, "#%Y-%m-%d#");

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
espetadores$EscalaoEtario <- gsub("\\+64", ">64", espetadores$EscalaoEtario)
espetadores$EscalaoEtario <- factor(espetadores$EscalaoEtario)

correspondencia_espetadores <- espetadores[, c("ID", "Codigo", "Data")]

# Remove os espetadores da região desconhecida
espetadores <- espetadores[espetadores$Regiao!="Regiao - Z",]

espetadores <- espetadores[order(espetadores$Codigo, espetadores$ID),]

# Remove espectadores duplicados (com exatamente a mesma informação)
# Regista se espectadores já existem mas têm novas informações
mudancas_lentas <- espetadores[!duplicated(espetadores[c("Codigo", "Regiao", "Sexo", "DonaDeCasa", "EscalaoEtario", "Classe")]),]
duplicados_index <- duplicated(mudancas_lentas$Codigo) | duplicated(mudancas_lentas$Codigo, fromLast = T)
duplicados <- mudancas_lentas[duplicados_index,]
duplicados <- duplicados[order(duplicados$Codigo, duplicados$ID),]
duplicados$DataFim <- NA
duplicados$EmVigor <- NA
duplicados$Adicionado <- NA

mudancas_lentas <- mudancas_lentas[!duplicados_index,]
mudancas_lentas$DataFim <- as.Date("1996-07-01", "%Y-%m-%d")
mudancas_lentas$EmVigor <- T
mudancas_lentas$Adicionado <- NA; 
sem_mudanca_num <- nrow(mudancas_lentas)

# Função verifica se as linhas de um espectador têm erros. Ignora se um espectador tiver menos de 2 linhas
verifica_sem_erros <- function(v){
  if(nrow(v) < 2){
    return(F)
  }
  
  escalao <- c("4-14", "15-24", "25-34", "35-44", "45-54", "55-64", ">64")

  for(j in 2:nrow(v)){
    n_anterior <- v[j-1,];
    n_atual <- v[j,];
    
    diff_escalao <- which(escalao == n_atual$EscalaoEtario) - (which(escalao == n_anterior$EscalaoEtario))
                                                
    if(diff_escalao < 0 | diff_escalao > 1){
      return(F);
    }
    if(n_atual$Sexo != n_anterior$Sexo){
      return(F);
    }
  }
  return(T);
}


# Adiciona os espectadores validos e com mudanças ao resto dos espectadores
novos_dados <- NA;

for(i in 2:nrow(duplicados)){
  anterior <- duplicados[i-1,];
  atual <- duplicados[i,];
  if (anterior$Codigo == atual$Codigo){
    novos_dados <- rbind(novos_dados, anterior);
  } else {
    novos_dados <- rbind(novos_dados, anterior);
    novos_dados <- novos_dados[!is.na(novos_dados$Codigo),]
    
    if(verifica_sem_erros(novos_dados)){

      for(j in 2:nrow(novos_dados)){
        novos_dados[j-1,]$DataFim <- as.character(novos_dados[j,]$Data - 1)
      }
      
      # Acrescenta informações para lidar com mudanças lentas
      novos_dados[2:nrow(novos_dados),]$Adicionado <- T;
      novos_dados[nrow(novos_dados),]$DataFim <- "1996-07-01";
      novos_dados[1:nrow(novos_dados)-1,]$EmVigor <- F;
      novos_dados[nrow(novos_dados),]$EmVigor <- T;
      novos_dados$DataFim <- as.Date(novos_dados$DataFim, "%Y-%m-%d");
      
      mudancas_lentas <- rbind(mudancas_lentas, novos_dados);
      
    }
    novos_dados <- NA;
    
  }
  
}

# Repete o processo para o ultimo elemento da lista
novos_dados <- rbind(novos_dados, atual);
novos_dados <- novos_dados[!is.na(novos_dados$Codigo),]

if(verifica_sem_erros(novos_dados)){

  for(j in 2:nrow(novos_dados)){
    novos_dados[j-1,]$DataFim <- as.character(novos_dados[j,]$Data - 1)
  }

  novos_dados[2:nrow(novos_dados),]$Adicionado <- T;
  novos_dados[nrow(novos_dados),]$DataFim <- "1996-07-01";
  novos_dados[1:nrow(novos_dados)-1,]$EmVigor <- F;
  novos_dados[nrow(novos_dados),]$EmVigor <- T;
  novos_dados$DataFim <- as.Date(novos_dados$DataFim, "%Y-%m-%d");

  mudancas_lentas <- rbind(mudancas_lentas, novos_dados);

}

mudancas_lentas$Adicionado[is.na(mudancas_lentas$Adicionado)] <- F

espetadores <- mudancas_lentas
espetadores <- espetadores[order(espetadores$Data, espetadores$Codigo, espetadores$ID),]

espetadores[,"Chave Substituta Espetador"] <- 1:nrow(espetadores)


espetadores["Chave Super Natural"] <- NA;
index_chave <- espetadores$Adicionado == F
espetadores$`Chave Super Natural`[index_chave] <- 1:length(which(index_chave))

# Adiciona Chaves Super Natural para identificar as várias linhas do mesmo espetador
sem_chave <- espetadores[is.na(espetadores$`Chave Super Natural`),]
for(i in 1:nrow(sem_chave)){
  linha <- sem_chave[i,]
  
  espetadores[espetadores$ID == linha$ID,]$`Chave Super Natural` <- espetadores[espetadores$Codigo == linha$Codigo & espetadores$Adicionado == F,]$`Chave Super Natural`
}

espetadores <- separate(espetadores, "Classe", c("Classe1", "Classe2"), "/")

espetadores <- merge(espetadores, classes, by.x = "Classe1", by.y = "Classe", all.x = T)
names(espetadores)[names(espetadores)  %in% c("Estatuto", "Ocupacao")] <- c("Estatuto1", "Ocupacao1")

espetadores <- merge(espetadores, classes, by.x = "Classe2", by.y = "Classe", all.x = T)
names(espetadores)[names(espetadores)  %in% c("Estatuto", "Ocupacao")] <- c("Estatuto2", "Ocupacao2")

espetadores$Estatuto1 <- as.character(espetadores$Estatuto1 )
espetadores$Estatuto1 [is.na(espetadores$Estatuto1 )] <- "Estatuto não definido"
espetadores$Estatuto1 <- gsub(",", "", espetadores$Estatuto1)
espetadores$Estatuto1  <- factor(espetadores$Estatuto1)

espetadores$Ocupacao1 <- as.character(espetadores$Ocupacao1 )
espetadores$Ocupacao1 [is.na(espetadores$Ocupacao1 )] <- "Ocupação não definida"
espetadores$Ocupacao1 <- gsub(",", "", espetadores$Ocupacao1)
espetadores$Ocupacao1  <- factor(espetadores$Ocupacao1)


espetadores$Estatuto2 <- as.character(espetadores$Estatuto2 )
espetadores$Estatuto2 [is.na(espetadores$Estatuto2 )] <- "Estatuto não definido"
espetadores$Estatuto2 <- gsub(",", "", espetadores$Estatuto2)
espetadores$Estatuto2  <- factor(espetadores$Estatuto2)

espetadores$Ocupacao2 <- as.character(espetadores$Ocupacao2 )
espetadores$Ocupacao2 [is.na(espetadores$Ocupacao2 )] <- "Ocupação não definida"
espetadores$Ocupacao2 <- gsub(",", "", espetadores$Ocupacao2)
espetadores$Ocupacao2  <- factor(espetadores$Ocupacao2)


# espetadores$Estatuto <- paste(espetadores$Estatuto1, espetadores$Estatuto2, sep = "; ")
# espetadores$Estatuto <- gsub("; NA", "", espetadores$Estatuto)
# espetadores$Estatuto <- factor(espetadores$Estatuto)
# 
# espetadores$Ocupacao <- paste(espetadores$Ocupacao1, espetadores$Ocupacao2, sep = "; ")
# espetadores$Ocupacao <- gsub("; NA", "", espetadores$Ocupacao)
# espetadores$Ocupacao <- factor(espetadores$Ocupacao)
# 
# espetadores <- espetadores[, !(colnames(espetadores) %in% c("Classe1", "Classe2", "Estatuto1", "Ocupacao1", "Estatuto2", "Ocupacao2"))]
espetadores <- espetadores[, !(colnames(espetadores) %in% c("Classe1", "Classe2"))]




espetadores$DonaDeCasa <- gsub("nDDC", "Não Dona de Casa", espetadores$DonaDeCasa)
espetadores$DonaDeCasa <- gsub("DDC", "Dona de Casa", espetadores$DonaDeCasa)
espetadores$DonaDeCasa <- factor(espetadores$DonaDeCasa)

espetadores$Sexo <- gsub("Masc.", "Masculino", espetadores$Sexo)
espetadores$Sexo <- gsub("Femin.", "Feminino", espetadores$Sexo)
espetadores$Sexo <- factor(espetadores$Sexo)

espetadores$Regiao <- gsub("Gr. Lisboa", "Grande Lisboa", espetadores$Regiao)
espetadores$Regiao <- gsub("Gr. Porto", "Grande Porto", espetadores$Regiao)
espetadores$Regiao <- gsub("Lit Norte", "Litoral Norte", espetadores$Regiao)
espetadores$Regiao <- gsub("Lit. Centro", "Litoral Centro", espetadores$Regiao)
espetadores$Regiao <- factor(espetadores$Regiao)

correspondencia_espetadores <- correspondencia_espetadores[correspondencia_espetadores$Codigo %in% espetadores$Codigo,]
names(espetadores)[11:12] <- c("Substituta", "Supernatural")

sqldf("CREATE INDEX ce_ID ON correspondencia_espetadores(ID); CREATE INDEX ce_Codigo ON correspondencia_espetadores(Codigo, Data); CREATE INDEX e_ID ON espetadores(ID); CREATE INDEX e_Codigo ON espetadores(Codigo, Data, DataFim);")
correspondencia_espetadores <- sqldf("SELECT ce.ID, ce.Codigo, e.Substituta, e.Supernatural, ce.Data, e.DataFim, e.EmVigor FROM correspondencia_espetadores as ce LEFT JOIN espetadores as e ON (ce.ID = e.ID OR (ce.Codigo = e.Codigo AND ce.Data >= e.Data AND ce.Data <= e.DataFim))");

names(correspondencia_espetadores) <- c("ID", "Codigo", "Chave Substituta Espetador", "Chave Super Natural", "Data Início", "Data Fim", "Em Vigor")

correspondencia_espetadores$`Data Início`<- as.Date(correspondencia_espetadores$`Data Início`, "%Y-%m-%d");
correspondencia_espetadores$`Data Fim` <- as.Date(correspondencia_espetadores$`Data Fim`, "%Y-%m-%d")
correspondencia_espetadores$`Em Vigor` <-  as.logical(correspondencia_espetadores$`Em Vigor`)

espetadores$EmVigor <- as.character(espetadores$EmVigor);

espetadores <- espetadores[, !(colnames(espetadores) %in% c("ID", "Adicionado"))]

espetadores <- espetadores[, c(9:10, 1, 3, 5, 2, 11:14, 4, 6:8)]
names(espetadores) <- c("Chave Substituta Espetador", "Chave Supernatural Espetador", "Codigo NK", "Género", "Escalão Etário", "Região", "Estatuto 1", "Ocupação 1", "Estatuto 2", "Ocupação 2", "Dona de Casa", "Data Início", "Data Fim", "Em Vigor")

espetadores <- espetadores[order(espetadores$`Chave Substituta Espetador`),]


write.table(espetadores,
            file = "./Dimensoes/dimEspectador.tsv",
            sep = "\t",                   # Campos separados por tabulações.
            row.names = FALSE,            # Não mostrar números de linhas.
            col.names = TRUE)            # Nomes dos campos na primeira linha.

write.table(correspondencia_espetadores,
            file = "./Dimensoes/correspondencia_espetador.tsv",
            sep = "\t",                   # Campos separados por tabulações.
            row.names = FALSE,            # Não mostrar números de linhas.
            col.names = TRUE)            # Nomes dos campos na primeira linha.

setwd("..")