
CREATE TABLE tbl_session(
    id                INT NOT NULL AUTO_INCREMENT UNIQUE,
    id_usuario        INT NOT NULL,
    inicio            TIMESTAMP NULL DEFAULT NULL,
    fin               TIMESTAMP NULL DEFAULT NULL,
    token             VARCHAR(200),
    calificacion      INT,
    createdBy         INT,
    updatedBy         INT,
    deletedBy         INT,
    createdAt         TIMESTAMP NULL DEFAULT NULL,
    updatedAt         TIMESTAMP NULL DEFAULT NULL,
    deletedAt         TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT pk_tbl_session PRIMARY KEY (id)
);

ALTER TABLE tbl_session
ADD CONSTRAINT fk_tbl_session_tbl_usuario_rol FOREIGN KEY(id_usuario)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;

ALTER TABLE tbl_session
ADD CONSTRAINT fk_tbl_session_tbl_usuario_rol_create FOREIGN KEY(updatedBy)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;

    ALTER TABLE tbl_session
ADD CONSTRAINT fk_tbl_session_tbl_usuario_rol_updated FOREIGN KEY(updatedBy)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;

ALTER TABLE tbl_session
ADD CONSTRAINT fk_tbl_session_tbl_usuario_rol_deleted FOREIGN KEY(deletedBy)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;




    


-- INSERT session
-- DROP PROCEDURE IF EXISTS sp_insertar_session;

DELIMITER $$
CREATE PROCEDURE sp_insertar_session (_id_usuario int,_token VARCHAR(200),_createBy int)

BEGIN

    DECLARE  _id_session int;
    -- exit if the duplicate key occurs
    DECLARE duplicate_key INT DEFAULT 0;     
  DECLARE sql_exception INT DEFAULT 0;     
  DECLARE CONTINUE HANDLER FOR 1062 SET duplicate_key = 1;     
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_exception = 1; 
  INSERT INTO tbl_session
        (id_usuario,
        inicio,
        token,
        createdBy,
        createdAt)
     VALUES
      ( _id_usuario,
        NOW(),
        _token,
       _createBy,
         NOW()); 

    set _id_session   = LAST_INSERT_ID();          
   SELECT true as exito, "0" as id, CONCAT('Session insertada correctamente ',_id_session) as message; 


 END
$$

--- ejecutar
-- CALL sp_insertar_session (1,'jdjksjd',1)




-- ACTUALIZAR session
-- DROP PROCEDURE IF EXISTS sp_actualizar_session;

DELIMITER $$
CREATE PROCEDURE sp_actualizar_session (_id_session int,_id_usuario int,_updateBy int)

BEGIN
    -- exit if the duplicate key occurs
     DECLARE duplicate_key INT DEFAULT 0;     
  DECLARE sql_exception INT DEFAULT 0;     
  DECLARE CONTINUE HANDLER FOR 1062 SET duplicate_key = 1;     
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_exception = 1; 

  UPDATE tbl_session SET
        id_usuario=_id_usuario,
        fin=NOW(),
        updatedBy=_updateBy,
        updatedAt=NOW()
     WHERE 
     id=_id_session;
      
   SELECT true as exito,"0" as id,'Session actualizada correctamente' as message; 

 END
$$


-- CALIFICAR session
-- DROP PROCEDURE IF EXISTS sp_calificar_session;

DELIMITER $$
CREATE PROCEDURE sp_calificar_session (_id_session int, _calificacion int,_updateBy int)

BEGIN
    -- exit if the duplicate key occurs
     DECLARE duplicate_key INT DEFAULT 0;     
  DECLARE sql_exception INT DEFAULT 0;     
  DECLARE CONTINUE HANDLER FOR 1062 SET duplicate_key = 1;     
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_exception = 1; 

  UPDATE tbl_session SET
        calificacion=_calificacion,
        fin=NOW(),
        updatedAt=NOW()
     WHERE 
     id=_id_session;
      
   SELECT true as exito,"0" as id,'Session calificada correctamente' as message; 

 END
$$





--- ejecutar
-- CALL sp_calificar_session (728,1,1)



-- OBTENER rol
-- DROP PROCEDURE IF EXISTS sp_obtener_session;

DELIMITER $$
CREATE PROCEDURE sp_obtener_session(_id_session int) 

BEGIN   
        -- exit if the duplicate key occurs
    DECLARE sql_exception INT DEFAULT 0;     
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_exception = 1;
 
 SELECT * FROM tbl_session  WHERE id=_id_session;

END 
$$
-- ejecutar
-- CALL sp_obtener_session (1)


-- OBTENER rol
-- DROP PROCEDURE IF EXISTS sp_obtener_last_session;

DELIMITER $$
CREATE PROCEDURE sp_obtener_last_session(_id_usuario int) 

BEGIN   
        -- exit if the duplicate key occurs
    DECLARE sql_exception INT DEFAULT 0;     
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_exception = 1;
 
  SELECT CONVERT(id,CHAR) as id, CONVERT(id_usuario,CHAR) as id_usuario, calificacion , inicio, fin  FROM tbl_session  WHERE deletedAt IS NULL AND createdAt= (SELECT MAX(createdAt) FROM tbl_session WHERE id_usuario=_id_usuario);
END 
$$
-- ejecutar
-- CALL sp_obtener_last_session (1)




-- SELECT listar roles
-- DROP PROCEDURE IF EXISTS sp_listar_sessiones;

DELIMITER $$
CREATE PROCEDURE sp_listar_sessiones(
  _id_usuario int,
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
 DECLARE _byUser varchar(100);

     -- exit if the duplicate key occurs
   DECLARE sql_exception INT DEFAULT 0;     
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_exception = 1;
   
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
  IF _id_usuario IS NOT NULL AND _id_usuario > 0 then
   SET _byUser = CONCAT(" WHERE id_usuario= ",_id_usuario);
  else
   SET _byUser = "";
  end IF;


 SET @sql = CONCAT("SELECT * FROM tbl_session ",_byUser,
  _auxQuery,_orderBy,_pagination);

  PREPARE stmt1 FROM @sql; 
  EXECUTE stmt1; 
  DEALLOCATE PREPARE stmt1; 

END
$$
-- ejecutar
-- CALL sp_listar_sessiones (1,'', '', 0, 4, null);



-- listar chat_usuario
-- DROP PROCEDURE IF EXISTS sp_listar_sessiones_usuario;

DELIMITER $$
CREATE PROCEDURE sp_listar_sessiones_usuario(
  _id_usuario int,
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
 DECLARE _byUser varchar(100);

     -- exit if the duplicate key occurs
    DECLARE sql_exception INT DEFAULT 0;     
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_exception = 1;
   
  IF _nombre IS NOT NULL AND CHAR_LENGTH(TRIM(_nombre)) > 0 AND _columna IS NOT NULL AND CHAR_LENGTH(TRIM(_columna)) > 0 then
   SET _auxQuery = CONCAT("AND ",TRIM(_columna)," like '%",TRIM(_nombre),"%'");
  else
   SET _auxQuery = " ";
  end IF;

  IF _sort IS NOT NULL AND CHAR_LENGTH(TRIM(_sort))> 0 then
   SET _orderBy = CONCAT("order by ",TRIM(_sort));
  else
   SET _orderBy = " ORDER BY createdAt ASC";
  end IF;
  IF _limit IS NOT NULL AND _limit > 0 then
   SET _pagination = CONCAT(" LIMIT ",_limit," OFFSET ",_offset);
  else
   SET _pagination = " ";
  end IF;

  IF _id_usuario IS NOT NULL AND _id_usuario > 0 then
   SET _byUser = CONCAT(" AND id_usuario = ",_id_usuario);
  else
   SET _byUser = " ";
  end IF;

 SET @sql = CONCAT("SELECT CONVERT(id,CHAR) as id, CONVERT(id_usuario,CHAR) as id_usuario, calificacion , inicio, fin  FROM tbl_session  WHERE deletedAt IS NULL",_byUser,
  _auxQuery,_orderBy,_pagination);

  PREPARE stmt1 FROM @sql; 
  EXECUTE stmt1; 
  DEALLOCATE PREPARE stmt1; 

END
$$
-- ejecutar
-- CALL sp_listar_sessiones_usuario (1,'', '', 0, 4, null);



