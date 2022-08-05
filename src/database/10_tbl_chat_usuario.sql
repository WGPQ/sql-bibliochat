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
	REFERENCES tbl_cliente(id)
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
   SELECT CONVERT(id_chat,CHAR)  as chat FROM tbl_chat_usuario WHERE usuario_created=_id_usuario_created AND usuario_interacted=_id_usuario_interacted;
   else

   IF EXISTS(SELECT * FROM tbl_chat_usuario WHERE usuario_created=_id_usuario_interacted  AND usuario_interacted=_id_usuario_created )THEN
   SELECT CONVERT(id_chat,CHAR)  as chat FROM tbl_chat_usuario WHERE usuario_created=_id_usuario_interacted AND usuario_interacted=_id_usuario_created;
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

