-- Examen 02 - Topicos Avanzados de Base de Datos
-- Samuel Parra Cadavid
-- ID SIGAA: 000551191
-- PostgreSQL 18.x
-- Base de datos: examen02
-- Esquema: brechas_seguridad

-- Este script esta organizado por bloques.
-- La carga de los cuatro CSV a staging_brechas se realiza desde DBeaver
-- despues de crear la tabla staging y antes de ejecutar el bloque de carga normalizada.

-- Bloque 1. Usuario, esquema y privilegios
-- Ejecutar este bloque como administrador.
-- La contrasena del rol debe configurarse fuera del repositorio desde DBeaver.

create role samuel
with login;

grant connect on database examen02
to samuel;

create schema brechas_seguridad
authorization samuel;

alter role samuel
set search_path to brechas_seguridad, public;


-- Bloque 2. Tablas normalizadas

create table brechas_seguridad.organizacion (
    id_organizacion integer generated always as identity,
    nombre_organizacion varchar(150) not null,
    sector_organizacion varchar(100) not null,
    pais_organizacion varchar(100) not null,
    tamano_empleados integer not null,

    constraint pk_organizacion
        primary key (id_organizacion),

    constraint uk_organizacion_nombre
        unique (nombre_organizacion),

    constraint ck_organizacion_tamano_empleados
        check (tamano_empleados > 0)
);


create table brechas_seguridad.brecha (
    codigo_brecha varchar(50) not null,
    id_organizacion integer not null,
    fecha_ocurrencia date not null,
    fecha_deteccion date not null,
    vector_ataque varchar(100) not null,
    severidad_incidente varchar(50) not null,
    registros_afectados_total integer not null,
    costo_estimado_total numeric(14,2) not null,

    constraint pk_brecha
        primary key (codigo_brecha),

    constraint fk_brecha_organizacion
        foreign key (id_organizacion)
        references brechas_seguridad.organizacion (id_organizacion),

    constraint ck_brecha_fechas
        check (fecha_deteccion >= fecha_ocurrencia),

    constraint ck_brecha_registros_afectados
        check (registros_afectados_total >= 0),

    constraint ck_brecha_costo
        check (costo_estimado_total >= 0),

    constraint ck_brecha_severidad
        check (severidad_incidente in ('Baja', 'Media', 'Alta', 'Critica'))
);


create table brechas_seguridad.usuario_afectado (
    codigo_usuario varchar(50) not null,
    id_organizacion integer not null,
    pseudonimo_usuario varchar(100) not null,
    email_hash_usuario varchar(255) not null,
    pais_residencia_usuario varchar(100) not null,
    fecha_registro_usuario date not null,

    constraint pk_usuario_afectado
        primary key (codigo_usuario),

    constraint fk_usuario_organizacion
        foreign key (id_organizacion)
        references brechas_seguridad.organizacion (id_organizacion)
);


create table brechas_seguridad.tipo_dato_expuesto (
    id_tipo_dato integer generated always as identity,
    nombre_tipo_dato varchar(100) not null,
    categoria_sensibilidad varchar(50) not null,

    constraint pk_tipo_dato_expuesto
        primary key (id_tipo_dato),

    constraint uk_tipo_dato_nombre
        unique (nombre_tipo_dato),

    constraint ck_tipo_dato_sensibilidad
        check (categoria_sensibilidad in ('Baja', 'Media', 'Alta', 'Critica'))
);


create table brechas_seguridad.exposicion_usuario_brecha (
    codigo_brecha varchar(50) not null,
    codigo_usuario varchar(50) not null,
    id_tipo_dato integer not null,
    fecha_notificacion_usuario date not null,

    constraint pk_exposicion_usuario_brecha
        primary key (
            codigo_brecha,
            codigo_usuario,
            id_tipo_dato
        ),

    constraint fk_exposicion_brecha
        foreign key (codigo_brecha)
        references brechas_seguridad.brecha (codigo_brecha),

    constraint fk_exposicion_usuario
        foreign key (codigo_usuario)
        references brechas_seguridad.usuario_afectado (codigo_usuario),

    constraint fk_exposicion_tipo_dato
        foreign key (id_tipo_dato)
        references brechas_seguridad.tipo_dato_expuesto (id_tipo_dato)
);


-- Bloque 3. Tabla staging

create table brechas_seguridad.staging_brechas (
    nombre_organizacion text,
    sector_organizacion text,
    pais_organizacion text,
    tamano_empleados_organizacion text,
    codigo_brecha text,
    fecha_ocurrencia text,
    fecha_deteccion text,
    vector_ataque text,
    severidad_incidente text,
    registros_afectados_total text,
    costo_estimado_total text,
    codigo_usuario text,
    pseudonimo_usuario text,
    email_hash_usuario text,
    pais_residencia_usuario text,
    fecha_registro_usuario text,
    tipo_dato_expuesto text,
    categoria_sensibilidad_dato text,
    fecha_notificacion_usuario text
);


-- Cargar aqui los cuatro CSV mediante DBeaver en modo Append/Insert.
-- Resultado esperado:
-- select count(*) from brechas_seguridad.staging_brechas;
-- 40000


-- Bloque 4. Carga normalizada

insert into brechas_seguridad.organizacion (
    nombre_organizacion,
    sector_organizacion,
    pais_organizacion,
    tamano_empleados
)
select distinct
    nombre_organizacion,
    sector_organizacion,
    pais_organizacion,
    tamano_empleados_organizacion::integer
from brechas_seguridad.staging_brechas;


insert into brechas_seguridad.tipo_dato_expuesto (
    nombre_tipo_dato,
    categoria_sensibilidad
)
select distinct
    tipo_dato_expuesto,
    categoria_sensibilidad_dato
from brechas_seguridad.staging_brechas;


insert into brechas_seguridad.brecha (
    codigo_brecha,
    id_organizacion,
    fecha_ocurrencia,
    fecha_deteccion,
    vector_ataque,
    severidad_incidente,
    registros_afectados_total,
    costo_estimado_total
)
select distinct
    s.codigo_brecha,
    o.id_organizacion,
    s.fecha_ocurrencia::date,
    s.fecha_deteccion::date,
    s.vector_ataque,
    s.severidad_incidente,
    s.registros_afectados_total::integer,
    s.costo_estimado_total::numeric(14,2)
from brechas_seguridad.staging_brechas s
join brechas_seguridad.organizacion o
    on o.nombre_organizacion = s.nombre_organizacion;


insert into brechas_seguridad.usuario_afectado (
    codigo_usuario,
    id_organizacion,
    pseudonimo_usuario,
    email_hash_usuario,
    pais_residencia_usuario,
    fecha_registro_usuario
)
select distinct
    s.codigo_usuario,
    o.id_organizacion,
    s.pseudonimo_usuario,
    s.email_hash_usuario,
    s.pais_residencia_usuario,
    s.fecha_registro_usuario::date
from brechas_seguridad.staging_brechas s
join brechas_seguridad.organizacion o
    on o.nombre_organizacion = s.nombre_organizacion;


insert into brechas_seguridad.exposicion_usuario_brecha (
    codigo_brecha,
    codigo_usuario,
    id_tipo_dato,
    fecha_notificacion_usuario
)
select distinct
    s.codigo_brecha,
    s.codigo_usuario,
    t.id_tipo_dato,
    s.fecha_notificacion_usuario::date
from brechas_seguridad.staging_brechas s
join brechas_seguridad.tipo_dato_expuesto t
    on t.nombre_tipo_dato = s.tipo_dato_expuesto;


-- Bloque 5. Validaciones

-- Conteos esperados
select 'organizacion' as tabla, count(*) as registros
from brechas_seguridad.organizacion
union all
select 'tipo_dato_expuesto', count(*)
from brechas_seguridad.tipo_dato_expuesto
union all
select 'brecha', count(*)
from brechas_seguridad.brecha
union all
select 'usuario_afectado', count(*)
from brechas_seguridad.usuario_afectado
union all
select 'exposicion_usuario_brecha', count(*)
from brechas_seguridad.exposicion_usuario_brecha;

-- Esperado:
-- organizacion                  60
-- tipo_dato_expuesto            10
-- brecha                        800
-- usuario_afectado              7887
-- exposicion_usuario_brecha     40000


-- Duplicados en claves naturales y primarias
select nombre_organizacion, count(*)
from brechas_seguridad.organizacion
group by nombre_organizacion
having count(*) > 1;

select codigo_brecha, count(*)
from brechas_seguridad.brecha
group by codigo_brecha
having count(*) > 1;

select codigo_usuario, count(*)
from brechas_seguridad.usuario_afectado
group by codigo_usuario
having count(*) > 1;

select nombre_tipo_dato, count(*)
from brechas_seguridad.tipo_dato_expuesto
group by nombre_tipo_dato
having count(*) > 1;

select
    codigo_brecha,
    codigo_usuario,
    id_tipo_dato,
    count(*)
from brechas_seguridad.exposicion_usuario_brecha
group by
    codigo_brecha,
    codigo_usuario,
    id_tipo_dato
having count(*) > 1;


-- Nulos en campos obligatorios
select count(*) as nulos_organizacion
from brechas_seguridad.organizacion
where id_organizacion is null
   or nombre_organizacion is null
   or sector_organizacion is null
   or pais_organizacion is null
   or tamano_empleados is null;

select count(*) as nulos_brecha
from brechas_seguridad.brecha
where codigo_brecha is null
   or id_organizacion is null
   or fecha_ocurrencia is null
   or fecha_deteccion is null
   or vector_ataque is null
   or severidad_incidente is null
   or registros_afectados_total is null
   or costo_estimado_total is null;

select count(*) as nulos_usuario
from brechas_seguridad.usuario_afectado
where codigo_usuario is null
   or id_organizacion is null
   or pseudonimo_usuario is null
   or email_hash_usuario is null
   or pais_residencia_usuario is null
   or fecha_registro_usuario is null;

select count(*) as nulos_tipo_dato
from brechas_seguridad.tipo_dato_expuesto
where id_tipo_dato is null
   or nombre_tipo_dato is null
   or categoria_sensibilidad is null;

select count(*) as nulos_exposicion
from brechas_seguridad.exposicion_usuario_brecha
where codigo_brecha is null
   or codigo_usuario is null
   or id_tipo_dato is null
   or fecha_notificacion_usuario is null;


-- Claves foraneas huerfanas
select count(*) as brechas_sin_organizacion
from brechas_seguridad.brecha b
left join brechas_seguridad.organizacion o
    on o.id_organizacion = b.id_organizacion
where o.id_organizacion is null;

select count(*) as usuarios_sin_organizacion
from brechas_seguridad.usuario_afectado u
left join brechas_seguridad.organizacion o
    on o.id_organizacion = u.id_organizacion
where o.id_organizacion is null;

select count(*) as exposiciones_sin_brecha
from brechas_seguridad.exposicion_usuario_brecha e
left join brechas_seguridad.brecha b
    on b.codigo_brecha = e.codigo_brecha
where b.codigo_brecha is null;

select count(*) as exposiciones_sin_usuario
from brechas_seguridad.exposicion_usuario_brecha e
left join brechas_seguridad.usuario_afectado u
    on u.codigo_usuario = e.codigo_usuario
where u.codigo_usuario is null;

select count(*) as exposiciones_sin_tipo_dato
from brechas_seguridad.exposicion_usuario_brecha e
left join brechas_seguridad.tipo_dato_expuesto t
    on t.id_tipo_dato = e.id_tipo_dato
where t.id_tipo_dato is null;


-- Calidad de datos
select count(*) as organizaciones_tamano_invalido
from brechas_seguridad.organizacion
where tamano_empleados <= 0;

select count(*) as brechas_fechas_invalidas
from brechas_seguridad.brecha
where fecha_deteccion < fecha_ocurrencia;

select count(*) as brechas_valores_negativos
from brechas_seguridad.brecha
where registros_afectados_total < 0
   or costo_estimado_total < 0;

select count(*) as severidades_invalidas
from brechas_seguridad.brecha
where severidad_incidente not in ('Baja', 'Media', 'Alta', 'Critica');

select count(*) as sensibilidades_invalidas
from brechas_seguridad.tipo_dato_expuesto
where categoria_sensibilidad not in ('Baja', 'Media', 'Alta', 'Critica');

select count(*) as notificaciones_antes_deteccion
from brechas_seguridad.exposicion_usuario_brecha e
join brechas_seguridad.brecha b
    on b.codigo_brecha = e.codigo_brecha
where e.fecha_notificacion_usuario < b.fecha_deteccion;

select count(*) as exposiciones_organizacion_inconsistente
from brechas_seguridad.exposicion_usuario_brecha e
join brechas_seguridad.brecha b
    on b.codigo_brecha = e.codigo_brecha
join brechas_seguridad.usuario_afectado u
    on u.codigo_usuario = e.codigo_usuario
where b.id_organizacion <> u.id_organizacion;
