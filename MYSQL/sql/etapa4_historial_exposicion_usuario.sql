-- ============================================================
-- Examen 02 - Topicos Avanzados de Base de Datos
-- Sebastian Quijano Jaramillo
-- ID SIGAA: 000547795
-- MySQL 8.4.9 - AWS RDS
-- ============================================================


-- Consulta funcional
SELECT
    u.codigo_usuario,
    b.codigo_brecha,
    t.nombre_tipo_dato,
    t.categoria_sensibilidad,
    o.nombre_organizacion,
    e.fecha_notificacion_usuario
FROM brechas_seguridad.usuario_afectado u
JOIN brechas_seguridad.exposicion_usuario_brecha e
    ON e.codigo_usuario = u.codigo_usuario
JOIN brechas_seguridad.brecha b
    ON b.codigo_brecha = e.codigo_brecha
JOIN brechas_seguridad.tipo_dato_expuesto t
    ON t.id_tipo_dato = e.id_tipo_dato
JOIN brechas_seguridad.organizacion o
    ON o.id_organizacion = b.id_organizacion
WHERE u.codigo_usuario = 'US-002823'
ORDER BY e.fecha_notificacion_usuario;


-- Plan de ejecucion inicial
EXPLAIN ANALYZE
SELECT
    u.codigo_usuario,
    b.codigo_brecha,
    t.nombre_tipo_dato,
    t.categoria_sensibilidad,
    o.nombre_organizacion,
    e.fecha_notificacion_usuario
FROM brechas_seguridad.usuario_afectado u
JOIN brechas_seguridad.exposicion_usuario_brecha e
    ON e.codigo_usuario = u.codigo_usuario
JOIN brechas_seguridad.brecha b
    ON b.codigo_brecha = e.codigo_brecha
JOIN brechas_seguridad.tipo_dato_expuesto t
    ON t.id_tipo_dato = e.id_tipo_dato
JOIN brechas_seguridad.organizacion o
    ON o.id_organizacion = b.id_organizacion
WHERE u.codigo_usuario = 'US-002823'
ORDER BY e.fecha_notificacion_usuario;


-- Indice de optimizacion
CREATE INDEX idx_exposicion_usuario_fecha
ON brechas_seguridad.exposicion_usuario_brecha (
    codigo_usuario,
    fecha_notificacion_usuario,
    codigo_brecha,
    id_tipo_dato
);


-- Plan de ejecucion optimizado
EXPLAIN ANALYZE
SELECT
    u.codigo_usuario,
    b.codigo_brecha,
    t.nombre_tipo_dato,
    t.categoria_sensibilidad,
    o.nombre_organizacion,
    e.fecha_notificacion_usuario
FROM brechas_seguridad.usuario_afectado u
JOIN brechas_seguridad.exposicion_usuario_brecha e
    ON e.codigo_usuario = u.codigo_usuario
JOIN brechas_seguridad.brecha b
    ON b.codigo_brecha = e.codigo_brecha
JOIN brechas_seguridad.tipo_dato_expuesto t
    ON t.id_tipo_dato = e.id_tipo_dato
JOIN brechas_seguridad.organizacion o
    ON o.id_organizacion = b.id_organizacion
WHERE u.codigo_usuario = 'US-002823'
ORDER BY e.fecha_notificacion_usuario;

