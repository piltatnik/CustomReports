select s02.d as "����",s02.code as "����� ��������",coalesce(s0.sh,0) as "������ �� ��������",coalesce(s0.summa,0),
       coalesce(s96.sh,0) as "������ �� ����� Visa" ,
       coalesce(s22.sh,0)as "��������� ��",
       coalesce(s21.sh,0)as "��������� ���" ,
       coalesce(s32.sh,0) as "��������� �����" ,
       coalesce(s22.sh,0)+coalesce(s21.sh,0)+coalesce(s32.sh,0) as "�����", 
       
       coalesce(s31.sh,0)as "�������� ��",
       coalesce(s31.sh,0)+coalesce(s13.sh,0)+coalesce(s12.sh,0) as "�����" ,
       coalesce(s13.sh,0)as "�������� ���" ,
       coalesce(s12.sh,0)as "��������� �����" ,
       
       coalesce(s11.sh,0)as "�������� �����" ,
      
       
       coalesce(s35.sh,0)as "��" ,
       coalesce(s34.sh,0)as "���" ,
       coalesce(s25.sh,0)+coalesce(s34.sh,0)+coalesce(s35.sh,0) as "�����",
       coalesce(s25.sh,0) as "�����" , 
    
from 
        ( select distinct to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code
    from t_data left join route on t_data.id_route=route.id
    where  t_data.kind in (14,15,17) 
    and t_data.date_of between '01.09.2016' and '01.10.2016' 
   -- group by to_date(t_data.date_of,'dd-MM-YYYY'),t_data.train_table,
    ) s02    
 left outer join 

left outer join 

(select coalesce(t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division in (800246845,700246845,6100246845,6200246845) and t_data.card_series in (34,35) --��1��
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code,t_data.card_series
    ) s22
  on 
  s02.code=s22.code
  and s02.d=s22.d
left outer join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division in (800246845,700246845,6100246845,6200246845) and t_data.card_series in (24,25)  --��1��
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code,t_data.card_series
    ) s21
  on 
  s02.code=s21.code
  and s02.d=s21.d
left outer join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division in (800246845,700246845,6100246845,6200246845) and t_data.card_series in (14,15,16)  --��2
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code,t_data.card_series
    ) s32
  on 
    s02.code=s32.code
  and s02.d=s32.d
  left outer join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division in (800246845,700246845,6100246845,6200246845) and t_data.card_series in (31,32) --��1��
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code,t_data.card_series
    ) s31
  on 
    s02.code=s31.code
  and s02.d=s31.d
  left outer join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division in (800246845,700246845,6100246845,6200246845) and t_data.card_series in (21,22)   --��1��
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code,t_data.card_series
    ) s13
  on 
   s02.code=s13.code
  and s02.d=s13.d
 left outer join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division in (800246845,700246845,6100246845,6200246845) and t_data.card_series in (11,12,13) --��2
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code,t_data.card_series
    ) s12
  on 
    s02.code=s12.code
  and s02.d=s12.d
  left outer join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division in (800246845,700246845,6100246845,6200246845) and t_data.card_series =17 --���
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code,t_data.card_series
    ) s11
  on 
   s02.code=s11.code
  and s02.d=s11.d
 left join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division in (800246845,700246845,6100246845,6200246845) and t_data.card_series in (19,50) --1��
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code,t_data.card_series
    ) s35
  on 
   s02.code=s35.code
  and s02.d=s35.d
  left join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division in (800246845,700246845,6100246845,6200246845) and t_data.card_series in (29,52)  --1��
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code,t_data.card_series
    ) s34
  on 
    s02.code=s34.code
  and s02.d=s34.d
  
  left outer join 
     (select to_date(t_data.date_of,'dd-MM-YYYY') as d,route.code,t_data.card_series,count(t_data.id) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join route on t_data.id_route=route.id
    where t_data.kind in (14,17) and t_data.id_division in (800246845,700246845,6100246845,6200246845) and t_data.card_series in (39,53) --2
    and t_data.date_of between '01.09.2016' and '01.10.2016'  
    group by to_date(t_data.date_of,'dd-MM-YYYY'),route.code,t_data.card_series
    ) s25
  on 
   s02.code=s25.code
  and s02.d=s25.d
 
   order by 1,2
  
 
   
