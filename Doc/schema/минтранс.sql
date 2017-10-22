select d.id,p.name, count(*),sum(t.amount)
from card c right join privilege p on c.id_privilege=p.id
right join t_data t on c.id=t.id_card
left join division d on t.id_division=d.id
where d.id in (600246845,500246845)
      and p.code between 11 and 15
      and t.kind in (7,8,12,13)
group by d.id,p.name
order by 1,2
