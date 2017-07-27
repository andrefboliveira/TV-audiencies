# -----------------------------------------------------------------------------
# Integração e Processamento Analítico de Informação
#
#   André Oliveira - 45648
#   Maria Móteiro - 43178
#   Tânia Maldonado - 44745
#
# Projecto Audiências Televisivas
# 	Cria modelos de aprendizagem automática (árvores de decisão) para os dados
#     obtidos do SQL server
# -----------------------------------------------------------------------------


# --------------------------------- Inicalização --------------------------------------------

rm(list=ls(all=TRUE))

# Permite a reproducibilidade, evitar variações dos números aleatórios
# install.packages("TeachingDemos")
library(TeachingDemos);
set.seed(char2seed("IPAI07", set = F));

# install.packages("rpart")
library(rpart);

# install.packages("maptree")
require(maptree)


# --------------------------------- Criar matrix de confusão e F-Score --------------------------------------------

# install.packages("e1071")
# install.packages("caret")
library("caret")

computarCM <- function(real, previsao){
  confusion_matrix <- confusionMatrix(previsao, real);
  table <- confusion_matrix$table;
  print(table);
  
  results <- confusion_matrix$byClass;
  results <- data.frame(results);
  precision <- results$Pos.Pred.Value;   
  recall <- results$Sensitivity;
  f_measure <- 2 * ((precision * recall) / (precision + recall))
  
  classes <- names(table[1,]);
  score <- cbind(classes, precision);
  score <- cbind(score, recall);
  score <- cbind(score, f_measure);
  score <- data.frame(score)
  
  average <- sapply(score[,-1], function(x) mean(as.numeric(levels(x))));
  average_row <- c("Média", average);
  names(average_row) <- names(score);
  score <- rbind(score, as.data.frame(t(average_row)))
  print(score)
  
}

# --------------------------------- Leitura dos dados --------------------------------------------
dados_audiencias <-
  read.table(file = "./Dados/data_mining.tsv",
             header = TRUE,
             sep = "\t",
             encoding="UTF-8");

names(dados_audiencias) <- c("espetador", "genero", "escalao_etario", "regiao", "estatuto1", "ocupacao1", "estatuto2", "ocupacao2", "dona_casa", "programa", "canal_programa_visto", "categoria_programa_visto", "data_completa", "horario_completo", "periodo_dia_programa_visto", "duracao_programa_visto", "classificacao");


# Verificar se há valores em falta
sapply(dados_audiencias, function(x) sum(is.na(x)))


Y <- "classificacao"
X <- c("espetador", "programa", "data_completa", "horario_completo")

todos_nomes <- names(dados_audiencias)
nomes_usar <- names(dados_audiencias[!todos_nomes %in% c(Y, X)])

formula <- as.formula(paste(paste(Y, "~"),
                      paste(nomes_usar, collapse=" + ")))



# --------------------------------- ARVORES --------------------------------------------

# --------------------------------- Todos os dados --------------------------------------------

# Gerar árvore de decisão com todos os dados
arvore_todos_dados <- rpart(formula,
                         data = dados_audiencias,
                         method = "class");

# Obter número de folhas da árvore e erro de classificação
summary(arvore_todos_dados);

# Desenhar árvore de decisão.
plot(arvore_todos_dados);
text(arvore_todos_dados, cex = 0.8, pretty=1);
title("Prever a categoria de programa mais visto por um espectador (Todos os dados)")

plot(arvore_todos_dados, uniform = TRUE, branch = 0.6, margin = 0.05);
text(arvore_todos_dados, cex = 0.8, pretty=1);
title("Prever a categoria de programa mais visto por um espectador (Todos os dados)")

# Desenho alternativo com todos os valores.
draw.tree(arvore_todos_dados)
title("Prever a categoria de programa mais visto por um espectador (Todos os dados)")

# Resultados Cross validation
printcp(arvore_todos_dados);
plotcp(arvore_todos_dados);


# ---

# Ver sumário de erros de classificação face aos dados iniciais.
tabela_resultado <- table(dados_audiencias$classificacao, predict(arvore_todos_dados, type = "class"));
tabela_resultado <- cbind(tabela_resultado, table(dados_audiencias$classificacao));
print(tabela_resultado);

# Obter dados mal classificados.
dados_audiencias[dados_audiencias$classificacao != predict(arvore_todos_dados, type = "class"), ];


# --------------------------------- Partição Conjunto treino - Conjunto teste --------------------------------------------

# Dividir o data set 
proporcao_treino <- 2/3


numero_linhas <- nrow(dados_audiencias)
index_treino <- sort(sample(1:numero_linhas, 
                           size = trunc(proporcao_treino*numero_linhas)));

dados_treino <- na.omit(dados_audiencias[index_treino,])
dados_teste <- na.omit(dados_audiencias[-index_treino,])


# Arvore com dados de treino
arvore_particao_dados <- rpart(formula,
                         data = dados_treino,
                         method = "class");

# Obter número de folhas da árvore e erro de classificação
summary(arvore_particao_dados);

# Desenhar árvore de decisão.
plot(arvore_particao_dados);
text(arvore_particao_dados, cex = 0.8, pretty=1);
title("Prever a categoria de programa mais visto por um espectador (Dados de Treino)")

plot(arvore_particao_dados, uniform = TRUE, branch = 0.6, margin = 0.05);
text(arvore_particao_dados, cex = 0.8, pretty=1);
title("Prever a categoria de programa mais visto por um espectador (Dados de Treino)")

# Desenho alternativo com todos os valores.
draw.tree(arvore_particao_dados)
title("Prever a categoria de programa mais visto por um espectador (Dados de Treino)")


printcp(arvore_particao_dados);
plotcp(arvore_particao_dados);


# --- Comparar com resultados de treino
print("Ver resultados de treino")
predictions.train <- predict(arvore_particao_dados, type = "class");

tabela_resultado_treino <- table(dados_treino$classificacao, predictions.train);
tabela_resultado_treino <- cbind(tabela_resultado_treino, table(dados_treino$classificacao));
print(tabela_resultado_treino);

dados_treino[dados_treino$classificacao != predictions.train, ];


# --- Ver resultados de teste
print("Comparar com resultados de teste")
dados_teste_sem_class <- subset(dados_teste, select = nomes_usar)
predictions.test <- predict(arvore_particao_dados, newdata = dados_teste_sem_class, type = "class");

tabela_resultado_teste <- table(dados_teste$classificacao, predictions.test);
tabela_resultado_teste <- cbind(tabela_resultado_teste, table(dados_teste$classificacao));
print(tabela_resultado_teste);

dados_teste[dados_teste$classificacao != predictions.test, ];


# Ver qualidade do modelo
comparar_resultados <- data.frame(real=dados_teste$classificacao, previsao=predictions.test);
computarCM(comparar_resultados$real, comparar_resultados$previsao)


# --------------------------------- Equilibrar Partições treino - teste --------------------------------------------


# install.packages("DMwR")
library(DMwR)

# Compara as proporções de observações de cada classe. Aumenta a proporção das classes mais raras por oversampling e undersampling
prop.table(table(dados_treino$classificacao))
dados_treino_SMOTE <- SMOTE(formula, dados_treino, perc.over = 200, perc.under=200);
prop.table(table(dados_treino_SMOTE$classificacao));

# Apenas lida com uma classificação rara de cada vez. Faz para a classificação seguinte
dados_treino_SMOTE_2 <- SMOTE(formula, dados_treino_SMOTE, perc.over = 300, perc.under=300);
prop.table(table(dados_treino_SMOTE_2$classificacao));

# Arvore usando um conjunto de dados mais equilibrado que o original
arvore_baleanceada <- rpart(formula,
                  data = dados_treino_SMOTE_2,
                  method = "class");

# Obter número de folhas da árvore e erro de classificação
summary(arvore_baleanceada);


# Desenhar árvore de decisão.
plot(arvore_baleanceada);
text(arvore_baleanceada, cex = 0.8, pretty=1);
title("Prever a categoria de programa mais visto por um espectador (Dados de Treino equilibrado)")

plot(arvore_baleanceada, uniform = TRUE, branch = 0.6, margin = 0.05);
text(arvore_baleanceada, cex = 0.8, pretty=1);
title("Prever a categoria de programa mais visto por um espectador (Dados de Treino equilibrado)")

# Desenho alternativo com todos os valores.
draw.tree(arvore_baleanceada)
title("Prever a categoria de programa mais visto por um espectador (Dados de Treino equilibrado)")


printcp(arvore_baleanceada);
plotcp(arvore_baleanceada);


# ---
print("Ver resultados de treino")
predictions.train_SMOTE_2 <- predict(arvore_baleanceada, type = "class");

tabela_resultado_treino_SMOTE_2 <- table(dados_treino_SMOTE_2$classificacao, predictions.train_SMOTE_2);
tabela_resultado_treino_SMOTE_2 <- cbind(tabela_resultado_treino_SMOTE_2, table(dados_treino_SMOTE_2$classificacao));
print(tabela_resultado_treino_SMOTE_2);

dados_treino_SMOTE_2[dados_treino_SMOTE_2$classificacao != predictions.train_SMOTE_2, ];


# ---
print("Comparar com resultados de teste")
predictions.test_SMOTE_2 <- predict(arvore_baleanceada, newdata = dados_teste_sem_class, type = "class");

tabela_resultado_teste_SMOTE_2 <- table(dados_teste$classificacao, predictions.test_SMOTE_2);
tabela_resultado_teste_SMOTE_2 <- cbind(tabela_resultado_teste_SMOTE_2, table(dados_teste$classificacao));
print(tabela_resultado_teste_SMOTE_2);


dados_teste[dados_teste$classificacao != predictions.test_SMOTE_2, ];

comparar_resultados_SMOTE_2 <- data.frame(real=dados_teste$classificacao, previsao=predictions.test_SMOTE_2);
computarCM(comparar_resultados_SMOTE_2$real, comparar_resultados_SMOTE_2$previsao)



# --------------------------------- Pruning da árvore --------------------------------------------


# Podar algumas folhas da árvore de decisão,

# valor_cp = arvore_baleanceada$cptable[which.min(arvore_baleanceada$cptable[,"xerror"]),"CP"];
# print(valor_cp);
valor_cp = 0.021;
arvore_baleanceada_podada <- prune(arvore_baleanceada, cp=valor_cp);


summary(arvore_baleanceada_podada);

# Desenhar nova árvore de decisão.
plot(arvore_baleanceada_podada);
text(arvore_baleanceada_podada, cex = 0.8, pretty=1);
title("Prever a categoria de programa mais visto por um espectador (árvore podada)")

plot(arvore_baleanceada_podada, uniform = TRUE, branch = 0.6, margin = 0.05);
text(arvore_baleanceada_podada, cex = 0.8, pretty=1);
title("Prever a categoria de programa mais visto por um espectador (árvore podada)")

# Desenho alternativo com todos os valores.
draw.tree(arvore_baleanceada_podada)
title("Prever a categoria de programa mais visto por um espectador (árvore podada)")


printcp(arvore_baleanceada_podada);
plotcp(arvore_baleanceada_podada);


# ---
print("Ver resultados de treino")
predictions.train_SMOTE_2_podado <- predict(arvore_baleanceada_podada, type = "class");

tabela_resultado_treino_SMOTE_2_podado <- table(dados_treino_SMOTE_2$classificacao, predictions.train_SMOTE_2_podado);
tabela_resultado_treino_SMOTE_2_podado <- cbind(tabela_resultado_treino_SMOTE_2_podado, table(dados_treino_SMOTE_2$classificacao));
print(tabela_resultado_treino_SMOTE_2_podado);

dados_treino_SMOTE_2[dados_treino_SMOTE_2$classificacao != predictions.train_SMOTE_2_podado, ];


# ---
print("Comparar com resultados de teste")
predictions.test_SMOTE_2_podado <- predict(arvore_baleanceada_podada, newdata = dados_teste_sem_class, type = "class");

tabela_resultado_teste_SMOTE_2_podado <- table(dados_teste$classificacao, predictions.test_SMOTE_2_podado);
tabela_resultado_teste_SMOTE_2_podado <- cbind(tabela_resultado_teste_SMOTE_2_podado, table(dados_teste$classificacao));
print(tabela_resultado_teste_SMOTE_2_podado);

dados_teste[dados_teste$classificacao != predictions.test_SMOTE_2_podado, ];

comparar_resultados_SMOTE_2_podado <- data.frame(real=dados_teste$classificacao, previsao=predictions.test_SMOTE_2_podado);
computarCM(comparar_resultados_SMOTE_2_podado$real, comparar_resultados_SMOTE_2_podado$previsao)


# --------------------------------- Comparar com Random Forests --------------------------------------------


library(randomForest)
rf <- randomForest(formula, data = dados_audiencias)
print(rf) # view results 
importance(rf) # importance of each predictor