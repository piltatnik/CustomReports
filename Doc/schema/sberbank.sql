select distinct num_to_ean(c.num) as "Lic",replace(c.f,'��� ������','��') as "FIO",'��' as "Adress",
            case when extract(day from sysdate)<13                 -- ������� �����,�� ������� ����� ������ ���������
            then extract(month from sysdate)||substr(extract(year from sysdate),3)
                 else extract(month from (add_months(sysdate,1))) ||substr(extract(year from (add_months(sysdate,1))),3)
       end as "month",
         case when sc.ser=17 then sc.name --���� ����� 17,�� ������� �������� ������ �� ������� privelege
             when c.num like '012%' then p.name
            else upper(sc.ser_name) end ,
             coalesce(sc.ser,17),coalesce(sc.amount,330)
from card c  left outer join
      privilege p 
     on c.id_privilege=p.id
    left outer join  --������� ��������� ������,�� ������� ����������� ���������
       (select distinct card_num,first_value(s.id_ser) over (partition  by card_num  order by date_of desc) as ser ,
        first_value(date_of) over (partition  by card_num order by date_of desc), 
        first_value(s.amount) over (partition  by card_num  order by date_of desc) as amount,
        first_value(s.ser_name) over (partition  by card_num order by date_of desc) as ser_name,
        coalesce(first_value(p.name) over (partition  by card_num order by date_of desc),s.ser_name) as name
        from t_data t left join series s --���������� � ��������-������������ �����
        on coalesce(t.new_card_series,t.card_series)=s.id_ser
        left outer join privilege p
        on t.id_privilege=p.id
        where kind in (7,8,12,13) and coalesce(t.new_card_series,t.card_series) not in(13,16)  -- ��������� ��������� � ���������� 100%   
       ) sc
     on c.num= sc.card_num 
         
                          
   
   where c.num is not null 
   
   and case when sc.ser=17 then p.name --���� ����� 17,�� ������� �������� ������ �� ������� privelege
             when c.num like '012%' then '���������' 
            else upper(sc.ser_name) end is not null                                     
  and c.id not in                                          -- ������ �� ����� , � ������� ���� ���������
      (select t.id_card from t_data t                                             
       where t.kind in (7,8,11,12,13) and
 
       t.date_to=                             --��������� �� ����� ����� ����� ������ ���������
                     (select case when extract(day from sysdate)<13             --�� 13 �����    
                      then last_day(trunc(sysdate))                       -- �� ������� �����
                      else last_day(add_months(trunc(sysdate),1))  end  -- ����� 13 �� ���������
                      from t_data
                      where rownum=1))
    and c.id in( -- ��������� ������
   select t.id_card from t_data t where t.id_privilege in (400246845,500246845,600246845,700246845,800246845,900246845) or t.id_privilege is null );



