-- Creacion de Roles --
CREATE ROLE 'Programador'@'%'; 
CREATE ROLE 'Diseñador'@'%';
CREATE ROLE 'Administrador'@'localhost';


-- Asignacion de Privilegios a Roles --
GRANT ALL PRIVILEGES ON *.* TO 'Administrador'@'localhost' WITH GRANT OPTION; 
GRANT SELECT, UPDATE, DELETE, INSERT, DROP, CREATE VIEW, SHOW VIEW, TRIGGER, EXECUTE,CREATE ROUTINE, ALTER ROUTINE ON BDA_TPI.* TO 'Programador'@'%';
GRANT SELECT, UPDATE, DELETE, INSERT, EXECUTE ON BDA_TPI.* TO 'Diseñador'@'%'; --


-- Creacion de Usuarios por cada Rol --

CREATE USER 'AdministradorBD'@'localhost' IDENTIFIED BY 'AdministradorBD' PASSWORD EXPIRE ; --
CREATE USER 'ProgramadorBD'@'%' IDENTIFIED BY 'ProgramadorBD' PASSWORD EXPIRE ; --
CREATE USER 'DiseñadorBD'@'%' IDENTIFIED BY 'DiseñadorBD' PASSWORD EXPIRE ; --

-- Asignaciones de Roles a Usuarios --

GRANT 'Administrador'@'localhost' TO 'AdministradorBD'@'localhost'; --
GRANT 'Diseñador' TO 'DiseñadorBD'@'%';--
GRANT 'Programador' TO 'ProgramadorBD'@'%'; --


-- Acciones para Administrador --
-- Creacion de roles --
CREATE ROLE 'Programador'@'%'; 
CREATE ROLE 'Diseñador'@'%';
-- Asignacion de Permisos a roles --
GRANT SELECT, UPDATE, DELETE, INSERT, CREATE VIEW, SHOW VIEW, TRIGGER, EXECUTE,CREATE ROUTINE, ALTER ROUTINE ON BDA_TPI.* TO 'Programador'@'%';
GRANT ALL PRIVILEGES ON *.* TO 'Diseñador'@'%';

-- Creacion de Usuarios --
CREATE USER 'DiseñadorBD'@'%' IDENTIFIED BY 'DiseñadorBD' PASSWORD EXPIRE ; 
CREATE USER 'ProgramadorBD'@'%' IDENTIFIED BY 'ProgramadorBD' PASSWORD EXPIRE ;

-- Asignacion de roles a usuarios --
GRANT 'Diseñador' TO 'DiseñadorBD'@'%';
GRANT 'Programador' TO 'ProgramadorBD'@'%'; 


-- Acciones para el Diseñador --
SELECT * FROM empleados;

UPDATE empleados
SET titulacion= 'Ingeniero'
WHERE titulacion= 'Dr';


-- Acciones para el Programador --
CALL  listar_proyecto (3);