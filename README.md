# FleetLogix — Infraestructura de Datos para Logística de Última Milla

Diseño e implementación end-to-end de la infraestructura de datos de una empresa de logística ficticia (200 vehículos, operación en 5 ciudades de Colombia), desde el modelo relacional hasta una arquitectura cloud. Módulo 2 — Soy Henry Data Science AI.

## Problema de negocio

FleetLogix necesita centralizar y analizar la operación de su flota —vehículos, conductores, rutas, viajes y entregas— para detectar problemas de puntualidad y cumplimiento, optimizar las consultas analíticas que soportan esas decisiones, y migrar esa infraestructura a la nube.

## Pipeline — 4 etapas, cada una sobre la anterior

| Etapa | Contenido |
|---|---|
| 1 — Modelo relacional y generación de datos | PostgreSQL con 6 tablas interrelacionadas · generación sintética con Faker (locale colombiano, seed fija) · 505.569 registros · 5 validaciones de integridad |
| 2 — Análisis y optimización SQL | 12 queries de negocio en 3 niveles de complejidad · 5 índices de optimización con mejoras de hasta 51% (medido con `EXPLAIN ANALYZE`) |
| 3 — Data Warehouse en Snowflake | Modelo estrella (`fact_deliveries` + 7 dimensiones) · pipeline ETL que calcula 8 métricas nuevas · filtrado de calidad y optimización de carga |
| 4 — Arquitectura cloud en AWS | Diseño con API Gateway, Lambda, DynamoDB, S3 y RDS para operación en tiempo real (diseño técnico, no desplegado) |

## Dataset

- 505.569 registros sintéticos — 2 años de operación histórica
- 200 vehículos · 400 conductores · 48 rutas · 100.000 viajes · 400.001 entregas · 4.920 mantenimientos
- Generado con Faker (`es_CO`) y seed fija para reproducibilidad; incluye distribución horaria realista, ocupación variable de vehículos y una tasa deliberada de entregas tardías para que el análisis de puntualidad tenga sentido

## Hallazgos clave

- **Cumplimiento:** un conductor opera con licencia vencida desde el 22/05/2026
- **Puntualidad:** 54% de retrasos *todos los días sin excepción* — indica un problema estructural, no situacional
- **Eficiencia de ruta:** Bogotá–Barranquilla es la ruta menos eficiente en consumo de combustible (0,116 l/km)
- **Performance SQL:** 5 índices nuevos redujeron el tiempo de ejecución hasta 51%
- **Calidad de datos en el ETL:** de 33.900 registros extraídos, 18.905 pasaron los filtros de calidad (se descartaron 14.995 por inconsistencias temporales que habrían distorsionado el análisis)
- **Troubleshooting de performance:** la carga de clientes por `MERGE` fila por fila generaba timeout con 17.000 registros; se resolvió migrando a carga en batch, bajando el tiempo de minutos a segundos

## Arquitectura cloud (diseño)

```
App del conductor → API Gateway → Lambda (verificación de entregas, cálculo de ETA, detección de desvíos)
                                      ├── DynamoDB   (estado en tiempo real de entregas y posiciones)
                                      ├── S3          (archivo histórico)
                                      └── RDS         (PostgreSQL administrado)
```

Diagrama completo en `Avance_4/aws_architecture_diagram.png`.

## Estructura del repositorio

| Carpeta | Contenido |
|---|---|
| `Avance_1/` | Schema SQL, script de generación de datos, diagrama ER |
| `Avance_2/` | Queries de análisis, script de índices de optimización |
| `Avance_3/` | Modelo dimensional (SQL), pipeline ETL a Snowflake |
| `Avance_4/` | Scripts de arquitectura AWS (`aws_setup.py`, `lambda_functions.py`), script de migración, diagrama de arquitectura |

## Stack

PostgreSQL · Python (psycopg2, Faker) · SQL · Snowflake (snowflake-connector-python) · pandas · NumPy · AWS — diseño (API Gateway, Lambda, DynamoDB, S3, RDS) · boto3 · draw.io

## Autor

Mauricio Melgarejo · [LinkedIn](https://linkedin.com/in/mauricio-daniel-melgarejo-amaro-482596105) · [GitHub](https://github.com/mmelgarejo-ds)
