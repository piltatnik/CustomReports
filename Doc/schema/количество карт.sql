select sum(amount_bail) from
t_data
where coalesce(t_data.new_card_series,t_data.card_series) in (19,29,39,50,52,53) and t_data.kind in (7,8,12,13) and t_data.id_division in  (800246845,700246845,6100246845,6200246845,8100246845)                      
    and t_data.date_of between '06.12.2016' and '13.12.2016'           
   
select * from t_data where
t_data.kind in (7,8,12,13) and t_data.id_division in  (800246845,700246845,6100246845,6200246845,8100246845)                      
    and t_data.date_of between '06.12.2016' and '13.12.2016'    
