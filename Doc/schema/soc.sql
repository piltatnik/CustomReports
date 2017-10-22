insert all
into soc(num,fio) values(20062310,'йнпнкеб бхйрнп яепцеебхв')
into soc(num,fio) values(20062311,'лсгшвемйн мхйнкюи цюбпхкнбхв')
into soc(num,fio) values(20062308,'йхяекебю бюкемрхмю цпхцнпэебмю')
into soc(num,fio) values(20062317,'йнгкнбю рюлюпю яепцеебмю')
into soc(num,fio) values(20062316,'лнпнгнбю мюрюкэъ юкейяюмдпнбмю')
into soc(num,fio) values(20062315,'дюпэхмю пюхяю лхуюикнбмю')
into soc(num,fio) values(20062314,'юярпюонбхв бюкемрхмю юмдпеебмю')
into soc(num,fio) values(20062313,'гюижебю бюкемрхмю ъйнбкебмю')
into soc(num,fio) values(20062312,'мюгхмю нкэцю теднпнбмю')
into soc(num,fio) values(20062305,'вслюйнб хбюм демхянбхв')
into soc(num,fio) values(20062306,'йсопхъмнбю мхмю юмдпеебмю')
into soc(num,fio) values(20062303,'цнпнавемйн бюкемрхмю хккюпхнмнбмю')
into soc(num,fio) values(20062304,'еяхмю мюрюкхъ лхуюикнбмю')
into soc(num,fio) values(20062309,'цпсгдеб бхйрнп бюяхкэебхв')
into soc(num,fio) values(20062307,'йскхйнб цеммюдхи юкейяеебхв')
into soc(num,fio) values(20060063,'люмсьхм юмюрнкхи ютюмюяэебхв')
into soc(num,fio) values(20060064,'хлеьеб яепцеи гюуюпнбхв')
SELECT 1 FROM dual

select * from soc
truncate table soc
SELECT NUM,COUNT(NUM)
FROM SOC
GROUP BY NUM
HAVING COUNT(NUM)>1

select c.chip,p.code,c.social_card,'15.09.2016'
from card c right join soc s  on c.num=s.num
left join privilege p on c.id_privilege=p.id


              
              
update soc set priv_code=case
when priv='ТЕДЕПЮКЭМШИ' then '00000015'
when priv='БЕР. рПСДЮ' then '00000014'
when priv='ПЕЦХНМЮКЭМШИ' then '00000012'
when priv='ОЕМЯХНМЕПШ' then '00000007'
when priv='ЦНПНДЯЙНИ' then '00000007'
  end
  
  
update soc set fio='дпюяйнбю рюрэъмю юкейяюмдпнбмю'
where num=20008541



/*MERGE
INTO    card c
USING   (
        SELECT  card.f AS f1,card.num as n1,soc.fio f2,soc.num as n2
        FROM    card 
        JOIN    soc
        ON      card.num = soc.num
               
        ) src
ON      (c.num = src.n2)
WHEN MATCHED THEN UPDATE
    SET c.f = src.f2;
    */
