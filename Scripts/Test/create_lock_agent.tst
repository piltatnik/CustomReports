PL/SQL Developer Test script 3.0
20
BEGIN
  -- Test statements here
  :cl := '<agents>';
  FOR rec IN (SELECT xmlelement("agent",
                                xmlelement("id", id),
                                xmlelement("state",
                                           CASE
                                             WHEN id IN
                                                  (2100246845, 2200246845, 4100246845, 600246845) THEN
                                              'Y'
                                             ELSE
                                              'N'
                                           END)) AS res
              FROM cptt.operator o)
  LOOP
    dbms_lob.append(:cl, rec.res.getclobval());
  END LOOP;
  dbms_lob.append(:cl, '</agents>');
  pkg$trep_reports.setagentlockedstate(pagentsstatelist => :cl);
END;
1
cl
1
<CLOB>
4208
0
