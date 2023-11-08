
-- Consulta 1 --
SELECT AVG(JSON_EXTRACT(cjson, '$.edad')) as PromedioEdad
FROM postulantes;

-- Consulta 2 --
SELECT x.puestos, count(*) AS Cantidad
FROM postulantes p
JOIN JSON_TABLE(
                 p.cjson,
                '$.aspiraciones[*]."puestos"[*]' COLUMNS (puestos VARCHAR(50) PATH '$')
       ) AS x
GROUP BY x.puestos
ORDER BY Cantidad;
-- Consulta 3 --
SELECT JSON_EXTRACT(cjson, '$.nombre') as Nombre, JSON_EXTRACT(cjson, '$.edad') as Edad, JSON_EXTRACT(cjson, '$.ciudad') as Ciudad, JSON_EXTRACT(cjson, '$.aspiraciones[*]." conocimientos"[*]') as Conociemientos
FROM postulantes
WHERE JSON_SEARCH(cjson, 'one', 'PHP', NULL, '$.aspiraciones[*]." lenguajes"[*]') IS NOT NULL;

-- Consulta 4 --
SELECT JSON_EXTRACT(cjson, '$.nombre') as Nombre, JSON_EXTRACT(cjson, '$.edad') as Edad, JSON_EXTRACT(cjson, '$.ciudad') as Ciudad
FROM postulantes
WHERE JSON_LENGTH(JSON_SEARCH(cjson, 'all', "Virtual", NULL,'$."experiencia laboral"[*].empresa.tipo'))= JSON_LENGTH(JSON_EXTRACT(cjson, '$."experiencia laboral"[*].empresa.tipo') );

-- Consulta 5 --

SELECT JSON_EXTRACT(cjson, '$.nombre') as Nombre, JSON_EXTRACT(cjson, '$."redes sociales"[*]') as Redes
FROM postulantes
WHERE (JSON_SEARCH(cjson, 'one', 'Java', NULL, '$."educación formal"[*].tema') IS NOT NULL) AND (JSON_SEARCH(cjson, 'one', 'Git', NULL, '$.aspiraciones[*]." conocimientos"[*]')  IS NOT NULL);


