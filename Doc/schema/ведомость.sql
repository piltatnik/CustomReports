/*  
group by  P.NAME

*/
select sum(t.amount) 
from CARD C LEFT JOIN PRIVILEGE P ON C.ID_PRIVILEGE=P.ID 
right join t_data t on c.id=t.id_card 
where  t.kind in (7,8,12,13)
and t.ins_date between '13.11.2016'   and '06.12.2016'      
--and coalesce(t.new_card_series,t.card_series) in (19)                                  
and t.id_division  in  (800246845,700246845,6100246845,6200246845,8100246845) 
--group by  coalesce(t.new_card_series,t.card_series)  

select c.f,P.NAME,to_char(t.date_of,'dd.MM.YYYY')                                                                    
from CARD C LEFT JOIN PRIVILEGE P ON C.ID_PRIVILEGE=P.ID 
right join t_data t on c.id=t.id_card 
where t.card_series=17 and t.kind in (7,8,12,13)
and t.ins_date between '13.12.2016'   and '06.01.2017'      
and p.code in (15)                                  
and t.id_division  in  (800246845,700246845,6100246845,6200246845,8100246845)                                                                
order by c.f 
