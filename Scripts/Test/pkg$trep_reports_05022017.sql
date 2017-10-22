CREATE OR REPLACE PACKAGE pkg$trep_reports_2 IS

  -- Author  : PILARTSER
  -- Created : 29.01.2017 11:31:14
  -- Purpose : Транспортные отчеты(Рязань)
  PROCEDURE fillActivationSeriesPrivilege(pActivationBeginDate IN DATE,
                                          pActivationEndDate   IN DATE);

  PROCEDURE fillPassSeriesPrivilegeCarrier(pPassBeginDate IN DATE,
                                           pPassEndDate   IN DATE);

  PROCEDURE fillReportActivePassExcel(pActivationBeginDate IN DATE,
                                      pActivationEndDate   IN DATE,
                                      pPassBeginDAte       IN DATE,
                                      pPassEndDate         IN DATE);
  PROCEDURE fillReportPrivilegeExcel(pActivationBeginDate IN DATE,
                                     pActivationEndDate   IN DATE,
                                     pPassBeginDate       IN DATE,
                                     pPassEndDate         IN DATE);

END pkg$trep_reports_2;
/
CREATE OR REPLACE PACKAGE BODY pkg$trep_reports_2 IS

  CRLF VARCHAR2(3) := chr(10) || chr(13);
  --Заполнение активированных карт с группировкой по серии и привилегии
  PROCEDURE fillActivationSeriesPrivilege(pActivationBeginDate IN DATE,
                                          pActivationEndDate   IN DATE) AS
  BEGIN
    DELETE FROM TMP$TREP_ACTIVE_SERIESPRIV_2;
    INSERT INTO TMP$TREP_ACTIVE_SERIESPRIV_2
      (SERIES,
       ID_PRIVILEGE,
       COUNT_ACTIVE,
       SUM_ACTIVE)
      WITH trans_activation AS
       (SELECT trans.id,
               nvl(amount, 0) - nvl(amount_bail, 0) AS amount,
               CASE
                 WHEN nvl(trans.new_card_series, trans.card_series) IN
                      ('41', '44') THEN
                  '141'
                 WHEN nvl(trans.new_card_series, trans.card_series) IN
                      ('42', '45') THEN
                  '242'
                 WHEN nvl(trans.new_card_series, trans.card_series) IN
                      ('43', '46') THEN
                  '343'
                 ELSE
                  nvl(trans.new_card_series, trans.card_series)
               END AS series,
               decode(nvl(trans.new_card_series, trans.card_series),
                      '17',
                      trans.id_privilege,
                      NULL) AS id_privilege
        FROM cptt.t_data   trans,
             cptt.division div
        WHERE trans.kind IN (7, 8, 10, 11, 12, 13) --активация
        AND trans.d = 0 -- не удален
        AND trunc(trans.date_of) >= pActivationBeginDate --период активации
        AND trunc(trans.date_of) <= pActivationEndDate --
        AND trans.id_division = div.id --отбрасываем тестовых операторов
        AND div.id_operator NOT IN
              (2100246845, 2200246845, 4100246845, 600246845))
      SELECT series,
             id_privilege,
             nvl(COUNT(1), 0) AS count_active,
             nvl(SUM(amount), 0) AS sum_active
      FROM trans_activation
      GROUP BY series,
               id_privilege;
    COMMIT;
  END;

  --Заполнение проездов с группировкой по серии, привилегии и опреатору
  PROCEDURE fillPassSeriesPrivilegeCarrier(pPassBeginDate IN DATE,
                                           pPassEndDate   IN DATE) AS
  BEGIN
    DELETE FROM TMP$TREP_PASS_SERIESPRIVOPL_2;
    FOR rec IN (WITH carrier AS
                   (SELECT id AS id_operator
                   FROM operator
                   WHERE role = 1
                   AND id NOT IN (2200246845, 4100246845)),
                  trans_pass AS
                   (SELECT trans.id,
                          nvl(trans.amount, 0) - nvl(trans.amount_bail, 0) AS amount,
                          CASE
                            WHEN nvl(trans.new_card_series, trans.card_series) IN
                                 ('41', '44') THEN
                             '141'
                            WHEN nvl(trans.new_card_series, trans.card_series) IN
                                 ('42', '45') THEN
                             '242'
                            WHEN nvl(trans.new_card_series, trans.card_series) IN
                                 ('43', '46') THEN
                             '343'
                            ELSE
                             nvl(trans.new_card_series, trans.card_series)
                          END AS series,
                          decode(nvl(trans.new_card_series,
                                     trans.card_series),
                                 '17',
                                 trans.id_privilege,
                                 NULL) AS id_privilege,
                          carrier.id_operator
                   FROM cptt.t_data   trans,
                        cptt.division div,
                        carrier
                   WHERE trans.date_of >= pPassBeginDate
                   AND trans.date_of < pPassEndDate
                   AND trans.d = 0 -- не удален
                   AND trans.id_division = div.id
                   AND div.id_operator = carrier.id_operator
                   AND trans.kind IN ('32', '14', '17'))
                  SELECT series,
                         id_privilege,
                         id_operator,
                         nvl(COUNT(1), 0) AS count_pass,
                         nvl(SUM(amount), 0) AS sum_pass
                  FROM trans_pass
                  GROUP BY series,
                           id_privilege,
                           id_operator)
    LOOP
      INSERT INTO cptt.TMP$TREP_PASS_SERIESPRIVOPL_2
        (series,
         id_privilege,
         id_operator,
         count_pass,
         sum_pass)
      VALUES
        (rec.series,
         rec.id_privilege,
         rec.id_operator,
         rec.count_pass,
         rec.sum_pass);
    END LOOP;
    COMMIT;
  END;
  --Формирование отчета Инвестора-Оператора о количестве фактически совершенных поездок в транспортных средствах
  PROCEDURE fillReportActivePassExcel(pActivationBeginDate IN DATE,
                                      pActivationEndDate   IN DATE,
                                      pPassBeginDate       IN DATE,
                                      pPassEndDate         IN DATE) AS
    vCityPrivilegeCount     NUMBER;
    vRegionalPrivilegeCount NUMBER;
  BEGIN
    DELETE FROM cptt.TMP$TREP_REPORT_EXCEL_2;
    SELECT COUNT(1)
    INTO vCityPrivilegeCount
    FROM privilege
    WHERE code LIKE '000000__';
    SELECT COUNT(1)
    INTO vRegionalPrivilegeCount
    FROM privilege
    WHERE code LIKE '100000__';
  
    pkg$trep_reports_2.fillactivationseriesprivilege(pactivationbegindate,
                                                   pactivationenddate);
  
    FOR rec IN (WITH non_priv_primary AS
                   (SELECT DISTINCT nvl(ts.synthetic_series, ts.series) AS series,
                                   ts.id_pay_type,
                                   NULL AS id_privilege,
                                   NULL AS privilege_type
                   FROM cptt.ref$trep_series ts
                   WHERE series != '17'
                   OR series IS NULL),
                  non_priv_secondary AS
                   (SELECT series,
                          id_pay_type,
                          id_privilege,
                          privilege_type,
                          CASE
                            WHEN series IN
                                 ('24', '34', '14', '21', '31', '11') THEN
                             '      основная'
                            WHEN series IN
                                 ('25', '35', '15', '22', '32', '12') THEN
                             '      льготная'
                            WHEN series IN ('16', '13') THEN
                             '      бесплатная'
                            WHEN series IN ('29', '39', '19') THEN
                             '      граждане полные'
                            WHEN series IN ('242', '343', '141') THEN
                             '      организации'
                            WHEN series IS NULL THEN
                             'За наличные денежные средства,' || CRLF ||
                             'всего'
                            WHEN series IN ('96') THEN
                             'Карта VISA'
                            ELSE
                             ''
                          END AS row_name,
                          CASE
                            WHEN series IN ('24', '34') THEN
                             8
                            WHEN series IN ('14') THEN
                             11
                            WHEN series IN ('21', '31') THEN
                             16
                            WHEN series IN ('11') THEN
                             19
                            WHEN series IN ('25', '35') THEN
                             9
                            WHEN series IN ('15') THEN
                             12
                            WHEN series IN ('22', '32') THEN
                             17
                            WHEN series IN ('12') THEN
                             20
                            WHEN series IN ('16') THEN
                             13
                            WHEN series IN ('13') THEN
                             21
                            WHEN series IN ('29', '39') THEN
                             29 + vCityPrivilegeCount +
                             vRegionalPrivilegeCount
                            WHEN series IN ('19') THEN
                             33 + vCityPrivilegeCount +
                             vRegionalPrivilegeCount
                            WHEN series IN ('242', '343') THEN
                             31 + vCityPrivilegeCount +
                             vRegionalPrivilegeCount
                            WHEN series IN ('141') THEN
                             35 + vCityPrivilegeCount +
                             vRegionalPrivilegeCount
                            WHEN series IS NULL THEN
                             37 + vCityPrivilegeCount +
                             vRegionalPrivilegeCount
                            WHEN series IN ('96') THEN
                             38 + vCityPrivilegeCount +
                             vRegionalPrivilegeCount
                            ELSE
                             1
                          END AS row_num
                   FROM non_priv_primary),
                  city_priv AS
                   (SELECT '17' AS series,
                          1 AS id_pay_type,
                          id AS id_privilege,
                          'CITY_PRIVILEGE' AS privilege_type,
                          '      ' || lower(NAME) AS row_name,
                          23 + rownum AS row_num
                   FROM privilege
                   WHERE code LIKE '000000__'
                   ORDER BY id_privilege),
                  federal_priv AS
                   (SELECT '17' AS series,
                          1 AS id_pay_type,
                          id AS id_privilege,
                          'FEDERAL_PRIVILEGE' AS privilege_type,
                          '   ' || lower(NAME) AS row_name,
                          24 + vCityPrivilegeCount AS row_num
                   FROM privilege
                   WHERE code LIKE '200%'
                   ORDER BY id_privilege),
                  regional_priv AS
                   (SELECT '17' AS series,
                          1 AS id_pay_type,
                          id AS id_privilege,
                          'REGIONAL_PRIVILEGE' AS privilege_type,
                          '      ' || lower(NAME) AS row_name,
                          25 + vCityPrivilegeCount + rownum AS row_num
                   FROM privilege
                   WHERE code LIKE '100000__'
                   ORDER BY id_privilege),
                  all_priv AS
                   (SELECT series,
                          id_pay_type,
                          id_privilege,
                          privilege_type,
                          row_name,
                          row_num
                   FROM city_priv
                   UNION ALL
                   SELECT series,
                          id_pay_type,
                          id_privilege,
                          privilege_type,
                          row_name,
                          row_num
                   FROM regional_priv
                   UNION ALL
                   SELECT series,
                          id_pay_type,
                          id_privilege,
                          privilege_type,
                          row_name,
                          row_num
                   FROM federal_priv),
                  value_rows AS
                   (SELECT series,
                          id_privilege,
                          privilege_type,
                          row_name,
                          row_num
                   FROM non_priv_secondary
                   UNION ALL
                   SELECT series,
                          id_privilege,
                          privilege_type,
                          row_name,
                          row_num
                   FROM all_priv),
                  value_rows_distinct AS
                   (SELECT DISTINCT decode(series,
                                          NULL,
                                          '3.',
                                          '96',
                                          '4.',
                                          NULL) AS point,
                                   row_name,
                                   row_num
                   FROM value_rows
                   UNION ALL
                   SELECT NULL AS point,
                          '      граждане (на полмесяца)',
                          30 + vCityPrivilegeCount + vRegionalPrivilegeCount AS row_num
                   FROM dual
                   UNION ALL
                   SELECT NULL AS point,
                          '      граждане (на полмесяца)',
                          34 + vCityPrivilegeCount + vRegionalPrivilegeCount AS row_num
                   FROM dual),
                  group_rows_level_1 AS
                   (SELECT NULL AS point,
                          '   на 1 вид' AS row_name,
                          7 AS row_num,
                          '=SUM(' || listagg('C' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS c_column,
                          '=SUM(' || listagg('E' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS e_column,
                          '=SUM(' || listagg('F' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS f_column,
                          '=SUM(' || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(' || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column
                   FROM value_rows_distinct
                   WHERE row_num IN (8, 9)
                   UNION ALL
                   SELECT NULL AS point,
                          '   на 2 вида транспорта' AS row_name,
                          10 AS row_num,
                          '=SUM(' || listagg('C' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS c_column,
                          NULL AS e_column,
                          NULL AS f_column,
                          '=SUM(' || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(' || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column
                   FROM value_rows_distinct
                   WHERE row_num IN (11, 12, 13)
                   UNION ALL
                   SELECT NULL AS point,
                          '   на 1 вид' AS row_name,
                          15 AS row_num,
                          '=SUM(' || listagg('C' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS c_column,
                          '=SUM(' || listagg('E' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS e_column,
                          '=SUM(' || listagg('F' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS f_column,
                          '=SUM(' || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(' || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column
                   FROM value_rows_distinct
                   WHERE row_num IN (16, 17)
                   UNION ALL
                   SELECT NULL AS point,
                          '   на 2 вида транспорта' AS row_name,
                          18 AS row_num,
                          '=SUM(' || listagg('C' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS c_column,
                          NULL AS e_column,
                          NULL AS f_column,
                          '=SUM(' || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(' || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column
                   FROM value_rows_distinct
                   WHERE row_num IN (19, 20, 21)
                   UNION ALL
                   SELECT NULL AS point,
                          '   городские льготники' AS row_name,
                          23 AS row_num,
                          '=SUM(' || listagg('C' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS c_column,
                          NULL AS e_column,
                          NULL AS f_column,
                          '=SUM(' || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(' || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column
                   FROM value_rows_distinct
                   WHERE row_num BETWEEN 24 AND 23 + vCityPrivilegeCount
                   UNION ALL
                   SELECT NULL AS point,
                          '   региональные льготники' AS row_name,
                          25 + vCityPrivilegeCount AS row_num,
                          '=SUM(' || listagg('C' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS c_column,
                          NULL AS e_column,
                          NULL AS f_column,
                          '=SUM(' || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(' || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column
                   FROM value_rows_distinct
                   WHERE row_num BETWEEN 26 + vCityPrivilegeCount AND
                         25 + vCityPrivilegeCount + vRegionalPrivilegeCount
                   UNION ALL
                   SELECT NULL AS point,
                          '      на 1 вид в т.числе' AS row_name,
                          28 + vCityPrivilegeCount + vRegionalPrivilegeCount AS row_num,
                          '=SUM(' || listagg('C' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS c_column,
                          '=SUM(' || listagg('E' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS e_column,
                          '=SUM(' || listagg('F' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS f_column,
                          '=SUM(' || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(' || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column
                   FROM value_rows_distinct
                   WHERE row_num BETWEEN
                         29 + vCityPrivilegeCount + vRegionalPrivilegeCount AND
                         31 + vCityPrivilegeCount + vRegionalPrivilegeCount
                   UNION ALL
                   SELECT NULL AS point,
                          '      на 2 вида в т.числе' AS row_name,
                          32 + vCityPrivilegeCount + vRegionalPrivilegeCount AS row_num,
                          '=SUM(' || listagg('C' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS c_column,
                          NULL AS e_column,
                          NULL AS f_column,
                          '=SUM(' || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(' || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column
                   FROM value_rows_distinct
                   WHERE row_num BETWEEN
                         33 + vCityPrivilegeCount + vRegionalPrivilegeCount AND
                         35 + vCityPrivilegeCount + vRegionalPrivilegeCount),
                  group_rows_level_2 AS
                   (SELECT '1.1.' AS point,
                          'Транспортная карта "Школьная"' AS row_name,
                          6 AS row_num,
                          '=SUM(' || listagg('C' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS c_column,
                          NULL AS e_column,
                          NULL AS f_column,
                          '=SUM(' || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(' || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column
                   FROM group_rows_level_1
                   WHERE row_num IN (7, 10)
                   UNION ALL
                   SELECT '1.2.' AS point,
                          'Транспортная карта "Студенческая"' AS row_name,
                          14 AS row_num,
                          '=SUM(' || listagg('C' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS c_column,
                          NULL AS e_column,
                          NULL AS f_column,
                          '=SUM(' || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(' || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column
                   FROM group_rows_level_1
                   WHERE row_num IN (15, 18)
                   UNION ALL
                   SELECT '1.3.' AS point,
                          'Транспортная карта "Льготная"' AS row_name,
                          22 AS row_num,
                          '=SUM(C' || to_char(24 + vCityPrivilegeCount) || ',' ||
                          listagg('C' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS c_column,
                          NULL AS e_column,
                          NULL AS f_column,
                          '=SUM(H' || to_char(24 + vCityPrivilegeCount) || ',' ||
                          listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(I' || to_char(24 + vCityPrivilegeCount) || ',' ||
                          listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column
                   FROM group_rows_level_1
                   WHERE row_num IN (23, 25 + vCityPrivilegeCount)
                   UNION ALL
                   SELECT '2.1.' AS point,
                          'Проездной билет на месяц' || CRLF ||
                          '(пластиковая карта стандарт Mifare)' AS row_name,
                          27 + vCityPrivilegeCount + vRegionalPrivilegeCount AS row_num,
                          '=SUM(' || listagg('C' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS c_column,
                          NULL AS e_column,
                          NULL AS f_column,
                          '=SUM(' || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(' || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column
                   FROM group_rows_level_1
                   WHERE row_num IN
                         (28 + vCityPrivilegeCount + vRegionalPrivilegeCount,
                          32 + vCityPrivilegeCount + vRegionalPrivilegeCount)
                   UNION ALL
                   SELECT '2.2.' AS point,
                          'Транспортная карта стандарта Ultralight' || CRLF ||
                          ' (бесконтактная бумажная карта)' AS row_name,
                          36 + vCityPrivilegeCount + vRegionalPrivilegeCount AS row_num,
                          NULL AS c_column,
                          NULL AS e_column,
                          NULL AS f_column,
                          NULL AS h_column,
                          NULL AS i_column
                   FROM dual),
                  group_rows_level_3 AS
                   (SELECT '1.' AS point,
                          'Социальные персонализированные ' || CRLF ||
                          'транспортные карты, всего в том числе:' AS row_name,
                          5 AS row_num,
                          '=SUM(' || listagg('C' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS c_column,
                          NULL AS e_column,
                          NULL AS f_column,
                          '=SUM(' || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(' || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column
                   FROM group_rows_level_2
                   WHERE row_num IN (6, 14, 22)
                   UNION ALL
                   SELECT '2.' AS point,
                          'Транспортная карта "Городская", ' || CRLF ||
                          'в том числе:' AS row_name,
                          26 + vCityPrivilegeCount + vRegionalPrivilegeCount AS row_num,
                          '=SUM(' || listagg('C' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS c_column,
                          NULL AS e_column,
                          NULL AS f_column,
                          '=SUM(' || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(' || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column
                   FROM group_rows_level_2
                   WHERE row_num IN
                         (27 + vCityPrivilegeCount + vRegionalPrivilegeCount,
                          36 + vCityPrivilegeCount + vRegionalPrivilegeCount)),
                  row_formula_a_i AS
                   (SELECT point,
                          row_name,
                          row_num,
                          NULL     AS c_column,
                          NULL     AS e_column,
                          NULL     AS f_column,
                          NULL     AS h_column,
                          NULL     AS i_column
                   FROM value_rows_distinct
                   UNION ALL
                   SELECT point,
                          row_name,
                          row_num,
                          c_column,
                          e_column,
                          f_column,
                          h_column,
                          i_column
                   FROM group_rows_level_1
                   UNION ALL
                   SELECT point,
                          row_name,
                          row_num,
                          c_column,
                          e_column,
                          f_column,
                          h_column,
                          i_column
                   FROM group_rows_level_2
                   UNION ALL
                   SELECT point,
                          row_name,
                          row_num,
                          c_column,
                          e_column,
                          f_column,
                          h_column,
                          i_column
                   FROM group_rows_level_3),
                  trans_activation_row AS
                   (SELECT vr.series,
                          vr.row_num,
                          nvl(tas.count_active, 0) AS count_active,
                          nvl(tas.sum_active, 0) AS sum_active
                   FROM value_rows vr
                   LEFT OUTER JOIN cptt.TMP$TREP_ACTIVE_SERIESPRIV_2 tas
                   ON (vr.series = tas.series AND
                      (vr.id_privilege = tas.id_privilege OR
                      (vr.id_privilege IS NULL AND
                      tas.id_privilege IS NULL)))),
                  trans_pass_row AS
                   (SELECT vr.series,
                          vr.row_num,
                          tps.id_operator,
                          nvl(tps.count_pass, 0) AS count_pass,
                          nvl(tps.sum_pass, 0) AS sum_pass
                   FROM value_rows vr
                   LEFT OUTER JOIN cptt.TMP$TREP_PASS_SERIESPRIVOPL_2 tps
                   ON ((vr.series = tps.series OR
                      (vr.series IS NULL AND tps.series IS NULL)) AND
                      (vr.id_privilege = tps.id_privilege OR
                      (vr.id_privilege IS NULL AND
                      tps.id_privilege IS NULL)))),
                  lists AS
                   (SELECT 1 AS list_num
                   FROM dual
                   UNION ALL
                   SELECT 2 AS list_num
                   FROM dual
                   UNION ALL
                   SELECT 3 AS list_num
                   FROM dual),
                  --колонка A
                  col_a AS
                   (SELECT lists.list_num,
                          r.row_num,
                          'A' AS col_name,
                          r.point AS VALUE
                   FROM row_formula_a_i r,
                        lists
                   WHERE r.point IS NOT NULL),
                  --колонка B
                  col_b AS
                   (SELECT lists.list_num,
                          r.row_num,
                          'B' AS col_name,
                          r.row_name AS VALUE
                   FROM row_formula_a_i r,
                        lists),
                  --колонка C
                  col_c AS
                   (SELECT 1 AS list_num,
                          r.row_num,
                          'C' AS col_name,
                          r.c_column AS VALUE
                   FROM row_formula_a_i r
                   WHERE c_column IS NOT NULL
                   UNION ALL
                   SELECT 1 AS list_num,
                          tar.row_num,
                          'C' AS col_name,
                          to_char(tar.count_active) AS VALUE
                   FROM trans_activation_row tar
                   WHERE tar.series LIKE '1%'
                   OR tar.series IN '96'
                   OR tar.series IS NULL
                   UNION ALL
                   SELECT DISTINCT 1 AS list_num,
                                   row_num,
                                   'C' AS col_name,
                                   '=SUM(E' || row_num || ',F' || row_num || ')' AS VALUE
                   FROM value_rows
                   WHERE series LIKE '2%'
                   OR series LIKE '3%'),
                  --колонка E
                  col_e AS
                   (SELECT 1 AS list_num,
                          r.row_num,
                          'E' AS col_name,
                          r.e_column AS VALUE
                   FROM row_formula_a_i r
                   WHERE e_column IS NOT NULL
                   UNION ALL
                   SELECT 1 AS list_num,
                          tar.row_num,
                          'E' AS col_name,
                          to_char(tar.count_active) AS VALUE
                   FROM trans_activation_row tar
                   WHERE tar.series LIKE '3%'),
                  --колонка F
                  col_f AS
                   (SELECT 1 AS list_num,
                          r.row_num,
                          'F' AS col_name,
                          r.f_column AS VALUE
                   FROM row_formula_a_i r
                   WHERE f_column IS NOT NULL
                   UNION ALL
                   SELECT 1 AS list_num,
                          tar.row_num,
                          'F' AS col_name,
                          to_char(tar.count_active) AS VALUE
                   FROM trans_activation_row tar
                   WHERE tar.series LIKE '2%'),
                  --колонка H
                  col_h AS
                   (SELECT 1 AS list_num,
                          r.row_num,
                          'H' AS col_name,
                          r.h_column AS VALUE
                   FROM row_formula_a_i r
                   WHERE h_column IS NOT NULL
                   UNION ALL
                   SELECT 1 AS list_num,
                          tpr.row_num,
                          'H' AS col_name,
                          to_char(tpr.count_pass) AS VALUE
                   FROM trans_pass_row tpr
                   WHERE tpr.id_operator IN ('500246845')),
                  --колонка I
                  col_i AS
                   (SELECT 1 AS list_num,
                          r.row_num,
                          'I' AS col_name,
                          r.i_column AS VALUE
                   FROM row_formula_a_i r
                   WHERE i_column IS NOT NULL),
                  a_i_coord AS
                   (SELECT list_num,
                          row_num,
                          col_name,
                          VALUE
                   FROM col_a
                   UNION ALL
                   SELECT list_num,
                          row_num,
                          col_name,
                          VALUE
                   FROM col_b
                   UNION ALL
                   SELECT list_num,
                          row_num,
                          col_name,
                          VALUE
                   FROM col_c
                   UNION ALL
                   SELECT list_num,
                          row_num,
                          col_name,
                          VALUE
                   FROM col_e
                   UNION ALL
                   SELECT list_num,
                          row_num,
                          col_name,
                          VALUE
                   FROM col_f
                   UNION ALL
                   SELECT list_num,
                          row_num,
                          col_name,
                          VALUE
                   FROM col_h
                   UNION ALL
                   SELECT list_num,
                          row_num,
                          col_name,
                          VALUE
                   FROM col_i)
                  SELECT list_num,
                         row_num,
                         col_name,
                         VALUE
                  FROM a_i_coord
                  ORDER BY list_num,
                           row_num,
                           col_name)
    LOOP
      INSERT INTO cptt.TMP$TREP_REPORT_EXCEL_2
        (list_num,
         row_num,
         col_name,
         VALUE,
         debug_comment)
      VALUES
        (rec.list_num,
         rec.row_num,
         rec.col_name,
         rec.value,
         '');
    END LOOP;
  
    INSERT INTO cptt.TMP$TREP_REPORT_EXCEL_2
      (VALUE,
       list_num,
       row_num,
       col_name,
       debug_comment)
    VALUES
      ('Ежемесячный отчет Инвестора-Оператора о количестве фактически совершенных поездок в транспортных средствах Перевозчика за период с ' ||
       to_char(pPassBeginDate, 'dd.mm.yyyy (HH24:MI:SS)') || ' по ' ||
       to_char(pPassEndDate, 'dd.mm.yyyy  (HH24:MI:SS)'),
       1,
       1,
       'A',
       'Заголовок первого листа');
    INSERT INTO cptt.TMP$TREP_REPORT_EXCEL_2
      (VALUE,
       list_num,
       row_num,
       col_name,
       debug_comment)
    VALUES
      ('Ежемесячный отчет Инвестора-Оператора об активации/пополнении транспортных карт за период с ' ||
       to_char(pPassBeginDate, 'dd.mm.yyyy (HH24:MI:SS)') || ' по ' ||
       to_char(pPassEndDate, 'dd.mm.yyyy (HH24:MI:SS)'),
       2,
       1,
       'A',
       'Заголовок третьего листа');
    INSERT INTO cptt.TMP$TREP_REPORT_EXCEL_2
      (VALUE,
       list_num,
       row_num,
       col_name,
       debug_comment)
    VALUES
      ('Ежемесячный отчет Инвестора-Оператора об активации/пополнении транспортных карт за период с ' ||
       to_char(pPassBeginDate, 'dd.mm.yyyy (HH24:MI:SS)') || ' по ' ||
       to_char(pPassEndDate, 'dd.mm.yyyy (HH24:MI:SS)'),
       3,
       1,
       'A',
       'Заголовок первого листа');
    COMMIT;
  END;

  --устаревает на ходу
  /*  PROCEDURE fillReportActivePassExcel_Old(pActivationBeginDate IN DATE,
                                      pActivationEndDate   IN DATE,
                                      pPassBeginDate       IN DATE,
                                      pPassEndDate         IN DATE) AS
  BEGIN
    DELETE FROM cptt.TMP$TREP_REPORT_EXCEL_2;
    FOR rec_active_pass IN (WITH card AS
                               (SELECT DISTINCT nvl(ts.synthetic_series,
                                                   ts.series) AS series,
                                               ts.id_pay_type,
                                               ts.privilege_type
                               FROM cptt.ref$trep_series ts),
                              head AS
                               (SELECT id,
                                      series,
                                      pay_type.short_name AS pay_type,
                                      privilege_type,
                                      CASE
                                        WHEN series = '11' THEN
                                         19
                                        WHEN series = '12' THEN
                                         20
                                        WHEN series = '13' THEN
                                         21
                                        WHEN series = '14' THEN
                                         11
                                        WHEN series = '15' THEN
                                         12
                                        WHEN series = '16' THEN
                                         13
                                        WHEN series = '17' THEN
                                         CASE
                                           WHEN privilege_type =
                                                'CITY_PRIVILEGE' THEN
                                            23
                                           WHEN privilege_type =
                                                'REGIONAL_PRIVILEGE' THEN
                                            25
                                           WHEN privilege_type =
                                                'FEDERAL_PRIVILEGE' THEN
                                            24
                                           ELSE
                                            1
                                         END
                                        WHEN series = '19' THEN
                                         33
                                        WHEN series = '141' THEN
                                         35
                                        WHEN series = '21' THEN
                                         16
                                        WHEN series = '22' THEN
                                         17
                                        WHEN series = '24' THEN
                                         8
                                        WHEN series = '25' THEN
                                         9
                                        WHEN series = '29' THEN
                                         29
                                        WHEN series = '242' THEN
                                         31
                                        WHEN series = '31' THEN
                                         16
                                        WHEN series = '32' THEN
                                         17
                                        WHEN series = '34' THEN
                                         8
                                        WHEN series = '35' THEN
                                         9
                                        WHEN series = '39' THEN
                                         29
                                        WHEN series = '343' THEN
                                         31
                                        WHEN series = '96' THEN
                                         38
                                        WHEN series IS NULL THEN
                                         37
                                      END AS row_num
                               FROM card,
                                    cptt.ref$trep_pay_type pay_type
                               WHERE card.id_pay_type = pay_type.id),
                              priv_category AS
                               (SELECT id AS id_privilege,
                                      CASE
                                        WHEN code LIKE '000000__' THEN
                                         'CITY_PRIVILEGE'
                                        WHEN code LIKE '100000__' THEN
                                         'REGIONAL_PRIVILEGE'
                                        WHEN code LIKE '200%' THEN
                                         'FEDERAL_PRIVILEGE'
                                        ELSE
                                         NULL
                                      END AS privilege_type
                               FROM cptt.privilege),
                              trans_active AS
                               (SELECT trans.id,
                                      nvl(amount, 0) - nvl(amount_bail, 0) AS amount,
                                      CASE
                                        WHEN nvl(trans.new_card_series,
                                                 trans.card_series) IN
                                             ('41', '44') THEN
                                         '141'
                                        WHEN nvl(trans.new_card_series,
                                                 trans.card_series) IN
                                             ('42', '45') THEN
                                         '242'
                                        WHEN nvl(trans.new_card_series,
                                                 trans.card_series) IN
                                             ('43', '46') THEN
                                         '343'
                                        ELSE
                                         nvl(trans.new_card_series,
                                             trans.card_series)
                                      END AS series,
                                      priv_category.privilege_type
                               FROM cptt.t_data   trans,
                                    cptt.division div,
                                    priv_category
                               WHERE trans.kind IN (7, 8, 10, 11, 12, 13) --активация
                               AND trans.d = 0 -- не удален
                               AND trunc(trans.date_of) >=
                                     pActivationBeginDate --период активации
                               AND trunc(trans.date_of) <= pActivationEndDate --
                               AND trans.id_division = div.id --отбрасываем тестовых операторов
                               AND div.id_operator NOT IN
                                     (2100246845,
                                      2200246845,
                                      4100246845,
                                      600246845)
                               AND trans.id_privilege =
                                     priv_category.id_privilege(+)),
                              trans_active_counted AS
                               (SELECT nvl(series, 'null') AS series,
                                      nvl(privilege_type, 'null') AS privilege_type,
                                      COUNT(1) AS count_active,
                                      SUM(amount) AS sum_active
                               FROM trans_active
                               GROUP BY series,
                                        privilege_type),
                              trans_active_head AS
                               (SELECT head.series,
                                      head.pay_type,
                                      head.privilege_type,
                                      nvl(trans_active_counted.count_active,
                                          0) AS count_active,
                                      trans_active_counted.sum_active,
                                      head.row_num
                               FROM head,
                                    trans_active_counted
                               WHERE head.series =
                                     trans_active_counted.series(+)
                               AND nvl(head.privilege_type, 'null') =
                                     trans_active_counted.privilege_type(+)),
                              trans_active_coord AS
                               (
                               --Количество активаций
                               SELECT series,
                                       pay_type,
                                       privilege_type,
                                       to_char(count_active) AS VALUE,
                                       1 AS list_num,
                                       row_num,
                                       CASE
                                         WHEN series LIKE '1%' THEN
                                          3
                                         WHEN series LIKE '2%' THEN
                                          6
                                         WHEN series LIKE '3%' THEN
                                          5
                                         ELSE
                                          3
                                       END AS col_num
                               FROM trans_active_head
                               UNION ALL
                               --Стоимость проездных для А или Т
                               SELECT series,
                                       pay_type,
                                       privilege_type,
                                       decode(count_active,
                                              0,
                                              '0',
                                              to_char(sum_active / count_active,
                                                      'FM999999999999990.00')) AS VALUE,
                                       CASE
                                         WHEN series LIKE '2%' THEN
                                          2
                                         WHEN series LIKE '3%' THEN
                                          3
                                       END AS list_num,
                                       row_num,
                                       5 AS col_num
                               FROM trans_active_head
                               WHERE series LIKE '2%'
                               OR series LIKE '3%'
                               UNION ALL
                               --Стоимость проездных для АТ
                               SELECT series,
                                       pay_type,
                                       privilege_type,
                                       decode(count_active,
                                              0,
                                              '0',
                                              to_char(sum_active / count_active,
                                                      'FM999999999999990.00')) AS VALUE,
                                       lists.list_num,
                                       row_num,
                                       5 AS col_num
                               FROM trans_active_head,
                                     (SELECT 2 AS list_num
                                      FROM dual
                                      UNION ALL
                                      SELECT 3 AS list_num
                                      FROM dual) lists
                               WHERE series LIKE '1%'),
                              pass_kind_pay AS
                               (SELECT '32' AS kind,
                                      'VISA' AS pay_type
                               FROM dual
                               UNION ALL
                               SELECT '14' AS kind,
                                      'CASH' AS pay_type
                               FROM dual
                               UNION ALL
                               SELECT '17' AS kind,
                                      'CARD' AS pay_type
                               FROM dual),
                              operator_carrier AS
                               (SELECT id AS id_operator,
                                      decode(id,
                                             16100246845,
                                             'M',
                                             400246845,
                                             'T',
                                             500246845,
                                             'A') AS carrier_type
                               FROM operator
                               WHERE role = 1
                               AND id NOT IN (2200246845, 4100246845)),
                              trans_pass AS
                               (SELECT trans.id,
                                      nvl(trans.amount, 0) -
                                      nvl(trans.amount_bail, 0) AS amount,
                                      CASE
                                        WHEN nvl(trans.new_card_series,
                                                 trans.card_series) IN
                                             ('41', '44') THEN
                                         '141'
                                        WHEN nvl(trans.new_card_series,
                                                 trans.card_series) IN
                                             ('42', '45') THEN
                                         '242'
                                        WHEN nvl(trans.new_card_series,
                                                 trans.card_series) IN
                                             ('43', '46') THEN
                                         '343'
                                        ELSE
                                         nvl(trans.new_card_series,
                                             trans.card_series)
                                      END AS series,
                                      pass_kind_pay.pay_type,
                                      operator_carrier.carrier_type,
                                      priv_category.privilege_type
                               FROM cptt.t_data      trans,
                                    cptt.division    div,
                                    pass_kind_pay,
                                    operator_carrier,
                                    priv_category
                               WHERE trans.date_of >= pPassBeginDate
                               AND trans.date_of < pPassEndDate
                               AND trans.d = 0 -- не удален
                               AND trans.kind = pass_kind_pay.kind
                               AND trans.id_division = div.id
                               AND div.id_operator =
                                     operator_carrier.id_operator
                               AND trans.id_privilege =
                                     priv_category.id_privilege(+)),
                              trans_pass_counted AS
                               (SELECT nvl(series, 'null') AS series,
                                      pay_type,
                                      carrier_type,
                                      nvl(privilege_type, 'null') AS privilege_type,
                                      COUNT(1) AS count_pass,
                                      SUM(amount) AS sum_pass
                               FROM trans_pass
                               GROUP BY series,
                                        pay_type,
                                        carrier_type,
                                        privilege_type
                               ORDER BY carrier_type,
                                        series,
                                        pay_type),
                              trans_pass_head AS
                               (SELECT head.series,
                                      head.pay_type,
                                      head.privilege_type,
                                      trans_pass_counted.carrier_type,
                                      trans_pass_counted.count_pass,
                                      trans_pass_counted.sum_pass,
                                      head.row_num
                               FROM head,
                                    trans_pass_counted
                               WHERE nvl(head.series, 'null') =
                                     trans_pass_counted.series
                               AND nvl(head.pay_type, 'null') =
                                     trans_pass_counted.pay_type
                               AND nvl(head.privilege_type, 'null') =
                                     trans_pass_counted.privilege_type),
                              trans_pass_coord AS
                               (SELECT trans_pass_head.series,
                                      trans_pass_head.pay_type,
                                      trans_pass_head.privilege_type,
                                      trans_pass_head.carrier_type,
                                      to_char(nvl(trans_pass_head.count_pass,
                                                  0)) AS VALUE,
                                      1 AS list_num,
                                      trans_pass_head.row_num,
                                      decode(trans_pass_head.carrier_type,
                                             'A',
                                             8,
                                             'T',
                                             9,
                                             1) AS col_num
                               FROM trans_pass_head
                               UNION ALL
                               SELECT trans_pass_head.series,
                                      trans_pass_head.pay_type,
                                      trans_pass_head.privilege_type,
                                      trans_pass_head.carrier_type,
                                      decode(trans_pass_head.count_pass,
                                             0,
                                             '0',
                                             to_char(trans_pass_head.sum_pass /
                                                     trans_pass_head.count_pass,
                                                     'FM999999999999990.00')) AS VALUE,
                                      decode(trans_pass_head.carrier_type,
                                             'A',
                                             3,
                                             'T',
                                             2),
                                      trans_pass_head.row_num,
                                      5 AS col_num
                               FROM trans_pass_head
                               WHERE (series IS NULL OR series IN ('96'))
                               AND trans_pass_head.carrier_type IN ('A', 'T')
                               UNION ALL
                               SELECT trans_pass_head.series,
                                      trans_pass_head.pay_type,
                                      trans_pass_head.privilege_type,
                                      trans_pass_head.carrier_type,
                                      to_char(trans_pass_head.sum_pass,
                                              'FM999999999999990.00') AS VALUE,
                                      decode(trans_pass_head.carrier_type,
                                             'A',
                                             3,
                                             'T',
                                             2),
                                      trans_pass_head.row_num,
                                      6 AS col_num
                               FROM trans_pass_head
                               WHERE (series IS NULL OR series IN ('96'))
                               AND trans_pass_head.carrier_type IN ('A', 'T'))
                              SELECT series,
                                     pay_type,
                                     privilege_type,
                                     NULL AS carrier_type,
                                     VALUE,
                                     list_num,
                                     row_num,
                                     col_num
                              FROM trans_active_coord
                              UNION ALL
                              SELECT series,
                                     pay_type,
                                     privilege_type,
                                     carrier_type,
                                     VALUE,
                                     list_num,
                                     row_num,
                                     col_num
                              FROM trans_pass_coord)
    LOOP
      INSERT INTO cptt.TMP$TREP_REPORT_EXCEL_2
        (VALUE,
         list_num,
         row_num,
         col_num,
         debug_comment)
      VALUES
        (rec_active_pass.value,
         rec_active_pass.list_num,
         rec_active_pass.row_num,
         rec_active_pass.col_num,
         '"' || rec_active_pass.series || '"/' || '"' ||
         rec_active_pass.pay_type || '"/' || '"' ||
         rec_active_pass.privilege_type || '"/' || '"' ||
         rec_active_pass.carrier_type || '"');
    END LOOP;
    INSERT INTO cptt.TMP$TREP_REPORT_EXCEL_2
      (VALUE,
       list_num,
       row_num,
       col_num,
       debug_comment)
    VALUES
      ('Ежемесячный отчет Инвестора-Оператора о количестве фактически совершенных поездок в транспортных средствах Перевозчика за период с ' ||
       to_char(pPassBeginDate, 'dd.mm.yyyy (HH24:MI:SS)') || ' по ' ||
       to_char(pPassEndDate, 'dd.mm.yyyy  (HH24:MI:SS)'),
       1,
       1,
       1,
       'Заголовок первого листа');
    INSERT INTO cptt.TMP$TREP_REPORT_EXCEL_2
      (VALUE,
       list_num,
       row_num,
       col_num,
       debug_comment)
    VALUES
      ('Ежемесячный отчет Инвестора-Оператора об активации/пополнении транспортных карт за период с ' ||
       to_char(pPassBeginDate, 'dd.mm.yyyy (HH24:MI:SS)') || ' по ' ||
       to_char(pPassEndDate, 'dd.mm.yyyy (HH24:MI:SS)'),
       2,
       1,
       1,
       'Заголовок третьего листа');
    INSERT INTO cptt.TMP$TREP_REPORT_EXCEL_2
      (VALUE,
       list_num,
       row_num,
       col_num,
       debug_comment)
    VALUES
      ('Ежемесячный отчет Инвестора-Оператора об активации/пополнении транспортных карт за период с ' ||
       to_char(pPassBeginDate, 'dd.mm.yyyy (HH24:MI:SS)') || ' по ' ||
       to_char(pPassEndDate, 'dd.mm.yyyy (HH24:MI:SS)'),
       3,
       1,
       1,
       'Заголовок первого листа');
    COMMIT;
  END;*/

  PROCEDURE fillReportPrivilegeExcel(pActivationBeginDate IN DATE,
                                     pActivationEndDate   IN DATE,
                                     pPassBeginDate       IN DATE,
                                     pPassEndDate         IN DATE) AS
  BEGIN
    DELETE FROM cptt.TMP$TREP_REPORT_EXCEL_2;
    COMMIT;
  END;

END pkg$trep_reports_2;
/
