-- Examen 02 - Topicos Avanzados de Base de Datos
-- Etapa 4 - Historial de exposicion de un usuario
-- Samuel Parra Cadavid
-- ID SIGAA: 000551191
-- PostgreSQL 18.x

-- Consulta funcional
select
    u.codigo_usuario,
    b.codigo_brecha,
    t.nombre_tipo_dato,
    t.categoria_sensibilidad,
    o.nombre_organizacion,
    e.fecha_notificacion_usuario
from brechas_seguridad.usuario_afectado u
join brechas_seguridad.exposicion_usuario_brecha e
    on e.codigo_usuario = u.codigo_usuario
join brechas_seguridad.brecha b
    on b.codigo_brecha = e.codigo_brecha
join brechas_seguridad.tipo_dato_expuesto t
    on t.id_tipo_dato = e.id_tipo_dato
join brechas_seguridad.organizacion o
    on o.id_organizacion = b.id_organizacion
where u.codigo_usuario = 'US-002823'
order by e.fecha_notificacion_usuario;


-- Plan de ejecucion inicial
explain (analyze, buffers)
select
    u.codigo_usuario,
    b.codigo_brecha,
    t.nombre_tipo_dato,
    t.categoria_sensibilidad,
    o.nombre_organizacion,
    e.fecha_notificacion_usuario
from brechas_seguridad.usuario_afectado u
join brechas_seguridad.exposicion_usuario_brecha e
    on e.codigo_usuario = u.codigo_usuario
join brechas_seguridad.brecha b
    on b.codigo_brecha = e.codigo_brecha
join brechas_seguridad.tipo_dato_expuesto t
    on t.id_tipo_dato = e.id_tipo_dato
join brechas_seguridad.organizacion o
    on o.id_organizacion = b.id_organizacion
where u.codigo_usuario = 'US-002823'
order by e.fecha_notificacion_usuario;


-- Indice de optimizacion
create index idx_exposicion_usuario_fecha
on brechas_seguridad.exposicion_usuario_brecha (
    codigo_usuario,
    fecha_notificacion_usuario
)
include (
    codigo_brecha,
    id_tipo_dato
);


-- Plan de ejecucion optimizado
explain (analyze, buffers)
select
    u.codigo_usuario,
    b.codigo_brecha,
    t.nombre_tipo_dato,
    t.categoria_sensibilidad,
    o.nombre_organizacion,
    e.fecha_notificacion_usuario
from brechas_seguridad.usuario_afectado u
join brechas_seguridad.exposicion_usuario_brecha e
    on e.codigo_usuario = u.codigo_usuario
join brechas_seguridad.brecha b
    on b.codigo_brecha = e.codigo_brecha
join brechas_seguridad.tipo_dato_expuesto t
    on t.id_tipo_dato = e.id_tipo_dato
join brechas_seguridad.organizacion o
    on o.id_organizacion = b.id_organizacion
where u.codigo_usuario = 'US-002823'
order by e.fecha_notificacion_usuario;
