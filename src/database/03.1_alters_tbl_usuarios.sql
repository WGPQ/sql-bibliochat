
-- ALTER TABLE USUARIO
ALTER TABLE tbl_usuario
ADD CONSTRAINT pk_unique_correo UNIQUE (correo);


ALTER TABLE tbl_usuario
ADD CONSTRAINT fk_tbl_usuario_tbl_usuario_rol_updated FOREIGN KEY(updatedBy)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;

ALTER TABLE tbl_usuario
ADD CONSTRAINT fk_tbl_usuario_tbl_usuario_rol_deleted FOREIGN KEY(deletedBy)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;



-- ALTER TABLE USUARIO ROL
ALTER TABLE tbl_usuario_rol
ADD CONSTRAINT fk_tbl_usuario_rol_tbl_usuario FOREIGN KEY(id_usuario)
	REFERENCES tbl_usuario(id)
	ON UPDATE restrict
	ON DELETE restrict;


ALTER TABLE tbl_usuario_rol
ADD CONSTRAINT fk_tbl_usuario_rol_tbl_rol FOREIGN KEY(id_rol)
	REFERENCES tbl_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;



ALTER TABLE tbl_usuario_rol
ADD CONSTRAINT fk_tbl_usuario_rol_tbl_usuario_rol_updated FOREIGN KEY(updatedBy)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;

ALTER TABLE tbl_usuario_rol
ADD CONSTRAINT fk_tbl_usuario_rol_tbl_usuario_rol_deleted FOREIGN KEY(deletedBy)
	REFERENCES tbl_usuario_rol(id)
	ON UPDATE restrict
	ON DELETE restrict;



