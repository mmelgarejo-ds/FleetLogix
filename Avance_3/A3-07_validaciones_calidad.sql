-- =====================================================
-- Queries que respaldan los filtros aplicados en el 
-- pipeline ETL (A3-05_etl_pipeline_estudiantes.py)
-- =====================================================

-- V1: Distribución por estado de entrega
-- Resultado: 400.001 registros, todos con status 'delivered'
SELECT delivery_status, COUNT(*) AS cantidad
FROM deliveries 
GROUP BY delivery_status 
ORDER BY COUNT(*) DESC;

-- V2: Entregas con tiempo negativo (delivered < scheduled)
-- Resultado: 177.134 registros en toda la base
SELECT COUNT(*) AS con_tiempo_negativo
FROM deliveries 
WHERE delivered_datetime < scheduled_datetime;

-- V3: Pesos fuera de rango (<=0 o >=10.000 kg)
-- Resultado: 0 registros fuera de rango
SELECT COUNT(*) AS fuera_de_rango
FROM deliveries 
WHERE package_weight_kg <= 0 OR package_weight_kg >= 10000;

-- V4: Registros con tiempo negativo en ventana ETL (últimos 2 meses)
-- Resultado: 14.995 registros filtrados
-- Esto explica: 33.900 extraídos - 14.995 filtrados = 18.905 cargados en Snowflake
SELECT COUNT(*) AS registros_tiempo_negativo_2meses
FROM deliveries
WHERE delivered_datetime < scheduled_datetime
AND delivered_datetime >= (
    SELECT MAX(delivered_datetime) - INTERVAL '2 months' 
    FROM deliveries
);