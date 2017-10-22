
select s02.d,s02.train_table,coalesce(s0.sh,0),coalesce(s0.summa,0),s0.c,
       s22.d,s22.train_table,coalesce(s22.sh,0),s22.summa,s22.card_series,
       s21.d,s21.train_table,coalesce(s21.sh,0),s21.summa,s21.card_series,
       s32.d,s32.train_table,coalesce(s32.sh,0),s32.summa,s32.card_series,
       s31.d,s31.train_table,coalesce(s31.sh,0),s31.summa,s31.card_series,
       s13.d,s13.train_table,coalesce(s13.sh,0),s21.summa,s13.card_series,
       s12.d,s12.train_table,coalesce(s12.sh,0),s12.summa,s12.card_series,
       s11.d,s11.train_table,coalesce(s11.sh,0),s11.summa,s11.card_series,
       s25.d,s25.train_table,coalesce(s25.sh,0),s25.summa,s25.card_series,
       s24.d,s24.train_table,coalesce(s24.sh,0),s24.summa,s24.card_series,
       s35.d,s35.train_table,coalesce(s35.sh,0),s35.summa,s35.card_series,
       s34.d,s34.train_table,coalesce(s34.sh,0),s34.summa,s34.card_series,
       s16.d,s16.train_table,coalesce(s16.sh,0),s16.summa,s16.card_series,
       s15.d,s15.train_table,coalesce(s15.sh,0),s15.summa,s15.card_series,
       s14.d,s14.train_table,coalesce(s14.sh,0),s14.summa,s14.card_series,
       s17.d,s17.train_table,coalesce(s17.sh,0),s17.summa,s17.card_series
from 
        ( select distinct to_date(t_data.date_of,'dd-MM-YYYY') as d,t_data.train_table
    from t_data
    where  t_data.kind in (14,17) and t_data.id_division=300246845
    and t_data.date_of between '01.09.2016' and '01.10.2016' 
   -- group by to_date(t_data.date_of,'dd-MM-YYYY'),t_data.train_table,
    ) s02    
 left join 

  ( select to_date(t_data.date_of,'dd-MM-YYYY') as d,t_data.train_table,coalesce(card.series,'02') as c,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from t_data left join card on t_data.id_card=card.id
    where  t_data.kind in (14,17) and t_data.id_division=300246845
    and t_data.date_of between '01.09.2016' and '01.10.2016' and coalesce(card.series,'02')=02  --нал
    group by to_date(t_data.date_of,'dd-MM-YYYY'),t_data.train_table,coalesce(card.series,'02')
    
    ) s0
 
  on   s02.train_table=s0.train_table
  and s02.d=s0.d

left outer join 

(select to_date(t_data.date_of,'dd-MM-YYYY') as d,t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series =22 --ст50тр
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),t_data.train_table,t_data.card_series
    ) s22
  on 
  s02.train_table=s22.train_table
  and s02.d=s22.d
left outer join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series =21  --ст тр
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),t_data.train_table,t_data.card_series
    ) s21
  on 
  s02.train_table=s21.train_table
  and s02.d=s21.d
left outer join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series =32  --ст50 ат
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),t_data.train_table,t_data.card_series
    ) s32
  on 
    s02.train_table=s32.train_table
  and s02.d=s32.d
  left outer join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series =31 --ст ат
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),t_data.train_table,t_data.card_series
    ) s31
  on 
    s02.train_table=s31.train_table
  and s02.d=s31.d
  left outer join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series =13   --ст100 2
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),t_data.train_table,t_data.card_series
    ) s13
  on 
   s02.train_table=s13.train_table
  and s02.d=s13.d
 left outer join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series =12 --ст50 2
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),t_data.train_table,t_data.card_series
    ) s12
  on 
    s02.train_table=s12.train_table
  and s02.d=s12.d
  left outer join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series =11 --ст2
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),t_data.train_table,t_data.card_series
    ) s11
  on 
   s02.train_table=s11.train_table
  and s02.d=s11.d
 left join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series =35 --шк50ат
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),t_data.train_table,t_data.card_series
    ) s35
  on 
   s02.train_table=s35.train_table
  and s02.d=s35.d
  left join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series =34  --шк ат
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),t_data.train_table,t_data.card_series
    ) s34
  on 
    s02.train_table=s34.train_table
  and s02.d=s34.d
  
  left outer join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series =25 --шк50тр
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),t_data.train_table,t_data.card_series
    ) s25
  on 
   s02.train_table=s25.train_table
  and s02.d=s25.d
  
  left outer join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series =24 --шк тр
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),t_data.train_table,t_data.card_series
    ) s24
  on 
    s02.train_table=s24.train_table
  and s02.d=s24.d

  left outer join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series =16 --шк 100
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),t_data.train_table,t_data.card_series
    ) s16
  on 
    s02.train_table=s16.train_table
  and s02.d=s16.d

  left outer join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series =15 --шк50 2
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),t_data.train_table,t_data.card_series
    ) s15
  on 
    s02.train_table=s15.train_table
  and s02.d=s15.d

  left outer join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series =14 --шк 2
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),t_data.train_table,t_data.card_series
    ) s14
  on 
    s02.train_table=s14.train_table
  and s02.d=s14.d

  left outer join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series =17 --льготники
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),t_data.train_table,t_data.card_series
    ) s17
  on 
    s02.train_table=s17.train_table
  and s02.d=s17.d
   order by 1,2
  
   --and s1.train_table=s3.train_table
   -- order by id_code desc
    
    
    
    
 /*      select to_date(t_data.date_of,'dd-MM-YYYY') as d,t_data.train_table,coalesce(card.series,'02'),count(t_data.id) as sh,sum(t_data.amount) as summa   
    from t_data left join card on t_data.id_card=card.id
    where  t_data.kind in (14,17) and t_data.id_division=300246845
    and t_data.date_of between '01.09.2016' and '01.10.2016'   
    group by to_date(t_data.date_of,'dd-MM-YYYY'),t_data.train_table,coalesce(card.series,'02')
    
    
  --  select * from t_dATA 
--where train_table='292661' AND date_of >'24.08.2016' */
   
