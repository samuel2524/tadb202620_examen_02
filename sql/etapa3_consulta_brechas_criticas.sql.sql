-- ============================================================
-- Examen 02 - Topicos Avanzados de Base de Datos
-- Sebastian Quijano Jaramillo
-- ID SIGAA: 000547795
-- MySQL 8.4.9 - AWS RDS
-- ============================================================


-- ============================================================
-- CONSULTA BASE
-- ============================================================

SELECT
    o.nombre_organizacion,
    b.codigo_brecha,
    b.fecha_deteccion,
    b.vector_ataque,
    COUNT(DISTINCT e.codigo_usuario) AS usuarios_afectados
FROM brechas_seguridad.brecha b
JOIN brechas_seguridad.organizacion o
    ON o.id_organizacion = b.id_organizacion
JOIN brechas_seguridad.exposicion_usuario_brecha e
    ON e.codigo_brecha = b.codigo_brecha
WHERE b.fecha_deteccion >= (
    SELECT MAX(fecha_deteccion) - INTERVAL 1 YEAR
    FROM brechas_seguridad.brecha
)
AND b.severidad_incidente IN ('Alta', 'Critica')
AND EXISTS (
    SELECT 1
    FROM brechas_seguridad.exposicion_usuario_brecha e_critica
    JOIN brechas_seguridad.tipo_dato_expuesto t_critico
        ON t_critico.id_tipo_dato = e_critica.id_tipo_dato
    WHERE e_critica.codigo_brecha = b.codigo_brecha
      AND t_critico.categoria_sensibilidad = 'Critica'
)
GROUP BY
    o.nombre_organizacion,
    b.codigo_brecha,
    b.fecha_deteccion,
    b.vector_ataque
ORDER BY usuarios_afectados DESC;


-- ============================================================
-- PLAN DE EJECUCION INICIAL
-- ============================================================

EXPLAIN ANALYZE
SELECT
    o.nombre_organizacion,
    b.codigo_brecha,
    b.fecha_deteccion,
    b.vector_ataque,
    COUNT(DISTINCT e.codigo_usuario) AS usuarios_afectados
FROM brechas_seguridad.brecha b
JOIN brechas_seguridad.organizacion o
    ON o.id_organizacion = b.id_organizacion
JOIN brechas_seguridad.exposicion_usuario_brecha e
    ON e.codigo_brecha = b.codigo_brecha
WHERE b.fecha_deteccion >= (
    SELECT MAX(fecha_deteccion) - INTERVAL 1 YEAR
    FROM brechas_seguridad.brecha
)
AND b.severidad_incidente IN ('Alta', 'Critica')
AND EXISTS (
    SELECT 1
    FROM brechas_seguridad.exposicion_usuario_brecha e_critica
    JOIN brechas_seguridad.tipo_dato_expuesto t_critico
        ON t_critico.id_tipo_dato = e_critica.id_tipo_dato
    WHERE e_critica.codigo_brecha = b.codigo_brecha
      AND t_critico.categoria_sensibilidad = 'Critica'
)
GROUP BY
    o.nombre_organizacion,
    b.codigo_brecha,
    b.fecha_deteccion,
    b.vector_ataque
ORDER BY usuarios_afectados DESC;


-- ============================================================
-- MEJORA 1
-- Indice para fecha de deteccion y severidad
-- ============================================================

CREATE INDEX idx_brecha_fecha_severidad
ON brechas_seguridad.brecha (
    fecha_deteccion,
    severidad_incidente
);


-- ============================================================
-- PLAN DESPUES DEL PRIMER INDICE
-- ============================================================

EXPLAIN ANALYZE
SELECT
    o.nombre_organizacion,
    b.codigo_brecha,
    b.fecha_deteccion,
    b.vector_ataque,
    COUNT(DISTINCT e.codigo_usuario) AS usuarios_afectados
FROM brechas_seguridad.brecha b
JOIN brechas_seguridad.organizacion o
    ON o.id_organizacion = b.id_organizacion
JOIN brechas_seguridad.exposicion_usuario_brecha e
    ON e.codigo_brecha = b.codigo_brecha
WHERE b.fecha_deteccion >= (
    SELECT MAX(fecha_deteccion) - INTERVAL 1 YEAR
    FROM brechas_seguridad.brecha
)
AND b.severidad_incidente IN ('Alta', 'Critica')
AND EXISTS (
    SELECT 1
    FROM brechas_seguridad.exposicion_usuario_brecha e_critica
    JOIN brechas_seguridad.tipo_dato_expuesto t_critico
        ON t_critico.id_tipo_dato = e_critica.id_tipo_dato
    WHERE e_critica.codigo_brecha = b.codigo_brecha
      AND t_critico.categoria_sensibilidad = 'Critica'
)
GROUP BY
    o.nombre_organizacion,
    b.codigo_brecha,
    b.fecha_deteccion,
    b.vector_ataque
ORDER BY usuarios_afectados DESC;


-- ============================================================
-- MEJORA 2
-- Indice compuesto para las exposiciones
-- ============================================================

CREATE INDEX idx_exposicion_brecha_tipo_usuario
ON brechas_seguridad.exposicion_usuario_brecha (
    codigo_brecha,
    id_tipo_dato,
    codigo_usuario
);


-- ============================================================
-- PLAN FINAL CON LOS DOS INDICES
-- ============================================================

EXPLAIN ANALYZE
SELECT
    o.nombre_organizacion,
    b.codigo_brecha,
    b.fecha_deteccion,
    b.vector_ataque,
    COUNT(DISTINCT e.codigo_usuario) AS usuarios_afectados
FROM brechas_seguridad.brecha b
JOIN brechas_seguridad.organizacion o
    ON o.id_organizacion = b.id_organizacion
JOIN brechas_seguridad.exposicion_usuario_brecha e
    ON e.codigo_brecha = b.codigo_brecha
WHERE b.fecha_deteccion >= (
    SELECT MAX(fecha_deteccion) - INTERVAL 1 YEAR
    FROM brechas_seguridad.brecha
)
AND b.severidad_incidente IN ('Alta', 'Critica')
AND EXISTS (
    SELECT 1
    FROM brechas_seguridad.exposicion_usuario_brecha e_critica
    JOIN brechas_seguridad.tipo_dato_expuesto t_critico
        ON t_critico.id_tipo_dato = e_critica.id_tipo_dato
    WHERE e_critica.codigo_brecha = b.codigo_brecha
      AND t_critico.categoria_sensibilidad = 'Critica'
)
GROUP BY
    o.nombre_organizacion,
    b.codigo_brecha,
    b.fecha_deteccion,
    b.vector_ataque
ORDER BY usuarios_afectados DESC;

