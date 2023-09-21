
-- LOGIN
-- DROP PROCEDURE IF EXISTS sp_login


DELIMITER $$
CREATE PROCEDURE sp_login(_correo VARCHAR(60),_clave VARCHAR(80))
BEGIN
 DECLARE _id_usuario_rol VARCHAR(12);
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,'0' as id_usuario,@text message; 
  END;

  IF EXISTS(SELECT * FROM tbl_usuario WHERE correo = _correo) THEN
   IF(_clave IS NOT NULL AND CHAR_LENGTH(TRIM(_clave)) > 0)THEN  
  IF EXISTS(SELECT * FROM tbl_usuario WHERE correo = _correo AND  clave = PASSWORD(_clave))THEN
SET _id_usuario_rol =  (SELECT ur.id FROM tbl_usuario u,tbl_usuario_rol ur WHERE correo=_correo AND u.id=ur.id_usuario);

    IF (SELECT activo FROM tbl_usuario_rol WHERE id=_id_usuario_rol) IS true THEN
       UPDATE tbl_usuario_rol SET conectado=1, conectedAt=NOW() WHERE id=_id_usuario_rol;
    SELECT true as exito, _id_usuario_rol as id_usuario, 'Ingreso correcto' as message;
    else
     SELECT false as exito, '0' as id_usuario, 'Cuenta desactivado pongase en contacto con el Administrador' as message;
    end if;
  else
     SELECT false as exito, '0' as id_usuario, 'Contraseña incorrecta' as message;
  end IF;
   else 
SET _id_usuario_rol =  (SELECT ur.id FROM tbl_usuario u,tbl_usuario_rol ur WHERE correo=_correo AND u.id=ur.id_usuario);

    IF (SELECT activo FROM tbl_usuario_rol WHERE id=_id_usuario_rol) IS true THEN
       UPDATE tbl_usuario_rol SET conectado=1, conectedAt=NOW() WHERE id=_id_usuario_rol;
    SELECT true as exito, _id_usuario_rol as id_usuario, 'Ingreso correcto' as message;
    else
     SELECT false as exito, '0' as id_usuario, 'Cuenta desactivado pongase en contacto con el Administrador' as message;
    end if;

   end IF;
  else
    SELECT false as exito, '0' as id_usuario, 'Correo incorrecto' as message;
  end if;
 END
$$

-- ejecutar
-- CALL sp_login('leo@gmail.com','yJwqpsU3QB')




-- LOGIN
-- DROP PROCEDURE IF EXISTS sp_logout


DELIMITER $$
CREATE PROCEDURE sp_logout(_id_usuario_rol int)
BEGIN
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,'0' as id,@text message; 
  END;

  IF EXISTS(SELECT * FROM tbl_usuario_rol WHERE id=_id_usuario_rol) THEN

    -- IF (SELECT activo FROM tbl_usuario_rol WHERE id=_id_usuario_rol AND conectado=1) IS true THEN
       UPDATE tbl_usuario_rol SET conectado=0, conectedAt=NOW() WHERE id=_id_usuario_rol;
    SELECT true as exito, CONVERT(_id_usuario_rol,CHAR) as id, 'salia exitosa' as message;
    -- else
    --  SELECT false as exito, '0' as id,  'No puede salir si no inicio session' as message;
    -- end if;
  else
    SELECT false as exito, '0' as id, 'usuario no existe' as message;
  end if;
 END
$$

--ejecutar
-- CALL sp_logout(9)




-- RESETEAR CONTRASEÑA
-- DROP PROCEDURE IF EXISTS sp_resetear_contrasenia


DELIMITER $$
CREATE PROCEDURE sp_resetear_contrasenia (_id_usuario_rol INT,_clave VARCHAR(80),_updatedBy INT)

BEGIN
  DECLARE _id_usuario int;   
  -- exit if the duplicate key occurs
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,"0" as id,@text message; 
  END;
 SET _id_usuario = (SELECT id_usuario FROM tbl_usuario_rol WHERE id=_id_usuario_rol);
  
  IF (SELECT activo FROM tbl_usuario_rol WHERE id_usuario=_id_usuario) IS true THEN
  UPDATE tbl_usuario_rol SET verificado=0, updatedBy=_updatedBy WHERE id=_id_usuario_rol;
  UPDATE tbl_usuario SET
        clave=PASSWORD(_clave),
        updatedBy=_updatedBy,
        updatedAt=NOW()
     WHERE 
     id=_id_usuario;
  else
  SELECT false as exito,"0" as id, 'No se puede resetar debido a que la cuenta se encuentra desactivada' as message; 
  end if;
      
   SELECT true as exito,"0" as id,'Contraseña resetada correctamente' as message; 

 END
$$


-- ejecutar

-- CALL sp_resetear_contrasenia(77,'f2QOF27UTi','BIBLIOBOTUNIVERSIDADTENICADELNORTEIBARRA');





-- RESETEAR CONTRASEÑA
-- DROP PROCEDURE IF EXISTS sp_actualizar_contrasenia


DELIMITER $$
CREATE PROCEDURE sp_actualizar_contrasenia (_id_usuario_rol INT,_clave VARCHAR(80),_updatedBy INT)

BEGIN
  DECLARE _id_usuario int;   
  -- exit if the duplicate key occurs
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,"0" as id,@text message; 
  END;

 SET _id_usuario = (SELECT id_usuario FROM tbl_usuario_rol WHERE id=_id_usuario_rol);
  
  IF (SELECT activo FROM tbl_usuario_rol WHERE id_usuario=_id_usuario) IS true THEN
  UPDATE tbl_usuario_rol SET verificado=true,updatedAt=NOW(),updatedBy=_updatedBy WHERE id=_id_usuario_rol;
  UPDATE tbl_usuario SET
        clave=PASSWORD(_clave),
        updatedBy=_updatedBy,
        updatedAt=NOW()
     WHERE 
     id=_id_usuario;
  else
  SELECT false as exito,"0"as id,'No se puede actualizada la contraseña debido a que la cuenta se encuentra desactivada' as message; 
  end if;
      
   SELECT true as exito,"0" as id,'Contraseña actualizada correctamente' as message; 

 END
$$


-- ejecutar
-- CALL sp_actualizar_contrasenia(4,'f2QOF27UTi',4);

-- SELECT obtener ultimo chat
-- DROP PROCEDURE IF EXISTS sp_auth_library;

DELIMITER $$
CREATE PROCEDURE sp_auth_library(_email VARCHAR(40))
BEGIN

DECLARE _id_usuario INT;
     -- exit if the duplicate key occurs
 DECLARE EXIT HANDLER FOR 1062 SELECT false as exito,"Error al realizar la consulta"  message; 
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,@text message; 
  END;

IF EXISTS(SELECT * FROM tbl_usuario WHERE correo=_email AND deletedAt IS NULL) THEN
SET _id_usuario = (SELECT ur.id FROM tbl_usuario_rol ur,tbl_usuario u WHERE ur.id_usuario=u.id AND u.deletedAt IS NULL AND ur.deletedAt IS NULL AND u.correo=_email);
SELECT true as exito,CONCAT('Usuario encontrado -',CONVERT(_id_usuario,CHAR)) as message; 

else
SELECT false as exito,'Usuario no encontrado' as message; 
END IF;

END
$$

-- ejecutar
-- CALL sp_auth_library ("wgpumaq@gmail.com");




-- SELECT obtener ultimo chat
-- DROP PROCEDURE IF EXISTS sp_usuarios_en_linea;

DELIMITER $$
CREATE PROCEDURE sp_usuarios_en_linea(_id_rol int)
BEGIN
      -- exit if the duplicate key occurs
 DECLARE EXIT HANDLER FOR 1062 SELECT false as exito, "Usurio no encontrado"  message; 

 DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,@text message; 
  END;
 SELECT CONVERT(ur.id,CHAR) as id, ur.verificado, u.foto, u.nombres, u.apellidos, u.nombre_completo, u.telefono, u.correo,u.rol, CONVERT(ur.id_rol,CHAR) as id_rol, ur.activo as activo, ur.conectado as conectado, ur.conectedAt as conectedAt FROM tbl_usuario u, tbl_usuario_rol ur WHERE u.deletedAt IS NULL AND ur.deletedAt IS NULL AND ur.conectado=1 AND u.id=ur.id_usuario AND ur.id_rol=_id_rol;


END
$$

-- ejecutar
-- CALL sp_usuarios_en_linea (3);




-- DROP PROCEDURE IF EXISTS sp_auth_clientes;

DELIMITER $$
CREATE PROCEDURE sp_auth_clientes(_email VARCHAR(40))
BEGIN

DECLARE _id_cliente INT;
     -- exit if the duplicate key occurs
 DECLARE EXIT HANDLER FOR 1062 SELECT false as exito,"Error al realizar la consulta"  message; 
 DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
     GET DIAGNOSTICS CONDITION 1  @text = MESSAGE_TEXT;
       SELECT false as exito,@text message; 
  END;

IF EXISTS(SELECT * FROM tbl_cliente WHERE correo=_email AND deletedAt IS NULL) THEN
SET _id_cliente = (SELECT id FROM tbl_cliente WHERE correo=_email);
SELECT true as exito,CONCAT('Usuario encontrado -',CONVERT(_id_cliente,CHAR)) as message; 

else
SELECT false as exito,'Usuario no encontrado' as message; 
END IF;

END
$$

-- ejecutar
-- CALL sp_auth_clientes ("erickm@gmail.com");

