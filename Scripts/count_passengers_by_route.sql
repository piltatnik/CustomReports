WITH calc AS
 (SELECT id_route,
         id_operator,
         id_division,
         1 AS ord,
         date_of,
         COUNT(DISTINCT id_vehicle) AS count_vehicle,
         COUNT(1) AS count_pass,
         ROW_NUMBER() OVER(PARTITION BY id_route ORDER BY id_operator, id_division, date_of) AS route_rn,
         ROW_NUMBER() OVER(PARTITION BY id_route, id_operator, id_division ORDER BY date_of) AS org_rn,
         ROW_NUMBER() OVER(PARTITION BY id_route, id_operator, id_division, LAST_DAY(date_of) ORDER BY date_of) AS month_rn
  FROM   tmp$cptt_buffer_halfyear
  GROUP  BY id_route,
            id_operator,
            id_division,
            date_of
  UNION ALL
  SELECT id_route,
         id_operator,
         id_division,
         2 AS ord,
         LAST_DAY(date_of) AS date_of,
         NULL AS count_vehicle,
         COUNT(1) AS count_pass,
         NULL AS route_rn,
         NULL AS org_rn,
         NULL AS month_rn
  FROM   tmp$cptt_buffer_halfyear
  GROUP  BY id_route,
            id_operator,
            id_division,
            LAST_DAY(date_of)),
pre_show as
(SELECT decode(calc.id_operator,
                     400246845,
                     'Т',
                     500246845,
                     'А',
                     16100246845,
                     'М',
                     'UNKNOWN') || r.code AS route_code,
       nvl(div.name,op.name) AS org_name,
       calc.ord,
       calc.date_of,
       calc.count_vehicle,
       calc.count_pass,
       route_rn,
       org_rn,
       month_rn
FROM   calc
INNER  JOIN route r
ON     calc.id_route = r.id
INNER  JOIN operator op
ON     calc.id_operator = op.id
LEFT   JOIN division div
ON     calc.id_division = div.id
)
SELECT decode(ps.route_rn, 1, ps.route_code, NULL) as "Маршрут", 
       decode(ps.org_rn, 1, ps.org_name, NULL) AS "Организация",
       CASE WHEN ord = 2 THEN 'Итого за месяц:'
            WHEN ps.month_rn = 1 THEN to_char(date_of, 'Month')
            ELSE NULL
       END AS "Месяц",
       decode(ord, 1, ps.date_of, null) as "Дата",
       ps.count_vehicle AS "Кол-во машин на маршруте",
       ps.count_pass AS "Кол-во перевезенных пассажиров"
FROM pre_show ps
ORDER  BY ps.route_code,
          ps.org_name,
          ps.date_of,
          ps.ord
