-- Examen 02 - Topicos Avanzados de Base de Datos
-- Etapa 3 - Brechas criticas del ultimo ano
-- Samuel Parra Cadavid
-- ID SIGAA: 000551191
-- PostgreSQL 18.x

-- Consulta base
select
    o.nombre_organizacion,
    b.codigo_brecha,
    b.fecha_deteccion,
    b.vector_ataque,
    count(distinct e.codigo_usuario) as usuarios_afectados
from brechas_seguridad.brecha b
join brechas_seguridad.organizacion o
    on o.id_organizacion = b.id_organizacion
join brechas_seguridad.exposicion_usuario_brecha e
    on e.codigo_brecha = b.codigo_brecha
where b.fecha_deteccion >= (
    select max(fecha_deteccion) - interval '1 year'
    from brechas_seguridad.brecha
)
and b.severidad_incidente in ('Alta', 'Critica')
and exists (
    select 1
    from brechas_seguridad.exposicion_usuario_brecha e_critica
    join brechas_seguridad.tipo_dato_expuesto t_critico
        on t_critico.id_tipo_dato = e_critica.id_tipo_dato
    where e_critica.codigo_brecha = b.codigo_brecha
      and t_critico.categoria_sensibilidad = 'Critica'
)
group by
    o.nombre_organizacion,
    b.codigo_brecha,
    b.fecha_deteccion,
    b.vector_ataque
order by usuarios_afectados desc;

-- Plan de ejecucion inicial
explain (analyze, buffers)
select
    o.nombre_organizacion,
    b.codigo_brecha,
    b.fecha_deteccion,
    b.vector_ataque,
    count(distinct e.codigo_usuario) as usuarios_afectados
from brechas_seguridad.brecha b
join brechas_seguridad.organizacion o
    on o.id_organizacion = b.id_organizacion
join brechas_seguridad.exposicion_usuario_brecha e
    on e.codigo_brecha = b.codigo_brecha
where b.fecha_deteccion >= (
    select max(fecha_deteccion) - interval '1 year'
    from brechas_seguridad.brecha
)
and b.severidad_incidente in ('Alta', 'Critica')
and exists (
    select 1
    from brechas_seguridad.exposicion_usuario_brecha e_critica
    join brechas_seguridad.tipo_dato_expuesto t_critico
        on t_critico.id_tipo_dato = e_critica.id_tipo_dato
    where e_critica.codigo_brecha = b.codigo_brecha
      and t_critico.categoria_sensibilidad = 'Critica'
)
group by
    o.nombre_organizacion,
    b.codigo_brecha,
    b.fecha_deteccion,
    b.vector_ataque
order by usuarios_afectados desc;

-- Mejora 1
create index idx_brecha_fecha_severidad
on brechas_seguridad.brecha (
    fecha_deteccion,
    severidad_incidente
);

-- Plan despues del primer indice
explain (analyze, buffers)
select
    o.nombre_organizacion,
    b.codigo_brecha,
    b.fecha_deteccion,
    b.vector_ataque,
    count(distinct e.codigo_usuario) as usuarios_afectados
from brechas_seguridad.brecha b
join brechas_seguridad.organizacion o
    on o.id_organizacion = b.id_organizacion
join brechas_seguridad.exposicion_usuario_brecha e
    on e.codigo_brecha = b.codigo_brecha
where b.fecha_deteccion >= (
    select max(fecha_deteccion) - interval '1 year'
    from brechas_seguridad.brecha
)
and b.severidad_incidente in ('Alta', 'Critica')
and exists (
    select 1
    from brechas_seguridad.exposicion_usuario_brecha e_critica
    join brechas_seguridad.tipo_dato_expuesto t_critico
        on t_critico.id_tipo_dato = e_critica.id_tipo_dato
    where e_critica.codigo_brecha = b.codigo_brecha
      and t_critico.categoria_sensibilidad = 'Critica'
)
group by
    o.nombre_organizacion,
    b.codigo_brecha,
    b.fecha_deteccion,
    b.vector_ataque
order by usuarios_afectados desc;

-- Mejora 2
create index idx_exposicion_brecha_tipo_usuario
on brechas_seguridad.exposicion_usuario_brecha (
    codigo_brecha,
    id_tipo_dato,
    codigo_usuario
);

-- Plan final con los dos indices
explain (analyze, buffers)
select
    o.nombre_organizacion,
    b.codigo_brecha,
    b.fecha_deteccion,
    b.vector_ataque,
    count(distinct e.codigo_usuario) as usuarios_afectados
from brechas_seguridad.brecha b
join brechas_seguridad.organizacion o
    on o.id_organizacion = b.id_organizacion
join brechas_seguridad.exposicion_usuario_brecha e
    on e.codigo_brecha = b.codigo_brecha
where b.fecha_deteccion >= (
    select max(fecha_deteccion) - interval '1 year'
    from brechas_seguridad.brecha
)
and b.severidad_incidente in ('Alta', 'Critica')
and exists (
    select 1
    from brechas_seguridad.exposicion_usuario_brecha e_critica
    join brechas_seguridad.tipo_dato_expuesto t_critico
        on t_critico.id_tipo_dato = e_critica.id_tipo_dato
    where e_critica.codigo_brecha = b.codigo_brecha
      and t_critico.categoria_sensibilidad = 'Critica'
)
group by
    o.nombre_organizacion,
    b.codigo_brecha,
    b.fecha_deteccion,
    b.vector_ataque
order by usuarios_afectados desc;
