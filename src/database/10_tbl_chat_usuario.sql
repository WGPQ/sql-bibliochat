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


-- OBTENER chatsultimo_chat_usuario
-- DROP PROCEDURE IF EXISTS sp_obtener_ultimo_chat_usuario;

DELIMITER $$
CREATE PROCEDURE sp_obtener_ultimo_chat_usuario(_id_usuario int) 

BEGIN   
 DECLARE _id_session VARCHAR(10);
        -- exit if the duplicate key occurs
 DECLARE EXIT HANDLER FOR 1062 SELECT false as exito,0 as id, "Error al realizar la consulta"  message; 
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,0 as id,@text message; 
  END;
 SET _id_session = (SELECT CONVERT(id,CHAR) as id FROM tbl_session WHERE deletedAt IS NULL AND id_usuario = _id_usuario AND inicio=(SELECT MAX(inicio) from tbl_session WHERE id_usuario = _id_usuario)  LIMIT 1);

 SELECT CONVERT(id,CHAR) as id,CONVERT(id_usuario,CHAR) as  id_usuario, CONVERT(id_chat,CHAR) as id_chat, contenido, CONVERT(id_session,CHAR) as id_session, CONVERT(answerBy,CHAR) as answerBy,createdAt FROM tbl_message  WHERE id_session=_id_session;

END 
$$
-- ejecutar
-- CALL sp_obtener_ultimo_chat_usuario (8)


