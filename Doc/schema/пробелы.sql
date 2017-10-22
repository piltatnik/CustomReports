select c.f,regexp_count(c.f,'   ') from CARD c
where f is not null
and regexp_count(c.f,'  ')<>0

select replace (c.f,'  ',' ') from card c 
where f is not null
and regexp_count(c.f,'  ')<>0


update card c set
c.f=replace (c.f,'  ',' ')
where c.f is not null
and regexp_count(c.f,'  ')<>0
 
