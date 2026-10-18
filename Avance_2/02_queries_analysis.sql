-- Q1: Contar vehículos por tipo
SELECT 
    vehicle_type,        -- el tipo de vehículo
    COUNT(*) AS cantidad -- cuántos hay de cada tipo
FROM vehicles            -- en la tabla vehículos
GROUP BY vehicle_type    -- agrupados por tipo
ORDER BY cantidad DESC;  -- de mayor a menor

EXPLAIN ANALYZE
SELECT 
    vehicle_type,
    COUNT(*) AS cantidad
FROM vehicles
GROUP BY vehicle_type
ORDER BY cantidad DESC;

-- Q2: Conductores con licencia próxima a vencer
SELECT 
    first_name, 
    last_name, 
    license_number, 
    license_expiry
FROM drivers
WHERE license_expiry < CURRENT_DATE + INTERVAL '30 days'
ORDER BY license_expiry;

EXPLAIN ANALYZE
SELECT 
    first_name, 
    last_name, 
    license_number, 
    license_expiry
FROM drivers
WHERE license_expiry < CURRENT_DATE + INTERVAL '30 days'
ORDER BY license_expiry;

-- Q3: Total de viajes por estado
-- Problema de negocio: Monitorear operaciones en curso

SELECT 
    status,
    COUNT(*) AS total_viajes
FROM trips
GROUP BY status
ORDER BY total_viajes DESC;

EXPLAIN ANALYZE
SELECT 
    status,
    COUNT(*) AS total_viajes
FROM trips
GROUP BY status
ORDER BY total_viajes DESC;

-- Q4: Total de entregas por ciudad destino (últimos 2 meses)
SELECT 
    r.destination_city,
    COUNT(d.delivery_id) AS total_entregas
FROM routes r
JOIN trips t ON t.route_id = r.route_id
JOIN deliveries d ON d.trip_id = t.trip_id
WHERE t.departure_datetime >= CURRENT_DATE - INTERVAL '2 months'
GROUP BY r.destination_city
ORDER BY total_entregas DESC;

EXPLAIN ANALYZE
SELECT 
    r.destination_city,
    COUNT(d.delivery_id) AS total_entregas
FROM routes r
JOIN trips t ON t.route_id = r.route_id
JOIN deliveries d ON d.trip_id = t.trip_id
WHERE t.departure_datetime >= CURRENT_DATE - INTERVAL '2 months'
GROUP BY r.destination_city
ORDER BY total_entregas DESC;

-- Q5: Conductores activos con viajes completados
SELECT 
    d.first_name,
    d.last_name,
    d.employee_code,
    COUNT(t.trip_id) AS total_viajes
FROM drivers d
LEFT JOIN trips t ON t.driver_id = d.driver_id
    AND t.status = 'completed'
WHERE d.status = 'active'
GROUP BY d.driver_id, d.first_name, d.last_name, d.employee_code
ORDER BY total_viajes DESC
LIMIT 10;

EXPLAIN ANALYZE
SELECT 
    d.first_name,
    d.last_name,
    d.employee_code,
    COUNT(t.trip_id) AS total_viajes
FROM drivers d
LEFT JOIN trips t ON t.driver_id = d.driver_id
    AND t.status = 'completed'
WHERE d.status = 'active'
GROUP BY d.driver_id, d.first_name, d.last_name, d.employee_code
ORDER BY total_viajes DESC
LIMIT 10;

-- Q6: Promedio de entregas por conductor (últimos 6 meses)
SELECT 
    d.first_name,
    d.last_name,
    COUNT(DISTINCT t.trip_id) AS total_viajes,
    COUNT(del.delivery_id) AS total_entregas,
    ROUND(COUNT(del.delivery_id)::decimal / 
          NULLIF(COUNT(DISTINCT t.trip_id), 0), 2) AS promedio_entregas_por_viaje
FROM drivers d
JOIN trips t ON t.driver_id = d.driver_id
JOIN deliveries del ON del.trip_id = t.trip_id
WHERE t.departure_datetime >= CURRENT_DATE - INTERVAL '6 months'
AND d.status = 'active'
GROUP BY d.driver_id, d.first_name, d.last_name
ORDER BY promedio_entregas_por_viaje DESC
LIMIT 10;

EXPLAIN ANALYZE
SELECT 
    d.first_name,
    d.last_name,
    COUNT(DISTINCT t.trip_id) AS total_viajes,
    COUNT(del.delivery_id) AS total_entregas,
    ROUND(COUNT(del.delivery_id)::decimal / 
          NULLIF(COUNT(DISTINCT t.trip_id), 0), 2) AS promedio_entregas_por_viaje
FROM drivers d
JOIN trips t ON t.driver_id = d.driver_id
JOIN deliveries del ON del.trip_id = t.trip_id
WHERE t.departure_datetime >= CURRENT_DATE - INTERVAL '6 months'
AND d.status = 'active'
GROUP BY d.driver_id, d.first_name, d.last_name
ORDER BY promedio_entregas_por_viaje DESC
LIMIT 10;

-- Q7: Rutas con mayor consumo de combustible por kilómetro
SELECT 
    r.route_code,
    r.origin_city,
    r.destination_city,
    r.distance_km,
    ROUND(AVG(t.fuel_consumed_liters), 2) AS promedio_combustible,
    ROUND(AVG(t.fuel_consumed_liters) / r.distance_km, 4) AS litros_por_km
FROM routes r
JOIN trips t ON t.route_id = r.route_id
GROUP BY r.route_id, r.route_code, r.origin_city, 
         r.destination_city, r.distance_km
ORDER BY litros_por_km DESC
LIMIT 10;

EXPLAIN ANALYZE
SELECT 
    r.route_code,
    r.origin_city,
    r.destination_city,
    r.distance_km,
    ROUND(AVG(t.fuel_consumed_liters), 2) AS promedio_combustible,
    ROUND(AVG(t.fuel_consumed_liters) / r.distance_km, 4) AS litros_por_km
FROM routes r
JOIN trips t ON t.route_id = r.route_id
GROUP BY r.route_id, r.route_code, r.origin_city, 
         r.destination_city, r.distance_km
ORDER BY litros_por_km DESC
LIMIT 10;

-- Q8: Entregas retrasadas por día de la semana
SELECT 
    CASE EXTRACT(DOW FROM scheduled_datetime)
        WHEN 0 THEN '1-Domingo'
        WHEN 1 THEN '2-Lunes'
        WHEN 2 THEN '3-Martes'
        WHEN 3 THEN '4-Miércoles'
        WHEN 4 THEN '5-Jueves'
        WHEN 5 THEN '6-Viernes'
        WHEN 6 THEN '7-Sábado'
    END AS dia_semana,
    COUNT(*) AS total_entregas,
    SUM(CASE WHEN delivered_datetime > scheduled_datetime 
        THEN 1 ELSE 0 END) AS entregas_retrasadas,
    ROUND(SUM(CASE WHEN delivered_datetime > scheduled_datetime 
        THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS porcentaje_retraso
FROM deliveries
WHERE scheduled_datetime IS NOT NULL 
AND delivered_datetime IS NOT NULL
GROUP BY EXTRACT(DOW FROM scheduled_datetime)
ORDER BY dia_semana;

EXPLAIN ANALYZE
SELECT 
    CASE EXTRACT(DOW FROM scheduled_datetime)
        WHEN 0 THEN '1-Domingo'
        WHEN 1 THEN '2-Lunes'
        WHEN 2 THEN '3-Martes'
        WHEN 3 THEN '4-Miércoles'
        WHEN 4 THEN '5-Jueves'
        WHEN 5 THEN '6-Viernes'
        WHEN 6 THEN '7-Sábado'
    END AS dia_semana,
    COUNT(*) AS total_entregas,
    SUM(CASE WHEN delivered_datetime > scheduled_datetime 
        THEN 1 ELSE 0 END) AS entregas_retrasadas,
    ROUND(SUM(CASE WHEN delivered_datetime > scheduled_datetime 
        THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2) AS porcentaje_retraso
FROM deliveries
WHERE scheduled_datetime IS NOT NULL 
AND delivered_datetime IS NOT NULL
GROUP BY EXTRACT(DOW FROM scheduled_datetime)
ORDER BY dia_semana;

-- Q9: Costo de mantenimiento por km recorrido (CTE)
WITH km_por_vehiculo AS (
    SELECT 
        t.vehicle_id,
        SUM(r.distance_km) AS total_km
    FROM trips t
    JOIN routes r ON r.route_id = t.route_id
    GROUP BY t.vehicle_id
),
costo_mantenimiento AS (
    SELECT 
        vehicle_id,
        SUM(cost) AS costo_total
    FROM maintenance
    GROUP BY vehicle_id
)
SELECT 
    v.vehicle_type,
    ROUND(AVG(km.total_km), 2) AS promedio_km,
    ROUND(AVG(cm.costo_total), 2) AS promedio_costo_mantenimiento,
    ROUND(AVG(cm.costo_total) / NULLIF(AVG(km.total_km), 0), 4) AS costo_por_km
FROM vehicles v
JOIN km_por_vehiculo km ON km.vehicle_id = v.vehicle_id
JOIN costo_mantenimiento cm ON cm.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_type
ORDER BY costo_por_km DESC;

EXPLAIN ANALYZE
WITH km_por_vehiculo AS (
    SELECT 
        t.vehicle_id,
        SUM(r.distance_km) AS total_km
    FROM trips t
    JOIN routes r ON r.route_id = t.route_id
    GROUP BY t.vehicle_id
),
costo_mantenimiento AS (
    SELECT 
        vehicle_id,
        SUM(cost) AS costo_total
    FROM maintenance
    GROUP BY vehicle_id
)
SELECT 
    v.vehicle_type,
    ROUND(AVG(km.total_km), 2) AS promedio_km,
    ROUND(AVG(cm.costo_total), 2) AS promedio_costo_mantenimiento,
    ROUND(AVG(cm.costo_total) / NULLIF(AVG(km.total_km), 0), 4) AS costo_por_km
FROM vehicles v
JOIN km_por_vehiculo km ON km.vehicle_id = v.vehicle_id
JOIN costo_mantenimiento cm ON cm.vehicle_id = v.vehicle_id
GROUP BY v.vehicle_type
ORDER BY costo_por_km DESC;

-- Q10: Ranking de conductores por eficiencia
WITH metricas_conductor AS (
    SELECT 
        d.driver_id,
        d.first_name,
        d.last_name,
        COUNT(DISTINCT t.trip_id) AS total_viajes,
        COUNT(del.delivery_id) AS total_entregas,
        ROUND(SUM(r.distance_km), 2) AS total_km,
        ROUND(SUM(t.fuel_consumed_liters), 2) AS total_combustible,
        ROUND(COUNT(del.delivery_id)::decimal / 
              NULLIF(SUM(t.fuel_consumed_liters), 0), 4) AS entregas_por_litro
    FROM drivers d
    JOIN trips t ON t.driver_id = d.driver_id
    JOIN routes r ON r.route_id = t.route_id
    JOIN deliveries del ON del.trip_id = t.trip_id
    WHERE d.status = 'active'
    GROUP BY d.driver_id, d.first_name, d.last_name
)
SELECT 
    RANK() OVER (ORDER BY entregas_por_litro DESC) AS ranking,
    first_name,
    last_name,
    total_viajes,
    total_entregas,
    total_km,
    entregas_por_litro
FROM metricas_conductor
ORDER BY ranking
LIMIT 10;

EXPLAIN ANALYZE
WITH metricas_conductor AS (
    SELECT 
        d.driver_id,
        d.first_name,
        d.last_name,
        COUNT(DISTINCT t.trip_id) AS total_viajes,
        COUNT(del.delivery_id) AS total_entregas,
        ROUND(SUM(r.distance_km), 2) AS total_km,
        ROUND(SUM(t.fuel_consumed_liters), 2) AS total_combustible,
        ROUND(COUNT(del.delivery_id)::decimal / 
              NULLIF(SUM(t.fuel_consumed_liters), 0), 4) AS entregas_por_litro
    FROM drivers d
    JOIN trips t ON t.driver_id = d.driver_id
    JOIN routes r ON r.route_id = t.route_id
    JOIN deliveries del ON del.trip_id = t.trip_id
    WHERE d.status = 'active'
    GROUP BY d.driver_id, d.first_name, d.last_name
)
SELECT 
    RANK() OVER (ORDER BY entregas_por_litro DESC) AS ranking,
    first_name,
    last_name,
    total_viajes,
    total_entregas,
    total_km,
    entregas_por_litro
FROM metricas_conductor
ORDER BY ranking
LIMIT 10;

-- Q11: Tendencia de viajes con LAG y LEAD
WITH viajes_por_mes AS (
    SELECT 
        DATE_TRUNC('month', departure_datetime) AS mes,
        COUNT(*) AS total_viajes
    FROM trips
    GROUP BY DATE_TRUNC('month', departure_datetime)
)
SELECT 
    TO_CHAR(mes, 'YYYY-MM') AS mes,
    total_viajes,
    LAG(total_viajes) OVER (ORDER BY mes) AS viajes_mes_anterior,
    LEAD(total_viajes) OVER (ORDER BY mes) AS viajes_mes_siguiente,
    ROUND(
        (total_viajes - LAG(total_viajes) OVER (ORDER BY mes))::decimal / 
        NULLIF(LAG(total_viajes) OVER (ORDER BY mes), 0) * 100, 2
    ) AS variacion_porcentual
FROM viajes_por_mes
ORDER BY mes;

EXPLAIN ANALYZE
WITH viajes_por_mes AS (
    SELECT 
        DATE_TRUNC('month', departure_datetime) AS mes,
        COUNT(*) AS total_viajes
    FROM trips
    GROUP BY DATE_TRUNC('month', departure_datetime)
)
SELECT 
    TO_CHAR(mes, 'YYYY-MM') AS mes,
    total_viajes,
    LAG(total_viajes) OVER (ORDER BY mes) AS viajes_mes_anterior,
    LEAD(total_viajes) OVER (ORDER BY mes) AS viajes_mes_siguiente,
    ROUND(
        (total_viajes - LAG(total_viajes) OVER (ORDER BY mes))::decimal / 
        NULLIF(LAG(total_viajes) OVER (ORDER BY mes), 0) * 100, 2
    ) AS variacion_porcentual
FROM viajes_por_mes
ORDER BY mes;

-- Q12: Distribución de entregas por hora y día (PIVOT)
SELECT 
    EXTRACT(HOUR FROM scheduled_datetime) AS hora,
    SUM(CASE WHEN EXTRACT(DOW FROM scheduled_datetime) = 1 
        THEN 1 ELSE 0 END) AS lunes,
    SUM(CASE WHEN EXTRACT(DOW FROM scheduled_datetime) = 2 
        THEN 1 ELSE 0 END) AS martes,
    SUM(CASE WHEN EXTRACT(DOW FROM scheduled_datetime) = 3 
        THEN 1 ELSE 0 END) AS miercoles,
    SUM(CASE WHEN EXTRACT(DOW FROM scheduled_datetime) = 4 
        THEN 1 ELSE 0 END) AS jueves,
    SUM(CASE WHEN EXTRACT(DOW FROM scheduled_datetime) = 5 
        THEN 1 ELSE 0 END) AS viernes,
    SUM(CASE WHEN EXTRACT(DOW FROM scheduled_datetime) = 6 
        THEN 1 ELSE 0 END) AS sabado,
    SUM(CASE WHEN EXTRACT(DOW FROM scheduled_datetime) = 0 
        THEN 1 ELSE 0 END) AS domingo,
    COUNT(*) AS total_hora
FROM deliveries
WHERE scheduled_datetime IS NOT NULL
GROUP BY EXTRACT(HOUR FROM scheduled_datetime)
ORDER BY hora;

EXPLAIN ANALYZE
SELECT 
    EXTRACT(HOUR FROM scheduled_datetime) AS hora,
    SUM(CASE WHEN EXTRACT(DOW FROM scheduled_datetime) = 1 
        THEN 1 ELSE 0 END) AS lunes,
    SUM(CASE WHEN EXTRACT(DOW FROM scheduled_datetime) = 2 
        THEN 1 ELSE 0 END) AS martes,
    SUM(CASE WHEN EXTRACT(DOW FROM scheduled_datetime) = 3 
        THEN 1 ELSE 0 END) AS miercoles,
    SUM(CASE WHEN EXTRACT(DOW FROM scheduled_datetime) = 4 
        THEN 1 ELSE 0 END) AS jueves,
    SUM(CASE WHEN EXTRACT(DOW FROM scheduled_datetime) = 5 
        THEN 1 ELSE 0 END) AS viernes,
    SUM(CASE WHEN EXTRACT(DOW FROM scheduled_datetime) = 6 
        THEN 1 ELSE 0 END) AS sabado,
    SUM(CASE WHEN EXTRACT(DOW FROM scheduled_datetime) = 0 
        THEN 1 ELSE 0 END) AS domingo,
    COUNT(*) AS total_hora
FROM deliveries
WHERE scheduled_datetime IS NOT NULL
GROUP BY EXTRACT(HOUR FROM scheduled_datetime)
ORDER BY hora;


