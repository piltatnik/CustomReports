create view inv(id_ser,id_code)
as 
select distinct case when t.card_series<>17 then t.card_series
                     else p.code end,
case when t.card_series=24 or t.card_series=34 then 1 --�� 1 ���
     when t.card_series=25 or t.card_series=35 then 2 --�� 1 ���
     when t.card_series=14 then 3 --�� 2 ��� 
     when t.card_series=15 then 4 --�� 2 ���    
     when t.card_series=21 or t.card_series=31  then 5 --�� 1 ���
     when t.card_series=22 or t.card_series=32 then 6 -- �� 1 ���
     when t.card_series=11 then 7 -- �� 2 ���
     when t.card_series=12 then 8 --�� 2 ���
     when t.card_series=13 then 9 --�� 2 ����
     when p.code in (7,8,9) then 10 --������� ���
     when p.code =15 then 11 --�����
     when p.code in (11,12,13,14) then 12 --������        
     when t.card_series in (29,39,52,53,42,43,45,46) then 13 --����� 1 
    when t.card_series=19 or t.card_series=50 or t.card_series=41 or t.card_series=44 then 14 --����� 2
      end
from t_data t full join privilege p on t.id_privilege=p.id
  where t.card_series in (11,12,13,14,15,17,21,22,24,25,31,32,34,35,19,29,39,50,52,53,41,42,43,44,45,46)-- and p.code <>4
--select * from inv 
--select distinct t.card_series from t_data t

