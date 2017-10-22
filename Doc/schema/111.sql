select p.id,count(*)
from CARD C right JOIN PRIVILEGE P ON C.ID_PRIVILEGE=P.ID 
left join t_data t on c.id=t.id_card
where p.id=400246845
group by p.id



select c.series,count(*) from CARD C 
left join (select distinct t1.id_card from t_data t1, CARD C  where t1.kind in (7,8,12,13) and c.series in (01,32,31) and c.id=t1.id_card ) t on  c.id=t.id_card 
where
c.series in (01,32,31)
group by c.series
order by series desc


select distinct C.NUM,C.SERIES,C.F,P.NAME,t.amount,to_char(t.date_of,'YYYY-MM-DD')                                                               
from CARD C LEFT JOIN PRIVILEGE P ON C.ID_PRIVILEGE=P.ID 
right join t_data t on c.id=t.id_card 
where c.series=16 and t.kind in (7,8,12,13)
and t.date_of between '23.08.2016' and '06.09.2016 '                                                                       
order by c.f

select C.NUM,C.SERIES,C.F,P.NAME,t.*,to_char(t.date_of,'YYYY-MM-DD')                                                               
from CARD C LEFT JOIN PRIVILEGE P ON C.ID_PRIVILEGE=P.ID 
right join t_data t on c.id=t.id_card
where c.num=0100015197
