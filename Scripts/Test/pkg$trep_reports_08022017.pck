CREATE OR REPLACE PACKAGE pkg$trep_reports IS

  -- Author  : PILARTSER
  -- Created : 29.01.2017 11:31:14
  -- Purpose : Транспортные отчеты(Рязань)
  PROCEDURE fillActivationSeriesPrivilege(pActivationBeginDate IN DATE,
                                          pActivationEndDate   IN DATE);

  PROCEDURE fillPassSeriesPrivilegeCarrier(pPassBeginDate IN DATE,
                                           pPassEndDate   IN DATE);

  --Заполнение проездов с группировкой по серии, привилегии и дню
  PROCEDURE fillPassSeriesPrivilegeDay(pPassBeginDate IN DATE,
                                       pPassEndDate   IN DATE);
  --Заполнение проездов, разбитых по номерам карт/привилегиям/перевозчику
  PROCEDURE fillPassCardPrivilegeCarrier(pPassBeginDate IN DATE,
                                         pPassEndDate   IN DATE);

  --Получение буквенного представления колонки excel
  FUNCTION getExcelColName(pColNum IN NUMBER) RETURN VARCHAR2;

  --Формирование отчета Инвестора-Оператора о количестве фактически совершенных поездок в транспортных средствах
  PROCEDURE fillReportActivePassExcel(pActivationBeginDate         IN DATE,
                                      pActivationEndDate           IN DATE,
                                      pPassBeginDate               IN DATE,
                                      pPassEndDate                 IN DATE,
                                      pIsRegionalPrivilegeSplitted IN VARCHAR2 DEFAULT 'N');

  PROCEDURE fillReportPrivilegeExcel(pActivationBeginDate IN DATE,
                                     pActivationEndDate   IN DATE,
                                     pPassBeginDate       IN DATE,
                                     pPassEndDate         IN DATE);
  PROCEDURE fillReportTransactionExcel(pPassBeginDate IN DATE,
                                       pPassEndDate   IN DATE);

END pkg$trep_reports;
/
CREATE OR REPLACE PACKAGE BODY pkg$trep_reports IS

  CRLF VARCHAR2(3) := chr(10) || chr(13);
  --Заполнение активированных карт с группировкой по серии и привилегии
  PROCEDURE fillActivationSeriesPrivilege(pActivationBeginDate IN DATE,
                                          pActivationEndDate   IN DATE) AS
  BEGIN
    DELETE FROM TMP$TREP_ACTIVE_SERIESPRIV;
    INSERT INTO TMP$TREP_ACTIVE_SERIESPRIV
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
    DELETE FROM TMP$TREP_PASS_SERIESPRIVOP;
    FOR rec IN (WITH carrier AS
                   (SELECT id AS id_operator
                   FROM operator
                   WHERE role = 1
                   AND id NOT IN (2200246845,
                                 4100246845, /*маршрутки сейчас исключены*/
                                 16100246845)),
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
      INSERT INTO cptt.TMP$TREP_PASS_SERIESPRIVOP
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

  --Заполнение проездов с группировкой по серии, привилегии и дню
  PROCEDURE fillPassSeriesPrivilegeDay(pPassBeginDate IN DATE,
                                       pPassEndDate   IN DATE) AS
  BEGIN
    DELETE FROM cptt.tmp$trep_pass_seriesprivday;
    --Нарезаем даты кусками по одному дню от начала периода и пока меньше окончания периода
    FOR date_rec IN (SELECT pPassBeginDate + LEVEL - 1 AS begin_date
                     FROM dual
                     START WITH pPassBeginDate < pPassEndDate
                     CONNECT BY pPassBeginDate + LEVEL - 1 < pPassEndDate
                     ORDER BY LEVEL)
    LOOP
      INSERT INTO cptt.tmp$trep_pass_seriesprivday
        (series,
         id_privilege,
         DAY,
         count_pass)
        WITH carrier AS
         (SELECT id AS id_operator
          FROM operator
          WHERE role = 1
          AND id NOT IN (2200246845,
                        4100246845, /*маршрутки сейчас исключены*/
                        16100246845)),
        pass AS
         (SELECT CASE
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
               cptt.division div,
               carrier
          WHERE trans.date_of >= date_rec.begin_date
          AND trans.date_of < date_rec.begin_date + 1
               --на случай если время окончания периода не совпадает в временем начала периода
          AND trans.date_of < pPassEndDate
          AND trans.d = 0 -- не удален
          AND trans.kind IN ('32', '14', '17')
          AND trans.id_division = div.id
          AND div.id_operator = carrier.id_operator)
        SELECT pass.series,
               id_privilege,
               date_rec.begin_date,
               COUNT(1) AS count_pass
        FROM pass
        GROUP BY pass.series,
                 pass.id_privilege;
    END LOOP;
    COMMIT;
  END;

  --Заполнение проездов, разбитых по номерам карт/привилегиям/перевозчику
  PROCEDURE fillPassCardPrivilegeCarrier(pPassBeginDate IN DATE,
                                         pPassEndDate   IN DATE) AS
  BEGIN
    DELETE FROM cptt.tmp$trep_pass_cardprivop;
    INSERT INTO cptt.tmp$trep_pass_cardprivop
      (card_num,
       id_privilege,
       id_operator,
       count_pass)
      WITH carrier AS
       (SELECT id AS id_operator
        FROM operator
        WHERE role = 1
        AND id NOT IN (2200246845,
                      4100246845, /*маршрутки сейчас исключены*/
                      16100246845)),
      pass AS
       (SELECT trans.card_num,
               trans.id_privilege,
               carrier.id_operator
        FROM cptt.t_data    trans,
             cptt.division  div,
             carrier,
             cptt.privilege priv
        WHERE trans.date_of >= pPassBeginDate
        AND trans.date_of < pPassEndDate
        AND trans.d = 0 -- не удален
        AND trans.kind IN ('32', '14', '17')
        AND trans.id_division = div.id
        AND div.id_operator = carrier.id_operator
        AND trans.id_privilege = priv.id)
      SELECT card_num,
             id_privilege,
             id_operator,
             COUNT(1) AS count_pass
      FROM pass
      GROUP BY card_num,
               id_privilege,
               id_operator;
    COMMIT;
  END;

  --Получение буквенного представления колонки excel
  FUNCTION getExcelColName(pColNum IN NUMBER) RETURN VARCHAR2 AS
    vDividend NUMBER;
    vModulo   NUMBER;
    vColName  VARCHAR2(10);
  BEGIN
    vDividend := pColNum;
    WHILE (vDividend > 0)
    LOOP
      vModulo   := MOD((vDividend - 1), 26);
      vColName  := chr(vModulo + ASCII('A')) || vColName;
      vDividend := floor((vDividend - vModulo) / 26);
    END LOOP;
    RETURN vColName;
  END;

  --Формирование отчета Инвестора-Оператора о количестве фактически совершенных поездок в транспортных средствах
  PROCEDURE fillReportActivePassExcel(pActivationBeginDate         IN DATE,
                                      pActivationEndDate           IN DATE,
                                      pPassBeginDate               IN DATE,
                                      pPassEndDate                 IN DATE,
                                      pIsRegionalPrivilegeSplitted IN VARCHAR2 DEFAULT 'N') AS
    vCityPrivilegeCount     NUMBER;
    vRegionalPrivilegeCount NUMBER;
  BEGIN
    DELETE FROM cptt.TMP$TREP_REPORT_EXCEL;
    DELETE FROM cptt.tmp$trep_report_excel_format;
    SELECT COUNT(1)
    INTO vCityPrivilegeCount
    FROM privilege
    WHERE code LIKE '000000__';
    IF (pIsRegionalPrivilegeSplitted = 'Y') THEN
      SELECT COUNT(1)
      INTO vRegionalPrivilegeCount
      FROM privilege
      WHERE code LIKE '100000__';
    ELSE
      vRegionalPrivilegeCount := 0;
    END IF;
  
    pkg$trep_reports.fillactivationseriesprivilege(pactivationbegindate,
                                                   pactivationenddate);
  
    pkg$trep_reports.fillpassseriesprivilegeCarrier(pPassbegindate,
                                                    pPassenddate);
  
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
                   SELECT '17' AS series,
                          1 AS pay_type,
                          NULL AS id_privilege,
                          'REGIONAL_PRIVILEGE' AS privilege_type,
                          '   региональные льготники' AS row_name,
                          25 + vCityPrivilegeCount AS row_num
                   FROM dual
                   WHERE nvl(pIsRegionalPrivilegeSplitted, 'N') != 'Y'
                   UNION ALL
                   SELECT series,
                          id_pay_type,
                          id_privilege,
                          privilege_type,
                          row_name,
                          row_num
                   FROM regional_priv
                   WHERE nvl(pIsRegionalPrivilegeSplitted, 'N') = 'Y'
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
                          '=ROUND(SUM(' || listagg('F' || row_num, ',') within GROUP(ORDER BY row_num) || '), 2)' AS f_column_2_3,
                          '=SUM(' || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(' || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column,
                          '=SUM(' || listagg('G' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS g_column_2_3
                   FROM value_rows_distinct
                   WHERE row_num IN (8, 9)
                   UNION ALL
                   SELECT NULL AS point,
                          '   на 2 вида транспорта' AS row_name,
                          10 AS row_num,
                          '=SUM(' || listagg('C' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS c_column,
                          NULL AS e_column,
                          NULL AS f_column,
                          '=ROUND(SUM(' || listagg('F' || row_num, ',') within GROUP(ORDER BY row_num) || '), 2)' AS f_column_2_3,
                          '=SUM(' || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(' || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column,
                          '=SUM(' || listagg('G' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS g_column_2_3
                   FROM value_rows_distinct
                   WHERE row_num IN (11, 12, 13)
                   UNION ALL
                   SELECT NULL AS point,
                          '   на 1 вид' AS row_name,
                          15 AS row_num,
                          '=SUM(' || listagg('C' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS c_column,
                          '=SUM(' || listagg('E' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS e_column,
                          '=SUM(' || listagg('F' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS f_column,
                          '=ROUND(SUM(' || listagg('F' || row_num, ',') within GROUP(ORDER BY row_num) || '), 2)' AS f_column_2_3,
                          '=SUM(' || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(' || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column,
                          '=SUM(' || listagg('G' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS g_column_2_3
                   FROM value_rows_distinct
                   WHERE row_num IN (16, 17)
                   UNION ALL
                   SELECT NULL AS point,
                          '   на 2 вида транспорта' AS row_name,
                          18 AS row_num,
                          '=SUM(' || listagg('C' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS c_column,
                          NULL AS e_column,
                          NULL AS f_column,
                          '=ROUND(SUM(' || listagg('F' || row_num, ',') within GROUP(ORDER BY row_num) || '), 2)' AS f_column_2_3,
                          '=SUM(' || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(' || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column,
                          '=SUM(' || listagg('G' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS g_column_2_3
                   FROM value_rows_distinct
                   WHERE row_num IN (19, 20, 21)
                   UNION ALL
                   SELECT NULL AS point,
                          '   городские льготники' AS row_name,
                          23 AS row_num,
                          '=SUM(' || listagg('C' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS c_column,
                          NULL AS e_column,
                          NULL AS f_column,
                          '=ROUND(SUM(' || listagg('F' || row_num, ',') within GROUP(ORDER BY row_num) || '), 2)' AS f_column_2_3,
                          '=SUM(' || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(' || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column,
                          '=SUM(' || listagg('G' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS g_column_2_3
                   FROM value_rows_distinct
                   WHERE row_num BETWEEN 24 AND 23 + vCityPrivilegeCount
                   UNION ALL
                   select point, row_name, row_num, c_column, e_column, f_column, f_column_2_3, h_column, i_column, g_column_2_3
                   from(
                   SELECT NULL AS point,
                          '   региональные льготники' AS row_name,
                          25 + vCityPrivilegeCount AS row_num,
                          '=SUM(' || listagg('C' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS c_column,
                          NULL AS e_column,
                          NULL AS f_column,
                          '=ROUND(SUM(' || listagg('F' || row_num, ',') within GROUP(ORDER BY row_num) || '), 2)' AS f_column_2_3,
                          '=SUM(' || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(' || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column,
                          '=SUM(' || listagg('G' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS g_column_2_3
                   FROM value_rows_distinct
                   WHERE row_num BETWEEN 26 + vCityPrivilegeCount AND
                         25 + vCityPrivilegeCount + vRegionalPrivilegeCount
                   )
                   where nvl(pIsRegionalPrivilegeSplitted, 'N') = 'Y'
                   UNION ALL
                   SELECT NULL AS point,
                          '      на 1 вид в т.числе' AS row_name,
                          28 + vCityPrivilegeCount + vRegionalPrivilegeCount AS row_num,
                          '=SUM(' || listagg('C' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS c_column,
                          '=SUM(' || listagg('E' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS e_column,
                          '=SUM(' || listagg('F' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS f_column,
                          '=ROUND(SUM(' || listagg('F' || row_num, ',') within GROUP(ORDER BY row_num) || '), 2)' AS f_column_2_3,
                          '=SUM(' || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(' || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column,
                          '=SUM(' || listagg('G' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS g_column_2_3
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
                          '=ROUND(SUM(' || listagg('F' || row_num, ',') within GROUP(ORDER BY row_num) || '), 2)' AS f_column_2_3,
                          '=SUM(' || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(' || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column,
                          '=SUM(' || listagg('G' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS g_column_2_3
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
                          '=ROUND(SUM(' || listagg('F' || row_num, ',') within GROUP(ORDER BY row_num) || '), 2)' AS f_column_2_3,
                          '=SUM(' || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(' || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column,
                          '=SUM(' || listagg('G' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS g_column_2_3
                   FROM group_rows_level_1
                   WHERE row_num IN (7, 10)
                   UNION ALL
                   SELECT '1.2.' AS point,
                          'Транспортная карта "Студенческая"' AS row_name,
                          14 AS row_num,
                          '=SUM(' || listagg('C' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS c_column,
                          NULL AS e_column,
                          NULL AS f_column,
                          '=ROUND(SUM(' || listagg('F' || row_num, ',') within GROUP(ORDER BY row_num) || '), 2)' AS f_column_2_3,
                          '=SUM(' || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(' || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column,
                          '=SUM(' || listagg('G' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS g_column_2_3
                   FROM group_rows_level_1
                   WHERE row_num IN (15, 18)
                   UNION ALL
                   SELECT '1.3.' AS point,
                          'Транспортная карта "Льготная"' AS row_name,
                          22 AS row_num,
                          '=SUM(C' || to_char(24 + vCityPrivilegeCount) || ',' 
                          || 
                          --
                          decode(nvl(pIsRegionalPrivilegeSplitted, 'N'),
                                 'N',
                                 'C' || to_char(25 + vCityPrivilegeCount) || ',',
                                 '') 
                          --
                          ||
                          listagg('C' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS c_column,
                          NULL AS e_column,
                          NULL AS f_column,
                          '=ROUND(SUM(F' ||
                          to_char(24 + vCityPrivilegeCount) || ',' 
                          ||
                          --
                          decode(nvl(pIsRegionalPrivilegeSplitted, 'N'),
                                 'N', 
                                 'F' || to_char(25 + vCityPrivilegeCount) || ',',
                                 '')
                          --
                          ||
                          listagg('F' || row_num, ',') within GROUP(ORDER BY row_num) || '), 2)' AS f_column_2_3,
                          '=SUM(H' || to_char(24 + vCityPrivilegeCount) || ',' 
                          ||
                          --
                          decode(nvl(pIsRegionalPrivilegeSplitted, 'N'),
                                 'N', 
                                 'H' || to_char(25 + vCityPrivilegeCount) || ',',
                                 '')
                          --
                          ||
                          listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(I' || to_char(24 + vCityPrivilegeCount) || ',' 
                          ||
                          --
                          decode(nvl(pIsRegionalPrivilegeSplitted, 'N'),
                                 'N', 
                                 'I' || to_char(25 + vCityPrivilegeCount) || ',',
                                 '')
                          --
                          ||
                          listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column,
                          '=SUM(G' || to_char(24 + vCityPrivilegeCount) || ',' 
                          || 
                          --
                          decode(nvl(pIsRegionalPrivilegeSplitted, 'N'),
                                 'N',
                                 'G' || to_char(25 + vCityPrivilegeCount) || ',',
                                 '')
                          --
                          ||
                          listagg('G' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS g_column_2_3
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
                          '=ROUND(SUM(' || listagg('F' || row_num, ',') within GROUP(ORDER BY row_num) || '), 2)' AS f_column_2_3,
                          '=SUM(' || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(' || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column,
                          '=SUM(' || listagg('G' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS g_column_2_3
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
                          NULL AS f_column_2_3,
                          NULL AS h_column,
                          NULL AS i_column,
                          NULL AS g_column_2_3
                   FROM dual),
                  group_rows_level_3 AS
                   (SELECT '1.' AS point,
                          'Социальные персонализированные ' || CRLF ||
                          'транспортные карты, всего в том числе:' AS row_name,
                          5 AS row_num,
                          '=SUM(' || listagg('C' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS c_column,
                          NULL AS e_column,
                          NULL AS f_column,
                          '=ROUND(SUM(' || listagg('F' || row_num, ',') within GROUP(ORDER BY row_num) || '), 2)' AS f_column_2_3,
                          '=SUM(' || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(' || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column,
                          '=SUM(' || listagg('G' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS g_column_2_3
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
                          '=ROUND(SUM(' || listagg('F' || row_num, ',') within GROUP(ORDER BY row_num) || '), 2)' AS f_column_2_3,
                          '=SUM(' || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(' || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column,
                          '=SUM(' || listagg('G' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS g_column_2_3
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
                          NULL     AS f_column_2_3,
                          NULL     AS h_column,
                          NULL     AS i_column,
                          NULL     AS g_column_2_3
                   FROM value_rows_distinct
                   UNION ALL
                   SELECT point,
                          row_name,
                          row_num,
                          c_column,
                          e_column,
                          f_column,
                          f_column_2_3,
                          h_column,
                          i_column,
                          g_column_2_3
                   FROM group_rows_level_1
                   UNION ALL
                   SELECT point,
                          row_name,
                          row_num,
                          c_column,
                          e_column,
                          f_column,
                          f_column_2_3,
                          h_column,
                          i_column,
                          g_column_2_3
                   FROM group_rows_level_2
                   UNION ALL
                   SELECT point,
                          row_name,
                          row_num,
                          c_column,
                          e_column,
                          f_column,
                          f_column_2_3,
                          h_column,
                          i_column,
                          g_column_2_3
                   FROM group_rows_level_3),
                  trans_activation_row AS
                   (SELECT vr.series,
                          vr.row_num,
                          SUM(nvl(tas.count_active, 0)) AS count_active,
                          SUM(nvl(tas.sum_active, 0)) AS sum_active
                   FROM value_rows vr
                   LEFT OUTER JOIN cptt.TMP$TREP_ACTIVE_SERIESPRIV tas
                   ON (vr.series = tas.series AND
                      (vr.id_privilege = tas.id_privilege OR
                      (vr.id_privilege IS NULL AND
                      tas.id_privilege IS NULL) OR
                      --хитрое условие сцепки региональных льготников
                      (nvl(pIsRegionalPrivilegeSplitted, 'N') = 'N' AND
                      vr.series = '17' AND vr.id_privilege IS NULL AND
                      tas.series = '17' AND
                      tas.id_privilege IN
                      (SELECT regional_priv.id_privilege
                          FROM regional_priv))))
                   GROUP BY vr.series,
                            vr.row_num),
                  carrier AS
                   (SELECT id AS id_operator
                   FROM operator
                   WHERE role = 1
                   AND id IN ('400246845', '500246845')),
                  trans_pass_row AS
                   (SELECT vr.series,
                          vr.row_num,
                          tps.id_operator,
                          SUM(nvl(tps.count_pass, 0)) AS count_pass,
                          SUM(nvl(tps.sum_pass, 0)) AS sum_pass
                   FROM value_rows vr
                   INNER JOIN cptt.TMP$TREP_PASS_SERIESPRIVOP tps
                   ON (((vr.series = tps.series OR
                      (vr.series IS NULL AND tps.series IS NULL)) AND
                      (vr.id_privilege = tps.id_privilege OR
                      (vr.id_privilege IS NULL AND
                      tps.id_privilege IS NULL)))
                      --хитрое условие сцепки региональных льготников
                      OR
                      (nvl(pIsRegionalPrivilegeSplitted, 'N') = 'N' AND
                       vr.series = '17' AND vr.id_privilege IS NULL AND
                       tps.series = '17' AND
                       tps.id_privilege IN
                       (SELECT regional_priv.id_privilege FROM regional_priv)))
                   GROUP BY vr.series,
                            vr.row_num,
                            tps.id_operator),
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
                        lists
                   UNION ALL
                   SELECT lists.list_num,
                          39 + vCityPrivilegeCount + vRegionalPrivilegeCount AS row_num,
                          'B' AS col_name,
                          'Итого:' AS VALUE
                   FROM lists),
                  --колонка C
                  col_c AS
                   (SELECT lists.list_num AS list_num,
                          r.row_num,
                          'C' AS col_name,
                          r.c_column AS VALUE
                   FROM row_formula_a_i r,
                        lists
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
                   OR series LIKE '3%'
                   UNION ALL
                   SELECT 2 AS list_num,
                          vr.row_num,
                          'C' AS col_name,
                          CASE
                            WHEN vr.series LIKE '1%' THEN
                             '=''По поездкам''!C' || vr.row_num
                            WHEN vr.series LIKE '2%' THEN
                             '=''По поездкам''!F' || vr.row_num
                            WHEN vr.series IN ('96') OR vr.series IS NULL THEN
                             '=''По поездкам''!I' || vr.row_num
                            ELSE
                             ''
                          END AS VALUE
                   FROM value_rows vr
                   WHERE vr.series LIKE '1%'
                   OR vr.series LIKE '2%'
                   OR vr.series IN ('96')
                   OR vr.series IS NULL
                   UNION ALL
                   SELECT 3 AS list_num,
                          vr.row_num,
                          'C' AS col_name,
                          CASE
                            WHEN vr.series LIKE '1%' THEN
                             '=''По поездкам''!C' || vr.row_num
                            WHEN vr.series LIKE '3%' THEN
                             '=''По поездкам''!E' || vr.row_num
                            WHEN vr.series IN ('96') OR vr.series IS NULL THEN
                             '=''По поездкам''!H' || vr.row_num
                            ELSE
                             ''
                          END AS VALUE
                   FROM value_rows vr
                   WHERE vr.series LIKE '1%'
                   OR vr.series LIKE '3%'
                   OR vr.series IN ('96')
                   OR vr.series IS NULL
                   UNION ALL
                   SELECT lists.list_num,
                          39 + vCityPrivilegeCount + vRegionalPrivilegeCount AS row_num,
                          'C' AS col_name,
                          '=SUM(C5,C' ||
                          to_char(26 + vCityPrivilegeCount +
                                  vRegionalPrivilegeCount) || ',C' ||
                          to_char(37 + vCityPrivilegeCount +
                                  vRegionalPrivilegeCount) || ',C' ||
                          to_char(38 + vCityPrivilegeCount +
                                  vRegionalPrivilegeCount) || ')' AS VALUE
                   FROM lists),
                  --колонка D
                  col_d AS
                   (SELECT 2 AS list_num,
                          vrd.row_num,
                          'D' AS col_name,
                          '=''По поездкам''!M' || vrd.row_num AS VALUE
                   FROM value_rows_distinct vrd
                   UNION ALL
                   SELECT 3 AS list_num,
                          vrd.row_num,
                          'D' AS col_name,
                          '=''По поездкам''!L' || vrd.row_num AS VALUE
                   FROM value_rows_distinct vrd),
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
                   WHERE tar.series LIKE '3%'
                   UNION ALL
                   SELECT 2 AS list_num,
                          tar.row_num,
                          'E' AS col_name,
                          decode(tar.count_active,
                                 0,
                                 '0',
                                 to_char(tar.sum_active / tar.count_active,
                                         'FM999999999999990.00')) AS VALUE
                   FROM trans_activation_row tar
                   WHERE tar.series LIKE '1%'
                   OR tar.series LIKE '2%'
                   UNION ALL
                   SELECT 3 AS list_num,
                          tar.row_num,
                          'E' AS col_name,
                          decode(tar.count_active,
                                 0,
                                 '0',
                                 to_char(tar.sum_active / tar.count_active,
                                         'FM999999999999990.00')) AS VALUE
                   FROM trans_activation_row tar
                   WHERE tar.series LIKE '1%'
                   OR tar.series LIKE '3%'
                   UNION ALL
                   SELECT decode(tpr.id_operator,
                                 400246845,
                                 2,
                                 500246845,
                                 3,
                                 4) AS list_num,
                          tpr.row_num,
                          'E' AS col_name,
                          decode(tpr.count_pass,
                                 0,
                                 '0',
                                 to_char(tpr.sum_pass / tpr.count_pass,
                                         'FM999999999999990.00')) AS VALUE
                   FROM trans_pass_row tpr
                   WHERE tpr.series IN ('96')
                   OR tpr.series IS NULL),
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
                   WHERE tar.series LIKE '2%'
                   UNION ALL
                   SELECT lists.list_num,
                          r.row_num,
                          'F' AS col_name,
                          r.f_column_2_3 AS VALUE
                   FROM row_formula_a_i r,
                        lists
                   WHERE r.f_column_2_3 IS NOT NULL
                   AND lists.list_num IN (2, 3)
                   --сумма по активациям
                   UNION ALL
                   SELECT 2 AS list_num,
                          tar.row_num,
                          'F' AS col_name,
                          '=D' || to_char(tar.row_num) || '*' ||
                          to_char(tar.sum_active) AS VALUE
                   FROM trans_activation_row tar
                   WHERE tar.series LIKE '2%'
                   OR tar.series LIKE '1%'
                   UNION ALL
                   SELECT 3 AS list_num,
                          tar.row_num,
                          'F' AS col_name,
                          '=D' || to_char(tar.row_num) || '*' ||
                          to_char(tar.sum_active) AS VALUE
                   FROM trans_activation_row tar
                   WHERE tar.series LIKE '3%'
                   OR tar.series LIKE '1%'
                   --
                   /*UNION ALL
                   SELECT lists.list_num,
                          vrd.row_num,
                          'F' AS col_name,
                          '=ROUND(D' || vrd.row_num || '*C' || vrd.row_num || '*E' ||
                          vrd.row_num || ', 2)' AS VALUE
                   FROM value_rows_distinct vrd,
                        lists
                   WHERE vrd.row_num NOT IN
                         (37 + vCityPrivilegeCount + vRegionalPrivilegeCount,
                          38 + vCityPrivilegeCount + vRegionalPrivilegeCount)
                   AND lists.list_num IN (2, 3)*/
                   --
                   UNION ALL
                   SELECT decode(tpr.id_operator,
                                 400246845,
                                 2,
                                 500246845,
                                 3,
                                 4) AS list_num,
                          tpr.row_num,
                          'F' AS col_name,
                          to_char(tpr.sum_pass) AS VALUE
                   FROM trans_pass_row tpr
                   WHERE tpr.series IN ('96')
                   OR tpr.series IS NULL
                   UNION ALL
                   SELECT lists.list_num,
                          39 + vCityPrivilegeCount + vRegionalPrivilegeCount AS row_num,
                          'F' AS col_name,
                          '=SUM(F5,F' ||
                          to_char(26 + vCityPrivilegeCount +
                                  vRegionalPrivilegeCount) || ',F' ||
                          to_char(37 + vCityPrivilegeCount +
                                  vRegionalPrivilegeCount) || ',F' ||
                          to_char(38 + vCityPrivilegeCount +
                                  vRegionalPrivilegeCount) || ')' AS VALUE
                   FROM lists
                   WHERE lists.list_num IN (2, 3)),
                  --колонка G
                  col_g AS
                   (SELECT lists.list_num,
                          r.row_num,
                          'G' AS col_name,
                          r.g_column_2_3 AS VALUE
                   FROM row_formula_a_i r,
                        lists
                   WHERE r.g_column_2_3 IS NOT NULL
                   UNION ALL
                   SELECT lists.list_num,
                          vrd.row_num,
                          'G' AS col_name,
                          '=ROUND(F' || vrd.row_num || '*0.0298, 2)' AS VALUE
                   FROM value_rows_distinct vrd,
                        lists
                   WHERE lists.list_num IN (2, 3)
                   UNION ALL
                   SELECT lists.list_num,
                          39 + vCityPrivilegeCount + vRegionalPrivilegeCount AS row_num,
                          'G' AS col_name,
                          '=SUM(G5,G' ||
                          to_char(26 + vCityPrivilegeCount +
                                  vRegionalPrivilegeCount) || ',G' ||
                          to_char(37 + vCityPrivilegeCount +
                                  vRegionalPrivilegeCount) || ',G' ||
                          to_char(38 + vCityPrivilegeCount +
                                  vRegionalPrivilegeCount) || ')' AS VALUE
                   FROM lists
                   WHERE lists.list_num IN (2, 3)),
                  --колонка H
                  col_h AS
                   (SELECT 1 AS list_num,
                          r.row_num,
                          'H' AS col_name,
                          r.h_column AS VALUE
                   FROM row_formula_a_i r
                   WHERE h_column IS NOT NULL
                   UNION ALL
                   SELECT DISTINCT 1 AS list_num,
                                   tpr.row_num,
                                   'H' AS col_name,
                                   to_char(tpr.count_pass) AS VALUE
                   FROM trans_pass_row tpr
                   WHERE tpr.id_operator IN ('500246845')
                   UNION ALL
                   SELECT 1 AS list_num,
                          vrd.row_num,
                          'H' AS col_name,
                          '0' AS VALUE
                   FROM value_rows_distinct vrd
                   WHERE vrd.row_num NOT IN
                         (SELECT row_num
                          FROM trans_pass_row
                          WHERE id_operator = '500246845')
                   UNION ALL
                   SELECT lists.list_num,
                          39 + vCityPrivilegeCount + vRegionalPrivilegeCount AS row_num,
                          'H' AS col_name,
                          '=SUM(H5,H' ||
                          to_char(26 + vCityPrivilegeCount +
                                  vRegionalPrivilegeCount) || ',H' ||
                          to_char(37 + vCityPrivilegeCount +
                                  vRegionalPrivilegeCount) || ',H' ||
                          to_char(38 + vCityPrivilegeCount +
                                  vRegionalPrivilegeCount) || ')' AS VALUE
                   FROM lists
                   WHERE lists.list_num IN (1)),
                  --колонка I
                  col_i AS
                   (SELECT 1 AS list_num,
                          r.row_num,
                          'I' AS col_name,
                          r.i_column AS VALUE
                   FROM row_formula_a_i r
                   WHERE i_column IS NOT NULL
                   UNION ALL
                   SELECT DISTINCT 1 AS list_num,
                                   tpr.row_num,
                                   'I' AS col_name,
                                   to_char(tpr.count_pass) AS VALUE
                   FROM trans_pass_row tpr
                   WHERE tpr.id_operator IN ('400246845')
                   UNION ALL
                   SELECT 1 AS list_num,
                          vrd.row_num,
                          'I' AS col_name,
                          '0' AS VALUE
                   FROM value_rows_distinct vrd
                   WHERE vrd.row_num NOT IN
                         (SELECT row_num
                          FROM trans_pass_row
                          WHERE id_operator = '400246845')
                   UNION ALL
                   SELECT lists.list_num,
                          39 + vCityPrivilegeCount + vRegionalPrivilegeCount AS row_num,
                          'I' AS col_name,
                          '=SUM(I5,I' ||
                          to_char(26 + vCityPrivilegeCount +
                                  vRegionalPrivilegeCount) || ',I' ||
                          to_char(37 + vCityPrivilegeCount +
                                  vRegionalPrivilegeCount) || ',I' ||
                          to_char(38 + vCityPrivilegeCount +
                                  vRegionalPrivilegeCount) || ')' AS VALUE
                   FROM lists
                   WHERE lists.list_num IN (1)),
                  --колонка J
                  col_j AS
                   (SELECT 1 AS list_num,
                          r.row_num,
                          'J' AS col_name,
                          '=SUM(H' || r.row_num || ',I' || r.row_num || ')' AS VALUE
                   FROM row_formula_a_i r
                   UNION ALL
                   SELECT lists.list_num,
                          39 + vCityPrivilegeCount + vRegionalPrivilegeCount AS row_num,
                          'J' AS col_name,
                          '=SUM(J5,J' ||
                          to_char(26 + vCityPrivilegeCount +
                                  vRegionalPrivilegeCount) || ',J' ||
                          to_char(37 + vCityPrivilegeCount +
                                  vRegionalPrivilegeCount) || ',J' ||
                          to_char(38 + vCityPrivilegeCount +
                                  vRegionalPrivilegeCount) || ')' AS VALUE
                   FROM lists
                   WHERE lists.list_num IN (1)),
                  --колонка L
                  col_l AS
                   (SELECT 1 AS list_num,
                          r.row_num,
                          'L' AS col_name,
                          CASE
                            WHEN r.row_num IN (7,
                                               8,
                                               9,
                                               15,
                                               16,
                                               17,
                                               37 + vCityPrivilegeCount +
                                               vRegionalPrivilegeCount,
                                               38 + vCityPrivilegeCount +
                                               vRegionalPrivilegeCount) OR
                                 r.row_num BETWEEN 28 + vCityPrivilegeCount +
                                 vRegionalPrivilegeCount AND
                                 31 + vCityPrivilegeCount +
                                 vRegionalPrivilegeCount THEN
                             '1'
                            ELSE
                             '=IF(J' || r.row_num || '=0, 0, ROUND(H' ||
                             r.row_num || '/J' || r.row_num || ', 2))'
                          END AS VALUE
                   FROM row_formula_a_i r),
                  --колонка M
                  col_m AS
                   (SELECT 1 AS list_num,
                          r.row_num,
                          'M' AS col_name,
                          CASE
                            WHEN r.row_num IN (7,
                                               8,
                                               9,
                                               15,
                                               16,
                                               17,
                                               37 + vCityPrivilegeCount +
                                               vRegionalPrivilegeCount,
                                               38 + vCityPrivilegeCount +
                                               vRegionalPrivilegeCount) OR
                                 r.row_num BETWEEN 28 + vCityPrivilegeCount +
                                 vRegionalPrivilegeCount AND
                                 31 + vCityPrivilegeCount +
                                 vRegionalPrivilegeCount THEN
                             '1'
                            ELSE
                             '=IF(J' || r.row_num || '=0, 0, ROUND(I' ||
                             r.row_num || '/J' || r.row_num || ', 2))'
                          END AS VALUE
                   FROM row_formula_a_i r),
                  a_m_coord AS
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
                   FROM col_d
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
                   FROM col_g
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
                   FROM col_i
                   UNION ALL
                   SELECT list_num,
                          row_num,
                          col_name,
                          VALUE
                   FROM col_j
                   UNION ALL
                   SELECT list_num,
                          row_num,
                          col_name,
                          VALUE
                   FROM col_l
                   UNION ALL
                   SELECT list_num,
                          row_num,
                          col_name,
                          VALUE
                   FROM col_m)
                  SELECT list_num,
                         row_num,
                         col_name,
                         VALUE
                  FROM a_m_coord
                  ORDER BY list_num,
                           row_num,
                           col_name)
    LOOP
      INSERT INTO cptt.TMP$TREP_REPORT_EXCEL
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
  
    INSERT INTO cptt.TMP$TREP_REPORT_EXCEL
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
    INSERT INTO cptt.TMP$TREP_REPORT_EXCEL
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
    INSERT INTO cptt.TMP$TREP_REPORT_EXCEL
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
  
    INSERT INTO cptt.tmp$trep_report_excel_format
      (list_num,
       RANGE,
       font_size)
    VALUES
      (1,
       'A1:A1',
       10);
    INSERT INTO cptt.tmp$trep_report_excel_format
      (list_num,
       RANGE,
       font_size)
    VALUES
      (2,
       'A1:A1',
       10);
    INSERT INTO cptt.tmp$trep_report_excel_format
      (list_num,
       RANGE,
       font_size)
    VALUES
      (3,
       'A1:A1',
       10);
    INSERT INTO cptt.tmp$trep_report_excel_format
      (list_num,
       RANGE,
       border)
    VALUES
      (1,
       'A5:M' ||
       to_char(39 + vCityPrivilegeCount + vRegionalPrivilegeCount),
       1);
    INSERT INTO cptt.tmp$trep_report_excel_format
      (list_num,
       RANGE,
       border)
    VALUES
      (2,
       'A5:H' ||
       to_char(39 + vCityPrivilegeCount + vRegionalPrivilegeCount),
       1);
    INSERT INTO cptt.tmp$trep_report_excel_format
      (list_num,
       RANGE,
       border)
    VALUES
      (3,
       'A5:H' ||
       to_char(39 + vCityPrivilegeCount + vRegionalPrivilegeCount),
       1);
    COMMIT;
  END;

  PROCEDURE fillReportPrivilegeExcel(pActivationBeginDate IN DATE,
                                     pActivationEndDate   IN DATE,
                                     pPassBeginDate       IN DATE,
                                     pPassEndDate         IN DATE) AS
  BEGIN
    DELETE FROM cptt.TMP$TREP_REPORT_EXCEL;
    DELETE FROM cptt.tmp$trep_report_excel_format;
    pkg$trep_reports.fillpasscardprivilegecarrier(ppassbegindate,
                                                  ppassenddate);
    FOR first_tab IN (WITH carrier_colnum AS
                         (SELECT op.id AS id_operator,
                                rownum + 2 AS col_num,
                                op.name
                         FROM operator op
                         WHERE op.role = 1
                         AND op.id NOT IN (2200246845,
                                          4100246845, /*маршрутки сейчас исключены*/
                                          16100246845)),
                        priv_rownum AS
                         (SELECT CASE
                                  WHEN code LIKE '100000__' THEN
                                   6
                                  WHEN code LIKE '200%' THEN
                                   10
                                  ELSE
                                   8
                                END AS row_num,
                                id
                         FROM cptt.privilege),
                        carrier_priv AS
                         (SELECT cc.id_operator,
                                pr.row_num,
                                cc.col_num
                         FROM carrier_colnum cc,
                              (SELECT DISTINCT row_num FROM priv_rownum) pr),
                        pass_priv_rownum AS
                         (SELECT priv.row_num,
                                id_operator,
                                cpo.count_pass
                         FROM cptt.tmp$trep_pass_cardprivop cpo,
                              priv_rownum                   priv
                         WHERE cpo.id_privilege = priv.id),
                        pass_row_col AS
                         (SELECT cp.row_num,
                                cp.col_num,
                                SUM(nvl(ppr.count_pass, 0)) AS count_pass
                         FROM carrier_priv     cp,
                              pass_priv_rownum ppr
                         WHERE cp.id_operator = ppr.id_operator(+)
                         AND cp.row_num = ppr.row_num(+)
                         GROUP BY cp.row_num,
                                  cp.col_num)
                        SELECT 5 AS row_num,
                               getExcelColName(col_num) AS col_name,
                               NAME AS VALUE
                        FROM carrier_colnum
                        UNION ALL
                        SELECT row_num,
                               getExcelColName(col_num) AS col_name,
                               to_char(count_pass) AS VALUE
                        FROM pass_row_col)
    LOOP
      INSERT INTO cptt.tmp$trep_report_excel
        (list_num,
         row_num,
         col_name,
         VALUE)
      VALUES
        (1,
         first_tab.row_num,
         first_tab.col_name,
         first_tab.value);
    END LOOP;
    COMMIT;
  END;

  PROCEDURE fillReportTransactionExcel(pPassBeginDate IN DATE,
                                       pPassEndDate   IN DATE) AS
    vCountTerm NUMBER;
  BEGIN
    DELETE FROM cptt.TMP$TREP_REPORT_EXCEL;
    DELETE FROM cptt.tmp$trep_report_excel_format;
    fillPassSeriesPrivilegeDay(pPassBeginDate, pPassEndDate);
    FOR rec IN (WITH pass_day_rownum AS
                   (SELECT CASE
                            WHEN series IS NULL THEN
                             17
                            WHEN series IN ('96') THEN
                             18
                            WHEN series IN ('17') AND
                                 priv.code LIKE '100000__' THEN
                             19
                            WHEN (series IN ('17') AND
                                 priv.code LIKE '000000__') OR
                                 series IN ('11',
                                            '12',
                                            '13',
                                            '14',
                                            '15',
                                            '16',
                                            '21',
                                            '22',
                                            '24',
                                            '25',
                                            '31',
                                            '32',
                                            '34',
                                            '35') THEN
                             20
                            WHEN series IN ('17') AND priv.code LIKE '2%' THEN
                             21
                            WHEN series IN ('39', '343') THEN
                             22
                            WHEN series IN ('19', '141') THEN
                             23
                            WHEN series IN ('29', '242') THEN
                             24
                            ELSE
                             1
                          END AS row_num,
                          spd.day,
                          spd.count_pass
                   FROM cptt.tmp$trep_pass_seriesprivday spd,
                        cptt.privilege                   priv
                   WHERE spd.id_privilege = priv.id(+)
                   ORDER BY DAY),
                  day_colnum AS
                   (SELECT rownum + 1 AS col_num,
                          pPassBeginDate + LEVEL - 1 AS DAY
                   FROM dual
                   START WITH pPassBeginDate < pPassEndDate
                   CONNECT BY pPassBeginDate + LEVEL - 1 < pPassEndDate
                   ORDER BY LEVEL),
                  second_tab AS
                   (SELECT pdr.row_num,
                          dc.col_num,
                          to_char(SUM(pdr.count_pass)) AS VALUE
                   FROM pass_day_rownum pdr,
                        day_colnum      dc
                   WHERE pdr.day = dc.day
                   GROUP BY row_num,
                            col_num
                   UNION ALL
                   SELECT 16 AS row_num,
                          dc.col_num,
                          'с ' || to_char(dc.day, 'dd.mm.yyyy HH24:MI:SS') AS VALUE
                   FROM day_colnum dc)
                  SELECT row_num,
                         col_num,
                         VALUE
                  FROM second_tab
                  ORDER BY row_num,
                           col_num)
    LOOP
      INSERT INTO cptt.TMP$TREP_REPORT_EXCEL
        (list_num,
         row_num,
         col_name,
         VALUE,
         debug_comment)
      VALUES
        (1,
         rec.row_num,
         getExcelColName(rec.col_num),
         rec.value,
         '');
    END LOOP;
    FOR rec IN (WITH pass_rownum AS
                   (SELECT CASE
                            WHEN series IS NULL THEN
                             6
                            WHEN series IN ('96') THEN
                             7
                            WHEN series IN ('17') AND
                                 priv.code LIKE '100000__' THEN
                             8
                            WHEN (series IN ('17') AND
                                 priv.code LIKE '000000__') OR
                                 series IN ('11',
                                            '12',
                                            '13',
                                            '14',
                                            '15',
                                            '16',
                                            '21',
                                            '22',
                                            '24',
                                            '25',
                                            '31',
                                            '32',
                                            '34',
                                            '35') THEN
                             9
                            WHEN series IN ('17') AND priv.code LIKE '2%' THEN
                             10
                            WHEN series IN ('39', '343') THEN
                             11
                            WHEN series IN ('19', '141') THEN
                             12
                            WHEN series IN ('29', '242') THEN
                             13
                            ELSE
                             1
                          END AS row_num,
                          spd.count_pass
                   FROM cptt.tmp$trep_pass_seriesprivday spd,
                        cptt.privilege                   priv
                   WHERE spd.id_privilege = priv.id(+)
                   ORDER BY DAY)
                  SELECT row_num,
                         'B' AS col_name,
                         SUM(count_pass) AS VALUE
                  FROM pass_rownum
                  GROUP BY row_num)
    LOOP
      INSERT INTO cptt.tmp$trep_report_excel
        (list_num,
         row_num,
         col_name,
         VALUE)
      VALUES
        (1,
         rec.row_num,
         rec.col_name,
         rec.value);
    END LOOP;
    INSERT INTO cptt.tmp$trep_report_excel
      (list_num,
       row_num,
       col_name,
       VALUE)
    VALUES
      (1,
       4,
       'B',
       'с ' || to_char(pPassBeginDate, 'dd.mm.yyyy HH24:MI:SS') || ' по ' ||
       to_char(pPassEndDate, 'dd.mm.yyyy HH24:MI:SS'));
    --Количество терминалов, по которым проводились транзакции
    WITH carrier AS
     (SELECT id AS id_operator
      FROM operator
      WHERE role = 1
      AND id NOT IN (2200246845,
                    4100246845, /*маршрутки сейчас исключены*/
                    16100246845)),
    pass AS
     (SELECT trans.id_term
      FROM cptt.t_data   trans,
           cptt.division div,
           carrier
      WHERE trans.date_of >= pPassBeginDate
      AND trans.date_of < pPassEndDate
      AND trans.d = 0 -- не удален
      AND trans.kind IN ('32', '14', '17')
      AND trans.id_division = div.id
      AND div.id_operator = carrier.id_operator)
    SELECT COUNT(DISTINCT id_term) INTO vCountTerm FROM pass;
    INSERT INTO cptt.tmp$trep_report_excel
      (list_num,
       row_num,
       col_name,
       VALUE)
    VALUES
      (1,
       14,
       'B',
       to_char(vCountTerm));
  
    INSERT INTO cptt.tmp$trep_report_excel
      (list_num,
       row_num,
       col_name,
       VALUE)
    VALUES
      (1,
       5,
       'B',
       '=SUM(B6:B13)');
  
    INSERT INTO cptt.tmp$trep_report_excel_format
      (list_num,
       RANGE,
       border)
    VALUES
      (1,
       'B4:B14',
       1);
    INSERT INTO cptt.tmp$trep_report_excel_format
      (list_num,
       RANGE,
       border)
    VALUES
      (1,
       'B16:' || getExcelColName(ceil(pPassEndDate - pPassBeginDate) + 1) || '24',
       1);
    COMMIT;
  END;
END pkg$trep_reports;
/
