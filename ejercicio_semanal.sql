create database spotify ; 
use spotify

-- 1 . obtener los artistas con su fecha más reciente de estadísticas:
SELECT a.nombre, MAX(s.fecha) AS fecha_ultima_estadistica
FROM sp_artista a
JOIN sp_artista_estadisticas s ON a.artista_id = s.artista_id
GROUP BY a.nombre;

    
-- 2. Ver los artistas con la mayor caída en popularidad en el mes 2.
SELECT 
    sp_artista.artista_id, 
    sp_artista.nombre, 
    (e1.popularidad - e2.popularidad) AS caida_popularidad
FROM 
    sp_artista
JOIN 
    sp_artista_estadisticas e1 ON sp_artista.artista_id = e1.artista_id
JOIN 
    sp_artista_estadisticas e2 ON sp_artista.artista_id = e2.artista_id
WHERE 
    MONTH(STR_TO_DATE(e1.fecha, '%m-%d-%Y')) = 4  -- Filtra el mes 1 (abril)
    AND MONTH(STR_TO_DATE(e2.fecha, '%m-%d-%Y')) = 5  -- Filtra el mes 2 (mayo)
    AND YEAR(STR_TO_DATE(e1.fecha, '%m-%d-%Y')) = YEAR(STR_TO_DATE(e2.fecha, '%m-%d-%Y'))  
    AND e1.popularidad > e2.popularidad  
ORDER BY 
    caida_popularidad DESC;  


-- 3 Obtén los artistas con más de 1 millón de seguidores:
SELECT a.nombre, MAX(s.seguidores) AS max_seguidores
FROM sp_artista a
JOIN sp_artista_estadisticas s ON a.artista_id = s.artista_id
GROUP BY a.nombre
HAVING MAX(s.seguidores) > 10000;


-- 4 extrae 10 artistas y la fecha en que tuvieron su popularidad más alta:
SELECT a.nombre, s.fecha, MAX(s.popularidad) AS popularidad_maxima
FROM sp_artista a
JOIN sp_artista_estadisticas s ON a.artista_id = s.artista_id
GROUP BY a.nombre, s.fecha
ORDER BY popularidad_maxima DESC
LIMIT 10;


-- 5. 10 Artistas con el crecimiento promedio más lento
SELECT 
    a.artista_id, 
    a.nombre AS artista, 
    AVG(e.seguidores) AS seguidores_promedio,
    MAX(e.seguidores) - MIN(e.seguidores) AS crecimiento_total
FROM 
    sp_artista_estadisticas e
JOIN 
    sp_artista a ON a.artista_id = e.artista_id
GROUP BY 
    a.artista_id, a.nombre
ORDER BY 
    crecimiento_total ASC
LIMIT 10;

-- 6 Obtener el artista con más seguidores en el primer mes
SELECT 
    sp_artista.artista_id, 
    sp_artista.nombre, 
    MAX(sa.seguidores) AS max_seguidores_abril
FROM 
    sp_artista 
JOIN 
    sp_artista_estadisticas sa ON sp_artista.artista_id = sa.artista_id
WHERE 
    MONTH(STR_TO_DATE(sa.fecha, '%m-%d-%Y')) = 4  
GROUP BY 
    sp_artista.artista_id, sp_artista.nombre
ORDER BY 
    max_seguidores_abril DESC
LIMIT 1;


-- 7 Obtener el promedio de seguidores de todos los artistas en el mes mayo junio y julio 
SELECT 
    AVG(seguidores_totales) AS promedio_seguidores
FROM
    (
        SELECT 
            a.artista_id,
            SUM(e.seguidores) AS seguidores_totales
        FROM 
            sp_artista a
        JOIN 
            sp_artista_estadisticas e ON a.artista_id = e.artista_id
        WHERE 
            DATE_FORMAT(STR_TO_DATE(e.fecha, '%m-%d-%Y'), '%m') IN ('04', '05', '06')
        GROUP BY 
            a.artista_id
    ) AS artistas_seguidores;
    
    
    -- 8 ¿Cuál es la media de popularidad de todos los artistas?
    SELECT 
    AVG(sa.popularidad) AS media_popularidad
FROM 
    sp_artista_estadisticas sa;

-- 9 que artistas superan la media de seguidores?
WITH media_seguidores AS (
    SELECT 
        AVG(sa.seguidores) AS media_seguidores
    FROM 
        sp_artista_estadisticas sa
)

SELECT 
    a.artista_id,
    a.nombre,
    SUM(sa.seguidores) AS total_seguidores
FROM 
    sp_artista a
JOIN 
    sp_artista_estadisticas sa ON a.artista_id = sa.artista_id
GROUP BY 
    a.artista_id, a.nombre
HAVING 
    total_seguidores > (SELECT media_seguidores FROM media_seguidores);


-- 10 cual es el artista que mas ha evolucionado popularidad
SELECT 
    a.artista_id,
    a.nombre,
    (MAX(sa.popularidad) - MIN(sa.popularidad)) AS evolucion_popularidad
FROM 
    sp_artista a
JOIN 
    sp_artista_estadisticas sa ON a.artista_id = sa.artista_id
GROUP BY 
    a.artista_id, a.nombre
ORDER BY 
    evolucion_popularidad DESC
LIMIT 1;

