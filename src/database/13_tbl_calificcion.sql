
CREATE TABLE tbl_calificacion(
    id          INT NOT NULL AUTO_INCREMENT UNIQUE,
    nombre      VARCHAR(60) NOT NULL,
    puntuacion  INT NOT NULL,
    createdBy   INT,
    updatedBy   INT,
    deletedBy   INT,
    createdAt   TIMESTAMP NULL,
    updatedAt   TIMESTAMP NULL,
    deletedAt   TIMESTAMP NULL,
    CONSTRAINT pk_tbl_calificacion PRIMARY KEY (id)
);

ALTER TABLE tbl_calificacion_sesion(
    id               INT NOT NULL AUTO_INCREMENT UNIQUE,
    id_sesion        INT NOT NULL,
	  id_calificacion  INT NOT NULL,
    createdBy        INT,
    updatedBy        INT,
    deletedBy        INT,
    createdAt        TIMESTAMP NULL,
    updatedAt        TIMESTAMP NULL,
    deletedAt        TIMESTAMP NULL,
    CONSTRAINT pk_tbl_calificacion_sesion PRIMARY KEY (id)
);



-- TABLE tbl_calificacion_sesion
ALTER TABLE tbl_calificacion_sesion
ADD CONSTRAINT fk_tbl_calificacion_sesion_tbl_sesion FOREIGN KEY(id_sesion)
	REFERENCES tbl_sesion(id)
	ON UPDATE restrict
	ON DELETE restrict;


ALTER TABLE tbl_calificacion_sesion
ADD CONSTRAINT fk_tbl_calificacion_sesion_tbl_calificacion FOREIGN KEY(id_calificacion)
	REFERENCES tbl_calificacion(id)
	ON UPDATE restrict
	ON DELETE restrict;
















































