select s02.d as "����" ,
      
       coalesce(s22.sh,0) as "�������� �����",
       coalesce(s21.sh,0) as "������������ �����",
       coalesce(s07.sh,0) as "���������",
       coalesce(s08.sh,0) as "����������",
       coalesce(s09.sh,0) as "����� ����",
       coalesce(s10.sh,0) as "��������",
       coalesce(s11.sh,0) as "��������� ����",
       coalesce(s12.sh,0) as "��������� ����������",
       coalesce(s13.sh,0) as "�����������������",
       coalesce(s14.sh,0) as "�������� �����",
       coalesce(s15.sh,0) as "�����������"
from 
        ( select distinct extract(month from (t_data.date_of)) ||'.'||(extract(year from t_data.date_of)) as d
    from t_data
    where  t_data.kind in (14,15,17) and t_data.id_division=300246845 -- 300246845 �� 100246845 -���
    and t_data.date_of > '01.07.2016'  ) s02 
 left  join 

 
  (select extract(month from (t_data.date_of)) ||'.'||(extract(year from t_data.date_of)) as d, count(t_data.id) as sh   
    from T_data
    where t_data.kind in (14,17) and t_data.id_division=300246845 and coalesce(t_data.new_card_series,t_data.card_series) in (11,12,13,21,22,31,32)  --����
    group by extract(month from (t_data.date_of)) ||'.'||(extract(year from t_data.date_of))
    ) s21
  on 
  s02.d=s21.d
  
  left  join  
  (select extract(month from (t_data.date_of)) ||'.'||(extract(year from t_data.date_of))as d,count(t_data.id) as sh   
    from  t_data 
    where t_data.kind in (14,17) and t_data.id_division=300246845 and t_data.card_series in (14,15,16,24,25,34,35)  --��
    group by extract(month from (t_data.date_of)) ||'.'||(extract(year from t_data.date_of))
    ) s22
  on 
  s02.d=s22.d
  
 
left  join   
( select extract(month from (t_data.date_of)) ||'.'||(extract(year from t_data.date_of)) as d,count(t_data.id) as sh
    from t_data left join privilege p on t_data.id_privilege=p.id
    where  t_data.kind in (14,17) and t_data.id_division=300246845
   --����
    and p.code =7
    group by  extract(month from (t_data.date_of)) ||'.'||(extract(year from t_data.date_of)) 
    
    ) s07
    on 
    s02.d=s07.d
    
 left  join   
( select extract(month from (t_data.date_of)) ||'.'||(extract(year from t_data.date_of)) as d,count(t_data.id) as sh
    from t_data left join privilege p on t_data.id_privilege=p.id
    where  t_data.kind in (14,17) and t_data.id_division=300246845
   --����������
    and p.code =8
    group by  extract(month from (t_data.date_of)) ||'.'||(extract(year from t_data.date_of)) 
    
    ) s08
    on 
    s02.d=s08.d
    
    left  join   
( select extract(month from (t_data.date_of)) ||'.'||(extract(year from t_data.date_of)) as d,count(t_data.id) as sh
    from t_data left join privilege p on t_data.id_privilege=p.id
    where  t_data.kind in (14,17) and t_data.id_division=300246845
   --�����
    and p.code =9
    group by  extract(month from (t_data.date_of)) ||'.'||(extract(year from t_data.date_of)) 
    
    ) s09
    on 
    s02.d=s09.d
    
    left  join   
( select extract(month from (t_data.date_of)) ||'.'||(extract(year from t_data.date_of)) as d,count(t_data.id) as sh
    from t_data left join privilege p on t_data.id_privilege=p.id
    where  t_data.kind in (14,17) and t_data.id_division=300246845
   --��������
    and p.code =10
    group by  extract(month from (t_data.date_of)) ||'.'||(extract(year from t_data.date_of)) 
    
    ) s10
    on 
    s02.d=s10.d
    
    left  join   
    
( select extract(month from (t_data.date_of)) ||'.'||(extract(year from t_data.date_of)) as d,count(t_data.id) as sh
    from t_data left join privilege p on t_data.id_privilege=p.id
    where  t_data.kind in (14,17) and t_data.id_division=300246845
   --���������
    and p.code =11
    group by  extract(month from (t_data.date_of)) ||'.'||(extract(year from t_data.date_of)) 
    
    ) s11
    on 
    s02.d=s11.d
    
    left  join   
( select extract(month from (t_data.date_of)) ||'.'||(extract(year from t_data.date_of)) as d,count(t_data.id) as sh
    from t_data left join privilege p on t_data.id_privilege=p.id
    where  t_data.kind in (14,17) and t_data.id_division=300246845
   -- �������
    and p.code =12
    group by  extract(month from (t_data.date_of)) ||'.'||(extract(year from t_data.date_of)) 
    
    ) s12
    on 
    s02.d=s12.d
    left  join   
( select extract(month from (t_data.date_of)) ||'.'||(extract(year from t_data.date_of)) as d,count(t_data.id) as sh
    from t_data left join privilege p on t_data.id_privilege=p.id
    where  t_data.kind in (14,17) and t_data.id_division=300246845
   --����
    and p.code =13
    group by  extract(month from (t_data.date_of)) ||'.'||(extract(year from t_data.date_of)) 
    
    ) s13
    on 
    s02.d=s13.d
    
    left  join   
( select extract(month from (t_data.date_of)) ||'.'||(extract(year from t_data.date_of)) as d,count(t_data.id) as sh
    from t_data left join privilege p on t_data.id_privilege=p.id
    where  t_data.kind in (14,17) and t_data.id_division=300246845
   --��������
    and p.code =14
    group by  extract(month from (t_data.date_of)) ||'.'||(extract(year from t_data.date_of)) 
    
    ) s14
    on 
    s02.d=s14.d
    
    left  join   
( select extract(month from (t_data.date_of)) ||'.'||(extract(year from t_data.date_of)) as d,count(t_data.id) as sh
    from t_data left join privilege p on t_data.id_privilege=p.id
    where  t_data.kind in (14,17) and t_data.id_division=300246845
   --�����
    and p.code =15
    group by  extract(month from (t_data.date_of)) ||'.'||(extract(year from t_data.date_of)) 
    
    ) s15
    on 
    s02.d=s15.d
  
  
   order by 1,2
  
 
   
