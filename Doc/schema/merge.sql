
MERGE
INTO    card c
USING   (
        SELECT  card.f AS f1,card.num as n1,soc.fio f2,soc.num as n2
        FROM    card 
        JOIN    soc
        ON      card.num = soc.num
        where soc.num<>20062438
        
        ) src
ON      (c.num = src.n2)
WHEN MATCHED THEN UPDATE
    SET c.f = src.f2;
