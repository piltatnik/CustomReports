CREATE OR REPLACE PACKAGE pkg$trep_reports IS

  -- Author  : PILARTSER
  -- Created : 29.01.2017 11:31:14
  -- Purpose : Транспортные отчеты(Рязань)

  PROCEDURE fillReportActivePassExcel(pActivationBeginDate IN DATE,
                                      pActivationEndDate   IN DATE,
                                      pPassBeginDAte       IN DATE,
                                      pPassEndDate         IN DATE);

END pkg$trep_reports;
/
CREATE OR REPLACE PACKAGE BODY pkg$trep_reports IS

  --Формирование отчета Инвестора-Оператора о количестве фактически совершенных поездок в транспортных средствах
  PROCEDURE fillReportActivePassExcel(pActivationBeginDate IN DATE,
                                      pActivationEndDate   IN DATE,
                                      pPassBeginDAte       IN DATE,
                                      pPassEndDate         IN DATE) AS
  BEGIN
    DELETE FROM cptt.tmp$trep_report_excel;
    FOR rec_active_pass IN (WITH head AS
                               (SELECT '11' AS series,
                                      'CARD' AS pay_type,
                                      NULL AS privilege_type,
                                      17 AS row_num
                               FROM dual
                               UNION ALL
                               SELECT '12' AS series,
                                      'CARD' AS pay_type,
                                      NULL AS privilege_type,
                                      18 AS row_num
                               FROM dual
                               UNION ALL
                               SELECT '13' AS series,
                                      'CARD' AS pay_type,
                                      NULL AS privilege_type,
                                      19 AS row_num
                               FROM dual
                               UNION ALL
                               SELECT '14' AS series,
                                      'CARD' AS pay_type,
                                      NULL AS privilege_type,
                                      9 AS row_num
                               FROM dual
                               UNION ALL
                               SELECT '15' AS series,
                                      'CARD' AS pay_type,
                                      NULL AS privilege_type,
                                      10 AS row_num
                               FROM dual
                               UNION ALL
                               SELECT '16' AS series,
                                      'CARD' AS pay_type,
                                      NULL AS privilege_type,
                                      11 AS row_num
                               FROM dual
                               UNION ALL
                               SELECT '17' AS series,
                                      'CARD' AS pay_type,
                                      'REGIONAL_PRIVILEGE' AS privilege_type,
                                      23 AS row_num
                               FROM dual
                               UNION ALL
                               SELECT '17' AS series,
                                      'CARD' AS pay_type,
                                      'FEDERAL_PRIVILEGE' AS privilege_type,
                                      22 AS row_num
                               FROM dual
                               UNION ALL
                               SELECT '17' AS series,
                                      'CARD' AS pay_type,
                                      'CITY_PRIVILEGE' AS privilege_type,
                                      21 AS row_num
                               FROM dual
                               UNION ALL
                               SELECT '19' AS series,
                                      'CARD' AS pay_type,
                                      NULL AS privilege_type,
                                      31 AS row_num
                               FROM dual
                               UNION ALL
                               SELECT '141' AS series,
                                      'CARD' AS pay_type,
                                      NULL AS privilege_type,
                                      33 AS row_num
                               FROM dual
                               UNION ALL
                               SELECT '21' AS series,
                                      'CARD' AS pay_type,
                                      NULL AS privilege_type,
                                      14 AS row_num
                               FROM dual
                               UNION ALL
                               SELECT '22' AS series,
                                      'CARD' AS pay_type,
                                      NULL AS privilege_type,
                                      15 AS row_num
                               FROM dual
                               UNION ALL
                               
                               SELECT '24' AS series,
                                      'CARD' AS pay_type,
                                      NULL AS privilege_type,
                                      6 AS row_num
                               FROM dual
                               UNION ALL
                               SELECT '25' AS series,
                                      'CARD' AS pay_type,
                                      NULL AS privilege_type,
                                      7 AS row_num
                               FROM dual
                               UNION ALL
                               
                               SELECT '29' AS series,
                                      'CARD' AS pay_type,
                                      NULL AS privilege_type,
                                      27 AS row_num
                               FROM dual
                               UNION ALL
                               SELECT '242' AS series,
                                      'CARD' AS pay_type,
                                      NULL AS privilege_type,
                                      29 AS row_num
                               FROM dual
                               UNION ALL
                               SELECT '31' AS series,
                                      'CARD' AS pay_type,
                                      NULL AS privilege_type,
                                      14 AS row_num
                               FROM dual
                               UNION ALL
                               SELECT '32' AS series,
                                      'CARD' AS pay_type,
                                      NULL AS privilege_type,
                                      15 AS row_num
                               FROM dual
                               UNION ALL
                               
                               SELECT '34' AS series,
                                      'CARD' AS pay_type,
                                      NULL AS privilege_type,
                                      6 AS row_num
                               FROM dual
                               UNION ALL
                               SELECT '35' AS series,
                                      'CARD' AS pay_type,
                                      NULL AS privilege_type,
                                      7 AS row_num
                               FROM dual
                               UNION ALL
                               
                               SELECT '39' AS series,
                                      'CARD' AS pay_type,
                                      NULL AS privilege_type,
                                      27 AS row_num
                               FROM dual
                               UNION ALL
                               SELECT '343' AS series,
                                      'CARD' AS pay_type,
                                      NULL AS privilege_type,
                                      29 AS row_num
                               FROM dual
                               UNION ALL
                               SELECT '96' AS series,
                                      'VISA' AS pay_type,
                                      NULL AS privilege_type,
                                      36 AS row_num
                               FROM dual
                               UNION ALL
                               SELECT NULL AS series,
                                      'CASH' AS pay_type,
                                      NULL AS privilege_type,
                                      35 AS row_num
                               FROM dual),
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
                                      COUNT(1) AS VALUE
                               FROM trans_active
                               GROUP BY series,
                                        privilege_type),
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
                                      COUNT(1) AS VALUE
                               FROM trans_pass
                               GROUP BY series,
                                        pay_type,
                                        carrier_type,
                                        privilege_type
                               ORDER BY carrier_type,
                                        series,
                                        pay_type),
                              trans_active_coord AS
                               (SELECT head.series,
                                      head.pay_type,
                                      head.privilege_type,
                                      nvl(trans_active_counted.value, 0) AS VALUE,
                                      head.row_num,
                                      CASE
                                        WHEN head.series LIKE '1%' THEN
                                         3
                                        WHEN head.series LIKE '2%' THEN
                                         6
                                        WHEN head.series LIKE '3%' THEN
                                         5
                                        ELSE
                                         3
                                      END AS col_num
                               FROM head,
                                    trans_active_counted
                               WHERE head.series =
                                     trans_active_counted.series(+)
                               AND nvl(head.privilege_type, 'null') =
                                     trans_active_counted.privilege_type(+)),
                              trans_pass_coord AS
                               (SELECT head.series,
                                      head.pay_type,
                                      head.privilege_type,
                                      trans_pass_counted.carrier_type,
                                      nvl(trans_pass_counted.value, 0) AS VALUE,
                                      head.row_num,
                                      decode(trans_pass_counted.carrier_type,
                                             'A',
                                             8,
                                             'T',
                                             9,
                                             1) AS col_num
                               FROM head,
                                    trans_pass_counted
                               WHERE nvl(head.series, 'null') =
                                     trans_pass_counted.series
                               AND nvl(head.pay_type, 'null') =
                                     trans_pass_counted.pay_type
                               AND nvl(head.privilege_type, 'null') =
                                     trans_pass_counted.privilege_type)
                              SELECT series,
                                     pay_type,
                                     privilege_type,
                                     NULL AS carrier_type,
                                     VALUE,
                                     row_num,
                                     col_num
                              FROM trans_active_coord
                              UNION ALL
                              SELECT series,
                                     pay_type,
                                     privilege_type,
                                     carrier_type,
                                     VALUE,
                                     row_num,
                                     col_num
                              FROM trans_pass_coord)
    LOOP
      INSERT INTO cptt.tmp$trep_report_excel
        (VALUE,
         row_num,
         col_num,
         debug_comment)
      VALUES
        (rec_active_pass.value,
         rec_active_pass.row_num,
         rec_active_pass.col_num,
         '"' || rec_active_pass.series || '"/' || '"' ||
         rec_active_pass.pay_type || '"/' || '"' ||
         rec_active_pass.privilege_type || '"/' || '"' ||
         rec_active_pass.carrier_type || '"');
    END LOOP;
    COMMIT;
  END;

END pkg$trep_reports;
/
