select s1.id_code,s1.c1,s1.sh,s1.summa,s1.av,
       coalesce(s2.c1,'0'),coalesce(s2.sh,0),coalesce(s2.summa,0),
       coalesce(s3.c1,'0'),coalesce(s3.sh,0),coalesce(s3.av,0),coalesce(s3.summa,0)
from 
  (select distinct sc.id_code,coalesce(t_data.new_card_series,t_data.card_series) as c1,count(*) as sh,avg(t_data.amount) as av,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join ser_code1 sc on coalesce(t_data.new_card_series,t_data.card_series)=sc.id_ser
    where coalesce(t_data.new_card_series,t_data.card_series) in (14,15,16) and t_data.kind in (7,8,12,13) and t_data.id_division in  (600246845)                               
    and t_data.date_of between '23.12.2016' and '06.01.2017'           
    group by sc.id_code,coalesce(t_data.new_card_series,t_data.card_series)) s1
full outer join 
(select sc.id_code,coalesce(t_data.new_card_series,t_data.card_series) as c1,count(*) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join ser_code1 sc on coalesce(t_data.new_card_series,t_data.card_series)=sc.id_ser
    where coalesce(t_data.new_card_series,t_data.card_series) in (24,25) and t_data.kind in (7,8,12,13) and t_data.id_division  in  (600246845)               
    and t_data.date_of between '23.12.2016' and '06.01.2017'                                                  
    group by sc.id_code,coalesce(t_data.new_card_series,t_data.card_series)) s2
    on 
    s1.id_code=s2.id_code
full outer join 
     (select sc.id_code,coalesce(t_data.new_card_series,t_data.card_series)as c1,count(*) as sh,avg(t_data.amount)as av,sum(t_data.amount) as summa  
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join ser_code1 sc on coalesce(t_data.new_card_series,t_data.card_series)=sc.id_ser
    where coalesce(t_data.new_card_series,t_data.card_series) in (34,35) and t_data.kind in (7,8,12,13) and t_data.id_division  in (600246845)                 
    and t_data.date_of between '23.12.2016' and '06.01.2017'           
    group by sc.id_code,coalesce(t_data.new_card_series,t_data.card_series)) s3        
    on 
    s1.id_code=s3.id_code
    order by id_code desc
