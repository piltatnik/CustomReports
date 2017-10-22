CREATE OR REPLACE PACKAGE pkg$trep_reports IS

  -- Author  : PILARTSER
  -- Created : 29.01.2017 11:31:14
  -- Purpose : ������������ ������(������)
  PROCEDURE fillActivationSeriesPrivilege(pActivationBeginDate IN DATE,
                                          pActivationEndDate   IN DATE,
                                          pAllPrivilege        IN VARCHAR2 DEFAULT 'N');
  --���������� ��������� �� ������
  PROCEDURE fillActivationSeries(pActivationBeginDate IN DATE,
                                 pActivationEndDate   IN DATE);

  PROCEDURE fillPassSeriesPrivilegeCarrier(pPassBeginDate IN DATE,
                                           pPassEndDate   IN DATE);

  --���������� �������� � ������������ �� �����, ���������� � ���
  PROCEDURE fillPassSeriesPrivilegeDay(pPassBeginDate IN DATE,
                                       pPassEndDate   IN DATE);

  --���������� ��������, �������� �� �����������/�����������/��������
  PROCEDURE fillPassPrivCarrierRoute(pPassBeginDate IN DATE,
                                     pPassEndDate   IN DATE);

  --���������� ��������, �������� �� ������� ����/�����������/�����������/��������
  PROCEDURE fillPassCardPrivCarrierRoute(pPassBeginDate IN DATE,
                                         pPassEndDate   IN DATE);

  --���������� �������� �������� �� ��������/���������/���
  PROCEDURE fillPassRouteTermDay(pPassBeginDate IN DATE,
                                 pPassEndDate   IN DATE);

  --��������� ��������� ������ �� ������ ��� ������� � ��������� �������� (��� �� ������������������ � t_data � �� ������)
  PROCEDURE fillData(pPassBeginDate IN DATE, pPassEndDate IN DATE);

  --��������� ���������� ������������� ������� excel
  FUNCTION getExcelColName(pColNum IN NUMBER) RETURN VARCHAR2;

  --��������� range ��� ������� ������� � �������
  FUNCTION getRange(pColNameBegin IN VARCHAR2,
                    pRowNumBegin  IN NUMBER,
                    pColNameEnd   IN VARCHAR2,
                    pRowNumEnd    IN NUMBER) RETURN VARCHAR2;

  --��������� �������� id_privilege ��� ���������� (��� �����������!!!)
  --���� �������� ������� ��� ������!
  FUNCTION getIdPrivilegeTrue(pSeries IN VARCHAR2, pIdPrivilege IN NUMBER)
    RETURN NUMBER;

  --������������ ��������
  FUNCTION getRouteName(pIdRoute IN NUMBER) RETURN VARCHAR;

  --������������ ����������
  FUNCTION getCarrierName(pIdRoute IN NUMBER) RETURN VARCHAR;

  --������� �����������(�/�/UNKNOWN)
  FUNCTION getCarrierPrefix(pIdRoute IN NUMBER) RETURN VARCHAR2;
    
  --������������ ������ ��������������� �������
  PROCEDURE setAgentLockedState(pAgentsStateList IN CLOB);
  
  --������������ ������ ��������������� �������������
  PROCEDURE setDivisionLockedState(pDivisionsStateList IN CLOB);

  --������������ ������ ���������-��������� � ���������� ���������� ����������� ������� � ������������ ���������
  PROCEDURE fillReportActivePassExcel(pActivationBeginDate         IN DATE,
                                      pActivationEndDate           IN DATE,
                                      pPassBeginDate               IN DATE,
                                      pPassEndDate                 IN DATE,
                                      pIsRegionalPrivilegeSplitted IN VARCHAR2 DEFAULT 'N');
  --���������-��������� � �������������
  PROCEDURE fillReportActivePassCommercial(pActivationBeginDate         IN DATE,
                                      pActivationEndDate           IN DATE,
                                      pPassBeginDate               IN DATE,
                                      pPassEndDate                 IN DATE);

  --����� �� ��������� ��������� ��������
  PROCEDURE fillReportActiveAgents(pActivationBeginDate IN DATE,
                                   pActivationEndDate   IN DATE,
                                   pPassBeginDate               IN DATE,
                                   pPassEndDate                 IN DATE);

  PROCEDURE fillReportPrivilegeExcel(pActivationBeginDate IN DATE,
                                     pActivationEndDate   IN DATE,
                                     pPassBeginDate       IN DATE,
                                     pPassEndDate         IN DATE);

  --����� �� ��������
  PROCEDURE fillReportRouteExcel(pIdRoute       IN NUMBER,
                                 pPassBeginDate IN DATE,
                                 pPassEndDate   IN DATE);
                                 
  --����� �� �����������(����������� ����� ��������������� ������ fillActivationSeriesPrivilege � fillPassSeriesPrivilegeCarrier)
  PROCEDURE fillReportOrganisationExcel(pIdCarrier IN NUMBER,
                                        pPassBeginDate IN DATE,
                                        pPassEndDate IN DATE);

  --����� �� ��������� ����������(����������� ������������� ����������� fillDataTerminal)
  PROCEDURE fillReportTerminalExcel(pIdTerminal    IN NUMBER,
                                    pPassBeginDate IN DATE,
                                    pPassEndDate   IN DATE);

  PROCEDURE fillReportTransactionExcel(pPassBeginDate IN DATE,
                                       pPassEndDate   IN DATE);
                                       
  --����� �� ������������ �����
  PROCEDURE fillReportTransportCardExcel(pCardNum IN NUMBER,
                                    pActivationBeginDate IN DATE,
                                    pActivationEndDate   IN DATE,
                                    pPassBeginDate       IN DATE,
                                    pPassEndDate         IN DATE);

  PROCEDURE fillReportVehicleExcel(pIdVehicle IN NUMBER, pPassBeginDate IN DATE, pPassEndDate IN DATE);

END pkg$trep_reports;
/
CREATE OR REPLACE PACKAGE BODY pkg$trep_reports IS

  CRLF VARCHAR2(3) :=  /*chr(10) ||*/
   chr(13);
  --���������� �������������� ���� � ������������ �� ����� � ����������
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
        WHERE trans.kind IN (7, 8, 10, 11, 12, 13, 37) --���������
        AND trans.d = 0 -- �� ������
        AND ((nvl(trans.new_card_series, trans.card_series) IN
              ('50', '52', '53') AND
              trunc(trans.date_of) >= add_months(trunc(pActivationEndDate, 'mm'), -1) + 22 AND
              trunc(trans.date_of) <=
              add_months(trunc(pActivationEndDate, 'mm'), 1) - 15) OR
              ((nvl(trans.new_card_series, trans.card_series) NOT IN
              ('50', '52', '53') AND
              trunc(trans.date_of) >= pActivationBeginDate --������ ���������
              AND trunc(trans.date_of) <= pActivationEndDate))) --
             
        AND trans.id_division = div.id --����������� �������� ����������
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

  --���������� ��������� �� ������
  PROCEDURE fillActivationSeries(pActivationBeginDate IN DATE,
                                 pActivationEndDate   IN DATE) AS
  BEGIN
    DELETE FROM cptt.tmp$trep_active_seriesagents;
    FOR rec IN (WITH trans AS
                   (SELECT nvl(trans.new_card_series, trans.card_series) AS series,
                           div.id_operator,
                           nvl(decode(nvl(trans.new_card_series, trans.card_series),'16', 950, amount), 0) - nvl(amount_bail, 0) AS amount,
                           nvl(amount_bail, 0) AS amount_bail
                    FROM cptt.t_data   trans,
                         cptt.division div
                    WHERE trans.kind IN (7, 8, 10, 11, 12, 13, 37) --���������
                    AND trans.d = 0 -- �� ������
                    AND trunc(trans.date_of) >= pActivationBeginDate --������ ���������
                    AND trunc(trans.date_of) <= pActivationEndDate
/*                    AND ((nvl(trans.new_card_series, trans.card_series) NOT IN
                          ('50', '52', '53')) OR
                          (nvl(trans.new_card_series, trans.card_series) IN ('50', '52', '53') AND
                          (trunc(trans.date_of) >= add_months(trunc(pActivationEndDate, 'mm'), -1) + 22 AND
                          trunc(trans.date_of) <=
                          add_months(trunc(pActivationEndDate, 'mm'), 1) - 15)))*/
                    AND trans.id_division = div.id --����������� �������� ����������
                    AND div.id_operator NOT IN (SELECT id FROM cptt.ref$trep_agents_locked))
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
  --���������� �������� � ������������ �� �����, ���������� � ���������
  PROCEDURE fillPassSeriesPrivilegeCarrier(pPassBeginDate IN DATE,
                                           pPassEndDate   IN DATE) AS
  BEGIN
    DELETE FROM TMP$TREP_PASS_SERIESPRIVOP;
    FOR rec IN (WITH carrier AS
                   (SELECT id_operator
                   FROM cptt.v$trep_carriers),
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
                          carrier.id_operator,
                          trans.kind
                   FROM cptt.t_data   trans,
                        cptt.division div,
                        carrier
                   WHERE trans.date_of >= pPassBeginDate
                   AND trans.date_of < pPassEndDate
                   AND trans.d = 0 -- �� ������
                   AND trans.id_division = div.id
                   AND div.id_operator = carrier.id_operator
                   AND trans.kind IN ('32', '14', '17', '20'))
                  SELECT series,
                         id_privilege,
                         id_operator,
                         nvl(sum(decode(kind, '20', -1, 1)), 0) AS count_pass,
                         nvl(SUM(decode(kind, '20', -amount, amount)), 0) AS sum_pass
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

  --���������� �������� � ������������ �� �����, ���������� � ���
  PROCEDURE fillPassSeriesPrivilegeDay(pPassBeginDate IN DATE,
                                       pPassEndDate   IN DATE) AS
  BEGIN
    DELETE FROM cptt.tmp$trep_pass_seriesprivday;
    --�������� ���� ������� �� ������ ��� �� ������ ������� � ���� ������ ��������� �������
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
         (SELECT id_operator
           FROM cptt.v$trep_carriers),
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
                        NULL) AS id_privilege,
                 trans.kind
          FROM cptt.t_data   trans,
               cptt.division div,
               carrier
          WHERE trans.date_of >= date_rec.begin_date
          AND trans.date_of < date_rec.begin_date + 1
               --�� ������ ���� ����� ��������� ������� �� ��������� � �������� ������ �������
          AND trans.date_of < pPassEndDate
          AND trans.d = 0 -- �� ������
          AND trans.kind IN ('32', '14', '17', '20')
          AND trans.id_division = div.id
          AND div.id_operator = carrier.id_operator
          AND (div.id_operator != 16100246845 OR nvl(trans.new_card_series, trans.card_series) IS NOT NULL))
        SELECT pass.series,
               id_privilege,
               date_rec.begin_date,
               nvl(sum(decode(kind, '20', -1, 1)), 0) AS count_pass
        FROM pass
        GROUP BY pass.series,
                 pass.id_privilege;
    END LOOP;
    COMMIT;
  END;

  --���������� ��������, �������� �� �����������/�����������/��������
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
                   AND div.id_operator = c.id_operator
                   AND div.id NOT IN (SELECT id FROM cptt.ref$trep_divisions_locked)),
                  pass AS
                   (SELECT trans.card_num,
                          getIdPrivilegeTrue(nvl(trans.new_card_series,
                                                 trans.card_series),
                                             trans.id_privilege) AS id_privilege,
                          carrier.id_operator,
                          trans.id_route,
                          trans.kind
                   FROM cptt.t_data          trans,
                        cptt.division        div,
                        cptt.v$trep_carriers carrier,
                        cptt.privilege       priv,
                        rt
                   WHERE trans.date_of >= pPassBeginDate
                   AND trans.date_of < pPassEndDate
                   AND trans.d = 0 -- �� ������
                   AND trans.kind IN ('32', '14', '17', '20')
                   AND trans.id_division = div.id
                   AND div.id_operator = carrier.id_operator
                   AND div.id NOT IN (SELECT id from cptt.ref$trep_divisions_locked)
                   AND trans.id_privilege = priv.id
                   AND trans.id_route = rt.id)
                  SELECT id_privilege,
                         id_operator,
                         id_route,
                         nvl(sum(decode(kind, '20', -1, 1)), 0) AS count_pass
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

  --���������� ��������, �������� �� ������� ����/�����������/�����������/��������
  PROCEDURE fillPassCardPrivCarrierRoute(pPassBeginDate IN DATE,
                                         pPassEndDate   IN DATE) AS
  BEGIN
    DELETE FROM cptt.tmp$trep_pass_cardprivoproute;
    FOR rec IN (WITH carrier AS
                   (SELECT id_operator
                   FROM cptt.v$trep_carriers),
                  rt AS
                   (SELECT r.id
                   FROM ROUTE    r,
                        division div,
                        carrier  c
                   WHERE r.id_division = div.id
                   AND div.id_operator = c.id_operator
                   AND div.id NOT IN (SELECT id FROM cptt.ref$trep_divisions_locked)),
                  pass AS
                   (SELECT trans.card_num,
                          cptt.pkg$trep_reports.getIdPrivilegeTrue(nvl(trans.new_card_series,
                                                                       trans.card_series),
                                                                   trans.id_privilege) AS id_privilege,
                          carrier.id_operator,
                          trans.id_route,
                          trans.kind
                   FROM cptt.t_data    trans,
                        cptt.division  div,
                        carrier,
                        cptt.privilege priv,
                        rt
                   WHERE trans.date_of >= pPassBeginDate
                   AND trans.date_of < pPassEndDate
                   AND trans.d = 0 -- �� ������
                   AND trans.kind IN ('32', '14', '16', '17', '20')
                   AND trans.id_division = div.id
                   AND div.id_operator = carrier.id_operator
                   AND trans.id_privilege = priv.id
                   AND trans.id_route = rt.id)
                  SELECT card_num,
                         id_privilege,
                         id_operator,
                         id_route,
                         nvl(sum(decode(kind, '20', -1, 1)), 0) AS count_pass
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

  --���������� �������� �������� �� ��������/���������/���
  PROCEDURE fillPassRouteTermDay(pPassBeginDate IN DATE,
                                 pPassEndDate   IN DATE) AS
  BEGIN
    DELETE FROM cptt.tmp$trep_pass_routetermday;
    FOR rec IN (WITH rt AS
                   (SELECT r.id
                   FROM ROUTE    r
                   WHERE r.id_division IN
                    (SELECT div.id
                     FROM cptt.division div,
                          cptt.operator op
                     WHERE div.id_operator = op.id
                     AND div.id NOT IN (SELECT id FROM cptt.ref$trep_divisions_locked)
                     AND op.id NOT IN (SELECT id FROM cptt.ref$trep_agents_locked)
                     AND op.role = 1)),
                  dates AS
                   (SELECT pPassBeginDate + LEVEL - 1 AS begin_date
                   FROM dual
                   START WITH pPassBeginDate < pPassEndDate
                   CONNECT BY pPassBeginDate + LEVEL - 1 < pPassEndDate
                   ORDER BY LEVEL),
                  pass AS
                   (SELECT trans.id_route,
                          trans.id_term,
                          dates.begin_date AS DAY,
                          trans.kind
                   FROM cptt.t_data          trans,
                        rt,
                        dates
                   WHERE trans.date_of >= pPassBeginDate
                   AND trans.date_of < pPassEndDate
                   AND trans.d = 0 -- �� ������
                   AND trans.kind IN ('32', '14', '16', '17', '20')
                   AND trans.id_division IN
                      (SELECT div.id
                       FROM cptt.division div,
                            cptt.operator op
                       WHERE div.id_operator = op.id
                       AND div.id NOT IN (SELECT id FROM cptt.ref$trep_divisions_locked)
                       AND op.id NOT IN (SELECT id FROM cptt.ref$trep_agents_locked)
                       AND op.role = 1)
                   AND trans.id_route = rt.id
                   AND trans.date_of >= dates.begin_date
                   AND trans.date_of < dates.begin_date + 1)
                  SELECT id_route,
                         id_term,
                         DAY,
                         nvl(sum(decode(kind, '20', -1, 1)), 0) AS count_pass
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

  --��������� ��������� ������ �� ������ ��� ������� � ��������� �������� (��� �� ������������������ � t_data � �� ������)
  PROCEDURE fillData(pPassBeginDate IN DATE, pPassEndDate IN DATE) AS
  BEGIN
    DELETE FROM cptt.tmp$trep_data;
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
         file_rn,
         card_num) 
    SELECT trans.id_term,
           nvl(trans.new_card_series, trans.card_series) AS series,
           trans.kind,
           trans.date_of,
           nvl(trans.amount, 0) - nvl(trans.amount_bail, 0) AS amount,
           getIdPrivilegeTrue(nvl(trans.new_card_series,
                                        trans.card_series),
                              trans.id_privilege) as id_privilege,
           trans.id_route,
           trans.id_vehicle,
           trans.train_table,
           trans.file_rn,
           trans.card_num
    FROM cptt.t_data          trans
    WHERE trans.date_of >= pPassBeginDate
    AND trans.date_of < pPassEndDate
    AND trans.d = 0
    AND trans.kind IN ('1', '2', '32', '14', '16', '17', '20')
    AND trans.id_route IS NOT NULL
    AND trans.id_term IS NOT NULL
    AND trans.id_division IN
      (SELECT div.id
       FROM cptt.division div,
            cptt.operator op
       WHERE div.id_operator = op.id
       AND div.id NOT IN (SELECT id FROM cptt.ref$trep_divisions_locked)
       AND op.id NOT IN (SELECT id FROM cptt.ref$trep_agents_locked)
       AND op.role = 1);
    COMMIT;
  END;

  --��������� ���������� ������������� ������� excel
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

  --��������� range ��� ������� ������� � �������
  FUNCTION getRange(pColNameBegin IN VARCHAR2,
                    pRowNumBegin  IN NUMBER,
                    pColNameEnd   IN VARCHAR2,
                    pRowNumEnd    IN NUMBER) RETURN VARCHAR2 AS
  BEGIN
    RETURN pColNameBegin || to_char(pRowNumBegin) || ':' || pColNameEnd || to_char(pRowNumEnd);
  END;

  --��������� �������� id_privilege ��� ���������� (��� �����������!!!)
  --���� �������� ������� ��� ������!
  FUNCTION getIdPrivilegeTrue(pSeries IN VARCHAR2, pIdPrivilege IN NUMBER)
    RETURN NUMBER AS
    vIdPrivilege NUMBER;
  BEGIN
    SELECT CASE
           --���� �� ������������� ����� ���� ����, ���� ���, ���� �� �������
             WHEN pSeries LIKE '1%' OR pSeries LIKE '2%' OR
                  pSeries LIKE '3%' THEN
              CASE
              --�������
                WHEN pSeries LIKE '_1' THEN
                 1000246845
              --�������_50
                WHEN pSeries LIKE '_2' THEN
                 1100246845
              --�������_100
                WHEN pSeries LIKE '_3' THEN
                 1200246845
              --��������
                WHEN pSeries LIKE '_4' THEN
                 1300246845
              --��������_50
                WHEN pSeries LIKE '_5' THEN
                 1400246845
              --��������_100
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

  --������������ ��������
  FUNCTION getRouteName(pIdRoute IN NUMBER) RETURN VARCHAR AS
    RESULT VARCHAR2(10);
  BEGIN
    SELECT getCarrierPrefix(pIdRoute) ||
           r.code
    INTO RESULT
    FROM ROUTE                r,
         division             div
    WHERE r.id_division = div.id
    AND r.id = pIdRoute;
    RETURN RESULT;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 'UNKNOWN';
  END;

  --������������ ����������
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

  FUNCTION getCarrierPrefix(pIdRoute IN NUMBER) RETURN VARCHAR2 AS
  RESULT VARCHAR2(8);
  BEGIN
    SELECT decode(div.id_operator,
                  400246845,
                  '�',
                  500246845,
                  '�',
                  16100246845,
                  '�',
                  'UNKNOWN')
    INTO RESULT
    FROM cptt.route    r,
         cptt.division div
    WHERE r.id_division = div.id
    AND r.id = pIdRoute;
    RETURN RESULT;
  EXCEPTION
    WHEN no_data_found THEN
      RETURN 'UNKNOWN';
  END;


  --��������� ����������������� ������
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

  --������������ ������ ��������������� �������
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
                                '������ ������������ ������ ��������������� �������');
      END;
  END;

  --��������� ����������������� �������������
  PROCEDURE setDivisionLockedState(pIdDivision IN NUMBER,
                                pIsLocked   IN VARCHAR2) AS
    vCntDivision NUMBER;
  BEGIN
    IF (pIsLocked = 'Y') THEN
      SELECT COUNT(0)
      INTO vCntDivision
      FROM cptt.ref$trep_divisions_locked
      WHERE id = pIdDivision;
      IF (vCntDivision = 0) THEN
        INSERT INTO cptt.ref$trep_divisions_locked (id) VALUES (pIdDivision);
      END IF;
    ELSE
      DELETE FROM cptt.ref$trep_divisions_locked tal
      WHERE tal.id = pIdDivision;
    END IF;
  END;

  --������������ ������ ��������������� �������������
  PROCEDURE setDivisionLockedState(pDivisionsStateList IN CLOB) AS
    vXml sys.xmltype;
  BEGIN
    IF pDivisionsStateList IS NOT NULL THEN
      vXml := xmltype(pDivisionsStateList);
      FOR rec IN (SELECT extractValue(VALUE(t), 'division/id') AS id,
                         extractValue(VALUE(t), 'division/state') AS state
                  FROM TABLE(XMLSequence(vXml.extract('divisions/division'))) t)
      LOOP
        setDivisionLockedState(rec.id, rec.state);
      END LOOP;
      COMMIT;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        ROLLBACK;
        raise_application_error(-20020,
                                '������ ������������ ������ ��������������� �������������');
      END;
  END;

  --������������ ������ ���������-��������� � ���������� ���������� ����������� ������� � ������������ ���������
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
                                                   pactivationenddate,
                                                   pIsRegionalPrivilegeSplitted);
  
    pkg$trep_reports.fillpassseriesprivilegeCarrier(pPassbegindate,
                                                    pPassenddate);
  
    FOR rec IN (WITH non_priv_primary AS
                   (SELECT DISTINCT nvl(ts.synthetic_series, ts.series) AS series,
                                   ts.id_pay_type,
                                   NULL AS id_privilege,
                                   NULL AS privilege_type
                   FROM cptt.ref$trep_series ts
                   WHERE series not in ('17', '10', '90', '60')
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
                            WHEN series IN ('150', '252', '353') THEN
                             '      �������� (�� ���������)'
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
                          '   ������������ ���������' AS row_name,
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
                          '      �������� (�� ���������)',
                          30 + vCityPrivilegeCount + vRegionalPrivilegeCount AS row_num
                   FROM dual
                   UNION ALL
                   SELECT NULL AS point,
                          '      �������� (�� ���������)',
                          34 + vCityPrivilegeCount + vRegionalPrivilegeCount AS row_num
                   FROM dual
                   */
                   --
                   ),
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
                               25 + vCityPrivilegeCount +
                               vRegionalPrivilegeCount)
                   WHERE nvl(pIsRegionalPrivilegeSplitted, 'N') = 'Y'
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
                          '������������ ����� ' || CRLF ||
                          '��������� Ultralight' || CRLF ||
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
                          SUM(nvl(tas.count_active, 0)) AS count_active,
                          SUM(nvl(tas.sum_active, 0)) AS sum_active
                   FROM value_rows vr
                   LEFT OUTER JOIN cptt.TMP$TREP_ACTIVE_SERIESPRIV tas
                   ON (vr.series = tas.series AND
                      (vr.id_privilege = tas.id_privilege OR
                      (vr.id_privilege IS NULL AND
                      tas.id_privilege IS NULL) OR
                      --������ ������� ������ ������������ ����������
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
                      --������ ������� ������ ������������ ����������
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
                   --����� �� ����������
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
                             r.row_num || '/J' || r.row_num || ', 4))'
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
                             r.row_num || '/J' || r.row_num || ', 4))'
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

  PROCEDURE fillReportActivePassCommercial(pActivationBeginDate         IN DATE,
                                      pActivationEndDate           IN DATE,
                                      pPassBeginDate               IN DATE,
                                      pPassEndDate                 IN DATE) AS
      vActivationHalfBeginDate DATE; 
      vActivationHalfEndDate DATE;
      vEPSLCount NUMBER;
      vPrivilegeCount NUMBER;
  BEGIN
      DELETE FROM cptt.TMP$TREP_REPORT_EXCEL;
      DELETE FROM cptt.tmp$trep_report_excel_format;

      vActivationHalfBeginDate := add_months(trunc(pActivationEndDate, 'mm'),
                                          -1) + 22;
      vActivationHalfEndDate   := add_months(trunc(pActivationEndDate, 'mm'),
                                              1) - 14;
      select count(distinct card_num) 
      into vEPSLCount 
      from cptt.t_data   trans,
               cptt.division div
          WHERE trans.kind IN (7, 8, 10, 11, 12, 13, 39, 37) --���������
          AND trans.d = 0 -- �� ������
          AND date_of >= pActivationBeginDate
          AND date_of < trunc(pActivationEndDate) + 1
          AND nvl(trans.new_card_series, trans.card_series) IN ('10', '90', '60');
      select nvl(count(1), 0)+4 into vPrivilegeCount  from cptt.privilege where code LIKE '000000__' --or code LIKE '100000__'
      ;
     
    for rec in (
      WITH trans_activepass AS
     (SELECT nvl(amount, 0) - nvl(amount_bail, 0) AS amount,
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
      WHERE (trans.kind IN (7, 8, 10, 11, 12, 13, 37) --���������
            OR -- ���� �� ��������
            trans.kind IN (32, 14, 16, 17, 20) --������
            OR
            nvl(trans.new_card_series, trans.card_series) IN ('10', '90', '60') AND trans.kind IN (39)
            OR
            nvl(trans.new_card_series, trans.card_series) NOT IN ('10', '90', '60') AND trans.kind IN (36)
            )
      AND trans.d = 0 -- �� ������
      AND date_of >= CASE
              WHEN trans.kind IN (32, 14, 16, 17, 20) THEN
               pPassBeginDate
              WHEN trans.kind IN (7, 8, 10, 11, 12, 13, 36, 37, 39) THEN
               CASE
                 WHEN nvl(trans.new_card_series, trans.card_series) IN
                      ('50', '52', '53') THEN
                  vActivationHalfBeginDate
                 ELSE
                  pActivationBeginDate
               END
            END
      AND date_of < CASE
              WHEN trans.kind IN (32, 14, 16, 17, 20) THEN
               pPassEndDate
              WHEN (trans.kind IN (7, 8, 10, 11, 12, 13, 36, 37, 39)) THEN
               CASE
                 WHEN nvl(trans.new_card_series, trans.card_series) IN
                      ('50', '52', '53') THEN
                  vActivationHalfEndDate
                 ELSE
                  trunc(pActivationEndDate) + 1
               END
            END
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
             '60') OR nvl(trans.new_card_series, trans.card_series) IS NULL)
      AND trans.id_division = div.id --����������� ��������������� ���������� � ��������������� ������������
      AND div.id_operator NOT IN
            (SELECT id
             FROM cptt.ref$trep_agents_locked)
      AND div.id NOT IN
             (SELECT id
             FROM cptt.ref$trep_divisions_locked)),
    trans_grouped_first as (SELECT trans_type,
           series,
           id_privilege,
           id_operator,
           id_division,
           kind,
           nvl(case 
                  when trans_type = 'PASS' then SUM(1)
                  when trans_type = 'ACTIVE' then 
                    case when series in ('10', '90', '60') then 0 else SUM(1) end 
               end, 0) as count_trans,
--           nvl(case when series in ('10', '90', '60') then count(distinct card_num) else SUM(1) end, 0) as count_trans,
           nvl(SUM(amount), 0) as sum_trans
    FROM trans_activepass ta
    GROUP BY trans_type,
             series,
             id_privilege,
             id_operator,
             id_division,
             kind),
     contents as 
     (select '1.' as key, '' as parent_key, '���������� ������������������� ������������ �����, ����� � ��� �����:' as caption from dual
     union all
     select '1.1.' as key, '1.' as parent_key, '������������ ����� "��������"' as caption from dual
     union all
     select '1.1.1.' as key, '1.1.' as parent_key, '�� 1 ���, � �.�.:' as caption from dual
     union all
     select '1.1.1.1.' as key, '1.1.1.' as parent_key, '��������' as caption from dual
     union all
     select '1.1.1.2.' as key, '1.1.1.' as parent_key, '��������' as caption from dual
     union all
     select '1.1.2.' as key, '1.1.' as parent_key, '�� 2 ���� ����������, � �.�.:' as caption from dual
     union all
     select '1.1.2.1.' as key, '1.1.2.' as parent_key, '��������' as caption from dual
     union all
     select '1.1.2.2.' as key, '1.1.2.' as parent_key, '��������' as caption from dual
     union all
     select '1.1.2.3.' as key, '1.1.2.' as parent_key, '����������' as caption from dual
     union all
     select '1.2.' as key, '1.' as parent_key, '������������ ����� "������������"' as caption from dual
     union all
     select '1.2.1.' as key, '1.2.' as parent_key, '�� 1 ���, � �.�.:' as caption from dual
     union all
     select '1.2.1.1.' as key, '1.2.1.' as parent_key, '��������' as caption from dual
     union all
     select '1.2.1.2.' as key, '1.2.1.' as parent_key, '��������' as caption from dual
     union all
     select '1.2.1.3.' as key, '1.2.1.' as parent_key, '������' as caption from dual
     union all
     select '1.2.2.' as key, '1.2.' as parent_key, '�� 2 ���� ����������, � �.�.:' as caption from dual
     union all
     select '1.2.2.1.' as key, '1.2.2.' as parent_key, '��������' as caption from dual
     union all
     select '1.2.2.2.' as key, '1.2.2.' as parent_key, '��������' as caption from dual
     union all
     select '1.2.2.3.' as key, '1.2.2.' as parent_key, '������' as caption from dual
     union all
     select '1.2.2.4.' as key, '1.2.2.' as parent_key, '����������' as caption from dual
     union all
     select '1.3.' as key, '1.' as parent_key, '������������ ����� "��������"' as caption from dual
     union all
     select '1.3.1.' as key, '1.3.' as parent_key, '��������� ���������, � �.�.:' as caption from dual
     union all
     select '1.3.1.'||row_number() over(order by code)||'.' as key, '1.3.1.' as parent_key, lower(name) || ' (' || code || ')' as caption  from cptt.privilege where code LIKE '000000__'
     union all
     select '1.3.2.' as key, '1.3.' as parent_key, '����������� ���������' as caption from dual
     union all
     select '1.3.3.' as key, '1.3.' as parent_key, '������������ ���������, � �.�.:' as caption from dual
     union all
     select '1.3.3.'||row_number() over(order by code)||'.' as key, '1.3.3.' as parent_key, lower(name) || ' (' || code || ')' as caption  from cptt.privilege 
                                                                    where code LIKE '100000__' AND code IN ('10000004', '10000007', '10000008')
     union all
     select '1.3.3.4.', '1.3.3.' as parent_key, '����' as caption from dual
     union all
     select '2.' as key, '' as parent_key, '������������ ����� "���������", � �.�.:' as caption from dual
     union all
     select '2.1.' as key, '2.' as parent_key, '��������� ����� �� ����� (����������� ����� �������� Mifare)' as caption from dual
     union all
     select '2.1.1.' as key, '2.1.' as parent_key, '�� 1 ���, � �.�.:' as caption from dual
     union all
     select '2.1.1.1.' as key, '2.1.1.' as parent_key, '�������� ������' as caption from dual
     union all
     select '2.1.1.2.' as key, '2.1.1.' as parent_key, '�������� (�� ���������)' as caption from dual
     union all
     select '2.1.1.3.' as key, '2.1.1.' as parent_key, '�����������' as caption from dual
     union all
     select '2.1.2.' as key, '2.1.' as parent_key, '�� 2 ����, � �.�.:' as caption from dual
     union all
     select '2.1.2.1.' as key, '2.1.2.' as parent_key, '�������� ������' as caption from dual
     union all
     select '2.1.2.2.' as key, '2.1.2.' as parent_key, '�������� (�� ���������)' as caption from dual
     union all
     select '2.1.2.3.' as key, '2.1.2.' as parent_key, '�����������' as caption from dual
     union all
     select '2.2.' as key, '2.' as parent_key, '������������ ����� ��������� Ultralight (������������� �������� �����)' as caption from dual
     union all
     select '2.3.' as key, '2.' as parent_key, '������������ ������� (����������� �������)' as caption from dual
     union al
     select '6.' as key, '' as parent_key, '�� �������� �������� ��������, �����' as caption from dual
     union all
     select '3.' as key, '' as parent_key, '���������� �����' as caption from dual),
trans_grouped_second as(     
     select case
              when series in ('24', '34') then '1.1.1.1.'
              when series in ('25', '35') then '1.1.1.2.'
              when series in ('14') then '1.1.2.1.'
              when series in ('15') then '1.1.2.2.'
              when series in ('16') then '1.1.2.3.'
              when series in ('21', '31') then '1.2.1.1.'
              when series in ('22', '32') then '1.2.1.2.'
              when series in ('23', '33') then '1.2.1.3.'
              when series in ('11') then '1.2.2.1.'
              when series in ('12') then '1.2.2.2.'
              when series in ('13') then '1.2.2.3.'
              when series in ('20') then '1.2.2.4.'
              when series in ('17') then case
                                         when priv.code LIKE '000000__' then '1.3.1.'||to_char(priv.num)||'.'
                                         when priv.code LIKE '200%' then '1.3.2.'
                                         when priv.code LIKE '100000__' then 
                                           case 
                                             when priv.code IN ('10000004', '10000007', '10000008')
                                                  then '1.3.3.'||to_char(priv.num)||'.'    
                                             else
                                                  '1.3.3.4.'    
                                           end
                                         end
              when series in ('29', '39') then '2.1.1.1.'
              when series in ('52', '53') then '2.1.1.2.'
              when series in ('42', '45', '43', '46') then '2.1.1.3.'
              when series in ('19') then '2.1.2.1.'
              when series in ('50') then '2.1.2.2.'
              when series in ('41', '44') then '2.1.2.3.'
              when series in ('10', '90', '60') then '2.3.'  
              when series in ('96') then '3.'
            end as key,
           tgf.trans_type,
           tgf.series,
           tgf.id_privilege,
           tgf.id_operator,
           tgf.id_division,
           tgf.kind,
           tgf.count_trans,
           tgf.sum_trans 
           from trans_grouped_first tgf 
                left outer join (select id, code, 
                                            row_number() over(partition by case when code LIKE '000000__' then 1 when code LIKE '200%' then 2 when code LIKE '100000__' then 3 else 4 end order by case when code IN ('10000004', '10000007', '10000008') then 1 else 2 end, code) as num 
                                 from cptt.privilege where code LIKE '000000__' or code LIKE '200%' or code LIKE '100000__') priv 
                             on tgf.id_privilege = priv.id),
     carriers as 
     (SELECT op.id as id_operator,
             CASE
               WHEN op.id IN (400246845, 500246845) THEN NULL  
               ELSE div.id
             END as id_division,
             CASE
               WHEN op.id IN (400246845, 500246845) THEN
                op.name
               ELSE
                div.name
             END as name,
             dense_rank() OVER (order by case 
                                         when op.id in (400246845, 500246845) 
                                           then 1 
                                         else 2 
                                         end, op.id, div.id) + 1 as list_num
        FROM cptt.operator op
             INNER JOIN cptt.division div
                   ON (div.id_operator = op.id)
        WHERE op.id NOT IN (SELECT id
                            FROM cptt.ref$trep_agents_locked)
              AND op.role = 1
              AND div.id NOT IN (SELECT id
                            FROM cptt.ref$trep_divisions_locked)
               
               
        ),
     contents_trans as
     (select con.key, con.parent_key, con.caption, 
             tgs.trans_type,
             tgs.series,
             tgs.id_privilege,
             tgs.id_operator,
             tgs.id_division,
             tgs.kind,
             tgs.count_trans,
             tgs.sum_trans 
     from contents con
          left outer join trans_grouped_second tgs
               on (tgs.key = con.key)),
     page1_pre1 as
     (select ct.key, ct.parent_key, ct.caption, 
            sum(case when ct.trans_type='ACTIVE' then count_trans else 0 end) + decode(key, '4.', vEPSLCount, 0) as count_active_all,
            sum(case when ct.trans_type='ACTIVE' AND (1=2/*����� ��������� ���� ����� �������?*/) then count_trans else null end) as count_active_other,
            sum(case when (ct.trans_type='ACTIVE')  AND (series in ('31', '32', '33', '34', '35', '36', '39', '53', '43', '46')) then count_trans else null end) as count_active_ak,
            sum(case when (ct.trans_type='ACTIVE')  AND (series in ('21', '22', '23', '24', '25', '26', '29', '52', '42', '45')) then count_trans else null end) as count_active_urt,
            sum(case when ct.trans_type='PASS' then decode(kind, 20, -count_trans, count_trans) else 0 end) as count_pass_all,
            sum(case when ct.trans_type='PASS' AND ct.id_operator not in (400246845, 500246845) then decode(kind, 20, -count_trans, count_trans) else 0 end) as count_pass_other,
            sum(case when ct.trans_type='PASS' AND ct.id_operator in (500246845) then decode(kind, 20, -count_trans, count_trans) else 0 end) as count_pass_ak,
            sum(case when ct.trans_type='PASS' AND ct.id_operator in (400246845) then decode(kind, 20, -count_trans, count_trans) else 0 end) as count_pass_urt
     from contents_trans ct/*
          left outer join carriers car 
               on ct.id_operator = car.id    */
     group by ct.key, ct.parent_key, ct.caption),
     page1_pre2 as (select *
     from page1_pre1
     start with parent_key is null
     connect by prior key = parent_key
     model 
     dimension by (key, parent_key, caption, rownum r)
     measures(count_active_all, count_active_other, count_active_ak, count_active_urt, count_pass_all, count_pass_other, count_pass_ak, count_pass_urt)
     rules 
     (
       count_active_all[any, any, any, any] order by r desc = nvl(count_active_all[cv(), cv(), cv(), cv()], 0) + nvl(sum(count_active_all)[any, cv(key), any, any], 0),
       count_active_other[any, for parent_key in ('1.1.1.', '1.2.1.', '2.1.1.'), any, any] = nvl(count_active_other[cv(), cv(), cv(), cv()], 0),
       count_active_other[for key in ('1.1.1.', '1.2.1.', '2.1.1.'), any, any, any] order by r desc = nvl(count_active_other[cv(), cv(), cv(), cv()], 0) + nvl(sum(count_active_other)[any, cv(key), any, any], 0),
       count_active_ak[any, for parent_key in ('1.1.1.', '1.2.1.', '2.1.1.'), any, any] = nvl(count_active_ak[cv(), cv(), cv(), cv()], 0),
       count_active_ak[for key in ('1.1.1.', '1.2.1.', '2.1.1.'), any, any, any] order by r desc = nvl(count_active_ak[cv(), cv(), cv(), cv()], 0) + nvl(sum(count_active_ak)[any, cv(key), any, any], 0),
       count_active_urt[any, for parent_key in ('1.1.1.', '1.2.1.', '2.1.1.'), any, any] = nvl(count_active_urt[cv(), cv(), cv(), cv()], 0),
       count_active_urt[for key in ('1.1.1.', '1.2.1.', '2.1.1.'), any, any, any] order by r desc = nvl(count_active_urt[cv(), cv(), cv(), cv()], 0) + nvl(sum(count_active_urt)[any, cv(key), any, any], 0),
       count_pass_all[any, any, any, any] order by r desc = nvl(count_pass_all[cv(), cv(), cv(), cv()], 0) + nvl(sum(count_pass_all)[any, cv(key), any, any], 0),
       count_pass_other[any, any, any, any] order by r desc = nvl(count_pass_other[cv(), cv(), cv(), cv()], 0) + nvl(sum(count_pass_other)[any, cv(key), any, any], 0),
       count_pass_ak[any, any, any, any] order by r desc = nvl(count_pass_ak[cv(), cv(), cv(), cv()], 0) + nvl(sum(count_pass_ak)[any, cv(key), any, any], 0),
       count_pass_urt[any, any, any, any] order by r desc = nvl(count_pass_urt[cv(), cv(), cv(), cv()], 0) + nvl(sum(count_pass_urt)[any, cv(key), any, any], 0)
     )),
     page1_pre3 as
     (select key, parent_key, caption, 
            count_active_all, count_active_other, count_active_ak, count_active_urt, 
            count_pass_all, count_pass_other, count_pass_ak, count_pass_urt,
            round(case
                    when key in ('3.') 
                      then 1
                    when (key in ('1.1.1.', '1.2.1.', '2.1.1.') OR parent_key in ('1.1.1.', '1.2.1.', '2.1.1.'))
                      then decode(count_pass_other + count_pass_ak, 0, 0, count_pass_other/(count_pass_other + count_pass_ak))
                    when count_pass_all > 0
                      then count_pass_other/count_pass_all
                    else 0
                  end, 7) as coeff_other,
            round(case
                    when key in ('3.') 
                      then 1
                    when (key in ('1.1.1.', '1.2.1.', '2.1.1.') OR parent_key in ('1.1.1.', '1.2.1.', '2.1.1.'))
                      then decode(count_pass_other + count_pass_ak, 0, 0, count_pass_ak/(count_pass_other + count_pass_ak))
                    when count_pass_all > 0
                      then 1 - round(count_pass_other/count_pass_all, 7) - round(count_pass_urt/count_pass_all, 7)
                    else 0
                  end, 7) as coeff_ak,
            round(case
                    when key in ('3.') 
                      then 1
                    when (key in ('1.1.1.', '1.2.1.', '2.1.1.') OR parent_key in ('1.1.1.', '1.2.1.', '2.1.1.'))
                      then 1
                    when count_pass_all > 0 --����� ����� ����������� �� 0.0001 ��-�� ����������
                      then count_pass_urt/count_pass_all
                    else 0
                  end, 7) as coeff_urt
     from page1_pre2),
     page1_final as (
     select row_number() over(order by key) as rn, /*decode(key, '4.', '3.', key) as */key, parent_key, caption, 
            count_active_all, count_active_other, count_active_ak, count_active_urt, 
            count_pass_all, count_pass_other, count_pass_ak, count_pass_urt,
            coeff_other + coeff_ak + coeff_urt as coeff_all, coeff_other, coeff_ak, coeff_urt
     from page1_pre3
     where key != '3.'
     union all
     select sum(1), null as key, null as parent_key, '�����' as caption,
            sum(case when key IN ('1.', '2.', '3.') then count_active_all else 0 end), null as count_active_other, null as count_active_ak, null as count_active_urt,
            sum(case when key IN ('1.', '2.', '3.') then count_pass_all else 0 end), sum(case when key IN ('1.', '2.', '4.') then count_pass_other else 0 end), sum(case when key IN ('1.', '2.', '4.') then count_pass_ak else 0 end), sum(case when key IN ('1.', '2.', '4.') then count_pass_urt else 0 end),
            null as coeff_all, null as coeff_other, null as coeff_ak, null as coeff_urt
      from page1_pre3 
     ),
     page_carrier_pre1 as
     (select ct.key, ct.parent_key, ct.caption, car.id_operator, car.id_division,
            sum(case 
                    when ct.trans_type='ACTIVE' and series is not null and series not in ('96')
                      then case
                             when car.id_operator in (500246845) AND (series not in ('21', '22', '23', '24', '25', '26', '29', '52', '42', '45') or series is null) then count_trans 
                             when car.id_operator in (400246845) AND (series not in ('31', '32', '33', '34', '35', '36', '39', '53', '43', '46') or series is null) then count_trans
                             when car.id_operator not in (400246845, 500246845) AND (series not in ('21', '22', '23', '24', '25', '26', '29', '52', '42', '45') /*or series is null*/) then count_trans
                             else 0
                           end
                    when ct.trans_type='PASS' and (series is null OR series in ('96')) and ct.id_operator = car.id_operator AND (ct.id_division = car.id_division OR ct.id_division IS NULL AND car.id_division IS NULL)
                         then decode(kind, 20, -count_trans, count_trans)
                    else 0 end)  /*������� EP/SL*/
             --+ decode(key, '4.', vEPSLCount, 0) 
             as count_active_carrier,
             sum(case 
                    when ct.trans_type='ACTIVE' and series is not null and series not in ('96')
                      then case
                             when car.id_operator in (500246845) AND (series not in ('21', '22', '23', '24', '25', '26', '29', '52', '42', '45') or series is null) then sum_trans 
                             when car.id_operator in (400246845) AND (series not in ('31', '32', '33', '34', '35', '36', '39', '53', '43', '46') or series is null) then sum_trans
                             when car.id_operator not in (400246845, 500246845) AND (series not in ('21', '22', '24', '25', '26', '29', '52', '42', '45') or series is null) then sum_trans
                             else 0
                           end
                    when ct.trans_type='PASS' and (series is null OR series in ('96')) and ct.id_operator = car.id_operator AND (ct.id_division = car.id_division OR ct.id_division IS NULL AND car.id_division IS NULL)
                         then decode(kind, 20, -sum_trans, sum_trans)
                    else 0 end)  as sum_active_carrier,
             sum(case
                    when ct.trans_type='PASS' and ct.id_operator = car.id_operator AND (ct.id_division = car.id_division OR ct.id_division IS NULL AND car.id_division IS NULL)
                      then decode(kind, 20, -count_trans, count_trans)            
                    else 0
                 end) as count_pass_carrier
     from contents_trans ct
          cross join carriers car
       group by ct.key, ct.parent_key, ct.caption, car.id_operator, car.id_division),
       page_carrier_pre2 as 
       (select pcp.key, pcp.parent_key, pcp.caption, pcp.id_operator, pcp.id_division,
              pcp.count_active_carrier, pcp.sum_active_carrier, 
              pcp.count_pass_carrier, 
              SUM(pcp.count_pass_carrier) OVER (partition by pcp.key, pcp.parent_key) as count_pass_all,
              pcp_akother.count_pass_akother
       from page_carrier_pre1 pcp
            left outer join (select key, SUM(count_pass_carrier) as count_pass_akother from page_carrier_pre1 where id_operator <> 400246845 group by key) pcp_akother
                 on pcp.key = pcp_akother.key),
       page_carrier_pre3 as
       (select key, parent_key, caption, id_operator, id_division,
              count_active_carrier, sum_active_carrier,
              count_pass_carrier,
              round(case when key in ('3.', '4.')
                         then 1
                    when (key in ('1.1.1.', '1.2.1.', '2.1.1.') OR parent_key in ('1.1.1.', '1.2.1.', '2.1.1.')) then
                      case
                        when id_operator = 400246845
                          then 1
                        when count_pass_akother > 0 
                          then count_pass_carrier/count_pass_akother
                      end
                    when count_pass_all > 0 
                      then count_pass_carrier/count_pass_all
               end, 7) as coeff
       from page_carrier_pre2),
       page_carrier_pre4 as
       (select key, parent_key, caption, id_operator, id_division,
              count_active_carrier, sum_active_carrier,
              count_pass_carrier, 
              coeff,
              sum(coeff) OVER (partition by key, parent_key) as coeff_sum
       from page_carrier_pre3),
       page_carrier_pre5 as 
       (select key, parent_key, caption, id_operator, id_division,
              count_active_carrier, sum_active_carrier,
              count_pass_carrier,
              coeff as coeff_old,
              coeff_sum,
              case id_operator
                        when 500246845 then
                          coeff+round(coeff_sum)-coeff_sum
                        else
                          coeff
                      end as coeff
       from page_carrier_pre4),
       page_carrier_pre6 as
       (select key, parent_key, caption, id_operator, id_division,
              count_active_carrier, 
              count_pass_carrier,
              coeff,
              case when count_active_carrier > 0
                then sum_active_carrier/count_active_carrier
              end as pass_doc_cost,
              sum_active_carrier * coeff as sum_total
       from page_carrier_pre5),
       page_carrier_pre7 as
       (select key, parent_key, caption, id_operator, id_division,
               count_active_carrier,
              count_pass_carrier,
              coeff,
              --case 
              --  when key in ('4.') 
              --    then lag(pass_doc_cost) over(order by id_operator, id_division, key)
              --  else
                  pass_doc_cost
              --end as pass_doc_cost
              ,
              --case
              --  when key in ('4.') then
              --    count_pass_carrier * lag(pass_doc_cost) over(order by id_operator, id_division, key)
              --  else
                  sum_total
              --end as sum_total
              ,
              --case
                --when key in ('4.') then
                --  count_pass_carrier * lag(pass_doc_cost) over(order by id_operator, id_division, key)
                --else
                  sum_total
              --end 
              * 0.0298 as sum_total_investor 
       from page_carrier_pre6),
       page_carrier_pre8 as
       (select *
       from page_carrier_pre7
       model 
       dimension by (key, parent_key, caption, id_operator, id_division, ROW_NUMBER() OVER (ORDER BY id_operator, id_division)r)
       measures(count_active_carrier, count_pass_carrier, coeff, pass_doc_cost, sum_total, sum_total_investor)
       rules(
           count_active_carrier[any, any, any, any, any, any] order by r desc = nvl(count_active_carrier[cv(), cv(), cv(), cv(), cv(), cv()], 0) + nvl(sum(count_active_carrier)[any, cv(key), any, cv(id_operator), cv(id_division), any], 0),
           count_pass_carrier[any, any, any, any, any, any] order by r desc = nvl(count_pass_carrier[cv(), cv(), cv(), cv(), cv(), cv()], 0) + nvl(sum(count_pass_carrier)[any, cv(key), any, cv(id_operator), cv(id_division), any], 0),
           sum_total[any, any, any, any, any, any] order by r desc = nvl(sum_total[cv(), cv(), cv(), cv(), cv(), cv()], 0) + nvl(sum(sum_total)[any, cv(key), any, cv(id_operator), cv(id_division), any], 0),
           sum_total_investor[any, any, any, any, any, any] order by r desc = nvl(sum_total_investor[cv(), cv(), cv(), cv(), cv(), cv()], 0) + nvl(sum(sum_total_investor)[any, cv(key), any, cv(id_operator), cv(id_division), any], 0)
       )),
       page_carrier_final as
       (select key, parent_key, caption,
               row_number() over(partition by id_operator, id_division order by key) as rn,
               dense_rank() over(order by case when id_operator in (400246845, 500246845) then 1 else 2 end, id_operator, id_division) + 1 as list_num,
               id_operator,
               id_division,
               count_active_carrier, count_pass_carrier, 
               coeff, 
               pass_doc_cost, 
               sum_total, sum_total_investor
       from page_carrier_pre8
            /*where id_operator in (400246845, 500246845) OR key not in ('3.')AND key not like '2.%'*/ 
       union all
       select null as key, null as parent_key, '�����' as caption,
              sum(1) + 1 as rn,
              dense_rank() over(order by case when id_operator in (400246845, 500246845) then 1 else 2 end, id_operator, id_division) + 1 as list_num,
              id_operator,
              id_division,
              sum(case when key IN ('1.', '2.', '3.', '4.') then count_active_carrier else 0 end) as count_active_carrier, 
              sum(case when key IN ('1.', '2.', '3.', '4.') then count_pass_carrier else 0 end) as count_pass_carrier,
              null,
              null,
              sum(case when key IN ('1.', '2.', '3.', '4.') then sum_total else 0 end) as sum_total,
              sum(case when key IN ('1.', '2.', '3.', '4.') then sum_total_investor else 0 end) as sum_total_investor
       from page_carrier_pre8 
       --where id_operator in (400246845, 500246845) OR key not in ('3.') AND key not like '2.%'
       group by id_operator, id_division
       ),
       page_control_pre1 as
     (select ct.key, ct.parent_key, ct.caption, 
             sum(case when ct.trans_type = 'ACTIVE' then ct.count_trans else null end) as count_active,
             sum(case when ct.trans_type = 'ACTIVE' then ct.sum_trans else null end) as sum_active 
      from contents_trans ct 
      --where ct.key not in ('3.', '4.')
      group by ct.key, ct.parent_key, ct.caption
     ),
     page_control_pre2 as
     (select key, parent_key, caption,
             count_active, sum_active, 
             case when nvl(count_active, 0) = 0 then null else sum_active/count_active end as travel_card_cost
      from page_control_pre1
     ),
     page_control_pre3 as
     (select *
     from page_control_pre2
     start with parent_key is null
     connect by prior key = parent_key
     model
     dimension by (key, parent_key, caption, row_number() over (order by key) rn)
     measures(count_active, sum_active, travel_card_cost)
     rules
     (
          count_active[any, any, any, any] order by rn desc = nvl(count_active[cv(), cv(), cv(), cv()], 0) + nvl(sum(count_active)[any, cv(key), any, any], 0),
          sum_active[any, any, any, any] order by rn desc = nvl(sum_active[cv(), cv(), cv(), cv()], 0) + nvl(sum(sum_active)[any, cv(key), any, any], 0)
     )),
     page_control_final as
     (select pcp.key, pcp.parent_key, pcp.caption,
             pcp.count_active, pcp.sum_active, pcp.travel_card_cost,
             pcp.rn,
             sum(pcf.sum_total) as sum_carrier_total
     from page_control_pre3 pcp
          left join 
               page_carrier_final pcf
          on pcp.key = pcf.key
      group by pcp.key, pcp.parent_key, pcp.caption,
             pcp.count_active, pcp.sum_active, pcp.travel_card_cost, pcp.rn
     )
       --������ ����
       select 1 as list_num,
              rn + 4 as row_num,
              cptt.pkg$trep_reports.getExcelColName(cols.num) as col_name,
              case cols.num 
                when 1 then (case when key in ('1.', '1.1.', '1.2.', '1.3.', '2.', '2.1.', '2.2.', '3.', '4.') then key else null end)
                when 2 then lpad(' ', length(key)*2, ' ') ||caption
                when 3 then to_char(count_active_all)
                when 4 then to_char(count_active_other)
                when 5 then to_char(count_active_ak)
                when 6 then to_char(count_active_urt)
                when 7 then  to_char(count_pass_all)
                when 8 then  to_char(count_pass_other)
                when 9 then  to_char(count_pass_ak)
                when 10 then to_char(count_pass_urt)
                when 11 then to_char(coeff_all)
                when 12 then to_char(coeff_other)
                when 13 then to_char(coeff_ak)
                when 14 then to_char(coeff_urt) 
              end as value
        from page1_final,
          (select level as num
          from dual 
          connect by level <= 14) cols
       
       --����
       /*select list_num,
              rn + 4 as row_num,
              cptt.pkg$trep_reports.getExcelColName(cols.num) as col_name,
              case cols.num
                when 1 then (case when key in ('1.', '1.1.', '1.2.', '1.3.', '2.', '2.1.', '2.2.', '3.', '4.') then key else null end)
                when 2 then lpad(' ', length(key)*2, ' ') ||caption
                when 3 then to_char(count_active_carrier)
                when 4 then to_char(count_pass_carrier)
                when 5 then to_char(coeff)
                when 6 then to_char(pass_doc_cost)
                when 7 then to_char(round(sum_total, 2))
                when 8 then to_char(round(sum_total_investor, 2))
              end as value
         from page_carrier_final,
              (select level as num
              from dual
              connect by level <= 8) cols
         where id_operator in (400246845, 500246845)
         union all*/
       --�����������
       /*union all
         select list_num,
              rn + 4 as row_num,
              cptt.pkg$trep_reports.getExcelColName(cols.num) as col_name,
              case cols.num
                when 1 then (case when key in ('1.', '1.1.', '1.2.', '1.3.', '2.', '2.1.', '2.2.', '3.', '4.') then key else null end)
                when 2 then lpad(' ', length(key)*2, ' ') ||caption
                when 3 then to_char(count_pass_carrier)
                when 4 then to_char(round(sum_total, 2))
                when 5 then to_char(round(sum_total_investor, 2))
              end as value
         from page_carrier_final,
              (select level as num
              from dual
              connect by level <= 5) cols
         --where id_operator not in (400246845, 500246845)
        union all
        select (select max(list_num) from carriers)+1 as list_num,
               rn + 2 as row_num,
               cptt.pkg$trep_reports.getExcelColName(cols.num) as col_name,
               case cols.num
                 when 1 then (case when key in ('1.', '1.1.', '1.2.', '1.3.', '2.', '2.1.', '2.2.') then key else null end)
                 when 2 then lpad(' ', length(key)*2, ' ') ||caption
                 when 3 then to_char(count_active)
                 when 4 then to_char(round(travel_card_cost, 4), 'FM999999999999990.0000')
                 when 5 then to_char(round(sum_active, 2), 'FM999999999999990.00') 
                 when 6 then to_char(round(sum_carrier_total, 2), 'FM999999999999990.00') 
               end as value
        from page_control_final,
             (select level as num
             from dual
             connect by level <= 6) cols
             
        union all
        --��������� ������ ����
        select 1 as list_num,
               1 as row_num,
               'A' as col_name,
               '����������� ����� ���������-��������� � ���������� ���������� ����������� ������� � ������������ ��������� ����������� �� ������ � '|| to_char(pPassBeginDate, 'dd.mm.yyyy (HH24:MI:SS)') ||' �� '|| to_char(pPassEndDate, 'dd.mm.yyyy (HH24:MI:SS)') as value
         from dual
        union all
        --��������� ����� ������������
        select list_num,
               cols.num as row_num,
               'A' as col_name,
               case cols.num
                 when 1 then
                   '����������� ����� ���������-��������� �� ���������/���������� ������������ ���� �� ������ � '|| to_char(pPassBeginDate, 'dd.mm.yyyy HH24:MI:SS') ||' �� '|| to_char(pPassEndDate, 'dd.mm.yyyy HH24:MI:SS')
                 else
                   name
               end  as value
        from carriers,
             (select level as num
              from dual
              connect by level <= 2) cols
        union all
        --��������� ������� �������
        select (select max(list_num) from carriers)+1 as list_num,
               decode(vals.num, 1, 1, 2) as row_num,
               cptt.pkg$trep_reports.getExcelColName(vals.num) as col_name,
               case vals.num
                 when 1 then '������� ����������� ������� ���������� � '|| to_char(pActivationBeginDate, 'dd.mm.yyyy (HH24:MI:SS)') ||' �� '|| to_char(pActivationEndDate, 'dd.mm.yyyy (HH24:MI:SS)')
                 when 2 then '���� ����'
                 when 3 then '���������� ����������'
                 when 4 then '����'
                 when 5 then '����� ����������'
                 when 6 then '����� �������������� �� ������������'    
               end as value
        from dual,
             (select level as num
             from dual
             connect by level <= 6) vals
        union all
        --������ ������� ��� 1 ����� � ������������
        select lists.list_num as list_num,
                4 +
                case 
                 when lists.list_num = 1 
                   then 36 
                 when lists.list_num in (2,3)
                   then 37
                 else 26 
               end + vPrivilegeCount + 1 + vals.num as row_num,
               'A' as col_name,
               case vals.num
                 when 1 then '��������-��������          _______________  __________________  _____________'
                 when 2 then '                                                       �.�.                              ���                         ����'
               end as value
        from (select level as num
              from dual
              connect by level <= 2) vals,
              (select 1 as list_num from dual
               union all
               select list_num from carriers) lists
        union all
        --������ ������� ��� ������� �������
        select (select max(list_num) from carriers)+1 as list_num,
               2 + vPrivilegeCount + 36 as row_num,
               case vals.num
                 when 1 then 'A'
                 when 2 then 'E'
                 when 3 then 'F'
               end as col_name,
               case vals.num
                 when 1 then '����� ���������� ���������'
                 when 2 then to_char(sum_active, 'FM999999999999990.00')
                 when 3 then to_char(sum_carrier_total, 'FM999999999999990.00')
               end as value
        from
        (select sum(sum_active) as sum_active,
               sum(sum_carrier_total) as sum_carrier_total
        from page_control_final
        where key in ('1.', '2.')) total,
        (select level as num
        from dual
        connect by level <= 3) vals*/
      )
      loop
        insert into cptt.tmp$trep_report_excel(list_num, row_num, col_name, value)
        values(rec.list_num, rec.row_num, rec.col_name, rec.value);
      end loop;
     -- return;
      for rec_format in (
        with carriers as
        (
        select op.id as id_operator,
               dense_rank() OVER (order by case 
                                               when op.id in (400246845, 500246845) 
                                                 then 1 
                                               else 2 
                                             end, op.id, div.id) + 1 as list_num
        FROM cptt.operator op
             inner join cptt.division div
                   ON (div.id_operator = op.id)
        WHERE op.id NOT IN (SELECT id
                            FROM cptt.ref$trep_agents_locked)
              AND op.role = 1
              AND div.id NOT IN (SELECT id
                                FROM cptt.ref$trep_divisions_locked)
        )
        select 1 as list_num, 
               cptt.pkg$trep_reports.getRange('A', 5, 'N', 4 + 36 + vPrivilegeCount) as range,
               1 as border,
               'N' as is_merged
        from dual
        union all
        SELECT list_num,
               cptt.pkg$trep_reports.getRange('A', 5, 'F'/*case 
                                                         when id_operator in (400246845, 500246845) 
                                                           then 'I'
                                                         else 'F' 
                                                       end*/, 
                                                       4 + case 
                                                               when id_operator in (400246845, 500246845) 
                                                                 then 37
                                                               else 25 
                                                             end + vPrivilegeCount) as range,
               1 as border,
               'N' as is_merged
        FROM carriers
        UNION ALL
        select lists.list_num,
               cptt.pkg$trep_reports.getRange('A',
               4 +
                case 
                 when lists.list_num = 1 
                   then 35 
                 when lists.list_num in (2,3)
                   then 36
                 else 24 
               end + vPrivilegeCount + 1 + vals.num,
               'F',
               4 +
                case 
                 when lists.list_num = 1 
                   then 35 
                 when lists.list_num in (2,3)
                   then 36
                 else 24 
               end + vPrivilegeCount + 1 + vals.num) as range,
               NULL as border,
               'Y' as is_merged
        from
        (select level as num
              from dual
              connect by level <= 2) vals,
        (select 1 as list_num from dual
         union all
         select list_num from carriers) lists
         union all
         select (select max(list_num) from carriers)+1 as list_num, 
                case level
                  when 1 then cptt.pkg$trep_reports.getRange('A', 1, 'F', 1)
                  when 2 then cptt.pkg$trep_reports.getRange('A', 2 + vPrivilegeCount + 35, 'D', 2 + vPrivilegeCount + 35)
                  when 3 then cptt.pkg$trep_reports.getRange('A', 1, 'F', 2 + vPrivilegeCount + 35)
                end as range,
                1 as border,
                decode(level, 3, 'N', 'Y') as is_merged
         from dual
         connect by level <=3
         )
      loop
        Insert into cptt.tmp$trep_report_excel_format(list_num, range, border, is_merged)
        values(rec_format.list_num, rec_format.range, rec_format.border, rec_format.is_merged);
      end loop;
  END;
  --����� �� ��������� ��������� ��������
  PROCEDURE fillReportActiveAgents(pActivationBeginDate IN DATE,
                                   pActivationEndDate   IN DATE,
                                   pPassBeginDate               IN DATE,
                                   pPassEndDate                 IN DATE) AS
      vAgentsCnt NUMBER;
      vSeriesCnt NUMBER;
    BEGIN
      DELETE FROM cptt.TMP$TREP_REPORT_EXCEL;
      DELETE FROM cptt.tmp$trep_report_excel_format;
    
      SELECT COUNT(1)
      INTO vAgentsCnt
      FROM cptt.operator
      WHERE id NOT IN (SELECT id FROM cptt.ref$trep_agents_locked);
      SELECT COUNT(DISTINCT series)
      INTO vSeriesCnt
      FROM cptt.REF$TREP_SERIES
      WHERE id_pay_type = 1;
      FOR rec IN (WITH agents AS
                     (SELECT id AS id_operator,
                            NAME AS operator_name,
                            group_num,
                            row_number() over (ORDER BY group_num, NAME) + group_num - 1 AS operator_num
                     FROM 
                     (SELECT id,
                             name,
                             case 
                               when id in ('14100246845', '8100246845', '400246845', '500246845') then 
                               2
                             else
                               1 
                             end as group_num
                     FROM cptt.operator
                     WHERE id NOT IN (SELECT id FROM cptt.ref$trep_agents_locked))),
                    max_group as
                    (
                    SELECT MAX(operator_num) + 1 AS group_row_num,
                           MIN(operator_num) AS min_op_num,
                           group_num
                    FROM agents
                    GROUP BY group_num
                    ),
                    ser AS
                     (SELECT DISTINCT series,
                                     REPLACE(decode(series,
                                                    '17',
                                                    '���������/�����������/������������ ���������',
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
                            a.group_num,
                            con.col_num,
                            con.series
                     FROM agents          a,
                          cat_ordered_num con),
                    data AS
                     (SELECT a_s.operator_num,
                            a_s.col_num,
                            a_s.group_num,
                            nvl(tas.count_active, 0) AS count_active,
                            nvl(tas.sum_active, 0) AS sum_active,
                            nvl(tas.sum_bail, 0) AS sum_bail
                     FROM agents_series                     a_s,
                          cptt.tmp$trep_active_seriesagents tas
                     WHERE a_s.id_operator = tas.id_operator(+)
                     AND a_s.series = tas.series(+)),
                     cols AS
                        (SELECT LEVEL AS col_num
                        FROM dual
                        START WITH 1 <= 2
                        CONNECT BY LEVEL <= 2
                        ORDER BY LEVEL),
                    total_grp as 
                    (SELECT
                         data.group_num,
                         data.col_num,
                         nvl(sum(count_active),0) as count_active,
                         nvl(sum(sum_active),0) as sum_active
                    FROM data
                    group by data.group_num,
                             data.col_num),
                    visa_ep_pass AS
                   (SELECT nvl(COUNT(1), 0) AS count_pass,
                           nvl(SUM(nvl(trans.amount, 0) - nvl(trans.amount_bail, 0)), 0) AS sum_pass,
                           decode(id_operator, 500246845, 1, 400246845, 2) as col_num
                    FROM cptt.t_data   trans,
                         cptt.division div
                    WHERE trans.date_of >= pPassBeginDate
                          AND trans.date_of < pPassEndDate
                          AND trans.d = 0 -- �� ������
                          and trans.id_division = div.id
                          AND id_operator IN (400246845, 500246845)
                          AND trans.kind IN ('32', '14', '17', '16')
                          AND nvl(trans.new_card_series, trans.card_series) IN ('96', '10', '90')
                    GROUP BY id_operator)
                    --��������� � ��������
                    SELECT cols.col_num AS list_num,
                           1 AS row_num,
                           'B' AS col_name,
                           '����� �� ��������� ��������� �������� ' ||
                           '�� ������ � ' ||
                           to_char(pActivationBeginDate,
                                   'dd.mm.yyyy HH24:MI:SS') || ' �� ' ||
                           to_char(pActivationEndDate + 1 -
                                   1 / 24 / 60 / 60,
                                   'dd.mm.yyyy HH24:MI:SS') AS VALUE
                    FROM dual,
                         cols
                    --
                    UNION ALL
                    --��������� � �����������
                    SELECT cols.col_num AS list_num,
                           3 AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(2 +
                                                                 ch.col_num) AS col_name,
                           to_char(series_name) AS VALUE
                    FROM cat_head ch,
                         cols
                    --
                    UNION ALL
                    --��������� � ����� �� �����
                    SELECT 1 AS list_num,
                           5 + mg.group_row_num AS col_num,
                           'A' AS col_name,
                           CASE mg.group_num
                             WHEN 1 THEN
                              '����� �� ������������ �����:'
                             ELSE
                              '����� �� ���������� �����:'
                           END AS VALUE
                    FROM max_group mg
                    --
                    UNION ALL
                    SELECT 1 AS list_num,
                           5 + vAgentsCnt +
                           (SELECT nvl(MAX(group_num), 0) FROM total_grp) + 1 AS row_num,
                           'A' AS col_name,
                           '�����' AS VALUE
                    FROM dual
                    --
                    UNION ALL
                    --��������� � �������
                    SELECT cols.col_num as list_num,
                           4 AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(2 + con.col_num) AS col_name,
                           series AS VALUE
                    FROM cat_ordered_num con,
                         cols
                    --
                    UNION ALL
                    --��������� ���-��
                    SELECT cols.col_num as list_num,
                           5 AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(2 + con.col_num) AS col_name,
                           '���-��' AS VALUE
                    FROM cat_ordered_num con,
                         cols
                    --
                    UNION ALL
                    --��������� �����
                    SELECT cols.col_num as list_num,
                           5 AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(2 + con.col_num + 1) AS col_name,
                           '�����' AS VALUE
                    FROM cat_ordered_num con,
                         cols
                    --
                    UNION ALL
                    --��������� ������
                    SELECT 1 as list_num,
                           3 AS row_num,
                           'A' AS col_name,
                           '������' AS VALUE
                    FROM dual
                    --
                    UNION ALL
                    --������ �������
                    SELECT 1 as list_num,
                           5 + operator_num AS row_num,
                           'A' AS col_name,
                           operator_name AS VALUE
                    FROM agents
                    --
                    UNION all
                    --��������� ��������� ������
                     SELECT  1 as list_num,
                             3 as row_num,
                             cptt.pkg$trep_reports.getExcelColName(1 + vSeriesCnt * 2 + 1) AS col_name,
                            '��-�� ������' as value
                     FROM dual
                    --
                    UNION all
                    --��������� ��������� ������
                     SELECT  1 as list_num,
                             3 as row_num,
                             cptt.pkg$trep_reports.getExcelColName(1 + vSeriesCnt * 2 + 2) AS col_name,
                            '����� �� ���������' as value
                     FROM dual
                    --
                    UNION all
                    --��������� ��������� ������
                     SELECT  1 as list_num,
                             3 as row_num,
                             cptt.pkg$trep_reports.getExcelColName(1 + vSeriesCnt * 2 + 3) AS col_name,
                            '����� �����' as value
                     FROM dual
                    --
                    UNION all
                    --��������� ��������� ������
                     SELECT  1 as list_num,
                             3 as row_num,
                             cptt.pkg$trep_reports.getExcelColName(1 + vSeriesCnt * 2 + 4) AS col_name,
                            '��' as value
                     FROM dual
                    --
                    UNION all
                    --��������� ��������� ������
                     SELECT  1 as list_num,
                             3 as row_num,
                             cptt.pkg$trep_reports.getExcelColName(1 + vSeriesCnt * 2 + 5) AS col_name,
                            '���' as value
                     FROM dual
                     --
                    UNION all
                    --��������� ��������� ������
                     SELECT  1 as list_num,
                             3 as row_num,
                             cptt.pkg$trep_reports.getExcelColName(1 + vSeriesCnt * 2 + 6) AS col_name,
                            '�� + ���' as value
                     FROM dual
                    --
                    UNION ALL
                    --������ �� ����������
                    SELECT 1 as list_num,
                           5 + operator_num AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(2 + col_num) AS col_name,
                           to_char(count_active) AS VALUE
                    FROM data
                    --
                    UNION ALL
                    --������ �� �����
                    SELECT 1 as list_num,
                           5 + operator_num AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(2 + col_num + 1) AS col_name,
                           to_char(sum_active) AS VALUE
                    FROM data
                    --
                    union all
                    --������ �� ����� �� �����
                    SELECT
                             1 as list_num,
                             5 + mg.group_row_num as row_num,
                             cptt.pkg$trep_reports.getExcelColName(2 + tg.col_num + cols.col_num - 1) AS col_name,
                             case cols.col_num
                               when 1 then
                                 to_char(tg.count_active)
                               else
                                 to_char(tg.sum_active)
                             end as value
                    FROM total_grp tg,
                         cols,
                         max_group mg
                    where tg.group_num = mg.group_num
                    --
                    UNION ALL
                    --������ �� �����(������)
                    SELECT 1 as list_num,
                           5 + vAgentsCnt + (select nvl(max( group_num), 0) from total_grp) + 1 as row_num,
                           cptt.pkg$trep_reports.getExcelColName(2 + tg.col_num + cols.col_num - 1) AS col_name,
                             case cols.col_num
                               when 1 then
                                 to_char(nvl(sum(tg.count_active), 0))
                               else
                                 to_char(nvl(sum(tg.sum_active), 0))
                             end as value
                    FROM total_grp tg,
                         cols
                    GROUP BY tg.col_num, cols.col_num
                    --
                    UNION ALL
                    --��������� �������
                    SELECT 1 as list_num,
                           5 + operator_num AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(1 +
                                                                 vSeriesCnt * 2 + 1) AS col_name,
                           to_char(SUM(sum_bail)) AS VALUE
                    FROM data
                    GROUP BY operator_num
                    --
                    UNION ALL
                    --��������� ����������
                    SELECT 1 as list_num,
                           5 + operator_num AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(1 +
                                                                 vSeriesCnt * 2 + 2) AS col_name,
                           to_char(SUM(sum_active)) AS VALUE
                    FROM data
                    GROUP BY operator_num
                    --
                    UNION ALL
                    --����� ���������
                    SELECT 1 as list_num,
                           5 + operator_num AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(1 +
                                                                 vSeriesCnt * 2 + 3) AS col_name,
                           to_char(SUM(sum_bail + sum_active)) AS VALUE
                    FROM data
                    GROUP BY operator_num
                    --
                    UNION ALL
                    --��
                    SELECT 1 as list_num,
                           5 + operator_num AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(1 +
                                                                 vSeriesCnt * 2 + 4) AS col_name,
                           '=ROUND(SUM(' ||
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
                                      '*'||'A'||to_char(5 + vAgentsCnt + 6)
                                   END,
                                   ',') within GROUP(ORDER BY col_num) || ')*0.75, 2)' AS VALUE
                    FROM 
                    agents_series 
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
                    --���
                    SELECT 1 as list_num,
                           5 + operator_num AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(1 +
                                                                 vSeriesCnt * 2 + 5) AS col_name,
                           '=ROUND(SUM(' || listagg(cptt.pkg$trep_reports.getExcelColName(2 +
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
                                                 '*'||'B'||to_char(5 + vAgentsCnt + 6)
                                              END,
                                              ',') within GROUP(ORDER BY col_num) || ')*0.75, 2)' AS VALUE
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
                    --�� + ���
                    SELECT 1 as list_num,
                           5 + operator_num AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(1 +
                                                                 vSeriesCnt * 2 + 6) AS col_name,
                           '=ROUND(SUM(' ||
                           cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                vSeriesCnt * 2 + 4),
                                                          5 + operator_num,
                                                          cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                vSeriesCnt * 2 + 5),
                                                          5 + operator_num) || '), 2)' AS VALUE
                    FROM agents
                    --������������ ��� ����� �� �����
                    UNION ALL
                    SELECT 1 AS list_num,
                           5 + group_row_num AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(1 +
                                                                 vSeriesCnt * 2 +
                                                                 f_cols.col_num) AS col_name,
                           '=SUM(' ||
                           cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                vSeriesCnt * 2 +
                                                                                                f_cols.col_num),
                                                          5 + min_op_num,
                                                          cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                vSeriesCnt * 2 +
                                                                                                f_cols.col_num),
                                                          5 + group_row_num - 1) || ')'
                    FROM max_group,
                         (SELECT LEVEL AS col_num
                          FROM dual
                          START WITH 1 <= 6
                          CONNECT BY LEVEL <= 6
                          ORDER BY LEVEL) f_cols
                    --
                    UNION ALL
                    --������������ ��� ����� (�����)
                    SELECT 1 AS list_num,
                           5 + vAgentsCnt +
                           (SELECT nvl(MAX(group_num), 0) FROM total_grp) + 1 AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(1 +
                                                                 vSeriesCnt * 2 +
                                                                 f_cols.col_num) AS col_name,
                           '=SUM(' || listagg(cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                    vSeriesCnt * 2 +
                                                                                    f_cols.col_num) ||
                                              to_char(5 + group_row_num),
                                              ',') within GROUP(ORDER BY group_row_num) || ')' AS VALUE
                    FROM max_group,
                         (SELECT LEVEL AS col_num
                          FROM dual
                          START WITH 1 <= 6
                          CONNECT BY LEVEL <= 6
                          ORDER BY LEVEL) f_cols
                    GROUP BY f_cols.col_num
                    --
                    UNION ALL
                    --������ ���� ����������� ���� �����
                    SELECT 2 AS list_num,
                           5 + group_num AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(CASE
                                                                   WHEN f_cols.col_num = 1 + vSeriesCnt * 2 + 2 THEN
                                                                    1 + vSeriesCnt * 2 + 1
                                                                   WHEN f_cols.col_num >= 1 + vSeriesCnt * 2 + 4 THEN
                                                                    f_cols.col_num - 2
                                                                   ELSE
                                                                    f_cols.col_num
                                                                 END) AS col_name,
                           '=''1''!' ||
                           cptt.pkg$trep_reports.getExcelColName(f_cols.col_num) ||
                           to_char(5 + mg.group_row_num) AS VALUE
                    FROM (SELECT group_num,
                                 group_row_num
                          FROM max_group
                          UNION ALL
                          SELECT 3 AS group_num,
                                 vAgentsCnt +
                                 (SELECT nvl(MAX(group_num), 0)
                                  FROM total_grp) + 1 AS group_row_num
                          FROM dual) mg,
                         (SELECT LEVEL AS col_num
                          FROM dual
                          START WITH 1 <= 1 + vSeriesCnt * 2 + 5
                          CONNECT BY LEVEL <= 1 + vSeriesCnt * 2 + 5
                          ORDER BY LEVEL) f_cols
                    WHERE f_cols.col_num NOT IN
                          (1 + vSeriesCnt * 2 + 1, 1 + vSeriesCnt * 2 + 3)
                    --�������� � ������������
                    UNION ALL
                    SELECT lists.list_num,
                           percent_rows.row_num,
                           cptt.pkg$trep_reports.getExcelColName(percent_cols.col_num) AS col_num,
                           CASE percent_rows.num
                             WHEN 1 THEN
                              CASE percent_cols.col_num
                                WHEN 1 THEN
                                 '�������'
                                ELSE
                                 '����������'
                              END
                             ELSE
                              CASE percent_cols.col_num
                                WHEN 1 THEN
                                 to_char(round(0.31, 2))--to_char(round(4 / 10, 2))
                                ELSE
                                 to_char(round(0.5, 2))--'=1-A' || to_char(percent_rows.row_num)
                              END
                           END AS VALUE
                    FROM (SELECT LEVEL  AS row_num,
                                 rownum AS num
                          FROM dual
                          WHERE LEVEL >= 5 + vAgentsCnt + 5
                          START WITH 5 + vAgentsCnt + 5 <=
                                     5 + vAgentsCnt + 6
                          CONNECT BY LEVEL <= 5 + vAgentsCnt + 6
                          ORDER BY LEVEL) percent_rows,
                         (SELECT LEVEL AS col_num
                          FROM dual
                          CONNECT BY LEVEL <= 2
                          ORDER BY LEVEL) percent_cols,
                          (SELECT LEVEL AS list_num
                          FROM dual
                          CONNECT BY LEVEL <= 2) lists
                    --
                    UNION ALL
                    --��������� ��������� �������� �� ������ �����
                    SELECT 2 AS list_num,
                           3 AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(row_num) AS col_name,
                           CASE num
                             WHEN 1 THEN
                              '����� �� ���������'
                             WHEN 2 THEN
                              '��'
                             ELSE
                              '���'
                           END AS VALUE
                    FROM (SELECT LEVEL  AS row_num,
                                 rownum AS num
                          FROM dual
                          WHERE LEVEL >= 1 + vSeriesCnt * 2 + 1
                          CONNECT BY LEVEL <= 1 + vSeriesCnt * 2 + 3
                          ORDER BY LEVEL) last_cols
                    --
                    UNION ALL
                    --�������� � �����
                    SELECT 2 AS list_num,
                           12 AS row_num,
                           cptt.pkg$trep_reports.getExcelColName(1 +
                                                                 (visa_ep_pass.col_num - 1) * 2 +
                                                                 cols.col_num) AS col_name,
                           CASE cols.col_num
                             WHEN 1 THEN
                              to_char(count_pass)
                             WHEN 2 THEN
                              to_char(sum_pass)
                           END AS VALUE
                    FROM visa_ep_pass,
                         cols
                    )
      LOOP
        INSERT INTO cptt.tmp$trep_report_excel
          (list_num,
           row_num,
           col_name,
           VALUE)
        VALUES
          (rec.list_num,
           rec.row_num,
           rec.col_name,
           rec.value);
      END LOOP;
    
      FOR rec_format IN (WITH ser AS
                            (SELECT DISTINCT series,
                                            decode(series,
                                                   '17',
                                                   '���������/�����������/������������ ���������',
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
                                     cnt_series),
                           cols AS
                              (SELECT LEVEL AS col_num
                              FROM dual
                              START WITH 1 <= 2
                              CONNECT BY LEVEL <= 2
                              ORDER BY LEVEL)
                           --��������� ����������� �����
                           SELECT cols.col_num AS list_num,
                                  cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(2 +
                                                                                                       ch.col_num),
                                                                 3,
                                                                 cptt.pkg$trep_reports.getExcelColName(2 +
                                                                                                       ch.col_num +
                                                                                                       ch.cnt_series * 2 - 1),
                                                                 3) AS RANGE,
                                  8 AS font_size,
                                  1 AS border,
                                  'Y' AS is_merged
                           FROM cat_head ch,
                                cols
                           --
                           UNION ALL
                           --��������� �����
                           SELECT cols.col_num AS list_num,
                                  cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(2 +
                                                                                                       con.col_num),
                                                                 4,
                                                                 cptt.pkg$trep_reports.getExcelColName(2 +
                                                                                                       con.col_num + 1),
                                                                 4) AS RANGE,
                                  8 AS font_size,
                                  1 AS border,
                                  'Y' AS is_merged
                           FROM cat_ordered_num con,
                                cols
                           --
                           UNION ALL
                           --��������� ������
                           SELECT cols.col_num AS list_num,
                                  cptt.pkg$trep_reports.getRange('A',
                                                                 3,
                                                                 'A',
                                                                 5) AS RANGE,
                                  8 AS font_size,
                                  1 AS border,
                                  'Y' AS is_merged
                           FROM dual,
                                cols
                           --
                           UNION ALL
                           --��� ������
                           SELECT 1 AS list_num,
                                  cptt.pkg$trep_reports.getRange('A',
                                                                 3,
                                                                 cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                       vSeriesCnt * 2 + 6),
                                                                 5 +
                                                                 vAgentsCnt + 3) AS RANGE,
                                  8 AS font_size,
                                  1 AS border,
                                  'N' AS is_merged
                           FROM dual
                           --
                           UNION ALL
                           --��������� ��������� ������
                           SELECT cols.col_num AS list_num,
                                  cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                       vSeriesCnt * 2 + 1),
                                                                 3,
                                                                 cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                       vSeriesCnt * 2 + 1),
                                                                 5) AS RANGE,
                                  8 AS font_size,
                                  1 AS border,
                                  'Y' AS is_merged
                           FROM dual,
                                cols
                           --
                           UNION ALL
                           --��������� ����� ���������
                           SELECT cols.col_num AS list_num,
                                  cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                       vSeriesCnt * 2 + 2),
                                                                 3,
                                                                 cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                       vSeriesCnt * 2 + 2),
                                                                 5) AS RANGE,
                                  8 AS font_size,
                                  1 AS border,
                                  'Y' AS is_merged
                           FROM dual,
                                cols
                           --
                           UNION ALL
                           --��������� ����� �����
                           SELECT cols.col_num AS list_num,
                                  cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                       vSeriesCnt * 2 + 3),
                                                                 3,
                                                                 cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                       vSeriesCnt * 2 + 3),
                                                                 5) AS RANGE,
                                  8 AS font_size,
                                  1 AS border,
                                  'Y' AS is_merged
                           FROM dual,
                                cols
                           --
                           UNION ALL
                           --��������� ��
                           SELECT 1 AS list_num,
                                  cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(1 +
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
                           --��������� ���
                           SELECT 1 AS list_num,
                                  cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(1 +
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
                           --��������� 2
                           SELECT 1 AS list_num,
                                  cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                       vSeriesCnt * 2 + 6),
                                                                 3,
                                                                 cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                       vSeriesCnt * 2 + 6),
                                                                 5) AS RANGE,
                                  8 AS font_size,
                                  1 AS border,
                                  'Y' AS is_merged
                           FROM dual
                           --
                           UNION ALL
                           --�������� �  ������������
                           SELECT LEVEL AS list_num,
                                  cptt.pkg$trep_reports.getRange('A',
                                                                 5 +
                                                                 vAgentsCnt + 5,
                                                                 'B',
                                                                 5 +
                                                                 vAgentsCnt + 6) AS RANGE,
                                  8 AS font_size,
                                  1 AS border,
                                  'N' AS is_merged
                           FROM dual
                           CONNECT BY LEVEL <= 2
                           --
                           UNION ALL
                           --������ ���� ������� �����
                           SELECT 2 AS list_num,
                                  cptt.pkg$trep_reports.getRange('A',
                                                                 3,
                                                                 cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                                       vSeriesCnt * 2 + 3),
                                                                 8) AS RANGE,
                                  8 AS font_size,
                                  1 AS border,
                                  'N' AS is_merged
                           FROM dual
                           )
      
      LOOP
        INSERT INTO cptt.tmp$trep_report_excel_format
          (list_num,
           RANGE,
           font_size,
           border,
           is_merged)
        VALUES
          (rec_format.list_num,
           rec_format.range,
           rec_format.font_size,
           rec_format.border,
           rec_format.is_merged);
      END LOOP;
      /*INSERT INTO cptt.tmp$trep_report_excel_format
        (list_num,
         RANGE,
         is_colored)
        WITH agents AS
         (SELECT id AS id_operator,
                 NAME AS operator_name,
                 group_num,
                 row_number() over(ORDER BY group_num, NAME) + group_num - 1 AS operator_num
          FROM (SELECT id,
                       NAME,
                       CASE
                         WHEN id IN ('14100246845', '8100246845') THEN
                          2
                         ELSE
                          1
                       END AS group_num
                FROM cptt.operator
                WHERE id NOT IN (SELECT id FROM cptt.ref$trep_agents_locked))),
        max_group AS
         (SELECT MAX(operator_num) + 1 AS group_row_num,
                 MIN(operator_num) AS min_op_num,
                 group_num
          FROM agents
          GROUP BY group_num)
        SELECT 1 AS list_num,
               cptt.pkg$trep_reports.getRange('A',
                                              5 + group_row_num,
                                              cptt.pkg$trep_reports.getExcelColName(1 +
                                                                                    vSeriesCnt * 2 + 6),
                                              5 + group_row_num) AS RANGE,
               'Y' AS is_colored
        FROM (SELECT group_row_num
              FROM max_group
              UNION ALL
              SELECT vAgentsCnt +
                     (SELECT nvl(MAX(group_num), 0) FROM max_group) + 1 AS group_row_num
              FROM dual);
      */
      COMMIT;
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
    FROM cptt.v$trep_carriers;
  
    SELECT COUNT(1) INTO vPrivilegeCount FROM cptt.privilege;
  
    WITH carrier AS
     (SELECT id_operator
      FROM cptt.v$trep_carriers)
    SELECT COUNT(1)
    INTO vRouteCount
    FROM ROUTE    r,
         division div,
         carrier  c
    WHERE r.id_division = div.id
    AND div.id_operator = c.id_operator
    AND div.id NOT IN (SELECT id FROM cptt.ref$trep_divisions_locked);
  
    pkg$trep_reports.fillPassPrivCarrierRoute(pPassBeginDate, pPassEndDate);
    pkg$trep_reports.fillActivationSeriesPrivilege(pActivationBeginDate,
                                                   pActivationEndDate,
                                                   'Y');
    pkg$trep_reports.fillPassSeriesPrivilegeCarrier(pPassBeginDate,
                                                    pPassEndDate);
    FOR first_tab IN (WITH carrier_colnum AS
                         (SELECT id_operator,
                                rownum + 2 AS col_num,
                                operator_name
                         FROM cptt.v$trep_carriers),
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
                        --������
                        SELECT 5 AS row_num,
                               'B' AS col_name,
                               '� ' ||
                               to_char(pPassBeginDate,
                                       'dd.mm.yyyy HH24:MI:SS') || CRLF ||
                               ' �� ' ||
                               to_char(pPassEndDate, 'dd.mm.yyyy HH24:MI:SS') AS VALUE
                        FROM dual
                        UNION ALL
                        --������������ ������������
                        SELECT 5 AS row_num,
                               getExcelColName(col_num) AS col_name,
                               operator_name AS VALUE
                        FROM carrier_colnum
                        UNION ALL
                        --����� ���������� ������������
                        SELECT row_num,
                               'B' AS col_name,
                               to_char(SUM(count_pass)) AS VALUE
                        FROM pass_row_col
                        GROUP BY row_num
                        UNION ALL
                        --���������� ������������
                        SELECT row_num,
                               getExcelColName(col_num) AS col_name,
                               to_char(count_pass) AS VALUE
                        FROM pass_row_col
                        UNION ALL
                        --���������� ��������������
                        SELECT 11 + order_num AS row_num,
                               'B' AS col_name,
                               to_char(SUM(nvl(count_active, 0))) AS VALUE
                        FROM activation
                        GROUP BY order_num
                        UNION ALL
                        --����� ����� �������� �������
                        SELECT 5 + order_num * 2 AS row_num,
                               'B' AS col_name,
                               to_char(SUM(nvl(sum_active, 0))) AS VALUE
                        FROM activation
                        GROUP BY order_num
                        UNION ALL
                        --�����, �������� �� �����������
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
                          (SELECT id_operator
                          FROM cptt.v$trep_carriers),
                         rt AS
                          (SELECT r.id AS id_route,
                                 getRouteName(r.id) AS route_name
                          FROM ROUTE    r,
                               division div,
                               carrier  c
                          WHERE r.id_division = div.id
                          AND div.id_operator = c.id_operator
                          AND div.id NOT IN (SELECT id FROM cptt.ref$trep_divisions_locked)
                          ORDER BY c.id_operator,
                                   r.code),
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
                         --�������� ������
                         --������������ ����������
                         SELECT 16 AS row_num,
                                getExcelColName(priv_num * 3) AS col_name,
                                priv_name || CRLF || ' ��� (' || code || ')' AS VALUE
                         FROM priv
                         --
                         UNION ALL
                         --������������ �������� ����������
                         SELECT 17 AS row_num,
                                getExcelColName(priv.priv_num * 3 +
                                                headers.order_num) AS col_name,
                                headers.header_name AS VALUE
                         FROM (SELECT 0 AS order_num,
                                      '���-�� ����������' AS header_name
                               FROM dual
                               UNION ALL
                               SELECT 1 AS order_num,
                                      '�����' AS header_name
                               FROM dual
                               UNION ALL
                               SELECT 2 AS order_num,
                                      '���-�� �������������� ��' AS header_name
                               FROM dual) headers,
                              priv
                         --
                         UNION ALL
                         --��������� ����� � ����������
                         SELECT 18 + ro.route_order_num AS row_num,
                                'B' AS col_name,
                                ro.route_name AS VALUE
                         FROM rt_order ro
                         --
                         UNION ALL
                         --��������� ���������� ��������, �������� �� ����������
                         SELECT 18 AS row_num,
                                getExcelColName(priv.priv_num * 3) AS col_name,
                                '=SUM(' ||
                                getExcelColName(priv.priv_num * 3) || '19:' ||
                                getExcelColName(priv.priv_num * 3) ||
                                to_char(18 + vRouteCount) || ')' AS VALUE
                         FROM priv
                         UNION ALL
                         --���������� �������� �� ��������� � ����������
                         SELECT 18 + ppr.route_order_num AS row_num,
                                getExcelColName(ppr.priv_num * 3) AS col_name,
                                to_char(ppr.count_pass) AS VALUE
                         FROM pass_priv_rt ppr
                         --
                         UNION ALL
                         --���� ����� ��������
                         SELECT 19 AS row_num,
                                'A' AS col_name,
                                '����� ��������' AS VALUE
                         FROM dual
                         --
                         UNION ALL
                         --���������� �������������� ����
                         SELECT 18 AS row_num,
                                getExcelColName(acs.priv_num * 3 + 2) AS col_name,
                                to_char(acs.count_active) AS VALUE
                         FROM activation_count_sum acs
                         --
                         UNION ALL
                         --���� ����������
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
                                --������������ ����������
                                SELECT getExcelColName(priv_num * 3) ||
                                       '16:' ||
                                       getExcelColName(priv_num * 3 + 2) || '16' AS RANGE,
                                       1 AS border,
                                       10 AS font_size,
                                       'Y' AS is_merged
                                FROM priv
                                --
                                UNION ALL
                                --������������ �������� ����������
                                SELECT 'C17:' ||
                                       getExcelColName(vPrivilegeCount * 3 + 2) || '17' AS RANGE,
                                       1 AS border,
                                       NULL AS font_size,
                                       'N' AS is_merged
                                FROM dual
                                --
                                UNION ALL
                                --���������� ��������
                                SELECT 'A18:' ||
                                       getExcelColName(vPrivilegeCount * 3 + 2) ||
                                       to_char(18 + vRouteCount) AS RANGE,
                                       1 AS border,
                                       NULL AS font_size,
                                       'N' AS is_merged
                                FROM dual
                                --
                                UNION ALL
                                --����������� ��� ���� ����� �������
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
   COMMIT;
  END;

  --����� �� ��������(����������� ����� ��������������� ������ fillpassRouteTermDay!)
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
                        --������ ��������
                        --������
                        SELECT 4 AS row_num,
                               'B' AS col_name,
                               '� ' ||
                               to_char(pPassBeginDate,
                                       'dd.mm.yyyy HH24:MI:SS') || ' �� ' ||
                               to_char(pPassEndDate, 'dd.mm.yyyy HH24:MI:SS') AS VALUE
                        FROM dual
                        --
                        UNION ALL
                        --����� ��������
                        SELECT 5 AS row_num,
                               'B' AS col_name,
                               to_char(rt.route_code) AS VALUE
                        FROM rt
                        --
                        UNION ALL
                        --����������
                        SELECT 9 AS row_num,
                               'B' AS col_name,
                               rt.operator_name AS VALUE
                        FROM rt
                        --
                        UNION ALL
                        --������ ��������
                        --������ "���������� ����������"
                        SELECT vSecondTableFirstRowNum + 1 AS row_num,
                               'A' AS col_name,
                               '���������� ����������' AS VALUE
                        FROM dual
                        WHERE vTermCount > 0
                        --
                        UNION ALL
                        --������ "���� �� ����"
                        SELECT vSecondTableFirstRowNum + vTermCount + 1 AS row_num,
                               'A' AS col_name,
                               '���� �� ����' AS VALUE
                        FROM dual
                        --
                        UNION ALL
                        --������ "���������� ����������, �� ������� ��������� ���������� � ����"
                        SELECT vSecondTableFirstRowNum + vTermCount + 2 AS row_num,
                               'A' AS col_name,
                               '���������� ����������, �� ������� ��������� ���������� � ����' AS VALUE
                        FROM dual
                        UNION ALL
                        --������ � ������
                        SELECT vSecondTableFirstRowNum AS row_num,
                               getExcelColName(2 + dates.date_num) AS col_name,
                               '� ' ||
                               to_char(dates.begin_date,
                                       'dd.mm.yyyy HH24:MI:SS') AS VALUE
                        FROM dates
                        --
                        UNION ALL
                        --������� � �����������
                        SELECT vSecondTableFirstRowNum + trm.term_num AS row_num,
                               getExcelColName(2) AS col_name,
                               to_char(trm.code_term) AS VALUE
                        FROM trm
                        --
                        UNION ALL
                        --������
                        SELECT vSecondTableFirstRowNum + pass.term_num AS row_num,
                               getExcelColName(2 + pass.date_num) AS col_name,
                               to_char(pass.count_pass) AS VALUE
                        FROM pass
                        --
                        UNION ALL
                        --���� �� ���������(���������)
                        SELECT vSecondTableFirstRowNum AS row_num,
                               getExcelColName(3 + ceil(pPassEndDate -
                                                        pPassBeginDate)) AS col_name,
                               '����' AS VALUE
                        FROM dual
                        --
                        
                        UNION ALL
                        --���� �� ���������
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
                        --���� �� ����(���������� ����������)
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
                        --���� ����� �� ��������
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
                        --���� �� ���������� ���������� �� �������� � ����
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

  --����� �� �����������(����������� ����� ��������������� ������ fillActivationSeriesPrivilege � fillPassSeriesPrivilegeCarrier)
  PROCEDURE fillReportOrganisationExcel(pIdCarrier           IN NUMBER,
                                      pPassBeginDate       IN DATE,
                                      pPassEndDate         IN DATE) AS
  vSecondTabFirstRowNum NUMBER;
  vThirdTabFirstRowNum NUMBER;
  BEGIN
    DELETE FROM cptt.tmp$trep_report_excel;
    DELETE FROM cptt.tmp$trep_report_excel_format;
  
    FOR first_tab IN (WITH trans AS
                         (SELECT op.name AS carrier_name,
                                to_char(nvl(COUNT(DISTINCT id_route), 0)) AS count_route,
                                to_char(nvl(COUNT(DISTINCT id_term), 0)) AS count_term,
                                to_char(nvl(COUNT(1), 0)) AS count_pass
                         FROM cptt.t_data   trans,
                              cptt.division div,
                              cptt.operator op
                         WHERE trans.date_of >= pPassBeginDate
                         AND trans.date_of < pPassEndDate
                         AND trans.d = 0
                         AND trans.kind IN ('32', '14', '17', '20')
                         AND trans.id_division = div.id
                         AND div.id_operator = pIdCarrier
                         AND div.id_operator = op.id
                         GROUP BY op.name),
                        dummy AS
                         (SELECT LEVEL AS num FROM dual CONNECT BY LEVEL <= 5)
                        SELECT 2 + dummy.num AS row_num,
                               'B' AS col_name,
                               CASE dummy.num
                                 WHEN 1 THEN
                                  '� ' ||
                                  to_char(pPassBeginDate,
                                          'dd.mm.yyyy HH24:MI:SS') || ' �� ' ||
                                  to_char(pPassEndDate,
                                          'dd.mm.yyyy HH24:MI:SS')
                                 WHEN 2 THEN
                                  carrier_name
                                 WHEN 3 THEN
                                  count_route
                                 WHEN 4 THEN
                                  count_term
                                 WHEN 5 THEN
                                  count_pass
                               END AS VALUE
                        FROM trans,
                             dummy)
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
  
    vSecondTabFirstRowNum := 9;
    FOR second_tab IN (WITH cat AS
                          (SELECT LEVEL AS cat_num,
                                 CASE LEVEL
                                   WHEN 1 THEN
                                    '��������� ���������'
                                   WHEN 2 THEN
                                    '������������ ���������'
                                   WHEN 3 THEN
                                    '����������� ���������'
                                   WHEN 4 THEN
                                    '�� ��������� "�������"'
                                   WHEN 5 THEN
                                    '�� ��������� "�������-����������"'
                                   WHEN 6 THEN
                                    '�� ��������� "����������"'
                                   WHEN 7 THEN
                                    '�� "����"'
                                   WHEN 8 THEN
                                    '��������'
                                 END AS cat_name
                          FROM dual
                          CONNECT BY LEVEL <= 8),
                         pass_data AS
                          (SELECT series,
                                 CASE
                                   WHEN series = '17' AND
                                        priv.code LIKE '000000__' THEN
                                    1
                                   WHEN series = '17' AND
                                        priv.code LIKE '100000__' THEN
                                    2
                                   WHEN series = '17' AND
                                        priv.code LIKE '200%' THEN
                                    3
                                   WHEN series IN ('39', '353', '343') THEN
                                    4
                                   WHEN series IN ('19', '150', '141') THEN
                                    5
                                   WHEN series IN ('29', '252', '242') THEN
                                    6
                                   WHEN series = '96' THEN
                                    7
                                   WHEN series IS NULL THEN
                                    8
                                 END AS cat_num,
                                 count_pass,
                                 sum_pass
                          FROM cptt.TMP$TREP_PASS_SERIESPRIVOP tps
                          LEFT OUTER JOIN cptt.privilege priv
                          ON (tps.id_privilege = priv.id)
                          WHERE tps.id_operator = pIdCarrier
                                AND (pIdCarrier != '16100246845'
                                    OR series IS NOT NULL)),
                         pass_cat AS
                          (SELECT cat.cat_num,
                                 nvl(SUM(pass_data.count_pass), 0) AS count_pass,
                                 nvl(SUM(pass_data.sum_pass), 0) AS sum_pass
                          FROM cat
                          LEFT OUTER JOIN pass_data
                          ON (cat.cat_num = pass_data.cat_num)
                          GROUP BY cat.cat_num)
                         --���������
                         SELECT vSecondTabFirstRowNum AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(cat.cat_num * 2 - 1) AS col_name,
                                cat.cat_name AS VALUE
                         FROM cat
                         --
                         UNION ALL
                         --��������� ���-��/�����
                         SELECT vSecondTabFirstRowNum + 1 AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(cat.cat_num * 2 - 2 +
                                                                      dummy.num) AS col_name,
                                CASE dummy.num
                                  WHEN 1 THEN
                                   '���������� ����������'
                                  WHEN 2 THEN
                                   '�����'
                                END AS VALUE
                         FROM cat,
                              (SELECT LEVEL AS num
                               FROM dual
                               CONNECT BY LEVEL <= 2) dummy
                         --
                         UNION ALL
                         --������ �� ���-�� � �����
                         SELECT vSecondTabFirstRowNum + 2 AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(pass_cat.cat_num * 2 - 2 +
                                                                      dummy.num) AS col_name,
                                CASE dummy.num
                                  WHEN 1 THEN
                                   to_char(pass_cat.count_pass)
                                  WHEN 2 THEN
                                   to_char(pass_cat.sum_pass)
                                END AS VALUE
                         FROM pass_cat,
                              (SELECT LEVEL AS num
                               FROM dual
                               CONNECT BY LEVEL <= 2) dummy)
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
    FOR second_tab_format IN (SELECT cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(LEVEL * 2 - 1),
                                                                    vSecondTabFirstRowNum,
                                                                    cptt.pkg$trep_reports.getExcelColName(LEVEL * 2),
                                                                    vSecondTabFirstRowNum) AS RANGE,
                                     1 AS border,
                                     'Y' AS is_merged
                              FROM dual
                              CONNECT BY LEVEL <= 8
                              UNION ALL
                              SELECT cptt.pkg$trep_reports.getRange('A',
                                                                    vSecondTabFirstRowNum,
                                                                    cptt.pkg$trep_reports.getExcelColName(8 * 2),
                                                                    vSecondTabFirstRowNum + 2) AS RANGE,
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
  
    vThirdTabFirstRowNum := 13;
    FOR third_tab IN (WITH cat AS
                         (SELECT row_number() over(ORDER BY NAME) AS cat_num,
                                id AS id_privilege,
                                NAME || ' (' || code || ' )' AS cat_name
                         FROM cptt.privilege),
                        data AS
                         (SELECT cat.cat_num,
                                nvl(SUM(tas.count_active), 0) AS count_active,
                                nvl(SUM(tps.count_pass), 0) AS count_pass
                         FROM cat
                         LEFT OUTER JOIN cptt.TMP$TREP_ACTIVE_SERIESPRIV tas
                         ON (cat.id_privilege =
                            cptt.pkg$trep_reports.getIdPrivilegeTrue(tas.series,
                                                                      tas.id_privilege))
                         LEFT OUTER JOIN cptt.TMP$TREP_PASS_SERIESPRIVOP tps
                         ON (cat.id_privilege =
                            cptt.pkg$trep_reports.getIdPrivilegeTrue(tps.series,
                                                                      tps.id_privilege))
                         WHERE tps.id_operator = pIdCarrier
                         GROUP BY cat.cat_num)
                        --���������
                        SELECT vThirdTabFirstRowNum AS row_num,
                               cptt.pkg$trep_reports.getExcelColName(cat_num * 2 - 1) AS col_name,
                               cat_name AS VALUE
                        FROM cat
                        --
                        UNION ALL
                        --��������� ���-��/�����
                        SELECT vThirdTabFirstRowNum + 1 AS row_num,
                               cptt.pkg$trep_reports.getExcelColName(cat_num * 2 - 2 +
                                                                     dummy.num) AS col_name,
                               CASE dummy.num
                                 WHEN 1 THEN
                                  '���-�� �������������� ����'
                                 WHEN 2 THEN
                                  '���-�� ����������'
                               END AS VALUE
                        FROM cat,
                             (SELECT LEVEL AS num
                              FROM dual
                              CONNECT BY LEVEL <= 2) dummy
                        --
                        UNION ALL
                        --��������� ���-��/�����
                        SELECT vThirdTabFirstRowNum + 2 AS row_num,
                               cptt.pkg$trep_reports.getExcelColName(cat_num * 2 - 2 +
                                                                     dummy.num) AS col_name,
                               CASE dummy.num
                                 WHEN 1 THEN
                                  to_char(count_active)
                                 WHEN 2 THEN
                                  to_char(count_pass)
                               END AS VALUE
                        FROM data,
                             (SELECT LEVEL AS num
                              FROM dual
                              CONNECT BY LEVEL <= 2) dummy)
    LOOP
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
    FOR third_tab_format IN (WITH cat AS
                                (SELECT row_number() over(ORDER BY NAME) AS cat_num
                                FROM cptt.privilege)
                               SELECT cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(cat_num * 2 - 1),
                                                                     vThirdTabFirstRowNum,
                                                                     cptt.pkg$trep_reports.getExcelColName(cat_num * 2),
                                                                     vThirdTabFirstRowNum) AS RANGE,
                                      1 AS border,
                                      'Y' AS is_merged
                               FROM cat
                               UNION ALL
                               SELECT cptt.pkg$trep_reports.getRange('A',
                                                                     vThirdTabFirstRowNum,
                                                                     cptt.pkg$trep_reports.getExcelColName(nvl(MAX(cat_num),
                                                                                                               1) * 2),
                                                                     vThirdTabFirstRowNum + 2) AS RANGE,
                                      1 AS border,
                                      'N' AS is_merged
                               FROM cat)
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
  END;

  --����� �� ��������� ����������(����������� ������������� ����������� fillData)
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
                             '� ' ||
                             to_char(pPassBeginDate, 'dd.mm.yyyy HH24:MI:SS') || CRLF ||
                             '�� ' ||
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
                         --����
                         SELECT vSecondTabFirstRowNum AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(-3 + 5 *
                                                                      date_num) AS col_name,
                                '� ' ||
                                to_char(begin_date, 'dd.mm.yyyy HH24:Mi:SS') AS VALUE
                         FROM dates
                         --
                         UNION ALL
                         --������� ���������
                         SELECT vSecondTabFirstRowNum + 1 AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(-3 + 5 *
                                                                      date_num) AS col_name,
                                '�������' AS VALUE
                         FROM dates
                         --
                         UNION ALL
                         --����� ������������� �������� ���������
                         SELECT vSecondTabFirstRowNum + 1 AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(-2 + 5 *
                                                                      date_num) AS col_name,
                                '����� ������������� ��������' AS VALUE
                         FROM dates
                         --
                         UNION ALL
                         --��������� ����� ��������� ��������� ���������
                         SELECT vSecondTabFirstRowNum + 1 AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(-1 + 5 *
                                                                      date_num) AS col_name,
                                '��������� ����� ��������� ���������' AS VALUE
                         FROM dates
                         --
                         UNION ALL
                         --������ ����� ���������
                         SELECT vSecondTabFirstRowNum + 1 AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(5 *
                                                                      date_num) AS col_name,
                                '������ �����' AS VALUE
                         FROM dates
                         --
                         UNION ALL
                         --����� ����� ���������
                         SELECT vSecondTabFirstRowNum + 1 AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(1 + 5 *
                                                                      date_num) AS col_name,
                                '����� �����' AS VALUE
                         FROM dates
                         --
                         UNION ALL
                         --�������
                         SELECT vSecondTabFirstRowNum + 1 + shift_num AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(-3 + 5 *
                                                                      date_num) AS col_name,
                                route_name AS VALUE
                         FROM shift_dates
                         --
                         UNION ALL
                         --����� ������������� ��������
                         SELECT vSecondTabFirstRowNum + 1 + shift_num AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(-2 + 5 *
                                                                      date_num) AS col_name,
                                vehicle_code AS VALUE
                         FROM shift_dates
                         --
                         UNION ALL
                         --��������� ����� ��������� ���������
                         SELECT vSecondTabFirstRowNum + 1 + shift_num AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(-1 + 5 *
                                                                      date_num) AS col_name,
                                train_table AS VALUE
                         FROM shift_dates
                         --
                         UNION ALL
                         --������ �����
                         SELECT vSecondTabFirstRowNum + 1 + shift_num AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(5 *
                                                                      date_num) AS col_name,
                                to_char(shift_begin, 'dd.mm.yyyy HH24:MI:ss') AS VALUE
                         FROM shift_dates
                         --
                         UNION ALL
                         --����� �����
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
                                '������������ ����� "���������" �������' AS cat_name
                         FROM dual
                         UNION ALL
                         SELECT vPrivilegeCount + 2 AS cat_num,
                                '������������ ����� "���������" �������-����������' AS cat_name
                         FROM dual
                         UNION ALL
                         SELECT vPrivilegeCount + 3 AS cat_num,
                                '������������ ����� "���������" ����������' AS cat_name
                         FROM dual
                         UNION ALL
                         SELECT vPrivilegeCount + 4 AS cat_num,
                                '�� ����' AS cat_name
                         FROM dual
                         UNION ALL
                         SELECT vPrivilegeCount + 5 AS cat_num,
                                '��������' AS cat_name
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
                         AND tdt.date_of < dates.begin_date + 1
                         AND (tdt.id_route NOT IN (SELECT r.id from route r,
                                                         division div
                                                   WHERE r.id_division = div.id AND div.id_operator = 16100246845)
                              OR tdt.series IS NOT NULL)),
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
                        --����
                        SELECT vThirdTabFirstRowNum AS row_num,
                               cptt.pkg$trep_reports.getExcelColName(2 +
                                                                     (date_num - 1) * 3) AS col_name,
                               '� ' ||
                               to_char(begin_date, 'dd.mm.yyyy HH24:MI:SS') AS VALUE
                        FROM dates
                        --
                        UNION ALL
                        --���������
                        SELECT cat_first_row_num AS row_num,
                               'A' AS col_name,
                               cat_name AS VALUE
                        FROM trans_cat_first_row
                        /*SELECT catdate_num AS row_num,
                               'A' AS col_name,
                               to_char(date_of, 'HH24:MI:SS') AS VALUE
                        FROM trans_indexed*/
                        --
                        UNION ALL
                        --���������
                        --
                        SELECT vThirdTabFirstRowNum + 1 AS row_num,
                               cptt.pkg$trep_reports.getExcelColName(2 +
                                                                     (date_num - 1) * 3) AS col_name,
                               '�������' AS VALUE
                        FROM dates
                        --
                        UNION ALL
                        --
                        SELECT vThirdTabFirstRowNum + 1 AS row_num,
                               cptt.pkg$trep_reports.getExcelColName(2 +
                                                                     (date_num - 1) * 3 + 1) AS col_name,
                               '����� ����������' AS VALUE
                        FROM dates
                        --
                        UNION ALL
                        --
                        SELECT vThirdTabFirstRowNum + 1 AS row_num,
                               cptt.pkg$trep_reports.getExcelColName(2 +
                                                                     (date_num - 1) * 3 + 2) AS col_name,
                               '����������' AS VALUE
                        FROM dates
                        --
                        UNION ALL
                        --
                        SELECT vThirdTabFirstRowNum AS row_num,
                               cptt.pkg$trep_reports.getExcelColName(2 +
                                                                     (ceil(pPassEndDate -
                                                                           pPassBeginDate) - 1) * 3 + 3) AS col_name,
                               '�� ��� ���' AS VALUE
                        FROM dual
                        --
                        UNION ALL
                        --�������
                        SELECT catdate_num AS row_num,
                               cptt.pkg$trep_reports.getExcelColName(2 +
                                                                     (date_num - 1) * 3) AS col_name,
                               route_name AS VALUE
                        FROM trans_indexed
                        --
                        UNION ALL
                        --����� ����������
                        SELECT catdate_num AS row_num,
                               cptt.pkg$trep_reports.getExcelColName(2 +
                                                                     (date_num - 1) * 3 + 1) AS col_name,
                               to_char(date_of, 'HH24:MI:SS') AS VALUE
                        FROM trans_indexed
                        --
                        UNION ALL
                        --����������
                        SELECT catdate_num AS row_num,
                               cptt.pkg$trep_reports.getExcelColName(2 +
                                                                     (date_num - 1) * 3 + 2) AS col_name,
                               '1' AS VALUE
                        FROM trans_indexed
                        --
                        UNION ALL
                        --����(�� ��� � ���������)(�����)
                        SELECT cat_last_row_num AS row_num,
                               'A' AS col_name,
                               '�����:' AS VALUE
                        FROM trans_cat_last_row
                        --
                        UNION ALL
                        --����(�� ��� � ���������)
                        SELECT cat_last_row_num AS row_num,
                               cptt.pkg$trep_reports.getExcelColName(2 +
                                                                     (date_num - 1) * 3 + 2) AS col_name,
                               to_char(count_pass) AS VALUE
                        FROM trans_total_date_cat
                        --
                        UNION ALL
                        --����(�� ���)(�����)
                        SELECT total_row_num+20 AS row_num,
                               'A' AS col_name,
                               '�����:' AS VALUE
                        FROM trans_total_date
                        WHERE rownum < 2
                        
                        --
                        UNION ALL
                        --����(�� ���)
                        SELECT total_row_num+20 AS row_num,
                               cptt.pkg$trep_reports.getExcelColName(2 +
                                                                     (date_num - 1) * 3 + 2) AS col_name,
                               to_char(count_pass) AS VALUE
                        FROM trans_total_date
                        --
                        UNION ALL
                        --���� �� ���������
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
                        --�����
                        SELECT total_row_num+20 AS row_num,
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
                        WHERE rownum < 2
                        
                        )
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
                                       '������������ ����� "���������" �������' AS cat_name
                                FROM dual
                                UNION ALL
                                SELECT vPrivilegeCount + 2 AS cat_num,
                                       '������������ ����� "���������" �������-����������' AS cat_name
                                FROM dual
                                UNION ALL
                                SELECT vPrivilegeCount + 3 AS cat_num,
                                       '������������ ����� "���������" ����������' AS cat_name
                                FROM dual
                                UNION ALL
                                SELECT vPrivilegeCount + 4 AS cat_num,
                                       '�� ����' AS cat_name
                                FROM dual
                                UNION ALL
                                SELECT vPrivilegeCount + 5 AS cat_num,
                                       '��������' AS cat_name
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
                                AND tdt.date_of < dates.begin_date + 1
                                AND (tdt.id_route NOT IN (SELECT r.id from route r,
                                                         division div
                                                   WHERE r.id_division = div.id AND div.id_operator = 16100246845)
                                     OR tdt.series IS NOT NULL)),
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

    EXCEPTION
       WHEN OTHERS THEN
         raise_application_error(-20001, to_char(pIdTerminal)||' '||SQLERRM);
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
                            WHEN series IN ('39', '343', '353') THEN
                             22
                            WHEN series IN ('19', '141', '150') THEN
                             23
                            WHEN series IN ('29', '242', '252') THEN
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
                          '� ' || to_char(dc.day, 'dd.mm.yyyy HH24:MI:SS') AS VALUE
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
                            WHEN series IN ('39', '343', '353') THEN
                             11
                            WHEN series IN ('19', '141', '150') THEN
                             12
                            WHEN series IN ('29', '242', '252') THEN
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
       '� ' || to_char(pPassBeginDate, 'dd.mm.yyyy HH24:MI:SS') || ' �� ' ||
       to_char(pPassEndDate, 'dd.mm.yyyy HH24:MI:SS'));
    --���������� ����������, �� ������� ����������� ����������
    WITH carrier AS
     (SELECT id_operator FROM cptt.v$trep_carriers),
    pass AS
     (SELECT trans.id_term
      FROM cptt.t_data   trans,
           cptt.division div,
           carrier
      WHERE trans.date_of >= pPassBeginDate
      AND trans.date_of < pPassEndDate
      AND trans.d = 0 -- �� ������
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

  --����� �� ������������ �����(����������� �������������� ���������� fillData)
  PROCEDURE fillReportTransportCardExcel(pCardNum IN NUMBER,
                                         pActivationBeginDate IN DATE,
                                         pActivationEndDate IN DATE,
                                         pPassBeginDate IN DATE,
                                         pPassEndDate IN DATE) AS 
  vSecondTabFirstRowNum NUMBER;
  vSecondTabLastRowNum NUMBER;
  BEGIN
    delete from cptt.tmp$trep_report_excel;
    delete from cptt.tmp$trep_report_excel_format;
    FOR first_tab IN (WITH data AS
                         (SELECT '� ' ||
                                to_char(pPassBeginDate,
                                        'dd.mm.yyyy HH24:MI:SS') || ' �� ' ||
                                to_char(pPassEndDate,
                                        'dd.mm.yyyy HH24:MI:SS') AS period,
                                ean,
                                card_series || ' - ' || CASE
                                  WHEN card_series = '17' THEN
                                   priv.name
                                  WHEN card_series IN
                                       ('39', '53', '43', '46') THEN
                                   '������������ ����� "���������" �������'
                                  WHEN card_series IN
                                       ('19', '50', '41', '44') THEN
                                   '������������ ����� "���������" �������-����������'
                                  WHEN card_series IN
                                       ('29', '52', '42', '45') THEN
                                   '������������ ����� "���������" ����������'
                                END AS card_name,
                                date_of,
                                term.code AS term_code,
                                to_char(date_of, 'dd.mm.yyyy HH24:MI:SS') AS date_active
                         FROM (SELECT trans.id_term,
                                      trans.date_of,
                                      num_to_ean(card_num) AS ean,
                                      nvl(trans.new_card_series,
                                          trans.card_series) AS card_series,
                                      cptt.pkg$trep_reports.getIdPrivilegeTrue(nvl(trans.new_card_series,
                                                                                   trans.card_series),
                                                                               id_privilege) AS id_privilege
                               FROM cptt.t_data   trans,
                                    cptt.division div
                               WHERE trans.kind IN (7, 8, 10, 11, 12, 13, 37) --���������
                               AND trans.d = 0 -- �� ������
                               AND trunc(trans.date_of) >=
                                     pActivationBeginDate
                               AND trunc(trans.date_of) <= pActivationEndDate
                               AND trans.id_division = div.id
                               AND div.id_operator NOT IN
                                     (SELECT id FROM cptt.ref$trep_agents_locked)
                               AND card_num = pCardNum
                               ORDER BY date_of DESC) active,
                              cptt.privilege priv,
                              cptt.term
                         WHERE active.id_privilege = priv.id(+)
                         AND active.id_term = term.id(+)
                         AND rownum = 1)
                        SELECT 2 + r.num AS row_num,
                               'B' AS col_name,
                               CASE r.num
                                 WHEN 1 THEN
                                  period
                                 WHEN 2 THEN
                                  ean
                                 WHEN 3 THEN
                                  card_name
                                 WHEN 4 THEN
                                  term_code
                                 WHEN 5 THEN
                                  date_active
                               END AS VALUE
                        FROM data,
                             (SELECT LEVEL AS num
                              FROM dual
                              CONNECT BY LEVEL <= 5) r)
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
  
    vSecondTabFirstRowNum := 9;
    vSecondTabLastRowNum := vSecondTabFirstRowNum + 1;
    FOR second_tab IN (WITH dates AS
                          (SELECT LEVEL AS num,
                                 pPassBeginDate + LEVEL - 1 AS begin_date
                          FROM dual
                          --START WITH pPassBeginDate < pPassEndDate
                          CONNECT BY pPassBeginDate + LEVEL - 1 <
                                     pPassEndDate
                          ORDER BY LEVEL),
                         data AS
                          (SELECT dates.num AS date_num,
                                 row_number() over(PARTITION BY dates.num ORDER BY cptt.tmp$trep_data.date_of) AS row_num,
                                 term.code AS term_code,
                                 vehicle.code AS vehicle_code,
                                 cptt.pkg$trep_reports.getCarrierPrefix(cptt.tmp$trep_data.id_route) ||
                                 route.code AS route_name,
                                 to_char(cptt.tmp$trep_data.date_of,
                                         'HH24:MI:SS') AS time_pass
                          FROM cptt.tmp$trep_data,
                               dates,
                               cptt.term,
                               cptt.vehicle,
                               cptt.route
                          WHERE card_num = pCardNum
                          AND cptt.tmp$trep_data.date_of >= dates.begin_date
                          AND cptt.tmp$trep_data.date_of <
                                dates.begin_date + 1
                          AND cptt.tmp$trep_data.id_term = term.id(+)
                          AND cptt.tmp$trep_data.id_vehicle = vehicle.id
                          AND cptt.tmp$trep_data.id_route = route.id),
                         total AS
                          (SELECT dates.num AS date_num,
                                 nvl(COUNT(data.date_num), 0) AS count_pass
                          FROM dates,
                               data
                          WHERE dates.num = data.date_num(+)
                          GROUP BY dates.num),
                         total_row AS
                          (SELECT vSecondTabFirstRowNum + 1 +
                                 nvl(MAX(count_pass), 0) + 1 AS row_num
                          FROM total),
                         cols AS
                          (SELECT LEVEL AS num
                          FROM dual
                          CONNECT BY LEVEL <= 4)
                         --��������� "����������� ���"
                         select 
                                    vSecondTabFirstRowNum as row_num,
                                    'A' as col_name,
                                    '����������� ���' as value
                         from dual
                         --
                         union all
                         --��������� � ������
                         SELECT vSecondTabFirstRowNum AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(1 +
                                                                      (dates.num - 1) * 4 + 1) AS col_name,
                                '� ' ||
                                to_date(begin_date, 'dd.mm.yyyy HH24:MI:SS') AS VALUE
                         FROM dates
                         --
                         UNION ALL
                         --������������
                         SELECT vSecondTabFirstRowNum + 1 AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(1 +
                                                                      (dates.num - 1) * 4 +
                                                                      cols.num) AS col_name,
                                CASE cols.num
                                  WHEN 1 THEN
                                   '����� ���������'
                                  WHEN 2 THEN
                                   '����� ������������� ��������'
                                  WHEN 3 THEN
                                   '�������'
                                  WHEN 4 THEN
                                   '�����'
                                END AS VALUE
                         FROM dates,
                              cols
                         --
                         UNION ALL
                         --����� "�����"
                         SELECT vSecondTabFirstRowNum AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(1 +
                                                                      (ceil(pPassEndDate -
                                                                            pPassBeginDate)) * 4 + 1) AS col_name,
                                '�����' AS VALUE
                         FROM dual
                         --
                         UNION ALL
                         --������
                         SELECT vSecondTabFirstRowNum + 1 + data.row_num AS row_num,
                                cptt.pkg$trep_reports.getExcelColName(1 +
                                                                      (data.date_num - 1) * 4 +
                                                                      cols.num) AS col_name,
                                CASE cols.num
                                  WHEN 1 THEN
                                   data.term_code
                                  WHEN 2 THEN
                                   data.vehicle_code
                                  WHEN 3 THEN
                                   data.route_name
                                  WHEN 4 THEN
                                   data.time_pass
                                END AS VALUE
                         FROM data,
                              cols
                         --
                         UNION ALL
                         --������ �����(���������)
                         SELECT tr.row_num,
                                'A' AS col_name,
                                '�����' AS VALUE
                         FROM total_row tr
                         --
                         UNION ALL
                         --����� �� ����
                         SELECT tr.row_num,
                                cptt.pkg$trep_reports.getExcelColName(1 +
                                                                      (total.date_num - 1) * 4 + 4) AS col_name,
                                to_char(total.count_pass) AS VALUE
                         FROM total,
                              total_row tr
                         --
                         UNION ALL
                         --�����
                         SELECT tr.row_num,
                                cptt.pkg$trep_reports.getExcelColName(1 +
                                                                      (ceil(pPassEndDate -
                                                                            pPassBeginDate)) * 4 + 1) AS col_name,
                                to_char(nvl(SUM(count_pass), 0)) AS VALUE
                         FROM total,
                              total_row tr
                         GROUP BY tr.row_num)
    LOOP
      if (second_tab.row_num > vSecondTabLastRowNum) then
        vSecondTabLastRowNum := second_tab.row_num;
      end if;
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
    
    for second_tab_format in (WITH dates AS
                          (SELECT LEVEL AS num,
                                 pPassBeginDate + LEVEL - 1 AS begin_date
                          FROM dual
                          --START WITH pPassBeginDate < pPassEndDate
                          CONNECT BY pPassBeginDate + LEVEL - 1 <
                                     pPassEndDate
                          ORDER BY LEVEL)
                          --��������� ���
                          select cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(1 +
                                                                      (dates.num - 1) * 4 + 1),
                                                                 vSecondTabFirstRowNum,
                                                                 cptt.pkg$trep_reports.getExcelColName(1 +
                                                                      (dates.num - 1) * 4 + 4),
                                                                 vSecondTabFirstRowNum) as range,
                                                                 1 as border,
                                 'Y' as is_merged
                          from dates
                          --
                          union all
                          --�����
                          select cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(1 +
                                                                      (dates.num - 1) * 4 + 1),
                                                                 vSecondTabLastRowNum,
                                                                 cptt.pkg$trep_reports.getExcelColName(1 +
                                                                      (dates.num - 1) * 4 + 3),
                                                                 vSecondTabLastRowNum) as range,
                                                                 1 as border,
                                 'Y' as is_merged
                          from dates
                          union all
                          --��� ������������ �����
                          select 
                            cptt.pkg$trep_reports.getRange('A',
                                                           vSecondTabFirstRowNum + 1,
                                                           'A',
                                                           vSecondTabLastRowNum - 1) as range,
                                                           1 as border,
                            'Y' as is_merged
                          from dual
                          where vSecondTabFirstRowNum+1 < vSecondTabLastRowNum -1
                          --
                          union all
                          --��� ������
                          select
                           cptt.pkg$trep_reports.getRange('A',
                                                          vSecondTabFirstRowNum,
                                                          cptt.pkg$trep_reports.getExcelColName(1 +
                                                                      (ceil(pPassEndDate -
                                                                            pPassBeginDate)) * 4 + 1),
                                                          vSecondTabLastRowNum) as range,
                                                          1 as border,
                           'N' as is_merged
                         from dual
                         --
                         union all
                         --����� �����
                         select 
                            cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(1 +
                                                                      (ceil(pPassEndDate -
                                                                            pPassBeginDate)) * 4 + 1),
                                                           vSecondTabFirstRowNum + 1,
                                                           cptt.pkg$trep_reports.getExcelColName(1 +
                                                                      (ceil(pPassEndDate -
                                                                            pPassBeginDate)) * 4 + 1),
                                                           vSecondTabLastRowNum - 1) as range,
                                                           1 as border,
                            'Y' as is_merged
                          from dual
                          where vSecondTabFirstRowNum+1 < vSecondTabLastRowNum -1
                          --
                          )
    loop
      insert into cptt.tmp$trep_report_excel_format(list_num, range, border, is_merged)
      values(1, second_tab_format.range,  second_tab_format.border, second_tab_format.is_merged);
    end loop;
    
    commit;
  END;
  
--����� �� ������������� �������� (����������� �������������� ���������� fillData)
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
                      --������
                      SELECT 4 AS row_num,
                             'B' AS col_name,
                             'c ' ||
                             to_char(pPassBeginDate, 'dd.mm.yyyy HH24:MI:SS') ||
                             ' �� ' ||
                             to_char(pPassEndDate, 'dd.mm.yyyy HH24:MI:SS') AS VALUE
                      FROM dual
                      --
                      UNION ALL
                      --����� ��
                      SELECT 5 AS row_num,
                             'B' AS col_name,
                             vehicle_code AS VALUE
                      FROM vehicle_data
                      --
                      UNION ALL
                      --����������
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
                               nvl(sum(decode(td.kind, '20', -1, 1)),0) AS count_pass,
                               nvl(sum(decode(td.kind, '20', -td.amount, td.amount)), 0) AS sum_pass,
                               sd.date_num,
                               sd.shift_num
                        FROM cptt.tmp$trep_data td,
                             shift_dates        sd
                        WHERE td.kind IN ('32', '14', '17', '20')
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
                              '����������� ���' AS VALUE
                       FROM dual
                       --
                       UNION ALL
                       --����
                       SELECT 8 AS row_num,
                              cptt.pkg$trep_reports.getExcelColName(2 +
                                                                    (date_num - 1) * 5) AS col_name,
                              '� ' ||
                              to_char(begin_date, 'dd.mm.yyyy HH24:MI:SS') AS VALUE
                       FROM dates
                       --
                       UNION ALL
                       --���������
                       SELECT 9 AS row_num,
                              cptt.pkg$trep_reports.getExcelColName(2 +
                                                                    (date_num - 1) * 5 +
                                                                    cols.col_num - 1) AS col_name,
                              CASE cols.col_num
                                WHEN 1 THEN
                                 '����� ���������'
                                WHEN 2 THEN
                                 '������ ������'
                                WHEN 3 THEN
                                 '��������� ������'
                                WHEN 4 THEN
                                 '���-�� ����������'
                                ELSE
                                 '�����'
                              END AS VALUE
                       FROM dates,
                            cols
                       --
                       UNION ALL
                       --������ � ��������� �� ���������� �� ���� ��������
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
                       --�����
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
                       --������ �����
                       SELECT 9 + max_shift.max_shift_num + 1 AS row_num,
                              'A' AS col_name,
                              '�����' AS VALUE
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
                              --��������� ���
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
                       WHERE id_vehicle = pIdVehicle
                       and kind in ('32', '14', '17', '20')
                       AND (id_route not in (select r.id from route r,
                                                    division div
                                                    where r.id_division = div.id AND div.id_operator = 16100246845)
                           OR series is not null)),
                      priv AS
                       (SELECT rownum AS cat_num,
                              id AS id_privilege,
                              upper(NAME) || ' (' || code || ')' AS cat_name
                       FROM PRIVILEGE),
                      priv_data AS
                       (SELECT priv.cat_num,
                              dates.date_num,
                              nvl(sum(decode(trans.kind, null, 0, '20', -1, 1)), 0) AS count_pass,
                              nvl(SUM(decode(trans.kind, '20', -amount, amount)), 0) AS sum_pass
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
                                 '��������� �� "�������"'
                                WHEN series IN ('19', '50', '41', '44') THEN
                                 '��������� �� "�������-����������"'
                                WHEN series IN ('29', '52', '42', '45') THEN
                                 '��������� �� "����������"'
                                WHEN series IN ('96') THEN
                                 '�� ����'
                                WHEN series IS NULL THEN
                                 '������� ������'
                                ELSE
                                 '������'
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
                             '����������� ���' AS VALUE
                      FROM dual
                      --
                      UNION ALL
                      --����
                      SELECT vThirdTabFirstRowNum AS row_num,
                             cptt.pkg$trep_reports.getExcelColName(2 +
                                                                   (date_num - 1) * 2) AS col_name,
                             '� ' ||
                             to_char(begin_date, 'dd.mm.yyyy HH24:MI:SS') AS VALUE
                      FROM dates
                      --
                      UNION ALL
                      --���������
                      SELECT vThirdTabFirstRowNum + 1 AS row_num,
                             cptt.pkg$trep_reports.getExcelColName(2 +
                                                                   (date_num - 1) * 2 +
                                                                   cols.col_num - 1) AS col_name,
                             CASE cols.col_num
                               WHEN 1 THEN
                                '���-��'
                               ELSE
                                '�����'
                             END AS VALUE
                      FROM dates,
                           cols
                      --
                      UNION ALL
                      --���������
                      SELECT vThirdTabFirstRowNum + 1 + cat_num AS row_num,
                             'A' AS col_name,
                             cat_name AS VALUE
                      FROM all_cat
                      --
                      UNION ALL
                      --��������� ����� �� ����
                      SELECT vThirdTabFirstRowNum + 1 +
                             max_cat.all_max_cat_num + 1 AS row_num,
                             'A' AS col_name,
                             '����� �� ����:' AS VALUE
                      FROM max_cat
                      --
                      UNION ALL
                      --����
                      SELECT vThirdTabFirstRowNum AS row_num,
                             cptt.pkg$trep_reports.getExcelColName(2 +
                                                                   ceil(pPassEndDate -
                                                                        pPassBeginDate) * 2) AS col_name,
                             '����' AS VALUE
                      FROM dual
                      --
                      UNION ALL
                      --����(������������)
                      SELECT vThirdTabFirstRowNum + 1 AS row_num,
                             cptt.pkg$trep_reports.getExcelColName(2 +
                                                                   ceil(pPassEndDate -
                                                                        pPassBeginDate) * 2 +
                                                                   cols.col_num - 1) AS col_name,
                             CASE cols.col_num
                               WHEN 1 THEN
                                '���-��'
                               ELSE
                                '�����'
                             END AS VALUE
                      FROM cols
                      --
                      UNION ALL
                      --������
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
    IF (third_tab.row_num > vThirdTabLastRowNum) THEN
      vThirdTabLastRowNum := third_tab.row_num;
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
                              ORDER BY LEVEL)
                             SELECT cptt.pkg$trep_reports.getRange(cptt.pkg$trep_reports.getExcelColName(2 +
                                                                                                         (date_num - 1) * 2),
                                                                   vThirdTabFirstRowNum,
                                                                   cptt.pkg$trep_reports.getExcelColName(2 +
                                                                                                         (date_num - 1) * 2 + 1),
                                                                   vThirdTabFirstRowNum) AS RANGE,
                                    1 AS border,
                                    'Y' AS is_merged
                             FROM (SELECT date_num
                                   FROM dates
                                   UNION ALL
                                   SELECT ceil(pPassEndDate - pPassBeginDate) + 1 AS date_num
                                   FROM dual)
                             UNION ALL
                             SELECT cptt.pkg$trep_reports.getRange('A',
                                                                   vThirdTabFirstRowNum,
                                                                   cptt.pkg$trep_reports.getExcelColName(2 +
                                                                                                         ceil(pPassEndDate -
                                                                                                              pPassBeginDate) * 2 + 1),
                                                                   vThirdTabLastRowNum) AS RANGE,
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
END;

END pkg$trep_reports;
/
