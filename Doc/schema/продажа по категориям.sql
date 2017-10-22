select count(amount),sum(amount) from t_data 
 where t_data.kind in (7,8,12,13) and t_data.id_division in  (600246845) and coalesce(t_data.new_card_series,t_data.card_series) in (17) and amount<>330
    and t_data.date_of between '23.12.2016' and '06.01.2017'           
