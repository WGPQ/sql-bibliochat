CREATE TABLE tbl_intencion(
  id           INT NOT NULL AUTO_INCREMENT UNIQUE,
	nombre       VARCHAR(80) NOT NULL,
	descripcion  VARCHAR(100) NOT NULL,
  createdBy    INT,
  updatedBy    INT,
  deletedBy    INT,
  createdAt    TIMESTAMP NULL DEFAULT NULL,
  updatedAt    TIMESTAMP NULL DEFAULT NULL,
  deletedAt    TIMESTAMP NULL DEFAULT NULL,
  CONSTRAINT pk_tbl_intencion PRIMARY KEY (id)
);



ALTER TABLE tbl_intencion
ADD CONSTRAINT fk_tbl_intencion_tbl_usuario_rol_created FOREIGN KEY(createdBy)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;

ALTER TABLE tbl_intencion
ADD CONSTRAINT fk_tbl_intencion_tbl_usuario_rol_updated FOREIGN KEY(updatedBy)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;

ALTER TABLE tbl_intencion
ADD CONSTRAINT fk_tbl_intencion_tbl_usuario_rol_deleted FOREIGN KEY(deletedBy)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;






-- INSERT intencion
-- DROP PROCEDURE IF EXISTS sp_insertar_intencion;

DELIMITER $$
CREATE PROCEDURE sp_insertar_intencion (_nombre VARCHAR(60),_descripcion VARCHAR(80),_createdBy INT)

BEGIN
    DECLARE  _id_intencion int;
    -- exit if the duplicate key occurs
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,0 as id,@text message; 
  END;

      IF (SELECT COUNT(id)  FROM tbl_intencion WHERE deletedAt IS NULL AND nombre=_nombre) =0 THEN
  INSERT INTO tbl_intencion
        (nombre,
        descripcion,
        createdBy,
        createdAt)
     VALUES
      (_nombre,
      _descripcion,
      _createdBy,
         NOW());
    
      set _id_intencion   = LAST_INSERT_ID();
      
   SELECT true as exito, _id_intencion as id, 'Intencion insertada correctamente' as message; 
else
SELECT false as exito, 0 as id,CONCAT("Ya existe una intencion registrado con el nombre: ",_nombre)  message; 
end IF;
 END
$$

--- ejecutar
-- CALL sp_insertar_intencion ('Saludar','001','Intencion para saludar al usuario',4);




-- ACTUALIZAR intencion
-- DROP PROCEDURE IF EXISTS sp_actualizar_intencion;

DELIMITER $$
CREATE PROCEDURE sp_actualizar_intencion (_id_intencion INT,_nombre VARCHAR(80),_descripcion VARCHAR(200),_updatedBy INT)

BEGIN
    -- exit if the duplicate key occurs
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,@text message; 
  END;

  IF (SELECT deletedAt FROM tbl_intencion WHERE id=_id_intencion) IS NULL AND EXISTS(SELECT * FROM tbl_intencion WHERE id=_id_intencion) THEN
        IF (SELECT COUNT(id)  FROM tbl_intencion WHERE deletedAt IS NULL AND nombre=_nombre AND id !=_id_intencion) =0 THEN
  UPDATE tbl_intencion SET
        nombre=_nombre,
        descripcion=_descripcion,
        updatedBy=_updatedBy,
        updatedAt=NOW()
     WHERE 
     id=_id_intencion;

   SELECT true as exito, 'Registro actualizado correctamente' as message; 
   else
SELECT false as exito,CONCAT("Ya existe una intencion registrado con el nombre: ",_nombre)  message; 
end IF;
  else
   SELECT false as exito, 'El registro que desea actualizar no existe' as message; 
  end IF;

 END
$$

--- ejecutar
-- CALL sp_actualizar_intencion (1,'William','001','Puma');




-- OBTENER intencion
-- DROP PROCEDURE IF EXISTS sp_obtener_intencion;

DELIMITER $$
CREATE PROCEDURE sp_obtener_intencion(_id_intencion int) 

BEGIN   
        -- exit if the duplicate key occurs
 DECLARE EXIT HANDLER FOR 1062 SELECT false as exito,0 as id, "Error al realizar la consulta"  message; 
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito, 0 as id,@text message; 
  END;
 SELECT CONVERT(id,CHAR) as id,nombre,descripcion FROM tbl_intencion  WHERE id=_id_intencion AND deletedAt IS NULL;

END 
$$

-- ejecutar
-- CALL sp_obtener_intencion (2);





-- SELECT listar intenciones
-- DROP PROCEDURE IF EXISTS sp_listar_intenciones;

DELIMITER $$
CREATE PROCEDURE sp_listar_intenciones(
  _columna varchar(250),
  _nombre varchar(250),
  _offset int,
  _limit int,
  _sort VARCHAR(100))
BEGIN

 DECLARE _selectQuery varchar(3000);
 DECLARE _auxQuery varchar(300);
 DECLARE _orderBy varchar(300);

     -- exit if the duplicate key occurs
 DECLARE EXIT HANDLER FOR 1062 SELECT false as exito,0 as id, "Error al realizar la consulta"  message; 
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,0 as id,@text message; 
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

 SET _selectQuery = CONCAT("SELECT CONVERT(id,CHAR) as id, nombre, descripcion FROM tbl_intencion  WHERE deletedAt IS NULL ",
  _auxQuery,_orderBy," LIMIT ",_limit," OFFSET ",_offset);

  PREPARE stmt1 FROM _selectQuery; 
  EXECUTE stmt1; 
  DEALLOCATE PREPARE stmt1; 

END
$$

-- ejecutar
-- CALL sp_listar_intenciones ('', '', 0, 4, null);





-- ELIMINAR intencion
-- DROP PROCEDURE IF EXISTS sp_eliminar_intencion;

DELIMITER $$
CREATE PROCEDURE sp_eliminar_intencion(_id_intencion int,_deletedBy INT) 

BEGIN   
DECLARE _nombre_intencion VARCHAR(80);
        -- exit if the duplicate key occurs
 DECLARE EXIT HANDLER FOR 1062 SELECT false as exito, "Error al realizar la consulta"  message; 

 DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,@text message; 
  END;
IF (SELECT deletedAt FROM tbl_intencion WHERE id=_id_intencion) IS NULL AND EXISTS(SELECT * FROM tbl_intencion WHERE id=_id_intencion) THEN
   SET _nombre_intencion = (SELECT nombre FROM tbl_intencion WHERE id=_id_intencion);
    IF ( SELECT COUNT(id_intencion)  FROM tbl_frace_intencion WHERE deletedAt IS NULL AND id_intencion=_id_intencion) =0 THEN

     UPDATE tbl_intencion set deletedAt = NOW(),deletedBy=_deletedBy where id= _id_intencion;
     SELECT true as exito, _id_intencion as id, 'Registro eliminado correctamente' as message;

  else
 SELECT false as exito, CONCAT('No puede eliminar la intencion: ',_nombre_intencion,' debido a que existen faces con este tipo de intencion.') as message;
 end IF;
 else
  SELECT false as exito, 'El registro que desea eliminar no existe' as message;
 end IF;

END 
$$

-- ejecutar
-- CALL sp_eliminar_intencion (2,4);

