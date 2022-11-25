CREATE TABLE tbl_chat_usuario(
  id                 INT NOT NULL AUTO_INCREMENT UNIQUE,
  usuario_created    INT NOT NULL,
  usuario_interacted INT NOT NULL,
  id_chat            INT NOT NULL,
  createdBy          INT,
  updatedBy          INT,
  deletedBy          INT,
  createdAt          TIMESTAMP NULL DEFAULT NULL,
  updatedAt          TIMESTAMP NULL DEFAULT NULL,
  deletedAt          TIMESTAMP NULL DEFAULT NULL,
  CONSTRAINT pk_tbl_chat_usuario PRIMARY KEY (id)
);

-- ALTER TABLE chat
ALTER TABLE tbl_chat_usuario
ADD CONSTRAINT fk_tbl_chat_usuario_tbl_chat FOREIGN KEY(id_chat)
	REFERENCES tbl_chat(id)
	ON UPDATE restrict
	ON DELETE restrict;

  ALTER TABLE tbl_chat_usuario
ADD CONSTRAINT fk_tbl_chat_usuario_tbl_usuario_rol_created FOREIGN KEY(createdBy)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;

ALTER TABLE tbl_chat_usuario
ADD CONSTRAINT fk_tbl_chat_usuario_tbl_usuario_rol_updated FOREIGN KEY(updatedBy)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;

ALTER TABLE tbl_chat_usuario
ADD CONSTRAINT fk_tbl_chat_usuario_tbl_usuario_rol_deleted FOREIGN KEY(deletedBy)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;


ALTER TABLE tbl_chat_usuario
ADD CONSTRAINT fk_tbl_chat_usuario_tbl_usuario_created FOREIGN KEY(usuario_created)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;


ALTER TABLE tbl_chat_usuario
ADD CONSTRAINT fk_tbl_chat_usuario_tbl_usuario_interacted FOREIGN KEY(usuario_interacted)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;






-- INSERT chat_usuario
-- DROP PROCEDURE IF EXISTS sp_crear_chat_usuario;

DELIMITER $$
CREATE PROCEDURE sp_crear_chat_usuario(_id_usuario_created INT,_id_usuario_interacted INT,_createdBy INT)

BEGIN
 DECLARE _id_chat VARCHAR(10);
   -- exit if the duplicate key occurs
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,@text message; 
  END;

 IF EXISTS(SELECT * FROM tbl_chat_usuario WHERE usuario_created=_id_usuario_created  AND usuario_interacted=_id_usuario_interacted) THEN
   SELECT CONVERT(id_chat,CHAR)  as id_chat FROM tbl_chat_usuario WHERE usuario_created=_id_usuario_created AND usuario_interacted=_id_usuario_interacted;
   else

   IF EXISTS(SELECT * FROM tbl_chat_usuario WHERE usuario_created=_id_usuario_interacted  AND usuario_interacted=_id_usuario_created )THEN
   SELECT CONVERT(id_chat,CHAR)  as id_chat FROM tbl_chat_usuario WHERE usuario_created=_id_usuario_interacted AND usuario_interacted=_id_usuario_created;
else
    INSERT INTO
     tbl_chat(
      tipo,
      createdBy,
      createdAt)
      VALUES(
      'privado',
      _createdBy,
      NOW());
    set _id_chat   = LAST_INSERT_ID();
    INSERT INTO tbl_chat_usuario (usuario_created,usuario_interacted, id_chat, createdAt,createdBy) VALUES (_id_usuario_created,_id_usuario_interacted, _id_chat,NOW(),_createdBy);
    SELECT _id_chat as chat;
end if;
end if;
 END
$$

-- SELECT IF ((SELECT id_chat FROM tbl_chat_usuario WHERE id=76)=(SELECT id_chat FROM tbl_chat_usuario WHERE id=95), 'true', 'false') as valido
-- ejecutar
-- CALL sp_crear_chat_usuario (76,95)


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
   SET _orderBy = " ORDER BY createdAt ASC";
  end IF;
  IF _limit IS NOT NULL AND _limit > 0 then
   SET _pagination = CONCAT(" LIMIT ",_limit," OFFSET ",_offset);
  else
   SET _pagination = " ";
  end IF;

 SET _selectQuery = CONCAT("SELECT CONVERT(id,CHAR) as id, CONVERT(id_usuario,CHAR) as id_usuario, inicio, fin  FROM tbl_session  WHERE deletedAt IS NULL "," AND id_usuario = ",_id_usuario,
  _auxQuery,_orderBy,_pagination);

  PREPARE stmt1 FROM _selectQuery; 
  EXECUTE stmt1; 
  DEALLOCATE PREPARE stmt1; 

END
$$
-- ejecutar
-- CALL sp_listar_sessiones_usuario (1,'', '', 0, 4, null);




SELECT * from tbl_message WHERE id_session = 95
-- SELECT * FROM `tbl_message` WHERE id_session = 26
-- SELECT * from tbl_session WHERE id_usuario = 1
-- (SELECT id from tbl_session WHERE id_usuario=14  ORDER by createdAt desc limit 1)






-- OBTENER chats_usuario
-- DROP PROCEDURE IF EXISTS sp_obtener_chats_usuario;

DELIMITER $$
CREATE PROCEDURE sp_obtener_chats_usuario(_id_session int) 

BEGIN   
        -- exit if the duplicate key occurs
 DECLARE EXIT HANDLER FOR 1062 SELECT false as exito,0 as id, "Error al realizar la consulta"  message; 
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,0 as id,@text message; 
  END;
 
 SELECT CONVERT(id,CHAR) as id,CONVERT(id_usuario,CHAR) as  id_usuario, CONVERT(id_chat,CHAR) as id_chat, contenido, CONVERT(id_session,CHAR) as id_session, CONVERT(answerBy,CHAR) as answerBy,createdAt FROM tbl_message  WHERE id_session=_id_session;

END 
$$
-- ejecutar
-- CALL sp_obtener_chats_usuario (2)


