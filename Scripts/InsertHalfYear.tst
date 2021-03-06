PL/SQL Developer Test script 3.0
78
DECLARE pPassBeginDate DATE := to_date('30.11.2017 3:00:00', 'dd.mm.yyyy HH24:MI:SS');
        pPassEndDate DATE := to_date('01.12.2017 3:00:00', 'dd.mm.yyyy HH24:MI:SS');
BEGIN
    /*DROP TABLE tmp$cptt_buffer_halfyear;
    CREATE TABLE tmp$cptt_buffer_halfyear(ID NUMBER(38),
                                          DATE_OF DATE,
                                          ID_ROUTE NUMBER(38),
                                          ID_VEHICLE NUMBER(38),
                                          ID_OPERATOR NUMBER(38),
                                          ID_DIVISION NUMBER(38));SELECT count(1) FRom tmp$cptt_buffer_halfyear*/
    DELETE FROM tmp$cptt_buffer_halfyear;
    INSERT INTO tmp$cptt_buffer_halfyear
        (ID,
         DATE_OF,
         ID_ROUTE,
         ID_VEHICLE,
         ID_OPERATOR,
         ID_DIVISION)
        SELECT trans.id,
               trunc(trans.date_of-3/24) AS date_of,
               trans.id_route,
               trans.id_vehicle,
               div.id_operator,
               CASE
                   WHEN div.id_operator IN (400246845, 500246845) THEN
                    NULL
                   ELSE
                    div.id
               END AS id_division
        FROM   cptt.t_data   trans,
               cptt.division div
        WHERE  trans.d = 0 -- �� ������
               AND trans.kind IN (32, 14, 16, 17, 20) --1,2
               AND date_of >= pPassBeginDate
               AND date_of < pPassEndDate
               AND (nvl(trans.new_card_series, trans.card_series) IN
               ('11',
                     '12',
                     '13',
                     '14',
                     '15',
                     '16',
                     '17',
                     '19',
                     '50',
                     '41',
                     '44',
                     '20',
                     '21',
                     '22',
                     '23',
                     '24',
                     '25',
                     '29',
                     '52',
                     '42',
                     '45',
                     '31',
                     '32',
                     '33',
                     '34',
                     '35',
                     '39',
                     '53',
                     '43',
                     '46',
                     '96',
                     '10',
                     '90',
                     '60') OR
               nvl(trans.new_card_series, trans.card_series) IS NULL)
               AND trans.id_division = div.id --����������� ��������������� ���������� � ��������������� ������������
               AND div.id_operator NOT IN
               (SELECT id FROM cptt.ref$trep_agents_locked)
               AND div.id NOT IN
               (SELECT id FROM cptt.ref$trep_divisions_locked);
        COMMIT;
END;
5
cur
1
<Cursor>
-116
pActivationBeginDate
1
16.10.2017
-12
pActivationEndDate
1
15.11.2017
-12
pPassBeginDate
1
30.11.2017 3:00:00
-12
pPassEndDate
1
01.12.2017 3:00:00
-12
0
