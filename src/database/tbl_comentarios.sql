use bibliotecautn
-- TABLE tbl_comentario

CREATE TABLE tbl_comentario(
  id           INT NOT NULL AUTO_INCREMENT UNIQUE,
  contenido    VARCHAR(800),
  correo       VARCHAR(200),
  id_session   INT,
  createdAt    TIMESTAMP NULL DEFAULT NULL,
  updatedAt    TIMESTAMP NULL DEFAULT NULL,
  deletedAt    TIMESTAMP NULL DEFAULT NULL,
  CONSTRAINT pk_tbl_comentario PRIMARY KEY (id)
);


ALTER TABLE tbl_comentario
ADD CONSTRAINT fk_tbl_comentario_tbl_session FOREIGN KEY(id_session)
	REFERENCES tbl_session(id)
	ON UPDATE restrict
	ON DELETE restrict;



-- INSERT rol
-- DROP PROCEDURE IF EXISTS sp_insertar_comentario;

DELIMITER $$
CREATE PROCEDURE sp_insertar_comentario (_contenido VARCHAR(800),_correo VARCHAR(200),_id_session int)

BEGIN
    -- exit if the duplicate key occurs
  DECLARE _id_comentario VARCHAR(50);
  DECLARE duplicate_key INT DEFAULT 0;     
  DECLARE sql_exception INT DEFAULT 0;     
  DECLARE CONTINUE HANDLER FOR 1062 SET duplicate_key = 1;     
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_exception = 1; 
  
  INSERT INTO tbl_comentario
        (contenido,
        correo,
        id_session,
        createdAt)
     VALUES
      (_contenido,
      _correo,
      _id_session,
         NOW()); 
         set _id_comentario   = LAST_INSERT_ID();     
   SELECT true as exito, CONVERT(_id_comentario,CHAR) as id,'Comentado insertado correctamente' as message; 

 END
$$

--- ejecutar
-- CALL sp_insertar_comentario ("Me parece un buen servicio que chevere!!! ","dwilgeo95@gmail.com",1)



-- DROP PROCEDURE IF EXISTS sp_listar_comentarios;

DELIMITER $$
CREATE PROCEDURE sp_listar_comentarios(
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
   SET _auxQuery = CONCAT("AND ",TRIM(_columna)," like '%",TRIM(_nombre),"%'");
  else
   SET _auxQuery = " ";
  end IF;

  IF _sort IS NOT NULL AND CHAR_LENGTH(TRIM(_sort))> 0 then
   SET _orderBy = CONCAT("order by ",TRIM(_sort));
  else
   SET _orderBy = " ORDER BY createdAt DESC";
  end IF;
  IF _limit IS NOT NULL AND _limit > 0 then
   SET _pagination = CONCAT(" LIMIT ",_limit," OFFSET ",_offset);
  else
   SET _pagination = " ";
  end IF;

 SET @sql = CONCAT("SELECT CONVERT(id,CHAR) as id, contenido, CONVERT(id_session,CHAR) as session, correo, createdAt  FROM tbl_comentario  WHERE deletedAt IS NULL ",
  _auxQuery,_orderBy,_pagination);

  PREPARE stmt1 FROM @sql; 
  EXECUTE stmt1; 
  DEALLOCATE PREPARE stmt1; 

END
$$
-- CALL sp_listar_comentarios ('', '', null, null, null);
