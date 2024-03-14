use bibliotecautn
-- TABLE tbl_disponibilida_bot

CREATE TABLE tbl_disponibilida_bot(
  id           INT NOT NULL AUTO_INCREMENT UNIQUE,
  dia         VARCHAR(20) NOT NULL,
  hora_inicio      VARCHAR(20) NOT NULL,
  hora_fin         VARCHAR(20) NOT NULL,
  activo      BOOLEAN NOT NULL,
  createdBy    INT,
  updatedBy    INT,
  deletedBy    INT,
  createdAt    TIMESTAMP NULL DEFAULT NULL,
  updatedAt    TIMESTAMP NULL DEFAULT NULL,
  deletedAt    TIMESTAMP NULL DEFAULT NULL,
  CONSTRAINT pk_tbl_disponibilida_bot PRIMARY KEY (id)
);





-- INSERT rol
-- DROP PROCEDURE IF EXISTS sp_insertar_disponibilida;

DELIMITER $$
CREATE PROCEDURE sp_insertar_disponibilida (_dia VARCHAR(20),_hora_inicio VARCHAR(20),_hora_fin VARCHAR(20),_createBy int)

BEGIN
    -- exit if the duplicate key occurs
  
    DECLARE duplicate_key INT DEFAULT 0;     
  DECLARE sql_exception INT DEFAULT 0;     
  DECLARE CONTINUE HANDLER FOR 1062 SET duplicate_key = 1;     
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_exception = 1; 

  IF (SELECT COUNT(id)  FROM tbl_disponibilida_bot WHERE deletedAt IS NULL AND dia=_dia) =0 THEN
  INSERT INTO tbl_disponibilida_bot
        (dia,
        hora_inicio,
        hora_fin,
        activo,
        createdBy,
        createdAt)
     VALUES
      (_dia,
      _hora_inicio,
      _hora_fin,
       true,
      _createBy,
         NOW());     

   SELECT true as exito,"0" as id, 'Disponibilidad insertada correctamente' as message; 
else 
SELECT false as exito,"0" as id, CONCAT("Ya existe una disponibilidad registrada con el dia: ",_dia)  message; 
end IF;

 END
$$

--- ejecutar
--CALL sp_insertar_disponibilida ('LU','10:00','13:00',0)




-- ACTUALIZAR usuario disponibilidad
-- DROP PROCEDURE IF EXISTS sp_actualizar_disponibilidad;

DELIMITER $$
CREATE PROCEDURE sp_actualizar_disponibilidad (_id_diponibilidad INT,_dia VARCHAR(80),_hora_inicio VARCHAR(20),_hora_fin VARCHAR(20),_activo BOOLEAN,_updateBy int)

BEGIN
    -- exit if the duplicate key occurs
    DECLARE duplicate_key INT DEFAULT 0; 
  DECLARE register_foud INT DEFAULT 0;     
  DECLARE sql_exception INT DEFAULT 0;     
  DECLARE CONTINUE HANDLER FOR 1062 SET duplicate_key = 1;     
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_exception = 1; 

  IF (SELECT deletedAt FROM tbl_disponibilida_bot WHERE id=_id_diponibilidad) IS NULL AND EXISTS(SELECT * FROM tbl_disponibilida_bot WHERE id=_id_diponibilidad) THEN
    IF (SELECT COUNT(id)  FROM tbl_disponibilida_bot WHERE deletedAt IS NULL AND dia=_dia AND id !=_id_diponibilidad) =0 THEN
  UPDATE tbl_disponibilida_bot SET
        dia=_dia,
        hora_inicio=_hora_inicio,
        hora_fin=_hora_fin,
        activo=_activo,
        updatedBy=_updateBy,
        updatedAt=NOW()
     WHERE 
     id=_id_diponibilidad;
      
   SELECT true as exito, CONVERT(_id_diponibilidad,CHAR) as id,'Registro actualizado correctamente' as message; 
   else 
SELECT false as exito, "0" as id, CONCAT("Ya existe un registro registrado con el nombre: ",_dia)  message; 
end IF;
   else
   SELECT false as exito, "0" as id, 'El registro que desea actualizar no existe' as message; 
   end IF;

 END
$$

--- ejecutar
-- CALL sp_actualizar_disponibilidad (1,'MA','12:00','14:00',1,4)



-- OBTENER rol
-- DROP PROCEDURE IF EXISTS sp_obtener_disponibilidad;

DELIMITER $$
CREATE PROCEDURE sp_obtener_disponibilidad(_id_disponibilidad int) 

BEGIN   
        -- exit if the duplicate key occurs
   DECLARE sql_exception INT DEFAULT 0;     
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_exception = 1; 
 
 SELECT CONVERT(id,CHAR) as id,dia,hora_inicio,hora_fin,activo FROM tbl_disponibilida_bot  WHERE id=_id_disponibilidad AND deletedAt IS NULL;

END 
$$
-- ejecutar
-- CALL sp_obtener_disponibilidad (2)



-- OBTENER disponibilidad
-- DROP PROCEDURE IF EXISTS sp_verificar_disponibilidad;

DELIMITER $$
CREATE PROCEDURE sp_verificar_disponibilidad(_dia VARCHAR(80), _hora VARCHAR(100)) 

BEGIN   
        -- exit if the duplicate key occurs
   DECLARE sql_exception INT DEFAULT 0;     
  DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET sql_exception = 1; 

  if(EXISTS(SELECT * from tbl_disponibilida_bot WHERE dia=_dia AND hora_inicio<_hora AND hora_fin>_hora AND activo=1)) THEN
   SELECT true as disponibilidad, _dia as dia, _hora as hora;
  else
   SELECT false as disponibilidad, _dia as dia, _hora as hora;
  end IF;
END 
$$
-- ejecutar
-- CALL sp_verificar_disponibilidad ("Martes","11:00");



-- SELECT listar disponiblidad
-- DROP PROCEDURE IF EXISTS sp_listar_disponiblidad;

DELIMITER $$
CREATE PROCEDURE sp_listar_disponiblidad(
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
   SET _orderBy = " ORDER BY id ASC";
  end IF;
  IF _limit IS NOT NULL AND _limit > 0 then
   SET _pagination = CONCAT(" LIMIT ",_limit," OFFSET ",_offset);
  else
   SET _pagination = " ";
  end IF;

 SET @sql = CONCAT("SELECT CONVERT(id,CHAR) as id,dia,hora_inicio,hora_fin,activo FROM tbl_disponibilida_bot  WHERE deletedAt IS NULL ",
  _auxQuery,_orderBy,_pagination);

  PREPARE stmt1 FROM @sql; 
  EXECUTE stmt1; 
  DEALLOCATE PREPARE stmt1; 

END
$$
-- ejecutar
-- CALL sp_listar_disponiblidad ('null', 'null', 1, 10, null);






