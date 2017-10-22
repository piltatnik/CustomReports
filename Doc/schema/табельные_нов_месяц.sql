select s02.train_table as "Табельный номер",coalesce(s0.sh,0) as "Проезд за наличные",
       coalesce(s96.sh,0) as "Проезд по карте Visa" ,
       coalesce(s22.sh,0) as "Льготная карта",
       coalesce(s33.sh,0) as "Гражданская карта",
       coalesce(s44.sh,0) as "Юридическое лицо",
       coalesce(s0.sh,0) + coalesce(s96.sh,0)+  coalesce(s22.sh,0)+  coalesce(s33.sh,0) + coalesce(s44.sh,0) as "Итого"
from 
        ( select distinct t_data.train_table
    from t_data
    where  t_data.kind in (14,15,17) and t_data.id_division=300246845 -- 300246845 -АК 100246845 -урт
    and t_data.date_of-3/24 between '01.01.2017' and '15.01.2017'  
   -- group by to_date(t_data.date_of,'dd-MM-YYYY'),t_data.train_table,
    ) s02    
 left outer join 

  ( select t_data.train_table,coalesce(card.series,'02') as c,count(t_data.id) as sh   
    from t_data left join card on t_data.id_card=card.id
    where  t_data.kind in (14,17) and t_data.id_division=300246845
    and t_data.date_of-3/24 between '01.01.2017' and '15.01.2017'   and coalesce(card.series,'02')=02  --нал
    group by t_data.train_table,coalesce(card.series,'02')
    
    ) s0
 
  on   s02.train_table=s0.train_table
  

left outer join 
  ( select t_data.train_table,t_data.card_series,count(t_data.id) as sh  
    from t_data left join card on t_data.id_card=card.id
    where  t_data.kind =32 and t_data.id_division=300246845
    and t_data.date_of-3/24 between '01.01.2017' and '15.01.2017'   -- and t_data.card_series=33  visa
    group by t_data.train_table,t_data.card_series
    
    ) s96
 
  on   s02.train_table=s96.train_table
 

left outer join 

(select t_data.train_table,count(t_data.id) as sh   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series in (11,12,13,14,15,16,17,21,22,24,25,31,32,34,35)  --льготн
    and t_data.date_of-3/24 between '01.01.2017' and '15.01.2017'   
    group by t_data.train_table
    ) s22
  on 
  s02.train_table=s22.train_table
  
 
left  join 

(select t_data.train_table,count(t_data.id) as sh   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series in (19,29,39,50,52,53)  --гражд
    and t_data.date_of-3/24 between '01.01.2017' and '15.01.2017'    
    group by t_data.train_table
    ) s33
  on 
  s02.train_table=s33.train_table
  
  
left  join 

(select t_data.train_table,count(t_data.id) as sh  
   from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series in (41,42,43,44,45,46)  --Юр
    and t_data.date_of-3/24 between '01.01.2017' and '15.01.2017'  
    group by t_data.train_table
    ) s44
  on 
  s02.train_table=s44.train_table
 
  
   order by 1,2
  
 
   
