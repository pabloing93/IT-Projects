
#Procedimientos Almacenados

#Escriba un procedimiento 
#almacenado que para un codigo de proyecto, imprima su nombre, el total de gastos realizados para ese proyecto, 
# la fecha en que se realizó
#y el nombre del empleado que hizo ese gasto.
#Para que cree la funcion
SET GLOBAL log_bin_trust_function_creators = 1;
DELIMITER //
CREATE PROCEDURE listar_proyecto(codigo_proyecto int)
BEGIN
	SET @total_gastos = (SELECT g.monto FROM gastos g WHERE g.cod_proyecto = codigo_proyecto);
    SELECT p.nombre,total_gastos,g.fecha,e.nombre
    FROM proyectos p INNER JOIN gastos g ON g.cod_proyecto = codigo_proyecto
    INNER JOIN empleado e ON g.cod_empleado = e.cod_empleado;
END //
DELIMITER ;

#Escriba una función que retorne en forma de tupla, para un codigo de informatico,
#la cantidad de proyectos en los que trabajó y la suma de horas.
DELIMITER //
CREATE FUNCTION listar_proyectos_y_horas(codigo_empleado int) RETURNS VARCHAR(100)
BEGIN
    SET @cod_empleado = (SELECT t.cod_informatico FROM trabaja t WHERE t.cod_informatico = codigo_empleado);
    SET @total_horas = (SELECT SUM(t.num_horas) FROM trabaja t INNER JOIN empleado e ON e.cod_empleado = cod_empleado AND e.tipo LIKE '%Informático%' );
    SET @total_proyectos = (SELECT COUNT(t.cod_proyecto) FROM trabaja t INNER JOIN empleado e ON e.cod_empleado = cod_empleado AND e.tipo LIKE '%Informático%' );
    RETURN CONCAT(total_horas,total_proyectos);
END //
