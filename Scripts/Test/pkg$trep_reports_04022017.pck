CREATE OR REPLACE PACKAGE pkg$trep_reports IS

  -- Author  : PILARTSER
  -- Created : 29.01.2017 11:31:14
  -- Purpose : ������������ ������(������)
  PROCEDURE fillActivationSeriesPrivilege(pActivationBeginDate IN DATE,
                                          pActivationEndDate   IN DATE);

  PROCEDURE fillReportActivePassExcel(pActivationBeginDate IN DATE,
                                      pActivationEndDate   IN DATE,
                                      pPassBeginDAte       IN DATE,
                                      pPassEndDate         IN DATE);
  PROCEDURE fillReportPrivilegeExcel(pActivationBeginDate IN DATE,
                                     pActivationEndDate   IN DATE,
                                     pPassBeginDate       IN DATE,
                                     pPassEndDate         IN DATE);

END pkg$trep_reports;
/
CREATE OR REPLACE PACKAGE BODY pkg$trep_reports IS

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
        WHERE trans.kind IN (7, 8, 10, 11, 12, 13) --���������
        AND trans.d = 0 -- �� ������
        AND trunc(trans.date_of) >= pActivationBeginDate --������ ���������
        AND trunc(trans.date_of) <= pActivationEndDate --
        AND trans.id_division = div.id --����������� �������� ����������
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

  --������������ ������ ���������-��������� � ���������� ���������� ����������� ������� � ������������ ���������
  PROCEDURE fillReportActivePassExcel(pActivationBeginDate IN DATE,
                                      pActivationEndDate   IN DATE,
                                      pPassBeginDate       IN DATE,
                                      pPassEndDate         IN DATE) AS
  BEGIN
    DELETE FROM cptt.tmp$trep_report_excel;
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
                               WHERE trans.kind IN (7, 8, 10, 11, 12, 13) --���������
                               AND trans.d = 0 -- �� ������
                               AND trunc(trans.date_of) >=
                                     pActivationBeginDate --������ ���������
                               AND trunc(trans.date_of) <= pActivationEndDate --
                               AND trans.id_division = div.id --����������� �������� ����������
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
                               --���������� ���������
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
                               --��������� ��������� ��� � ��� �
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
                               --��������� ��������� ��� ��
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
                               AND trans.d = 0 -- �� ������
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
      INSERT INTO cptt.tmp$trep_report_excel
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
    INSERT INTO cptt.tmp$trep_report_excel
      (VALUE,
       list_num,
       row_num,
       col_num,
       debug_comment)
    VALUES
      ('����������� ����� ���������-��������� � ���������� ���������� ����������� ������� � ������������ ��������� ����������� �� ������ � ' ||
       to_char(pPassBeginDate, 'dd.mm.yyyy (HH24:MI:SS)') || ' �� ' ||
       to_char(pPassEndDate, 'dd.mm.yyyy  (HH24:MI:SS)'),
       1,
       1,
       1,
       '��������� ������� �����');
    INSERT INTO cptt.tmp$trep_report_excel
      (VALUE,
       list_num,
       row_num,
       col_num,
       debug_comment)
    VALUES
      ('����������� ����� ���������-��������� �� ���������/���������� ������������ ���� �� ������ � ' ||
       to_char(pPassBeginDate, 'dd.mm.yyyy (HH24:MI:SS)') || ' �� ' ||
       to_char(pPassEndDate, 'dd.mm.yyyy (HH24:MI:SS)'),
       2,
       1,
       1,
       '��������� �������� �����');
    INSERT INTO cptt.tmp$trep_report_excel
      (VALUE,
       list_num,
       row_num,
       col_num,
       debug_comment)
    VALUES
      ('����������� ����� ���������-��������� �� ���������/���������� ������������ ���� �� ������ � ' ||
       to_char(pPassBeginDate, 'dd.mm.yyyy (HH24:MI:SS)') || ' �� ' ||
       to_char(pPassEndDate, 'dd.mm.yyyy (HH24:MI:SS)'),
       3,
       1,
       1,
       '��������� ������� �����');
    COMMIT;
  END;

  PROCEDURE fillReportPrivilegeExcel(pActivationBeginDate IN DATE,
                                     pActivationEndDate   IN DATE,
                                     pPassBeginDate       IN DATE,
                                     pPassEndDate         IN DATE) AS
  BEGIN
    DELETE FROM cptt.tmp$trep_report_excel;
    COMMIT;
  END;

END pkg$trep_reports;
/
