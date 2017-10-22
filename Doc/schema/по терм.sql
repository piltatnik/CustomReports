    select term.code,p.name,p.code,count(*) as sh,sum(t_data.amount) as summa   
    from CARD left outer join t_data on  card.id=t_data.id_card 
    left join privilege p on card.id_privilege=p.id
    left join division d on t_data.id_division=d.id
    left join term on t_data.id_term=term.id
    where p.code between 1 and 15 and t_data.card_series between 1 and 35 and t_data.kind in (7,8,12,13) and d.id=500246845
    and t_data.date_of between '23.08.2016' and '06.09.2016 '   
    group by term.code,p.code,p.name order by 1,3
