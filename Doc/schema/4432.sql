select s2.c2,s3.c3 from
     (select coalesce(t.card_series,'02') c,count(t.id) c2 from
      t_data t left join ser_code s on t.card_series=s.id_ser 
       left join division d on t.id_division=d.id
        where t.kind =14  and t.date_of between '01.12.2016' and '01.01.2017' and d.id = 300246845
          group by coalesce(t.card_series,'02')
               order by 1) s2

full outer join 
 
( select coalesce(t.card_series,'02') c,count(t.id) c3 from
 t_data t left join ser_code s on t.card_series=s.id_ser 
 left join division d on t.id_division=d.id
 where t.kind in (14)  and t.date_of between '01.12.2016' and '01.01.2017' and d.id = 100246845
 group by coalesce(t.card_series,'02')
 order by 1) s3
on s2.c=s3.c
order by 1
