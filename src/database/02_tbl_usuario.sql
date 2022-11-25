-- TABLE USUARIO 

CREATE TABLE tbl_usuario(
  id INT NOT NULL AUTO_INCREMENT UNIQUE,
  foto              VARCHAR(100),
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
CREATE PROCEDURE sp_insertar_usuario (_nombres VARCHAR(60), _apellidos VARCHAR(60),_telefono VARCHAR(15),_correo VARCHAR(50),_clave VARCHAR(50),_path_foto VARCHAR(300),_id_rol int,_createdBy int)

BEGIN
    DECLARE  _id_usuario int;
    DECLARE  _id_usuario_rol int;
    DECLARE _rol VARCHAR(100);
        -- exit if the duplicate key occurs
 DECLARE EXIT HANDLER FOR 1062 SELECT false as exito,"Error al insertar el registro"  message; 
 
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,@text message; 
  END;
  IF EXISTS(SELECT * FROM tbl_usuario WHERE correo=_correo) THEN
 SELECT false as exito,CONCAT("Ya existe una cuenta registrada con el correo: ",_correo) as message; 
  else
   IF (SELECT deletedAt FROM tbl_rol WHERE id=_id_rol) IS NULL AND EXISTS(SELECT * FROM tbl_rol WHERE id=_id_rol) THEN  
  SET _rol=(SELECT nombre FROM tbl_rol WHERE id=_id_rol);
  INSERT INTO tbl_usuario
        (nombres,
        apellidos,
        nombre_completo,
        telefono,
        correo,
        clave,
        foto,
        rol,
        createdBy,
        createdAt)
     VALUES
      (_nombres,
        _apellidos,
        CONCAT(_nombres," ",_apellidos),
        _telefono,
        _correo,
        PASSWORD(_clave),
        _path_foto,
        _rol,
        _createdBy,
         NOW());

  set _id_usuario   = LAST_INSERT_ID();

  INSERT INTO tbl_usuario_rol
       (id_usuario,
       id_rol,
       activo,
      verificado,
      conectado,
      conectedAt,
       createdBy,
       createdAt)
     VALUES
      (_id_usuario,
       _id_rol,
        1,
       0,
       0,
       NOW(),
       _createdBy,
      NOW());
        set _id_usuario_rol   = LAST_INSERT_ID();
      
   SELECT true as exito,'Registro insertado correctamente' as message; 
    else
  SELECT false as exito, 'Error no puede asignar un rol que no existe' as message;
 end IF;
 end IF;

 END
$$


-- INSERT INTO `tbl_usuario` (`id`, `foto`, `nombres`, `apellidos`, `telefono`, `correo`, `clave`, `createdBy`, `updatedBy`, `deletedBy`, `createdAt`, `updatedAt`, `deletedAt`) VALUES (NULL, NULL, 'William ', 'Puma', '08786767', 'wgpummaq@utn.edu.ec', '12345', '', NULL, NULL, '', NULL, NULL)
--- ejecutar
-- CALL sp_insertar_usuario ('William','Puma','0997702533','wgpumaq@utn.edu.ec','12345','images/wili',1,1)



-- ACTUALIZAR usuario con su rol
-- DROP PROCEDURE IF EXISTS sp_actualizar_usuario;


DELIMITER $$
CREATE PROCEDURE sp_actualizar_usuario (_id_usuario_rol INT,_nombres VARCHAR(60), _apellidos VARCHAR(60),_telefono VARCHAR(15),_correo VARCHAR(50),_activo BOOLEAN,_path_foto VARCHAR(300),_id_rol INT,_updatedBy INT)

BEGIN
  DECLARE _id_usuario int;   
  DECLARE _rol VARCHAR(100);
  -- exit if the duplicate key occurs
  DECLARE EXIT HANDLER FOR 1062 SELECT false as exito,"Error al actualizar el registro"  message;  
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,@text message; 
  END;
    IF EXISTS(SELECT * FROM tbl_usuario u,tbl_usuario_rol ur WHERE u.id=ur.id_usuario AND u.correo=_correo AND ur.id<>_id_usuario_rol) THEN
 SELECT false as exito,CONCAT("Ya existe una cuenta registrada con el correo: ",_correo) as message; 
  else
  IF (SELECT deletedAt FROM tbl_usuario_rol WHERE id=_id_usuario_rol) IS NULL AND EXISTS(SELECT * FROM tbl_usuario_rol WHERE id=_id_usuario_rol) THEN
 
   IF (SELECT deletedAt FROM tbl_rol WHERE id=_id_rol) IS NULL AND EXISTS(SELECT * FROM tbl_rol WHERE id=_id_rol) THEN  
   SET _id_usuario = (SELECT id_usuario FROM tbl_usuario_rol WHERE id=_id_usuario_rol);
  
  UPDATE  tbl_usuario_rol SET activo=_activo,id_rol=_id_rol,updatedBy=_updatedBy, updatedAt=NOW() WHERE id=_id_usuario_rol;
   SET _rol=(SELECT nombre FROM tbl_rol WHERE id=_id_rol);
  UPDATE tbl_usuario SET
        nombres=_nombres,
        apellidos=_apellidos,
        nombre_completo= CONCAT(_nombres," ",_apellidos),
        telefono=_telefono,
        correo=_correo,
        foto=_path_foto,
        rol=_rol,
        updatedBy=_updatedBy,
        updatedAt=NOW()
     WHERE 
     id=_id_usuario;

   SELECT true as exito,'Registro actualizado correctamente' as message; 
  else
  SELECT false as exito,'Error no puede asignar un rol que no existe' as message;
 end IF;
  else
   SELECT false as exito,'El registro que desea actualizar no existe' as message; 
  end IF;
  end IF;

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

     -- exit if the duplicate key occurs
 DECLARE EXIT HANDLER FOR 1062 SELECT false as exito,"Error al realizar la consulta"  message; 
 
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,@text message; 
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

 SET _selectQuery = CONCAT("SELECT CONVERT(ur.id,CHAR) as id , ur.verificado, u.foto, u.nombres, u.apellidos, u.nombre_completo, u.telefono, u.correo, u.rol, CONVERT(r.id,CHAR) as id_rol, ur.activo as activo, ur.conectado as conectado, ur.conectedAt as conectedAt FROM tbl_usuario u, tbl_rol r, tbl_usuario_rol ur WHERE ur.deletedAt IS NULL AND u.deletedAt IS NULL AND u.id=ur.id_usuario AND r.id=ur.id_rol ",
  _rolBy,_auxQuery,_orderBy," LIMIT ",_limit," OFFSET ",_offset);

  PREPARE stmt1 FROM _selectQuery; 
  EXECUTE stmt1; 
  DEALLOCATE PREPARE stmt1; 

END
$$
-- ejecutar
-- CALL sp_listar_usuarios (null, '', '', 0, 14, null);



-- SELECT listar un usuario
-- DROP PROCEDURE IF EXISTS sp_obtener_usuario;

DELIMITER $$
CREATE PROCEDURE sp_obtener_usuario(_id_usuario_rol int)
BEGIN
 DECLARE _id_usuario int;
      -- exit if the duplicate key occurs
 DECLARE EXIT HANDLER FOR 1062 SELECT false as exito, "Error al realizar la consulta"  message; 
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,@text message; 
  END;
 SET _id_usuario = (SELECT id_usuario FROM tbl_usuario_rol WHERE id=_id_usuario_rol);

 SELECT CONVERT(ur.id,CHAR) as id, ur.verificado, u.foto, u.nombres, u.apellidos, u.nombre_completo, u.telefono, u.correo,u.rol, CONVERT(r.id,CHAR) as id_rol, ur.activo as activo, ur.conectado as conectado, ur.conectedAt as conectedAt FROM tbl_usuario u, tbl_rol r, tbl_usuario_rol ur WHERE u.deletedAt IS NULL AND ur.deletedAt IS NULL AND u.id=_id_usuario AND u.id=ur.id_usuario AND r.id=ur.id_rol;

END
$$
-- ejecutar
-- CALL sp_obtener_usuario (28);




-- DELETE usuario
-- DROP PROCEDURE IF EXISTS sp_eliminar_usuario;

DELIMITER $$
CREATE PROCEDURE sp_eliminar_usuario(_id_usuario_rol int,_deletedBy int) 

BEGIN  
 DECLARE _id_usuario int;   
        -- exit if the duplicate key occurs
 DECLARE EXIT HANDLER FOR 1062 SELECT false as exito, "Error al realizar la consulta"  message; 
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,@text message; 
  END;
  IF (SELECT deletedAt FROM tbl_usuario_rol WHERE id=_id_usuario_rol) IS NULL AND EXISTS(SELECT * FROM tbl_usuario_rol WHERE id=_id_usuario_rol) THEN

 SET _id_usuario = (SELECT id_usuario FROM tbl_usuario_rol WHERE id=_id_usuario_rol);

 
 UPDATE tbl_usuario_rol set activo = 0, deletedAt = NOW(),deletedBy=_deletedBy where id= _id_usuario_rol;


 UPDATE tbl_usuario set  deletedAt = NOW(),deletedBy=_deletedBy where id= _id_usuario;
 SELECT true as exito, 'Registro eliminado correctamente' as message;
 else
  SELECT false as exito, 'El registro que desea eliminar no existe' as message;
 end IF;

END 
$$
-- ejecutar
-- CALL sp_eliminar_usuario (28,4);


