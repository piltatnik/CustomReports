select t.train_table,c.num ,count(t.id) from t_data t left join card c
on t.id_card=c.id
where t.date_of between '01.09.2016' and '28.09.2016' 
and c.series=17
and t.kind = 17
and t.id_division=300246845
group by c.num,t.train_table

order by count(t.id) desc,c.num 


/*select id_card,count(*) from t_data t left join card c
on t.id_card=c.id
where t.id_card_sec=13100246845
and t.id_division=300246845
and t.kind=17
group by id_card
order by count(*) desc

select t.train_table,c.num,to_date(t.date_of,'dd-MM-yyyy'),count(t.id) from t_data t left join card c
on t.id_card=c.id
where t.date_of between '01.09.2016' and '28.09.2016' 
and c.series=17
and t.kind = 17
and t.id_division=300246845
and t.train_table='291716'
group by c.num,to_date(t.date_of,'dd-MM-yyyy'),t.train_table
order by count(t.id) desc, t.train_table

*/

select * from t_data t left join card c
on t.id_card=c.id
where t.date_of between '01.09.2016' and '28.09.2016' 
and c.series=17
and t.kind = 17
and t.id_division=300246845
--and t.train_table='291716'
and c.num=20003859
