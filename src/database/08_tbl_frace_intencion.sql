
CREATE TABLE tbl_frace_intencion(
  id           INT NOT NULL AUTO_INCREMENT UNIQUE,
  id_intencion INT NOT NULL,
	frace        VARCHAR(200) CHARSET utf8mb4 NOT NULL,
  activo       BOOLEAN NOT NULL,
  createdBy    INT,
  updatedBy    INT,
  deletedBy    INT,
  createdAt    TIMESTAMP NULL DEFAULT NULL,
  updatedAt    TIMESTAMP NULL DEFAULT NULL,
  deletedAt    TIMESTAMP NULL DEFAULT NULL,
  CONSTRAINT pk_fraces_intencion PRIMARY KEY (id)
);


-- TABLE frace_intencion
ALTER TABLE tbl_frace_intencion
ADD CONSTRAINT fk_tbl_frace_intencion_tbl_intencion FOREIGN KEY(id_intencion)
	REFERENCES tbl_intencion(id)
	ON UPDATE restrict
	ON DELETE restrict;

ALTER TABLE tbl_frace_intencion
ADD CONSTRAINT fk_tbl_frace_intencion_tbl_usuario_rol_created FOREIGN KEY(createdBy)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;

ALTER TABLE tbl_frace_intencion
ADD CONSTRAINT fk_tbl_frace_intencionusuario_rol_updated FOREIGN KEY(updatedBy)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;

ALTER TABLE tbl_frace_intencion
ADD CONSTRAINT fk_tbl_frace_intenciontbl_usuario_rol_deleted FOREIGN KEY(deletedBy)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;


    




-- INSERT frace intencion
-- DROP PROCEDURE IF EXISTS sp_insertar_frace_intencion;

-- CAMBIAR A utf8mb4 _frace
DELIMITER $$
CREATE PROCEDURE sp_insertar_frace_intencion (_frace VARCHAR(200) CHARSET utf8mb4,_id_intencion INT,_createdBy INT)

BEGIN
   DECLARE  _id_frace int;
    -- exit if the duplicate key occurs
  DECLARE duplicate_key INT DEFAULT 0;     
  DECLARE sql_exception INT DEFAULT 0;     
  DECLARE CONTINUE HANDLER FOR 1062 SET duplicate_key = 1;     
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_exception = 1; 

 IF (SELECT deletedAt FROM tbl_intencion WHERE id=_id_intencion) IS NULL THEN
  INSERT INTO tbl_frace_intencion
        (frace,
        id_intencion,
        createdBy,
        activo,
        createdAt)
     VALUES
      (_frace,
      _id_intencion,
      _createdBy,
            1,
         NOW());
    
    set _id_frace   = LAST_INSERT_ID();
      
   SELECT true as exito, CONVERT(_id_frace,CHAR) as id,  'Registro insertado correctamente' as message; 
   else
  SELECT false as exito,"0" as id,  'Error la frace no puede ser asignada a una intencion que no existe' as message; 
   end IF;

 END
$$

--- ejecutar
-- CALL sp_insertar_frace_intencion ('Buenas noches como estas',1,7);




-- ACTUALIZAR intencion
-- DROP PROCEDURE IF EXISTS sp_actualizar_frace_intencion;

DELIMITER $$
CREATE PROCEDURE sp_actualizar_frace_intencion (_id_frace INT,_id_intencion INT,_frace VARCHAR(200) CHARSET utf8mb4,_activo BOOLEAN,_updatedBy INT)

BEGIN
    -- exit if the duplicate key occurs
   DECLARE duplicate_key INT DEFAULT 0; 
  DECLARE register_foud INT DEFAULT 0;     
  DECLARE sql_exception INT DEFAULT 0;     
  DECLARE CONTINUE HANDLER FOR 1062 SET duplicate_key = 1;     
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_exception = 1; 

   IF (SELECT deletedAt FROM tbl_frace_intencion WHERE id=_id_frace) IS NULL AND EXISTS(SELECT * FROM tbl_frace_intencion WHERE id=_id_frace) THEN
   IF (SELECT deletedAt FROM tbl_intencion WHERE id=_id_intencion) IS NULL AND EXISTS(SELECT * FROM tbl_intencion WHERE id=_id_intencion) THEN
  UPDATE tbl_frace_intencion SET
        id_intencion=_id_intencion,
        frace=_frace,
        activo=_activo,
        updatedBy=_updatedBy,
        updatedAt=NOW()
     WHERE 
     id=_id_frace;
        SELECT true as exito,CONVERT(_id_frace,CHAR) as id,'Registro actualizado correctamente' as message; 
 else
SELECT false as exito,"0" as id,'Error la frace no puede ser asignada a una intencion que no existe' as message; 
 end IF;
  else
   SELECT false as exito,"0" as id, 'El registro que desea actualizar no existe' as message; 
  end IF;

 END
$$

--- ejecutar
-- CALL sp_actualizar_frace_intencion (17,3,'Puma',1,1);





-- OBTENER intencion
-- DROP PROCEDURE IF EXISTS sp_obtener_frace_intencion;

DELIMITER $$
CREATE PROCEDURE sp_obtener_frace_intencion(_id_frace_intencion int) 

BEGIN   
        -- exit if the duplicate key occurs
 DECLARE sql_exception INT DEFAULT 0;     
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_exception = 1;
 SELECT CONVERT(id,CHAR) as id,CONVERT(id_intencion,CHAR) as intencion ,frace,activo FROM tbl_frace_intencion  WHERE id=_id_frace_intencion AND deletedAt IS NULL;

END 
$$

-- ejecutar
-- CALL sp_obtener_frace_intencion (2);





-- SELECT listar intenciones
-- DROP PROCEDURE IF EXISTS sp_listar_fraces_intencion;

DELIMITER $$
CREATE PROCEDURE sp_listar_fraces_intencion(
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
  DECLARE sql_exception INT DEFAULT 0;     
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_exception = 1;  

  IF _nombre IS NOT NULL AND CHAR_LENGTH(TRIM(_nombre)) > 0 AND _columna IS NOT NULL AND CHAR_LENGTH(TRIM(_columna)) > 0 then
   IF _columna="intencion" THEN
    SET _auxQuery=CONCAT(" AND ti.nombre like '%",TRIM(_nombre),"%'");
   else
   SET _auxQuery = CONCAT(" AND fi.",TRIM(_columna)," like '%",TRIM(_nombre),"%'");
   end IF;
  else
   SET _auxQuery = " ";
  end IF;

  IF _sort IS NOT NULL AND CHAR_LENGTH(TRIM(_sort))> 0 then
   SET _orderBy = CONCAT(" order by fi.",TRIM(_sort));
  else
   SET _orderBy = " ORDER BY fi.id ASC";
  end IF;
   IF _limit IS NOT NULL AND _limit > 0 then
   SET _pagination = CONCAT(" LIMIT ",_limit," OFFSET ",_offset);
  else
   SET _pagination = " ";
  end IF;

 SET @sql = CONCAT("SELECT CONVERT(fi.id,CHAR) as id,CONVERT(fi.id_intencion,CHAR) as intencion , fi.frace, fi.activo FROM  tbl_frace_intencion fi,tbl_intencion ti   WHERE fi.id_intencion=ti.id AND fi.deletedAt IS NULL",
  _auxQuery,_orderBy,_pagination);

  PREPARE stmt1 FROM @sql; 
  EXECUTE stmt1; 
  DEALLOCATE PREPARE stmt1; 

END
$$

-- ejecutar
-- CALL sp_listar_fraces_intencion ('', '', 0, 4, null);





-- ELIMINAR intencion
-- DROP PROCEDURE IF EXISTS sp_eliminar_frace_intencion;

DELIMITER $$
CREATE PROCEDURE sp_eliminar_frace_intencion(_id_frace_intencion int,_deletedBy INT) 

BEGIN   
        -- exit if the duplicate key occurs
 DECLARE _rowCount INT;

  IF (SELECT deletedAt FROM tbl_frace_intencion WHERE id=_id_frace_intencion) IS NULL AND EXISTS(SELECT * FROM tbl_frace_intencion WHERE id=_id_frace_intencion) THEN
 UPDATE tbl_frace_intencion set deletedAt = NOW(),deletedBy=_deletedBy where id= _id_frace_intencion;
 SELECT true as exito, CONVERT(_id_frace_intencion,CHAR) as id,'Registro eliminado correctamente' as message;

 else
  SELECT false as exito, "0" as id, 'El registro que desea eliminar no existe' as message;
 end IF;

END 
$$

-- ejecutar
-- CALL sp_eliminar_frace_intencion (4);







-- SELECT listar intenciones
-- DROP PROCEDURE IF EXISTS sp_frace_intencion_bot;

DELIMITER $$
CREATE PROCEDURE sp_frace_intencion_bot(_intencion varchar(100))
 
BEGIN   

        -- exit if the duplicate key occurs
  DECLARE sql_exception INT DEFAULT 0;     
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_exception = 1; 

  select CONVERT(fi.id,CHAR) as id,CONVERT(fi.id_intencion,CHAR) as intencion ,fi.frace,fi.activo from tbl_frace_intencion fi,tbl_intencion ti WHERE LOWER(ti.nombre)=LOWER(_intencion) AND ti.id=fi.id_intencion AND ti.deletedAt IS NULL AND fi.deletedAt IS NULL AND fi.activo=1  ORDER BY rand() LIMIT 1; 

END;
$$

-- ejecutar
-- CALL sp_frace_intencion_bot ("Despedirse");
