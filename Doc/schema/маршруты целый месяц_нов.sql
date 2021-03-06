Select s02.code as "����� ��������",coalesce(s0.sh,0) as "������ �� ��������",
       coalesce(s96.sh,0) as "������ �� ����� Visa" ,
       coalesce(s22.sh,0)as "1 ��� ��" ,
       coalesce(s32.sh,0) as "1 ��� ���" ,
       coalesce(s13.sh,0)as "2 ����" ,
       coalesce(s22.sh,0)+coalesce(s32.sh,0)+coalesce(s13.sh,0) as "�����",
       coalesce(s25.sh,0)as "1 ��� ��" ,
       coalesce(s35.sh,0) as "1 ��� ���" ,
       coalesce(s16.sh,0) as "2 ����" ,
       coalesce(s25.sh,0)+coalesce(s35.sh,0)+coalesce(s16.sh,0) as "�����",
       coalesce(s22.sh,0)+coalesce(s25.sh,0)as "1 ��� ��",
       coalesce(s32.sh,0)+coalesce(s35.sh,0) as "1 ��� ���" ,
       coalesce(s13.sh,0)+coalesce(s16.sh,0) as "2 ����" ,
       coalesce(s22.sh,0)+coalesce(s25.sh,0)+coalesce(s32.sh,0)+coalesce(s35.sh,0)+coalesce(s13.sh,0)+coalesce(s16.sh,0) as "�����",
       coalesce(s07.sh,0) as "��������� ���������" ,
       coalesce(s08.sh,0) as "��������� ���������" ,
       coalesce(s15f.sh,0) as "����������� ���������" ,
       coalesce(s17.sh,0) as "�����", 
       coalesce(s29.sh,0)as "1 ��� ��" ,
       coalesce(s39.sh,0) as "1 ��� ���" ,
       coalesce(s19.sh,0) as "2 ����" ,
       coalesce(s29.sh,0)+coalesce(s39.sh,0)+coalesce(s19.sh,0)as "�����",
       coalesce(s42.sh,0)as "1 ��� ��" ,
       coalesce(s43.sh,0) as "1 ��� ���" ,
       coalesce(s41.sh,0) as "2 ����" ,
       coalesce(s42.sh,0)+coalesce(s43.sh,0)+coalesce(s41.sh,0)as "�����",
       coalesce(s22.sh,0)+coalesce(s32.sh,0)+coalesce(s13.sh,0)+coalesce(s25.sh,0)+coalesce(s35.sh,0)+coalesce(s16.sh,0)+
       coalesce(s17.sh,0)+coalesce(s29.sh,0)+coalesce(s39.sh,0)+coalesce(s19.sh,0)+coalesce(s42.sh,0)+coalesce(s43.sh,0)+coalesce(s41.sh,0) as "�����"
       
from 
        ( select distinct route.code
    from t_data left join route on t_data.id_route=route.id
    where  t_data.kind in (14,15,17) and t_data.id_division=300246845
    and t_data.date_of between '01.10.2016' and '01.11.2016' 
   -- group by to_date(t_data.date_of,'dd-MM-YYYY'),t_data.code,
    ) s02    
 left outer join 

  ( select route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from t_data left join card on t_data.id_card=card.id
    left join route on t_data.id_route=route.id
    where  t_data.kind in (14,17) and t_data.id_division=300246845
    and t_data.date_of between '01.10.2016' and '01.11.2016' and coalesce(card.series,'02')=02  --���
    group by  route.code
    
    ) s0
 
  on   s02.code=s0.code
  

left outer join 
  ( select route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from t_data left join card on t_data.id_card=card.id
    left join route on t_data.id_route=route.id
    where  t_data.kind =32 and t_data.id_division=300246845
    and t_data.date_of between '01.10.2016' and '01.11.2016'   --visa
    group by  route.code
    
    ) s96
 
  on   s02.code=s96.code
  

left outer join 

(select route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series in (22,21) --��1��
    and t_data.date_of between '01.10.2016' and '01.11.2016'  
    group by  route.code
    ) s22
  on 
  s02.code=s22.code

  
left outer join 
     (select route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series in (32,31)  --��1 ��
    and t_data.date_of between '01.10.2016' and '01.11.2016'  
    group by  route.code
    ) s32
  on 
    s02.code=s32.code
  

  
  left outer join 
     (select route.code,count(t_data.id) as sh 
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series in (13,12,11)   --��2
    and t_data.date_of between '01.10.2016' and '01.11.2016'  
    group by  route.code
    ) s13
  on 
   s02.code=s13.code
 
  
 left join 
     (select route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series in( 35,34) --��1��
    and t_data.date_of between '01.10.2016' and '01.11.2016'  
    group by  route.code
    ) s35
  on 
   s02.code=s35.code
  
  
  left outer join 
     (select route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series in (25,24) --��1��
    and t_data.date_of between '01.10.2016' and '01.11.2016'  
    group by  route.code
    ) s25
  on 
   s02.code=s25.code
  
 
  left outer join 
     (select route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series in (16,14,15) --�� 100
    and t_data.date_of between '01.10.2016' and '01.11.2016'  
    group by  route.code
    ) s16
  on 
    s02.code=s16.code
  
  left outer join 
     (select route.code,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series =17 --���������
    and t_data.date_of between '01.10.2016' and '01.11.2016'  
    group by  route.code,t_data.card_series
    ) s17
  on 
    s02.code=s17.code
  
left outer join   
( select route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from t_data left join card on t_data.id_card=card.id
    left join privilege p on p.id=card.id_privilege
    left join route on t_data.id_route=route.id
    where  t_data.kind in (14,17) and t_data.id_division=300246845
    and t_data.date_of between '01.10.2016' and '01.11.2016'   --�����
    and p.code in (7,8,9)
    group by  route.code
    
    ) s07
    on 
    s02.code=s07.code
     
 left outer join   
( select route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from t_data left join card on t_data.id_card=card.id
    left join privilege p on p.id=card.id_privilege
    left join route on t_data.id_route=route.id
    where  t_data.kind in (14,17) and t_data.id_division=300246845
    and t_data.date_of between '01.10.2016' and '01.11.2016'   --����
    and p.code in (11,12,13,14)
    group by  route.code
    
    ) s08
    on 
    s02.code=s08.code   
  

    left outer join   
( select  route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from t_data left join card on t_data.id_card=card.id
    left join route on t_data.id_route=route.id
    left join privilege p on p.id=card.id_privilege
    where  t_data.kind in (14,17) and t_data.id_division=300246845
    and t_data.date_of between '01.10.2016' and '01.11.2016'   --�����������
    and p.code =15
    group by  route.code
    
    ) s15f
    on 
    s02.code=s15f.code
    
     left outer join 
    (select route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series in (29,52)  --����� 1��
    and t_data.date_of between '01.10.2016' and '01.11.2016'  
    group by route.code
    ) s29
  on 
  s02.code=s29.code
 
  left outer join 
    (select route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series in (39,53)  --����� 1���
    and t_data.date_of between '01.10.2016' and '01.11.2016'  
    group by route.code
    ) s39
  on 
  s02.code=s39.code
  
   left outer join 
    (select route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series in (19,50)  --����� 2
    and t_data.date_of between '01.10.2016' and '01.11.2016'  
    group by route.code
    ) s19
  on 
  s02.code=s19.code
  
   left outer join 
    (select route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series in (42,45)  --�� 1��
    and t_data.date_of between '01.10.2016' and '01.11.2016'  
    group by route.code
    ) s42
  on 
  s02.code=s42.code
  
   left outer join 
    (select route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series in (43,46)  --�� 1 ���
    and t_data.date_of between '01.10.2016' and '01.11.2016'  
    group by route.code
    ) s43
  on 
  s02.code=s43.code
  
   left outer join 
    (select route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series in (41,44)  --��2
    and t_data.date_of between '01.10.2016' and '01.11.2016'  
    group by route.code
    ) s41
  on 
  s02.code=s41.code
 
    
    

   order by 1,2
  
 
