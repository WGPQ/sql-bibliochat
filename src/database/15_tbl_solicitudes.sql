use bibliotecautn
-- TABLE tbl_solicitudes

CREATE TABLE tbl_solicitudes(
  id           INT NOT NULL AUTO_INCREMENT UNIQUE,
  solicitante  INT,
  reaccion     INT,
  id_session   INT,
  accion       BOOLEAN NOT NULL,
  conversationId VARCHAR(200),
  createdBy    INT,
  updatedBy    INT,
  createdAt    TIMESTAMP NULL DEFAULT NULL,
  updatedAt    TIMESTAMP NULL DEFAULT NULL,
  deletedAt    TIMESTAMP NULL DEFAULT NULL,
  CONSTRAINT pk_tbl_solicitud PRIMARY KEY (id)
);

ALTER TABLE tbl_solicitudes
ADD CONSTRAINT fk_tbl_solicitud_tbl_usuario_rol_solicitante FOREIGN KEY(solicitante)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;

ALTER TABLE tbl_solicitudes
ADD CONSTRAINT fk_tbl_solicitud_tbl_usuario_rol_reaccion FOREIGN KEY(reaccion)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;

ALTER TABLE tbl_solicitudes
ADD CONSTRAINT fk_tbl_solicitud_tbl_session FOREIGN KEY(id_session)
	REFERENCES tbl_session(id)
	ON UPDATE restrict
	ON DELETE restrict;

ALTER TABLE tbl_usuario
ADD CONSTRAINT fk_tbl_solicitud_tbl_usuario_rol_created FOREIGN KEY(createdBy)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;

ALTER TABLE tbl_usuario
ADD CONSTRAINT fk_tbl_solicitud_tbl_usuario_rol_updated FOREIGN KEY(updatedBy)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;



-- INSERT rol
-- DROP PROCEDURE IF EXISTS sp_insertar_solicitud;

DELIMITER $$
CREATE PROCEDURE sp_insertar_solicitud (_solicitante INT,_reaccion INT,_id_session INT,_accion BOOLEAN, _conversationId VARCHAR(200),_createBy int)

BEGIN
    -- exit if the duplicate key occurs
  DECLARE _id_solicitud VARCHAR(50);
   DECLARE duplicate_key INT DEFAULT 0; 
  DECLARE register_foud INT DEFAULT 0;     
  DECLARE sql_exception INT DEFAULT 0;     
  DECLARE CONTINUE HANDLER FOR 1062 SET duplicate_key = 1;     
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_exception = 1; 

  IF (SELECT COUNT(id)  FROM tbl_solicitudes WHERE deletedAt IS NULL AND id_session=_id_session) =0 THEN
  INSERT INTO tbl_solicitudes
        (solicitante,
        reaccion,
        id_session,
        accion,
        conversationId,
        createdBy,
        createdAt)
     VALUES
      (_solicitante,
      _reaccion,
      _id_session,
      _accion,
      _conversationId,
      _createBy,
         NOW()); 
         set _id_solicitud   = LAST_INSERT_ID();     
   SELECT true as exito, CONVERT(_id_solicitud,CHAR) as id,'Solicitud creada correctamente' as message; 
else 
SELECT false as exito,"0" as id, CONCAT("Ya existe una solicitud para la session ",_id_session)  message; 
end IF;

 END
$$

--- ejecutar
-- CALL sp_insertar_solicitud (1,19,128,1,1,1);




-- ACTUALIZAR solicitud
-- DROP PROCEDURE IF EXISTS sp_actualizar_solicitud;

DELIMITER $$
CREATE PROCEDURE sp_actualizar_solicitud (_id_solicitud INT,_reaccion INT,_id_session INT,_accion BOOLEAN,_updateBy int)

BEGIN
    -- exit if the duplicate key occurs
    DECLARE duplicate_key INT DEFAULT 0; 
  DECLARE register_foud INT DEFAULT 0;     
  DECLARE sql_exception INT DEFAULT 0;     
  DECLARE CONTINUE HANDLER FOR 1062 SET duplicate_key = 1;     
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_exception = 1; 

  IF (SELECT deletedAt FROM tbl_solicitudes WHERE id=_id_solicitud) IS NULL AND EXISTS(SELECT * FROM tbl_solicitudes WHERE id=_id_solicitud) THEN
    IF (SELECT COUNT(id)  FROM tbl_solicitudes WHERE deletedAt IS NULL AND id_session=_id_session AND id !=_id_solicitud) =0 THEN
  UPDATE tbl_solicitudes SET
        reaccion=_reaccion,
        accion=_accion,
        updatedBy=_updateBy,
        updatedAt=NOW()
     WHERE 
     id=_id_solicitud;
      
   SELECT true as exito,CONVERT(_id_solicitud,CHAR) as id,'Solicitud actualizada correctamente' as message; 
   else 
SELECT false as exito,"0" as id, CONCAT("Ya existe una solicitud para la session: ",_id_session)  message; 
end IF;
   else
   SELECT false as exito,"0" as id, 'La soliciud que desea actualizar no existe' as message; 
   end IF;

 END
$$

--- ejecutar
-- CALL sp_actualizar_solicitud (6,1,728,0,1);





-- REACCIONEAR solicitud
-- DROP PROCEDURE IF EXISTS sp_reaccionar_solicitud;

DELIMITER $$
CREATE PROCEDURE sp_reaccionar_solicitud (_id_solicitud INT,_id_reaccion INT,_accion BOOLEAN,_updateBy int)

BEGIN
    -- exit if the duplicate key occurs
        DECLARE duplicate_key INT DEFAULT 0; 
  DECLARE register_foud INT DEFAULT 0;     
  DECLARE sql_exception INT DEFAULT 0;     
  DECLARE CONTINUE HANDLER FOR 1062 SET duplicate_key = 1;     
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_exception = 1; 

  IF (SELECT deletedAt FROM tbl_solicitudes WHERE id=_id_solicitud) IS NULL AND EXISTS(SELECT * FROM tbl_solicitudes WHERE id=_id_solicitud) THEN
  UPDATE tbl_solicitudes SET
        reaccion=_id_reaccion,
        accion=_accion,
        updatedBy=_updateBy,
        updatedAt=NOW()
     WHERE 
     id=_id_solicitud;
      
   SELECT true as exito,CONVERT(_id_solicitud,CHAR) as id,'Solicitud actualizada correctamente' as message; 
   else
   SELECT false as exito,"0" as id, 'La soliciud que desea actualizar no existe' as message; 
   end IF;

 END
$$

--- ejecutar
-- CALL sp_reaccionar_solicitud (6,1,true,1);









-- OBTENER rol
-- DROP PROCEDURE IF EXISTS sp_obtener_solicitudes;

DELIMITER $$
CREATE PROCEDURE sp_obtener_solicitudes(_id_solicitud int) 

BEGIN   
        -- exit if the duplicate key occurs
    DECLARE sql_exception INT DEFAULT 0;     
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_exception = 1; 
 
 SELECT CONVERT(id,CHAR) as id, CONVERT(solicitante,CHAR) as solicitante, CONVERT(reaccion,CHAR) as reaccion, CONVERT(id_session,CHAR) as session, accion, conversationId, createdAt  FROM tbl_solicitudes  WHERE id=_id_solicitud AND deletedAt IS NULL;

END 
$$
-- ejecutar
-- CALL sp_obtener_solicitudes (2)




-- SELECT listar roles
-- DROP PROCEDURE IF EXISTS sp_listar_solicitudes;

DELIMITER $$
CREATE PROCEDURE sp_listar_solicitudes(
  _columna varchar(250),
  _nombre varchar(250),
  _offset int,
  _limit int,
  _anio VARCHAR(200),
  _meses VARCHAR(500),
  _sort VARCHAR(100))
BEGIN

 DECLARE _selectQuery varchar(3000);
 DECLARE _auxQuery varchar(300);
 DECLARE _orderBy varchar(300);
 DECLARE _pagination varchar(300);
 DECLARE _filterYear varchar(200);
 DECLARE _filterMoth varchar(200);

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
  IF _anio IS NOT NULL AND CHAR_LENGTH(TRIM(_anio)) > 0 then
  SET _filterYear = CONCAT(" AND YEAR(createdAt) = ",_anio);
  else
   SET _filterYear = " ";
  end IF;
  IF _meses IS NOT NULL AND CHAR_LENGTH(TRIM(_meses)) > 0 then
  SET _filterMoth = CONCAT(" AND MONTH(createdAt) REGEXP '",_meses,"'");
  else
   SET _filterMoth = " ";
  end IF;

 SET @sql = CONCAT("SELECT CONVERT(id,CHAR) as id, CONVERT(solicitante,CHAR) as solicitante, CONVERT(reaccion,CHAR) as reaccion, CONVERT(id_session,CHAR) as session, accion, conversationId, createdAt  FROM tbl_solicitudes  WHERE deletedAt IS NULL ",
  _filterMoth,_auxQuery,_filterYear,_orderBy,_pagination);

  PREPARE stmt1 FROM @sql; 
  EXECUTE stmt1; 
  DEALLOCATE PREPARE stmt1; 

END
$$
-- ejecutar
--  CALL sp_listar_solicitudes ('', '', null, null,"2021","[3|5]", null);

---SELECT * FROM tbl_solicitudes WHERE ",1,2,3,5,4,7,12," LIKE CONCAT('%,',CONVERT(MONTH(createdAt),CHAR),',%')
-- SELECT * FROM tbl_solicitudes WHERE ",1,2,3,5,4,7,12," like '%,'||MONTH(createdAt)||',%'
-- SELECT * FROM tbl_solicitudes WHERE MONTH(createdAt) IN('1', '2', '5');
-- SELECT * FROM tbl_solicitudes WHERE MONTH(createdAt) REGEXP '[3|5]'