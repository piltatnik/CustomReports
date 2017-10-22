select concat('203',substr(c.num,2)),C.SERIES,C.F,P.NAME,t.amount,to_char(t.date_of,'YYYY-MM-DD')                                                               
from CARD C LEFT JOIN PRIVILEGE P ON C.ID_PRIVILEGE=P.ID 
right join t_data t on c.id=t.id_card 
where t.card_series=16 and t.kind in (7,8,12,13)
and t.date_of between '23.08.2016' and '06.09.2016 '                                                                       
order by c.f

