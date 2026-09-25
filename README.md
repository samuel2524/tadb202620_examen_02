# tadb202620_examen_02

Repositorio del Examen 2 de Topicos Avanzados de Base de Datos, periodo 202620. El proyecto analiza brechas de seguridad y exposicion de datos mediante un mismo modelo relacional implementado en PostgreSQL y MySQL.

## Integrantes

| Integrante | ID SIGAA | Motor | GitHub |
|---|---:|---|---|
| Samuel Parra Cadavid | 000551191 | PostgreSQL 18.x | [samuel2524](https://github.com/samuel2524) |
| Pendiente de completar por el integrante MySQL | Pendiente | MySQL | Pendiente |

El integrante de MySQL debe completar sus datos en su propio commit antes de la entrega final.

## Alcance

El repositorio contiene:

- Cuatro lotes CSV con 40.000 registros consolidados.
- Un diagrama relacional comun para ambos motores.
- Implementaciones separadas para PostgreSQL y MySQL.
- Consultas de las Etapas 3 y 4 con sus mejoras de rendimiento.
- Documentacion y evidencias separadas por motor.

## Modelo relacional

El modelo normalizado contiene cinco tablas principales:

- `organizacion`
- `brecha`
- `usuario_afectado`
- `tipo_dato_expuesto`
- `exposicion_usuario_brecha`

La ultima tabla representa la relacion entre una brecha, un usuario afectado y el tipo de dato expuesto.

## Estructura

```text
tadb202620_examen_02/
|-- datos/
|-- diagrama/
|-- postgresql/
|   |-- documentacion/
|   |-- sql/
|   `-- resultados/
|-- mysql/
|   |-- documentacion/
|   |-- sql/
|   `-- resultados/
|-- .gitignore
`-- README.md
```

Las carpetas de MySQL se incorporaran mediante los commits del integrante responsable de ese motor.

## Datos

Los archivos de `datos/` deben cargarse en orden:

1. `sabana_brechas_seguridad_lote_1.csv`
2. `sabana_brechas_seguridad_lote_2.csv`
3. `sabana_brechas_seguridad_lote_3.csv`
4. `sabana_brechas_seguridad_lote_4.csv`

Cada archivo contiene encabezado y 10.000 filas. La configuracion de importacion es:

- Formato: CSV.
- Codificacion: UTF-8.
- Delimitador: coma.
- Primera fila como encabezado.
- Tabla destino en PostgreSQL: `brechas_seguridad.staging_brechas`.
- Modo de carga en DBeaver: Append/Insert.

## PostgreSQL

### Requisitos

- PostgreSQL 18.x.
- DBeaver o un cliente compatible.
- Base de datos `examen02`.
- Usuario administrador para crear el rol y el esquema.

La contrasena del rol `samuel` debe configurarse fuera del repositorio desde DBeaver. Ninguna credencial debe almacenarse en los scripts.

### Implementacion y carga

1. Abrir `postgresql/sql/implementacion_modelo_postgresql.sql`.
2. Ejecutar los bloques 1, 2 y 3 para crear el rol, el esquema, las tablas normalizadas y `staging_brechas`.
3. Importar los cuatro CSV en `brechas_seguridad.staging_brechas`, respetando el orden y la configuracion descritos anteriormente.
4. Confirmar que la tabla staging contiene 40.000 filas.
5. Ejecutar el bloque 4 para cargar las cinco tablas normalizadas.
6. Ejecutar el bloque 5 para validar conteos, duplicados, nulos, claves foraneas y calidad de datos.

Conteos esperados:

| Tabla | Registros |
|---|---:|
| `organizacion` | 60 |
| `brecha` | 800 |
| `usuario_afectado` | 7.887 |
| `tipo_dato_expuesto` | 10 |
| `exposicion_usuario_brecha` | 40.000 |

### Etapa 3

El script `postgresql/sql/etapa3_consulta_brechas_criticas.sql` identifica las brechas del ultimo ano con severidad alta o critica que expusieron al menos un tipo de dato critico. La condicion de sensibilidad se evalua con `EXISTS`, mientras el conteo incluye todos los usuarios distintos afectados por cada brecha.

El script contiene la consulta funcional, el plan inicial, los indices evaluados y los planes posteriores.

### Etapa 4

El script `postgresql/sql/etapa4_historial_exposicion_usuario.sql` consulta el historial de exposicion de un usuario, incluyendo brecha, tipo de dato, sensibilidad, organizacion y fecha de notificacion en orden cronologico.

## MySQL

La implementacion MySQL debe conservar el mismo modelo, relaciones y consultas funcionales. El integrante responsable debe agregar en `mysql/` sus scripts, resultados, documentacion y evidencias antes de la entrega final.

## Entregables PostgreSQL

- Diagrama relacional: `diagrama/`.
- Scripts SQL: `postgresql/sql/`.
- Planes y resultados: `postgresql/resultados/`.
- Documentacion de Etapas 3 y 4: `postgresql/documentacion/`.
- PDF de infraestructura: `postgresql/documentacion/Infraestructura_Samuel_Parra.pdf`.
- PDF de interaccion con IA: `postgresql/documentacion/Interaccion_IA.pdf`.

## Seguridad

- No se versionan contrasenas ni archivos de configuracion local.
- Las credenciales se configuran directamente en cada motor.
- Los archivos sensibles y temporales se excluyen mediante `.gitignore`.
