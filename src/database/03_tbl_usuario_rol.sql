-- TABLE USUARIO ROL

CREATE TABLE tbl_usuario_rol(
    id          INT NOT NULL AUTO_INCREMENT UNIQUE,
	id_usuario  INT NOT NULL,
	id_rol      INT NOT NULL,
    activo      BOOLEAN NOT NULL,
    verificado  BOOLEAN NOT NULL,
    conectado    BOOLEAN NOT NULL,
    conectedAt   TIMESTAMP NULL DEFAULT NULL,
    createdBy   INT,
    updatedBy   INT,
    deletedBy   INT,
    createdAt   TIMESTAMP NULL DEFAULT NULL,
    updatedAt   TIMESTAMP NULL DEFAULT NULL,
    deletedAt   TIMESTAMP NULL DEFAULT NULL,
    CONSTRAINT pk_tbl_usuario_rol PRIMARY KEY (id)
);




