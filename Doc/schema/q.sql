select s1.id_code,s1.series,s1.sh,s1.summa,s1.av,
       coalesce(s2.series,'0'),coalesce(s2.sh,0),coalesce(s2.summa,0),
       coalesce(s3.series,'0'),coalesce(s3.sh,0),coalesce(s3.av,0),coalesce(s3.summa,0)
from 
  (select distinct sc.id_code,card.series,count(*) as sh,avg(t_data.amount) as av,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join ser_code1 sc on card.series=sc.id_ser
    left join division d on t_data.id_division=d.id
    where card.series in (14,15,16) and t_data.kind in (7,8,12,13) and d.id=500246845 
    and t_data.date_of between '23.09.2016' and '06.10.2016'        
    group by sc.id_code,card.series) s1
left outer join 
(select sc.id_code,card.series,count(*) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join ser_code1 sc on card.series=sc.id_ser
    left join division d on t_data.id_division=d.id
    where card.series in (24,25) and t_data.kind in (7,8,12,13) and d.id=500246845
    and t_data.date_of between '23.09.2016' and '06.10.2016'      
    group by sc.id_code,card.series) s2
    on 
    s1.id_code=s2.id_code
left outer join 
     (select sc.id_code,card.series,count(*) as sh,avg(t_data.amount)as av,sum(t_data.amount) as summa  
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join ser_code1 sc on card.series=sc.id_ser
    left join division d on t_data.id_division=d.id
    where card.series in (34,35) and t_data.kind in (7,8,12,13) and d.id=500246845
    and t_data.date_of between '23.09.2016' and '06.10.2016'         
    group by sc.id_code,card.series) s3        
    on 
    s1.id_code=s3.id_code
    order by id_code desc
