WITH
--получаем серию
ser AS
 (SELECT series
    FROM cptt.ref$trep_card_series
   WHERE id_payment_type = cptt.pkg$trep_utility.getPaymentId('CASH')/*pPaymentId*/),
--получаем kind
knd AS
 (SELECT decode(cptt.Pkg$trep_Utility.getPaymentId('CASH') /*pPaymentId*/,
                cptt.Pkg$trep_Utility.getPaymentId('VISA'), --Виза
                '32',
                cptt.Pkg$trep_Utility.getPaymentId('CASH'), --Наличка
                14,
                --Все остальное
                17) AS kind
    FROM dual),
--получаем id Оператора, исходя из типа транспорта
oper AS
 (SELECT tro.id_operator
    FROM cptt.ref$trep_transport_operator tro
   WHERE tro.id_transport_type = cptt.pkg$trep_utility.getTransportId('A')/*pTransportId*/),
pass AS
 (SELECT trans.id
    FROM cptt.t_data   trans,
         cptt.division div
   WHERE trans.date_of >= to_date('01.12.2016 03:00:00', 'dd.mm.yyyy HH24:MI:SS')/*pBeginDate*/
     AND trans.date_of < to_date('01.01.2017 03:00:00', 'dd.mm.yyyy HH24:MI:SS')/*pEndDate*/
     AND trans.d = 0 -- не удален
     AND trans.kind IN (SELECT kind FROM knd)
     AND (nvl(trans.new_card_series, trans.card_series) IN
         (SELECT series FROM ser) OR
         ((pPaymentId = cptt.Pkg$trep_Utility.getPaymentId('CASH')) AND trans.card_series IS NULL))
     AND trans.id_division = div.id
     AND div.id_operator IN (SELECT oper.id_operator FROM oper))
SELECT COUNT(1) INTO vCount FROM pass;
