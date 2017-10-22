 select p.name, count(t.id),sum(t.amount)                                                                     
from CARD C LEFT JOIN PRIVILEGE P ON C.ID_PRIVILEGE=P.ID 
right join t_data t on c.id=t.id_card 
where t.card_series=17 and t.kind in (7,8,12,13)
and t.ins_date between '06.12.2016' and '13.12.2016'       
and p.code between 7 and 15                                
and t.id_division  in  (800246845,700246845,6100246845,6200246845,8100246845)                                                                    
group by p.name


