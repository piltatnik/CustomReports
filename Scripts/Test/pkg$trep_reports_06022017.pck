CREATE OR REPLACE PACKAGE pkg$trep_reports IS

  -- Author  : PILARTSER
  -- Created : 29.01.2017 11:31:14
  -- Purpose : ������������ ������(������)
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

END pkg$trep_reports;
/
CREATE OR REPLACE PACKAGE BODY pkg$trep_reports IS

  CRLF VARCHAR2(3) := chr(10) || chr(13);
  --���������� �������������� ���� � ������������ �� ����� � ����������
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

  --���������� �������� � ������������ �� �����, ���������� � ���������
  PROCEDURE fillPassSeriesPrivilegeCarrier(pPassBeginDate IN DATE,
                                           pPassEndDate   IN DATE) AS
  BEGIN
    DELETE FROM TMP$TREP_PASS_SERIESPRIVOP;
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
                   AND trans.d = 0 -- �� ������
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
  --������������ ������ ���������-��������� � ���������� ���������� ����������� ������� � ������������ ���������
  PROCEDURE fillReportActivePassExcel(pActivationBeginDate IN DATE,
                                      pActivationEndDate   IN DATE,
                                      pPassBeginDate       IN DATE,
                                      pPassEndDate         IN DATE) AS
    vCityPrivilegeCount     NUMBER;
    vRegionalPrivilegeCount NUMBER;
  BEGIN
    DELETE FROM cptt.TMP$TREP_REPORT_EXCEL;
    SELECT COUNT(1)
    INTO vCityPrivilegeCount
    FROM privilege
    WHERE code LIKE '000000__';
    SELECT COUNT(1)
    INTO vRegionalPrivilegeCount
    FROM privilege
    WHERE code LIKE '100000__';
  
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
                             '      ��������'
                            WHEN series IN
                                 ('25', '35', '15', '22', '32', '12') THEN
                             '      ��������'
                            WHEN series IN ('16', '13') THEN
                             '      ����������'
                            WHEN series IN ('29', '39', '19') THEN
                             '      �������� ������'
                            WHEN series IN ('242', '343', '141') THEN
                             '      �����������'
                            WHEN series IS NULL THEN
                             '�� �������� �������� ��������,' || CRLF ||
                             '�����'
                            WHEN series IN ('96') THEN
                             '����� VISA'
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
                          '      �������� (�� ���������)',
                          30 + vCityPrivilegeCount + vRegionalPrivilegeCount AS row_num
                   FROM dual
                   UNION ALL
                   SELECT NULL AS point,
                          '      �������� (�� ���������)',
                          34 + vCityPrivilegeCount + vRegionalPrivilegeCount AS row_num
                   FROM dual),
                  group_rows_level_1 AS
                   (SELECT NULL AS point,
                          '   �� 1 ���' AS row_name,
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
                          '   �� 2 ���� ����������' AS row_name,
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
                          '   �� 1 ���' AS row_name,
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
                          '   �� 2 ���� ����������' AS row_name,
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
                          '   ��������� ���������' AS row_name,
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
                   SELECT NULL AS point,
                          '   ������������ ���������' AS row_name,
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
                   UNION ALL
                   SELECT NULL AS point,
                          '      �� 1 ��� � �.�����' AS row_name,
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
                          '      �� 2 ���� � �.�����' AS row_name,
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
                          '������������ ����� "��������"' AS row_name,
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
                          '������������ ����� "������������"' AS row_name,
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
                          '������������ ����� "��������"' AS row_name,
                          22 AS row_num,
                          '=SUM(C' || to_char(24 + vCityPrivilegeCount) || ',' ||
                          listagg('C' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS c_column,
                          NULL AS e_column,
                          NULL AS f_column,
                          '=ROUND(SUM(F' ||
                          to_char(24 + vCityPrivilegeCount) || ',' ||
                          listagg('F' || row_num, ',') within GROUP(ORDER BY row_num) || '), 2)' AS f_column_2_3,
                          '=SUM(H' || to_char(24 + vCityPrivilegeCount) || ',' ||
                          listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(I' || to_char(24 + vCityPrivilegeCount) || ',' ||
                          listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column,
                          '=SUM(G' || to_char(24 + vCityPrivilegeCount) || ',' ||
                          listagg('G' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS g_column_2_3
                   FROM group_rows_level_1
                   WHERE row_num IN (23, 25 + vCityPrivilegeCount)
                   UNION ALL
                   SELECT '2.1.' AS point,
                          '��������� ����� �� �����' || CRLF ||
                          '(����������� ����� �������� Mifare)' AS row_name,
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
                          '������������ ����� ��������� Ultralight' || CRLF ||
                          ' (������������� �������� �����)' AS row_name,
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
                          '���������� ������������������� ' || CRLF ||
                          '������������ �����, ����� � ��� �����:' AS row_name,
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
                          '������������ ����� "���������", ' || CRLF ||
                          '� ��� �����:' AS row_name,
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
                          nvl(tas.count_active, 0) AS count_active,
                          nvl(tas.sum_active, 0) AS sum_active
                   FROM value_rows vr
                   LEFT OUTER JOIN cptt.TMP$TREP_ACTIVE_SERIESPRIV tas
                   ON (vr.series = tas.series AND
                      (vr.id_privilege = tas.id_privilege OR
                      (vr.id_privilege IS NULL AND
                      tas.id_privilege IS NULL)))),
                  carrier AS
                   (SELECT id AS id_operator
                   FROM operator
                   WHERE role = 1
                   AND id IN ('400246845', '500246845')),
                  trans_pass_row AS
                   (SELECT vr.series,
                          vr.row_num,
                          tps.id_operator,
                          nvl(tps.count_pass, 0) AS count_pass,
                          nvl(tps.sum_pass, 0) AS sum_pass
                   FROM value_rows vr
                   INNER JOIN cptt.TMP$TREP_PASS_SERIESPRIVOP tps
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
                  --������� A
                  col_a AS
                   (SELECT lists.list_num,
                          r.row_num,
                          'A' AS col_name,
                          r.point AS VALUE
                   FROM row_formula_a_i r,
                        lists
                   WHERE r.point IS NOT NULL),
                  --������� B
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
                          '�����:' AS VALUE
                   FROM lists),
                  --������� C
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
                             '=''�� ��������''!C' || vr.row_num
                            WHEN vr.series LIKE '2%' THEN
                             '=''�� ��������''!F' || vr.row_num
                            WHEN vr.series IN ('96') OR vr.series IS NULL THEN
                             '=''�� ��������''!I' || vr.row_num
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
                             '=''�� ��������''!C' || vr.row_num
                            WHEN vr.series LIKE '3%' THEN
                             '=''�� ��������''!E' || vr.row_num
                            WHEN vr.series IN ('96') OR vr.series IS NULL THEN
                             '=''�� ��������''!H' || vr.row_num
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
                  --������� D
                  col_d AS
                   (SELECT 2 AS list_num,
                          vrd.row_num,
                          'D' AS col_name,
                          '=''�� ��������''!M' || vrd.row_num AS VALUE
                   FROM value_rows_distinct vrd
                   UNION ALL
                   SELECT 3 AS list_num,
                          vrd.row_num,
                          'D' AS col_name,
                          '=''�� ��������''!L' || vrd.row_num AS VALUE
                   FROM value_rows_distinct vrd),
                  --������� E
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
                  --������� F
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
                   UNION ALL
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
                   AND lists.list_num IN (2, 3)
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
                  --������� G
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
                  --������� H
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
                  --������� I
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
                  --������� J
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
                  --������� L
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
                  --������� M
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
      ('����������� ����� ���������-��������� � ���������� ���������� ����������� ������� � ������������ ��������� ����������� �� ������ � ' ||
       to_char(pPassBeginDate, 'dd.mm.yyyy (HH24:MI:SS)') || ' �� ' ||
       to_char(pPassEndDate, 'dd.mm.yyyy  (HH24:MI:SS)'),
       1,
       1,
       'A',
       '��������� ������� �����');
    INSERT INTO cptt.TMP$TREP_REPORT_EXCEL
      (VALUE,
       list_num,
       row_num,
       col_name,
       debug_comment)
    VALUES
      ('����������� ����� ���������-��������� �� ���������/���������� ������������ ���� �� ������ � ' ||
       to_char(pPassBeginDate, 'dd.mm.yyyy (HH24:MI:SS)') || ' �� ' ||
       to_char(pPassEndDate, 'dd.mm.yyyy (HH24:MI:SS)'),
       2,
       1,
       'A',
       '��������� �������� �����');
    INSERT INTO cptt.TMP$TREP_REPORT_EXCEL
      (VALUE,
       list_num,
       row_num,
       col_name,
       debug_comment)
    VALUES
      ('����������� ����� ���������-��������� �� ���������/���������� ������������ ���� �� ������ � ' ||
       to_char(pPassBeginDate, 'dd.mm.yyyy (HH24:MI:SS)') || ' �� ' ||
       to_char(pPassEndDate, 'dd.mm.yyyy (HH24:MI:SS)'),
       3,
       1,
       'A',
       '��������� ������� �����');
    COMMIT;
  END;

  --���������� �� ����
  /*  PROCEDURE fillReportActivePassExcel_Old(pActivationBeginDate IN DATE,
                                      pActivationEndDate   IN DATE,
                                      pPassBeginDate       IN DATE,
                                      pPassEndDate         IN DATE) AS
  BEGIN
    DELETE FROM cptt.TMP$TREP_REPORT_EXCEL;
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
      INSERT INTO cptt.TMP$TREP_REPORT_EXCEL
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
    INSERT INTO cptt.TMP$TREP_REPORT_EXCEL
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
    INSERT INTO cptt.TMP$TREP_REPORT_EXCEL
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
    INSERT INTO cptt.TMP$TREP_REPORT_EXCEL
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
  END;*/

  PROCEDURE fillReportPrivilegeExcel(pActivationBeginDate IN DATE,
                                     pActivationEndDate   IN DATE,
                                     pPassBeginDate       IN DATE,
                                     pPassEndDate         IN DATE) AS
  BEGIN
    DELETE FROM cptt.TMP$TREP_REPORT_EXCEL;
    COMMIT;
  END;

END pkg$trep_reports;
/
