WITH pass_vehicle AS
 (SELECT id_operator,
         id_division,
         id_route,
         date_of,
         id_vehicle,
         COUNT(1) AS count_pass
  FROM   tmp$cptt_buffer_halfyear
  GROUP  BY date_of,
            id_operator,
            id_division,
            id_route,
            id_vehicle),
pass_route_day AS
 (SELECT id_operator,
         id_division,
         id_route,
         date_of,
         COUNT(DISTINCT id_vehicle) AS count_vehicle,
         AVG(count_pass) AS avg_pass_vehicle
  FROM   pass_vehicle
  GROUP  BY 
            id_operator,
            id_division,
            id_route,
            date_of),
pass_route_month AS
(
SELECT id_operator,
       id_division,
       id_route,
       LAST_DAY(date_of) as date_of,
       SUM(count_pass) AS sum_pass_month
  FROM   pass_vehicle
  GROUP  BY id_operator,
            id_division,
            id_route,
            LAST_DAY(date_of)
)
SELECT 1 AS ord,
       prm.id_operator,
       op.name as operator_name,
       id_division,
       div.name as division_name,
       id_route,
       date_of 
FROM pass_route_month prm
     INNER JOIN cptt.operator op
           ON prm.id_operator = op.id
     INNER JOIN cptt.division div
           ON prm.id_division = div.id 
           ORDER BY date_of
