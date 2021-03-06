select s02.d as "����",s02.code as "����� ��������",coalesce(s0.sh,0) as "������ �� ��������",coalesce(s0.summa,0),
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
       coalesce(s08.sh,0) as "�������� ���������" ,
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
        ( select distinct to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code
    from t_data left join route on t_data.id_route=route.id
    where  t_data.kind in (14,15,17) and t_data.id_division=100246845
    and t_data.date_of between '01.12.2016' and '01.01.2017' 
   -- group by to_date(t_data.date_of,'dd-MM-YYYY'),t_data.train_table,
    ) s02    
 left outer join 

  ( select to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from t_data left join card on t_data.id_card=card.id
    left join route on t_data.id_route=route.id
    where  t_data.kind in (14,17) and t_data.id_division=100246845
    and t_data.date_of between '01.12.2016' and '01.01.2017' and coalesce(card.series,'02')=02  --���
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code
    
    ) s0
 
  on   s02.code=s0.code
  and s02.d=s0.d

left outer join 
  ( select to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from t_data left join card on t_data.id_card=card.id
    left join route on t_data.id_route=route.id
    where  t_data.kind =32 and t_data.id_division=100246845
    and t_data.date_of between '01.12.2016' and '01.01.2017' --and t_data.card_series=96  --visa
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code
    
    ) s96
 
  on   s02.code=s96.code
  and s02.d=s96.d

left outer join 

(select to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and coalesce(t_data.new_card_series,t_data.card_series) in (22,21) --��1��
    and t_data.date_of between '01.12.2016' and '01.01.2017'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code
    ) s22
  on 
  s02.code=s22.code
  and s02.d=s22.d

left outer join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and coalesce(t_data.new_card_series,t_data.card_series) in (32,31)  --��1 ��
    and t_data.date_of between '01.12.2016' and '01.01.2017'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code
    ) s32
  on 
    s02.code=s32.code
  and s02.d=s32.d
 
  left outer join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and coalesce(t_data.new_card_series,t_data.card_series) in (13,12,11)   --��2
    and t_data.date_of between '01.12.2016' and '01.01.2017'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code
    ) s13
  on 
   s02.code=s13.code
  and s02.d=s13.d
 
 left join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and  coalesce(t_data.new_card_series,t_data.card_series) in( 35,34) --��1��
    and t_data.date_of between '01.12.2016' and '01.01.2017'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code
    ) s35
  on 
   s02.code=s35.code
  and s02.d=s35.d
 
  
  left outer join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and coalesce(t_data.new_card_series,t_data.card_series) in (25,24) --��1��
    and t_data.date_of between '01.12.2016' and '01.01.2017'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code
    ) s25
  on 
   s02.code=s25.code
  and s02.d=s25.d
  
  left outer join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and coalesce(t_data.new_card_series,t_data.card_series) in (16,14,15) --�� 100
    and t_data.date_of between '01.12.2016' and '01.01.2017'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code
    ) s16
  on 
    s02.code=s16.code
  and s02.d=s16.d


  left outer join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and coalesce(t_data.new_card_series,t_data.card_series) =17 --���������
    and t_data.date_of between '01.12.2016' and '01.01.2017'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code
    ) s17
  on 
    s02.code=s17.code
  and s02.d=s17.d
left outer join   
( select to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from t_data left join card on t_data.id_card=card.id
    left join privilege p on p.id=card.id_privilege
    left join route on t_data.id_route=route.id
    where  t_data.kind in (14,17) and t_data.id_division=100246845
    and t_data.date_of between '01.12.2016' and '01.01.2017'   --�����
   and p.code in (7,8,9)
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code
    
    ) s07
    on 
    s02.code=s07.code
      and s02.d=s07.d
 left outer join   
( select to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from t_data left join card on t_data.id_card=card.id
    left join privilege p on p.id=card.id_privilege
    left join route on t_data.id_route=route.id
    where  t_data.kind in (14,17) and t_data.id_division=100246845
    and t_data.date_of between '01.12.2016' and '01.01.2017'   --���
     and p.code in (11,12,13,14)
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code
    
    ) s08
    on 
    s02.code=s08.code   
  and s02.d=s08.d

 
    left outer join   
( select to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from t_data left join card on t_data.id_card=card.id
    left join route on t_data.id_route=route.id
    left join privilege p on p.id=card.id_privilege
    where  t_data.kind in (14,17) and t_data.id_division=100246845
    and t_data.date_of between '01.12.2016' and '01.01.2017'   --�����������
    and p.code =15
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code
    
    ) s15f
    on 
    s02.code=s15f.code
    and s02.d=s15f.d
    
 left outer join 
    (select to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and coalesce(t_data.new_card_series,t_data.card_series) in (29,52)  --����� 1��
    and t_data.date_of between '01.12.2016' and '01.01.2017'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code
    ) s29
  on 
  s02.code=s29.code
  and s02.d=s29.d
 
  left outer join 
    (select to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and coalesce(t_data.new_card_series,t_data.card_series) in (39,53)  --����� 1���
    and t_data.date_of between '01.12.2016' and '01.01.2017'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code
    ) s39
  on 
  s02.code=s39.code
  and s02.d=s39.d
  
   left outer join 
    (select to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and coalesce(t_data.new_card_series,t_data.card_series) in (19,50)  --����� 2
    and t_data.date_of between '01.12.2016' and '01.01.2017'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code
    ) s19
  on 
  s02.code=s19.code
  and s02.d=s19.d
  
   left outer join 
    (select to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and coalesce(t_data.new_card_series,t_data.card_series) in (42,45)  --�� 1��
    and t_data.date_of between '01.12.2016' and '01.01.2017'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code
    ) s42
  on 
  s02.code=s42.code
  and s02.d=s42.d
  
   left outer join 
    (select to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and coalesce(t_data.new_card_series,t_data.card_series) in (43,46)  --�� 1 ���
    and t_data.date_of between '01.12.2016' and '01.01.2017'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code
    ) s43
  on 
  s02.code=s43.code
  and s02.d=s43.d
  
   left outer join 
    (select to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division=100246845 and coalesce(t_data.new_card_series,t_data.card_series) in (41,44)  --��2
    and t_data.date_of between '01.12.2016' and '01.01.2017'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code
    ) s41
  on 
  s02.code=s41.code
  and s02.d=s41.d
 
    
    

   order by 1,2
  
 
  
 
   
