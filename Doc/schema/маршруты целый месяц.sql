Select s02.code as "����� ��������",coalesce(s0.sh,0) as "������ �� ��������",coalesce(s0.summa,0),
       coalesce(s96.sh,0) as "������ �� ����� Visa" ,
       coalesce(s22.sh,0)as "������ 50%" ,
       coalesce(s21.sh,0)as "������" ,
        coalesce(s22.sh,0)+coalesce(s21.sh,0) as "�����", 
       coalesce(s32.sh,0) as "������ 50%" ,
       coalesce(s31.sh,0)as "������" ,
       coalesce(s32.sh,0)+coalesce(s31.sh,0) as "�����" ,
       coalesce(s13.sh,0)as "������ 100%" ,
       coalesce(s12.sh,0)as "������ 50%" ,
       coalesce(s11.sh,0)as "������" ,
       coalesce(s13.sh,0)+coalesce(s12.sh,0)+ coalesce(s11.sh,0) as "�����",
       coalesce(s25.sh,0)as "������ 50%" ,
       coalesce(s24.sh,0)as "������" ,
       coalesce(s25.sh,0)+coalesce(s24.sh,0) as "�����",
       coalesce(s35.sh,0) as "������ 50%" ,
       coalesce(s34.sh,0) as "������" ,
        coalesce(s35.sh,0)+coalesce(s34.sh,0) as "�����",
       coalesce(s16.sh,0) as "������ 100%" ,
       coalesce(s15.sh,0) as "������ 50%" ,              
       coalesce(s14.sh,0) as "������" ,
       coalesce(s16.sh,0)+coalesce(s15.sh,0)+coalesce(s14.sh,0)  as "�����",                                 
       coalesce(s07.sh,0) as "����������" ,
       coalesce(s08.sh,0) as "����������" ,
       coalesce(s09.sh,0) as "����� ����" ,
       coalesce(s10.sh,0) as "�������� ��������" ,
       coalesce(s11t.sh,0)as "��������� ����" ,
       coalesce(s12o.sh,0)as "��������� ����������" ,
       coalesce(s13r.sh,0)as "�����������������" ,
       coalesce(s14v.sh,0)as "�������� �����" ,
       coalesce(s15f.sh,0) as "����������� ���������" ,
       coalesce(s17.sh,0) as "�����" 
from 
        ( select distinct route.code
    from t_data left join route on t_data.id_route=route.id
    where  t_data.kind in (14,15,17) and t_data.id_division=100246845
    and t_data.date_of between '01.09.2016' and '01.10.2016' 
   -- group by to_date(t_data.date_of,'dd-MM-YYYY'),t_data.train_table,
    ) s02    
 left outer join 

  ( select route.code,coalesce(card.series,'02') as c,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from t_data left join card on t_data.id_card=card.id
    left join route on t_data.id_route=route.id
    where  t_data.kind in (14,17) and t_data.id_division=100246845
    and t_data.date_of between '01.09.2016' and '01.10.2016' and coalesce(card.series,'02')=02  --���
    group by  route.code,coalesce(card.series,'02')
    
    ) s0
 
  on   s02.code=s0.code
  

left outer join 
  ( select route.code,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from t_data left join card on t_data.id_card=card.id
    left join route on t_data.id_route=route.id
    where  t_data.kind =32 and t_data.id_division=100246845
    and t_data.date_of between '01.09.2016' and '01.10.2016'   --visa
    group by  route.code,t_data.card_series
    
    ) s96
 
  on   s02.code=s96.code
  

left outer join 

(select route.code,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =22 --��50��
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by  route.code,t_data.card_series
    ) s22
  on 
  s02.code=s22.code
  
left outer join 
     (select route.code,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =21  --�� ��
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by  route.code,t_data.card_series
    ) s21
  on 
  s02.code=s21.code
  
left outer join 
     (select route.code,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =32  --��50 ��
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by  route.code,t_data.card_series
    ) s32
  on 
    s02.code=s32.code
  
  left outer join 
     (select route.code,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =31 --�� ��
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by  route.code,t_data.card_series
    ) s31
  on 
    s02.code=s31.code
  
  left outer join 
     (select route.code,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =13   --��100 2
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by  route.code,t_data.card_series
    ) s13
  on 
   s02.code=s13.code
  
 left outer join 
     (select route.code,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =12 --��50 2
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by  route.code,t_data.card_series
    ) s12
  on 
    s02.code=s12.code
  
  left outer join 
     (select route.code,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =11 --��2
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by  route.code,t_data.card_series
    ) s11
  on 
   s02.code=s11.code
  
 left join 
     (select route.code,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =35 --��50��
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by  route.code,t_data.card_series
    ) s35
  on 
   s02.code=s35.code
  
  left join 
     (select route.code,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =34  --�� ��
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by  route.code,t_data.card_series
    ) s34
  on 
    s02.code=s34.code
 
  
  left outer join 
     (select route.code,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =25 --��50��
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by  route.code,t_data.card_series
    ) s25
  on 
   s02.code=s25.code
  
  
  left outer join 
     (select route.code,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =24 --�� ��
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by  route.code,t_data.card_series
    ) s24
  on 
    s02.code=s24.code
  

  left outer join 
     (select route.code,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =16 --�� 100
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by  route.code,t_data.card_series
    ) s16
  on 
    s02.code=s16.code
  

  left outer join 
     (select route.code,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =15 --��50 2
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by  route.code,t_data.card_series
    ) s15
  on 
    s02.code=s15.code
  

  left outer join 
     (select route.code,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =14 --�� 2
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by  route.code,t_data.card_series
    ) s14
  on 
    s02.code=s14.code
  

  left outer join 
     (select route.code,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and t_data.card_series =17 --���������
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by  route.code,t_data.card_series
    ) s17
  on 
    s02.code=s17.code
  
left outer join   
( select route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from t_data left join card on t_data.id_card=card.id
    left join privilege p on p.id=card.id_privilege
    left join route on t_data.id_route=route.id
    where  t_data.kind in (14,17) and t_data.id_division=100246845
    and t_data.date_of between '01.09.2016' and '01.10.2016'   --����
    and p.code =7
    group by  route.code,p.code
    
    ) s07
    on 
    s02.code=s07.code
     
 left outer join   
( select route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from t_data left join card on t_data.id_card=card.id
    left join privilege p on p.id=card.id_privilege
    left join route on t_data.id_route=route.id
    where  t_data.kind in (14,17) and t_data.id_division=100246845
    and t_data.date_of between '01.09.2016' and '01.10.2016'   --�����
    and p.code =8
    group by  route.code,p.code
    
    ) s08
    on 
    s02.code=s08.code   
  

left outer join   
( select route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from t_data left join card on t_data.id_card=card.id
    left join privilege p on p.id=card.id_privilege
    left join route on t_data.id_route=route.id
    where  t_data.kind in (14,17) and t_data.id_division=100246845
    and t_data.date_of between '01.09.2016' and '01.10.2016'   --�����
    and p.code =9
    group by  route.code,p.code
    
    ) s09
    on 
    s02.code=s09.code
   
    
left outer join  
 
( select route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from t_data left join card on t_data.id_card=card.id
    left join privilege p on p.id=card.id_privilege
    left join route on t_data.id_route=route.id
    where  t_data.kind in (14,17) and t_data.id_division=100246845
    and t_data.date_of between '01.09.2016' and '01.10.2016'   --��������
    and p.code =10
    group by  route.code,p.code
    
    ) s10
    on 
    s02.code=s10.code
    
    
    left outer join   
( select route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from t_data left join card on t_data.id_card=card.id
    left join privilege p on p.id=card.id_privilege
    left join route on t_data.id_route=route.id
    where  t_data.kind in (14,17) and t_data.id_division=100246845
    and t_data.date_of between '01.09.2016' and '01.10.2016'   --���������
    and p.code =11
    group by  route.code,p.code
    
    ) s11t
    on 
    s02.code=s11t.code
    

left outer join   
( select route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from t_data left join card on t_data.id_card=card.id
    left join privilege p on p.id=card.id_privilege
    left join route on t_data.id_route=route.id
    where  t_data.kind in (14,17) and t_data.id_division=100246845
    and t_data.date_of between '01.09.2016' and '01.10.2016'   --���������
    and p.code =12
    group by  route.code,p.code
    
    ) s12o
    on 
    s02.code=s12o.code
    
    
left outer join   
( select route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from t_data left join card on t_data.id_card=card.id
    left join route on t_data.id_route=route.id
    left join privilege p on p.id=card.id_privilege
    where  t_data.kind in (14,17) and t_data.id_division=100246845
    and t_data.date_of between '01.09.2016' and '01.10.2016'   --����
    and p.code =13
    group by  route.code,p.code
    
    ) s13r
    on 
    s02.code=s13r.code
    

    left outer join   
( select route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from t_data left join card on t_data.id_card=card.id
    left join privilege p on p.id=card.id_privilege
    left join route on t_data.id_route=route.id
    where  t_data.kind in (14,17) and t_data.id_division=100246845
    and t_data.date_of between '01.09.2016' and '01.10.2016'   --��������
    and p.code =14
    group by  route.code,p.code
    
    ) s14v
    on 
    s02.code=s14v.code
    
    left outer join   
( select  route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from t_data left join card on t_data.id_card=card.id
    left join route on t_data.id_route=route.id
    left join privilege p on p.id=card.id_privilege
    where  t_data.kind in (14,17) and t_data.id_division=100246845
    and t_data.date_of between '01.09.2016' and '01.10.2016'   --�����������
    and p.code =15
    group by  route.code,p.code
    
    ) s15f
    on 
    s02.code=s15f.code
    
    

   order by 1,2
  
 
