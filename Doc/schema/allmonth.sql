
select s02.train_table,coalesce(s0.sh,0),coalesce(s0.summa,0),
       coalesce(s96.sh,0),
       coalesce(s22.sh,0),
       coalesce(s21.sh,0),
       coalesce(s32.sh,0),
       coalesce(s31.sh,0),
       coalesce(s13.sh,0),
       coalesce(s12.sh,0),
       coalesce(s11.sh,0),
       coalesce(s25.sh,0),
       coalesce(s24.sh,0),
       coalesce(s35.sh,0),
       coalesce(s34.sh,0),
       coalesce(s16.sh,0),
       coalesce(s15.sh,0),
       coalesce(s14.sh,0),
       coalesce(s17.sh,0)
from 
        ( select distinct t_data.train_table
    from t_data
    where  t_data.kind in (14,15,17) and t_data.id_division=100246845
    and t_data.date_of between '01.09.2016' and '01.10.2016' 
   -- group by to_date(t_data.date_of,'dd-MM-YYYY'),t_data.train_table,
    ) s02    
 left outer join 

  ( select t_data.train_table,coalesce(card.series,'02') as c,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from t_data left join card on t_data.id_card=card.id
    where  t_data.kind in (14,17) and t_data.id_division=100246845
    and t_data.date_of between '01.09.2016' and '01.10.2016' and coalesce(card.series,'02')=02  --���
    group by t_data.train_table,coalesce(card.series,'02')
    
    ) s0
 
  on   s02.train_table=s0.train_table
  

left outer join 
  ( select t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from t_data left join card on t_data.id_card=card.id
    where  t_data.kind in (14,15,17) and t_data.id_division=100246845
    and t_data.date_of between '01.09.2016' and '01.10.2016' and t_data.card_series=96  --visa
    group by t_data.train_table,t_data.card_series
    
    ) s96
 
  on   s02.train_table=s96.train_table
 

left outer join 

(select t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =22 --��50��
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by t_data.train_table,t_data.card_series
    ) s22
  on 
  s02.train_table=s22.train_table
  
left outer join 
     (select t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =21  --�� ��
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by t_data.train_table,t_data.card_series
    ) s21
  on 
  s02.train_table=s21.train_table
  
left outer join 
     (select t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =32  --��50 ��
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by t_data.train_table,t_data.card_series
    ) s32
  on 
    s02.train_table=s32.train_table
  
  left outer join 
     (select t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =31 --�� ��
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by t_data.train_table,t_data.card_series
    ) s31
  on 
    s02.train_table=s31.train_table
  
  left outer join 
     (select t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =13   --��100 2
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by t_data.train_table,t_data.card_series
    ) s13
  on 
   s02.train_table=s13.train_table
  
 left outer join 
     (select t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =12 --��50 2
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by t_data.train_table,t_data.card_series
    ) s12
  on 
    s02.train_table=s12.train_table
 
  left outer join 
     (select t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =11 --��2
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by t_data.train_table,t_data.card_series
    ) s11
  on 
   s02.train_table=s11.train_table
  
 left join 
     (select t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =35 --��50��
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by t_data.train_table,t_data.card_series
    ) s35
  on 
   s02.train_table=s35.train_table
 
  left join 
     (select t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =34  --�� ��
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by t_data.train_table,t_data.card_series
    ) s34
  on 
    s02.train_table=s34.train_table
  
  
  left outer join 
     (select t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =25 --��50��
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by t_data.train_table,t_data.card_series
    ) s25
  on 
   s02.train_table=s25.train_table
  
  
  left outer join 
     (select t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =24 --�� ��
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by t_data.train_table,t_data.card_series
    ) s24
  on 
    s02.train_table=s24.train_table
  

  left outer join 
     (select t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =16 --�� 100
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by t_data.train_table,t_data.card_series
    ) s16
  on 
    s02.train_table=s16.train_table
  

  left outer join 
     (select t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =15 --��50 2
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by t_data.train_table,t_data.card_series
    ) s15
  on 
    s02.train_table=s15.train_table
  

  left outer join 
     (select t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =14 --�� 2
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by t_data.train_table,t_data.card_series
    ) s14
  on 
    s02.train_table=s14.train_table
  

  left outer join 
     (select t_data.train_table,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =17 --���������
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by t_data.train_table,t_data.card_series
    ) s17
  on 
    s02.train_table=s17.train_table
  
   order by 1,2
  
 
   
