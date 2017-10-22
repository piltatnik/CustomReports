PL/SQL Developer Test script 3.0
564
-- Created on 03.02.2017 by PILARTSER 
DECLARE
  vCityPrivilegeCount     NUMBER := 3;
  vRegionalPrivilegeCount NUMBER := 3;
  CRLF                    VARCHAR2(5) := chr(10) || chr(13);
  --vFederalPrivilegeCount  NUMBER := 1;
BEGIN
  SELECT COUNT(1)
  INTO vCityPrivilegeCount
  FROM privilege
  WHERE code LIKE '000000__';
  SELECT COUNT(1)
  INTO vRegionalPrivilegeCount
  FROM privilege
  WHERE code LIKE '100000__';
  /*  SELECT COUNT(1)
  INTO vFederalPrivilegeCount
  FROM privilege
  WHERE code LIKE '200%';*/

  pkg$trep_reports.fillactivationseriesprivilege(pactivationbegindate => :pactivationbegindate,
                                                 pactivationenddate   => :pactivationenddate);

  OPEN :cur FOR
    WITH non_priv_primary AS
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
               WHEN series IN ('24', '34', '14', '21', '31', '11') THEN
                '      ��������'
               WHEN series IN ('25', '35', '15', '22', '32', '12') THEN
                '      ��������'
               WHEN series IN ('16', '13') THEN
                '      ����������'
               WHEN series IN ('29', '39', '19') THEN
                '      �������� ������'
               WHEN series IN ('242', '343', '141') THEN
                '      �����������'
               WHEN series IS NULL THEN
                '�� �������� �������� ��������,' || CRLF || '�����'
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
                29 + vCityPrivilegeCount + vRegionalPrivilegeCount
               WHEN series IN ('19') THEN
                33 + vCityPrivilegeCount + vRegionalPrivilegeCount
               WHEN series IN ('242', '343') THEN
                31 + vCityPrivilegeCount + vRegionalPrivilegeCount
               WHEN series IN ('141') THEN
                35 + vCityPrivilegeCount + vRegionalPrivilegeCount
               WHEN series IS NULL THEN
                37 + vCityPrivilegeCount + vRegionalPrivilegeCount
               WHEN series IN ('96') THEN
                38 + vCityPrivilegeCount + vRegionalPrivilegeCount
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
     (SELECT DISTINCT decode(series, NULL, '3.', '96', '4.', NULL) AS point,
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
             '=SUM(' || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
             '=SUM(' || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column
      FROM value_rows_distinct
      WHERE row_num IN (8, 9)
      UNION ALL
      SELECT NULL AS point,
             '   �� 2 ���� ����������' AS row_name,
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
             '   �� 1 ���' AS row_name,
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
             '   �� 2 ���� ����������' AS row_name,
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
             '   ��������� ���������' AS row_name,
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
             '   ������������ ���������' AS row_name,
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
             '      �� 1 ��� � �.�����' AS row_name,
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
             '      �� 2 ���� � �.�����' AS row_name,
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
             '������������ ����� "��������"' AS row_name,
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
             '������������ ����� "������������"' AS row_name,
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
             '������������ ����� "��������"' AS row_name,
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
             '��������� ����� �� �����' || CRLF ||
             '(����������� ����� �������� Mifare)' AS row_name,
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
             '������������ ����� ��������� Ultralight' || CRLF ||
             ' (������������� �������� �����)' AS row_name,
             36 + vCityPrivilegeCount + vRegionalPrivilegeCount AS row_num,
             NULL AS c_column,
             NULL AS e_column,
             NULL AS f_column,
             NULL AS h_column,
             NULL AS i_column
      FROM dual),
    group_rows_level_3 AS
     (SELECT '1.' AS point,
             '���������� ������������������� ' || CRLF ||
             '������������ �����, ����� � ��� �����:' AS row_name,
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
             '������������ ����� "���������", ' || CRLF || '� ��� �����:' AS row_name,
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
      LEFT OUTER JOIN cptt.TMP$TREP_ACTIVE_SERIESPRIV tas
      ON (vr.series = tas.series AND
         (vr.id_privilege = tas.id_privilege OR
         (vr.id_privilege IS NULL AND tas.id_privilege IS NULL)))),
    trans_pass_row AS
     (SELECT vr.series,
             vr.row_num,
             tps.id_operator,
             nvl(tps.count_pass, 0) AS count_pass,
             nvl(tps.sum_pass, 0) AS sum_pass
      FROM value_rows vr
      LEFT OUTER JOIN cptt.tmp$trep_pass_seriesprivop tps
      ON ((vr.series = tps.series OR
         (vr.series IS NULL AND tps.series IS NULL)) AND
         (vr.id_privilege = tps.id_privilege OR
         (vr.id_privilege IS NULL AND tps.id_privilege IS NULL)))),
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
           lists),
    --������� C
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
      WHERE tar.series LIKE '3%'),
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
      WHERE tar.series LIKE '2%'),
    --������� H
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
    --������� I
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
    SELECT * from trans_pass_row;
END;
3
cur
1
<Cursor>
116
pActivationBeginDate
1
13.11.2016
12
pActivationEndDate
1
12.12.2016
12
0
