PL/SQL Developer Test script 3.0
17
BEGIN
  -- Call the procedure
  pkg$trep_reports.fillreportactivepassexcel(pactivationbegindate => :pactivationbegindate,
                                             pactivationenddate   => :pactivationenddate,
                                             ppassbegindate       => :ppassbegindate,
                                             ppassenddate         => :ppassenddate);
  OPEN :cur FOR
    SELECT VALUE,
           list_num,
           row_num,
           col_name,
           t.debug_comment
    FROM cptt.TMP$TREP_REPORT_EXCEL t
    ORDER BY list_num,
             row_num,
             col_name;
END;
5
pactivationbegindate
1
13.11.2016
12
pactivationenddate
1
12.12.2016
12
ppassbegindate
1
01.12.2016 3:00:00
12
ppassenddate
1
01.01.2017 3:00:00
12
cur
1
<Cursor>
116
0
