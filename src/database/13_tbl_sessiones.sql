
CREATE TABLE tbl_session(
    id                INT NOT NULL AUTO_INCREMENT UNIQUE,
    id_usuario        INT NOT NULL,
    inicio            TIMESTAMP NULL DEFAULT NULL,
    fin               TIMESTAMP NULL DEFAULT NULL,
    token             VARCHAR(200),
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
   DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,@text message; 
  END;
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
   SELECT true as exito, CONCAT('Session insertada correctamente ',_id_session) as message; 


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
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,@text message; 
  END;
  UPDATE tbl_session SET
        id_usuario=_id_usuario,
        fin=NOW(),
        updatedBy=_updateBy,
        updatedAt=NOW()
     WHERE 
     id=_id_session;
      
   SELECT true as exito,'Session actualizada correctamente' as message; 

 END
$$

--- ejecutar
-- CALL sp_actualizar_session (1,1,1)



-- OBTENER rol
-- DROP PROCEDURE IF EXISTS sp_obtener_session;

DELIMITER $$
CREATE PROCEDURE sp_obtener_session(_id_session int) 

BEGIN   
        -- exit if the duplicate key occurs
 DECLARE EXIT HANDLER FOR 1062 SELECT false as exito,0 as id, "Error al realizar la consulta"  message; 
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,0 as id,@text message; 
  END;
 
 SELECT * FROM tbl_session  WHERE id=_id_session;

END 
$$
-- ejecutar
-- CALL sp_obtener_session (1)




-- SELECT listar roles
DROP PROCEDURE IF EXISTS sp_listar_sessiones;

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
  IF _id_usuario IS NOT NULL AND _id_usuario > 0 then
   SET _byUser = CONCAT(" WHERE id_usuario= ",_id_usuario);
  else
   SET _byUser = " ";
  end IF;


 SET _selectQuery = CONCAT("SELECT * FROM tbl_session ",_byUser,
  _auxQuery,_orderBy,_pagination);

  PREPARE stmt1 FROM _selectQuery; 
  EXECUTE stmt1; 
  DEALLOCATE PREPARE stmt1; 

END
$$
-- ejecutar
-- CALL sp_listar_sessiones (1,'', '', 0, 4, null);










--NO IMPLEMENTADO AUN------------


-- DELETE rol
-- DROP PROCEDURE IF EXISTS sp_eliminar_rol;

DELIMITER $$
CREATE PROCEDURE sp_eliminar_rol(_id_rol int,_deleteBy int) 

BEGIN   
DECLARE _nombre_rol VARCHAR(80);
        -- exit if the duplicate key occurs
 DECLARE EXIT HANDLER FOR 1062 SELECT false as exito,  "Error al realizar la consulta"  message; 
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,@text message; 
  END;

   
   IF (SELECT deletedAt FROM tbl_rol WHERE id=_id_rol) IS NULL AND EXISTS(SELECT * FROM tbl_rol WHERE id=_id_rol) THEN
   SET _nombre_rol =(SELECT nombre FROM tbl_rol WHERE id=_id_rol);
    IF ( SELECT COUNT(id)  FROM tbl_usuario_rol WHERE deletedAt IS NULL AND id_rol=_id_rol) =0 THEN

 UPDATE tbl_rol set deletedAt = NOW(), deletedBy=_deleteBy where id= _id_rol;
 SELECT true as exito, 'Registro eliminado correctamente' as message;
 else
 SELECT false as exito, CONCAT('No puede eliminar el rol: ',_nombre_rol,' debido a que existen usuarios activos con este tipo de rol.') as message;
 end IF;
 else
  SELECT false as exito, 'El registro que desea eliminar no existe' as message;
 end IF;

END 
$$


-- ejecutar
-- CALL sp_eliminar_rol (2,4)
