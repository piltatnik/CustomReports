create view ser_code(id_ser,id_code)
as 
select distinct c.series,
case when c.series=11 or c.series=21 or c.series=31 then 00000001
     when c.series=12 or c.series=22 or c.series=32 then 00000002
    when c.series=13 then 00000003
    when  c.series=14 or c.series=24 or c.series=34 then 00000004
    when c.series=15 or c.series=25 or c.series=35 then 00000005
     when c.series=16 then 00000006
       end
from card c where c.series in (11,12,13,14,15,16,21,22,24,25,31,32,34,35)
select * from ser_code


select s1.id_code,s1.series,s1.sh,s1.summa,s1.av,
       coalesce(s2.series,'0'),coalesce(s2.sh,0),coalesce(s2.summa,0),
       coalesce(s3.series,'0'),coalesce(s3.sh,0),coalesce(s3.av,0),coalesce(s3.summa,0)
from 
  (select sc.id_code,card.series,count(*) as sh,avg(t_data.amount) as av,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join ser_code sc on card.series=sc.id_ser
    left join division d on t_data.id_division=d.id
    where card.series in (14,15) and t_data.kind in (7,8,12,13) and d.id=500246845
    group by sc.id_code,card.series) s1
left outer join 
(select sc.id_code,card.series,count(*) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join ser_code sc on card.series=sc.id_ser
    left join division d on t_data.id_division=d.id
    where card.series in (24,25) and t_data.kind in (7,8,12,13) and d.id=500246845
    group by sc.id_code,card.series) s2
    on 
    s1.id_code=s2.id_code
left outer join 
     (select sc.id_code,card.series,count(*) as sh,avg(t_data.amount)as av,sum(t_data.amount) as summa  
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join ser_code sc on card.series=sc.id_ser
    left join division d on t_data.id_division=d.id
    where card.series in (34,35) and t_data.kind in (7,8,12,13) and d.id=500246845
    group by sc.id_code,card.series) s3
    on 
    s1.id_code=s3.id_code
    order by id_code desc
    
    
    select p.name,p.code,count(*) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join privilege p on card.id_privilege=p.id
    left join division d on t_data.id_division=d.id
    where p.code between 7 and 15 and card.series=17 and t_data.kind in (7,8,12,13) and d.id=500246845
    group by p.code,p.name order by 1
    


