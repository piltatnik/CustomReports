CREATE OR REPLACE PACKAGE pkg$trep_reports IS

  -- Author  : PILARTSER
  -- Created : 29.01.2017 11:31:14
  -- Purpose : Транспортные отчеты(Рязань)
  PROCEDURE fillActivationSeriesPrivilege(pActivationBeginDate IN DATE,
                                          pActivationEndDate   IN DATE,
                                          pAllPrivilege        IN VARCHAR2 DEFAULT 'N');
  --Заполнение активаций по сериям
  PROCEDURE fillActivationSeries(pActivationBeginDate IN DATE,
                                 pActivationEndDate   IN DATE);

  PROCEDURE fillPassSeriesPrivilegeCarrier(pPassBeginDate IN DATE,
                                           pPassEndDate   IN DATE);

  --Заполнение проездов с группировкой по серии, привилегии и дню
  PROCEDURE fillPassSeriesPrivilegeDay(pPassBeginDate IN DATE,
                                       pPassEndDate   IN DATE);

  --Заполнение проездов, разбитых по привилегиям/перевозчику/маршруту
  PROCEDURE fillPassPrivCarrierRoute(pPassBeginDate IN DATE,
                                     pPassEndDate   IN DATE);

  --Заполнение проездов, разбитых по номерам карт/привилегиям/перевозчику/маршруту
  PROCEDURE fillPassCardPrivCarrierRoute(pPassBeginDate IN DATE,
                                         pPassEndDate   IN DATE);

  --Заполнение проездов разбитых по маршруту/терминалу/дню
  PROCEDURE fillPassRouteTermDay(pPassBeginDate IN DATE,
                                 pPassEndDate   IN DATE);

  --Процедура получения данных за период для залития в отдельную табличку (раз уж партиционированием в t_data и не пахнет)
  PROCEDURE fillData(pPassBeginDate IN DATE, pPassEndDate IN DATE);

  --Получение буквенного представления колонки excel
  FUNCTION getExcelColName(pColNum IN NUMBER) RETURN VARCHAR2;

  --Получение range для большей красоты в запросе
  FUNCTION getRange(pColNameBegin IN VARCHAR2,
                    pRowNumBegin  IN NUMBER,
                    pColNameEnd   IN VARCHAR2,
                    pRowNumEnd    IN NUMBER) RETURN VARCHAR2;

  --получение истинной id_privilege для транзакции (это ненормально!!!)
  --боги хардкода примите мою жертву!
  FUNCTION getIdPrivilegeTrue(pSeries IN VARCHAR2, pIdPrivilege IN NUMBER)
    RETURN NUMBER;

  --аббревиатура маршрута
  FUNCTION getRouteName(pIdRoute IN NUMBER) RETURN VARCHAR;

  --наименование первозчика
  FUNCTION getCarrierName(pIdRoute IN NUMBER) RETURN VARCHAR;

  --Формирование списка заблокированных агентов
  PROCEDURE setAgentLockedState(pAgentsStateList IN CLOB);

  --Формирование отчета Инвестора-Оператора о количестве фактически совершенных поездок в транспортных средствах
  PROCEDURE fillReportActivePassExcel(pActivationBeginDate         IN DATE,
                                      pActivationEndDate           IN DATE,
                                      pPassBeginDate               IN DATE,
                                      pPassEndDate                 IN DATE,
                                      pIsRegionalPrivilegeSplitted IN VARCHAR2 DEFAULT 'N');

  --отчет по активации проездных агентами
  PROCEDURE fillReportActiveAgents(pActivationBeginDate IN DATE,
                                   pActivationEndDate   IN DATE);

  PROCEDURE fillReportPrivilegeExcel(pActivationBeginDate IN DATE,
                                     pActivationEndDate   IN DATE,
                                     pPassBeginDate       IN DATE,
                                     pPassEndDate         IN DATE);

  --Отчет по маршруту
  PROCEDURE fillReportRouteExcel(pIdRoute       IN NUMBER,
                                 pPassBeginDate IN DATE,
                                 pPassEndDate   IN DATE);

  --Отчет по терминалу кондуктора(обязательно предварительн орассчитать fillDataTerminal)
  PROCEDURE fillReportTerminalExcel(pIdTerminal    IN NUMBER,
                                    pPassBeginDate IN DATE,
                                    pPassEndDate   IN DATE);

  PROCEDURE fillReportTransactionExcel(pPassBeginDate IN DATE,
                                       pPassEndDate   IN DATE);

  PROCEDURE fillReportVehicleExcel(pIdVehicle IN NUMBER, pPassBeginDate IN DATE, pPassEndDate IN DATE);

END pkg$trep_reports;
/
CREATE OR REPLACE PACKAGE BODY pkg$trep_reports IS

  CRLF VARCHAR2(3) :=  /*chr(10) ||*/
   chr(13);
  --Заполнение активированных карт с группировкой по серии и привилегии
  PROCEDURE fillActivationSeriesPrivilege(pActivationBeginDate IN DATE,
                                          pActivationEndDate   IN DATE,
                                          pAllPrivilege        IN VARCHAR2 DEFAULT 'N') AS
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
                 WHEN nvl(trans.new_card_series, trans.card_series) IN ('50') THEN
                  '150'
                 WHEN nvl(trans.new_card_series, trans.card_series) IN ('52') THEN
                  '252'
                 WHEN nvl(trans.new_card_series, trans.card_series) IN ('53') THEN
                  '353'
                 ELSE
                  nvl(trans.new_card_series, trans.card_series)
               END AS series,
               decode(nvl(trans.new_card_series, trans.card_series),
                      '17',
                      trans.id_privilege,
                      decode(pAllPrivilege,
                             'Y',
                             getIdPrivilegeTrue(nvl(trans.new_card_series,
                                                    trans.card_series),
                                                id_privilege),
                             NULL)) AS id_privilege
        FROM cptt.t_data   trans,
             cptt.division div
        WHERE trans.kind IN (7, 8, 10, 11, 12, 13) --активация
        AND trans.d = 0 -- не удален
        AND ((nvl(trans.new_card_series, trans.card_series) IN
              ('50', '52', '53') AND
              trunc(trans.date_of) >= trunc(pActivationEndDate, 'mm') AND
              trunc(trans.date_of) <=
              add_months(trunc(pActivationEndDate, 'mm'), 1) - 15) OR
              ((nvl(trans.new_card_series, trans.card_series) NOT IN
              ('50', '52', '53') AND
              trunc(trans.date_of) >= pActivationBeginDate --период активации
              AND trunc(trans.date_of) <= pActivationEndDate))) --
             
        AND trans.id_division = div.id --отбрасываем тестовых операторов
        AND div.id_operator NOT IN
              (SELECT id FROM cptt.ref$trep_agents_locked))
      SELECT series,
             id_privilege,
             nvl(COUNT(1), 0) AS count_active,
             nvl(SUM(amount), 0) AS sum_active
      FROM trans_activation
      GROUP BY series,
               id_privilege;
    COMMIT;
  END;

  --Заполнение активаций по сериям
  PROCEDURE fillActivationSeries(pActivationBeginDate IN DATE,
                                 pActivationEndDate   IN DATE) AS
  BEGIN
    DELETE FROM cptt.tmp$trep_active_seriesagents;
    FOR rec IN (WITH trans AS
                   (SELECT nvl(trans.new_card_series, trans.card_series) AS series,
                          div.id_operator,
                          nvl(amount, 0) - nvl(amount_bail, 0) AS amount,
                          nvl(amount_bail, 0) AS amount_bail
                   FROM cptt.t_data   trans,
                        cptt.division div
                   WHERE trans.kind IN (7, 8, 10, 11, 12, 13) --активация
                   AND trans.d = 0 -- не удален
                   AND ((nvl(trans.new_card_series, trans.card_series) IN
                         ('50', '52', '53') AND
                         trunc(trans.date_of) >=
                         trunc(pActivationEndDate, 'mm') AND
                         trunc(trans.date_of) <=
                         add_months(trunc(pActivationEndDate, 'mm'), 1) - 15) OR
                         ((nvl(trans.new_card_series, trans.card_series) NOT IN
                         ('50', '52', '53') AND
                         trunc(trans.date_of) >= pActivationBeginDate --период активации
                         AND trunc(trans.date_of) <= pActivationEndDate))) --
                        
                   AND trans.id_division = div.id --отбрасываем тестовых операторов
                   AND div.id_operator NOT IN
                         (SELECT id FROM cptt.ref$trep_agents_locked))
                  SELECT series,
                         id_operator,
                         COUNT(1) AS count_active,
                         nvl(SUM(amount), 0) AS sum_active,
                         nvl(SUM(amount_bail), 0) AS sum_bail
                  FROM trans
                  GROUP BY series,
                           id_operator)
    LOOP
      INSERT INTO cptt.tmp$trep_active_seriesagents
        (series,
         id_operator,
         count_active,
         sum_active,
         sum_bail)
      VALUES
        (rec.series,
         rec.id_operator,
         rec.count_active,
         rec.sum_active,
         rec.sum_bail);
    END LOOP;
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
                   AND id IN (400246845, 500246845)),
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
                            WHEN nvl(trans.new_card_series, trans.card_series) IN
                                 ('50') THEN
                             '150'
                            WHEN nvl(trans.new_card_series, trans.card_series) IN
                                 ('52') THEN
                             '252'
                            WHEN nvl(trans.new_card_series, trans.card_series) IN
                                 ('53') THEN
                             '353'
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
                   WHEN nvl(trans.new_card_series, trans.card_series) IN
                        ('50') THEN
                    '150'
                   WHEN nvl(trans.new_card_series, trans.card_series) IN
                        ('52') THEN
                    '252'
                   WHEN nvl(trans.new_card_series, trans.card_series) IN
                        ('53') THEN
                    '353'
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

  --Заполнение проездов, разбитых по привилегиям/перевозчику/маршруту
  PROCEDURE fillPassPrivCarrierRoute(pPassBeginDate IN DATE,
                                     pPassEndDate   IN DATE) AS
  BEGIN
    DELETE FROM cptt.tmp$trep_pass_privoproute;
    FOR rec IN (WITH rt AS
                   (SELECT r.id
                   FROM ROUTE                r,
                        division             div,
                        cptt.v$trep_carriers c
                   WHERE r.id_division = div.id
                   AND div.id_operator = c.id_operator),
                  pass AS
                   (SELECT trans.card_num,
                          getIdPrivilegeTrue(nvl(trans.new_card_series,
                                                 trans.card_series),
                                             trans.id_privilege) AS id_privilege,
                          carrier.id_operator,
                          trans.id_route
                   FROM cptt.t_data          trans,
                        cptt.division        div,
                        cptt.v$trep_carriers carrier,
                        cptt.privilege       priv,
                        rt
                   WHERE trans.date_of >= pPassBeginDate
                   AND trans.date_of < pPassEndDate
                   AND trans.d = 0 -- не удален
                   AND trans.kind IN ('32', '14', '17')
                   AND trans.id_division = div.id
                   AND div.id_operator = carrier.id_operator
                   AND trans.id_privilege = priv.id
                   AND trans.id_route = rt.id)
                  SELECT id_privilege,
                         id_operator,
                         id_route,
                         COUNT(1) AS count_pass
                  FROM pass
                  GROUP BY id_privilege,
                           id_operator,
                           id_route)
    LOOP
      INSERT INTO cptt.tmp$trep_pass_privoproute
        (id_privilege,
         id_operator,
         id_route,
         count_pass)
      VALUES
        (rec.id_privilege,
         rec.id_operator,
         rec.id_route,
         rec.count_pass);
    END LOOP;
  
    COMMIT;
  END;

  --Заполнение проездов, разбитых по номерам карт/привилегиям/перевозчику/маршруту
  PROCEDURE fillPassCardPrivCarrierRoute(pPassBeginDate IN DATE,
                                         pPassEndDate   IN DATE) AS
  BEGIN
    DELETE FROM cptt.tmp$trep_pass_cardprivoproute;
    FOR rec IN (WITH carrier AS
                   (SELECT id AS id_operator
                   FROM operator
                   WHERE role = 1
                   AND id NOT IN (2200246845,
                                 4100246845, /*маршрутки сейчас исключены*/
                                 16100246845)),
                  rt AS
                   (SELECT r.id
                   FROM ROUTE    r,
                        division div,
                        carrier  c
                   WHERE r.id_division = div.id
                   AND div.id_operator = c.id_operator),
                  pass AS
                   (SELECT trans.card_num,
                          cptt.pkg$trep_reports.getIdPrivilegeTrue(nvl(trans.new_card_series,
                                                                       trans.card_series),
                                                                   trans.id_privilege) AS id_privilege,
                          carrier.id_operator,
                          trans.id_route
                   FROM cptt.t_data    trans,
                        cptt.division  div,
                        carrier,
                        cptt.privilege priv,
                        rt
                   WHERE trans.date_of >= pPassBeginDate
                   AND trans.date_of < pPassEndDate
                   AND trans.d = 0 -- не удален
                   AND trans.kind IN ('32', '14', '17')
                   AND trans.id_division = div.id
                   AND div.id_operator = carrier.id_operator
                   AND trans.id_privilege = priv.id
                   AND trans.id_route = rt.id)
                  SELECT card_num,
                         id_privilege,
                         id_operator,
                         id_route,
                         COUNT(1) AS count_pass
                  FROM pass
                  GROUP BY card_num,
                           id_privilege,
                           id_operator,
                           id_route)
    LOOP
      INSERT INTO cptt.tmp$trep_pass_cardprivoproute
        (card_num,
         id_privilege,
         id_operator,
         id_route,
         count_pass)
      VALUES
        (rec.card_num,
         rec.id_privilege,
         rec.id_operator,
         rec.id_route,
         rec.count_pass);
    END LOOP;
    COMMIT;
  END;

  --Заполнение проездов разбитых по маршруту/терминалу/дню
  PROCEDURE fillPassRouteTermDay(pPassBeginDate IN DATE,
                                 pPassEndDate   IN DATE) AS
  BEGIN
    DELETE FROM cptt.tmp$trep_pass_routetermday;
    FOR rec IN (WITH rt AS
                   (SELECT r.id
                   FROM ROUTE                r,
                        division             div,
                        cptt.v$trep_carriers c
                   WHERE r.id_division = div.id
                   AND div.id_operator = c.id_operator),
                  dates AS
                   (SELECT pPassBeginDate + LEVEL - 1 AS begin_date
                   FROM dual
                   START WITH pPassBeginDate < pPassEndDate
                   CONNECT BY pPassBeginDate + LEVEL - 1 < pPassEndDate
                   ORDER BY LEVEL),
                  pass AS
                   (SELECT trans.id_route,
                          trans.id_term,
                          dates.begin_date AS DAY
                   FROM cptt.t_data          trans,
                        cptt.division        div,
                        cptt.v$trep_carriers carrier,
                        rt,
                        dates
                   WHERE trans.date_of >= pPassBeginDate
                   AND trans.date_of < pPassEndDate
                   AND trans.d = 0 -- не удален
                   AND trans.kind IN ('32', '14', '17')
                   AND trans.id_division = div.id
                   AND div.id_operator = carrier.id_operator
                   AND trans.id_route = rt.id
                   AND trans.date_of >= dates.begin_date
                   AND trans.date_of < dates.begin_date + 1)
                  SELECT id_route,
                         id_term,
                         DAY,
                         COUNT(1) AS count_pass
                  FROM pass
                  GROUP BY id_route,
                           id_term,
                           DAY)
    LOOP
      INSERT INTO cptt.tmp$trep_pass_routetermday
        (id_route,
         id_term,
         DAY,
         count_pass)
      VALUES
        (rec.id_route,
         rec.id_term,
         rec.day,
         rec.count_pass);
    END LOOP;
    COMMIT;
  END;

  --Процедура получения данных за период для залития в отдельную табличку (раз уж партиционированием в t_data и не пахнет)
  PROCEDURE fillData(pPassBeginDate IN DATE, pPassEndDate IN DATE) AS
  BEGIN
    DELETE FROM cptt.tmp$trep_data;
    FOR rec IN (SELECT trans.kind,
                       trans.date_of,
                       nvl(trans.amount, 0) - nvl(trans.amount_bail, 0) AS amount,
                       trans.id_term,
                       trans.id_route,
                       nvl(trans.new_card_series, trans.card_series) AS series,
                       getIdPrivilegeTrue(nvl(trans.new_card_series,
                                                    trans.card_series),
                                          trans.id_privilege) as id_privilege,
                       trans.train_table,
                       trans.id_vehicle,
                       trans.file_rn
                FROM cptt.t_data          trans,
                     cptt.division        div,
                     cptt.v$trep_carriers car
                WHERE trans.date_of >= pPassBeginDate
                AND trans.date_of < pPassEndDate
                AND trans.d = 0
                AND trans.kind IN ('1', '2', '32', '14', '17')
                AND trans.id_route IS NOT NULL
                AND trans.id_term IS NOT NULL
                AND trans.id_division = div.id
                AND div.id_operator = car.id_operator)
    LOOP
      INSERT INTO cptt.tmp$trep_data
        (id_term,
         series,
         kind,
         date_of,
         amount,
         id_privilege,
         id_route,
         id_vehicle,
         train_table,
         file_rn)
      VALUES
        (rec.id_term,
         rec.series,
         rec.kind,
         rec.date_of,
         rec.amount,
         rec.id_privilege,
         rec.id_route,
         rec.id_vehicle,
         rec.train_table,
         rec.file_rn);
    END LOOP;
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

  --Получение range для большей красоты в запросе
  FUNCTION getRange(pColNameBegin IN VARCHAR2,
                    pRowNumBegin  IN NUMBER,
                    pColNameEnd   IN VARCHAR2,
                    pRowNumEnd    IN NUMBER) RETURN VARCHAR2 AS
  BEGIN
    RETURN pColNameBegin || to_char(pRowNumBegin) || ':' || pColNameEnd || to_char(pRowNumEnd);
  END;

  --получение истинной id_privilege для транзакции (это ненормально!!!)
  --боги хардкода примите мою жертву!
  FUNCTION getIdPrivilegeTrue(pSeries IN VARCHAR2, pIdPrivilege IN NUMBER)
    RETURN NUMBER AS
    vIdPrivilege NUMBER;
  BEGIN
    SELECT CASE
           --хоть ты синтетическую серию сюда кинь, хоть нет, враг не пройдет
             WHEN pSeries LIKE '1%' OR pSeries LIKE '2%' OR
                  pSeries LIKE '3%' THEN
              CASE
              --студент
                WHEN pSeries LIKE '_1' THEN
                 1000246845
              --студент_50
                WHEN pSeries LIKE '_2' THEN
                 1100246845
              --студент_100
                WHEN pSeries LIKE '_3' THEN
                 1200246845
              --школьник
                WHEN pSeries LIKE '_4' THEN
                 1300246845
              --школьник_50
                WHEN pSeries LIKE '_5' THEN
                 1400246845
              --школьник_100
                WHEN pSeries LIKE '_6' THEN
                 1500246845
                ELSE
                 pIdPrivilege
              END
             ELSE
              pIdPrivilege
           END
    INTO vIdPrivilege
    FROM dual;
    RETURN vIdPrivilege;
  END;

  --аббревиатура маршрута
  FUNCTION getRouteName(pIdRoute IN NUMBER) RETURN VARCHAR AS
    RESULT VARCHAR2(10);
  BEGIN
    SELECT decode(c.id_operator, 400246845, 'T', 500246845, 'A', 'UNKNOWN') ||
           r.code
    INTO RESULT
    FROM ROUTE                r,
         division             div,
         cptt.v$trep_carriers c
    WHERE r.id_division = div.id
    AND div.id_operator = c.id_operator
    AND r.id = pIdRoute;
    RETURN RESULT;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 'UNKNOWN';
  END;

  --наименование первозчика
  FUNCTION getCarrierName(pIdRoute IN NUMBER) RETURN VARCHAR AS
    RESULT VARCHAR2(10);
  BEGIN
    SELECT c.operator_name
    INTO RESULT
    FROM ROUTE                r,
         division             div,
         cptt.v$trep_carriers c
    WHERE r.id_division = div.id
    AND div.id_operator = c.id_operator
    AND r.id = pIdRoute;
    RETURN RESULT;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 'UNKNOWN';
  END;

  --установка заблокированности агента
  PROCEDURE setAgentLockedState(pIdOperator IN NUMBER,
                                pIsLocked   IN VARCHAR2) AS
    vCntAgent NUMBER;
  BEGIN
    IF (pIsLocked = 'Y') THEN
      SELECT COUNT(0)
      INTO vCntAgent
      FROM cptt.ref$trep_agents_locked
      WHERE id = pIdOperator;
      IF (vCntAgent = 0) THEN
        INSERT INTO cptt.ref$trep_agents_locked (id) VALUES (pIdOperator);
      END IF;
    ELSE
      DELETE FROM cptt.ref$trep_agents_locked tal
      WHERE tal.id = pIdOperator;
    END IF;
  END;

  --Формирование списка заблокированных агентов
  PROCEDURE setAgentLockedState(pAgentsStateList IN CLOB) AS
    vXml sys.xmltype;
  BEGIN
    IF pAgentsStateList IS NOT NULL THEN
      vXml := xmltype(pAgentsStateList);
      FOR rec IN (SELECT extractValue(VALUE(t), 'agent/id') AS id,
                         extractValue(VALUE(t), 'agent/state') AS state
                  FROM TABLE(XMLSequence(vXml.extract('agents/agent'))) t)
      LOOP
        setAgentLockedState(rec.id, rec.state);
      END LOOP;
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        ROLLBACK;
        raise_application_error(-20020,
                                'Ошибка формирования списка заблокированных агентов');
      END;
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
                            WHEN series IN ('150', '252', '353') THEN
                             '      граждане (на полмесяца)'
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
                            WHEN series IN ('252', '353') THEN
                             30 + vCityPrivilegeCount +
                             vRegionalPrivilegeCount
                            WHEN series IN ('242', '343') THEN
                             31 + vCityPrivilegeCount +
                             vRegionalPrivilegeCount
                            WHEN series IN ('19') THEN
                             33 + vCityPrivilegeCount +
                             vRegionalPrivilegeCount
                            WHEN series IN ('150') THEN
                             34 + vCityPrivilegeCount +
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
                   --
                   /*
                   UNION ALL
                   SELECT NULL AS point,
                          '      граждане (на полмесяца)',
                          30 + vCityPrivilegeCount + vRegionalPrivilegeCount AS row_num
                   FROM dual
                   UNION ALL
                   SELECT NULL AS point,
                          '      граждане (на полмесяца)',
                          34 + vCityPrivilegeCount + vRegionalPrivilegeCount AS row_num
                   FROM dual
                   */
                   --
                   ),
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
                   FROM (SELECT NULL AS point,
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
                               25 + vCityPrivilegeCount +
                               vRegionalPrivilegeCount)
                   WHERE nvl(pIsRegionalPrivilegeSplitted, 'N') = 'Y'
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
                          '=SUM(C' || to_char(24 + vCityPrivilegeCount) || ',' ||
                          --
                           decode(nvl(pIsRegionalPrivilegeSplitted, 'N'),
                                  'N',
                                  'C' || to_char(25 + vCityPrivilegeCount) || ',',
                                  '')
                          --
                           || listagg('C' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS c_column,
                          NULL AS e_column,
                          NULL AS f_column,
                          '=ROUND(SUM(F' ||
                           to_char(24 + vCityPrivilegeCount) || ',' ||
                          --
                           decode(nvl(pIsRegionalPrivilegeSplitted, 'N'),
                                  'N',
                                  'F' || to_char(25 + vCityPrivilegeCount) || ',',
                                  '')
                          --
                           || listagg('F' || row_num, ',') within GROUP(ORDER BY row_num) || '), 2)' AS f_column_2_3,
                          '=SUM(H' || to_char(24 + vCityPrivilegeCount) || ',' ||
                          --
                           decode(nvl(pIsRegionalPrivilegeSplitted, 'N'),
                                  'N',
                                  'H' || to_char(25 + vCityPrivilegeCount) || ',',
                                  '')
                          --
                           || listagg('H' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS h_column,
                          '=SUM(I' || to_char(24 + vCityPrivilegeCount) || ',' ||
                          --
                           decode(nvl(pIsRegionalPrivilegeSplitted, 'N'),
                                  'N',
                                  'I' || to_char(25 + vCityPrivilegeCount) || ',',
                                  '')
                          --
                           || listagg('I' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS i_column,
                          '=SUM(G' || to_char(24 + vCityPrivilegeCount) || ',' ||
                          --
                           decode(nvl(pIsRegionalPrivilegeSplitted, 'N'),
                                  'N',
                                  'G' || to_char(25 + vCityPrivilegeCount) || ',',
                                  '')
                          --
                           || listagg('G' || row_num, ',') within GROUP(ORDER BY row_num) || ')' AS g_column_2_3
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
                          'Транспортная карта ' || CRLF ||
                          'стандарта Ultralight' || CRLF ||
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
                                         'FM999999999999990.0000')) AS VALUE
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
                                         'FM999999999999990.0000')) AS VALUE
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
                                         'FM999999999999990.0000')) AS VALUE
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

  --отчет по активации проездных агентами
  PROCEDURE fillReportActiveAgents(pActivationBeginDate IN DATE,
                                     pActivationEndDate   IN DATE) AS
      vAgentsCnt NUMBER;
      vSeriesCnt NUMBER;
    BEGIN
      DELETE FROM cptt.TMP$TREP_REPORT_EXCEL;
      DELETE FROM cptt.tmp$trep_report_excel_format;
    
      SELECT COUNT(1)
      INTO vAgentsCnt
      FROM cptt.operator
      WHERE role = 2
      AND id NOT IN (SELECT id FROM cptt.ref$trep_agents_locked);
      SELECT COUNT(DISTINCT series)
      INTO vSeriesCnt
      FROM cptt.REF$TREP_SERIES
      WHERE id_pay_type = 1;
      FOR rec IN (WITH agents AS
                     (SELECT id AS id_operator,
                            NAME AS operator_name,
                            row_number() over(ORDER BY NAME) AS operator_num
                     FROM cptt.operator
                     WHERE role = 2
                     AND id NOT IN (SELECT id FROM cptt.ref$trep_agents_locked)),
                    ser AS
                     (SELECT DISTINCT series,
                                     REPLACE(decode(series,
                                                    '17',
                                                    'Городские/федеральные/региональные льготники',
                                                    name_long),
                                             ',',
                                             ',' || CRLF) AS series_name
                     FROM cptt.REF$TREP_SERIES
                     WHERE id_pay_type = 1),
                    cat AS
                     (SELECT series_name,
                            series,
                            row_number() over(PARTITION BY series_name ORDER BY series) AS ser_cat_num
                     FROM ser),
                    cat_counted AS
                     (SELECT series_name,
                            COUNT(1) AS cnt_series
                     FROM cat
                     GROUP BY series_name),
                    cat_ordered AS
                     (SELECT cat.series,
                            cat.series_name,
                            cat.ser_cat_num,
                            cat_counted.cnt_series
                     FROM cat_counted,
                          cat
                     WHERE cat_counted.series_name = cat.series_name
                     ORDER BY cat_counted.cnt_series ASC,
                              decode(cat_counted.cnt_series,
                                     1,
                                     cat.series,
                                     cat.series_name) ASC,
                              cat.ser_cat_num ASC),
                    cat_ordered_num AS
                     (SELECT co.series,
                            co.series_name,
                            co.cnt_series,
                            (rownum - 1) * 2 AS col_num
                     FROM cat_ordered co),
                    cat_head AS
                     (SELECT con.series_name,
                            con.cnt_series,
                            MIN(col_num) AS col_num
                     FROM cat_ordered_num con
                     GROUP BY series_name,
                              cnt_series),
                    agents_series AS
                     (SELECT a.operator_num,
                            a.id_operator,
                            con.col_num,
                            con.series
                     FROM agents          a,
                          cat_ordered_num con),
                    data AS
                     (SELECT a_s.operator_num,
                            a_s.col_num,
                            nvl(tas.count_active, 0) AS count_active,
                            nvl(tas.sum_active, 0) AS sum_active,
                            nvl(tas.sum_bail, 0) AS sum_bail
                     FROM agents_series                     a_s,
                          cptt.tmp$trep_active_seriesagents tas
                     WHERE a_s.id_operator = tas.id_operator(+)
                     AND a_s.series = tas.series(+))
                    --Заголовок с периодом
                    select 1 as row_num,
                           'B' as col_name,
                           'Отчет по активации проездных агентами '||
                           'за период с '||to_char(pActivationBeginDate, 'dd.mm.yyyy HH24:MI:SS')||
                           ' по '||to_char(pActivationEndDate, 'dd.mm.yyyy HH24:MI:SS') as value
                    from dual
                    --
                    union all
                    --Заголовок с категориями
                    SELECT 3 AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(2 + col_num) AS col_name,
                           to_char(series_name) AS VALUE
                    FROM cat_head
                    --
                    UNION ALL
                    --Заголовок с сериями
                    SELECT 4 AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(2 + col_num) AS col_name,
                           series AS VALUE
                    FROM cat_ordered_num
                    --
                    UNION ALL
                    --Заголовок кол-во
                    SELECT 5 AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(2 + col_num) AS col_name,
                           'Кол-во' AS VALUE
                    FROM cat_ordered_num
                    --
                    UNION ALL
                    --Заголовок сумма
                    SELECT 5 AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(2 + col_num + 1) AS col_name,
                           'Сумма' AS VALUE
                    FROM cat_ordered_num
                    --
                    UNION ALL
                    --Заголовок агенты
                    SELECT 3 AS row_num,
                           'A' AS col_name,
                           'Агенты' AS VALUE
                    FROM dual
                    --
                    UNION ALL
                    --Список агентов
                    SELECT 5 + operator_num AS row_num,
                           'A' AS col_name,
                           operator_name AS VALUE
                    FROM agents
                    --
                    UNION all
                    --заголовок стоимость бланка
                     SELECT  3 as row_num,
                             cptt.pkg$trep_reports.getExcelColName(1 + vSeriesCnt * 2 + 1) AS col_name,
                            'Ст-ть бланка' as value
                     FROM dual
                    --
                    UNION all
                    --заголовок стоимость бланка
                     SELECT  3 as row_num,
                             cptt.pkg$trep_reports.getExcelColName(1 + vSeriesCnt * 2 + 2) AS col_name,
                            'Сумма за проездные' as value
                     FROM dual
                    --
                    UNION all
                    --заголовок стоимость бланка
                     SELECT  3 as row_num,
                             cptt.pkg$trep_reports.getExcelColName(1 + vSeriesCnt * 2 + 3) AS col_name,
                            'Общая сумма' as value
                     FROM dual
                    --
                    UNION all
                    --заголовок стоимость бланка
                     SELECT  3 as row_num,
                             cptt.pkg$trep_reports.getExcelColName(1 + vSeriesCnt * 2 + 4) AS col_name,
                            'АК' as value
                     FROM dual
                    --
                    UNION all
                    --заголовок стоимость бланка
                     SELECT  3 as row_num,
                             cptt.pkg$trep_reports.getExcelColName(1 + vSeriesCnt * 2 + 5) AS col_name,
                            'УРТ' as value
                     FROM dual
                     --
                    UNION all
                    --заголовок стоимость бланка
                     SELECT  3 as row_num,
                             cptt.pkg$trep_reports.getExcelColName(1 + vSeriesCnt * 2 + 6) AS col_name,
                            'АК + УРТ' as value
                     FROM dual
                    --
                    UNION ALL
                    --данные по количеству
                    SELECT 5 + operator_num AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(2 + col_num) AS col_name,
                           to_char(count_active) AS VALUE
                    FROM data
                    --
                    UNION ALL
                    --данные по сумме
                    SELECT 5 + operator_num AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(2 + col_num + 1) AS col_name,
                           to_char(sum_active) AS VALUE
                    FROM data
                    --
                    UNION ALL
                    --стоимость бланков
                    SELECT 5 + operator_num AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(1 +
                                                                 vSeriesCnt * 2 + 1) AS col_name,
                           to_char(SUM(sum_bail)) AS VALUE
                    FROM data
                    GROUP BY operator_num
                    --
                    UNION ALL
                    --стоимость бланков
                    SELECT 5 + operator_num AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(1 +
                                                                 vSeriesCnt * 2 + 2) AS col_name,
                           to_char(SUM(sum_active)) AS VALUE
                    FROM data
                    GROUP BY operator_num
                    --
                    UNION ALL
                    --общая стоимость
                    SELECT 5 + operator_num AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(1 +
                                                                 vSeriesCnt * 2 + 3) AS col_name,
                           to_char(SUM(sum_bail + sum_active)) AS VALUE
                    FROM data
                    GROUP BY operator_num
                    --
                    UNION ALL
                    --АК
                    SELECT 5 + operator_num AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(1 +
                                                                 vSeriesCnt * 2 + 4) AS col_name,
                           '=SUM(' ||
                           listagg(cptt.pkg$trep_reports.getExcelColName(2 + col_num + 1) ||
                                   to_char(5 + operator_num) || CASE
                                     WHEN series IN ('31',
                                                     '32',
                                                     '33',
                                                     '34',
                                                     '35',
                                                     '36',
                                                     '39',
                                                     '53',
                                                     '43',
                                                     '46') THEN
                                      ''
                                     ELSE
                                      '*0.4'
                                   END,
                                   ',') within GROUP(ORDER BY col_num) || ')*0.75' AS VALUE
                    FROM agents_series
                    WHERE series IN ('31',
                                '32',
                                '33',
                                '34',
                                '35',
                                '36',
                                '39',
                                '53',
                                '43',
                                '46',
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
                                '44')
                    GROUP BY operator_num
                    --
                    UNION ALL
                    --УРТ
                    SELECT 5 + operator_num AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(1 +
                                                                 vSeriesCnt * 2 + 5) AS col_name,
                           '=SUM(' || listagg(cptt.pkg$trep_reports.getExcelColName(2 +
                                                                                    col_num + 1) ||
                                              to_char(5 + operator_num) || CASE
                                                WHEN series IN ('21',
                                                                '22',
                                                                '23',
                                                                '24',
                                                                '25',
                                                                '26',
                                                                '29',
                                                                '52',
                                                                '42',
                                                                '45') THEN
                                                 ''
                                                ELSE
                                                 '*0.6'
                                              END,
                                              ',') within GROUP(ORDER BY col_num) || ')*0.75' AS VALUE
                    FROM agents_series
                    WHERE series IN ('21',
                                '22',
                                '23',
                                '24',
                                '25',
                                '26',
                                '29',
                                '52',
                                '42',
                                '45',
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
                                '44')
                    GROUP BY operator_num
                    --
                    UNION ALL
                    --АК + УРТ
                    SELECT 5 + operator_num AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(1 +
                                                                 vSeriesCnt * 2 + 6) AS col_name,
                           '=SUM(' ||
                           cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                vSeriesCnt * 2 + 4),
                                                          5 + operator_num,
                                                          cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                vSeriesCnt * 2 + 5),
                                                          5 + operator_num) || ')' AS VALUE
                    FROM agents)
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
    
      FOR rec_format IN (WITH ser AS
                            (SELECT DISTINCT series,
                                            decode(series,
                                                   '17',
                                                   'Городские/федеральные/региональные льготники',
                                                   name_long) AS series_name
                            FROM cptt.REF$TREP_SERIES
                            WHERE id_pay_type = 1),
                           cat AS
                            (SELECT series_name,
                                   series,
                                   row_number() over(PARTITION BY series_name ORDER BY series) AS ser_cat_num
                            FROM ser),
                           cat_counted AS
                            (SELECT series_name,
                                   COUNT(1) AS cnt_series
                            FROM cat
                            GROUP BY series_name),
                           cat_ordered AS
                            (SELECT cat.series,
                                   cat.series_name,
                                   cat.ser_cat_num,
                                   cat_counted.cnt_series
                            FROM cat_counted,
                                 cat
                            WHERE cat_counted.series_name = cat.series_name
                            ORDER BY cat_counted.cnt_series ASC,
                                     decode(cat_counted.cnt_series,
                                            1,
                                            cat.series,
                                            cat.series_name) ASC,
                                     cat.ser_cat_num ASC),
                           cat_ordered_num AS
                            (SELECT co.series,
                                   co.series_name,
                                   co.cnt_series,
                                   (rownum - 1) * 2 AS col_num
                            FROM cat_ordered co),
                           cat_head AS
                            (SELECT con.series_name,
                                   con.cnt_series,
                                   MIN(col_num) AS col_num
                            FROM cat_ordered_num con
                            GROUP BY series_name,
                                     cnt_series)
                           --заголовок расшифровки серий
                           SELECT cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(2 +
                                                                                                       col_num),
                                                                 3,
                                                                 cptt.pkg$trep_reports.getExcelColName(2 +
                                                                                                       col_num +
                                                                                                       cnt_series * 2 - 1),
                                                                 3) AS RANGE,
                                  8 AS font_size,
                                  1 AS border,
                                  'Y' AS is_merged
                           FROM cat_head
                           --
                           UNION ALL
                           --заголовок серии
                           SELECT cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(2 +
                                                                                                       col_num),
                                                                 4,
                                                                 cptt.pkg$trep_reports.getExcelColName(2 +
                                                                                                       col_num + 1),
                                                                 4) AS RANGE,
                                  8 AS font_size,
                                  1 AS border,
                                  'Y' AS is_merged
                           FROM cat_ordered_num
                           --
                           UNION ALL
                           --заголовок агенты
                           SELECT cptt.pkg$trep_reports.getRange('A',
                                                                 3,
                                                                 'A',
                                                                 5) AS RANGE,
                                  8 AS font_size,
                                  1 AS border,
                                  'Y' AS is_merged
                           FROM dual
                           --
                           UNION ALL
                           --все данные
                           SELECT cptt.pkg$trep_reports.getRange('A',
                                                                 3,
                                                                 cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                       vSeriesCnt * 2 + 6),
                                                                 5 + vAgentsCnt) AS RANGE,
                                  8 AS font_size,
                                  1 AS border,
                                  'N' AS is_merged
                           FROM dual
                           --
                           UNION ALL
                           --заголовок стоимость бланка
                           SELECT cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                       vSeriesCnt * 2 + 1),
                                                                 3,
                                                                 cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                       vSeriesCnt * 2 + 1),
                                                                 5) AS RANGE,
                                  8 AS font_size,
                                  1 AS border,
                                  'Y' AS is_merged
                           FROM dual
                           --
                           UNION ALL
                           --заголовок сумма проездных
                           SELECT cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                       vSeriesCnt * 2 + 2),
                                                                 3,
                                                                 cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                       vSeriesCnt * 2 + 2),
                                                                 5) AS RANGE,
                                  8 AS font_size,
                                  1 AS border,
                                  'Y' AS is_merged
                           FROM dual
                           --
                           UNION ALL
                           --заголовок общая сумма
                           SELECT cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                       vSeriesCnt * 2 + 3),
                                                                 3,
                                                                 cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                       vSeriesCnt * 2 + 3),
                                                                 5) AS RANGE,
                                  8 AS font_size,
                                  1 AS border,
                                  'Y' AS is_merged
                           FROM dual
                           --
                           UNION ALL
                           --заголовок АК
                           SELECT cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                       vSeriesCnt * 2 + 4),
                                                                 3,
                                                                 cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                       vSeriesCnt * 2 + 4),
                                                                 5) AS RANGE,
                                  8 AS font_size,
                                  1 AS border,
                                  'Y' AS is_merged
                           FROM dual
                           --
                           UNION ALL
                           --заголовок УРТ
                           SELECT cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                       vSeriesCnt * 2 + 5),
                                                                 3,
                                                                 cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                       vSeriesCnt * 2 + 5),
                                                                 5) AS RANGE,
                                  8 AS font_size,
                                  1 AS border,
                                  'Y' AS is_merged
                           FROM dual
                           --
                           UNION ALL
                           --заголовок 2
                           SELECT cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                       vSeriesCnt * 2 + 6),
                                                                 3,
                                                                 cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                       vSeriesCnt * 2 + 6),
                                                                 5) AS RANGE,
                                  8 AS font_size,
                                  1 AS border,
                                  'Y' AS is_merged
                           FROM dual)
      
      LOOP
        INSERT INTO cptt.tmp$trep_report_excel_format
          (list_num,
           RANGE,
           font_size,
           border,
           is_merged)
        VALUES
          (1,
           rec_format.range,
           rec_format.font_size,
           rec_format.border,
           rec_format.is_merged);
      END LOOP COMMIT;
    END;
  
  PROCEDURE fillReportPrivilegeExcel(pActivationBeginDate IN DATE,
                                     pActivationEndDate   IN DATE,
                                     pPassBeginDate       IN DATE,
                                     pPassEndDate         IN DATE) AS
    vCarrierCount   NUMBER;
    vPrivilegeCount NUMBER;
    vRouteCount     NUMBER;
  BEGIN
    DELETE FROM cptt.TMP$TREP_REPORT_EXCEL;
    DELETE FROM cptt.tmp$trep_report_excel_format;
  
    SELECT COUNT(1)
    INTO vCarrierCount
    FROM operator op
    WHERE op.role = 1
    AND op.id NOT IN (2200246845,
                     4100246845, /*маршрутки сейчас исключены*/
                     16100246845);
  
    SELECT COUNT(1) INTO vPrivilegeCount FROM cptt.privilege;
  
    WITH carrier AS
     (SELECT id AS id_operator
      FROM operator
      WHERE role = 1
      AND id NOT IN (2200246845,
                    4100246845, /*маршрутки сейчас исключены*/
                    16100246845))
    SELECT COUNT(1)
    INTO vRouteCount
    FROM ROUTE    r,
         division div,
         carrier  c
    WHERE r.id_division = div.id
    AND div.id_operator = c.id_operator;
  
    pkg$trep_reports.fillPassPrivCarrierRoute(pPassBeginDate, pPassEndDate);
    pkg$trep_reports.fillActivationSeriesPrivilege(pActivationBeginDate,
                                                   pActivationEndDate,
                                                   'Y');
    pkg$trep_reports.fillPassSeriesPrivilegeCarrier(pPassBeginDate,
                                                    pPassEndDate);
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
                         FROM cptt.tmp$trep_pass_privoproute cpo,
                              priv_rownum                    priv
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
                                  cp.col_num),
                        activation AS
                         (SELECT tas.series,
                                decode(tas.series, '17', id_privilege, NULL) AS id_privilege,
                                CASE
                                  WHEN priv.code LIKE '100000__' THEN
                                   1
                                  WHEN priv.code LIKE '200%' THEN
                                   3
                                  ELSE
                                   2
                                END AS order_num,
                                tas.count_active,
                                tas.sum_active
                         FROM cptt.tmp$trep_active_seriespriv tas,
                              cptt.privilege                  priv
                         WHERE tas.id_privilege = priv.id
                         AND tas.series IN ('11',
                                           '12',
                                           '13',
                                           '14',
                                           '15',
                                           '16',
                                           '17',
                                           '21',
                                           '22',
                                           '24',
                                           '25',
                                           '31',
                                           '32',
                                           '34',
                                           '35')),
                        pass_series AS
                         (SELECT tps.series,
                                CASE
                                  WHEN priv.code LIKE '100000__' THEN
                                   1
                                  WHEN priv.code LIKE '200%' THEN
                                   3
                                  ELSE
                                   2
                                END AS order_num,
                                tps.id_operator,
                                tps.id_privilege,
                                tps.count_pass
                         FROM cptt.tmp$trep_pass_seriesprivop tps,
                              cptt.privilege                  priv
                         WHERE tps.id_privilege = priv.id(+)
                         AND tps.series IN ('11',
                                           '12',
                                           '13',
                                           '14',
                                           '15',
                                           '16',
                                           '17',
                                           '21',
                                           '22',
                                           '24',
                                           '25',
                                           '31',
                                           '32',
                                           '34',
                                           '35')),
                        pass_series_coeff AS
                         (SELECT series,
                                id_privilege,
                                id_operator,
                                order_num,
                                CASE
                                  WHEN series LIKE '2%' OR series LIKE '3%' THEN
                                   1
                                  ELSE
                                   decode(count_pass,
                                          0,
                                          0,
                                          round(count_pass /
                                                (SELECT SUM(count_pass)
                                                 FROM pass_series
                                                 WHERE pass_series.series =
                                                       ps.series
                                                 AND (pass_series.id_privilege =
                                                       ps.id_privilege OR
                                                       pass_series.id_privilege IS NULL AND
                                                       ps.id_privilege IS NULL)),
                                                2))
                                END AS coeff
                         FROM pass_series ps),
                        pass_carrier_sum AS
                         (SELECT act.sum_active * psc.coeff AS sum_part,
                                act.series,
                                act.id_privilege,
                                psc.id_operator,
                                psc.order_num
                         FROM activation        act,
                              pass_series_coeff psc
                         WHERE act.series = psc.series
                         AND (act.id_privilege = psc.id_privilege OR
                               act.id_privilege IS NULL AND
                               psc.id_privilege IS NULL)),
                        pass_privilege_carrier_sum AS
                         (SELECT order_num,
                                id_operator,
                                SUM(sum_part) AS sum_part
                         FROM pass_carrier_sum
                         GROUP BY order_num,
                                  id_operator)
                        --период
                        SELECT 5 AS row_num,
                               'B' AS col_name,
                               'с ' ||
                               to_char(pPassBeginDate,
                                       'dd.mm.yyyy HH24:MI:SS') || CRLF ||
                               ' по ' ||
                               to_char(pPassEndDate, 'dd.mm.yyyy HH24:MI:SS') AS VALUE
                        FROM dual
                        UNION ALL
                        --наименования перевозчиков
                        SELECT 5 AS row_num,
                               getExcelColName(col_num) AS col_name,
                               NAME AS VALUE
                        FROM carrier_colnum
                        UNION ALL
                        --общее количество перевезенных
                        SELECT row_num,
                               'B' AS col_name,
                               to_char(SUM(count_pass)) AS VALUE
                        FROM pass_row_col
                        GROUP BY row_num
                        UNION ALL
                        --количество перевезенных
                        SELECT row_num,
                               getExcelColName(col_num) AS col_name,
                               to_char(count_pass) AS VALUE
                        FROM pass_row_col
                        UNION ALL
                        --количество активированных
                        SELECT 11 + order_num AS row_num,
                               'B' AS col_name,
                               to_char(SUM(nvl(count_active, 0))) AS VALUE
                        FROM activation
                        GROUP BY order_num
                        UNION ALL
                        --общая сумма денежных средств
                        SELECT 5 + order_num * 2 AS row_num,
                               'B' AS col_name,
                               to_char(SUM(nvl(sum_active, 0))) AS VALUE
                        FROM activation
                        GROUP BY order_num
                        UNION ALL
                        --сумма, разбитая по первозчикам
                        SELECT 5 + ppcs.order_num * 2 AS row_num,
                               getExcelColName(cc.col_num) AS col_name,
                               to_char(nvl(ppcs.sum_part, 0)) AS VALUE
                        FROM carrier_colnum             cc,
                             pass_privilege_carrier_sum ppcs
                        WHERE cc.id_operator = ppcs.id_operator(+))
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
  
    INSERT INTO cptt.tmp$trep_report_excel_format
      (list_num,
       RANGE,
       border)
    VALUES
      (1,
       'B5:' || getExcelColName(2 + vCarrierCount) || '11',
       1);
  
    INSERT INTO cptt.tmp$trep_report_excel_format
      (list_num,
       RANGE,
       border)
    VALUES
      (1,
       'B12:B14',
       1);
  
    FOR second_tab IN (WITH priv AS
                          (SELECT rownum AS priv_num,
                                 id AS id_privilege,
                                 code,
                                 lower(NAME) AS priv_name
                          FROM cptt.privilege),
                         carrier AS
                          (SELECT id AS id_operator
                          FROM operator
                          WHERE role = 1
                          AND id NOT IN (2200246845,
                                        4100246845, /*маршрутки сейчас исключены*/
                                        16100246845)),
                         rt AS
                          (SELECT r.id AS id_route,
                                 decode(c.id_operator,
                                        400246845,
                                        'T',
                                        500246845,
                                        'A',
                                        'UNKNOWN') || r.code AS route_name
                          FROM ROUTE    r,
                               division div,
                               carrier  c
                          WHERE r.id_division = div.id
                          AND div.id_operator = c.id_operator
                          ORDER BY c.id_operator,
                                   to_number(TRIM(r.code))),
                         rt_order AS
                          (SELECT id_route,
                                 route_name,
                                 rownum AS route_order_num
                          FROM rt),
                         priv_rt AS
                          (SELECT priv.id_privilege,
                                 priv.priv_num,
                                 ro.id_route,
                                 ro.route_order_num
                          FROM priv,
                               rt_order ro),
                         pass_priv_rt AS
                          (SELECT pr.priv_num,
                                 pr.route_order_num,
                                 nvl(SUM(tpc.count_pass), 0) AS count_pass
                          FROM priv_rt                        pr,
                               cptt.tmp$trep_pass_privoproute tpc
                          WHERE pr.id_privilege = tpc.id_privilege(+)
                          AND pr.id_route = tpc.id_route(+)
                          GROUP BY pr.priv_num,
                                   pr.route_order_num),
                         activation_count_sum AS
                          (SELECT priv.priv_num,
                                 nvl(SUM(tas.count_active), 0) AS count_active,
                                 nvl(SUM(tas.sum_active), 0) AS sum_active
                          FROM cptt.tmp$trep_active_seriespriv tas,
                               priv
                          WHERE priv.id_privilege = tas.id_privilege(+)
                          GROUP BY priv.priv_num)
                         --набираем ячейки
                         --наименования льготников
                         SELECT 16 AS row_num,
                                getExcelColName(priv_num * 3) AS col_name,
                                priv_name || CRLF || ' код (' || code || ')' AS VALUE
                         FROM priv
                         --
                         UNION ALL
                         --подзаголовки разбитых льготников
                         SELECT 17 AS row_num,
                                getExcelColName(priv.priv_num * 3 +
                                                headers.order_num) AS col_name,
                                headers.header_name AS VALUE
                         FROM (SELECT 0 AS order_num,
                                      'Кол-во транзакций' AS header_name
                               FROM dual
                               UNION ALL
                               SELECT 1 AS order_num,
                                      'Тариф' AS header_name
                               FROM dual
                               UNION ALL
                               SELECT 2 AS order_num,
                                      'Кол-во активированных ТК' AS header_name
                               FROM dual) headers,
                              priv
                         --
                         UNION ALL
                         --заголовки строк с маршрутами
                         SELECT 18 + ro.route_order_num AS row_num,
                                'B' AS col_name,
                                ro.route_name AS VALUE
                         FROM rt_order ro
                         --
                         UNION ALL
                         --суммарное количество проездов, разбитое по льготникам
                         SELECT 18 AS row_num,
                                getExcelColName(priv.priv_num * 3) AS col_name,
                                '=SUM(' ||
                                getExcelColName(priv.priv_num * 3) || '19:' ||
                                getExcelColName(priv.priv_num * 3) ||
                                to_char(18 + vRouteCount) || ')' AS VALUE
                         FROM priv
                         UNION ALL
                         --количество проездов по маршрутам и льготникам
                         SELECT 18 + ppr.route_order_num AS row_num,
                                getExcelColName(ppr.priv_num * 3) AS col_name,
                                to_char(ppr.count_pass) AS VALUE
                         FROM pass_priv_rt ppr
                         --
                         UNION ALL
                         --поле номер маршрута
                         SELECT 19 AS row_num,
                                'A' AS col_name,
                                'Номер маршрута' AS VALUE
                         FROM dual
                         --
                         UNION ALL
                         --количество активированных карт
                         SELECT 18 AS row_num,
                                getExcelColName(acs.priv_num * 3 + 2) AS col_name,
                                to_char(acs.count_active) AS VALUE
                         FROM activation_count_sum acs
                         --
                         UNION ALL
                         --цена проездного
                         SELECT 18 AS row_num,
                                getExcelColName(acs.priv_num * 3 + 1) AS col_name,
                                to_char(decode(acs.count_active,
                                               0,
                                               0,
                                               acs.sum_active /
                                               acs.count_active),
                                        'FM999999999999990.0000') AS VALUE
                         FROM activation_count_sum acs)
    LOOP
      INSERT INTO cptt.tmp$trep_report_excel
        (list_num,
         row_num,
         col_name,
         VALUE)
      VALUES
        (1,
         second_tab.row_num,
         second_tab.col_name,
         second_tab.value);
    END LOOP;
  
    FOR second_tab_format IN (WITH priv AS
                                 (SELECT rownum AS priv_num,
                                        id AS id_privilege,
                                        lower(NAME) AS priv_name
                                 FROM cptt.privilege)
                                --наименования льготников
                                SELECT getExcelColName(priv_num * 3) ||
                                       '16:' ||
                                       getExcelColName(priv_num * 3 + 2) || '16' AS RANGE,
                                       1 AS border,
                                       10 AS font_size,
                                       'Y' AS is_merged
                                FROM priv
                                --
                                UNION ALL
                                --подзаголовки разбитых льготников
                                SELECT 'C17:' ||
                                       getExcelColName(vPrivilegeCount * 3 + 2) || '17' AS RANGE,
                                       1 AS border,
                                       NULL AS font_size,
                                       'N' AS is_merged
                                FROM dual
                                --
                                UNION ALL
                                --разлиновка значений
                                SELECT 'A18:' ||
                                       getExcelColName(vPrivilegeCount * 3 + 2) ||
                                       to_char(18 + vRouteCount) AS RANGE,
                                       1 AS border,
                                       NULL AS font_size,
                                       'N' AS is_merged
                                FROM dual
                                --
                                UNION ALL
                                --объединение для поля номер маршрут
                                SELECT 'A19:A' || to_char(18 + vRouteCount) AS RANGE,
                                       1 AS border,
                                       NULL font_size,
                                       'Y' AS is_merged
                                FROM dual)
    LOOP
      INSERT INTO cptt.tmp$trep_report_excel_format
        (list_num,
         RANGE,
         border,
         font_size,
         is_merged)
      VALUES
        (1,
         second_tab_format.range,
         second_tab_format.border,
         second_tab_format.font_size,
         second_tab_format.is_merged);
    END LOOP;
    /*FOR third_tab_head IN (WITH date_order AS
                              (SELECT pPassBeginDate + LEVEL - 1 AS begin_date,
                                     rownum AS date_order_num
                              FROM dual
                              START WITH pPassBeginDate < pPassEndDate
                              CONNECT BY pPassBeginDate + LEVEL - 1 <
                                         pPassEndDate
                              ORDER BY LEVEL)
                             --
                             SELECT 20 + vRouteCount AS row_num,
                                    'A' AS col_name,
                                    'Номер ТК' AS VALUE
                             FROM dual
                             --
                             UNION ALL
                             --
                             SELECT 20 + vRouteCount AS row_num,
                                    'B' AS col_name,
                                    'Код' AS VALUE
                             FROM dual
                             --
                             UNION ALL
                             --
                             SELECT 20 + vRouteCount AS row_num,
                                    'C' AS col_name,
                                    'Общее кол-во' || CRLF || ' транзакций' AS VALUE
                             FROM dual
                             --
                             UNION ALL
                             --дни
                             SELECT 20 + vRouteCount AS row_num,
                                    getExcelColName(1 +
                                                    dor.date_order_num * 3) AS col_name,
                                    'с ' ||
                                    to_char(dor.begin_date,
                                            'dd.mm.yyyy HH24:MI:SS') AS VALUE
                             FROM date_order dor
                             --
                             UNION ALL
                             --поле кол-во транзакций
                             SELECT 21 + vRouteCount AS row_num,
                                    getExcelColName(1 +
                                                    dor.date_order_num * 3) AS col_name,
                                    'Кол-во' || CRLF || ' транзакций' AS VALUE
                             FROM date_order dor
                             --
                             UNION ALL
                             --поле номер маршрута
                             SELECT 21 + vRouteCount AS row_num,
                                    getExcelColName(2 +
                                                    dor.date_order_num * 3) AS col_name,
                                    'Номер ' || CRLF || ' маршрута' AS VALUE
                             FROM date_order dor
                             --
                             UNION ALL
                             --поле время транзакции
                             SELECT 21 + vRouteCount AS row_num,
                                    getExcelColName(3 +
                                                    dor.date_order_num * 3) AS col_name,
                                    'Время ' || CRLF || 'транзакции' AS VALUE
                             FROM date_order dor)
    LOOP
      INSERT INTO cptt.tmp$trep_report_excel
        (list_num,
         row_num,
         col_name,
         VALUE)
      VALUES
        (1,
         third_tab_head.row_num,
         third_tab_head.col_name,
         third_tab_head.value);
    END LOOP;
    
    FOR third_tab_head_format IN (WITH date_order AS
                                     (SELECT pPassBeginDate + LEVEL - 1 AS begin_date,
                                            rownum AS date_order_num
                                     FROM dual
                                     START WITH pPassBeginDate <
                                                pPassEndDate
                                     CONNECT BY pPassBeginDate + LEVEL - 1 <
                                                pPassEndDate
                                     ORDER BY LEVEL)
                                    --
                                    SELECT getExcelColName(1 +
                                                           dor.date_order_num * 3) ||
                                           to_char(20 + vRouteCount) || ':' ||
                                           getExcelColName(3 +
                                                           dor.date_order_num * 3) ||
                                           to_char(20 + vRouteCount) AS RANGE,
                                           1 AS border,
                                           10 AS font_size,
                                           'Y' AS is_merged
                                    FROM date_order dor)
    LOOP
      INSERT INTO cptt.tmp$trep_report_excel_format
        (list_num,
         RANGE,
         border,
         font_size,
         is_merged)
      VALUES
        (1,
         third_tab_head_format.range,
         third_tab_head_format.border,
         third_tab_head_format.font_size,
         third_tab_head_format.is_merged);
    END LOOP;
    
    vCurrentCardNumRowNum := 22 + vRouteCount;
    
    vDummyStop := 100;
    FOR num_rec IN (SELECT card_num,
                           id_privilege,
                           count_pass
                    FROM (SELECT tpc.card_num,
                                 tpc.id_privilege,
                                 SUM(count_pass) AS count_pass
                          FROM cptt.tmp$trep_pass_cardprivoproute tpc
                          GROUP BY card_num,
                                   id_privilege
                          ORDER BY tpc.card_num)
                    WHERE rownum < vDummyStop
                    )
    LOOP
      FOR column_head_rec IN (SELECT 'A' AS col_name,
                                     num_rec.card_num AS VALUE
                              FROM dual
                              UNION ALL
                              SELECT 'B' AS col_name,
                                     num_rec.id_privilege AS VALUE
                              FROM dual
                              UNION ALL
                              SELECT 'C' AS col_name,
                                     num_rec.count_pass AS VALUE
                              FROM dual)
      LOOP
        INSERT INTO cptt.tmp$trep_report_excel
          (list_num,
           row_num,
           col_name,
           VALUE)
        VALUES
          (1,
           vCurrentCardNumRowNum,
           column_head_rec.col_name,
           column_head_rec.value);
      END LOOP;
    
      vMaxCount := 1;
      FOR date_rec IN (SELECT pPassBeginDate + LEVEL - 1 AS begin_date,
                              rownum AS date_order_num
                       FROM dual
                       START WITH pPassBeginDate < pPassEndDate
                       CONNECT BY pPassBeginDate + LEVEL - 1 < pPassEndDate
                       ORDER BY LEVEL)
      LOOP
        vCurrentCount := 0;
        FOR trans_rec IN (WITH carrier AS
                             (SELECT id AS id_operator
                             FROM operator
                             WHERE role = 1
                             AND id NOT IN (2200246845,
                                           4100246845, \*маршрутки сейчас исключены*\
                                           16100246845)),
                            rt AS
                             (SELECT r.id,
                                    r.code AS route_code
                             FROM ROUTE    r,
                                  division div,
                                  carrier  c
                             WHERE r.id_division = div.id
                             AND div.id_operator = c.id_operator),
                            trans AS
                             (SELECT trans.card_num,
                                    carrier.id_operator,
                                    rt.route_code,
                                    trans.date_of AS trans_date,
                                    rownum AS trans_order_num,
                                    decode(carrier.id_operator,
                                           400246845,
                                           'T',
                                           500246845,
                                           'A',
                                           'UNKNOWN') || rt.route_code AS route_name
                             FROM cptt.t_data   trans,
                                  cptt.division div,
                                  carrier,
                                  rt
                             WHERE trans.date_of >= date_rec.begin_date
                             AND trans.date_of < date_rec.begin_date + 1
                             AND trans.d = 0 -- не удален
                             AND trans.kind IN ('32', '14', '17')
                             AND trans.id_division = div.id
                             AND div.id_operator = carrier.id_operator
                             AND trans.id_route = rt.id
                             AND trans.card_num = num_rec.card_num
                             ORDER BY carrier.id_operator,
                                      to_number(TRIM(rt.route_code)),
                                      trans_date)
                            --
                            SELECT route_name,
                                   to_char(trans_date, 'HH24:MI') AS trans_time
                            FROM trans)
        LOOP
          INSERT INTO cptt.tmp$trep_report_excel
            (list_num,
             row_num,
             col_name,
             VALUE)
          VALUES
            (1,
             vCurrentCardNumRowNum + vCurrentCount,
             getExcelColName(1 + date_rec.date_order_num * 3),
             '1');
          INSERT INTO cptt.tmp$trep_report_excel
            (list_num,
             row_num,
             col_name,
             VALUE)
          VALUES
            (1,
             vCurrentCardNumRowNum + vCurrentCount,
             getExcelColName(2 + date_rec.date_order_num * 3),
             trans_rec.route_name);
          INSERT INTO cptt.tmp$trep_report_excel
            (list_num,
             row_num,
             col_name,
             VALUE)
          VALUES
            (1,
             vCurrentCardNumRowNum + vCurrentCount,
             getExcelColName(3 + date_rec.date_order_num * 3),
             trans_rec.trans_time);
          vCurrentCount := vCurrentCount + 1;
          NULL;
        END LOOP;
        IF (vCurrentCount > vMaxCount) THEN
          vMaxCount := vCurrentCount;
        END IF;
        NULL;
      END LOOP;
          
        FOR column_result IN (WITH date_order AS
                                 (SELECT pPassBeginDate + LEVEL - 1 AS begin_date,
                                        rownum AS date_order_num
                                 FROM dual
                                 START WITH pPassBeginDate < pPassEndDate
                                 CONNECT BY pPassBeginDate + LEVEL - 1 <
                                            pPassEndDate
                                 ORDER BY LEVEL)
                                --вначале было слово итог
                                SELECT 'A' AS col_name,
                                       'Итог' AS VALUE
                                FROM dual
                                --
                                UNION ALL
                                --сумма
                                SELECT getExcelColName(1 +
                                                       dor.date_order_num * 3) AS col_name,
                                       '=SUM(' ||
                                       getExcelColName(1 +
                                                       dor.date_order_num * 3) ||
                                       to_char(vCurrentCardNumRowNum) || ':' ||
                                       getExcelColName(1 +
                                                       dor.date_order_num * 3) ||
                                       to_char(vCurrentCardNumRowNum +
                                               vMaxCount - 1) || ')' AS VALUE
                                FROM date_order dor
                                --
                                UNION ALL
                                --крестик
                                SELECT getExcelColName(2 +
                                                       dor.date_order_num * 3) AS col_name,
                                       'x' AS VALUE
                                FROM date_order dor
                                --
                                UNION ALL
                                --крестик-2
                                SELECT getExcelColName(3 +
                                                       dor.date_order_num * 3) AS col_name,
                                       'x' AS VALUE
                                FROM date_order dor)
        LOOP
          INSERT INTO cptt.tmp$trep_report_excel
            (list_num,
             row_num,
             col_name,
             VALUE)
          VALUES
            (1,
             vCurrentCardNumRowNum + vMaxCount,
             column_result.col_name,
             column_result.value);
        END LOOP;
      
      vCurrentCardNumRowNum := vCurrentCardNumRowNum + vMaxCount + 1;
    END LOOP;
    
    INSERT INTO cptt.tmp$trep_report_excel_format
      (list_num,
       RANGE,
       border)
    VALUES
      (1,
       'A' || to_char(20 + vRouteCount) || ':' ||
       getExcelColName(3 + ceil(pPassEndDate - pPassBeginDate) * 3) ||
       to_char(vCurrentCardNumRowNum - 1),
       1);
    */
    COMMIT;
  END;

  --Отчет по маршруту(обязательно нужен предварительный расчет fillpassRouteTermDay!)
  PROCEDURE fillReportRouteExcel(pIdRoute       IN NUMBER,
                                 pPassBeginDate IN DATE,
                                 pPassEndDate   IN DATE) AS
    vSecondTableFirstRowNum NUMBER;
    vTermCount              NUMBER;
  BEGIN
    DELETE FROM cptt.tmp$trep_report_excel;
    DELETE FROM cptt.tmp$trep_report_excel_format;
    vSecondTableFirstRowNum := 13;
    SELECT COUNT(DISTINCT tpr.id_term)
    INTO vTermCount
    FROM cptt.tmp$trep_pass_routetermday tpr
    WHERE tpr.id_route = pIdRoute;
    FOR value_rec IN (WITH rt AS
                         (SELECT r.code AS route_code,
                                c.operator_name
                         FROM ROUTE                r,
                              division             div,
                              cptt.v$trep_carriers c
                         WHERE r.id_division = div.id
                         AND div.id_operator = c.id_operator
                         AND r.id = pIdRoute),
                        dates AS
                         (SELECT pPassBeginDate + LEVEL - 1 AS begin_date,
                                rownum AS date_num
                         FROM dual
                         START WITH pPassBeginDate < pPassEndDate
                         CONNECT BY pPassBeginDate + LEVEL - 1 <
                                    pPassEndDate
                         ORDER BY LEVEL),
                        trm AS
                         (SELECT td.id_term,
                                t.code     AS code_term,
                                rownum     AS term_num
                         FROM (SELECT DISTINCT tpr.id_term
                               FROM cptt.tmp$trep_pass_routetermday tpr
                               WHERE tpr.id_route = pIdRoute) td,
                              cptt.term t
                         WHERE td.id_term = t.id(+)
                         ORDER BY td.id_term),
                        pass AS
                         (SELECT dates.date_num,
                                trm.term_num,
                                tpr.count_pass
                         FROM cptt.tmp$trep_pass_routetermday tpr,
                              dates,
                              trm
                         WHERE tpr.id_route = pIdRoute
                         AND tpr.day = dates.begin_date
                         AND tpr.id_term = trm.id_term)
                        --Первая табличка
                        --период
                        SELECT 4 AS row_num,
                               'B' AS col_name,
                               'с ' ||
                               to_char(pPassBeginDate,
                                       'dd.mm.yyyy HH24:MI:SS') || ' по ' ||
                               to_char(pPassEndDate, 'dd.mm.yyyy HH24:MI:SS') AS VALUE
                        FROM dual
                        --
                        UNION ALL
                        --номер маршрута
                        SELECT 5 AS row_num,
                               'B' AS col_name,
                               to_char(rt.route_code) AS VALUE
                        FROM rt
                        --
                        UNION ALL
                        --перевозчик
                        SELECT 9 AS row_num,
                               'B' AS col_name,
                               rt.operator_name AS VALUE
                        FROM rt
                        --
                        UNION ALL
                        --Вторая табличка
                        --Ячейка "Количество транзакций"
                        SELECT vSecondTableFirstRowNum + 1 AS row_num,
                               'A' AS col_name,
                               'Количество транзакций' AS VALUE
                        FROM dual
                        WHERE vTermCount > 0
                        --
                        UNION ALL
                        --Ячейка "Итог по дате"
                        SELECT vSecondTableFirstRowNum + vTermCount + 1 AS row_num,
                               'A' AS col_name,
                               'Итог по дате' AS VALUE
                        FROM dual
                        --
                        UNION ALL
                        --Ячейка "Количество терминалов, по которым проходили транзакции в день"
                        SELECT vSecondTableFirstRowNum + vTermCount + 2 AS row_num,
                               'A' AS col_name,
                               'Количество терминалов, по которым проходили транзакции в день' AS VALUE
                        FROM dual
                        UNION ALL
                        --строка с датами
                        SELECT vSecondTableFirstRowNum AS row_num,
                               getExcelColName(2 + dates.date_num) AS col_name,
                               'с ' ||
                               to_char(dates.begin_date,
                                       'dd.mm.yyyy HH24:MI:SS') AS VALUE
                        FROM dates
                        --
                        UNION ALL
                        --столбец с терминалами
                        SELECT vSecondTableFirstRowNum + trm.term_num AS row_num,
                               getExcelColName(2) AS col_name,
                               to_char(trm.code_term) AS VALUE
                        FROM trm
                        --
                        UNION ALL
                        --данные
                        SELECT vSecondTableFirstRowNum + pass.term_num AS row_num,
                               getExcelColName(2 + pass.date_num) AS col_name,
                               to_char(pass.count_pass) AS VALUE
                        FROM pass
                        --
                        UNION ALL
                        --Итог по терминалу(заголовок)
                        SELECT vSecondTableFirstRowNum AS row_num,
                               getExcelColName(3 + ceil(pPassEndDate -
                                                        pPassBeginDate)) AS col_name,
                               'Итог' AS VALUE
                        FROM dual
                        --
                        
                        UNION ALL
                        --Итог по терминалу
                        SELECT vSecondTableFirstRowNum + trm.term_num AS row_num,
                               getExcelColName(3 + ceil(pPassEndDate -
                                                        pPassBeginDate)) AS col_name,
                               '=SUM(' || getRange('C',
                                                   vSecondTableFirstRowNum +
                                                   trm.term_num,
                                                   getExcelColName(2 +
                                                                   ceil(pPassEndDate -
                                                                        pPassBeginDate)),
                                                   vSecondTableFirstRowNum +
                                                   trm.term_num) || ')' AS VALUE
                        FROM trm
                        --
                        UNION ALL
                        --Итог по дням(количество транзакций)
                        SELECT vSecondTableFirstRowNum + vTermCount + 1 AS row_num,
                               getExcelColName(2 + dates.date_num) AS col_name,
                               '=SUM(' ||
                               getRange(getExcelColName(2 + dates.date_num),
                                        vSecondTableFirstRowNum + 1,
                                        getExcelColName(2 + dates.date_num),
                                        vSecondTableFirstRowNum + vTermCount) || ')' AS VALUE
                        FROM dates
                        --
                        UNION ALL
                        --Итог всего по маршруту
                        SELECT vSecondTableFirstRowNum + vTermCount + 1 AS row_num,
                               getExcelColName(3 + ceil(pPassEndDate -
                                                        pPassBeginDate)) AS col_name,
                               '=SUM(' ||
                               getRange('C',
                                        vSecondTableFirstRowNum + vTermCount + 1,
                                        getExcelColName(2 +
                                                        ceil(pPassEndDate -
                                                             pPassBeginDate)),
                                        vSecondTableFirstRowNum + vTermCount + 1) || ')' AS VALUE
                        FROM dual
                        --
                        UNION ALL
                        --Итог по количеству терминалов на маршруте в день
                        SELECT vSecondTableFirstRowNum + vTermCount + 2 AS row_num,
                               getExcelColName(2 + dates.date_num) AS col_name,
                               '=COUNTIF(' ||
                               getRange(getExcelColName(2 + dates.date_num),
                                        vSecondTableFirstRowNum + 1,
                                        getExcelColName(2 + dates.date_num),
                                        vSecondTableFirstRowNum + vTermCount) ||
                               ', ">0")' AS VALUE
                        FROM dates)
    LOOP
      INSERT INTO cptt.tmp$trep_report_excel
        (list_num,
         row_num,
         col_name,
         VALUE)
      VALUES
        (1,
         value_rec.row_num,
         value_rec.col_name,
         value_rec.value);
    END LOOP;
  
    FOR format_rec IN (SELECT getRange('A',
                                       vSecondTableFirstRowNum + 1,
                                       'A',
                                       vSecondTableFirstRowNum + vTermCount) AS RANGE,
                              1 AS border,
                              'Y' AS is_merged
                       FROM dual
                       WHERE vTermCount > 0
                       UNION ALL
                       SELECT getRange('A',
                                       vSecondTableFirstRowNum,
                                       getExcelColName(3 +
                                                       ceil(pPassEndDate -
                                                            pPassBeginDate)),
                                       vSecondTableFirstRowNum + vTermCount + 2) AS RANGE,
                              1 AS border,
                              'N' AS is_merged
                       FROM dual)
    LOOP
      INSERT INTO cptt.tmp$trep_report_excel_format
        (list_num,
         RANGE,
         border,
         is_merged)
      VALUES
        (1,
         format_rec.range,
         format_rec.border,
         format_rec.is_merged);
    END LOOP;
    COMMIT;
  END;

  --Отчет по терминалу кондуктора(обязательно предварительн орассчитать fillData)
  PROCEDURE fillReportTerminalExcel(pIdTerminal    IN NUMBER,
                                    pPassBeginDate IN DATE,
                                    pPassEndDate   IN DATE) AS
    vSecondTabFirstRowNum NUMBER;
    vMaxSecondRowNum      NUMBER;
    vPrivilegeCount       NUMBER;
    vThirdTabFirstRowNum  NUMBER;
    vMaxThirdRowNum       NUMBER;
  BEGIN
    DELETE FROM cptt.tmp$trep_report_excel;
    DELETE FROM cptt.tmp$trep_report_excel_format;
    FOR first_tab IN (SELECT 4 AS row_num,
                             'B' AS col_name,
                             'с ' ||
                             to_char(pPassBeginDate, 'dd.mm.yyyy HH24:MI:SS') || CRLF ||
                             'по ' ||
                             to_char(pPassEndDate, 'dd.mm.yyyy HH24:MI:SS') AS VALUE
                      FROM dual
                      UNION ALL
                      SELECT 5 AS row_num,
                             'B' AS col_name,
                             code AS VALUE
                      FROM cptt.term trm
                      WHERE trm.id = pIdTerminal)
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
  
    vSecondTabFirstRowNum := 8;
    vMaxSecondRowNum      := vSecondTabFirstRowNum;
    FOR second_tab IN (WITH dates AS
                          (SELECT rownum AS date_num,
                                 pPassBeginDate + LEVEL - 1 AS begin_date
                          FROM dual
                          START WITH pPassBeginDate < pPassEndDate
                          CONNECT BY pPassBeginDate + LEVEL - 1 <
                                     pPassEndDate
                          ORDER BY LEVEL),
                         shift AS
                          (SELECT trm_shift_open.date_of AS shift_begin,
                                 MIN(trm_shift_close.date_of) AS shift_end,
                                 trm_shift_open.id_route,
                                 trm_shift_open.id_vehicle,
                                 trm_shift_open.train_table
                          FROM cptt.tmp$trep_data trm_shift_open,
                               cptt.tmp$trep_data trm_shift_close
                          WHERE trm_shift_open.file_rn =
                                trm_shift_close.file_rn
                          AND trm_shift_open.kind = 1
                          AND trm_shift_open.id_term = pIdTerminal
                          AND trm_shift_close.kind = 2
                          AND trm_shift_close.id_term = pIdTerminal
                          AND trm_shift_open.date_of <
                                trm_shift_close.date_of
                          
                          GROUP BY trm_shift_open.date_of,
                                   trm_shift_open.id_route,
                                   trm_shift_open.id_vehicle,
                                   trm_shift_open.train_table),
                         shift_dates AS
                          (SELECT shift_begin,
                                 shift_end,
                                 cptt.pkg$trep_reports.getRouteName(id_route) AS route_name,
                                 v.code AS vehicle_code,
                                 train_table,
                                 dates.date_num,
                                 row_number() over(PARTITION BY dates.date_num ORDER BY shift_begin) AS shift_num
                          FROM shift,
                               dates,
                               cptt.vehicle v
                          WHERE shift.shift_begin >= dates.begin_date
                          AND shift.shift_begin < dates.begin_date + 1
                          AND shift.id_vehicle = v.id)
                         --даты
                         SELECT vSecondTabFirstRowNum AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(-3 + 5 *
                                                                      date_num) AS col_name,
                                'с ' ||
                                to_char(begin_date, 'dd.mm.yyyy HH24:Mi:SS') AS VALUE
                         FROM dates
                         --
                         UNION ALL
                         --маршрут заголовок
                         SELECT vSecondTabFirstRowNum + 1 AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(-3 + 5 *
                                                                      date_num) AS col_name,
                                'Маршрут' AS VALUE
                         FROM dates
                         --
                         UNION ALL
                         --номер транспортного средства заголовок
                         SELECT vSecondTabFirstRowNum + 1 AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(-2 + 5 *
                                                                      date_num) AS col_name,
                                'Номер транспортного средства' AS VALUE
                         FROM dates
                         --
                         UNION ALL
                         --табельный номер работника терминала заголовок
                         SELECT vSecondTabFirstRowNum + 1 AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(-1 + 5 *
                                                                      date_num) AS col_name,
                                'Табельный номер работника терминала' AS VALUE
                         FROM dates
                         --
                         UNION ALL
                         --начало смены заголовок
                         SELECT vSecondTabFirstRowNum + 1 AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(5 *
                                                                      date_num) AS col_name,
                                'Начало смены' AS VALUE
                         FROM dates
                         --
                         UNION ALL
                         --конец смены заголовок
                         SELECT vSecondTabFirstRowNum + 1 AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(1 + 5 *
                                                                      date_num) AS col_name,
                                'Конец смены' AS VALUE
                         FROM dates
                         --
                         UNION ALL
                         --маршрут
                         SELECT vSecondTabFirstRowNum + 1 + shift_num AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(-3 + 5 *
                                                                      date_num) AS col_name,
                                route_name AS VALUE
                         FROM shift_dates
                         --
                         UNION ALL
                         --номер транспортного средства
                         SELECT vSecondTabFirstRowNum + 1 + shift_num AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(-2 + 5 *
                                                                      date_num) AS col_name,
                                vehicle_code AS VALUE
                         FROM shift_dates
                         --
                         UNION ALL
                         --табельный номер работника терминала
                         SELECT vSecondTabFirstRowNum + 1 + shift_num AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(-1 + 5 *
                                                                      date_num) AS col_name,
                                train_table AS VALUE
                         FROM shift_dates
                         --
                         UNION ALL
                         --начало смены
                         SELECT vSecondTabFirstRowNum + 1 + shift_num AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(5 *
                                                                      date_num) AS col_name,
                                to_char(shift_begin, 'dd.mm.yyyy HH24:MI:ss') AS VALUE
                         FROM shift_dates
                         --
                         UNION ALL
                         --конец смены
                         SELECT vSecondTabFirstRowNum + 1 + shift_num AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(1 + 5 *
                                                                      date_num) AS col_name,
                                to_char(shift_end, 'dd.mm.yyyy HH24:MI:ss') AS VALUE
                         FROM shift_dates)
    LOOP
      IF (second_tab.row_num > vMaxSecondRowNum) THEN
        vMaxSecondRowNum := second_tab.row_num;
      END IF;
      INSERT INTO cptt.tmp$trep_report_excel
        (list_num,
         row_num,
         col_name,
         VALUE)
      VALUES
        (1,
         second_tab.row_num,
         second_tab.col_name,
         second_tab.value);
    END LOOP;
  
    FOR second_tab_format IN (WITH dates AS
                                 (SELECT rownum AS date_num,
                                        pPassBeginDate + LEVEL - 1 AS begin_date
                                 FROM dual
                                 START WITH pPassBeginDate < pPassEndDate
                                 CONNECT BY pPassBeginDate + LEVEL - 1 <
                                            pPassEndDate
                                 ORDER BY LEVEL)
                                SELECT cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(-3 + 5 *
                                                                                                            date_num),
                                                                      vSecondTabFirstRowNum,
                                                                      cptt.pkg$trep_reports.getExcelColName(1 + 5 *
                                                                                                            date_num),
                                                                      vSecondTabFirstRowNum) AS RANGE,
                                       1 AS border,
                                       'Y' AS is_merged
                                FROM dates
                                UNION ALL
                                SELECT cptt.pkg$trep_reports.getRange('A',
                                                                      vSecondTabFirstRowNum,
                                                                      cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                            ceil(pPassEndDate -
                                                                                                                 pPassBeginDate) * 5),
                                                                      vMaxSecondRowNum) AS RANGE,
                                       1 AS border,
                                       'N' AS is_merged
                                FROM dual)
    LOOP
      INSERT INTO cptt.tmp$trep_report_excel_format
        (list_num,
         RANGE,
         border,
         is_merged)
      VALUES
        (1,
         second_tab_format.range,
         second_tab_format.border,
         second_tab_format.is_merged);
    END LOOP;
  
    SELECT COUNT(1) INTO vPrivilegeCount FROM cptt.privilege;
  
    vThirdTabFirstRowNum := vMaxSecondRowNum + 3;
    vMaxThirdRowNum      := vThirdTabFirstRowNum;
  
    FOR third_tab IN (WITH dates AS
                         (SELECT rownum AS date_num,
                                pPassBeginDate + LEVEL - 1 AS begin_date
                         FROM dual
                         START WITH pPassBeginDate < pPassEndDate
                         CONNECT BY pPassBeginDate + LEVEL - 1 <
                                    pPassEndDate
                         ORDER BY LEVEL),
                        priv AS
                         (SELECT id AS id_privilege,
                                rownum AS cat_num,
                                NAME || CRLF || '(' || code || ')' AS cat_name
                         FROM cptt.privilege priv
                         ORDER BY code),
                        cat AS
                         (SELECT cat_num,
                                cat_name
                         FROM priv
                         UNION ALL
                         SELECT vPrivilegeCount + 1 AS cat_num,
                                'Транспортная карта "городская" АВТОБУС' AS cat_name
                         FROM dual
                         UNION ALL
                         SELECT vPrivilegeCount + 2 AS cat_num,
                                'Транспортная карта "городская" АВТОБУС-ТРОЛЛЕЙБУС' AS cat_name
                         FROM dual
                         UNION ALL
                         SELECT vPrivilegeCount + 3 AS cat_num,
                                'Транспортная карта "городская" ТРОЛЛЕЙБУС' AS cat_name
                         FROM dual
                         UNION ALL
                         SELECT vPrivilegeCount + 4 AS cat_num,
                                'БК Виза' AS cat_name
                         FROM dual
                         UNION ALL
                         SELECT vPrivilegeCount + 5 AS cat_num,
                                'Наличные' AS cat_name
                         FROM dual),
                        trans AS
                         (SELECT CASE
                                  WHEN priv.cat_num IS NOT NULL THEN
                                   priv.cat_num
                                  WHEN tdt.series IN ('39', '53', '43', '46') THEN
                                   vPrivilegeCount + 1
                                  WHEN tdt.series IN ('19', '50', '41', '44') THEN
                                   vPrivilegeCount + 2
                                  WHEN tdt.series IN ('29', '52', '42', '45') THEN
                                   vPrivilegeCount + 3
                                  WHEN tdt.series IN ('96') THEN
                                   vPrivilegeCount + 4
                                  WHEN tdt.series IS NULL THEN
                                   vPrivilegeCount + 5
                                  ELSE
                                   1
                                END AS cat_num,
                                tdt.date_of,
                                tdt.id_route,
                                dates.date_num
                         FROM cptt.tmp$trep_data tdt,
                              priv,
                              dates
                         WHERE tdt.id_privilege = priv.id_privilege(+)
                         AND tdt.id_term = pIdTerminal
                         AND tdt.kind NOT IN ('1', '2')
                         AND tdt.date_of >= dates.begin_date
                         AND tdt.date_of < dates.begin_date + 1),
                        trans_count AS
                         (SELECT cat_num,
                                date_num,
                                COUNT(1) AS count_pass
                         FROM trans
                         GROUP BY trans.cat_num,
                                  date_num),
                        trans_max_count AS
                         (SELECT cat_num,
                                MAX(count_pass) AS max_count_pass
                         FROM trans_count
                         GROUP BY cat_num),
                        trans_cat_first_row AS
                         (SELECT vThirdTabFirstRowNum + 2 +
                                (SELECT nvl(SUM(max_count_pass), 0)
                                 FROM trans_max_count
                                 WHERE cat_num < cat.cat_num) +
                                (cat_num - 1) * 2 AS cat_first_row_num,
                                cat.cat_num,
                                cat.cat_name
                         FROM cat),
                        trans_indexed AS
                         (SELECT trans.cat_num,
                                trans.date_num,
                                trans.date_of,
                                cptt.pkg$trep_reports.getRouteName(trans.id_route) AS route_name,
                                tcfr.cat_first_row_num + row_number() over(PARTITION BY trans.cat_num, trans.date_num ORDER BY date_of) - 1 AS catdate_num
                         FROM trans,
                              trans_cat_first_row tcfr
                         WHERE trans.cat_num = tcfr.cat_num),
                        trans_cat_last_row AS
                         (SELECT tcfr.cat_first_row_num + tmc.max_count_pass AS cat_last_row_num,
                                tcfr.cat_num
                         FROM trans_cat_first_row tcfr,
                              trans_max_count     tmc
                         WHERE tcfr.cat_num = tmc.cat_num),
                        
                        trans_total_date_cat AS
                         (SELECT all_cat_date.date_num,
                                all_cat_date.cat_last_row_num,
                                nvl(tc.count_pass, 0) AS count_pass
                         FROM trans_count tc,
                              (SELECT cat_num,
                                      cat_last_row_num,
                                      date_num
                               FROM trans_cat_last_row,
                                    dates) all_cat_date
                         WHERE all_cat_date.cat_num = tc.cat_num(+)
                         AND all_cat_date.date_num = tc.date_num(+)),
                        trans_total_date AS
                         (SELECT (SELECT MAX(cat_last_row_num) + 1
                                 FROM trans_cat_last_row) AS total_row_num,
                                ttdc.date_num,
                                nvl(SUM(ttdc.count_pass), 0) AS count_pass
                         FROM trans_total_date_cat ttdc
                         GROUP BY ttdc.date_num)
                        --даты
                        SELECT vThirdTabFirstRowNum AS row_num,
                               cptt.pkg$trep_reports.getExcelColName(2 +
                                                                     (date_num - 1) * 3) AS col_name,
                               'с ' ||
                               to_char(begin_date, 'dd.mm.yyyy HH24:MI:SS') AS VALUE
                        FROM dates
                        --
                        UNION ALL
                        --Категории
                        SELECT cat_first_row_num AS row_num,
                               'A' AS col_name,
                               cat_name AS VALUE
                        FROM trans_cat_first_row
                        --
                        UNION ALL
                        --заголовки
                        --
                        SELECT vThirdTabFirstRowNum + 1 AS row_num,
                               cptt.pkg$trep_reports.getExcelColName(2 +
                                                                     (date_num - 1) * 3) AS col_name,
                               'Маршрут' AS VALUE
                        FROM dates
                        --
                        UNION ALL
                        --
                        SELECT vThirdTabFirstRowNum + 1 AS row_num,
                               cptt.pkg$trep_reports.getExcelColName(2 +
                                                                     (date_num - 1) * 3 + 1) AS col_name,
                               'Время транзакции' AS VALUE
                        FROM dates
                        --
                        UNION ALL
                        --
                        SELECT vThirdTabFirstRowNum + 1 AS row_num,
                               cptt.pkg$trep_reports.getExcelColName(2 +
                                                                     (date_num - 1) * 3 + 2) AS col_name,
                               'Количество' AS VALUE
                        FROM dates
                        --
                        UNION ALL
                        --
                        SELECT vThirdTabFirstRowNum AS row_num,
                               cptt.pkg$trep_reports.getExcelColName(2 +
                                                                     (ceil(pPassEndDate -
                                                                           pPassBeginDate) - 1) * 3 + 3) AS col_name,
                               'За все дни' AS VALUE
                        FROM dual
                        --
                        UNION ALL
                        --Маршрут
                        SELECT catdate_num AS row_num,
                               cptt.pkg$trep_reports.getExcelColName(2 +
                                                                     (date_num - 1) * 3) AS col_name,
                               route_name AS VALUE
                        FROM trans_indexed
                        --
                        UNION ALL
                        --время транзакции
                        SELECT catdate_num AS row_num,
                               cptt.pkg$trep_reports.getExcelColName(2 +
                                                                     (date_num - 1) * 3 + 1) AS col_name,
                               to_char(date_of, 'HH24:MI:SS') AS VALUE
                        FROM trans_indexed
                        --
                        UNION ALL
                        --количество
                        SELECT catdate_num AS row_num,
                               cptt.pkg$trep_reports.getExcelColName(2 +
                                                                     (date_num - 1) * 3 + 2) AS col_name,
                               '1' AS VALUE
                        FROM trans_indexed
                        --
                        UNION ALL
                        --Итог(по дню и категории)(слово)
                        SELECT cat_last_row_num AS row_num,
                               'A' AS col_name,
                               'Итого:' AS VALUE
                        FROM trans_cat_last_row
                        --
                        UNION ALL
                        --Итог(по дню и категории)
                        SELECT cat_last_row_num AS row_num,
                               cptt.pkg$trep_reports.getExcelColName(2 +
                                                                     (date_num - 1) * 3 + 2) AS col_name,
                               to_char(count_pass) AS VALUE
                        FROM trans_total_date_cat
                        --
                        UNION ALL
                        --Итог(по дню)(слово)
                        SELECT total_row_num AS row_num,
                               'A' AS col_name,
                               'Всего:' AS VALUE
                        FROM trans_total_date
                        WHERE rownum < 2
                        --
                        UNION ALL
                        --Итог(по дню)
                        SELECT total_row_num AS row_num,
                               cptt.pkg$trep_reports.getExcelColName(2 +
                                                                     (date_num - 1) * 3 + 2) AS col_name,
                               to_char(count_pass) AS VALUE
                        FROM trans_total_date
                        --
                        UNION ALL
                        --Итог по категории
                        SELECT cat_last_row_num AS row_num,
                               cptt.pkg$trep_reports.getExcelColName(2 +
                                                                     (ceil(pPassEndDate -
                                                                           pPassBeginDate) - 1) * 3 + 3) AS col_name,
                               '=SUM(' ||
                               cptt.pkg$trep_reports.getRange('B',
                                                              cat_last_row_num,
                                                              cptt.pkg$trep_reports.getExcelColName(2 +
                                                                                                    (ceil(pPassEndDate -
                                                                                                          pPassBeginDate) - 1) * 3 + 2),
                                                              cat_last_row_num) || ')' AS VALUE
                        FROM trans_cat_last_row
                        --
                        UNION ALL
                        --Всего
                        SELECT total_row_num AS row_num,
                               cptt.pkg$trep_reports.getExcelColName(2 +
                                                                     (ceil(pPassEndDate -
                                                                           pPassBeginDate) - 1) * 3 + 3) AS col_name,
                               '=SUM(' ||
                               cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(2 +
                                                                                                    (ceil(pPassEndDate -
                                                                                                          pPassBeginDate) - 1) * 3 + 3),
                                                              vThirdTabFirstRowNum + 2,
                                                              cptt.pkg$trep_reports.getExcelColName(2 +
                                                                                                    (ceil(pPassEndDate -
                                                                                                          pPassBeginDate) - 1) * 3 + 3),
                                                              total_row_num - 1) || ')' AS VALUE
                        FROM trans_total_date
                        WHERE rownum < 2)
    LOOP
      IF (third_tab.row_num > vMaxThirdRowNum) THEN
        vMaxThirdRowNum := third_tab.row_num;
      END IF;
      INSERT INTO cptt.tmp$trep_report_excel
        (list_num,
         row_num,
         col_name,
         VALUE)
      VALUES
        (1,
         third_tab.row_num,
         third_tab.col_name,
         third_tab.value);
    END LOOP;
  
    FOR third_tab_format IN (WITH dates AS
                                (SELECT rownum AS date_num,
                                       pPassBeginDate + LEVEL - 1 AS begin_date
                                FROM dual
                                START WITH pPassBeginDate < pPassEndDate
                                CONNECT BY pPassBeginDate + LEVEL - 1 <
                                           pPassEndDate
                                ORDER BY LEVEL),
                               priv AS
                                (SELECT id AS id_privilege,
                                       rownum AS cat_num,
                                       NAME || CRLF || '(' || code || ')' AS cat_name
                                FROM cptt.privilege priv
                                ORDER BY code),
                               cat AS
                                (SELECT cat_num,
                                       cat_name
                                FROM priv
                                UNION ALL
                                SELECT vPrivilegeCount + 1 AS cat_num,
                                       'Транспортная карта "городская" АВТОБУС' AS cat_name
                                FROM dual
                                UNION ALL
                                SELECT vPrivilegeCount + 2 AS cat_num,
                                       'Транспортная карта "городская" АВТОБУС-ТРОЛЛЕЙБУС' AS cat_name
                                FROM dual
                                UNION ALL
                                SELECT vPrivilegeCount + 3 AS cat_num,
                                       'Транспортная карта "городская" ТРОЛЛЕЙБУС' AS cat_name
                                FROM dual
                                UNION ALL
                                SELECT vPrivilegeCount + 4 AS cat_num,
                                       'БК Виза' AS cat_name
                                FROM dual
                                UNION ALL
                                SELECT vPrivilegeCount + 5 AS cat_num,
                                       'Наличные' AS cat_name
                                FROM dual),
                               trans AS
                                (SELECT CASE
                                         WHEN priv.cat_num IS NOT NULL THEN
                                          priv.cat_num
                                         WHEN tdt.series IN
                                              ('39', '53', '43', '46') THEN
                                          vPrivilegeCount + 1
                                         WHEN tdt.series IN
                                              ('19', '50', '41', '44') THEN
                                          vPrivilegeCount + 2
                                         WHEN tdt.series IN
                                              ('29', '52', '42', '45') THEN
                                          vPrivilegeCount + 3
                                         WHEN tdt.series IN ('96') THEN
                                          vPrivilegeCount + 4
                                         WHEN tdt.series IS NULL THEN
                                          vPrivilegeCount + 5
                                         ELSE
                                          1
                                       END AS cat_num,
                                       tdt.date_of,
                                       tdt.id_route,
                                       dates.date_num
                                FROM cptt.tmp$trep_data tdt,
                                     priv,
                                     dates
                                WHERE tdt.id_privilege =
                                      priv.id_privilege(+)
                                AND tdt.id_term = pIdTerminal
                                AND tdt.kind NOT IN ('1', '2')
                                AND tdt.date_of >= dates.begin_date
                                AND tdt.date_of < dates.begin_date + 1),
                               trans_count AS
                                (SELECT cat_num,
                                       date_num,
                                       COUNT(1) AS count_pass
                                FROM trans
                                GROUP BY trans.cat_num,
                                         date_num),
                               trans_max_count AS
                                (SELECT cat_num,
                                       MAX(count_pass) AS max_count_pass
                                FROM trans_count
                                GROUP BY cat_num),
                               trans_cat_first_row AS
                                (SELECT vThirdTabFirstRowNum + 2 +
                                       (SELECT nvl(SUM(max_count_pass), 0)
                                        FROM trans_max_count
                                        WHERE cat_num < cat.cat_num) +
                                       (cat_num - 1) * 2 AS cat_first_row_num,
                                       cat.cat_num,
                                       cat.cat_name
                                FROM cat),
                               trans_cat_last_row AS
                                (SELECT tcfr.cat_first_row_num,
                                       tcfr.cat_first_row_num +
                                       tmc.max_count_pass AS cat_last_row_num,
                                       tcfr.cat_num
                                FROM trans_cat_first_row tcfr,
                                     trans_max_count     tmc
                                WHERE tcfr.cat_num = tmc.cat_num)
                               SELECT cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(2 +
                                                                                                           (date_num - 1) * 3),
                                                                     vThirdTabFirstRowNum,
                                                                     cptt.pkg$trep_reports.getExcelColName(2 +
                                                                                                           (date_num - 1) * 3 + 2),
                                                                     vThirdTabFirstRowNum) AS RANGE,
                                      1 AS border,
                                      'Y' AS is_merged
                               FROM dates
                               --
                               UNION ALL
                               SELECT cptt.pkg$trep_reports.getRange('A',
                                                                     cat_first_row_num,
                                                                     'A',
                                                                     cat_last_row_num - 1) AS RANGE,
                                      1 AS border,
                                      'Y' AS is_merged
                               FROM trans_cat_last_row
                               --
                               UNION ALL
                               --
                               SELECT cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(2 +
                                                                                                           (ceil(pPassEndDate -
                                                                                                                 pPassBeginDate) - 1) * 3 + 3),
                                                                     vThirdTabFirstRowNum,
                                                                     cptt.pkg$trep_reports.getExcelColName(2 +
                                                                                                           (ceil(pPassEndDate -
                                                                                                                 pPassBeginDate) - 1) * 3 + 3),
                                                                     vThirdTabFirstRowNum + 1) AS RANGE,
                                      1 AS border,
                                      'Y' AS is_merged
                               FROM dual
                               --
                               UNION ALL
                               SELECT cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(2 +
                                                                                                           (ceil(pPassEndDate -
                                                                                                                 pPassBeginDate) - 1) * 3 + 3),
                                                                     cat_first_row_num,
                                                                     cptt.pkg$trep_reports.getExcelColName(2 +
                                                                                                           (ceil(pPassEndDate -
                                                                                                                 pPassBeginDate) - 1) * 3 + 3),
                                                                     cat_last_row_num - 1) AS RANGE,
                                      1 AS border,
                                      'Y' AS is_merged
                               FROM trans_cat_last_row
                               --
                               --
                               UNION ALL
                               --
                               SELECT cptt.pkg$trep_reports.getRange('A',
                                                                     cat_last_row_num + 1,
                                                                     cptt.pkg$trep_reports.getExcelColName(2 +
                                                                                                           (ceil(pPassEndDate -
                                                                                                                 pPassBeginDate) - 1) * 3 + 3),
                                                                     cat_last_row_num + 1) AS RANGE,
                                      1 AS border,
                                      'Y' AS is_merged
                               FROM trans_cat_last_row
                               WHERE rownum <
                                (SELECT COUNT(1) FROM trans_cat_last_row)
                               UNION ALL
                               --
                               SELECT cptt.pkg$trep_reports.getRange('A',
                                                                     vThirdTabFirstRowNum,
                                                                     cptt.pkg$trep_reports.getExcelColName(2 +
                                                                                                           (ceil(pPassEndDate -
                                                                                                                 pPassBeginDate) - 1) * 3 + 3),
                                                                     vMaxThirdRowNum) AS RANGE,
                                      1 AS border,
                                      'N' AS is_merged
                               FROM dual)
    LOOP
      INSERT INTO cptt.tmp$trep_report_excel_format
        (list_num,
         RANGE,
         border,
         is_merged)
      VALUES
        (1,
         third_tab_format.range,
         third_tab_format.border,
         third_tab_format.is_merged);
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

--Отчет по транспортному средству (обязательно предварительно рассчитать fillData)
PROCEDURE fillReportVehicleExcel(pIdVehicle     IN NUMBER,
                                 pPassBeginDate IN DATE,
                                 pPassEndDate   IN DATE) AS
  vSecondTabLastRowNum NUMBER;
  vThirdTabFirstRowNum NUMBER;
  vThirdTabLastRowNum  NUMBER;
BEGIN
  DELETE FROM cptt.tmp$trep_report_excel;
  DELETE FROM cptt.tmp$trep_report_excel_format;

  FOR first_tab IN (WITH vehicle_data AS
                       (SELECT v.code  AS vehicle_code,
                              op.name AS operator_name
                       FROM cptt.vehicle  v,
                            cptt.division div,
                            cptt.operator op
                       WHERE v.id = pIdVehicle
                       AND v.id_division = div.id
                       AND div.id_operator = op.id)
                      --период
                      SELECT 4 AS row_num,
                             'B' AS col_name,
                             'c ' ||
                             to_char(pPassBeginDate, 'dd.mm.yyyy HH24:MI:SS') ||
                             ' по ' ||
                             to_char(pPassEndDate, 'dd.mm.yyyy HH24:MI:SS') AS VALUE
                      FROM dual
                      --
                      UNION ALL
                      --номер ТС
                      SELECT 5 AS row_num,
                             'B' AS col_name,
                             vehicle_code AS VALUE
                      FROM vehicle_data
                      --
                      UNION ALL
                      --перевозчик
                      SELECT 6 AS row_num,
                             'B' AS col_name,
                             operator_name AS VALUE
                      FROM vehicle_data)
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

  vSecondTabLastRowNum := 9;
  FOR second_tab IN (WITH dates AS
                        (SELECT rownum AS date_num,
                               pPassBeginDate + LEVEL - 1 AS begin_date
                        FROM dual
                        START WITH pPassBeginDate < pPassEndDate
                        CONNECT BY pPassBeginDate + LEVEL - 1 < pPassEndDate
                        ORDER BY LEVEL),
                       cols AS
                        (SELECT LEVEL AS col_num
                        FROM dual
                        START WITH 1 <= 5
                        CONNECT BY LEVEL <= 5
                        ORDER BY LEVEL),
                       shift AS
                        (SELECT trm_shift_open.id_term,
                               trm_shift_open.date_of AS shift_begin,
                               MIN(trm_shift_close.date_of) AS shift_end
                        FROM cptt.tmp$trep_data trm_shift_open,
                             cptt.tmp$trep_data trm_shift_close
                        WHERE trm_shift_open.file_rn =
                              trm_shift_close.file_rn
                        AND trm_shift_open.kind = 1
                        AND trm_shift_open.id_term = trm_shift_close.id_term
                        AND trm_shift_close.kind = 2
                        AND trm_shift_open.date_of < trm_shift_close.date_of
                        AND trm_shift_open.id_vehicle = pIdVehicle
                        GROUP BY trm_shift_open.date_of,
                                 trm_shift_open.id_term,
                                 trm_shift_open.id_vehicle),
                       shift_dates AS
                        (SELECT t.code AS term_code,
                               shift.shift_begin,
                               shift.shift_end,
                               dates.date_num,
                               row_number() over(PARTITION BY dates.date_num ORDER BY shift_begin) AS shift_num
                        FROM shift,
                             dates,
                             cptt.term t
                        WHERE shift.shift_begin >= dates.begin_date
                        AND shift.shift_begin < dates.begin_date + 1
                        AND shift.id_term = t.id),
                       data AS
                        (SELECT sd.term_code,
                               sd.shift_begin,
                               sd.shift_end,
                               COUNT(1) AS count_pass,
                               SUM(td.amount) AS sum_pass,
                               sd.date_num,
                               sd.shift_num
                        FROM cptt.tmp$trep_data td,
                             shift_dates        sd
                        WHERE td.kind IN ('32', '14', '17')
                        AND td.id_vehicle = pIdVehicle
                        AND td.date_of >= sd.shift_begin
                        AND td.date_of <= sd.shift_end
                        GROUP BY sd.term_code,
                                 sd.shift_begin,
                                 sd.shift_end,
                                 sd.date_num,
                                 sd.shift_num),
                       max_shift AS
                        (SELECT nvl(MAX(shift_num), 0) AS max_shift_num
                        FROM data),
                       total AS
                        (SELECT max_shift.max_shift_num,
                               dates.date_num,
                               nvl(SUM(data.count_pass), 0) AS count_pass,
                               nvl(SUM(data.sum_pass), 0) AS sum_pass
                        FROM dates,
                             data,
                             max_shift
                        WHERE dates.date_num = data.date_num(+)
                        GROUP BY max_shift.max_shift_num,
                                 dates.date_num)
                       
                       SELECT 8 AS row_num,
                              'A' AS col_name,
                              'Календарные дни' AS VALUE
                       FROM dual
                       --
                       UNION ALL
                       --даты
                       SELECT 8 AS row_num,
                              cptt.pkg$trep_reports.getExcelColName(2 +
                                                                    (date_num - 1) * 5) AS col_name,
                              'с ' ||
                              to_char(begin_date, 'dd.mm.yyyy HH24:MI:SS') AS VALUE
                       FROM dates
                       --
                       UNION ALL
                       --заголовки
                       SELECT 9 AS row_num,
                              cptt.pkg$trep_reports.getExcelColName(2 +
                                                                    (date_num - 1) * 5 +
                                                                    cols.col_num - 1) AS col_name,
                              CASE cols.col_num
                                WHEN 1 THEN
                                 'Номер терминала'
                                WHEN 2 THEN
                                 'Начало работы'
                                WHEN 3 THEN
                                 'Окончание работы'
                                WHEN 4 THEN
                                 'Кол-во транзакций'
                                ELSE
                                 'Сумма'
                              END AS VALUE
                       FROM dates,
                            cols
                       --
                       UNION ALL
                       --данные с разбивкой по терминалам по всем столбцам
                       SELECT 9 + data.shift_num AS row_num,
                              cptt.pkg$trep_reports.getExcelColName(2 +
                                                                    (date_num - 1) * 5 +
                                                                    cols.col_num - 1) AS col_name,
                              CASE cols.col_num
                                WHEN 1 THEN
                                 data.term_code
                                WHEN 2 THEN
                                 to_char(data.shift_begin, 'HH24:MI:SS')
                                WHEN 3 THEN
                                 to_char(data.shift_end, 'HH24:MI:SS')
                                WHEN 4 THEN
                                 to_char(data.count_pass)
                                ELSE
                                 to_char(data.sum_pass,
                                         'FM999999999999990.00')
                              END AS VALUE
                       FROM data,
                            cols
                       --
                       UNION ALL
                       --Итого
                       SELECT 9 + total.max_shift_num + 1 AS row_num,
                              cptt.pkg$trep_reports.getExcelColName(2 +
                                                                    (date_num - 1) * 5 +
                                                                    cols.col_num - 1) AS col_name,
                              CASE cols.col_num
                                WHEN 4 THEN
                                 to_char(total.count_pass)
                                ELSE
                                 to_char(total.sum_pass,
                                         'FM999999999999990.00')
                              END AS VALUE
                       FROM total,
                            cols
                       WHERE cols.col_num BETWEEN 4 AND 5
                       --
                       UNION ALL
                       --строка Итого
                       SELECT 9 + max_shift.max_shift_num + 1 AS row_num,
                              'A' AS col_name,
                              'Итого' AS VALUE
                       FROM max_shift)
  LOOP
    IF (vSecondTabLastRowNum < second_tab.row_num) THEN
      vSecondTabLastRowNum := second_tab.row_num;
    END IF;
    INSERT INTO cptt.tmp$trep_report_excel
      (list_num,
       row_num,
       col_name,
       VALUE)
    VALUES
      (1,
       second_tab.row_num,
       second_tab.col_name,
       second_tab.value);
  END LOOP;

  FOR second_tab_format IN (WITH dates AS
                               (SELECT rownum AS date_num,
                                      pPassBeginDate + LEVEL - 1 AS begin_date
                               FROM dual
                               START WITH pPassBeginDate < pPassEndDate
                               CONNECT BY pPassBeginDate + LEVEL - 1 <
                                          pPassEndDate
                               ORDER BY LEVEL)
                              --заголовки дат
                              SELECT cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(2 +
                                                                                                          (date_num - 1) * 5),
                                                                    8,
                                                                    cptt.pkg$trep_reports.getExcelColName(2 +
                                                                                                          (date_num - 1) * 5 + 4),
                                                                    8) AS RANGE,
                                     1 AS border,
                                     'Y' AS is_merged
                              FROM dates
                              --
                              UNION ALL
                              --
                              SELECT cptt.pkg$trep_reports.getRange('A',
                                                                    9,
                                                                    'A',
                                                                    vSecondTabLastRowNum - 1) AS RANGE,
                                     1 AS border,
                                     'Y' AS is_merged
                              FROM dual
                              WHERE vSecondTabLastRowNum > 10
                              --
                              UNION ALL
                              --
                              SELECT cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(2 +
                                                                                                          (date_num - 1) * 5),
                                                                    vSecondTabLastRowNum,
                                                                    cptt.pkg$trep_reports.getExcelColName(2 +
                                                                                                          (date_num - 1) * 5 + 2),
                                                                    vSecondTabLastRowNum) AS RANGE,
                                     1 AS border,
                                     'Y' AS is_merged
                              FROM dates
                              WHERE vSecondTabLastRowNum > 9
                              --
                              UNION ALL
                              --all
                              SELECT cptt.pkg$trep_reports.getRange('A',
                                                                    8,
                                                                    cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                          ceil(pPassEndDate -
                                                                                                               pPassBeginDate) * 5),
                                                                    vSecondTabLastRowNum) AS RANGE,
                                     1 AS border,
                                     'N' AS is_merged
                              FROM dual)
  LOOP
    INSERT INTO cptt.tmp$trep_report_excel_format
      (list_num,
       RANGE,
       border,
       is_merged)
    VALUES
      (1,
       second_tab_format.range,
       second_tab_format.border,
       second_tab_format.is_merged);
  END LOOP;

  vThirdTabFirstRowNum := vSecondTabLastRowNum + 2;
  vThirdTabLastRowNum  := vThirdTabFirstRowNum + 1;

  FOR third_tab IN (WITH dates AS
                       (SELECT rownum AS date_num,
                              pPassBeginDate + LEVEL - 1 AS begin_date
                       FROM dual
                       START WITH pPassBeginDate < pPassEndDate
                       CONNECT BY pPassBeginDate + LEVEL - 1 < pPassEndDate
                       ORDER BY LEVEL),
                      cols AS
                       (SELECT LEVEL AS col_num
                       FROM dual
                       START WITH 1 <= 2
                       CONNECT BY LEVEL <= 2
                       ORDER BY LEVEL),
                      trans AS
                       (SELECT *
                       FROM cptt.tmp$trep_data
                       WHERE id_vehicle = 139700246845),
                      priv AS
                       (SELECT rownum AS cat_num,
                              id AS id_privilege,
                              upper(NAME) || ' (' || code || ')' AS cat_name
                       FROM PRIVILEGE),
                      priv_data AS
                       (SELECT priv.cat_num,
                              dates.date_num,
                              nvl(COUNT(trans.amount), 0) AS count_pass,
                              nvl(SUM(trans.amount), 0) AS sum_pass
                       FROM priv
                       CROSS JOIN dates
                       LEFT OUTER JOIN trans
                       ON (priv.id_privilege = trans.id_privilege AND
                          dates.begin_date <= trans.date_of AND
                          dates.begin_date + 1 > trans.date_of)
                       GROUP BY cat_num,
                                date_num),
                      max_priv AS
                       (SELECT nvl(MAX(cat_num), 0) AS priv_max_cat_num
                       FROM priv),
                      non_priv AS
                       (SELECT CASE
                                WHEN series IN ('39', '53', '43', '46') THEN
                                 priv_max_cat_num + 1
                                WHEN series IN ('19', '50', '41', '44') THEN
                                 priv_max_cat_num + 2
                                WHEN series IN ('29', '52', '42', '45') THEN
                                 priv_max_cat_num + 3
                                WHEN series IN ('96') THEN
                                 priv_max_cat_num + 4
                                WHEN series IS NULL THEN
                                 priv_max_cat_num + 5
                                ELSE
                                 priv_max_cat_num + 6
                              END AS cat_num,
                              CASE
                                WHEN series IN ('39', '53', '43', '46') THEN
                                 'Городская ТК "Автобус"'
                                WHEN series IN ('19', '50', '41', '44') THEN
                                 'Городская ТК "Автобус-Троллейбус"'
                                WHEN series IN ('29', '52', '42', '45') THEN
                                 'Городская ТК "Троллейбус"'
                                WHEN series IN ('96') THEN
                                 'БК Виза'
                                WHEN series IS NULL THEN
                                 'Разовые билеты'
                                ELSE
                                 'Ошибка'
                              END AS cat_name,
                              ser.series
                       FROM max_priv,
                            cptt.ref$trep_series ser
                       WHERE series IN ('39',
                                        '53',
                                        '43',
                                        '46',
                                        '19',
                                        '50',
                                        '41',
                                        '44',
                                        '29',
                                        '52',
                                        '42',
                                        '45',
                                        '96')
                       OR series IS NULL),
                      all_cat AS
                       (SELECT cat_num,
                              cat_name
                       FROM priv
                       UNION ALL
                       SELECT DISTINCT cat_num,
                                       cat_name
                       FROM non_priv),
                      non_priv_data AS
                       (SELECT non_priv.cat_num,
                              dates.date_num,
                              nvl(COUNT(trans.rowid), 0) AS count_pass,
                              nvl(SUM(trans.amount), 0) AS sum_pass
                       FROM non_priv
                       CROSS JOIN dates
                       LEFT OUTER JOIN trans
                       ON ((non_priv.series = trans.series OR
                          (non_priv.series IS NULL AND
                          trans.series IS NULL)) AND
                          dates.begin_date <= trans.date_of AND
                          dates.begin_date + 1 > trans.date_of)
                       GROUP BY non_priv.cat_num,
                                dates.date_num),
                      pass_data AS
                       (SELECT *
                       FROM priv_data
                       UNION ALL
                       SELECT *
                       FROM non_priv_data),
                      max_cat AS
                       (SELECT nvl(MAX(cat_num), 0) AS all_max_cat_num
                       FROM non_priv),
                      total_date AS
                       (SELECT max_cat.all_max_cat_num + 1 AS cat_num,
                              pd.date_num,
                              nvl(SUM(pd.count_pass), 0) AS count_pass,
                              nvl(SUM(pd.sum_pass), 0) AS sum_pass
                       FROM pass_data pd,
                            max_cat
                       GROUP BY pd.date_num,
                                max_cat.all_max_cat_num),
                      total_cat AS
                       (SELECT cat_num,
                              ceil(pPassEndDate - pPassBeginDate) + 1 AS date_num,
                              nvl(SUM(pdtd.count_pass), 0) AS count_pass,
                              nvl(SUM(pdtd.sum_pass), 0) AS sum_pass
                       FROM (SELECT *
                             FROM pass_data
                             UNION ALL
                             SELECT *
                             FROM total_date) pdtd
                       GROUP BY cat_num),
                      all_data AS
                       (SELECT *
                       FROM pass_data
                       UNION ALL
                       SELECT *
                       FROM total_date
                       UNION ALL
                       SELECT *
                       FROM total_cat)
                      SELECT vThirdTabFirstRowNum AS row_num,
                             'A' AS col_name,
                             'Календарные дни' AS VALUE
                      FROM dual
                      --
                      UNION ALL
                      --даты
                      SELECT vThirdTabFirstRowNum AS row_num,
                             cptt.pkg$trep_reports.getExcelColName(2 +
                                                                   (date_num - 1) * 2) AS col_name,
                             'с ' ||
                             to_char(begin_date, 'dd.mm.yyyy HH24:MI:SS') AS VALUE
                      FROM dates
                      --
                      UNION ALL
                      --заголовки
                      SELECT vThirdTabFirstRowNum + 1 AS row_num,
                             cptt.pkg$trep_reports.getExcelColName(2 +
                                                                   (date_num - 1) * 2 +
                                                                   cols.col_num - 1) AS col_name,
                             CASE cols.col_num
                               WHEN 1 THEN
                                'Кол-во'
                               ELSE
                                'Сумма'
                             END AS VALUE
                      FROM dates,
                           cols
                      --
                      UNION ALL
                      --Категории
                      SELECT vThirdTabFirstRowNum + 1 + cat_num AS row_num,
                             'A' AS col_name,
                             cat_name AS VALUE
                      FROM all_cat
                      --
                      UNION ALL
                      --заголовок Всего по дням
                      SELECT vThirdTabFirstRowNum + 1 +
                             max_cat.all_max_cat_num + 1 AS row_num,
                             'A' AS col_name,
                             'Итого по дням:' AS VALUE
                      FROM max_cat
                      --
                      UNION ALL
                      --ИТОГ
                      SELECT vThirdTabFirstRowNum AS row_num,
                             cptt.pkg$trep_reports.getExcelColName(2 +
                                                                   ceil(pPassEndDate -
                                                                        pPassBeginDate) * 2) AS col_name,
                             'Итог' AS VALUE
                      FROM dual
                      --
                      UNION ALL
                      --ИТОГ(подзаголовки)
                      SELECT vThirdTabFirstRowNum + 1 AS row_num,
                             cptt.pkg$trep_reports.getExcelColName(2 +
                                                                   ceil(pPassEndDate -
                                                                        pPassBeginDate) * 2 +
                                                                   cols.col_num - 1) AS col_name,
                             CASE cols.col_num
                               WHEN 1 THEN
                                'Кол-во'
                               ELSE
                                'Сумма'
                             END AS VALUE
                      FROM cols
                      --
                      UNION ALL
                      --данные
                      SELECT vThirdTabFirstRowNum + 1 + cat_num AS row_num,
                             cptt.pkg$trep_reports.getExcelColName(2 +
                                                                   (date_num - 1) * 2 +
                                                                   cols.col_num - 1) AS col_name,
                             CASE cols.col_num
                               WHEN 1 THEN
                                to_char(count_pass)
                               ELSE
                                to_char(sum_pass, 'FM999999999999990.00')
                             END AS VALUE
                      FROM all_data ad,
                           cols)
  LOOP
    if (third_tab.row_num > vThirdTabLastRowNum) then
      vThirdTabLastRowNum := third_tab.row_num;
    end if;
    INSERT INTO cptt.tmp$trep_report_excel
      (list_num,
       row_num,
       col_name,
       VALUE)
    VALUES
      (1,
       third_tab.row_num,
       third_tab.col_name,
       third_tab.value);
  END LOOP;

END;

END pkg$trep_reports;
/
