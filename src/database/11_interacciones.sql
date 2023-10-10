

-- SELECT listar usuarios
-- DROP PROCEDURE IF EXISTS sp_listar_interacciones;

DELIMITER $$
CREATE PROCEDURE sp_listar_interacciones(
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

     -- exit if the duplicate key occurs
  DECLARE sql_exception INT DEFAULT 0;     
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_exception = 1;

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

 SET @sql = CONCAT("SELECT CONVERT(id,CHAR) as id, CONVERT(id_chat,CHAR) as chat, CONVERT(usuario_created,CHAR) as usuario_created,CONVERT(usuario_interacted,CHAR) as usuario_interacted  FROM tbl_chat_usuario  WHERE deletedAt IS NULL AND usuario_created=",_id_usuario," OR usuario_interacted=",_id_usuario,
  _auxQuery,_orderBy," LIMIT ",_limit," OFFSET ",_offset);

  PREPARE stmt1 FROM @sql; 
  EXECUTE stmt1; 
  DEALLOCATE PREPARE stmt1; 

END
$$

-- ejecutar
-- CALL sp_listar_interacciones (76, '', '', 0, 14, null);
