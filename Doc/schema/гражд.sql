select s1.id_code,s1.c1,s1.sh,s1.summa,s1.av,
       coalesce(s2.c1,'0'),coalesce(s2.sh,0),coalesce(s2.summa,0),
       coalesce(s3.c1,'0'),coalesce(s3.sh,0),coalesce(s3.av,0),coalesce(s3.summa,0)
from 
  (select distinct sc.id_code,coalesce(t_data.new_card_series,t_data.card_series) as c1,count(*) as sh,avg(t_data.amount) as av,sum(t_data.amount)as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join ser_code1 sc on t_data.card_series=sc.id_ser
       where coalesce(t_data.new_card_series,t_data.card_series) =19 and t_data.kind in (7,8,12,13)and  t_data.id_division  in  (800246845,700246845,6100246845,6200246845,8100246845)    
 --  and t_data.amount_bail=100                         
    and t_data.date_of between '13.12.2016' and '06.01.2017'        
    group by sc.id_code,coalesce(t_data.new_card_series,t_data.card_series)) s1
full outer join 
(select sc.id_code,coalesce(t_data.new_card_series,t_data.card_series) as c1,count(*) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join ser_code1 sc on t_data.card_series=sc.id_ser
        where coalesce(t_data.new_card_series,t_data.card_series) =29 and t_data.kind in (7,8,12,13) and t_data.id_division  in  (800246845,700246845,6100246845,6200246845,8100246845)    
 -- and t_data.amount_bail=100 
    and t_data.date_of between '13.12.2016' and '06.01.2017'           
    group by sc.id_code,coalesce(t_data.new_card_series,t_data.card_series)) s2
    on 
    s1.id_code=s2.id_code
full outer join 
     (select sc.id_code,coalesce(t_data.new_card_series,t_data.card_series) as c1,count(*) as sh,avg(t_data.amount)as av,sum(t_data.amount) as summa  
    from CARD left outer join t_data on  card.id=t_data.id_card
    left join ser_code1 sc on t_data.card_series=sc.id_ser 
       where coalesce(t_data.new_card_series,t_data.card_series) =39 and t_data.kind in (7,8,12,13) and t_data.id_division  in  (800246845,700246845,6100246845,6200246845,8100246845)    
--  and t_data.amount_bail=100
    and t_data.date_of between '13.12.2016' and '06.01.2017'    
    group by sc.id_code,coalesce(t_data.new_card_series,t_data.card_series)) s3        
    on 
    s1.id_code=s3.id_code
    order by id_code desc
