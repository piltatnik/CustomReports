PL/SQL Developer Test script 3.0
234
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
                 (SELECT /*tr.name_long AS name_transport,
                                                           pt.name_long AS name_payment,
                                                           cat.name_long AS name_category,*/
                  nvl(car.carrier, head.transport) AS carrier_short_name,
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
                                                                                       head.transport)) AS pass_count,
                  
                  head.*
                 /*,
                 tr.id  AS id_transport,
                 pt.id  AS id_payment,
                 cat.id AS id_category*/
                   FROM head,
                        car /*,
                                                           cptt.ref$trep_card_transport tr,
                                                           cptt.ref$trep_payment_type   pt,
                                                           cptt.ref$trep_card_category  cat*/
                  WHERE head.transport = car.transport(+) /*
                                                      AND head.transport = tr.short_name(+)
                                                      AND head.payment_type = pt.short_name(+)
                                                      AND head.category = cat.short_name(+)*/
                  ORDER BY head.row_num)
                SELECT * FROM calc) LOOP
    dbms_output.put_line(/*lpad('Пригоден в транспорте: ' ||
                              rec.name_transport,
                              45) ||
                         lpad('Проехал в : ' || rec.carrier_short_name,
                              15) || lpad(' ' || rec.name_payment, 30) ||
                         lpad(' ' || rec.name_category, 30) ||
                         */lpad(' ' || rec.active_count, 10) ||
                         lpad(' ' || rec.pass_count, 10));
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
