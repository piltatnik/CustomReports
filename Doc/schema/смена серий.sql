select t.id,t.date_of,num_to_ean(c.num),t.new_card_series,t.card_series from t_data t left join card c 
on t.id_card=c.id where 
t.new_card_series<>t.card_series
and t.new_card_series=16
and t.date_of between '11.11.2016' and '13.12.2016'
