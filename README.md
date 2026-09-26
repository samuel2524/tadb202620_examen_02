# tadb202620_examen_02

Repositorio del Examen 2 de Tópicos Avanzados de Base de Datos, periodo 202620. El proyecto analiza brechas de seguridad y exposición de datos mediante un mismo modelo relacional implementado en PostgreSQL y MySQL.

## Integrantes

| Integrante | ID SIGAA | Motor | GitHub |
| --- | ---: | --- | --- |
| Samuel Parra Cadavid | 000551191 | PostgreSQL 18.x | [samuel2524](https://github.com/samuel2524) |
| Sebastián Quijano Jaramillo | 000547795 | MySQL 8.4.9 - AWS RDS | [SebastianQuijanoj](https://github.com/SebastianQuijanoj) |

## Alcance

El repositorio contiene:

- Cuatro lotes CSV con 40.000 registros consolidados.
- Un diagrama relacional común para ambos motores.
- Implementaciones separadas para PostgreSQL y MySQL.
- Consultas de las Etapas 3 y 4 con sus respectivas mejoras de rendimiento.
- Planes de ejecución para comparar el comportamiento antes y después de las optimizaciones.
- Documentación y evidencias separadas por motor.

## Modelo relacional

El modelo normalizado contiene cinco tablas principales:

- `organizacion`
- `brecha`
- `usuario_afectado`
- `tipo_dato_expuesto`
- `exposicion_usuario_brecha`

La última tabla representa la relación entre una brecha, un usuario afectado y el tipo de dato expuesto.

## Estructura

```text
tadb202620_examen_02/
|-- datos/
|-- diagrama/
|-- postgresql/
|   |-- documentacion/
|   |-- sql/
|   `-- resultados/
|-- MYSQL/
|   |-- Documentacion/
|   |-- Resultados/
|   `-- sql/
|-- .gitignore
`-- README.md
```

## Datos

Los archivos de `datos/` deben cargarse en orden:

1. `sabana_brechas_seguridad_lote_1.csv`
2. `sabana_brechas_seguridad_lote_2.csv`
3. `sabana_brechas_seguridad_lote_3.csv`
4. `sabana_brechas_seguridad_lote_4.csv`

Cada archivo contiene encabezado y 10.000 filas. La configuración general de importación es:

- Formato: CSV.
- Codificación: UTF-8.
- Delimitador: coma.
- Primera fila como encabezado.
- Tabla destino: `staging_brechas`.
- Modo de carga en DBeaver: Append/Insert.

## PostgreSQL

### Requisitos

- PostgreSQL 18.x.
- DBeaver o un cliente compatible.
- Base de datos `examen02`.
- Usuario administrador para crear el rol y el esquema.

La contraseña del rol `samuel` debe configurarse fuera del repositorio desde DBeaver. Ninguna credencial debe almacenarse en los scripts.

### Implementación y carga

1. Abrir `postgresql/sql/implementacion_modelo_postgresql.sql`.
2. Ejecutar los bloques correspondientes para crear el rol, esquema, tablas normalizadas y `staging_brechas`.
3. Importar los cuatro CSV en `brechas_seguridad.staging_brechas`.
4. Confirmar que la tabla staging contiene 40.000 filas.
5. Cargar las cinco tablas normalizadas.
6. Validar conteos, duplicados, nulos, claves foráneas y calidad de datos.

### Etapa 3

El script `postgresql/sql/etapa3_consulta_brechas_criticas.sql` identifica las brechas del último año con severidad alta o crítica que expusieron al menos un tipo de dato crítico.

El script contiene la consulta funcional, el plan inicial, los índices evaluados y los planes posteriores.

### Etapa 4

El script `postgresql/sql/etapa4_historial_exposicion_usuario.sql` consulta el historial de exposición de un usuario, incluyendo brecha, tipo de dato, sensibilidad, organización y fecha de notificación en orden cronológico.

## MySQL

### Requisitos

- MySQL 8.4.9.
- Instancia MySQL Community desplegada en AWS RDS.
- DBeaver o un cliente compatible.
- Base de datos `brechas_seguridad`.
- Conectividad configurada hacia la instancia RDS por el puerto 3306.

### Implementación y carga

La implementación MySQL mantiene el mismo modelo relacional utilizado en PostgreSQL.

El script principal se encuentra en:

`MYSQL/sql/implementacion_modelo_mysql.sql`

Este script contiene la creación de las tablas:

- `organizacion`
- `brecha`
- `usuario_afectado`
- `tipo_dato_expuesto`
- `exposicion_usuario_brecha`
- `staging_brechas`

Después de realizar la carga y normalización de los datos se obtuvieron los siguientes conteos:

| Tabla | Registros |
| --- | ---: |
| `organizacion` | 60 |
| `brecha` | 800 |
| `usuario_afectado` | 7.887 |
| `tipo_dato_expuesto` | 10 |
| `exposicion_usuario_brecha` | 40.000 |
| `staging_brechas` | 40.000 |

### Etapa 3 - Brechas críticas del último año

El script:

`MYSQL/sql/etapa3_consulta_brechas_criticas.sql`

identifica las brechas del último año con severidad `Alta` o `Critica` que presentan exposición de al menos un tipo de dato con sensibilidad `Critica`.

La consulta utiliza `EXISTS` para verificar la existencia del dato crítico y `COUNT(DISTINCT codigo_usuario)` para determinar la cantidad de usuarios afectados.

Para analizar y mejorar el rendimiento se utilizaron planes `EXPLAIN ANALYZE` y se evaluaron dos índices:

```sql
idx_brecha_fecha_severidad
(fecha_deteccion, severidad_incidente)
```

```sql
idx_exposicion_brecha_tipo_usuario
(codigo_brecha, id_tipo_dato, codigo_usuario)
```

Los planes permiten comparar la consulta inicial con las ejecuciones posteriores a la incorporación de los índices.

### Etapa 4 - Historial de exposición de un usuario

El script:

`MYSQL/sql/etapa4_historial_exposicion_usuario.sql`

consulta el historial de exposición del usuario `US-002823`, mostrando:

- Código de usuario.
- Código de brecha.
- Tipo de dato expuesto.
- Categoría de sensibilidad.
- Organización.
- Fecha de notificación.

Los resultados se presentan cronológicamente mediante `fecha_notificacion_usuario`.

Para optimizar la consulta se implementó el índice compuesto:

```sql
idx_exposicion_usuario_fecha
(codigo_usuario, fecha_notificacion_usuario, codigo_brecha, id_tipo_dato)
```

El plan optimizado utiliza este índice como `Covering index lookup`, evitando el ordenamiento adicional que aparecía en el plan inicial.

## Entregables PostgreSQL

- Diagrama relacional: `diagrama/`.
- Scripts SQL: `postgresql/sql/`.
- Planes y resultados: `postgresql/resultados/`.
- Documentación: `postgresql/documentacion/`.

## Entregables MySQL

- Scripts SQL: `MYSQL/sql/`.
- Planes de ejecución y resultados: `MYSQL/Resultados/`.
- Documentación de infraestructura y conectividad: `MYSQL/Documentacion/`.
- Evidencia de interacción con IA: `MYSQL/Documentacion/`.

## Seguridad

- No se versionan contraseñas ni credenciales de AWS RDS.
- Las credenciales se configuran directamente en cada motor o cliente de base de datos.
- El acceso a la instancia MySQL de AWS RDS se controla mediante las reglas del grupo de seguridad.
- Los archivos sensibles y temporales se excluyen mediante `.gitignore`.
