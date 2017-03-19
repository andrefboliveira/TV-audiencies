# -----------------------------------------------------------------------------
# Integração e Processamento Analítico de Informação
#
#   André Oliveira - 45648
#   Jacek Żyła - 49122
#   Tomás Peixinho - 43256
#
# TV audiences project - Check for errors in the data sources
# -----------------------------------------------------------------------------

#install.packages("sqldf");
library("sqldf");
#library("lattice");

# -----------------------------------------------------------------------------

# Statistics:

summary(audiencias);
summary(espetadores);
summary(classes);
summary(tipologia);
summary(todos.dados.pet);


# -----------------------------------------------------------------------------

# Check for missing values (display the lines with missing values):

# Audiencias File
audiencias[is.na(audiencias$ID),];
audiencias[is.na(audiencias$Data),];
audiencias[is.na(audiencias$Canal),];
audiencias[is.na(audiencias$Duracao),];
audiencias[is.na(audiencias$HoraInicio),];
audiencias[is.na(audiencias$HoraFim),];

# Espetadores File
espetadores[is.na(espetadores$ID),];
espetadores[is.na(espetadores$Codigo),];
espetadores[is.na(espetadores$Regiao),];
espetadores[is.na(espetadores$Sexo),];
espetadores[is.na(espetadores$DonaDeCasa),];
espetadores[is.na(espetadores$EscalaoEtario),];
espetadores[is.na(espetadores$Classe),];
espetadores[is.na(espetadores$Data),];

# Classes File
classes[is.na(classes$Classe),];
classes[is.na(classes$Estatuto),];
classes[is.na(classes$Ocupacao),];

# Tipologia File
tipologia[is.na(tipologia$Tipo),];
tipologia[is.na(tipologia$Designacao),];

# Pet Files
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

# Sort the values of the original files (before processing) to easier analyse the files content:

# Audiencias File
audiencias_original.sort.ID <- sqldf("SELECT * FROM audiencias_original ORDER BY ID");
audiencias_original.sort.Data <- sqldf("SELECT * FROM audiencias_original ORDER BY Data");
audiencias_original.sort.Canal <- sqldf("SELECT * FROM audiencias_original ORDER BY Canal");
audiencias_original.sort.Duracao <- sqldf("SELECT * FROM audiencias_original ORDER BY Duracao");
audiencias_original.sort.HoraInicio <- sqldf("SELECT * FROM audiencias_original ORDER BY HoraInicio");
audiencias_original.sort.HoraFim <- sqldf("SELECT * FROM audiencias_original ORDER BY HoraFim");

# Espetadores File
espetadores_original.sort.ID <- sqldf("SELECT * FROM espetadores_original ORDER BY ID");
espetadores_original.sort.Codigo <- sqldf("SELECT * FROM espetadores_original ORDER BY Codigo");
espetadores_original.sort.Regiao <- sqldf("SELECT * FROM espetadores_original ORDER BY Regiao");
espetadores_original.sort.Sexo <- sqldf("SELECT * FROM espetadores_original ORDER BY Sexo");
espetadores_original.sort.DonaDeCasa <- sqldf("SELECT * FROM espetadores_original ORDER BY DonaDeCasa");
espetadores_original.sort.EscalaoEtario <- sqldf("SELECT * FROM espetadores_original ORDER BY EscalaoEtario");
espetadores_original.sort.Classe <- sqldf("SELECT * FROM espetadores_original ORDER BY Classe");
espetadores_original.sort.Data <- sqldf("SELECT * FROM espetadores_original ORDER BY Data");

# Classes File
classes.sort.Classe <- sqldf("SELECT * FROM classes ORDER BY Classe");
classes.sort.Estatuto <- sqldf("SELECT * FROM classes ORDER BY Estatuto");
classes.sort.Ocupacao<- sqldf("SELECT * FROM classes ORDER BY Ocupacao");

# Tipologia File
tipologia.sort.Tipo <- sqldf("SELECT * FROM tipologia ORDER BY Tipo");
tipologia.sort.Designacao <- sqldf("SELECT * FROM tipologia ORDER BY Designacao");

# Pet Files
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

# See data connections:
pet_data_original <- todos.dados.pet_original;

espetadores_classes <- sqldf("SELECT * FROM espetadores, classes WHERE espetadores.Classe == classes.Classe");
espetadores_audiencias <- sqldf("SELECT * FROM espetadores, audiencias_original WHERE espetadores.ID == audiencias_original.ID");
# audiencias_programa <- sqldf("SELECT * FROM audiencias_original, pet_data_original  WHERE audiencias_original.Canal == pet_data_original.Canal");
# programa_tipo <- sqldf("SELECT * FROM pet_data_original, tipologia WHERE pet_data_original.Tipo == tipologia.Tipo");

# -----------------------------------------------------------------------------

# See viewers with same code and differente details:
espetadores_details <- sqldf("SELECT DISTINCT espetadores.Codigo, espetadores.Sexo, espetadores.DonaDeCasa, espetadores.DonaDeCasa, espetadores.EscalaoEtario, espetadores.Classe FROM espetadores ORDER BY espetadores.Codigo");

