select * from t_data t where t.kind in (7,8,12,13) and t.id_division  =2100246845    --500246845  
 and t.ins_date between '13.12.2016' and '06.01.2017' and coalesce(t.new_card_series,t.card_series) in (41)
