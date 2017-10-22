CREATE TABLE series (
         id_ser      NUMBER(2) PRIMARY KEY,
         ser_name    VARCHAR2(30) NOT NULL,
         amount      number)
         
         
insert all
 into series(id_ser,ser_name,amount) values(10,'электронный кошелек',0)
 into series(id_ser,ser_name,amount) values(11,'студент 2вида',620)
 into series(id_ser,ser_name,amount) values(12,'студент 2вида 50%',310)
 into series(id_ser,ser_name,amount) values(13,'студент 2вида 100%',0)
 into series(id_ser,ser_name,amount) values(14,'школьник 2вида',310)
 into series(id_ser,ser_name,amount) values(15,'школьник 2вида 50%',155)
 into series(id_ser,ser_name,amount) values(16,'школьник 2вида 100%',0)
 into series(id_ser,ser_name,amount) values(17,'льготники',310)
 into series(id_ser,ser_name,amount) values(18,'временная',620)
 into series(id_ser,ser_name,amount) values(19,'гражданский 2вида',1220)
 into series(id_ser,ser_name,amount) values(21,'студент Тр',440)
 into series(id_ser,ser_name,amount) values(22,'студент Тр 50%',230)
 into series(id_ser,ser_name,amount) values(24,'школьник Тр',230)
 into series(id_ser,ser_name,amount) values(25,'школьник Тр 50%',120)
 into series(id_ser,ser_name,amount) values(29,'гражданский Тр',820)
 into series(id_ser,ser_name,amount) values(31,'студент Авт',440)
 into series(id_ser,ser_name,amount) values(32,'студент Авт 50%',230)
 into series(id_ser,ser_name,amount) values(34,'школьник Авт',230)
 into series(id_ser,ser_name,amount) values(35,'школьник Авт 50%',120)
 into series(id_ser,ser_name,amount) values(39,'гражданский Авт',820)
 into series(id_ser,ser_name,amount) values(41,'юридический 2вида б/н',1860)
 into series(id_ser,ser_name,amount) values(42,'юридический Тр б/н',1590)
 into series(id_ser,ser_name,amount) values(43,'юридический Авт б/н',1590)
 into series(id_ser,ser_name,amount) values(44,'юридический 2вида нал',1860)
 into series(id_ser,ser_name,amount) values(45,'юридический Тр нал',1590)
 into series(id_ser,ser_name,amount) values(46,'юридический Авт нал',1590)
 into series(id_ser,ser_name,amount) values(50,'гражданский 2вида 50%',610)
 into series(id_ser,ser_name,amount) values(52,'гражданский Тр 50%',410)
 into series(id_ser,ser_name,amount) values(53,'гражданский Авт 50%',410)
 into series(id_ser,ser_name,amount) values(60,'10 поездок',180)
 into series(id_ser,ser_name,amount) values(96,'Visa',0)
select * from series
