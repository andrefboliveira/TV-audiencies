use IPAI07BD;


DROP TABLE  #categoria_vista;
DROP TABLE  #espetador_classificacao;
DROP TABLE data_mining;

SELECT f.espetador, p.categoria, SUM(f.duracao) AS soma
INTO #categoria_vista
FROM factAudiencias AS f, dimPrograma AS p, dimData AS d
WHERE f.programa = p.id
	AND f.[data inicio] = d.id AND d.[data completa] BETWEEN  '1996-01-01' AND '1996-01-07'
GROUP BY f.espetador, p.categoria
ORDER BY f.espetador ASC, soma DESC;


SELECT c1.espetador, c1.categoria AS classificacao
INTO #espetador_classificacao 
FROM #categoria_vista AS c1
WHERE (c1.categoria = '"TELENOVELA"' OR c1.categoria = '"NOTICIARO"' OR c1.categoria = '"PROG. INF. JUVENIL"')
	AND c1.soma >= ALL (SELECT c2.soma
	FROM #categoria_vista AS c2
	WHERE c1.espetador = c2.espetador);
	


SELECT f.espetador, e.genero, e.[escalao etario], e.regiao, e.estatuto1, e.ocupacao1, e.estatuto2, e.ocupacao2, e.[dona de casa], 
	f.programa, p.canal, p.categoria, d.[data completa], h.[horario completo], h.[periodo do dia], f.duracao, c.classificacao
INTO data_mining
FROM factAudiencias AS f, dimEspetador AS e, dimPrograma AS p, dimData AS d, dimHorario AS h, #espetador_classificacao AS c
WHERE f.espetador = e.id AND f.programa = p.id AND f.[data inicio] = d.id AND c.espetador = f.espetador AND f.[hora inicio] = h.id AND
	f.espetador IN (SELECT espetador FROM #espetador_classificacao) AND f.programa = p.id AND 
	(p.categoria = '"TELENOVELA"' OR p.categoria = '"NOTICIARO"' OR p.categoria = '"PROG. INF. JUVENIL"') AND
	d.[data completa] BETWEEN  '1996-01-01' AND '1996-01-07'
ORDER BY f.espetador, d.[data completa], h.[horario completo];


SELECT * FROM data_mining;



