select s02.d as "Дата" ,coalesce(s0.sh,0) as "Проезд за наличные",
       coalesce(s96.sh,0) as "Проезд по карте Visa" ,
       coalesce(s22.sh,0) as "Льготная карта",
       coalesce(s0.sh,0) + coalesce(s96.sh,0)+  coalesce(s22.sh,0) as "Итого"
from 
        ( select distinct to_date(t_data.date_of,'dd-MM-YYYY') as d
    from t_data
    where  t_data.kind in (14,15,17) and t_data.id_division=100246845 -- 300246845 АК 100246845 -урт
    and t_data.date_of between '01.10.2016' and '01.11.2016' 
   -- group by to_date(t_data.date_of,'dd-MM-YYYY'),t_data.train_table,
    ) s02    
 left outer join 

  ( select to_date(t_data.date_of,'dd-MM-YYYY') as d,count(t_data.id) as sh   
    from t_data
    where  t_data.kind in (14,17) and t_data.id_division=100246845
    and t_data.date_of between '01.10.2016' and '01.11.2016' and coalesce(t_data.card_series,'02')=02  --нал
    group by to_date(t_data.date_of,'dd-MM-YYYY')
    
    ) s0
 
  on   s02.d=s0.d

left outer join 
  ( select to_date(t_data.date_of,'dd-MM-YYYY') as d,count(t_data.id) as sh  
    from t_data
    where  t_data.kind =32 and t_data.id_division=100246845
    and t_data.date_of between '01.10.2016' and '01.11.2016' -- and t_data.card_series=33  visa
    group by to_date(t_data.date_of,'dd-MM-YYYY')
    
    ) s96
 
  on   s02.d=s96.d

left outer join 


(select to_date(t_data.date_of,'dd-MM-YYYY') as d,count(t_data.id) as sh   
    from t_data
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series in (41,42,43,44,45,46,19,29,39,50,52,53,11,12,13,14,15,16,17,21,22,24,25,31,32,34,35)  --льготн
    and t_data.date_of between '01.10.2016' and '01.11.2016'  
    group by to_date(t_data.date_of,'dd-MM-YYYY')
    ) s22
  on 
  s02.d=s22.d
 
  
  
   order by 1,2
  
 
   
