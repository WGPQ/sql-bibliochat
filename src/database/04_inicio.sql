CREATE DATABASE bibliotecautn;
use bibliotecautn
CALL sp_insertar_rol ('Administrador','Acceso administrar la plataforma',0);
CALL sp_insertar_usuario ('Admin','Admin','9999999999','admin@utn.edu.ec','admin','images/admin',1,1);
