/* -- El criterio que usamos para el nombre de los triggers es: -- */
/* -- nombreTabla_descripcion_evento_restriccion -- */
/*
	nombreTabla: Bueno, es bastante descriptivo, es el nombre de la tabla
	descripcion: Viene siendo el campo que se actualizará o qué cosas se van a validar, en fin, una descripcion de lo que se hará
	evento: Seria el insert, update, o delete
    restriccion: Serian los SS8, SS9, SS10, SS11, etc etc. Esto con la finalidad de validar la correcta creacion del trigger mas adelante
*/


/* -- RESTRICCIÓN SS8 -- */
/* -- SS8 PROYECTO.Horas estimadas <= PROYECTO.Fecha_fin - PROYECTO. Fecha_inicio -- */
DROP TRIGGER IF EXISTS proyectos_horas_estimadas_insert_SS8;
DELIMITER //
CREATE TRIGGER proyectos_horas_estimadas_insert_SS8 BEFORE INSERT ON proyectos FOR EACH ROW
BEGIN
    IF(NEW.horas_estimadas > TIMESTAMPDIFF(HOUR, NEW.fecha_inicio, NEW.fecha_fin))THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El campo horas_estimadas debe ser menor o igual a la diferencia entre fecha_fin y fecha_inicio';
    END IF;
END//
DELIMITER ;


DROP TRIGGER IF EXISTS proyectos_horas_estimadas_update_SS8;
DELIMITER //
CREATE TRIGGER proyectos_horas_estimadas_update_SS8 BEFORE UPDATE ON proyectos FOR EACH ROW
BEGIN
	IF(NEW.horas_estimadas > TIMESTAMPDIFF(HOUR, NEW.fecha_inicio, NEW.fecha_fin))THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El campo horas_estimadas debe ser menor o igual a la diferencia entre fecha_fin y fecha_inicio';
    END IF;
END//
DELIMITER ;


/* -- RESTRICCIÓN SS10 -- */
/* -- SS10 Comprobar que los intervalos de fechas en la entidad FASE estén incluidos en el intervalo
compuesto por la fecha de inicio y la fecha de fin del proyecto -- */
DROP TRIGGER IF EXISTS fases_rango_fechas_insert_SS10;
DELIMITER //
CREATE TRIGGER fases_rango_fechas_insert_SS10 BEFORE INSERT ON fases FOR EACH ROW
BEGIN
	SET @fecha_inicio := (SELECT fecha_inicio FROM proyectos WHERE cod_proyecto = NEW.cod_proyecto);
    SET @fecha_fin := (SELECT fecha_fin FROM proyectos WHERE cod_proyecto = NEW.cod_proyecto);
	IF(NEW.fecha_inicio < @fecha_inicio OR NEW.fecha_fin > @fecha_fin)THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El rango de fechas de ésta fase, está fuera del rango de fechas del proyecto asociado';
    END IF;
END//
DELIMITER ;


DROP TRIGGER IF EXISTS fases_rango_fechas_update_SS10;
DELIMITER //
CREATE TRIGGER fases_rango_fechas_update_SS10 BEFORE UPDATE ON fases FOR EACH ROW
BEGIN
	SET @fecha_inicio := (SELECT fecha_inicio FROM proyectos WHERE cod_proyecto = NEW.cod_proyecto);
    SET @fecha_fin := (SELECT fecha_fin FROM proyectos WHERE cod_proyecto = NEW.cod_proyecto);
	IF(NEW.fecha_inicio < @fecha_inicio OR NEW.fecha_fin > @fecha_fin)THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El rango de fechas de ésta fase, está fuera del rango de fechas del proyecto asociado';
    END IF;
END//
DELIMITER ;

/* -- RESTRICCIÓN SS11 -- */
/* -- SS11. Comprobar que la suma de todas las fechas correspondientes al conjunto de fases de un determinado proyecto, no exceda la fecha de finalización del mismo -- */

DROP TRIGGER IF EXISTS fases_control_suma_fechas_insert_SS11;
DELIMITER //
CREATE TRIGGER fases_control_suma_fechas_insert_SS11 BEFORE INSERT ON fases FOR EACH ROW
BEGIN
	SET @cantidad_horas_proyecto := (SELECT TIMESTAMPDIFF(HOUR, fecha_inicio, fecha_fin) FROM proyectos WHERE NEW.cod_proyecto = cod_proyecto);

	SET @cantidad_horas_fases := (
		SELECT SUM(TIMESTAMPDIFF(HOUR, fecha_inicio, fecha_fin))
		FROM fases
		WHERE NEW.cod_proyecto = cod_proyecto
	);

	IF(@cantidad_horas_fases > @cantidad_horas_proyecto)THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El numero de horas total de fases excede el numero de horas del proyecto';
	END IF;
	
END//
DELIMITER ;

DROP TRIGGER IF EXISTS fases_control_suma_fechas_update_SS11;
DELIMITER //
CREATE TRIGGER fases_control_suma_fechas_update_SS11 BEFORE UPDATE ON fases FOR EACH ROW
BEGIN
	IF(NEW.fecha_inicio != fecha_inicio OR NEW.fecha_fin != fecha_fin)THEN
		SET @cantidad_horas_proyecto := (SELECT TIMESTAMPDIFF(HOUR, fecha_inicio, fecha_fin) FROM proyectos WHERE NEW.cod_proyecto = cod_proyecto);

		SET @cantidad_horas_fases := (
			SELECT SUM(TIMESTAMPDIFF(HOUR, fecha_inicio, fecha_fin))
			FROM fases
			WHERE NEW.cod_proyecto = cod_proyecto
		);

		IF(@cantidad_horas_fases > @cantidad_horas_proyecto)THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'El numero de horas total de fases excede el numero de horas del proyecto';
		END IF;
	END IF;
END//
DELIMITER ;

/* -- RESTRICCIÓN SS12 -- */
/* -- SS12 Dirigido.Num_horas = PROYECTO.Fecha_fin - PROYECTO.Fecha_inicio. -- */

/* -- Considero que el campo num_horas NO será ingresado por el usuario y será el sistema quien lo ingresará, es decir, 
el trigger en este caso -- */
DROP TRIGGER IF EXISTS dirigido_num_horas_insert_SS12;
DELIMITER //
CREATE TRIGGER dirigido_num_horas_insert_SS12 BEFORE INSERT ON dirigido FOR EACH ROW
BEGIN
	SET @fecha_inicio := (SELECT fecha_inicio FROM proyectos WHERE cod_proyecto = NEW.cod_proyecto);
    SET @fecha_fin := (SELECT fecha_fin FROM proyectos WHERE cod_proyecto = NEW.cod_proyecto);
	SET NEW.num_horas = TIMESTAMPDIFF(HOUR, @fecha_inicio, @fecha_fin);
END//
DELIMITER ;

/* -- Controla el caso de que por las dudas se intente manipular el numero de horas -- */
DROP TRIGGER IF EXISTS dirigido_num_horas_update_SS12;
DELIMITER //
CREATE TRIGGER dirigido_num_horas_update_SS12 BEFORE UPDATE ON dirigido FOR EACH ROW
BEGIN
	IF (NEW.num_horas != num_horas) THEN
		SET @fecha_inicio := (SELECT fecha_inicio FROM proyectos WHERE cod_proyecto = NEW.cod_proyecto);
		SET @fecha_fin := (SELECT fecha_fin FROM proyectos WHERE cod_proyecto = NEW.cod_proyecto);
		SET NEW.num_horas = TIMESTAMPDIFF(HOUR, @fecha_inicio, @fecha_fin);
	END IF;
END//
DELIMITER ;

DROP TRIGGER IF EXISTS proyectos_num_horas_dirigido_y_trabaja_update_SS12_SS13;
DELIMITER //
CREATE TRIGGER proyectos_num_horas_dirigido_y_trabaja_update_SS12_SS13 AFTER UPDATE ON proyectos FOR EACH ROW
BEGIN
	IF (NEW.fecha_inicio != fecha_inicio OR NEW.fecha_fin != fecha_fin) THEN -- Pregunta antes si cambio algun valor en la fecha, sino no la ejecuta 
		SET @num_horas = TIMESTAMPDIFF(HOUR, NEW.fecha_inicio, NEW.fecha_fin);
		UPDATE dirigido SET num_horas = @num_horas  WHERE cod_proyecto = NEW.cod_proyecto;
        UPDATE trabaja SET num_horas = @num_horas  WHERE cod_proyecto = NEW.cod_proyecto;
	END IF;
END//
DELIMITER ;



/* -- RESTRICCIÓN SS13 -- */
/* -- SS13 Trabaja.Num_horas = PROYECTO.Fecha_fin - PROYECTO.Fecha_inicio. -- */

/* -- Considero que el campo num_horas NO será ingresado por el usuario y será el sistema quien lo ingresará, es decir, 
el trigger en este caso -- */
DROP TRIGGER IF EXISTS trabaja_num_horas_insert_SS13;
DELIMITER //
CREATE TRIGGER trabaja_num_horas_insert_SS13 BEFORE INSERT ON trabaja FOR EACH ROW
BEGIN
	SET @fecha_inicio := (SELECT fecha_inicio FROM proyectos WHERE cod_proyecto = NEW.cod_proyecto);
    SET @fecha_fin := (SELECT fecha_fin FROM proyectos WHERE cod_proyecto = NEW.cod_proyecto);
	SET NEW.num_horas = TIMESTAMPDIFF(HOUR, @fecha_inicio, @fecha_fin);
END//
DELIMITER ;

/* -- Controla el caso de que por las dudas se intente manipular el numero de horas -- */
DROP TRIGGER IF EXISTS trabaja_num_horas_update_SS13;
DELIMITER //
CREATE TRIGGER trabaja_num_horas_update_SS13 BEFORE UPDATE ON trabaja FOR EACH ROW
BEGIN
	IF (NEW.num_horas != num_horas) THEN
		SET @fecha_inicio := (SELECT fecha_inicio FROM proyectos WHERE cod_proyecto = NEW.cod_proyecto);
		SET @fecha_fin := (SELECT fecha_fin FROM proyectos WHERE cod_proyecto = NEW.cod_proyecto);
		SET NEW.num_horas = TIMESTAMPDIFF(HOUR, @fecha_inicio, @fecha_fin);
	END IF;
END//
DELIMITER ;


/* -- RESTRICCIÓN SS14 -- */
/* -- SS14 Involucrado.Num_horas =< FASE.Fecha_fin - FASE.Fecha_inicio. -- */
DROP TRIGGER IF EXISTS involucrado_en_num_horas_insert_SS14;
DELIMITER //
CREATE TRIGGER involucrado_en_num_horas_insert_SS14 BEFORE INSERT ON involucrado_en FOR EACH ROW
BEGIN
	SET @fecha_inicio := (SELECT fecha_inicio FROM fases WHERE cod_fase = NEW.cod_fase LIMIT 1);
	SET @fecha_fin := (SELECT fecha_fin FROM fases WHERE cod_fase = NEW.cod_fase LIMIT 1) ;

	IF(NEW.num_horas > TIMESTAMPDIFF(HOUR, @fecha_inicio, @fecha_fin))THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El campo num_horas debe ser menor o igual a la diferencia entre fecha_fin y fecha_inicio asociada a la fase correspondiente';
    END IF;
END//
DELIMITER ;

/* -- Contemplamos el caso de que intente actualizarse el numero de horas -- */
DROP TRIGGER IF EXISTS involucrado_en_num_horas_update_SS14;
DELIMITER //
CREATE TRIGGER involucrado_en_num_horas_update_SS14 BEFORE UPDATE ON involucrado_en FOR EACH ROW
BEGIN
	SET @fecha_inicio := (SELECT fecha_inicio FROM fases WHERE cod_fase = NEW.cod_fase LIMIT 1);
	SET @fecha_fin := (SELECT fecha_fin FROM fases WHERE cod_fase = NEW.cod_fase LIMIT 1) ;

	IF(NEW.num_horas > TIMESTAMPDIFF(HOUR, @fecha_inicio, @fecha_fin))THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El campo num_horas debe ser menor o igual a la diferencia entre fecha_fin y fecha_inicio asociada a la fase correspondiente';
    END IF;
END//
DELIMITER ;


/* -- RESTRICCIÓN SS16 -- */
/* -- SS16 Comprobar que el intervalo de tiempo de la interrelación Se_asigna está contenido en el
compuesto por las fechas de inicio y de fin de la fase correspondiente -- */

DROP TRIGGER IF EXISTS se_asigna_intervalo_tiempo_insert_SS16;
DELIMITER //
CREATE TRIGGER se_asigna_intervalo_tiempo_insert_SS16 BEFORE INSERT ON se_asigna FOR EACH ROW
BEGIN
	SET @fecha_inicio := (SELECT fecha_inicio FROM fases WHERE NEW.cod_fase = cod_fase);
	SET @fecha_fin := (SELECT fecha_fin FROM fases WHERE NEW.cod_fase = cod_fase);

	IF(NEW.fecha_i < @fecha_inicio OR NEW.fecha_f > @fecha_fin)THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El rango de fechas debe estar comprendido en el rango de fechas de la fase correspondiente';
    END IF;

END//
DELIMITER ;

-- insert into se_asigna values (NOW(), "2021-11-30", 1, 1, 1, "Nombre");

DROP TRIGGER IF EXISTS se_asigna_intervalo_tiempo_update_SS16;
DELIMITER //
CREATE TRIGGER se_asigna_intervalo_tiempo_update_SS16 BEFORE UPDATE ON se_asigna FOR EACH ROW
BEGIN
	SET @fecha_inicio := (SELECT fecha_inicio FROM fases WHERE NEW.cod_fase = cod_fase);
	SET @fecha_fin := (SELECT fecha_fin FROM fases WHERE NEW.cod_fase = cod_fase);

	IF(NEW.fecha_i < @fecha_inicio OR NEW.fecha_f > @fecha_fin)THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El rango de fechas debe estar comprendido en el rango de fechas de la fase correspondiente';
    END IF;

END//
DELIMITER ;

/* -- RESTRICCIÓN SS17 -- */
/* -- SS17 Los periodos de tiempo de la interrelación Se_asigna no pueden solaparse para el mismo
recurso -- */

DROP TRIGGER IF EXISTS se_asigna_solapamiento_fechas_insert_SS17;
DELIMITER //
CREATE TRIGGER se_asigna_solapamiento_fechas_insert_SS17 BEFORE INSERT ON se_asigna FOR EACH ROW
BEGIN
	SET @cantidad := (SELECT COUNT(*) FROM se_asigna WHERE ((NEW.fecha_i >= fecha_i AND NEW.fecha_i <= fecha_f) OR (NEW.fecha_f <= fecha_f AND NEW.fecha_f >= fecha_i)) AND NEW.cod_recurso = cod_recurso);
	IF(@cantidad > 0)THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El rango de fechas no debe solaparse para el mismo recurso';
	END IF;
END//
DELIMITER ;
/*

(cod_recurso, fecha_i, fecha_f)

(1, "29-11-2020", "02-12-2020") EJEMPLO
(1, "01-12-2020", "05-12-2020") SE SOLAPA
(1, "20-11-2020", "30-11-2020") SE SOLAPA

*/

DROP TRIGGER IF EXISTS se_asigna_solapamiento_fechas_update_SS17;
DELIMITER //
CREATE TRIGGER se_asigna_solapamiento_fechas_update_SS17 BEFORE UPDATE ON se_asigna FOR EACH ROW
BEGIN
	SET @cantidad := (SELECT COUNT(*) FROM se_asigna WHERE ((NEW.fecha_i >= fecha_i AND NEW.fecha_i <= fecha_f) OR (NEW.fecha_f <= fecha_f AND NEW.fecha_f >= fecha_i)) AND NEW.cod_recurso = cod_recurso);
	IF(@cantidad > 0)THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El rango de fechas no debe solaparse para el mismo recurso';
	END IF;
END//
DELIMITER ;

/* AMBOS ESTAN PENDIENTES DE TESTEO */

/* -- RESTRICCIÓN SS18 -- */
/* -- SS18 Un informático ha de aparecer en la interrelación Trabaja para todos los proyectos en los que
aparece como Involucrado en alguna de sus fases -- */

/* Considero que NO puede cargarse datos en la tabla involucrado_en, si previamente no se cargaron en trabaja*/
DROP TRIGGER IF EXISTS involucrado_en_controlar_involucrado_insert_SS18;
DELIMITER //
CREATE TRIGGER involucrado_en_controlar_involucrado_insert_SS18 BEFORE INSERT ON involucrado_en FOR EACH ROW
BEGIN
	SET @existe := (SELECT TRUE FROM trabaja WHERE NEW.cod_informatico = cod_informatico AND NEW.cod_proyecto = cod_proyecto);
	IF(@existe IS NULL)THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El informatico no trabaja en este proyecto';
	END IF;

END//
DELIMITER ;

DROP TRIGGER IF EXISTS involucrado_en_controlar_involucrado_update_SS18;
DELIMITER //
CREATE TRIGGER involucrado_en_controlar_involucrado_update_SS18 BEFORE UPDATE ON involucrado_en FOR EACH ROW
BEGIN
	IF(NEW.cod_informatico != OLD.cod_informatico OR NEW.cod_proyecto != OLD.cod_proyecto)THEN
		SET @existe := (SELECT TRUE FROM trabaja WHERE NEW.cod_informatico = cod_informatico AND NEW.cod_proyecto = cod_proyecto);
		IF(@existe IS NULL)THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'El informatico no trabaja en este proyecto';
		END IF;
	END IF;

END//
DELIMITER ;

/* AMBOS ESTAN PENDIENTES DE TESTEO */


/* -- RESTRICCIÓN SS20 -- */
/* -- SS20. PROYECTO.Fecha_inicio =< GASTO.Fecha =< PROYECTO.Fecha_fin -- */
DROP TRIGGER IF EXISTS gastos_control_fecha_insert_SS20;
DELIMITER //
CREATE TRIGGER gastos_control_fecha_insert_SS20 BEFORE INSERT ON gastos FOR EACH ROW
BEGIN
	SET @fecha_inicio := (SELECT fecha_inicio FROM proyectos WHERE NEW.cod_proyecto = cod_proyecto);
	SET @fecha_fin := (SELECT fecha_fin FROM proyectos WHERE NEW.cod_proyecto = cod_proyecto);

	IF(NEW.fecha < @fecha_inicio OR NEW.fecha > @fecha_fin)THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El rango de fechas debe estar comprendido en el rango de fechas del proyecto correspondiente';
    END IF;
END//
DELIMITER ;


DROP TRIGGER IF EXISTS gastos_control_fecha_update_SS20;
DELIMITER //
CREATE TRIGGER gastos_control_fecha_update_SS20 BEFORE UPDATE ON gastos FOR EACH ROW
BEGIN
	IF(NEW.fecha != OLD.fecha)THEN
		SET @fecha_inicio := (SELECT fecha_inicio FROM proyectos WHERE NEW.cod_proyecto = cod_proyecto);
		SET @fecha_fin := (SELECT fecha_fin FROM proyectos WHERE NEW.cod_proyecto = cod_proyecto);

		IF(NEW.fecha < @fecha_inicio OR NEW.fecha > @fecha_fin)THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'El rango de fechas debe estar comprendido en el rango de fechas del proyecto correspondiente';
		END IF;
	END IF;
END//
DELIMITER ;

/* AMBOS ESTAN PENDIENTES DE TESTEO */

/* -- RESTRICCIÓN SS21 -- */
/* -- SS21. Controlar que el empleado que realiza el gasto esté trabajando en el proyecto al que se carga dicho gasto -- */

/* -- Consideraciones: será necesario hacer un query sobre la tabla trabaja y dirigido. Ya que en la 
tabla trabaja solo estarán los empleados de tipo informatico y en la tabla dirigido estarán
los empleados de tipo jeye de proyectos. Con que se encuentre en cualqueira de estas dos,
será suficiente para validar la transacción --*/

DROP TRIGGER IF EXISTS gastos_empleado_involucrado_insert_SS21;
DELIMITER //
CREATE TRIGGER gastos_empleado_involucrado_insert_SS21 BEFORE INSERT ON gastos FOR EACH ROW
BEGIN
	SET @empleado_trabaja := (SELECT TRUE FROM trabaja WHERE NEW.cod_empleado = cod_informatico AND NEW.cod_proyecto = cod_proyecto);
	SET @empleado_dirigido := (SELECT TRUE FROM dirigido WHERE NEW.cod_empleado = cod_jefe AND NEW.cod_proyecto = cod_proyecto);

	IF(@empleado_trabaja IS NULL AND @empleado_dirigido IS NULL)THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'El empleado no trabaja en este proyecto';
	END IF;
END//
DELIMITER ;

DROP TRIGGER IF EXISTS gastos_empleado_involucrado_update_SS21;
DELIMITER //
CREATE TRIGGER gastos_empleado_involucrado_update_SS21 BEFORE UPDATE ON gastos FOR EACH ROW
BEGIN
	IF(NEW.cod_empleado != OLD.cod_empleado OR NEW.cod_proyecto != OLD.cod_proyecto)THEN
		SET @empleado_trabaja := (SELECT TRUE FROM trabaja WHERE NEW.cod_empleado = cod_informatico AND NEW.cod_proyecto = cod_proyecto);
		SET @empleado_dirigido := (SELECT TRUE FROM dirigido WHERE NEW.cod_empleado = cod_jefe AND NEW.cod_proyecto = cod_proyecto);

		IF(@empleado_trabaja IS NULL AND @empleado_dirigido IS NULL)THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'El empleado no trabaja en este proyecto';
		END IF;
	END IF;
END//
DELIMITER ;

/* AMBOS ESTAN PENDIENTES DE TESTEO */


/* -- RESTRICCIÓN SS22 -- */
/* -- SS22 El presupuesto de un proyecto siempre ha de ser mayor o igual a la suma de todos los costes de sus empleados más los gastos que generan -- */

/* -- TABLA GASTOS -- */
DROP TRIGGER IF EXISTS gastos_control_suma_insert_SS22;
DELIMITER //
CREATE TRIGGER gastos_control_suma_insert_SS22 BEFORE INSERT ON gastos FOR EACH ROW
BEGIN
	SET @presupuesto := (
		SELECT presupuesto
		FROM proyectos
		WHERE NEW.cod_proyecto = cod_proyecto
	);

	SET @suma_gatos := (
		SELECT SUM(monto)
		FROM gastos
		WHERE NEW.cod_proyecto = cod_proyecto
	);

	SET @suma_trabaja := (
		SELECT SUM(coste_total)
		FROM trabaja
		WHERE NEW.cod_proyecto = cod_proyecto
	);

	SET @suma_dirigido := (
		SELECT SUM(coste_total)
		FROM dirigido
		WHERE NEW.cod_proyecto = cod_proyecto
	);

	SET @suma_total := (@suma_gatos + @suma_trabaja + @suma_dirigido);

	IF(@presupuesto < @suma_total)THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Con este gasto se excede el presupuesto del proyecto asociado';
	END IF;
END//
DELIMITER ;


DROP TRIGGER IF EXISTS gastos_control_suma_update_SS22;
DELIMITER //
CREATE TRIGGER gastos_control_suma_update_SS22 BEFORE UPDATE ON gastos FOR EACH ROW
BEGIN
	IF(NEW.monto != OLD.monto OR NEW.cod_proyecto != OLD.cod_proyecto)THEN
		SET @presupuesto := (
			SELECT presupuesto
			FROM proyectos
			WHERE NEW.cod_proyecto = cod_proyecto
		);

		SET @suma_gatos := (
			SELECT SUM(monto)
			FROM gastos
			WHERE NEW.cod_proyecto = cod_proyecto
		);

		SET @suma_trabaja := (
			SELECT SUM(coste_total)
			FROM trabaja
			WHERE NEW.cod_proyecto = cod_proyecto
		);

		SET @suma_dirigido := (
			SELECT SUM(coste_total)
			FROM dirigido
			WHERE NEW.cod_proyecto = cod_proyecto
		);

		SET @suma_total := (@suma_gatos + @suma_trabaja + @suma_dirigido);

		IF(@presupuesto < @suma_total)THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Con este gasto se excede el presupuesto del proyecto asociado';
		END IF;
	END IF;
END//
DELIMITER ;

/* -- TABLA TRABAJA -- */
DROP TRIGGER IF EXISTS trabaja_control_suma_insert_SS22;
DELIMITER //
CREATE TRIGGER trabaja_control_suma_insert_SS22 BEFORE INSERT ON trabaja FOR EACH ROW
BEGIN
	SET @presupuesto := (
		SELECT presupuesto
		FROM proyectos
		WHERE NEW.cod_proyecto = cod_proyecto
	);

	SET @suma_gatos := (
		SELECT SUM(monto)
		FROM gastos
		WHERE NEW.cod_proyecto = cod_proyecto
	);

	SET @suma_trabaja := (
		SELECT SUM(coste_total)
		FROM trabaja
		WHERE NEW.cod_proyecto = cod_proyecto
	);

	SET @suma_dirigido := (
		SELECT SUM(coste_total)
		FROM dirigido
		WHERE NEW.cod_proyecto = cod_proyecto
	);

	SET @suma_total := (@suma_gatos + @suma_trabaja + @suma_dirigido);

	IF(@presupuesto < @suma_total)THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Con este gasto se excede el presupuesto del proyecto asociado';
	END IF;
END//
DELIMITER ;


DROP TRIGGER IF EXISTS trabaja_control_suma_update_SS22;
DELIMITER //
CREATE TRIGGER trabaja_control_suma_update_SS22 BEFORE UPDATE ON trabaja FOR EACH ROW
BEGIN
	IF(NEW.coste_total != OLD.coste_total OR NEW.cod_proyecto != OLD.cod_proyecto)THEN
		SET @presupuesto := (
			SELECT presupuesto
			FROM proyectos
			WHERE NEW.cod_proyecto = cod_proyecto
		);

		SET @suma_gatos := (
			SELECT SUM(monto)
			FROM gastos
			WHERE NEW.cod_proyecto = cod_proyecto
		);

		SET @suma_trabaja := (
			SELECT SUM(coste_total)
			FROM trabaja
			WHERE NEW.cod_proyecto = cod_proyecto
		);

		SET @suma_dirigido := (
			SELECT SUM(coste_total)
			FROM dirigido
			WHERE NEW.cod_proyecto = cod_proyecto
		);

		SET @suma_total := (@suma_gatos + @suma_trabaja + @suma_dirigido);

		IF(@presupuesto < @suma_total)THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Con este gasto se excede el presupuesto del proyecto asociado';
		END IF;
	END IF;
END//
DELIMITER ;

/* -- TABLA DIRIGIDO -- */
DROP TRIGGER IF EXISTS dirigido_control_suma_insert_SS22;
DELIMITER //
CREATE TRIGGER dirigido_control_suma_insert_SS22 BEFORE INSERT ON dirigido FOR EACH ROW
BEGIN
	SET @presupuesto := (
		SELECT presupuesto
		FROM proyectos
		WHERE NEW.cod_proyecto = cod_proyecto
	);

	SET @suma_gatos := (
		SELECT SUM(monto)
		FROM gastos
		WHERE NEW.cod_proyecto = cod_proyecto
	);

	SET @suma_trabaja := (
		SELECT SUM(coste_total)
		FROM trabaja
		WHERE NEW.cod_proyecto = cod_proyecto
	);

	SET @suma_dirigido := (
		SELECT SUM(coste_total)
		FROM dirigido
		WHERE NEW.cod_proyecto = cod_proyecto
	);

	SET @suma_total := (@suma_gatos + @suma_trabaja + @suma_dirigido);

	IF(@presupuesto < @suma_total)THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Con este gasto se excede el presupuesto del proyecto asociado';
	END IF;
END//
DELIMITER ;

DROP TRIGGER IF EXISTS dirigido_control_suma_update_SS22;
DELIMITER //
CREATE TRIGGER dirigido_control_suma_update_SS22 BEFORE UPDATE ON dirigido FOR EACH ROW
BEGIN
	IF(NEW.coste_total != OLD.coste_total OR NEW.cod_proyecto != OLD.cod_proyecto)THEN
		SET @presupuesto := (
			SELECT presupuesto
			FROM proyectos
			WHERE NEW.cod_proyecto = cod_proyecto
		);

		SET @suma_gatos := (
			SELECT SUM(monto)
			FROM gastos
			WHERE NEW.cod_proyecto = cod_proyecto
		);

		SET @suma_trabaja := (
			SELECT SUM(coste_total)
			FROM trabaja
			WHERE NEW.cod_proyecto = cod_proyecto
		);

		SET @suma_dirigido := (
			SELECT SUM(coste_total)
			FROM dirigido
			WHERE NEW.cod_proyecto = cod_proyecto
		);

		SET @suma_total := (@suma_gatos + @suma_trabaja + @suma_dirigido);

		IF(@presupuesto < @suma_total)THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Con este gasto se excede el presupuesto del proyecto asociado';
		END IF;
	END IF;
END//
DELIMITER ;

