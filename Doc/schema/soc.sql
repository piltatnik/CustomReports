insert all
into soc(num,fio) values(20062310,'������� ������ ���������')
into soc(num,fio) values(20062311,'��������� ������� ����������')
into soc(num,fio) values(20062308,'�������� ��������� �����������')
into soc(num,fio) values(20062317,'������� ������ ���������')
into soc(num,fio) values(20062316,'�������� ������� �������������')
into soc(num,fio) values(20062315,'������� ����� ����������')
into soc(num,fio) values(20062314,'���������� ��������� ���������')
into soc(num,fio) values(20062313,'������� ��������� ���������')
into soc(num,fio) values(20062312,'������ ����� ���������')
into soc(num,fio) values(20062305,'������� ���� ���������')
into soc(num,fio) values(20062306,'���������� ���� ���������')
into soc(num,fio) values(20062303,'���������� ��������� ������������')
into soc(num,fio) values(20062304,'����� ������� ����������')
into soc(num,fio) values(20062309,'������� ������ ����������')
into soc(num,fio) values(20062307,'������� �������� ����������')
into soc(num,fio) values(20060063,'������� �������� �����������')
into soc(num,fio) values(20060064,'������ ������ ���������')
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
when priv='�����������' then '00000015'
when priv='���. �����' then '00000014'
when priv='������������' then '00000012'
when priv='����������' then '00000007'
when priv='���������' then '00000007'
  end
  
  
update soc set fio='�������� ������� �������������'
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
