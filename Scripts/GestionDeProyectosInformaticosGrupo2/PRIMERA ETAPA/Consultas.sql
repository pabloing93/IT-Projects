
DELETE
FROM lenguajes
WHERE nombre = 'Cobol';



/* 1.1. Nombre de los proyectos que produjeron al menos 10 productos distintos */

WITH productos_por_proyectos AS(
	SELECT DISTINCT f.cod_proyecto, COUNT(p.cod_producto) AS cantidad
    FROM fases f INNER JOIN genera g INNER JOIN productos p
		ON f.cod_proyecto = g.cod_proyecto AND g.cod_producto = p.cod_producto
	GROUP BY f.cod_proyecto
    HAVING cantidad >= 10
)

SELECT cod_proyecto
FROM productos_por_proyectos;

/* 1.2. Listar los pares (Producto 1, Producto 2) tales que Producto 1 fue producida por una fase que también produjo Producto 2 */

WITH id_productos AS (
	SELECT g.cod_producto, f.num_fase
	FROM fases f INNER JOIN genera g
		ON f.cod_proyecto = g.cod_proyecto
)

SELECT DISTINCT p1.cod_producto, p2.cod_producto
FROM id_productos p1 INNER JOIN id_productos p2
	ON p1.cod_producto != p2.cod_producto
WHERE p1.num_fase = p2.num_fase;

/* 1.3 Listar los nombres de los empleados involucrados en la fase que se haya asignado ningún recurso */

Por interpretación del Modelo Entidad Relación y analizando las cardinalidades entre las entidades, concluimos que no se puede realizar esta consulta dado que una fase siempre va a tener asignada al menos un recurso.
;
/*1.4 Listar  los  nombres  de  los  proyectos  privadas  que  no  lanzaron  ningún  producto del tipo prototipo  */



SELECT P.nombre FROM proyectos P
INNER JOIN fases F ON  P.cod_proyecto = F.cod_proyecto
INNER JOIN genera G ON F.cod_fase = G.cod_fase
WHERE G.cod_producto NOT IN (
    SELECT P.nombre FROM proyectos P
    INNER JOIN fases F ON P.cod_proyecto = F.cod_proyecto
    INNER JOIN genera G ON F.cod_fase = G.cod_fase
    INNER JOIN productos Pr ON g.cod_producto = Pr.cod_producto
    WHERE Pr.tipo = 'Prototipo' )

/*1.5. Listar los empleados (Informáticos) que hayan trabajado en todos los proyectos.  
*/

SELECT e.cod_empleado
FROM empleados e, proyectos p, gastos g, informaticos i
WHERE e.cod_gasto = g.cod_gasto AND e.cod_gasto = p.cod_gasto AND g.cod_gasto = p.cod_gasto AND i.cod_e = e.cod_empleado
GROUP BY e.cod_empleado
HAVING count(*) = (SELECT count(*) FROM proyectos);

-- 2.1. Nombre de los recursos que forman parte de al menos dos recursos distintos.
SELECT x.cod_recurso FROM (
    SELECT pd.cod_recurso,COUNT(pd.cod_recurso_compuesto)as total_recursos
    FROM parte_de pd GROUP BY pd.cod_recurso ) as x
WHERE x.total_recursos >= 2

-- 2.2. ídem 2.1 pero listando de que recursos forman parte
WITH recursos_R1 AS (
SELECT x.cod_recurso FROM (
    SELECT pd.cod_recurso,COUNT(pd.cod_recurso_compuesto)as total_recursos
    FROM parte_de pd GROUP BY pd.cod_recurso ) as x
WHERE x.total_recursos >= 2
)
SELECT pd.cod_recurso_compuesto,pd.cod_recurso FROM parte_de pd
INNER JOIN recursos_R1 r1 ON pd.cod_recurso = r1.cod_recurso

-- 2.5. Listar los recursos que no forman parte de ningun otro recurso (forma directa)

SELECT DISTINCT pd.cod_recurso_compuesto FROM parte_de pd
WHERE pd.cod_recurso_compuesto NOT IN (
	SELECT x.cod_recurso FROM (
   	 SELECT pd.cod_recurso,COUNT(pd.cod_recurso_compuesto)as total_recursos
   	 FROM parte_de pd GROUP BY pd.cod_recurso )as x    
)

-- 3.1 Listar los jefes de proyectos, el total de sus horas dedicadas y el promedio de
-- horas por proyectos

SELECT e.nombre as nombre_jefe,SUM(d.num_horas)as total_horas,AVG(d.num_horas)as promedio_horas
FROM empleados e INNER JOIN jefe_proyectos jp ON e.cod_empleado = jp.cod_empleado
INNER JOIN dirigido d ON jp.cod_empleado = d.cod_jefe GROUP BY nombre_jefe


/*3.2 Listar los 3 jefes de proyectos que obtuvieron el mayor gasto acumulado*/
WITH tabla as (
SELECT e.nombre ,SUM(d.num_horas)as total_horas FROM empleados e INNER JOIN jefe_proyectos jp ON
e.cod_empleado = jp.cod_e INNER JOIN dirigido d ON jp.cod_e = d.cod_jefe
GROUP BY e.nombre
)

SELECT nombre,total_horas FROM tabla WHERE total_horas = (SELECT MAX(total_horas) FROM tabla ) LIMIT 3;

-- 3.3 El Jefe de proyecto cubre el 3% del total del los gastos generados en el proyecto. Obtener el listado de cuanto deberá pagar por jefe de proyecto y por proyecto

WITH gastos_proyecto as ( 
     SELECT g.cod_proyecto as cod_proyecto,SUM(g.monto)as total_gasto_proyecto
     FROM gastos g GROUP BY cod_proyecto
)
SELECT d.cod_jefe,0.03*gp.total_gasto_proyecto FROM dirigido d INNER JOIN gastos_proyecto gp ON d.cod_proyecto = gp.cod_proyecto


-- 3.4 Listar el gasto total del Proyecto,
-- número de productos generados y suma de las cantidades de fases.

WITH tabla1 as (
   SELECT iv.cod_proyecto,COUNT(iv.cod_producto)as total_productos,COUNT(iv.cod_fase)
   as total_fases FROM involucrado_en iv GROUP BY iv.cod_proyecto
)
SELECT g.cod_proyecto,g.monto as total_gasto,t1.total_productos,t1.total_fases
FROM gastos g INNER JOIN tabla1 t1 ON g.cod_proyecto = t1.cod_proyecto

-- 3.5 Para cada mes y año, número total de gastos,
-- costo total y monto promedio por proyecto.
   
SELECT YEAR(g.fecha)as año,MONTH(g.fecha)as mes,COUNT(cod_gasto)as total_gastos,
   
SUM(g.monto)as total_suma_gastos,AVG(g.monto)as promedio_gastos FROM
   
gastos g GROUP BY año,mes

-- 4.1 Crear un índice sobre cod_empleados en gastos
CREATE INDEX indice_gastos ON gastos(cod_empleado)
