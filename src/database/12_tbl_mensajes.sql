

CREATE TABLE tbl_message(
    id         INT NOT NULL AUTO_INCREMENT UNIQUE,
    id_usuario INT NOT NULL,
    id_chat    INT NOT NULL,
    contenido  VARCHAR(800) NOT NULL,
    id_session INT,
    answereBy  INT,
    createdBy  INT,
    updatedBy  INT,
    deletedBy  INT,        
    createdAt  TIMESTAMP NULL DEFAULT NULL,
    updatedAt  TIMESTAMP NULL DEFAULT NULL,
    deletedAt  TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT pk_tbl_message PRIMARY KEY (id)
);


-- ALTER TABLE message
ALTER TABLE tbl_message
ADD CONSTRAINT fk_tbl_message_tbl_chat FOREIGN KEY(id_chat)
	REFERENCES tbl_chat(id)
	ON UPDATE restrict
	ON DELETE restrict;
  
  ALTER TABLE tbl_chat_usuario
ADD CONSTRAINT fk_tbl_message_tbl_usuario_rol_created FOREIGN KEY(createdBy)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;

ALTER TABLE tbl_chat_usuario
ADD CONSTRAINT fk_tbl_message_tbl_usuario_rol_updated FOREIGN KEY(updatedBy)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;

ALTER TABLE tbl_chat_usuario
ADD CONSTRAINT fk_tbl_message_tbl_usuario_rol_deleted FOREIGN KEY(deletedBy)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;


ALTER TABLE tbl_message
ADD CONSTRAINT fk_tbl_message_tbl_answereBy_tbl_usuario_rol FOREIGN KEY(answereBy)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;

ALTER TABLE tbl_message
ADD CONSTRAINT fk_tbl_message_tbl_usuario_rol FOREIGN KEY(id_usuario)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;

ALTER TABLE tbl_message
ADD CONSTRAINT fk_tbl_message_tbl_session FOREIGN KEY(id_session)
	REFERENCES tbl_session(id)
	ON UPDATE restrict
	ON DELETE restrict;




-- INSERT mensaje
-- DROP PROCEDURE IF EXISTS sp_crear_mensaje;

DELIMITER $$
CREATE PROCEDURE sp_crear_mensaje(_id_usuario_rol INT,_id_chat INT,_contenido VARCHAR(800),_answerBy INT,_id_session INT,_createdBy INT)

BEGIN
DECLARE _id_message VARCHAR(10);

 DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito, "0" as id, @text message; 
  END;
 IF EXISTS (SELECT * FROM tbl_chat WHERE id=_id_chat AND deletedAt IS NULL) THEN
   INSERT INTO
     tbl_message(
      id_usuario,
      id_chat,
      contenido,
      answerBy,
      id_session,
      createdBy,
      createdAt)
      VALUES(
        _id_usuario_rol,
        _id_chat,
        _contenido,
        _answerBy,
        _id_session,
        _createdBy,
      NOW());
       set _id_message   = LAST_INSERT_ID();
      SELECT true as exito ,CONVERT(_id_message,CHAR) as id ,CONCAT('Mensaje guardado correctamente -',CONVERT(_id_message,CHAR)) as message; 
else
SELECT false as exito,"0" as id,'No existe chat' as message; 
end if;

 END
$$

-- ejecutar
-- CALL sp_crear_mensaje (4,2,'Hola Carlos como estas',2,28,4)





-- SELECT listar usuarios
-- DROP PROCEDURE IF EXISTS sp_listar_mensajes;

DELIMITER $$
CREATE PROCEDURE sp_listar_mensajes(
  _id_chat int,
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
 DECLARE EXIT HANDLER FOR 1062 SELECT false as exito,"Error al realizar la consulta"  message; 
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,@text message; 
  END;   
  IF _nombre IS NOT NULL AND CHAR_LENGTH(TRIM(_nombre)) > 0 AND _columna IS NOT NULL AND CHAR_LENGTH(TRIM(_columna)) > 0 then
   SET _auxQuery = CONCAT(" AND ",TRIM(_columna)," like '%",TRIM(_nombre),"%'");
  else
   SET _auxQuery = " ";
  end IF;

  IF _sort IS NOT NULL AND CHAR_LENGTH(TRIM(_sort))> 0 then
   SET _orderBy = CONCAT("order by ",TRIM(_sort));
  else
   SET _orderBy = " ORDER BY id ASC";
  end IF;

 SET _selectQuery = CONCAT("SELECT CONVERT(id,CHAR) as id, CONVERT(id_chat,CHAR) as id_chat, CONVERT(id_usuario,CHAR) as id_usuario, contenido,CONVERT(id_session,CHAR) as id_session ,CONVERT(answerBy,CHAR) as answerBy,createdAt FROM tbl_message  WHERE deletedAt IS NULL AND id_chat=",_id_chat,
  _auxQuery,_orderBy," LIMIT ",_limit," OFFSET ",_offset);

  PREPARE stmt1 FROM _selectQuery; 
  EXECUTE stmt1; 
  DEALLOCATE PREPARE stmt1; 

END
$$

-- ejecutar
-- CALL sp_listar_mensajes (2, '', '', 0, 14, null)





-- SELECT obtener ultimo chat
-- DROP PROCEDURE IF EXISTS sp_obtener_ultimo_mensaje;

DELIMITER $$
CREATE PROCEDURE sp_obtener_ultimo_mensaje(_id_chat int)
BEGIN

     -- exit if the duplicate key occurs
 DECLARE EXIT HANDLER FOR 1062 SELECT false as exito,"Error al realizar la consulta"  message; 
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,@text message; 
  END;
SELECT CONVERT(id,CHAR) as id, CONVERT(id_chat,CHAR) as id_chat, CONVERT(id_usuario,CHAR) as id_usuario, contenido,CONVERT(id_session,CHAR) as id_session ,CONVERT(answerBy,CHAR) as answerBy,createdAt FROM tbl_message  WHERE deletedAt IS NULL AND id_chat=_id_chat;


END
$$

-- ejecutar
-- CALL sp_mensajes_nuevos (19);

