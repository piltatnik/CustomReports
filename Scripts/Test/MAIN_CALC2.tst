PL/SQL Developer Test script 3.0
268
BEGIN
  FOR rec IN (WITH head AS
                 (SELECT 'A' AS transport,
                        'SCHOOL' AS payment_type,
                        'BASE' AS category,
                        6 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'A' AS transport,
                        'SCHOOL' AS payment_type,
                        'HALF_COST' AS category,
                        7 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'A' AS transport,
                        'STUDENT' AS payment_type,
                        'BASE' AS category,
                        14 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'A' AS transport,
                        'STUDENT' AS payment_type,
                        'HALF_COST' AS category,
                        15 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'A' AS transport,
                        'CITY_MIFARE' AS payment_type,
                        'BASE' AS category,
                        27 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'A' AS transport,
                        'CITY_MIFARE' AS payment_type,
                        'HALF_MONTH' AS category,
                        28 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'A' AS transport,
                        'CITY_MIFARE' AS payment_type,
                        'ORGANISATION' AS category,
                        29 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'A' AS transport,
                        'CASH' AS payment_type,
                        'NONE' AS category,
                        35 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'A' AS transport,
                        'VISA' AS payment_type,
                        'NONE' AS category,
                        36 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'T' AS transport,
                        'SCHOOL' AS payment_type,
                        'BASE' AS category,
                        6 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'T' AS transport,
                        'SCHOOL' AS payment_type,
                        'HALF_COST' AS category,
                        7 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'T' AS transport,
                        'STUDENT' AS payment_type,
                        'BASE' AS category,
                        14 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'T' AS transport,
                        'STUDENT' AS payment_type,
                        'HALF_COST' AS category,
                        15 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'T' AS transport,
                        'CITY_MIFARE' AS payment_type,
                        'BASE' AS category,
                        27 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'T' AS transport,
                        'CITY_MIFARE' AS payment_type,
                        'HALF_MONTH' AS category,
                        28 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'T' AS transport,
                        'CITY_MIFARE' AS payment_type,
                        'ORGANISATION' AS category,
                        29 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'T' AS transport,
                        'CASH' AS payment_type,
                        'NONE' AS category,
                        35 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'T' AS transport,
                        'VISA' AS payment_type,
                        'NONE' AS category,
                        36 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'AT' AS transport,
                        'SCHOOL' AS payment_type,
                        'BASE' AS category,
                        9 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'AT' AS transport,
                        'SCHOOL' AS payment_type,
                        'HALF_COST' AS category,
                        10 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'AT' AS transport,
                        'SCHOOL' AS payment_type,
                        'FREE' AS category,
                        11 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'AT' AS transport,
                        'STUDENT' AS payment_type,
                        'BASE' AS category,
                        17 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'AT' AS transport,
                        'STUDENT' AS payment_type,
                        'HALF_COST' AS category,
                        18 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'AT' AS transport,
                        'STUDENT' AS payment_type,
                        'FREE' AS category,
                        19 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'AT' AS transport,
                        'PRIVILEGE' AS payment_type,
                        'CITY_PRIVILEGE' AS category,
                        21 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'AT' AS transport,
                        'PRIVILEGE' AS payment_type,
                        'FEDERAL_PRIVILEGE' AS category,
                        22 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'AT' AS transport,
                        'PRIVILEGE' AS payment_type,
                        'REGIONAL_PRIVILEGE' AS category,
                        23 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'AT' AS transport,
                        'CITY_MIFARE' AS payment_type,
                        'BASE' AS category,
                        31 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'AT' AS transport,
                        'CITY_MIFARE' AS payment_type,
                        'HALF_MONTH' AS category,
                        32 AS row_num
                   FROM dual
                 UNION ALL
                 SELECT 'AT' AS transport,
                        'CITY_MIFARE' AS payment_type,
                        'ORGANISATION' AS category,
                        33 AS row_num
                   FROM dual),
                car AS
                 (SELECT 'AT' AS transport,
                        'A' AS carrier
                   FROM dual
                 UNION ALL
                 SELECT 'AT' AS transport,
                        'T' AS carrier
                   FROM dual),
                calc AS
                 (SELECT head.transport,
                        head.payment_type,
                        head.category,
                        head.row_num,
                        nvl(car.carrier, head.transport) AS carrier,
                        cptt.pkg$trep_utility.getCardActiveCount(pBeginDate          => :pActivationBeginDate,
                                                                 pEndDate            => :pActivationEndDate,
                                                                 pTransportShortName => head.transport,
                                                                 pPaymentShortName   => head.payment_type,
                                                                 pCategoryShortName  => head.category) AS active_count,
                        cptt.pkg$trep_utility.getPassCount(pBeginDate                 => :pPassBeginDate,
                                                           pEndDate                   => :pPassEndDate,
                                                           pTransportShortName        => head.transport,
                                                           pPaymentShortName          => head.payment_type,
                                                           pCategoryShortName         => head.category,
                                                           pTransportCarrierShortName => nvl(car.carrier,
                                                                                             head.transport)) AS pass_count
                   FROM head,
                        car
                  WHERE head.transport = car.transport(+)
                  ORDER BY head.row_num),
                calc_coord AS
                 (SELECT DISTINCT calc.transport,
                                 calc.payment_type,
                                 calc.category,
                                 calc.carrier,
                                 calc.row_num,
                                 decode(calc.transport,
                                        'AT',
                                        3,
                                        'A',
                                        5,
                                        'T',
                                        6) AS col_num,
                                 'ACTIVE' AS attrib,
                                 calc.active_count AS val
                   FROM calc
                 UNION ALL
                 SELECT calc.transport,
                        calc.payment_type,
                        calc.category,
                        calc.carrier,
                        calc.row_num,
                        decode(calc.carrier, 'A', 8, 'T', 9) AS col_num,
                        'PASS' AS attrib,
                        calc.pass_count AS val
                   FROM calc)
                SELECT t.name_long        AS transport_name,
                       p.name_long        AS payment_name,
                       cat.name_long      AS category_name,
                       car.name_long      AS carrier_name,
                       decode(calc_coord.attrib, 'ACTIVE', 'Активировал ','Проехал в : ' || car.name_long) as cell_type_name,
                       calc_coord.row_num,
                       calc_coord.col_num,
                       calc_coord.val
                  FROM calc_coord,
                       ref$trep_card_transport t,
                       ref$trep_payment_type   p,
                       ref$trep_card_category  cat,
                       ref$trep_card_transport car
                 WHERE calc_coord.transport = t.short_name(+)
                   AND calc_coord.payment_type = p.short_name(+)
                   AND calc_coord.category = cat.short_name(+)
                   AND calc_coord.carrier = car.short_name(+)
                 ORDER BY row_num,
                          col_num) LOOP
    dbms_output.put_line(rpad('Пригоден в транспорте: ' ||
                              rec.transport_name,
                              45) ||
                         rpad(rec.cell_type_name,
                              25) || rpad(' ' || rec.payment_name, 30) ||
                         rpad(' ' || rec.category_name, 30) ||
                         rpad(' ' || rec.row_num, 10) ||
                         rpad(' ' || rec.col_num, 10) ||
                         rpad(' ' || rec.val, 10));
  END LOOP;
  --to_date('01.12.2016 03:00:00', 'dd.mm.yyyy HH24:MI:SS')
END;
4
pActivationBeginDate
1
13.11.2016
12
pActivationEndDate
1
12.12.2016
12
pPassBeginDate
1
01.12.2016 3:00:00
12
pPassEndDate
1
01.01.2017 3:00:00
12
0
