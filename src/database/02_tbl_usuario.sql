-- TABLE USUARIO 

CREATE TABLE tbl_usuario(
  id INT NOT NULL AUTO_INCREMENT UNIQUE,
  foto              VARCHAR(200) DEFAULT NULL,
	nombres           VARCHAR(60),
	apellidos         VARCHAR(60),
  nombre_completo   VARCHAR (120), 
	telefono          VARCHAR(15) ,
	correo            VARCHAR(100) NOT NULL,
	clave             VARCHAR(100),
  rol               VARCHAR(100),
  createdBy         INT,
  updatedBy         INT,
  deletedBy         INT,
  createdAt         TIMESTAMP NULL DEFAULT NULL,
  updatedAt         TIMESTAMP NULL DEFAULT NULL,
  deletedAt         TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT pk_tbl_usuario PRIMARY KEY (id)
);




-- INSERT usuario con su rol
-- DROP PROCEDURE IF EXISTS sp_insertar_usuario;
DELIMITER $$

CREATE PROCEDURE sp_insertar_usuario (_nombres VARCHAR(60), _apellidos VARCHAR(60),_telefono VARCHAR(15),_correo VARCHAR(50),_clave VARCHAR(50),_path_foto VARCHAR(300),_id_rol INT,_createdBy INT)
BEGIN
    DECLARE _id_usuario INT;
    DECLARE _id_usuario_rol INT;
    DECLARE _rol VARCHAR(100);
    DECLARE duplicate_key INT DEFAULT 0;
    DECLARE sql_exception INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR 1062 SET duplicate_key = 1;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION SET sql_exception = 1;
    
    SET duplicate_key = 0;
    SET sql_exception = 0;

    -- Check for duplicate email
    SELECT COUNT(*) INTO duplicate_key FROM tbl_usuario WHERE correo = _correo;
    
    IF duplicate_key = 1 THEN
        SELECT FALSE AS exito, "0" AS id, CONCAT("Ya existe una cuenta registrada con el correo: ", _correo) AS message;
    ELSE
        -- Check if the specified role exists
        SELECT nombre INTO _rol FROM tbl_rol WHERE id = _id_rol AND deletedAt IS NULL LIMIT 1;
        
        IF _rol IS NOT NULL THEN
            -- Insert user
            INSERT INTO tbl_usuario (nombres, apellidos, nombre_completo, telefono, correo, clave, foto, rol, createdBy, createdAt)
            VALUES (_nombres, _apellidos, CONCAT(_nombres, " ", _apellidos), _telefono, _correo, PASSWORD(_clave), _path_foto, _rol, _createdBy, NOW());
            
            SET _id_usuario = LAST_INSERT_ID();
            
            -- Insert user role
            INSERT INTO tbl_usuario_rol (id_usuario, id_rol, activo, verificado, conectado, conectedAt, createdBy, createdAt)
            VALUES (_id_usuario, _id_rol, 1, 0, 0, NOW(), _createdBy, NOW());
            
            SET _id_usuario_rol = LAST_INSERT_ID();
            
            SELECT TRUE AS exito, CONVERT(_id_usuario_rol, CHAR) AS id, 'Registro insertado correctamente' AS message;
        ELSE
            SELECT FALSE AS exito, "0" AS id, 'Error: no puede asignar un rol que no existe' AS message;
        END IF;
    END IF;
END$$

DELIMITER ;



-- INSERT INTO `tbl_usuario` (`id`, `foto`, `nombres`, `apellidos`, `telefono`, `correo`, `clave`, `createdBy`, `updatedBy`, `deletedBy`, `createdAt`, `updatedAt`, `deletedAt`) VALUES (NULL, NULL, 'William ', 'Puma', '08786767', 'wgpummaq@utn.edu.ec', '12345', '', NULL, NULL, '', NULL, NULL)
--- ejecutar
-- CALL sp_insertar_usuario ('William','Puma','0997702533','wgpumaq@utn.edu.ec','12345','images/wili',1,1)



-- ACTUALIZAR usuario con su rol
-- DROP PROCEDURE IF EXISTS sp_actualizar_usuario;
DELIMITER $$
CREATE PROCEDURE sp_actualizar_usuario (_id_usuario_rol INT, _nombres VARCHAR(60), _apellidos VARCHAR(60), _telefono VARCHAR(15), _correo VARCHAR(50), _activo BOOLEAN, _path_foto VARCHAR(300), _id_rol INT, _updatedBy INT)

BEGIN
  DECLARE _id_usuario INT;
  DECLARE _rol VARCHAR(100);
  DECLARE duplicate_key INT DEFAULT 0;
  DECLARE register_foud INT DEFAULT 0;     
  DECLARE sql_exception INT DEFAULT 0;     
  DECLARE CONTINUE HANDLER FOR 1062 SET duplicate_key = 1;     
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_exception = 1; 

  IF EXISTS (SELECT * FROM tbl_usuario u, tbl_usuario_rol ur WHERE u.id = ur.id_usuario AND u.correo = _correo AND ur.id <> _id_usuario_rol) THEN
    SELECT FALSE AS exito, "0" AS id, CONCAT("Ya existe una cuenta registrada con el correo: ", _correo) AS message;
  ELSE
    IF (SELECT deletedAt FROM tbl_usuario_rol WHERE id = _id_usuario_rol) IS NULL AND EXISTS(SELECT * FROM tbl_usuario_rol WHERE id = _id_usuario_rol) THEN
      IF (SELECT deletedAt FROM tbl_rol WHERE id = _id_rol) IS NULL AND EXISTS(SELECT * FROM tbl_rol WHERE id = _id_rol) THEN
        SET _id_usuario = (SELECT id_usuario FROM tbl_usuario_rol WHERE id = _id_usuario_rol);
        UPDATE tbl_usuario_rol SET activo = _activo, id_rol = _id_rol, updatedBy = _updatedBy, updatedAt = NOW() WHERE id = _id_usuario_rol;
        SET _rol = (SELECT nombre FROM tbl_rol WHERE id = _id_rol);
        UPDATE tbl_usuario SET
          nombres = _nombres,
          apellidos = _apellidos,
          nombre_completo = CONCAT(_nombres, " ", _apellidos),
          telefono = _telefono,
          correo = _correo,
          foto = _path_foto,
          rol = _rol,
          updatedBy = _updatedBy,
          updatedAt = NOW()
        WHERE id = _id_usuario;

        IF sql_exception = 0 THEN
          SELECT TRUE AS exito, CONVERT(_id_usuario_rol, CHAR) AS id, 'Registro actualizado correctamente' AS message;
        ELSE
          SELECT FALSE AS exito, "0" AS id, 'Error no puede asignar un rol que no existe' AS message;
        END IF;
      ELSE
        SELECT FALSE AS exito, "0" AS id, 'Error no puede asignar un rol que no existe' AS message;
      END IF;
    ELSE
      SELECT FALSE AS exito, "0" AS id, 'El registro que desea actualizar no existe' AS message;
    END IF;
  END IF;
END
$$




--- ejecutar
-- CALL sp_actualizar_usuario (80,'Carlos2','Cumbal','0997702533','carlos@utn.edu.ec',0,'images/wili',29,1)



-- SELECT listar usuarios
-- DROP PROCEDURE IF EXISTS sp_listar_usuarios;

DELIMITER $$
CREATE PROCEDURE sp_listar_usuarios(
  _rol int,
  _columna varchar(250),
  _nombre varchar(250),
  _offset int,
  _limit int,
  _sort VARCHAR(100))
BEGIN

 DECLARE _selectQuery varchar(3000);
 DECLARE _auxQuery varchar(300);
 DECLARE _orderBy varchar(300);
 DECLARE _rolBy varchar(300);
 DECLARE _pagination varchar(300);

     -- exit if the duplicate key occurs
 DECLARE EXIT HANDLER FOR 1062 SELECT false as exito,"Error al realizar la consulta"  message; 
 
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,0 as id ,@text message; 
  END;
IF _rol IS NOT NULL AND CHAR_LENGTH(TRIM(_rol)) > 0  then
   SET _rolBy = CONCAT("AND r.id=",TRIM(_rol));
  else
   SET _rolBy = " ";
  end IF;

  IF _nombre IS NOT NULL AND CHAR_LENGTH(TRIM(_nombre)) > 0 AND _columna IS NOT NULL AND CHAR_LENGTH(TRIM(_columna)) > 0 then
   SET _auxQuery = CONCAT(" AND u.",TRIM(_columna)," like '%",TRIM(_nombre),"%'");
  else
   SET _auxQuery = " ";
  end IF;

  IF _sort IS NOT NULL AND CHAR_LENGTH(TRIM(_sort))> 0 then
   SET _orderBy = CONCAT(" order by u.",TRIM(_sort));
  else
   SET _orderBy = " ORDER BY u.id ASC ";
  end IF;

  IF _limit IS NOT NULL AND _limit > 0 then
   SET _pagination = CONCAT(" LIMIT ",_limit," OFFSET ",_offset);
  else
   SET _pagination = " ";
  end IF;


 SET _selectQuery = CONCAT("SELECT CONVERT(ur.id,CHAR) as id , ur.verificado, u.foto, u.nombres, u.apellidos, u.nombre_completo, 
 u.telefono, u.correo, u.rol,CONVERT(r.id,CHAR) as id_rol, ur.activo as activo, ur.conectado as conectado, ur.conectedAt as conectedAt,
 (SELECT calificacion FROM tbl_session WHERE id_usuario =ur.id AND createdAt= (SELECT MAX(createdAt) FROM tbl_session WHERE id_usuario=ur.id) LIMIT 1) as calificacion
  FROM tbl_usuario u, tbl_rol r, tbl_usuario_rol ur WHERE ur.deletedAt IS NULL AND u.deletedAt IS NULL AND 
  u.id=ur.id_usuario AND r.id=ur.id_rol ",
  _rolBy,_auxQuery,_orderBy,_pagination);

  PREPARE stmt1 FROM _selectQuery; 
  EXECUTE stmt1; 
  DEALLOCATE PREPARE stmt1; 

END
$$
-- ejecutar
-- CALL sp_listar_usuarios (null, '', '', 0, 0, null);

-- SELECT listar un usuario
-- DROP PROCEDURE IF EXISTS sp_obtener_usuario;

DELIMITER $$
CREATE PROCEDURE sp_obtener_usuario(_id_usuario_rol int)
BEGIN
 DECLARE _id_usuario int;
      -- exit if the duplicate key occurs
   DECLARE sql_exception INT DEFAULT 0;     
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_exception = 1; 
 SET _id_usuario = (SELECT id_usuario FROM tbl_usuario_rol WHERE id=_id_usuario_rol);

SELECT CONVERT(ur.id,CHAR) as id, ur.verificado, u.foto, u.nombres, u.apellidos, u.nombre_completo, u.telefono,
  u.correo,u.rol, CONVERT(r.id,CHAR) as id_rol, ur.activo as activo, ur.conectado as conectado, ur.conectedAt as conectedAt,
  (SELECT calificacion FROM tbl_session WHERE id_usuario =ur.id AND createdAt= (SELECT MAX(createdAt) FROM tbl_session WHERE id_usuario=ur.id) LIMIT 1) as calificacion
   FROM tbl_usuario u, tbl_rol r, tbl_usuario_rol ur WHERE u.deletedAt IS NULL AND ur.deletedAt IS NULL AND u.id=_id_usuario
  AND u.id=ur.id_usuario AND r.id=ur.id_rol;
END
$$
-- ejecutar
-- CALL sp_obtener_usuario (28);




-- SELECT listar un usuario por correo
-- DROP PROCEDURE IF EXISTS sp_obtener_usuario_by_correo;

DELIMITER $$
CREATE PROCEDURE sp_obtener_usuario_by_correo(_correo varchar(100))
BEGIN
 DECLARE _id_usuario int;
      -- exit if the duplicate key occurs
 DECLARE sql_exception INT DEFAULT 0;     
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_exception = 1; 

 SET _id_usuario = (SELECT id_usuario FROM tbl_usuario_rol ur, tbl_usuario u WHERE ur.id_usuario= u.id AND u.correo=_correo);

SELECT CONVERT(ur.id,CHAR) as id, ur.verificado, u.foto, u.nombres, u.apellidos, u.nombre_completo, u.telefono,
  u.correo,u.rol, CONVERT(r.id,CHAR) as id_rol, ur.activo as activo, ur.conectado as conectado, ur.conectedAt as conectedAt,
  (SELECT calificacion FROM tbl_session WHERE id_usuario =ur.id AND createdAt= (SELECT MAX(createdAt) FROM tbl_session WHERE id_usuario=ur.id)) as calificacion
   FROM tbl_usuario u, tbl_rol r, tbl_usuario_rol ur WHERE u.deletedAt IS NULL AND ur.deletedAt IS NULL AND u.id=_id_usuario
  AND u.id=ur.id_usuario AND r.id=ur.id_rol;
END
$$
-- ejecutar
-- CALL sp_obtener_usuario_by_correo ('carlos@utn.edu.ec');



-- DELETE usuario
-- DROP PROCEDURE IF EXISTS sp_eliminar_usuario;

DELIMITER $$
CREATE PROCEDURE sp_eliminar_usuario(_id_usuario_rol int,_deletedBy int) 

BEGIN  
 DECLARE _id_usuario int;   
  -- exit if the duplicate key occurs
   DECLARE sql_exception INT DEFAULT 0;     
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_exception = 1; 
 
  IF (SELECT deletedAt FROM tbl_usuario_rol WHERE id=_id_usuario_rol) IS NULL AND EXISTS(SELECT * FROM tbl_usuario_rol WHERE id=_id_usuario_rol) THEN

 SET _id_usuario = (SELECT id_usuario FROM tbl_usuario_rol WHERE id=_id_usuario_rol);

 
 UPDATE tbl_usuario_rol set activo = 0, deletedAt = NOW(),deletedBy=_deletedBy where id= _id_usuario_rol;


 UPDATE tbl_usuario set  deletedAt = NOW(),deletedBy=_deletedBy where id= _id_usuario;
 SELECT true as exito, CONVERT(_id_usuario_rol,CHAR) as id, 'Registro eliminado correctamente' as message;
 else
  SELECT false as exito, "0" as id, 'El registro que desea eliminar no existe' as message;
 end IF;

END 
$$
-- ejecutar
-- CALL sp_eliminar_usuario (28,4);


