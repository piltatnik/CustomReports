select distinct num_to_ean(c.num) as "Lic",replace(c.f,'Ќ≈“ ƒјЌЌџ’','нд') as "FIO",'нд' as "Adress",
            case when extract(day from sysdate)<13                 -- выводим мес€ц,на который можно купить проездной
            then extract(month from sysdate)||substr(extract(year from sysdate),3)
                 else extract(month from (add_months(sysdate,1))) ||substr(extract(year from (add_months(sysdate,1))),3)
       end as "month",
         case when sc.ser=17 then p.name --если сери€ 17,то смотрим название льготы по таблице privelege
            else upper(sc.ser_name) end ,sc.ser,sc.amount
from t_data t right join card c  
     on t.id_card=c.id
     left join privilege p 
     on c.id_privilege=p.id
     left join  --смотрим последнюю льготу,на которую активирован проездной
       (select distinct card_num,id_card,first_value(s.id_ser) over (partition  by card_num  order by date_of desc) as ser ,
        first_value(date_of) over (partition  by card_num order by date_of desc), 
        first_value(s.amount) over (partition  by card_num  order by date_of desc) as amount,
        first_value(s.ser_name) over (partition  by card_num order by date_of desc) as ser_name
        from t_data t left join series s --соединение с таблицей-справочником серий
        on t.card_series=s.id_ser
        where kind in (7,8,12,13) and coalesce(t.new_card_series,t.card_series)=s.id_ser
       ) sc
     on c.id= sc.id_card 
         

  where t.kind in (7,8,12,13)                               --покупка проездного
  and coalesce(t.new_card_series,t.card_series) not in (13,16)                                 -- исключаем студентов и школьников 100%                    
  and c.num not in                                          -- фильтр на карты , у которых есть проездной
      (select c.num                                             
       from card c left join t_data t on 
       c.id=t.id_card
       where t.kind in (7,8,11,12,13) and
 
       t.date_to=                             --вычисл€ем на какой мес€ц можно купить проездной
                     (select case when extract(day from sysdate)<13             --до 13 числа    
                      then last_day(trunc(sysdate))                       -- на текущий мес€ц
                      else last_day(add_months(trunc(sysdate),1))  end  -- после 13 на следующий
                      from t_data
                      where rownum=1));



