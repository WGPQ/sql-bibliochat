CREATE TABLE tbl_chat(
  id         INT NOT NULL AUTO_INCREMENT UNIQUE,
  tipo       VARCHAR(20),
  createdBy    INT,
  updatedBy    INT,
  deletedBy    INT,
  createdAt  TIMESTAMP NULL DEFAULT NULL,
  updatedAt  TIMESTAMP NULL DEFAULT NULL,
  deletedAt  TIMESTAMP NULL DEFAULT NULL,
  CONSTRAINT pk_tbl_chat PRIMARY KEY (id)
);

-- SELECT obtener ultimo chat
-- DROP PROCEDURE IF EXISTS sp_obtener_conversacion;

DELIMITER $$
CREATE PROCEDURE sp_obtener_conversacion(_id_chat int)
BEGIN

     -- exit if the duplicate key occurs
 DECLARE EXIT HANDLER FOR 1062 SELECT false as exito,"Error al realizar la consulta"  message; 
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,@text message; 
  END;
SELECT  CONVERT(id,CHAR) as id,CONVERT(id_usuario,CHAR) as usuario,CONVERT(id_chat,CHAR) as chat, contenido, visto,createdAt FROM tbl_message WHERE id_chat=_id_chat AND createdAt= (SELECT MAX(createdAt) FROM tbl_message WHERE id_chat=_id_chat) AND deletedAt IS NULL;


END
$$

-- ejecutar
-- CALL sp_obtener_conversacion (19);
