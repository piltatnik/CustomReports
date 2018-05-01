PL/SQL Developer Test script 3.0
109
-- Created on 03.12.2017 by PILAR 
declare 
   vActivationHalfBeginDate DATE; 
      vActivationHalfEndDate DATE;
begin
  vActivationHalfBeginDate := add_months(trunc(:pActivationEndDate, 'mm'),
                                          -1) + 22;
  vActivationHalfEndDate   := add_months(trunc(:pActivationEndDate, 'mm'),
                                              1) - 14;
  open :cur for
  SELECT nvl(amount, 0) - nvl(amount_bail, 0) AS amount,
             nvl(trans.new_card_series, trans.card_series) AS series,
             decode(nvl(trans.new_card_series, trans.card_series),
                    '17',
                    trans.id_privilege,
                    NULL) AS id_privilege,
             CASE
               WHEN trans.kind IN (7, 8, 10, 11, 12, 13, 36, 37, 39) THEN
                'ACTIVE'
               WHEN trans.kind IN (32, 14, 16, 17, 20) THEN
                'PASS'
             END AS trans_type,
             div.id_operator,
             trans.kind,
             trans.card_num,
             CASE
               WHEN div.id_operator IN (400246845, 500246845) THEN NULL  
               ELSE div.id
             END as id_division
      FROM cptt.t_data   trans,
           cptt.division div
      WHERE (trans.kind IN (7, 8, 10, 11, 12, 13, 37) --активация
            OR -- дабы не путаться
            trans.kind IN (32, 14, 16, 17, 20) --проезд
            OR
            nvl(trans.new_card_series, trans.card_series) IN ('10', '90', '60') AND trans.kind IN (39)
            OR
            nvl(trans.new_card_series, trans.card_series) NOT IN ('10', '90', '60') AND trans.kind IN (36)
            )
      AND trans.d = 0 -- не удален
      AND date_of >= CASE
              WHEN trans.kind IN (32, 14, 16, 17, 20) THEN
               :pPassBeginDate
              WHEN trans.kind IN (7, 8, 10, 11, 12, 13, 36, 37, 39) THEN
               CASE
                 WHEN nvl(trans.new_card_series, trans.card_series) IN
                      ('50', '52', '53') THEN
                  vActivationHalfBeginDate
                 ELSE
                  :pActivationBeginDate
               END
            END
      AND date_of < CASE
              WHEN trans.kind IN (32, 14, 16, 17, 20) THEN
               :pPassEndDate
              WHEN (trans.kind IN (7, 8, 10, 11, 12, 13, 36, 37, 39)) THEN
               CASE
                 WHEN nvl(trans.new_card_series, trans.card_series) IN
                      ('50', '52', '53') THEN
                  vActivationHalfEndDate
                 ELSE
                  trunc(:pActivationEndDate) + 1
               END
            END
      AND (nvl(trans.new_card_series, trans.card_series) IN
            (
             '11',
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
             '60'
             ))
      AND trans.id_division = div.id --отбрасываем заблокированных операторов и заблокированных маршрутчиков
      AND div.id_operator NOT IN
            (SELECT id
             FROM cptt.ref$trep_agents_locked)
      AND div.id NOT IN
             (SELECT id
             FROM cptt.ref$trep_divisions_locked);
end;
5
cur
1
<Cursor>
116
pActivationBeginDate
1
16.10.2017
12
pActivationEndDate
1
15.11.2017
12
pPassBeginDate
1
01.11.2017 3:00:00
12
pPassEndDate
1
01.12.2017 3:00:00
12
0
