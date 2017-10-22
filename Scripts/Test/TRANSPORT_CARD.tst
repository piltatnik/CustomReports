PL/SQL Developer Test script 3.0
120
BEGIN
  -- Test statements here
  OPEN :cur FOR
    WITH dates AS
     (SELECT LEVEL AS num,
             :pPassBeginDate + LEVEL - 1 AS begin_date
      FROM dual
      --START WITH pPassBeginDate < pPassEndDate
      CONNECT BY :pPassBeginDate + LEVEL - 1 < :pPassEndDate
      ORDER BY LEVEL),
    data AS
     (SELECT dates.num AS date_num,
             row_number() over(PARTITION BY dates.num ORDER BY cptt.tmp$trep_data.date_of) AS row_num,
             term.code AS term_code,
             vehicle.code AS vehicle_code,
             cptt.pkg$trep_reports.getCarrierPrefix(cptt.tmp$trep_data.id_route) ||
             route.code AS route_name,
             to_char(cptt.tmp$trep_data.date_of, 'HH24:MI:SS') AS time_pass
      FROM cptt.tmp$trep_data,
           dates,
           cptt.term,
           cptt.vehicle,
           cptt.route
      WHERE card_num = :pCardNum
      AND cptt.tmp$trep_data.date_of >= dates.begin_date
      AND cptt.tmp$trep_data.date_of < dates.begin_date + 1
      AND cptt.tmp$trep_data.id_term = term.id(+)
      AND cptt.tmp$trep_data.id_vehicle = vehicle.id
      AND cptt.tmp$trep_data.id_route = route.id),
    total AS
     (SELECT dates.num AS date_num,
             nvl(COUNT(data.date_num), 0) AS count_pass
      FROM dates,
           data
      WHERE dates.num = data.date_num(+)
      GROUP BY dates.num),
    total_row AS
     (SELECT :vSecondTabFirstRowNum + 1 + nvl(MAX(count_pass), 0) + 1 AS row_num
      FROM total),
    cols AS
     (SELECT LEVEL AS num FROM dual CONNECT BY LEVEL <= 4)
    --заголовок с датами
    SELECT :vSecondTabFirstRowNum AS row_num,
           cptt.pkg$trep_reports.getExcelColName(1 + (dates.num - 1) * 4 + 1) AS col_name,
           'с ' || to_date(begin_date, 'dd.mm.yyyy HH24:MI:SS') AS VALUE
    FROM dates
    --
    UNION ALL
    --подзаголовки
    SELECT :vSecondTabFirstRowNum + 1 AS row_num,
           cptt.pkg$trep_reports.getExcelColName(1 + (dates.num - 1) * 4 +
                                                 cols.num) AS col_name,
           CASE cols.num
             WHEN 1 THEN
              'Номер терминала'
             WHEN 2 THEN
              'Номер транспортного средства'
             WHEN 3 THEN
              'Маршрут'
             WHEN 4 THEN
              'Время'
           END AS VALUE
    FROM dates,
         cols
    --
    UNION ALL
    --Графа "Всего"
    SELECT :vSecondTabFirstRowNum AS row_num,
           cptt.pkg$trep_reports.getExcelColName(1 +
                                                 (ceil(:pPassEndDate -
                                                       :pPassBeginDate)) * 4 + 1) AS col_name,
           'Всего' AS VALUE
    FROM dual
    --
    UNION ALL
    --данные
    SELECT :vSecondTabFirstRowNum + 1 + data.row_num AS row_num,
           cptt.pkg$trep_reports.getExcelColName(1 +
                                                 (data.date_num - 1) * 4 +
                                                 cols.num) AS col_name,
           CASE cols.num
             WHEN 1 THEN
              data.term_code
             WHEN 2 THEN
              data.vehicle_code
             WHEN 3 THEN
              data.route_name
             WHEN 4 THEN
              data.time_pass
           END AS VALUE
    FROM data,
         cols
    --
    UNION ALL
    --строка Итого(заголовок)
    SELECT tr.row_num,
           'A' AS col_name,
           'Итого' AS VALUE
    FROM total_row tr
    --
    UNION ALL
    --Итого по дням
    SELECT tr.row_num,
           cptt.pkg$trep_reports.getExcelColName(1 +
                                                 (total.date_num - 1) * 4 + 4) AS col_name,
           to_char(total.count_pass) AS VALUE
    FROM total,
         total_row tr
    --
    UNION ALL
    --Всего
    SELECT tr.row_num,
           cptt.pkg$trep_reports.getExcelColName(1 +
                                                 (ceil(:pPassEndDate -
                                                       :pPassBeginDate)) * 4 + 1) AS col_name,
           to_char(nvl(SUM(count_pass), 0)) AS VALUE
    FROM total,
         total_row tr
    GROUP BY tr.row_num;
END;
7
cur
1
<Cursor>
116
pActivationBeginDate
1
16.02.2017
-12
pActivationEndDate
1
15.03.2017
-12
pPassBeginDate
1
01.03.2017 3:00:00
12
pPassEndDate
1
01.04.2017 3:00:00
12
pCardNum
1
150004292
3
vSecondTabFirstRowNum
1
9
3
0
