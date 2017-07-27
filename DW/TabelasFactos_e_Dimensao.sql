USE IPAI07BD;


drop table factAudiencias;
drop table dimEspetador;
drop table dimPrograma;
drop table dimData;
drop table dimHorario;

-----------
CREATE TABLE dimEspetador (
   id NUMERIC(9,0),
  [chave supernatural espetador] NUMERIC (9,0),
  codigo NUMERIC(9,0) NOT NULL,
  genero NVARCHAR(MAX) NOT NULL,
  [escalao etario] NVARCHAR(MAX) NOT NULL,
  regiao NVARCHAR(MAX) NOT NULL,
  estatuto1 NVARCHAR(MAX) NOT NULL,
  ocupacao1 NVARCHAR(MAX) NOT NULL,
  estatuto2 NVARCHAR(MAX) NOT NULL,
  ocupacao2 NVARCHAR(MAX) NOT NULL,
  [dona de casa] NVARCHAR(MAX) NOT NULL,
  [data inicio] DATE,
  [data fim] DATE,
  [em vigor] NVARCHAR(MAX),
  constraint pk_dimEspetador
    primary key (id),
  constraint ck_dimEspetador_id
    check (id>0)
);

CREATE TABLE dimPrograma (
  id NUMERIC(9,0),
  [nome geral] NVARCHAR(MAX) NOT NULL,
  [nome especifico] NVARCHAR(MAX) NOT NULL,
  canal NUMERIC(2,0) NOT NULL,
  tipo NVARCHAR(MAX) NOT NULL,
  categoria NVARCHAR(MAX) NOT NULL,
  genero NVARCHAR(MAX) NOT NULL,
  constraint pk_dimPrograma
    primary key (id),
  constraint ck_dimPrograma_id
    check (id>0)
);

CREATE TABLE dimData (
  id NUMERIC(8,0),
  [data completa] DATE NOT NULL,      
  [dia do mes] NUMERIC(2,0) NOT NULL,
  mes NUMERIC(2,0) NOT NULL, 
  [nome do mes] NVARCHAR(MAX) NOT NULL,
  ano NUMERIC(4,0) NOT NULL,
  [dia da semana] NVARCHAR(MAX) NOT NULL,
  [semana do ano] NUMERIC(2,0) NOT NULL,
  [fim de semana] NVARCHAR(MAX) NOT NULL,
  [indicador feriado] NVARCHAR(MAX) NOT NULL,
  [indicador data comemorativa] NVARCHAR(MAX) NOT NULL,
  [nome data comemorativa] NVARCHAR(MAX) NOT NULL,
  constraint pk_dimData
    primary key (id),
  constraint ck_dimData
    check (id>0)
);

CREATE TABLE dimHorario (
  id NUMERIC(6,0),
  [horario completo] NVARCHAR(MAX) NOT NULL,
  [periodo do dia] NVARCHAR(MAX) NOT NULL,
  hora NUMERIC(2,0) NOT NULL,
  minutos NUMERIC(2,0) NOT NULL,
  segundos NUMERIC(2,0) NOT NULL,
  constraint pk_dimHorario
    primary key (id),
  constraint ck_dimHorario
    check (id>=0)
);


CREATE TABLE factAudiencias (
  espetador NUMERIC(9,0),
  programa NUMERIC(9,0),
  [data inicio] NUMERIC(8,0),
  [hora inicio]  NUMERIC(6,0),
  duracao NUMERIC(10,0) CONSTRAINT nn_factVenda_duracao NOT NULL,
--
  CONSTRAINT pk_factAudiencias
    PRIMARY KEY (espetador, programa, [data inicio], [hora inicio]),
--
  CONSTRAINT fk_factAudiencias_espetador
    FOREIGN KEY (espetador)
    REFERENCES dimEspetador(id),
--
  CONSTRAINT fk_factAudiencias_programa
    FOREIGN KEY (programa)
    REFERENCES dimPrograma(id),
--
  CONSTRAINT fk_factAudiencias_data
    FOREIGN KEY ([data inicio])
    REFERENCES dimData(id),
--
  CONSTRAINT fk_factAudiencias_horario
    FOREIGN KEY ([hora inicio])
    REFERENCES dimHorario(id)
);

