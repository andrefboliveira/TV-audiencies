# -----------------------------------------------------------------------------
# Integração e Processamento Analítico de Informação
#
#   André Oliveira - 45648
#   Maria Móteiro - 43178
#   Tânia Maldonado - 44745
#
# Projecto Audiências Televisivas
# 	Analisar dados e procurar erros
# -----------------------------------------------------------------------------

#install.packages("sqldf");
library("sqldf");
#library("lattice");

# -----------------------------------------------------------------------------

# Análise descritiva de todas as variáveis de dados existentes em cada ficheiro.

summary(audiencias);
summary(espetadores);
summary(classes);
summary(tipologia);
summary(todos.dados.pet);


# -----------------------------------------------------------------------------

# Procurar valores em falta / NA (mostra a linha da data frame com o valor em falta):

# Ficheiro Audiencias
audiencias[is.na(audiencias$ID),];
audiencias[is.na(audiencias$Data),];
audiencias[is.na(audiencias$Canal),];
audiencias[is.na(audiencias$Duracao),];
audiencias[is.na(audiencias$HoraInicio),];
audiencias[is.na(audiencias$HoraFim),];
# Devolve índices (n-1 se tiver cabeçalho) dos NA's
# print(NA_values <- sapply(audiencias, function(x) which(is.na(x))))   

# Ficheiro Espetadores
espetadores[is.na(espetadores$ID),];
espetadores[is.na(espetadores$Codigo),];
espetadores[is.na(espetadores$Regiao),];
espetadores[is.na(espetadores$Sexo),];
espetadores[is.na(espetadores$DonaDeCasa),];
espetadores[is.na(espetadores$EscalaoEtario),];
espetadores[is.na(espetadores$Classe),];
espetadores[is.na(espetadores$Data),];
# Devolve índices (n-1 se tiver cabeçalho) dos NA's
# print(NA_values <- sapply(espetadores, function(x) which(is.na(x)))) 

# Ficheiro Classes
classes[is.na(classes$Classe),];
classes[is.na(classes$Estatuto),];
classes[is.na(classes$Ocupacao),];

# Ficheiro Tipologia
tipologia[is.na(tipologia$Tipo),];
tipologia[is.na(tipologia$Designacao),];

# Ficheiros PET
todos.dados.pet[is.na(todos.dados.pet$Canal),];
todos.dados.pet[is.na(todos.dados.pet$HoraInicio),];
todos.dados.pet[is.na(todos.dados.pet$Duracao),];
todos.dados.pet[is.na(todos.dados.pet$Nome1),];
todos.dados.pet[is.na(todos.dados.pet$Nome2),];
todos.dados.pet[is.na(todos.dados.pet$Classificacao),];
todos.dados.pet[is.na(todos.dados.pet$Tipo),];
todos.dados.pet[is.na(todos.dados.pet$ParteTodo),];
todos.dados.pet[is.na(todos.dados.pet$Data),];


# -----------------------------------------------------------------------------

# Ordena os valores do ficheiros originais (antes de serem alterados) para permitir analisar os dados e perceber possiveis erros.
# Ordenado por cada um dos parâmetros.

# Ficheiro Audiencias
audiencias_original.sort.ID <- sqldf("SELECT * FROM audiencias_original ORDER BY ID");
audiencias_original.sort.Data <- sqldf("SELECT * FROM audiencias_original ORDER BY Data");
audiencias_original.sort.Canal <- sqldf("SELECT * FROM audiencias_original ORDER BY Canal");
audiencias_original.sort.Duracao <- sqldf("SELECT * FROM audiencias_original ORDER BY Duracao");
audiencias_original.sort.HoraInicio <- sqldf("SELECT * FROM audiencias_original ORDER BY HoraInicio");
audiencias_original.sort.HoraFim <- sqldf("SELECT * FROM audiencias_original ORDER BY HoraFim");

# Ficheiro Espetadores
espetadores_original.sort.ID <- sqldf("SELECT * FROM espetadores_original ORDER BY ID");
espetadores_original.sort.Codigo <- sqldf("SELECT * FROM espetadores_original ORDER BY Codigo");
espetadores_original.sort.Regiao <- sqldf("SELECT * FROM espetadores_original ORDER BY Regiao");
espetadores_original.sort.Sexo <- sqldf("SELECT * FROM espetadores_original ORDER BY Sexo");
espetadores_original.sort.DonaDeCasa <- sqldf("SELECT * FROM espetadores_original ORDER BY DonaDeCasa");
espetadores_original.sort.EscalaoEtario <- sqldf("SELECT * FROM espetadores_original ORDER BY EscalaoEtario");
espetadores_original.sort.Classe <- sqldf("SELECT * FROM espetadores_original ORDER BY Classe");
espetadores_original.sort.Data <- sqldf("SELECT * FROM espetadores_original ORDER BY Data");

# Ficheiro Classes
classes.sort.Classe <- sqldf("SELECT * FROM classes ORDER BY Classe");
classes.sort.Estatuto <- sqldf("SELECT * FROM classes ORDER BY Estatuto");
classes.sort.Ocupacao<- sqldf("SELECT * FROM classes ORDER BY Ocupacao");

# Ficheiro Tipologia
tipologia.sort.Tipo <- sqldf("SELECT * FROM tipologia ORDER BY Tipo");
tipologia.sort.Designacao <- sqldf("SELECT * FROM tipologia ORDER BY Designacao");

# Ficheiros PET
pet_data_original <- todos.dados.pet_original;
pet_data_original.sort.Canal <- sqldf("SELECT * FROM pet_data_original ORDER BY Canal");
pet_data_original.sort.HoraInicio <- sqldf("SELECT * FROM pet_data_original ORDER BY HoraInicio");
pet_data_original.sort.Duracao <- sqldf("SELECT * FROM pet_data_original ORDER BY Duracao");
pet_data_original.sort.Nome1 <- sqldf("SELECT * FROM pet_data_original ORDER BY Nome1");
pet_data_original.sort.Nome2 <- sqldf("SELECT * FROM pet_data_original ORDER BY Nome2");
pet_data_original.sort.Classificacao <- sqldf("SELECT * FROM pet_data_original ORDER BY Classificacao");
pet_data_original.sort.Tipo <- sqldf("SELECT * FROM pet_data_original ORDER BY Tipo");
pet_data_original.sort.ParteTodo <- sqldf("SELECT * FROM pet_data_original ORDER BY ParteTodo");
pet_data_original.sort.Data <- sqldf("SELECT * FROM pet_data_original ORDER BY Data");


# -----------------------------------------------------------------------------

# Ver as ligações/relações entre os dados:
pet_data_original <- todos.dados.pet_original;


espetadores_classes <- sqldf("SELECT * FROM espetadores, classes WHERE espetadores.Classe == classes.Classe");
espetadores_audiencias <- sqldf("SELECT * FROM espetadores, audiencias_original WHERE espetadores.ID == audiencias_original.ID");

# Não funcionam:
# audiencias_programa <- sqldf("SELECT * FROM audiencias_original, pet_data_original  WHERE audiencias_original.Canal == pet_data_original.Canal AND audiencias_original.Data == pet_data_original.Data");
# programa_tipo <- sqldf("SELECT * FROM pet_data_original, tipologia WHERE pet_data_original.Tipo == tipologia.Tipo");

# -----------------------------------------------------------------------------

# Procurar espetadores com o mesmo código que possam ter informações diferentes:
espetadores_details <- sqldf("SELECT DISTINCT espetadores.Codigo, espetadores.Sexo, espetadores.DonaDeCasa, espetadores.DonaDeCasa, espetadores.EscalaoEtario, espetadores.Classe FROM espetadores ORDER BY espetadores.Codigo");

