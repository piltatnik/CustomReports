select to_char(t.date_of,'YYYY-MM-DD'),term.code,count(*)
from t_data t left join term on t.id_term=term.id
where t.kind in (14,17) and  t.date_of between '22.08.2016' and '01.09.2016'
group by to_char(t.date_of,'YYYY-MM-DD'),term.code
order by 1
