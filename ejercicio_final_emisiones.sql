-- 1. Combinación de datos de diferentes años Tareas:
-- A. Crea la base de datos y la tabla total.
create database emisiones
use emisiones;

CREATE TABLE emisiones_total AS
SELECT * FROM emisiones2020
where 1=0;

-- B. Inserta los datos de las tablas de los años 2020, 2021, 2022 y 2023 en la tabla total.
insert into emisiones_total select * from emisiones2020;
insert into emisiones_total select * from emisiones2021;
insert into emisiones_total select * from emisiones2022;
insert into emisiones_total select * from emisiones2023;

-- C. Verifica que todos los datos se han insertado correctamente, mostrando el número total de
-- registros y los años disponibles en la tabla.
select count(*), count(DISTINCT ANO) from emisiones_total;
select distinct ano from emisiones_total;


-- 2. Creación de la columna valor_dia: A. Añade la columna valor_dia a la tabla total.

alter table emisiones_total add valor_dia int;

-- B. Rellena esta columna con los valores de dia d01
update emisiones_total set valor_dia = D01;


-- 3. Añadir una columna fecha: A. Crea la columna fecha en la tabla total con formato YYYY-MM-DD

alter table emisiones_total add fecha date;

-- B. Actualiza la columna fecha con los valores correspondientes a cada mes y año
update emisiones_total
set fecha = STR_TO_DATE(CONCAT(ano, '-', mes), '%Y-%m');

UPDATE emisiones_total
SET fecha = STR_TO_DATE(CONCAT(ano, '-', mes, '-', 
    CASE 
        WHEN valor_dia < 1 OR valor_dia > 31 OR valor_dia IS NULL THEN 00
        ELSE valor_dia
    END), '%Y-%m-%d');

-- 4. Consultar estaciones y contaminantes disponibles: A. Muestra las estaciones y los contaminantes
-- únicos que existen en la tabla total

select distinct magnitud, estacion from emisiones_total;


-- 5. Filtrar datos por estación y contaminante
-- A. compara los valores diarios de contaminación entre las estaciones "Ramon y Cajal" y "Escuelas Aguirre"
-- durante el año 2020, calcula la diferencia entre los valores de ambas estaciones para cada fecha y
-- devuelve las columnas: fecha, valor de "Ramon y Cajal", valor de "Escuelas Aguirre" y la diferencia de
-- valores, filtrando solo los registros donde la magnitud sea 1 y el rango de fechas sea del 1 de
-- enero de 2020 al 31 de diciembre de 2020, ordenando los resultados por fecha.

select fecha, 
       sum(case when estacion = 'Ramon y Cajal' then valor_dia else null end) as Ramon_y_Cajal, 
       sum(case when estacion = 'Escuelas Aguirre' then valor_dia else null end) as Escuelas_Aguirre, 
       sum(case when estacion = 'Ramon y Cajal' then valor_dia else 0 end) - 
       sum(case when estacion = 'Escuelas Aguirre' then valor_dia else 0 end) as diferencia
from emisiones_total
where fecha between '2020-01-01' and '2020-12-31'
and magnitud = 1
group by fecha
order by fecha;


-- 6. Resumen descriptivo por contaminante (Magnitud)
-- A. Muestra el valor mínimo, máximo, promedio y la desviación estándar de los valores de contaminación para cada contaminante.

-- por dia
select magnitud, 
       min(valor_dia) as minimo, 
       max(valor_dia) as maximo, 
       avg(valor_dia) as promedio, 
       stddev(valor_dia) as desviacion_estandar
from emisiones_total
group by magnitud;


-- 7. Resumen descriptivo por estación:  A. Muestra el valor mínimo, máximo, promedio 
-- y la desviación estándar de los valores de contaminación para cada estación

select estacion, 
       min(valor_dia) as minimo, 
       max(valor_dia) as maximo, 
       avg(valor_dia) as promedio, 
       stddev(valor_dia) as desviacion_estandar
from emisiones_total
group by estacion;


-- 8. Calcular medias mensuales de contaminación: A. ¿Cómo podemos calcular el promedio mensual 
-- de valores por estación y año, transformando los números de los meses en palabras y 
-- agrupándolos además en trimestres?

select
    estacion, ano,
    case mes
        when 1 then 'enero'
        when 2 then 'febrero'
        when 3 then 'marzo'
        when 4 then 'abril'
        when 5 then 'mayo'
        when 6 then 'junio'
        when 7 then 'julio'
        when 8 then 'agosto'
        when 9 then 'septiembre'
        when 10 then 'octubre'
        when 11 then 'noviembre'
        when 12 then 'diciembre'
        else 'mes inválido'
    end as nombre_mes,
    case
        when mes between 1 and 3 then 'primer trimestre'
        when mes between 4 and 6 then 'segundo trimestre'
        when mes between 7 and 9 then 'tercer trimestre'
        when mes between 10 and 12 then 'cuarto trimestre'
        else 'trimestre inválido'
    end as trimestre,
    avg(valor_dia) as promedio_mensual
from emisiones_total
group by estacion, ano,  mes
ORDER BY ano, estacion, mes;

-- 9. Medias mensuales por estación con nombre largo: A. Muestra la media mensual de contaminación 
-- para estaciones con nombres largos (más de 10 caracteres), agrupado por estación, contaminante y mes.

SELECT
    estacion,
    magnitud,
    mes,
    AVG(valor_dia) AS media_mensual
FROM emisiones_total
WHERE LENGTH(estacion) > 10 -- Filtro de nombres largos (más de 10 caracteres)
GROUP BY estacion, magnitud, mes
ORDER BY estacion, magnitud, mes;


-- 10. Niveles de contaminación acumulados por estación y contaminante:
-- A. calcula la media anual de las emisiones (valor_dia) por estación y magnitud para cada año, y asigna un
-- ranking de emisiones dentro de cada año y magnitud, donde el primer lugar corresponde al valor más alto. 
-- Ordena los resultados por año, magnitud y ranking de emisiones.

SELECT estacion,
		magnitud,
		ano, 
       AVG(valor_dia) AS media_anual, 
       RANK() OVER (PARTITION BY ano, magnitud ORDER BY AVG(valor_dia) DESC) AS ranking_emisiones
FROM emisiones_total
GROUP BY ano, magnitud, estacion
ORDER BY ano, magnitud, ranking_emisiones;


-- 11. Promedio acumulado de emisiones por estación: A. ¿Cómo podemos calcular el promedio acumulado anual y el 
-- promedio acumulado total  de emisiones por estación a lo largo de los años?

SELECT
    estacion,
    ano,
    AVG(valor_dia) AS promedio_anual,
    SUM(AVG(valor_dia)) OVER (PARTITION BY estacion ORDER BY ano) AS promedio_acumulado_anual,
    SUM(AVG(valor_dia)) OVER (PARTITION BY estacion) AS promedio_acumulado_total
FROM emisiones_total
GROUP BY estacion, ano;


-- 12. Días con datos de contaminación por estación y mes:
-- A. Muestra el número de días con datos de contaminación registrados por estación y nombre del mes
SELECT
    estacion,
    CASE
        WHEN mes = 1 THEN 'Enero'
        WHEN mes = 2 THEN 'Febrero'
        WHEN mes = 3 THEN 'Marzo'
        WHEN mes = 4 THEN 'Abril'
        WHEN mes = 5 THEN 'Mayo'
        WHEN mes = 6 THEN 'Junio'
        WHEN mes = 7 THEN 'Julio'
        WHEN mes = 8 THEN 'Agosto'
        WHEN mes = 9 THEN 'Septiembre'
        WHEN mes = 10 THEN 'Octubre'
        WHEN mes = 11 THEN 'Noviembre'
        WHEN mes = 12 THEN 'Diciembre'
    END AS nombre_mes,
    COUNT(valor_dia) AS dias_con_datos
FROM emisiones_total
WHERE valor_dia IS NOT NULL
GROUP BY estacion, mes
ORDER BY estacion, mes;


-- 13. Días transcurridos desde la última medición por estación:
-- A. ¿Cómo podemos identificar la última fecha de registro de datos para cada estación y calcular el
-- número de días transcurridos desde esa fecha hasta hoy?
SELECT
    estacion,
    MAX(fecha) AS ultima_fecha,
    DATEDIFF(CURRENT_DATE, MAX(fecha)) AS dias_transcurridos
FROM emisiones_total
WHERE valor_dia IS NOT NULL -- verifico datos válidos
GROUP BY estacion
ORDER BY estacion;

-- 14. Variación de contaminación entre días anteriores y posteriores:
-- A. Muestra cómo varió la contaminación de cada estación y contaminante en comparación con el día
-- anterior y el día siguiente, y también muestra el primer y último valor registrado de cada estación y
-- contaminante durante el año.

SELECT estacion, 
       magnitud, 
       fecha, 
       valor_dia AS valor_actual,
       LAG(valor_dia) OVER (PARTITION BY estacion, magnitud ORDER BY fecha) AS valor_dia_anterior,
       LEAD(valor_dia) OVER (PARTITION BY estacion, magnitud ORDER BY fecha) AS valor_dia_siguiente,
       valor_dia - LAG(valor_dia) OVER (PARTITION BY estacion, magnitud ORDER BY fecha) AS variacion_anterior,
       LEAD(valor_dia) OVER (PARTITION BY estacion, magnitud ORDER BY fecha) - valor_dia AS variacion_siguiente
FROM emisiones_total
ORDER BY estacion, magnitud, fecha;

