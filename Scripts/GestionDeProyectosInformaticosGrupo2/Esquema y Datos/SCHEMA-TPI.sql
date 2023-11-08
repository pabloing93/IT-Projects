/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `analistas` (
  `cod_analista` int NOT NULL,
  PRIMARY KEY (`cod_analista`),
  CONSTRAINT `analistas_ibfk_1` FOREIGN KEY (`cod_analista`) REFERENCES `informaticos` (`cod_informatico`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dirigido` (
  `cod_proyecto` int NOT NULL,
  `cod_jefe` int NOT NULL,
  `num_horas` float NOT NULL,
  `coste_total` float NOT NULL,
  PRIMARY KEY (`cod_proyecto`,`cod_jefe`),
  UNIQUE KEY `cod_proyecto` (`cod_proyecto`),
  KEY `cod_jefe` (`cod_jefe`),
  CONSTRAINT `dirigido_ibfk_1` FOREIGN KEY (`cod_jefe`) REFERENCES `jefe_proyectos` (`cod_jefe`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `dirigido_ibfk_2` FOREIGN KEY (`cod_proyecto`) REFERENCES `proyectos` (`cod_proyecto`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `empleados` (
  `cod_empleado` int NOT NULL AUTO_INCREMENT,
  `dni` int NOT NULL,
  `nombre` varchar(70) NOT NULL,
  `titulacion` varchar(70) NOT NULL,
  `anios_experiencia` int DEFAULT '0',
  `direccion` tinytext NOT NULL,
  `tipo` enum('Jefe proyecto','Informático') DEFAULT NULL,
  PRIMARY KEY (`cod_empleado`)
) ENGINE=InnoDB AUTO_INCREMENT=100001 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fases` (
  `nombre` varchar(80) NOT NULL,
  `cod_proyecto` int NOT NULL,
  `cod_fase` int NOT NULL,
  `fecha_inicio` datetime DEFAULT CURRENT_TIMESTAMP,
  `fecha_fin` datetime NOT NULL,
  `estado` enum('En curso','Finalizada') DEFAULT 'En curso',
  PRIMARY KEY (`cod_proyecto`,`cod_fase`),
  CONSTRAINT `fases_ibfk_1` FOREIGN KEY (`cod_proyecto`) REFERENCES `proyectos` (`cod_proyecto`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fecha_fin_fases_check` CHECK ((`fecha_fin` >= `fecha_inicio`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gastos` (
  `cod_gasto` int NOT NULL AUTO_INCREMENT,
  `cod_proyecto` int NOT NULL,
  `cod_empleado` int DEFAULT NULL,
  `monto` int NOT NULL,
  `fecha` datetime DEFAULT CURRENT_TIMESTAMP,
  `descripcion` tinytext,
  `tipo` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`cod_gasto`),
  KEY `cod_empleado` (`cod_empleado`),
  KEY `cod_proyecto` (`cod_proyecto`),
  CONSTRAINT `gastos_ibfk_1` FOREIGN KEY (`cod_empleado`) REFERENCES `empleados` (`cod_empleado`) ON UPDATE CASCADE,
  CONSTRAINT `gastos_ibfk_2` FOREIGN KEY (`cod_proyecto`) REFERENCES `proyectos` (`cod_proyecto`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `genera` (
  `cod_producto` int NOT NULL,
  `cod_proyecto` int NOT NULL,
  `cod_fase` int NOT NULL,
  PRIMARY KEY (`cod_producto`,`cod_fase`,`cod_proyecto`),
  KEY `cod_proyecto` (`cod_proyecto`,`cod_fase`),
  CONSTRAINT `genera_ibfk_1` FOREIGN KEY (`cod_producto`) REFERENCES `productos` (`cod_producto`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `genera_ibfk_2` FOREIGN KEY (`cod_proyecto`, `cod_fase`) REFERENCES `fases` (`cod_proyecto`, `cod_fase`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `informaticos` (
  `cod_informatico` int NOT NULL,
  `tipo` enum('Analista','Programador') NOT NULL,
  PRIMARY KEY (`cod_informatico`),
  CONSTRAINT `informaticos_ibfk_1` FOREIGN KEY (`cod_informatico`) REFERENCES `empleados` (`cod_empleado`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `involucrado_en` (
  `num_horas` float DEFAULT NULL,
  `cod_fase` int NOT NULL,
  `cod_proyecto` int NOT NULL,
  `cod_producto` int NOT NULL,
  `cod_informatico` int NOT NULL,
  PRIMARY KEY (`cod_proyecto`,`cod_fase`,`cod_producto`,`cod_informatico`),
  KEY `cod_producto` (`cod_producto`),
  KEY `cod_informatico` (`cod_informatico`),
  CONSTRAINT `involucrado_en_ibfk_1` FOREIGN KEY (`cod_producto`) REFERENCES `productos` (`cod_producto`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `involucrado_en_ibfk_2` FOREIGN KEY (`cod_informatico`) REFERENCES `informaticos` (`cod_informatico`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `involucrado_en_ibfk_3` FOREIGN KEY (`cod_proyecto`, `cod_fase`) REFERENCES `fases` (`cod_proyecto`, `cod_fase`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jefe_proyectos` (
  `cod_jefe` int NOT NULL,
  PRIMARY KEY (`cod_jefe`),
  CONSTRAINT `jefe_proyectos_ibfk_1` FOREIGN KEY (`cod_jefe`) REFERENCES `empleados` (`cod_empleado`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lenguajes` (
  `cod_lenguaje` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) NOT NULL,
  PRIMARY KEY (`cod_lenguaje`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `parte_de` (
  `cod_recurso_compuesto` int NOT NULL,
  `cod_recurso` int NOT NULL,
  PRIMARY KEY (`cod_recurso_compuesto`,`cod_recurso`),
  KEY `parte_de_ibfk_2` (`cod_recurso`),
  CONSTRAINT `parte_de_ibfk_1` FOREIGN KEY (`cod_recurso_compuesto`) REFERENCES `recursos` (`cod_recurso`),
  CONSTRAINT `parte_de_ibfk_2` FOREIGN KEY (`cod_recurso`) REFERENCES `recursos` (`cod_recurso`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `postulantes` (
  `cjson` json DEFAULT NULL,
  CONSTRAINT `validacion` CHECK (json_schema_valid(_utf8mb4'\n    {\n    "$schema": "http://json-schema.org/draft-07/schema",\n    "$id": "http://example.com/example.json",\n    "type": "object",\n    "title": "The root schema",\n    "description": "The root schema comprises the entire JSON document.",\n    "default": {},\n    "required": [\n					"dni",\n                "nombre",\n                "edad",\n                "ciudad",\n                "nivel estudio",\n                "email",\n                "redes sociales",\n                "experiencia laboral",\n                "educación formal",\n                "aspiraciones"\n    ],\n    "properties": {\n        "postulante": {\n            "$id": "#/properties/postulante",\n            "type": "object",\n            "title": "The postulante schema",\n            "description": "An explanation about the purpose of this instance.",\n            "default": {},\n            "examples": [\n                {\n                    "dni": 40404040,\n                    "nombre": "juan paredez",\n                    "edad": 24,\n                    "ciudad": "Madrid",\n                    "nivel estudio": "universitario",\n                    "email": "juanpa24@correos.com",\n                    "redes sociales": [\n                        {\n                            "instagram": "juanpa24"\n                        },\n                        {\n                            "twitter": "juanpa24"\n                        }\n                    ],\n                    "experiencia laboral": [\n                        {\n                            "empresa": {\n                                "nombre": "Yahoo",\n                                "lenguaje": "php",\n                                "años": 4,\n                                "puesto": "programador",\n                                "tipo ": "presencial"\n                            }\n                        },\n                        {\n                            "empresa": {\n                                "nombre": "Mercadolibre",\n                                "lenguaje": "",\n                                "años": 1,\n                                "puesto": "Scrum Master",\n                                "tipo ": "presencial"\n                            }\n                        },\n                        {\n                            "empresa": {\n                                "nombre": "Tiendamia",\n                                "lenguaje": "java",\n                                "años": 1,\n                                "puesto": "Testing",\n                                "tipo": "virtual"\n                            }\n                        }\n                    ],\n                    "educación formal": [\n                        {\n                            "tema": "php"\n                        },\n                        {\n                            "lugar": "Instituto"\n                        },\n                        {\n                            "tema": "Scrum"\n                        },\n                        {\n                            "lugar": "Utn"\n                        }\n                    ],\n                    "aspiraciones": [\n                        {\n                            "lenguajes": [\n                                "javascript",\n                                "android"\n                            ]\n                        },\n                        {\n                            "puestos": [\n                                "DevOps"\n                            ]\n                        },\n                        {\n                            "conocimientos": [\n                                "git",\n                                " redes"\n                            ]\n                        }\n                    ]\n                }\n            ],\n            "required": [\n                "dni",\n                "nombre",\n                "edad",\n                "ciudad",\n                "nivel estudio",\n                "email",\n                "redes sociales",\n                "experiencia laboral",\n                "educación formal",\n                "aspiraciones"\n            ],\n            "properties": {\n                "dni": {\n                    "$id": "#/properties/postulante/properties/dni",\n                    "type": "integer",\n                    "title": "The dni schema",\n                    "description": "An explanation about the purpose of this instance.",\n                    "default": 0,\n                    "examples": [\n                        40404040\n                    ]\n                },\n                "nombre": {\n                    "$id": "#/properties/postulante/properties/nombre",\n                    "type": "string",\n                    "title": "The nombre schema",\n                    "description": "An explanation about the purpose of this instance.",\n                    "default": "",\n                    "examples": [\n                        "juan paredez"\n                    ]\n                },\n                "edad": {\n                    "$id": "#/properties/postulante/properties/edad",\n                    "type": "integer",\n                    "title": "The edad schema",\n                    "description": "An explanation about the purpose of this instance.",\n                    "default": 0,\n                    "examples": [\n                        24\n                    ]\n                },\n                "ciudad": {\n                    "$id": "#/properties/postulante/properties/ciudad",\n                    "type": "string",\n                    "title": "The ciudad schema",\n                    "description": "An explanation about the purpose of this instance.",\n                    "default": "",\n                    "examples": [\n                        "Madrid"\n                    ]\n                },\n                "nivel estudio": {\n                    "$id": "#/properties/postulante/properties/nivel%20estudio",\n                    "type": "string",\n                    "title": "The nivel estudio schema",\n                    "description": "An explanation about the purpose of this instance.",\n                    "default": "",\n                    "examples": [\n                        "universitario"\n                    ]\n                },\n                "email": {\n                    "$id": "#/properties/postulante/properties/email",\n                    "type": "string",\n                    "title": "The email schema",\n                    "description": "An explanation about the purpose of this instance.",\n                    "default": "",\n                    "examples": [\n                        "juanpa24@correos.com"\n                    ]\n                },\n                "redes sociales": {\n                    "$id": "#/properties/postulante/properties/redes%20sociales",\n                    "type": "array",\n                    "title": "The redes sociales schema",\n                    "description": "An explanation about the purpose of this instance.",\n                    "default": [],\n                    "examples": [\n                        [\n                            {\n                                "instagram": "juanpa24"\n                            },\n                            {\n                                "twitter": "juanpa24"\n                            }\n                        ]\n                    ],\n                    "additionalItems": true,\n                    "items": {\n                        "$id": "#/properties/postulante/properties/redes%20sociales/items",\n                        "anyOf": [\n                            {\n                                "$id": "#/properties/postulante/properties/redes%20sociales/items/anyOf/0",\n                                "type": "object",\n                                "title": "The first anyOf schema",\n                                "description": "An explanation about the purpose of this instance.",\n                                "default": {},\n                                "examples": [\n                                    {\n                                        "instagram": "juanpa24"\n                                    }\n                                ],\n                                "required": [\n                                    "instagram"\n                                ],\n                                "properties": {\n                                    "instagram": {\n                                        "$id": "#/properties/postulante/properties/redes%20sociales/items/anyOf/0/properties/instagram",\n                                        "type": "string",\n                                        "title": "The instagram schema",\n                                        "description": "An explanation about the purpose of this instance.",\n                                        "default": "",\n                                        "examples": [\n                                            "juanpa24"\n                                        ]\n                                    }\n                                },\n                                "additionalProperties": true\n                            },\n                            {\n                                "$id": "#/properties/postulante/properties/redes%20sociales/items/anyOf/1",\n                                "type": "object",\n                                "title": "The second anyOf schema",\n                                "description": "An explanation about the purpose of this instance.",\n                                "default": {},\n                                "examples": [\n                                    {\n                                        "twitter": "juanpa24"\n                                    }\n                                ],\n                                "required": [\n                                    "twitter"\n                                ],\n                                "properties": {\n                                    "twitter": {\n                                        "$id": "#/properties/postulante/properties/redes%20sociales/items/anyOf/1/properties/twitter",\n                                        "type": "string",\n                                        "title": "The twitter schema",\n                                        "description": "An explanation about the purpose of this instance.",\n                                        "default": "",\n                                        "examples": [\n                                            "juanpa24"\n                                        ]\n                                    }\n                                },\n                                "additionalProperties": true\n                            }\n                        ]\n                    }\n                },\n                "experiencia laboral": {\n                    "$id": "#/properties/postulante/properties/experiencia%20laboral",\n                    "type": "array",\n                    "title": "The experiencia laboral schema",\n                    "description": "An explanation about the purpose of this instance.",\n                    "default": [],\n                    "examples": [\n                        [\n                            {\n                                "empresa": {\n                                    "nombre": "Yahoo",\n                                    "lenguaje": "php",\n                                    "años": 4,\n                                    "puesto": "programador",\n                                    "tipo ": "presencial"\n                                }\n                            },\n                            {\n                                "empresa": {\n                                    "nombre": "Mercadolibre",\n                                    "lenguaje": "",\n                                    "años": 1,\n                                    "puesto": "Scrum Master",\n                                    "tipo ": "presencial"\n                                }\n                            }\n                        ]\n                    ],\n                    "additionalItems": true,\n                    "items": {\n                        "$id": "#/properties/postulante/properties/experiencia%20laboral/items",\n                        "anyOf": [\n                            {\n                                "$id": "#/properties/postulante/properties/experiencia%20laboral/items/anyOf/0",\n                                "type": "object",\n                                "title": "The first anyOf schema",\n                                "description": "An explanation about the purpose of this instance.",\n                                "default": {},\n                                "examples": [\n                                    {\n                                        "empresa": {\n                                            "nombre": "Yahoo",\n                                            "lenguaje": "php",\n                                            "años": 4,\n                                            "puesto": "programador",\n                                            "tipo ": "presencial"\n                                        }\n                                    }\n                                ],\n                                "required": [\n                                    "empresa"\n                                ],\n                                "properties": {\n                                    "empresa": {\n                                        "$id": "#/properties/postulante/properties/experiencia%20laboral/items/anyOf/0/properties/empresa",\n                                        "type": "object",\n                                        "title": "The empresa schema",\n                                        "description": "An explanation about the purpose of this instance.",\n                                        "default": {},\n                                        "examples": [\n                                            {\n                                                "nombre": "Yahoo",\n                                                "lenguaje": "php",\n                                                "años": 4,\n                                                "puesto": "programador",\n                                                "tipo ": "presencial"\n                                            }\n                                        ],\n                                        "required": [\n                                            "nombre",\n                                            "lenguaje",\n                                            "años",\n                                            "puesto",\n                                            "tipo "\n                                        ],\n                                        "properties": {\n                                            "nombre": {\n                                                "$id": "#/properties/postulante/properties/experiencia%20laboral/items/anyOf/0/properties/empresa/properties/nombre",\n                                                "type": "string",\n                                                "title": "The nombre schema",\n                                                "description": "An explanation about the purpose of this instance.",\n                                                "default": "",\n                                                "examples": [\n                                                    "Yahoo"\n                                                ]\n                                            },\n                                            "lenguaje": {\n                                                "$id": "#/properties/postulante/properties/experiencia%20laboral/items/anyOf/0/properties/empresa/properties/lenguaje",\n                                                "type": "string",\n                                                "title": "The lenguaje schema",\n                                                "description": "An explanation about the purpose of this instance.",\n                                                "default": "",\n                                                "examples": [\n                                                    "php"\n                                                ]\n                                            },\n                                            "años": {\n                                                "$id": "#/properties/postulante/properties/experiencia%20laboral/items/anyOf/0/properties/empresa/properties/a%C3%B1os",\n                                                "type": "integer",\n                                                "title": "The años schema",\n                                                "description": "An explanation about the purpose of this instance.",\n                                                "default": 0,\n                                                "examples": [\n                                                    4\n                                                ]\n                                            },\n                                            "puesto": {\n                                                "$id": "#/properties/postulante/properties/experiencia%20laboral/items/anyOf/0/properties/empresa/properties/puesto",\n                                                "type": "string",\n                                                "title": "The puesto schema",\n                                                "description": "An explanation about the purpose of this instance.",\n                                                "default": "",\n                                                "examples": [\n                                                    "programador"\n                                                ]\n                                            },\n                                            "tipo ": {\n                                                "$id": "#/properties/postulante/properties/experiencia%20laboral/items/anyOf/0/properties/empresa/properties/tipo%20",\n                                                "type": "string",\n                                                "title": "The tipo  schema",\n                                                "description": "An explanation about the purpose of this instance.",\n                                                "default": "",\n                                                "examples": [\n                                                    "presencial"\n                                                ]\n                                            }\n                                        },\n                                        "additionalProperties": true\n                                    }\n                                },\n                                "additionalProperties": true\n                            }\n                        ]\n                    }\n                },\n                "educación formal": {\n                    "$id": "#/properties/postulante/properties/educaci%C3%B3n%20formal",\n                    "type": "array",\n                    "title": "The educación formal schema",\n                    "description": "An explanation about the purpose of this instance.",\n                    "default": [],\n                    "examples": [\n                        [\n                            {\n                                "tema": "php"\n                            },\n                            {\n                                "lugar": "Instituto"\n                            }\n                        ]\n                    ],\n                    "additionalItems": true,\n                    "items": {\n                        "$id": "#/properties/postulante/properties/educaci%C3%B3n%20formal/items",\n                        "anyOf": [\n                            {\n                                "$id": "#/properties/postulante/properties/educaci%C3%B3n%20formal/items/anyOf/0",\n                                "type": "object",\n                                "title": "The first anyOf schema",\n                                "description": "An explanation about the purpose of this instance.",\n                                "default": {},\n                                "examples": [\n                                    {\n                                        "tema": "php"\n                                    }\n                                ],\n                                "required": [\n                                    "tema"\n                                ],\n                                "properties": {\n                                    "tema": {\n                                        "$id": "#/properties/postulante/properties/educaci%C3%B3n%20formal/items/anyOf/0/properties/tema",\n                                        "type": "string",\n                                        "title": "The tema schema",\n                                        "description": "An explanation about the purpose of this instance.",\n                                        "default": "",\n                                        "examples": [\n                                            "php"\n                                        ]\n                                    }\n                                },\n                                "additionalProperties": true\n                            },\n                            {\n                                "$id": "#/properties/postulante/properties/educaci%C3%B3n%20formal/items/anyOf/1",\n                                "type": "object",\n                                "title": "The second anyOf schema",\n                                "description": "An explanation about the purpose of this instance.",\n                                "default": {},\n                                "examples": [\n                                    {\n                                        "lugar": "Instituto"\n                                    }\n                                ],\n                                "required": [\n                                    "lugar"\n                                ],\n                                "properties": {\n                                    "lugar": {\n                                        "$id": "#/properties/postulante/properties/educaci%C3%B3n%20formal/items/anyOf/1/properties/lugar",\n                                        "type": "string",\n                                        "title": "The lugar schema",\n                                        "description": "An explanation about the purpose of this instance.",\n                                        "default": "",\n                                        "examples": [\n                                            "Instituto"\n                                        ]\n                                    }\n                                },\n                                "additionalProperties": true\n                            }\n                        ]\n                    }\n                },\n                "aspiraciones": {\n                    "$id": "#/properties/postulante/properties/aspiraciones",\n                    "type": "array",\n                    "title": "The aspiraciones schema",\n                    "description": "An explanation about the purpose of this instance.",\n                    "default": [],\n                    "examples": [\n                        [\n                            {\n                                "lenguajes": [\n                                    "javascript",\n                                    "android"\n                                ]\n                            },\n                            {\n                                "puestos": [\n                                    "DevOps"\n                                ]\n                            }\n                        ]\n                    ],\n                    "additionalItems": true,\n                    "items": {\n                        "$id": "#/properties/postulante/properties/aspiraciones/items",\n                        "anyOf": [\n                            {\n                                "$id": "#/properties/postulante/properties/aspiraciones/items/anyOf/0",\n                                "type": "object",\n                                "title": "The first anyOf schema",\n                                "description": "An explanation about the purpose of this instance.",\n                                "default": {},\n                                "examples": [\n                                    {\n                                        "lenguajes": [\n                                            "javascript",\n                                            "android"\n                                        ]\n                                    }\n                                ],\n                                "required": [\n                                    "lenguajes"\n                                ],\n                                "properties": {\n                                    "lenguajes": {\n                                        "$id": "#/properties/postulante/properties/aspiraciones/items/anyOf/0/properties/lenguajes",\n                                        "type": "array",\n                                        "title": "The lenguajes schema",\n                                        "description": "An explanation about the purpose of this instance.",\n                                        "default": [],\n                                        "examples": [\n                                            [\n                                                "javascript",\n                                                "android"\n                                            ]\n                                        ],\n                                        "additionalItems": true,\n                                        "items": {\n                                            "$id": "#/properties/postulante/properties/aspiraciones/items/anyOf/0/properties/lenguajes/items",\n                                            "anyOf": [\n                                                {\n                                                    "$id": "#/properties/postulante/properties/aspiraciones/items/anyOf/0/properties/lenguajes/items/anyOf/0",\n                                                    "type": "string",\n                                                    "title": "The first anyOf schema",\n                                                    "description": "An explanation about the purpose of this instance.",\n                                                    "default": "",\n                                                    "examples": [\n                                                        "javascript",\n                                                        "android"\n                                                    ]\n                                                }\n                                            ]\n                                        }\n                                    }\n                                },\n                                "additionalProperties": true\n                            },\n                            {\n                                "$id": "#/properties/postulante/properties/aspiraciones/items/anyOf/1",\n                                "type": "object",\n                                "title": "The second anyOf schema",\n                                "description": "An explanation about the purpose of this instance.",\n                                "default": {},\n                                "examples": [\n                                    {\n                                        "puestos": [\n                                            "DevOps"\n                                        ]\n                                    }\n                                ],\n                                "required": [\n                                    "puestos"\n                                ],\n                                "properties": {\n                                    "puestos": {\n                                        "$id": "#/properties/postulante/properties/aspiraciones/items/anyOf/1/properties/puestos",\n                                        "type": "array",\n                                        "title": "The puestos schema",\n                                        "description": "An explanation about the purpose of this instance.",\n                                        "default": [],\n                                        "examples": [\n                                            [\n                                                "DevOps"\n                                            ]\n                                        ],\n                                        "additionalItems": true,\n                                        "items": {\n                                            "$id": "#/properties/postulante/properties/aspiraciones/items/anyOf/1/properties/puestos/items",\n                                            "anyOf": [\n                                                {\n                                                    "$id": "#/properties/postulante/properties/aspiraciones/items/anyOf/1/properties/puestos/items/anyOf/0",\n                                                    "type": "string",\n                                                    "title": "The first anyOf schema",\n                                                    "description": "An explanation about the purpose of this instance.",\n                                                    "default": "",\n                                                    "examples": [\n                                                        "DevOps"\n                                                    ]\n                                                }\n                                            ]\n                                        }\n                                    }\n                                },\n                                "additionalProperties": true\n                            },\n                            {\n                                "$id": "#/properties/postulante/properties/aspiraciones/items/anyOf/2",\n                                "type": "object",\n                                "title": "The third anyOf schema",\n                                "description": "An explanation about the purpose of this instance.",\n                                "default": {},\n                                "examples": [\n                                    {\n                                        "conocimientos": [\n                                            "git",\n                                            " redes"\n                                        ]\n                                    }\n                                ],\n                                "required": [\n                                    "conocimientos"\n                                ],\n                                "properties": {\n                                    "conocimientos": {\n                                        "$id": "#/properties/postulante/properties/aspiraciones/items/anyOf/2/properties/conocimientos",\n                                        "type": "array",\n                                        "title": "The conocimientos schema",\n                                        "description": "An explanation about the purpose of this instance.",\n                                        "default": [],\n                                        "examples": [\n                                            [\n                                                "git",\n                                                " redes"\n                                            ]\n                                        ],\n                                        "additionalItems": true,\n                                        "items": {\n                                            "$id": "#/properties/postulante/properties/aspiraciones/items/anyOf/2/properties/conocimientos/items",\n                                            "anyOf": [\n                                                {\n                                                    "$id": "#/properties/postulante/properties/aspiraciones/items/anyOf/2/properties/conocimientos/items/anyOf/0",\n                                                    "type": "string",\n                                                    "title": "The first anyOf schema",\n                                                    "description": "An explanation about the purpose of this instance.",\n                                                    "default": "",\n                                                    "examples": [\n                                                        "git",\n                                                        " redes"\n                                                    ]\n                                                }\n                                            ]\n                                        }\n                                    }\n                                },\n                                "additionalProperties": false\n                            }\n                        ]\n                    }\n                }\n            },\n            "additionalProperties": false\n        }\n    },\n    "additionalProperties": false\n}\n',`cjson`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `productos` (
  `cod_producto` int NOT NULL AUTO_INCREMENT,
  `cod_analista` int NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `estado` enum('Si','No') DEFAULT 'No',
  `descripcion` tinytext,
  `tipo` enum('Software','Prototipo','Informe Técnico') NOT NULL,
  PRIMARY KEY (`cod_producto`),
  KEY `cod_analista` (`cod_analista`),
  CONSTRAINT `productos_ibfk_1` FOREIGN KEY (`cod_analista`) REFERENCES `analistas` (`cod_analista`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `programador_lenguaje` (
  `cod_lenguaje` int NOT NULL,
  `cod_programador` int NOT NULL,
  PRIMARY KEY (`cod_lenguaje`,`cod_programador`),
  KEY `cod_programador` (`cod_programador`),
  CONSTRAINT `programador_lenguaje_ibfk_1` FOREIGN KEY (`cod_lenguaje`) REFERENCES `lenguajes` (`cod_lenguaje`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `programador_lenguaje_ibfk_2` FOREIGN KEY (`cod_programador`) REFERENCES `programadores` (`cod_programador`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `programadores` (
  `cod_programador` int NOT NULL,
  PRIMARY KEY (`cod_programador`),
  CONSTRAINT `programadores_ibfk_1` FOREIGN KEY (`cod_programador`) REFERENCES `informaticos` (`cod_informatico`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `prototipos` (
  `cod_producto` int NOT NULL,
  `version` varchar(20) DEFAULT NULL,
  `ubicacion` text,
  PRIMARY KEY (`cod_producto`),
  CONSTRAINT `prototipos_ibfk_1` FOREIGN KEY (`cod_producto`) REFERENCES `productos` (`cod_producto`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `proyectos` (
  `cod_proyecto` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(80) NOT NULL,
  `descripcion` varchar(50) DEFAULT NULL,
  `cliente` varchar(80) NOT NULL,
  `fecha_inicio` datetime DEFAULT CURRENT_TIMESTAMP,
  `fecha_fin` datetime NOT NULL,
  `horas_estimadas` float DEFAULT NULL,
  `presupuesto` float DEFAULT NULL,
  PRIMARY KEY (`cod_proyecto`),
  CONSTRAINT `fecha_fin_proyectos_check` CHECK ((`fecha_fin` >= `fecha_inicio`))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recursos` (
  `cod_recurso` int NOT NULL,
  `nombre` varchar(70) NOT NULL,
  `descripcion` text,
  `tipo` enum('Hw','Sw') NOT NULL,
  `costo` float NOT NULL,
  `fecha_adquisicion` datetime DEFAULT CURRENT_TIMESTAMP,
  `baja` enum('Si','No') NOT NULL,
  PRIMARY KEY (`cod_recurso`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `relacionado_con` (
  `cod_proyecto1` int NOT NULL,
  `cod_proyecto2` int NOT NULL,
  `keyword` tinytext NOT NULL,
  PRIMARY KEY (`cod_proyecto1`,`cod_proyecto2`),
  KEY `cod_proyecto2` (`cod_proyecto2`),
  CONSTRAINT `relacionado_con_ibfk_1` FOREIGN KEY (`cod_proyecto1`) REFERENCES `proyectos` (`cod_proyecto`),
  CONSTRAINT `relacionado_con_ibfk_2` FOREIGN KEY (`cod_proyecto2`) REFERENCES `proyectos` (`cod_proyecto`),
  CONSTRAINT `proyectos_relacionado_con_check` CHECK ((`cod_proyecto1` <> `cod_proyecto2`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `se_asigna` (
  `fecha_i` datetime DEFAULT CURRENT_TIMESTAMP,
  `fecha_f` datetime DEFAULT NULL,
  `cod_recurso` int NOT NULL,
  `cod_fase` int NOT NULL,
  `cod_proyecto` int NOT NULL,
  `nombre` varchar(70) DEFAULT NULL,
  PRIMARY KEY (`cod_recurso`,`cod_fase`,`cod_proyecto`),
  KEY `cod_proyecto` (`cod_proyecto`,`cod_fase`),
  CONSTRAINT `se_asigna_ibfk_1` FOREIGN KEY (`cod_proyecto`, `cod_fase`) REFERENCES `fases` (`cod_proyecto`, `cod_fase`) ON UPDATE CASCADE,
  CONSTRAINT `se_asigna_ibfk_2` FOREIGN KEY (`cod_recurso`) REFERENCES `recursos` (`cod_recurso`) ON UPDATE CASCADE,
  CONSTRAINT `fecha_f_se_asigna_check` CHECK ((`fecha_f` >= `fecha_i`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `softwares` (
  `cod_producto` int NOT NULL,
  `tipo` varchar(30) NOT NULL,
  PRIMARY KEY (`cod_producto`),
  CONSTRAINT `softwares_ibfk_1` FOREIGN KEY (`cod_producto`) REFERENCES `productos` (`cod_producto`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trabaja` (
  `num_horas` float NOT NULL,
  `coste_total` float NOT NULL,
  `cod_informatico` int NOT NULL,
  `cod_proyecto` int NOT NULL,
  PRIMARY KEY (`cod_informatico`,`cod_proyecto`),
  KEY `cod_proyecto` (`cod_proyecto`),
  CONSTRAINT `trabaja_ibfk_1` FOREIGN KEY (`cod_informatico`) REFERENCES `informaticos` (`cod_informatico`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `trabaja_ibfk_2` FOREIGN KEY (`cod_proyecto`) REFERENCES `proyectos` (`cod_proyecto`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
