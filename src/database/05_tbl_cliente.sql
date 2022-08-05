
CREATE TABLE tbl_cliente(
  id           INT NOT NULL AUTO_INCREMENT UNIQUE,
	nombre       VARCHAR(100) NOT NULL,
	correo  VARCHAR(100) NOT NULL,
  id_rol      INT NOT NULL,
  conectado    BOOLEAN NOT NULL DEFAULT 1,
  conectedAt   TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  createdBy    INT,
  updatedBy    INT,
  deletedBy    INT,
  createdAt    TIMESTAMP NULL DEFAULT NULL,
  updatedAt    TIMESTAMP NULL DEFAULT NULL,
  deletedAt    TIMESTAMP NULL DEFAULT NULL,
  CONSTRAINT pk_tbl_cliente PRIMARY KEY (id)
);




-- TABLE cliente

  ALTER TABLE tbl_cliente
ADD CONSTRAINT pk_tbl_cliente_unique_correo UNIQUE (correo);

ALTER TABLE tbl_cliente
ADD CONSTRAINT fk_tbl_cliente_tbl_rol FOREIGN KEY(id_rol)
	REFERENCES tbl_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;

ALTER TABLE tbl_cliente
ADD CONSTRAINT fk_tbl_cliente_tbl_usuario_rol_created FOREIGN KEY(createdBy)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;

ALTER TABLE tbl_cliente
ADD CONSTRAINT fk_tbl_cliente_tbl_usuario_rol_updated FOREIGN KEY(updatedBy)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;

ALTER TABLE tbl_cliente
ADD CONSTRAINT fk_tbl_cliente_tbl_usuario_rol_deleted FOREIGN KEY(deletedBy)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;






-- INSERT rol
-- DROP PROCEDURE IF EXISTS sp_insertar_cliente;

DELIMITER $$
CREATE PROCEDURE sp_insertar_cliente (_nombre VARCHAR(100),_correo VARCHAR(100),_createBy int)

BEGIN
  DECLARE _id_rol int;
    -- exit if the duplicate key occurs
   DECLARE EXIT HANDLER FOR 1062 SELECT false as exito,CONCAT("Ya existe una cuenta registrada con el correo: ",_correo)  message; 
   DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,@text message; 
  END;
  IF EXISTS(SELECT id FROM tbl_rol WHERE nombre="Cliente") THEN
   SET _id_rol= (SELECT id FROM tbl_rol WHERE nombre="Cliente");
  INSERT INTO tbl_cliente
        (nombre,
        correo,
        id_rol,
        createdBy,
        createdAt)
     VALUES
      (_nombre,
      _correo,
      _id_rol,
      _createBy,
         NOW());      
   SELECT true as exito, 'Cliente insertado correctamente' as message; 
  else

   SELECT false as exito, 'Ocurrio un problema al crear la cuenta' as message; 
  END IF;

 END
$$

--- ejecutar
-- CALL sp_insertar_cliente ('Leo','le0@gmail.com',7);




-- ACTUALIZAR usuario con su rol
-- DROP PROCEDURE IF EXISTS sp_actualizar_cliente;

DELIMITER $$
CREATE PROCEDURE sp_actualizar_cliente (_id_cliente INT,_nombre VARCHAR(80), _correo VARCHAR(100),_updateBy int)

BEGIN
    -- exit if the duplicate key occurs
     DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,@text message; 
  END;
  IF (SELECT deletedAt FROM tbl_cliente WHERE id=_id_cliente) IS NULL AND EXISTS(SELECT * FROM tbl_cliente WHERE id=_id_cliente) THEN
    IF (SELECT COUNT(id)  FROM tbl_cliente WHERE deletedAt IS NULL AND correo=_correo AND id !=_id_cliente) =0 THEN
  UPDATE tbl_cliente SET
        nombre=_nombre,
        correo=_correo,
        updatedBy=_updateBy,
        updatedAt=NOW()
     WHERE 
     id=_id_cliente;
      
   SELECT true as exito,'Registro actualizado correctamente' as message; 
   else 
SELECT false as exito, CONCAT("Ya existe un cliente registrado con el correo: ",_correo)  message; 
end IF;
   else
   SELECT false as exito, 'El registro que desea actualizar no existe' as message; 
   end IF;

 END
$$

--- ejecutar
-- CALL sp_actualizar_cliente (1,'1004096572','William',7)



-- OBTENER rol
-- DROP PROCEDURE IF EXISTS sp_obtener_cliente;

DELIMITER $$
CREATE PROCEDURE sp_obtener_cliente(_id_cliente int) 

BEGIN   
        -- exit if the duplicate key occurs
 DECLARE EXIT HANDLER FOR 1062 SELECT false as exito,0 as id, "Error al realizar la consulta"  message; 
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,0 as id,@text message; 
  END; 
 
 SELECT CONVERT(id,CHAR) as id,nombre,correo, CONVERT(id_rol,CHAR) as rol,  conectado, conectedAt FROM tbl_cliente WHERE id=_id_cliente AND deletedAt IS NULL;

END 
$$
-- ejecutar
-- CALL sp_obtener_cliente (2)




-- SELECT listar roles
-- DROP PROCEDURE IF EXISTS sp_listar_clientes;

DELIMITER $$
CREATE PROCEDURE sp_listar_clientes(
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
   SET _orderBy = " ORDER BY id ASC";
  end IF;

  IF _limit IS NOT NULL AND _limit > 0 then
   SET _pagination = CONCAT(" LIMIT ",_limit," OFFSET ",_offset);
  else
   SET _pagination = " ";
  end IF;

 SET _selectQuery = CONCAT("SELECT CONVERT(id,CHAR) as id, nombre, correo, CONVERT(id_rol,CHAR) as rol, conectado, conectedAt FROM tbl_cliente  WHERE deletedAt IS NULL ",
  _auxQuery,_orderBy,_pagination);

  PREPARE stmt1 FROM _selectQuery; 
  EXECUTE stmt1; 
  DEALLOCATE PREPARE stmt1; 

END
$$
-- ejecutar
-- CALL sp_listar_clientes ('', '', 0, 4, null);




-- DELETE rol
-- DROP PROCEDURE IF EXISTS sp_eliminar_cliente;

DELIMITER $$
CREATE PROCEDURE sp_eliminar_cliente(_id_cliente int,_deleteBy int) 

BEGIN   
DECLARE _nombre_rol VARCHAR(80);
        -- exit if the duplicate key occurs
 DECLARE EXIT HANDLER FOR 1062 SELECT false as exito,  "Error al realizar la consulta"  message; 
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,@text message; 
  END;
 IF (SELECT deletedAt FROM tbl_cliente WHERE id=_id_cliente) IS NULL AND EXISTS(SELECT * FROM tbl_cliente WHERE id=_id_cliente) THEN
 UPDATE tbl_cliente set deletedAt = NOW(),conectado=0, deletedBy=_deleteBy where id= _id_cliente;
 SELECT true as exito, 'Registro eliminado correctamente' as message;
 else
  SELECT false as exito, 'El registro que desea eliminar no existe' as message;
 end IF;

END 
$$


-- ejecutar
-- CALL sp_eliminar_cliente (2,7)



