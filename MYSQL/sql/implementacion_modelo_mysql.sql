-- ============================================================
-- Examen 02 - Topicos Avanzados de Base de Datos
-- SEBASTIAN QUIJANO JARAMILLO - 000547795
-- MySQL 8.4.9 - AWS RDS
-- ============================================================


-- ============================================================
-- BLOQUE 1. BASE DE DATOS
-- ============================================================

USE brechas_seguridad;


-- ============================================================
-- BLOQUE 2. TABLAS NORMALIZADAS
-- ============================================================

CREATE TABLE organizacion (
    id_organizacion INT NOT NULL,
    nombre_organizacion VARCHAR(200) NOT NULL,
    sector VARCHAR(100) NOT NULL,
    pais VARCHAR(100) NOT NULL,

    CONSTRAINT pk_organizacion
        PRIMARY KEY (id_organizacion),

    CONSTRAINT uq_organizacion_nombre
        UNIQUE (nombre_organizacion)
);


CREATE TABLE brecha (
    codigo_brecha VARCHAR(20) NOT NULL,
    id_organizacion INT NOT NULL,
    fecha_deteccion DATE NOT NULL,
    vector_ataque VARCHAR(100) NOT NULL,
    registros_comprometidos INT NOT NULL,
    costo_estimado_usd DECIMAL(15,2) NOT NULL,
    severidad_incidente VARCHAR(20) NOT NULL,

    CONSTRAINT pk_brecha
        PRIMARY KEY (codigo_brecha),

    CONSTRAINT fk_brecha_organizacion
        FOREIGN KEY (id_organizacion)
        REFERENCES organizacion (id_organizacion),

    CONSTRAINT chk_brecha_registros
        CHECK (registros_comprometidos >= 0),

    CONSTRAINT chk_brecha_costo
        CHECK (costo_estimado_usd >= 0),

    CONSTRAINT chk_brecha_severidad
        CHECK (
            severidad_incidente IN
            ('Baja', 'Media', 'Alta', 'Critica')
        )
);


CREATE TABLE usuario_afectado (
    codigo_usuario VARCHAR(20) NOT NULL,
    pais_residencia VARCHAR(100) NOT NULL,
    rango_edad VARCHAR(50) NOT NULL,

    CONSTRAINT pk_usuario_afectado
        PRIMARY KEY (codigo_usuario)
);


CREATE TABLE tipo_dato_expuesto (
    id_tipo_dato INT NOT NULL,
    nombre_tipo_dato VARCHAR(150) NOT NULL,
    categoria_sensibilidad VARCHAR(20) NOT NULL,

    CONSTRAINT pk_tipo_dato_expuesto
        PRIMARY KEY (id_tipo_dato),

    CONSTRAINT uq_tipo_dato_nombre
        UNIQUE (nombre_tipo_dato),

    CONSTRAINT chk_tipo_dato_sensibilidad
        CHECK (
            categoria_sensibilidad IN
            ('Baja', 'Media', 'Alta', 'Critica')
        )
);


CREATE TABLE exposicion_usuario_brecha (
    id_exposicion BIGINT NOT NULL AUTO_INCREMENT,
    codigo_brecha VARCHAR(20) NOT NULL,
    codigo_usuario VARCHAR(20) NOT NULL,
    id_tipo_dato INT NOT NULL,
    fecha_notificacion_usuario DATE NOT NULL,

    CONSTRAINT pk_exposicion_usuario_brecha
        PRIMARY KEY (id_exposicion),

    CONSTRAINT fk_exposicion_brecha
        FOREIGN KEY (codigo_brecha)
        REFERENCES brecha (codigo_brecha),

    CONSTRAINT fk_exposicion_usuario
        FOREIGN KEY (codigo_usuario)
        REFERENCES usuario_afectado (codigo_usuario),

    CONSTRAINT fk_exposicion_tipo_dato
        FOREIGN KEY (id_tipo_dato)
        REFERENCES tipo_dato_expuesto (id_tipo_dato),

    CONSTRAINT uq_exposicion
        UNIQUE (
            codigo_brecha,
            codigo_usuario,
            id_tipo_dato,
            fecha_notificacion_usuario
        )
);


-- ============================================================
-- BLOQUE 3. TABLA STAGING
-- ============================================================

CREATE TABLE staging_brechas (
    id_organizacion VARCHAR(255),
    nombre_organizacion VARCHAR(255),
    sector VARCHAR(255),
    pais VARCHAR(255),
    codigo_brecha VARCHAR(255),
    fecha_deteccion VARCHAR(255),
    vector_ataque VARCHAR(255),
    registros_comprometidos VARCHAR(255),
    costo_estimado_usd VARCHAR(255),
    severidad_incidente VARCHAR(255),
    codigo_usuario VARCHAR(255),
    pais_residencia VARCHAR(255),
    rango_edad VARCHAR(255),
    id_tipo_dato VARCHAR(255),
    nombre_tipo_dato VARCHAR(255),
    categoria_sensibilidad VARCHAR(255),
    fecha_notificacion_usuario VARCHAR(255),
    latitud VARCHAR(255),
    longitud VARCHAR(255)
);


-- ============================================================
-- VERIFICACION
-- ============================================================

SHOW TABLES;