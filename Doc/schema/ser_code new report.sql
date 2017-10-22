create view ser_code(id_ser,id_code)
as 
select distinct t.card_series,
case when  t.card_series=14 or t.card_series=24 or t.card_series=34 or t.card_series=15 or t.card_series=25 or t.card_series=35 or t.card_series=16 then 00000001 --шк
     when  t.card_series=11 or t.card_series=21 or t.card_series=31 or t.card_series=12 or t.card_series=22 or t.card_series=32 or t.card_series=13 then 00000002  --ст
     when  t.card_series=17 then 00000003 --льготники
     when  t.card_series=19 or t.card_series=29 or  t.card_series=50 or t.card_series=52 then 00000004   --гражд 1
     when t.card_series=39 or t.card_series=53 then 00000005--гражд2         
     when t.card_series=60  then 00000006--ultralight
     
         
       end
from t_data t where t.card_series in (14,24,34,15,25,35,16,11,21,31,12,22,32,13,17,19,29,50,52,39,53,60)

select s1.id_code,s1.c1,s2.c2,s3.c3
from 
       (select s.id_code,count(t.id) c1 from
        t_data t left join ser_code s on t.card_series=s.id_ser 
         left join division d on t.id_division=d.id
          where t.kind in (7,8,12,13)  and t.date_of between '23.08.2016' and '06.09.2016' and d.id in (500246845,600246845)
           group by s.id_code
            order by 1) s1
left outer join

     (select s.id_code,count(t.id) c2 from
      t_data t left join ser_code s on t.card_series=s.id_ser 
       left join division d on t.id_division=d.id
        where t.kind in (17)  and t.date_of between '01.09.2016' and '01.10.2016' and d.id = 300246845
           group by s.id_code
               order by 1) s2
on s1.id_code=s2.id_code
left outer join 
 
( select s.id_code,count(t.id) c3 from
 t_data t left join ser_code s on t.card_series=s.id_ser 
 left join division d on t.id_division=d.id
 where t.kind in (17)  and t.date_of between '01.09.2016' and '01.10.2016' and d.id = 100246845
 group by s.id_code
 order by 1) s3
on s1.id_code=s3.id_code
order by 1
 
--нал

select s2.c2,s3.c3 from
     (select coalesce(t.card_series,'02') c,count(t.id) c2 from
      t_data t left join ser_code s on t.card_series=s.id_ser 
       left join division d on t.id_division=d.id
        where t.kind =14  and t.date_of between '01.09.2016' and '01.10.2016' and d.id = 300246845
          group by coalesce(t.card_series,'02')
               order by 1) s2

full outer join 
 
( select coalesce(t.card_series,'02') c,count(t.id) c3 from
 t_data t left join ser_code s on t.card_series=s.id_ser 
 left join division d on t.id_division=d.id
 where t.kind in (14)  and t.date_of between '01.09.2016' and '01.10.2016' and d.id = 100246845
 group by coalesce(t.card_series,'02')
 order by 1) s3
on s2.c=s3.c
order by 1
 


