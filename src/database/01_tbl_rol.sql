use bibliotecautn
-- TABLE tbl_rol

CREATE TABLE tbl_rol(
  id           INT NOT NULL AUTO_INCREMENT UNIQUE,
	nombre       VARCHAR(80) NOT NULL,
	descripcion  VARCHAR(100) NOT NULL,
  createdBy    INT,
  updatedBy    INT,
  deletedBy    INT,
  createdAt    TIMESTAMP NULL DEFAULT NULL,
  updatedAt    TIMESTAMP NULL DEFAULT NULL,
  deletedAt    TIMESTAMP NULL DEFAULT NULL,
  CONSTRAINT pk_tbl_rol PRIMARY KEY (id)
);





-- INSERT rol
-- DROP PROCEDURE IF EXISTS sp_insertar_rol;

DELIMITER $$
CREATE PROCEDURE sp_insertar_rol (_nombre VARCHAR(60),_descripcion VARCHAR(80),_createBy int)

BEGIN
    -- exit if the duplicate key occurs
  DECLARE _id_rol VARCHAR(50);
   DECLARE EXIT HANDLER FOR SQLEXCEPTION

   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,@text message; 
  END;
  IF (SELECT COUNT(id)  FROM tbl_rol WHERE deletedAt IS NULL AND nombre=_nombre) =0 THEN
  INSERT INTO tbl_rol
        (nombre,
        descripcion,
        createdBy,
        createdAt)
     VALUES
      (_nombre,
      _descripcion,
      _createBy,
         NOW()); 
         set _id_rol   = LAST_INSERT_ID();     
   SELECT true as exito, CONVERT(_id_rol,CHAR) as id,'Rol insertado correctamente' as message; 
else 
SELECT false as exito,"0" as id, CONCAT("Ya existe un rol registrado con el nombre: ",_nombre)  message; 
end IF;

 END
$$

--- ejecutar
-- CALL sp_insertar_rol ('Administrador','Acceso administrar la plataforma',0),




-- ACTUALIZAR usuario con su rol
-- DROP PROCEDURE IF EXISTS sp_actualizar_rol;

DELIMITER $$
CREATE PROCEDURE sp_actualizar_rol (_id_rol INT,_nombre VARCHAR(80), _descripcion VARCHAR(100),_updateBy int)

BEGIN
    -- exit if the duplicate key occurs
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,@text message; 
  END;
  IF (SELECT deletedAt FROM tbl_rol WHERE id=_id_rol) IS NULL AND EXISTS(SELECT * FROM tbl_rol WHERE id=_id_rol) THEN
    IF (SELECT COUNT(id)  FROM tbl_rol WHERE deletedAt IS NULL AND nombre=_nombre AND id !=_id_rol) =0 THEN
  UPDATE tbl_rol SET
        nombre=_nombre,
        descripcion=_descripcion,
        updatedBy=_updateBy,
        updatedAt=NOW()
     WHERE 
     id=_id_rol;
      
   SELECT true as exito,CONVERT(_id_rol,CHAR) as id,'Registro actualizado correctamente' as message; 
   else 
SELECT false as exito,"0" as id, CONCAT("Ya existe un rol registrado con el nombre: ",_nombre)  message; 
end IF;
   else
   SELECT false as exito,"0" as id, 'El registro que desea actualizar no existe' as message; 
   end IF;

 END
$$

--- ejecutar
-- CALL sp_actualizar_rol (1,'1004096572','William',4)



-- OBTENER rol
-- DROP PROCEDURE IF EXISTS sp_obtener_rol;

DELIMITER $$
CREATE PROCEDURE sp_obtener_rol(_id_rol int) 

BEGIN   
        -- exit if the duplicate key occurs
 DECLARE EXIT HANDLER FOR 1062 SELECT false as exito,"0" as id, "Error al realizar la consulta"  message; 
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,"0" as id,@text message; 
  END;
 
 SELECT CONVERT(id,CHAR) as id,nombre,descripcion FROM tbl_rol  WHERE id=_id_rol AND deletedAt IS NULL;

END 
$$
-- ejecutar
-- CALL sp_obtener_rol (2)




-- SELECT listar roles
DROP PROCEDURE IF EXISTS sp_listar_roles;

DELIMITER $$
CREATE PROCEDURE sp_listar_roles(
  _columna varchar(250),
  _nombre varchar(250),
  _offset int,
  _limit int,
  _sort VARCHAR(100))
BEGIN

 DECLARE _selectQuery varchar(3000);
 DECLARE _auxQuery varchar(300);
 DECLARE _orderBy varchar(300);
 DECLARE _pagination varchar(300);

     -- exit if the duplicate key occurs
 DECLARE EXIT HANDLER FOR 1062 SELECT false as exito, "Error al realizar la consulta"  message; 
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,@text message; 
  END;
   
  IF _nombre IS NOT NULL AND CHAR_LENGTH(TRIM(_nombre)) > 0 AND _columna IS NOT NULL AND CHAR_LENGTH(TRIM(_columna)) > 0 then
   SET _auxQuery = CONCAT("AND ",TRIM(_columna)," like '%",TRIM(_nombre),"%'");
  else
   SET _auxQuery = " ";
  end IF;

  IF _sort IS NOT NULL AND CHAR_LENGTH(TRIM(_sort))> 0 then
   SET _orderBy = CONCAT("order by ",TRIM(_sort));
  else
   SET _orderBy = " ORDER BY id ASC";
  end IF;
  IF _limit IS NOT NULL AND _limit > 0 then
   SET _pagination = CONCAT(" LIMIT ",_limit," OFFSET ",_offset);
  else
   SET _pagination = " ";
  end IF;

 SET _selectQuery = CONCAT("SELECT CONVERT(id,CHAR) as id, nombre, descripcion FROM tbl_rol  WHERE deletedAt IS NULL ",
  _auxQuery,_orderBy,_pagination);

  PREPARE stmt1 FROM _selectQuery; 
  EXECUTE stmt1; 
  DEALLOCATE PREPARE stmt1; 

END
$$
-- ejecutar
-- CALL sp_listar_roles ('', '', 0, 4, null);




-- DELETE rol
-- DROP PROCEDURE IF EXISTS sp_eliminar_rol;

DELIMITER $$
CREATE PROCEDURE sp_eliminar_rol(_id_rol int,_deleteBy int) 

BEGIN   
DECLARE _nombre_rol VARCHAR(80);
        -- exit if the duplicate key occurs
 DECLARE EXIT HANDLER FOR 1062 SELECT false as exito,"0" as id,  "Error al realizar la consulta"  message; 
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,@text message; 
  END;

   
   IF (SELECT deletedAt FROM tbl_rol WHERE id=_id_rol) IS NULL AND EXISTS(SELECT * FROM tbl_rol WHERE id=_id_rol) THEN
   SET _nombre_rol =(SELECT nombre FROM tbl_rol WHERE id=_id_rol);
    IF ( SELECT COUNT(id)  FROM tbl_usuario_rol WHERE deletedAt IS NULL AND id_rol=_id_rol) =0 THEN

 UPDATE tbl_rol set deletedAt = NOW(), deletedBy=_deleteBy where id= _id_rol;
 SELECT true as exito,CONVERT(_id_rol,CHAR) as id, 'Registro eliminado correctamente' as message;
 else
 SELECT false as exito,"0" as id, CONCAT('No puede eliminar el rol: ',_nombre_rol,' debido a que existen usuarios activos con este tipo de rol.') as message;
 end IF;
 else
  SELECT false as exito,"0" as id, 'El registro que desea eliminar no existe' as message;
 end IF;

END 
$$


-- ejecutar
-- CALL sp_eliminar_rol (2,4)




