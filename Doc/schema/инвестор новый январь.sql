select s1.id_code,s1.c1,s2.c2,s3.c3
from 
       (select s.id_code,count(t.id) c1 from
      t_data t left outer join privilege p on t.id_privilege=p.id
      full join inv s on p.code=s.id_code 
      where  t.kind in (7,8,12,13)  and t.date_of between '23.11.2016' and '06.12.2016' and t.id_division in (500246845,600246845)
      and s.id_code  in (10,11,12) 
          group by s.id_code
            order by 1) s1
left outer join

     (select s.id_code,count(t.id) c2 from
      t_data t left join inv s on t.card_series=s.id_ser 
      where t.kind in (17)  and t.date_of between '01.12.2016' and '01.01.2017' and t.id_division = 300246845
       and s.id_code  in (10,11,12) 
           group by s.id_code
               order by 1) s2
on s1.id_code=s2.id_code
left outer join 
 
( select s.id_code,count(t.id) c3 from
 t_data t left join inv s on t.card_series=s.id_ser 
 where t.kind in (17)  and t.date_of between '01.12.2016' and '01.01.2017' and t.id_division = 100246845
  and s.id_code not in (10,11,12) 
 group by s.id_code
 order by 1) s3
on s1.id_code=s3.id_code
order by 1
