create view ser_code1(id_ser,id_code)
as 
select distinct t.card_series,
case when  t.card_series=11 or t.card_series=21 or t.card_series=31  then 00000001 --ст полн
     when  t.card_series=12 or t.card_series=22 or t.card_series=32  then 00000002  --ст 50%
     when  t.card_series=13 then 00000003 --ст 100%
     when  t.card_series=14 or t.card_series=24 or  t.card_series=34  then 00000004   --шк полн
     when t.card_series=15 or t.card_series=25 or t.card_series=35 then 00000005-- шк 50%         
     when t.card_series=16  then 00000006-- шк 100%
     when  t.card_series=19 or t.card_series=29 or t.card_series=39 then 00000007 --гражд
     when  t.card_series=50 or t.card_series=52 or t.card_series=53 then 00000007 --гр 50%
     when  t.card_series=41 or t.card_series=42 or t.card_series=43 then 00000008 --ют б/н
     when  t.card_series=44 or t.card_series=45 or t.card_series=46 then 00000009 --юр нал
     end
from t_data t where t.card_series in (11,21,31,12,22,32,13,14,24,34,15,25,35,16,19,29,39,41,42,43,44,45,46,50,52,53)

select * from ser_code1
