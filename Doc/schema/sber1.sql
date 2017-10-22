
select distinct c.num,replace(c.f,' ',',') as "fio",
       case when sc.ser=17 then p.name --���� ����� 17,�� ������� �������� ������ �� ������� privelege
            else upper(sc.ser_name) end ,
       case when extract(day from sysdate)<13                 -- ������� �����,�� ������� ����� ������ ���������
            then extract(month from sysdate)||'.'||extract(year from sysdate)
                 else extract(month from (add_months(sysdate,1))) ||'.'||extract(year from (add_months(sysdate,1)))
       end as "month",'���������',sc.amount
from t_data t right join card c  
     on t.id_card=c.id
     left join privilege p 
     on c.id_privilege=p.id
     left join  --������� ��������� ������,�� ������� ����������� ���������
       (select distinct card_num,id_card,s.ser_name,s.amount,coalesce(t.new_card_series,t.card_series) as ser,last_value(date_of) over (order by date_of desc) 
        from t_data t left join series s --���������� � ��������-������������ �����
        on t.card_series=s.id_ser
        where kind in (7,8,12,13) and coalesce(t.new_card_series,t.card_series)=s.id_ser) sc
     on c.id= sc.id_card   

  where t.kind in (7,8,12,13)                               --������� ����������
  and sc.ser not in (13,16)                                 -- ��������� ��������� � ���������� 100%                    
  and c.num not in                                          -- ������ �� ����� , � ������� ���� ���������
      (select c.num                                             
       from card c left join t_data t on 
       c.id=t.id_card
       where t.kind in (7,8,11,12,13) and
 
       t.date_to=                             --��������� �� ����� ����� ����� ������ ���������
                     (select case when extract(day from sysdate)<13             --�� 13 �����    
                      then last_day(trunc(sysdate))                       -- �� ������� �����
                      else last_day(add_months(trunc(sysdate),1))  end  -- ����� 13 �� ���������
                      from t_data
                      where rownum=1))
                      





