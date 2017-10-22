-------------------------------------------------
-- Export file for user CPTT                   --
-- Created by Admin_dl on 18.08.2016, 17:38:17 --
-------------------------------------------------

spool 1.log

prompt
prompt Creating table SYS$MENU
prompt =======================
prompt
create table SYS$MENU
(
  id          NUMBER(38) not null,
  name        VARCHAR2(255 CHAR) not null,
  xml_menu    CLOB,
  ins_date    DATE default sysdate not null,
  ins_id_user NUMBER(38) not null,
  upd_date    DATE default sysdate not null,
  upd_id_user NUMBER(38) not null,
  d           NUMBER(1) default 0 not null
)
;
comment on table SYS$MENU
  is 'Меню';
comment on column SYS$MENU.id
  is 'Идентификатор';
comment on column SYS$MENU.name
  is 'Название меню';
comment on column SYS$MENU.xml_menu
  is 'Меню';
comment on column SYS$MENU.ins_date
  is 'Дата создания записи';
comment on column SYS$MENU.ins_id_user
  is 'Кто создал';
comment on column SYS$MENU.upd_date
  is 'Дата изменения записи';
comment on column SYS$MENU.upd_id_user
  is 'Кто изменил';
comment on column SYS$MENU.d
  is 'Признак удаления = 1';
create unique index SI_SYS$MENU on SYS$MENU (UPPER(NAME));
alter table SYS$MENU
  add constraint PK_SYS$MENU primary key (ID);
alter table SYS$MENU
  add constraint FK_SYS$MENU_INS_ID_USR foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table SYS$MENU
  add constraint FK_SYS$MENU_UPD_ID_USR foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table SYS$MENU
  add constraint CHK_SYS$MENU_D
  check (D in (0,1));

prompt
prompt Creating table SYS$GROUPS
prompt =========================
prompt
create table SYS$GROUPS
(
  id          NUMBER(38) not null,
  name        VARCHAR2(255 CHAR) not null,
  description VARCHAR2(255 CHAR),
  id_menu     NUMBER(38),
  ins_date    DATE default sysdate not null,
  ins_id_user NUMBER(38),
  upd_date    DATE default sysdate not null,
  upd_id_user NUMBER(38),
  d           NUMBER(1) default 0 not null
)
;
comment on table SYS$GROUPS
  is 'Группы пользователей';
comment on column SYS$GROUPS.id
  is 'Идентификатор';
comment on column SYS$GROUPS.name
  is 'Имя';
comment on column SYS$GROUPS.description
  is 'Описание';
comment on column SYS$GROUPS.id_menu
  is 'Идентификатор меню группы';
comment on column SYS$GROUPS.ins_date
  is 'Дата создания записи';
comment on column SYS$GROUPS.ins_id_user
  is 'Кто создал';
comment on column SYS$GROUPS.upd_date
  is 'Дата изменения записи';
comment on column SYS$GROUPS.upd_id_user
  is 'Кто изменил';
comment on column SYS$GROUPS.d
  is 'Признак удаления = 1';
create index SI_SYS$GROUPS_ID_MENU on SYS$GROUPS (ID_MENU);
alter table SYS$GROUPS
  add constraint PK_SYS$GROUPS primary key (ID);
alter table SYS$GROUPS
  add constraint UI_SYS$GROUPS_NAME unique (NAME);
alter table SYS$GROUPS
  add constraint FK_SYS$GROUPS_ID_MENU foreign key (ID_MENU)
  references SYS$MENU (ID);
alter table SYS$GROUPS
  add constraint FK_SYS$GROUPS_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table SYS$GROUPS
  add constraint FK_SYS$GROUPS_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table SYS$GROUPS
  add constraint CHK_SYS$GROUPS_D
  check (d in (0,1));

prompt
prompt Creating table SYS$USERS
prompt ========================
prompt
create table SYS$USERS
(
  id          NUMBER(38) not null,
  name        VARCHAR2(30 CHAR) not null,
  fullname    VARCHAR2(255 CHAR) not null,
  description VARCHAR2(255 CHAR),
  id_menu     NUMBER(38),
  id_group    NUMBER(38),
  ins_date    DATE default sysdate not null,
  ins_id_user NUMBER(38) not null,
  upd_date    DATE default sysdate not null,
  upd_id_user NUMBER(38) not null,
  d           NUMBER(1) default 0 not null,
  db_number   NUMBER(38) not null
)
;
comment on table SYS$USERS
  is 'Пользователи';
comment on column SYS$USERS.id
  is 'Идентификатор';
comment on column SYS$USERS.name
  is 'Имя';
comment on column SYS$USERS.fullname
  is 'Полное имя';
comment on column SYS$USERS.description
  is 'Описание';
comment on column SYS$USERS.id_menu
  is 'Идентификатор меню пользователя';
comment on column SYS$USERS.id_group
  is 'ИД группы';
comment on column SYS$USERS.ins_date
  is 'Дата создания записи';
comment on column SYS$USERS.ins_id_user
  is 'Кто создал';
comment on column SYS$USERS.upd_date
  is 'Дата изменения записи';
comment on column SYS$USERS.upd_id_user
  is 'Кто изменил';
comment on column SYS$USERS.d
  is 'Признак удаления = 1';
comment on column SYS$USERS.db_number
  is 'Номер установки БД';
create index SI_SYS$USERS_ID_MENU on SYS$USERS (ID_MENU);
alter table SYS$USERS
  add constraint PK_SYS$USERS primary key (ID);
alter table SYS$USERS
  add constraint UI_SYS$USERS_NAME unique (NAME, DB_NUMBER);
alter table SYS$USERS
  add constraint FK_SYS$USERS_ID_GROUP foreign key (ID_GROUP)
  references SYS$GROUPS (ID);
alter table SYS$USERS
  add constraint FK_SYS$USERS_ID_INS_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table SYS$USERS
  add constraint FK_SYS$USERS_ID_MENU foreign key (ID_MENU)
  references SYS$MENU (ID);
alter table SYS$USERS
  add constraint FK_SYS$USERS_ID_UPD_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table SYS$USERS
  add constraint CHK_SYS$USERS_D
  check (D in (0,1));

prompt
prompt Creating table PRIVILEGE
prompt ========================
prompt
create table PRIVILEGE
(
  id                 NUMBER(38) not null,
  id_privilege_group NUMBER(38),
  code               VARCHAR2(8 CHAR) not null,
  name               VARCHAR2(255 CHAR) not null,
  ins_date           DATE default sysdate not null,
  ins_id_user        NUMBER(38) not null,
  upd_date           DATE default sysdate not null,
  upd_id_user        NUMBER(38) not null,
  d                  NUMBER(1) default 0 not null
)
;
comment on table PRIVILEGE
  is 'Льготы';
comment on column PRIVILEGE.id
  is 'ИД';
comment on column PRIVILEGE.id_privilege_group
  is 'ИД группы';
comment on column PRIVILEGE.code
  is 'Код льготы';
comment on column PRIVILEGE.name
  is 'Наименование';
comment on column PRIVILEGE.ins_date
  is 'Дата создания';
comment on column PRIVILEGE.ins_id_user
  is 'Кто создал';
comment on column PRIVILEGE.upd_date
  is 'Дата редактирования';
comment on column PRIVILEGE.upd_id_user
  is 'Кто редактировал';
comment on column PRIVILEGE.d
  is 'Признак удаления  = 1';
alter table PRIVILEGE
  add constraint PK_PRIVILEGE primary key (ID);
alter table PRIVILEGE
  add constraint UQ_PRIVILEGE unique (ID_PRIVILEGE_GROUP, CODE);
alter table PRIVILEGE
  add constraint FK_PRIVILEGE_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table PRIVILEGE
  add constraint FK_PRIVILEGE_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table PRIVILEGE
  add constraint CHK_PRIVILEGE_CODE
  check (code between '00000001' and '99999999');
alter table PRIVILEGE
  add constraint CHK_PRIVILEGE_D
  check (d in (0,1));

prompt
prompt Creating table PRIVILEGE_GROUP
prompt ==============================
prompt
create table PRIVILEGE_GROUP
(
  id          NUMBER(38) not null,
  code        VARCHAR2(20 CHAR) not null,
  name        VARCHAR2(255 CHAR) not null,
  ins_date    DATE default SYSDATE not null,
  ins_id_user NUMBER(38) default 100000001 not null,
  upd_date    DATE default SYSDATE not null,
  upd_id_user NUMBER(38) default 100000001 not null,
  d           NUMBER(1) default 0 not null,
  id_parent   NUMBER(38),
  kind        NUMBER(1) default 0 not null
)
;
comment on table PRIVILEGE_GROUP
  is 'Группы льгот';
comment on column PRIVILEGE_GROUP.id
  is 'ИД';
comment on column PRIVILEGE_GROUP.code
  is 'Код';
comment on column PRIVILEGE_GROUP.name
  is 'Наименование';
comment on column PRIVILEGE_GROUP.ins_date
  is 'Дата добавлния';
comment on column PRIVILEGE_GROUP.ins_id_user
  is 'Кто добавил';
comment on column PRIVILEGE_GROUP.upd_date
  is 'Дата изменения';
comment on column PRIVILEGE_GROUP.upd_id_user
  is 'Кто изменил';
comment on column PRIVILEGE_GROUP.d
  is 'Признак удаления = 1';
comment on column PRIVILEGE_GROUP.id_parent
  is 'ИД родителя';
comment on column PRIVILEGE_GROUP.kind
  is 'Тип группы (0-Регион, 1-Федеральная, 2-Региональная)';
alter table PRIVILEGE_GROUP
  add constraint FK_PRIVILEGE_GROUP primary key (ID);
alter table PRIVILEGE_GROUP
  add constraint UQ_PRIVILEGE_GROUP_CODE unique (CODE, KIND);
alter table PRIVILEGE_GROUP
  add constraint FK_PRIVILEGE_GROUP_ID_PARENT foreign key (ID_PARENT)
  references PRIVILEGE_GROUP (ID) on delete cascade;
alter table PRIVILEGE_GROUP
  add constraint FK_PRIVILEGE_GROUP_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table PRIVILEGE_GROUP
  add constraint FK_PRIVILEGE_GROUP_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table PRIVILEGE_GROUP
  add constraint CHK_PRIVILEGE_GROUP_D
  check (d in (0, 1));
alter table PRIVILEGE_GROUP
  add constraint CHK_PRIVILEGE_GROUP_KIND
  check (kind in (0, 1, 2));

prompt
prompt Creating table CARD
prompt ===================
prompt
create table CARD
(
  id                           NUMBER(38) not null,
  id_privilege                 NUMBER(38),
  id_privilege_group           NUMBER(38),
  ins_id_user                  NUMBER(38) not null,
  upd_id_user                  NUMBER(38) not null,
  chip                         VARCHAR2(20) not null,
  series                       VARCHAR2(5),
  num                          VARCHAR2(13),
  kind                         NUMBER(1) default 1 not null,
  social_card                  VARCHAR2(33 CHAR),
  f                            VARCHAR2(50 CHAR),
  i                            VARCHAR2(50 CHAR),
  o                            VARCHAR2(50 CHAR),
  type                         NUMBER(1) default 0 not null,
  state                        NUMBER(1) default 1 not null,
  ins_date                     DATE default sysdate not null,
  upd_date                     DATE default sysdate not null,
  d                            NUMBER(1) default 0 not null,
  is_activated                 NUMBER(1) default 0 not null,
  valid_date                   DATE,
  privilege_begin_date         DATE,
  dataformat                   NUMBER(38) default 1 not null,
  travel_doc_kind              NUMBER(1) default 0,
  ep_balance_fact              NUMBER,
  ep_balance_calc              NUMBER,
  sl_balance_fact              NUMBER,
  sl_balance_calc              NUMBER,
  date_of_balance_last         DATE,
  date_of_travel_doc_kind_last DATE
)
;
comment on table CARD
  is 'Карты';
comment on column CARD.id
  is 'ИД';
comment on column CARD.id_privilege
  is 'ИД льготы';
comment on column CARD.id_privilege_group
  is 'ИД региона';
comment on column CARD.ins_id_user
  is 'Кто создал';
comment on column CARD.upd_id_user
  is 'Кто изменил';
comment on column CARD.chip
  is 'Чип';
comment on column CARD.series
  is 'Серия';
comment on column CARD.num
  is 'Номер';
comment on column CARD.kind
  is 'Тип 1-персональная, 2-на предъявителя';
comment on column CARD.social_card
  is '№ социальной карты (964390 NN NNNNNNNNNN N NN/NN NNNN)';
comment on column CARD.f
  is 'Фамилия';
comment on column CARD.i
  is 'Имя';
comment on column CARD.o
  is 'Отчество';
comment on column CARD.type
  is 'Тип карты(0-служебные, 1-социальные, 2-транспортные)';
comment on column CARD.state
  is 'Состояние карты(1-в обращении, 2-в блок списке, 3-заблокирована, 4-в деблок списке, 5-изъята, 6-чужая в блок, 7-чужая из блок, 8-Заблокирована по списку терминалов)';
comment on column CARD.ins_date
  is 'Дата создания';
comment on column CARD.upd_date
  is 'Дата изменения';
comment on column CARD.d
  is 'Признак удаления = 1';
comment on column CARD.is_activated
  is 'Признак активированой карты';
comment on column CARD.valid_date
  is 'Дата окончания действия состояния карты';
comment on column CARD.privilege_begin_date
  is 'Дата начала действия льготы';
comment on column CARD.dataformat
  is 'Формат данных  (1, 2, 3)';
comment on column CARD.travel_doc_kind
  is 'Тип проездного документа: 1- EP электронный кошелек, 2 - SU сезонный проездной без ограничения количества поездок, 3 - SL сезонный проездной с ограничением количества поездок, 4- ET электронные поездки (т.н. Ивановская схема,  сезонного проездного с ограничением количества поездок), 5 - CT билет для проезда в кредит (сезонного проездного без ограничения количества поездок),  6-SC ? сезонный проездной с поездками в кредит, 7-LT, 8-OL, 0 - BL Пустой';
comment on column CARD.ep_balance_fact
  is 'Электронный кошелёк. Фактический баланс.';
comment on column CARD.ep_balance_calc
  is 'Электронный кошелёк. Рассчитаный баланс.';
comment on column CARD.sl_balance_fact
  is 'Cезонный проездной с ограниченым числом поездок. Фактический баланс.';
comment on column CARD.sl_balance_calc
  is 'Cезонный проездной с ограниченым числом поездок. Рассчитаный баланс.';
comment on column CARD.date_of_balance_last
  is 'Дата последней транзакции по карте c фактическим балансом';
comment on column CARD.date_of_travel_doc_kind_last
  is 'Дата последней транзакции по карте с типом проездного документа';
alter table CARD
  add constraint PK_CARD primary key (ID);
alter table CARD
  add constraint UQ_CARD_CHIP unique (CHIP);
alter table CARD
  add constraint UQ_CARD_ID_REG_S_N unique (SERIES, NUM, ID_PRIVILEGE_GROUP)
  disable;
alter table CARD
  add constraint FK_CARD_ID_PRIVILEGE foreign key (ID_PRIVILEGE)
  references PRIVILEGE (ID);
alter table CARD
  add constraint FK_CARD_ID_PRIVILEGE_GROUP foreign key (ID_PRIVILEGE_GROUP)
  references PRIVILEGE_GROUP (ID) on delete cascade;
alter table CARD
  add constraint FK_CARD_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table CARD
  add constraint FK_CARD_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table CARD
  add constraint CHK_CARD_D
  check (D in (0,1));
alter table CARD
  add constraint CHK_CARD_DATAFORMAT
  check (DATAFORMAT in (1,2,3));
alter table CARD
  add constraint CHK_CARD_IS_ACTIVATED
  check (is_activated in (0,1));
alter table CARD
  add constraint CHK_CARD_KIND
  check (kind in (1,2));
alter table CARD
  add constraint CHK_CARD_NUM
  check ((NUM between '000000' and '999999') OR (NUM between '0000000000' and '9999999999') OR (NUM between '0000000000000' and '9999999999999'));
alter table CARD
  add constraint CHK_CARD_SERIES
  check ((SERIES between '00' and '99') OR (SERIES between '00000' and '99999'));
alter table CARD
  add constraint CHK_CARD_STATE
  check (STATE in (1,2,3,4,5,6,7,8));
alter table CARD
  add constraint CHK_CARD_TRAVEL_DOC_KIND
  check (travel_doc_kind in (0,1,2,3,4,5,6,7,8));
alter table CARD
  add constraint CHK_CARD_TYPE
  check (TYPE in (0,1,2));

prompt
prompt Creating table T_DATA_CORRECT
prompt =============================
prompt
create table T_DATA_CORRECT
(
  id                   NUMBER(38) not null,
  id_card              NUMBER(38) not null,
  amount_e             NUMBER,
  amount_l             NUMBER,
  date_of              DATE,
  date_to              DATE,
  ins_date             DATE default SYSDATE not null,
  ins_id_user          NUMBER(38) not null,
  upd_date             DATE default SYSDATE not null,
  upd_id_user          NUMBER(38) not null,
  d                    NUMBER(1) default 0 not null,
  kind                 NUMBER(2) not null,
  travel_doc_kind      NUMBER(1) not null,
  amount_l_suburb      NUMBER,
  id_travel_zone_begin NUMBER(38),
  id_travel_zone_end   NUMBER(38)
)
;
comment on table T_DATA_CORRECT
  is 'Транзакции корректировок';
comment on column T_DATA_CORRECT.id
  is 'ИД';
comment on column T_DATA_CORRECT.id_card
  is 'ИД карты';
comment on column T_DATA_CORRECT.amount_e
  is 'Сумма корректировки баланса электронного кошелька';
comment on column T_DATA_CORRECT.amount_l
  is 'Сумма корректировки баланса поездок';
comment on column T_DATA_CORRECT.date_of
  is 'Пердположительная дата транзакции на термитнале';
comment on column T_DATA_CORRECT.date_to
  is 'Дата окончания действия в днях';
comment on column T_DATA_CORRECT.ins_date
  is 'Дата добавлния';
comment on column T_DATA_CORRECT.ins_id_user
  is 'Кто добавил';
comment on column T_DATA_CORRECT.upd_date
  is 'Дата изменения';
comment on column T_DATA_CORRECT.upd_id_user
  is 'Кто изменил';
comment on column T_DATA_CORRECT.d
  is 'Признак удаления = 1';
comment on column T_DATA_CORRECT.kind
  is 'Тип транзакции';
comment on column T_DATA_CORRECT.travel_doc_kind
  is 'Тип проездного документа: 1- EP электронный кошелек, 2 - SU сезонный проездной без ограничения количества поездок, 3 - SL сезонный проездной с ограничением количества поездок, 4- ET электронные поездки (т.н. Ивановская схема,  сезонного проездного с ограничением количества поездок), 5 - CT билет для проезда в кредит (сезонного проездного без ограничения количества поездок),  6-SC ? сезонный проездной с поездками в кредит, 7-LT сезонный лимитный с фиксированным количеством поездок, 8-OL Омский электронный проездной с лимитом поездок, 0 - BL Пустой';
comment on column T_DATA_CORRECT.amount_l_suburb
  is 'Сумма корректировки баланса поездок (OL,пригород)';
comment on column T_DATA_CORRECT.id_travel_zone_begin
  is 'ИД начальной зоны поездки';
comment on column T_DATA_CORRECT.id_travel_zone_end
  is 'ИД конечной зоны поездки';
alter table T_DATA_CORRECT
  add constraint PK_T_DATA_CORRECT primary key (ID);
alter table T_DATA_CORRECT
  add constraint FK_T_DATA_CORRECT_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table T_DATA_CORRECT
  add constraint FK_T_DATA_CORRECT_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table T_DATA_CORRECT
  add constraint CHK_T_DATA_CORRECT_D
  check (d in (0, 1));
alter table T_DATA_CORRECT
  add constraint CHK_T_DATA_CORRECT_TDK
  check (travel_doc_kind IN (0,1,2,3,4,5,6,7,8));

prompt
prompt Creating table CARD_MONITOR
prompt ===========================
prompt
create table CARD_MONITOR
(
  id                   NUMBER(38) not null,
  id_card              NUMBER(38) not null,
  bal_e_c              NUMBER,
  bal_e_f              NUMBER,
  bal_l_c              NUMBER,
  bal_l_f              NUMBER,
  upd_date             DATE,
  travel_doc_kind      NUMBER(1) not null,
  state                NUMBER(38) default 0 not null,
  date_to_c            DATE,
  date_to_f            DATE,
  delta                NUMBER,
  id_data_correct_last NUMBER(38),
  card_series          VARCHAR2(5) not null,
  date_begin           DATE,
  date_end             DATE
)
;
comment on table CARD_MONITOR
  is 'Журнал мониторинга';
comment on column CARD_MONITOR.id
  is 'ИД';
comment on column CARD_MONITOR.id_card
  is 'ИД карты';
comment on column CARD_MONITOR.bal_e_c
  is 'Баланс электронного кошелька рассчитаный';
comment on column CARD_MONITOR.bal_e_f
  is 'Баланс электронного кошелька фактический';
comment on column CARD_MONITOR.bal_l_c
  is 'Баланс поездок рассчитаный';
comment on column CARD_MONITOR.bal_l_f
  is 'Баланс поездок фактический';
comment on column CARD_MONITOR.upd_date
  is 'Дата редактирования данных';
comment on column CARD_MONITOR.travel_doc_kind
  is 'Тип проездного документа: 1- EP электронный кошелек, 2 - SU сезонный проездной без ограничения количества поездок, 3 - SL сезонный проездной с ограничением количества поездок, 4- ET электронные поездки (т.н. Ивановская схема,  сезонного проездного с ограничением количества поездок), 5 - CT билет для проезда в кредит (сезонного проездного без ограничения количества поездок),  6-SC ? сезонный проездной с поездками в кредит, 7-LT сезонный лимитный с фиксированным количеством поездок, 8-OL Омский электронный проездной с лимитом поездок, 0 - BL Пустой';
comment on column CARD_MONITOR.state
  is 'Состояние тревожности (0 – ОК,  количество тысяч - количество пропущеных тразакци, есть 100 - рублей Р>Ф, есть 200 - рублей Р<Ф, есть 10 - поездки Р>Ф, есть 20 - поездки Р<Ф, есть 1 - дата на трпнспорте > даты на кассе, есть 2 - дата на трпнспорте < даты на кассе)';
comment on column CARD_MONITOR.date_to_c
  is 'Дата окончания действия (транспорт)';
comment on column CARD_MONITOR.date_to_f
  is 'Дата окончания действия (касса)';
comment on column CARD_MONITOR.delta
  is 'РБ-ФБ для SL';
comment on column CARD_MONITOR.id_data_correct_last
  is 'ИД последней транзакции корректировки';
comment on column CARD_MONITOR.card_series
  is 'Серия карты на текущий момент мониторинга';
comment on column CARD_MONITOR.date_begin
  is 'Дата начала расхождения';
comment on column CARD_MONITOR.date_end
  is 'Дата окончания расхождения';
alter table CARD_MONITOR
  add constraint PK_CARD_MONITOR primary key (ID);
alter table CARD_MONITOR
  add constraint UQ_CARD_MONITOR unique (ID_CARD);
alter table CARD_MONITOR
  add constraint FK_CARD_MONITOR_ID_CARD foreign key (ID_CARD)
  references CARD (ID) on delete cascade;
alter table CARD_MONITOR
  add constraint FK_CM_ID_DATA_CORRECT_LAST foreign key (ID_DATA_CORRECT_LAST)
  references T_DATA_CORRECT (ID) on delete set null;
alter table CARD_MONITOR
  add constraint CHK_CARD_MONITOR_SERIES
  check ((CARD_SERIES between '00' and '99') OR (CARD_SERIES between '00000' and '99999'));
alter table CARD_MONITOR
  add constraint CHK_CARD_MONITOR_TDK
  check (travel_doc_kind IN (0,1,2,3,4,5,6,7,8));

prompt
prompt Creating table CARD_MONITOR_H
prompt =============================
prompt
create table CARD_MONITOR_H
(
  id              NUMBER(38) not null,
  id_card_monitor NUMBER(38) not null,
  travel_doc_kind NUMBER(1) not null,
  bal_e_c         NUMBER,
  bal_e_f         NUMBER,
  amount_e        NUMBER,
  bal_l_c         NUMBER,
  bal_l_f         NUMBER,
  amount_l        NUMBER,
  ins_date        DATE not null,
  date_to_c       DATE not null,
  date_to_f       DATE not null,
  kind            NUMBER(1) not null,
  id_data_correct NUMBER(38),
  card_series     VARCHAR2(5) not null,
  state           NUMBER(38) not null
)
;
comment on table CARD_MONITOR_H
  is 'История изменений журнала тревожности';
comment on column CARD_MONITOR_H.id
  is 'ИД';
comment on column CARD_MONITOR_H.id_card_monitor
  is 'ИД карты';
comment on column CARD_MONITOR_H.travel_doc_kind
  is 'Тип проездного документа: 1- EP электронный кошелек, 2 - SU сезонный проездной без ограничения количества поездок, 3 - SL сезонный проездной с ограничением количества поездок, 4- ET электронные поездки (т.н. Ивановская схема,  сезонного проездного с ограничением количества поездок), 5 - CT билет для проезда в кредит (сезонного проездного без ограничения количества поездок),  6-SC ? сезонный проездной с поездками в кредит, 7-LT сезонный лимитный с фиксированным количеством поездок, 8-OL Омский электронный проездной с лимитом поездок,  0 - BL Пустой';
comment on column CARD_MONITOR_H.bal_e_c
  is 'Баланс электронного кошелька рассчитаный после изменения';
comment on column CARD_MONITOR_H.bal_e_f
  is 'Баланс электронного кошелька фактический после изменения';
comment on column CARD_MONITOR_H.amount_e
  is 'Сумма корректировки баланса электронного кошелька';
comment on column CARD_MONITOR_H.bal_l_c
  is 'Баланс поездок рассчитаный после изменения';
comment on column CARD_MONITOR_H.bal_l_f
  is 'Баланс поездок фактический после изменения';
comment on column CARD_MONITOR_H.amount_l
  is 'Сумма корректировки баланса поездок';
comment on column CARD_MONITOR_H.ins_date
  is 'Дата добавления записи';
comment on column CARD_MONITOR_H.date_to_c
  is 'Дата окончания действия (транспорт)';
comment on column CARD_MONITOR_H.date_to_f
  is 'Дата окончания действия (касса)';
comment on column CARD_MONITOR_H.kind
  is 'Тип записи (1 - мониторинг, 2 - корректировка, 3-удаление корректировки, 4-учёт старой транзакции, 5-вручную)';
comment on column CARD_MONITOR_H.id_data_correct
  is 'ИД корректировки';
comment on column CARD_MONITOR_H.card_series
  is 'Серия карты';
comment on column CARD_MONITOR_H.state
  is 'Состояние тревожности (0 – ОК,  количество тысяч - количество пропущеных тразакци, есть 100 - рублей Р>Ф, есть 200 - рублей Р<Ф, есть 10 - поездки Р>Ф, есть 20 - поездки Р<Ф, есть 1 - дата на трпнспорте > даты на кассе, есть 2 - дата на трпнспорте < даты на кассе)';
alter table CARD_MONITOR_H
  add constraint PK_CARD_MONITOR_H primary key (ID);
alter table CARD_MONITOR_H
  add constraint FK_CMH_ID_CARD_MONITOR foreign key (ID_CARD_MONITOR)
  references CARD_MONITOR (ID) on delete cascade;
alter table CARD_MONITOR_H
  add constraint FK_CMH_ID_DATA_CORRECT foreign key (ID_DATA_CORRECT)
  references T_DATA_CORRECT (ID) on delete set null;
alter table CARD_MONITOR_H
  add constraint CHK_CARD_MONITOR_H_CARD_SERIES
  check ((CARD_SERIES between '00' and '99') OR (CARD_SERIES between '00000' and '99999'));
alter table CARD_MONITOR_H
  add constraint CHK_CARD_MONITOR_H_KIND
  check (kind IN (1,2,3,4,5));
alter table CARD_MONITOR_H
  add constraint CHK_CARD_MONITOR_H_TDK
  check (travel_doc_kind IN (0,1,2,3,4,5,6,7,8));

prompt
prompt Creating table FILE_LOAD
prompt ========================
prompt
create table FILE_LOAD
(
  id                NUMBER(38) not null,
  file_kind         NUMBER(38) not null,
  file_name         VARCHAR2(255 CHAR) not null,
  load_begin        DATE default sysdate not null,
  load_end          DATE default sysdate,
  all_data          NUMBER(38) default 0,
  success_load      NUMBER(38) default 0,
  find_double       NUMBER(38) default 0,
  unsuccess_load    NUMBER(38) default 0,
  unsuccess_parse   NUMBER(38) default 0,
  convert_all_data  NUMBER(38) default 0,
  convert_success   NUMBER(38) default 0,
  convert_unsuccess NUMBER(38) default 0,
  ins_date          DATE default sysdate not null,
  ins_id_user       NUMBER(38) not null,
  upd_date          DATE default sysdate not null,
  upd_id_user       NUMBER(38) not null,
  d                 NUMBER(1) default 0 not null,
  source_code       VARCHAR2(3 CHAR),
  file_name_decode  VARCHAR2(255),
  dataformat        NUMBER(1)
)
;
comment on table FILE_LOAD
  is 'Загрузка данных из файлов';
comment on column FILE_LOAD.id
  is 'ИД';
comment on column FILE_LOAD.file_kind
  is 'Тип файла для конвертирования:
  1 - паспорт карт
  2 - социальные транспортные карты
  3 - тарифы
  4 - контрольные ленты txt
  5 - категории льгот
  6 - контрольные ленты trd
  7 - терминалы
  8 - смена статуса карты
  9 - смена льготы карты
  10 - смена статуса терминала';
comment on column FILE_LOAD.file_name
  is 'Название файла';
comment on column FILE_LOAD.load_begin
  is 'Начало загрузки';
comment on column FILE_LOAD.load_end
  is 'Конец загрузки';
comment on column FILE_LOAD.all_data
  is 'Всего данных в файле';
comment on column FILE_LOAD.success_load
  is 'Успешно загружено';
comment on column FILE_LOAD.find_double
  is 'Найдено дублей';
comment on column FILE_LOAD.unsuccess_load
  is 'Не загружено';
comment on column FILE_LOAD.unsuccess_parse
  is 'Не разобрано';
comment on column FILE_LOAD.convert_all_data
  is 'Конвертор: всего записей';
comment on column FILE_LOAD.convert_success
  is 'Конвертор: успешно сконвертировано';
comment on column FILE_LOAD.convert_unsuccess
  is 'Конвертор: с ошибками конвертирования';
comment on column FILE_LOAD.ins_date
  is 'Дата создания';
comment on column FILE_LOAD.ins_id_user
  is 'Кто создал';
comment on column FILE_LOAD.upd_date
  is 'Дата редактирования';
comment on column FILE_LOAD.upd_id_user
  is 'Кто редактировал';
comment on column FILE_LOAD.d
  is 'Признак удаления = 1';
comment on column FILE_LOAD.source_code
  is 'Код источника';
comment on column FILE_LOAD.file_name_decode
  is 'Расшифрованое имя файла';
comment on column FILE_LOAD.dataformat
  is 'Формат данных  (1, 2, 3)';
alter table FILE_LOAD
  add constraint PK_FILE_LOAD primary key (ID);
alter table FILE_LOAD
  add constraint FK_FILE_LOAD_INS_ID_USR foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table FILE_LOAD
  add constraint FK_FILE_LOAD_UPD_ID_USR foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table FILE_LOAD
  add constraint CHK_FILE_LOAD_D
  check (d in (0, 1));
alter table FILE_LOAD
  add constraint CHK_FILE_LOAD_DATAFORMAT
  check (DATAFORMAT in (1, 2, 3));
alter table FILE_LOAD
  add constraint CHK_FILE_LOAD_FILE_KIND
  check (file_kind between 0 and 11);

prompt
prompt Creating table CARD_PRIVILEGE_HISTORY
prompt =====================================
prompt
create table CARD_PRIVILEGE_HISTORY
(
  id           NUMBER(38) not null,
  id_card      NUMBER(38) not null,
  id_file_load NUMBER(38),
  date_of      DATE not null,
  date_from    DATE not null,
  id_privilege NUMBER(38) not null
)
;
comment on table CARD_PRIVILEGE_HISTORY
  is 'Журнал изменений льгот карт';
comment on column CARD_PRIVILEGE_HISTORY.id
  is 'ИД';
comment on column CARD_PRIVILEGE_HISTORY.id_card
  is 'ИД карты';
comment on column CARD_PRIVILEGE_HISTORY.id_file_load
  is 'ИД файла';
comment on column CARD_PRIVILEGE_HISTORY.date_of
  is 'Дата операции';
comment on column CARD_PRIVILEGE_HISTORY.date_from
  is 'Дата начала действия ';
comment on column CARD_PRIVILEGE_HISTORY.id_privilege
  is 'ИД льготы';
alter table CARD_PRIVILEGE_HISTORY
  add constraint PK_CARD_PRIVILEGE_HISTORY primary key (ID);
alter table CARD_PRIVILEGE_HISTORY
  add constraint UQ_CARD_PRIVILEGE_HISTORY unique (ID_CARD, DATE_FROM);
alter table CARD_PRIVILEGE_HISTORY
  add constraint FK_C_PRIV_HISTORY_ID_CARD foreign key (ID_CARD)
  references CARD (ID) on delete cascade;
alter table CARD_PRIVILEGE_HISTORY
  add constraint FK_C_PRIV_HISTORY_ID_FILE foreign key (ID_FILE_LOAD)
  references FILE_LOAD (ID) on delete set null;
alter table CARD_PRIVILEGE_HISTORY
  add constraint FK_C_PRIV_HISTORY_ID_PRIVILEGE foreign key (ID_PRIVILEGE)
  references PRIVILEGE (ID);

prompt
prompt Creating table CARD_SERIES_HISTORY
prompt ==================================
prompt
create table CARD_SERIES_HISTORY
(
  id        NUMBER(38) not null,
  id_card   NUMBER(38) not null,
  series    VARCHAR2(5) not null,
  date_of   DATE not null,
  id_t_data NUMBER(38)
)
;
comment on table CARD_SERIES_HISTORY
  is 'Журнал изменений серий карт (30 транзакция)';
comment on column CARD_SERIES_HISTORY.id
  is 'ИД';
comment on column CARD_SERIES_HISTORY.id_card
  is 'ИД карты';
comment on column CARD_SERIES_HISTORY.series
  is 'Серия';
comment on column CARD_SERIES_HISTORY.date_of
  is 'Дата изменения серии';
comment on column CARD_SERIES_HISTORY.id_t_data
  is 'ИД транзакции';
create index SI_CARD_SERIES_HISTORY on CARD_SERIES_HISTORY (ID_CARD, DATE_OF);
alter table CARD_SERIES_HISTORY
  add constraint PK_CARD_SERIES_HISTORY primary key (ID);
alter table CARD_SERIES_HISTORY
  add constraint UQ_CARD_SERIES_HISTORY unique (ID_CARD, DATE_OF, SERIES, ID_T_DATA);
alter table CARD_SERIES_HISTORY
  add constraint FK_CARD_SERIES_HISTORY_ID_CARD foreign key (ID_CARD)
  references CARD (ID) on delete cascade;
alter table CARD_SERIES_HISTORY
  add constraint CHK_CARD_SERIES_HISTORY_SERIES
  check ((SERIES between '00' and '99') OR (SERIES between '00000' and '99999'));

prompt
prompt Creating table CARD_STATE_HISTORY
prompt =================================
prompt
create table CARD_STATE_HISTORY
(
  id           NUMBER(38) not null,
  id_card      NUMBER(38) not null,
  state        NUMBER(1) not null,
  date_of      DATE not null,
  id_file_load NUMBER(38),
  date_from    DATE not null,
  date_to      DATE,
  reason       VARCHAR2(1000 CHAR),
  kind         NUMBER(3) default 105 not null,
  id_t_data    NUMBER(38)
)
;
comment on table CARD_STATE_HISTORY
  is 'Журнал изменений состояний карт';
comment on column CARD_STATE_HISTORY.id
  is 'ИД';
comment on column CARD_STATE_HISTORY.id_card
  is 'ИД карты';
comment on column CARD_STATE_HISTORY.state
  is 'Состояние карты(1-в обращении, 2-в блок списке, 3-заблокирована, 4-в деблок списке, 5-изъята, 6-чужая в блок, 7-чужая из блок, 8-Заблокирована по списку терминалов)';
comment on column CARD_STATE_HISTORY.date_of
  is 'Дата изменения состояния';
comment on column CARD_STATE_HISTORY.id_file_load
  is 'ИД файла';
comment on column CARD_STATE_HISTORY.date_from
  is 'Дата начала действия состояния';
comment on column CARD_STATE_HISTORY.date_to
  is 'Дата окончания действия состояния';
comment on column CARD_STATE_HISTORY.reason
  is 'Причина смены состояния';
comment on column CARD_STATE_HISTORY.kind
  is 'Тип операции (105 - вручную, 106 - автоматически)';
comment on column CARD_STATE_HISTORY.id_t_data
  is 'ИД транзакции';
create index SI_CARD_STATE_HISTORY on CARD_STATE_HISTORY (ID_CARD, DATE_FROM);
alter table CARD_STATE_HISTORY
  add constraint PK_CARD_STATE_HISTORY primary key (ID);
alter table CARD_STATE_HISTORY
  add constraint UQ_CARD_STATE_HISTORY unique (ID_CARD, STATE, DATE_FROM);
alter table CARD_STATE_HISTORY
  add constraint FK_C_STATE_HISTORY_ID_CARD foreign key (ID_CARD)
  references CARD (ID) on delete cascade;
alter table CARD_STATE_HISTORY
  add constraint FK_C_STATE_HISTORY_ID_FILE foreign key (ID_FILE_LOAD)
  references FILE_LOAD (ID) on delete set null;
alter table CARD_STATE_HISTORY
  add constraint CHK_C_STATE_HISTORY_KIND
  check (KIND in (5, 6, 7, 8, 9, 23, 105, 106));
alter table CARD_STATE_HISTORY
  add constraint CHK_C_STATE_HISTORY_STATE
  check (STATE in (1,2,3,4,5,6,7,8));

prompt
prompt Creating table CFG
prompt ==================
prompt
create table CFG
(
  id                NUMBER(1) default 1 not null,
  version           NUMBER(8) default 1000000 not null,
  id_region         NUMBER(38),
  change_zone_name  NUMBER(1) default 0 not null,
  soft_version      NUMBER(38),
  report_number     NUMBER(38) default 0 not null,
  archive_date      DATE,
  last_monitor_date DATE,
  period_monitor    NUMBER,
  hh_monitor        NUMBER(2) default 0 not null,
  mi_monitor        NUMBER(2) default 0 not null,
  ss_monitor        NUMBER(2) default 0 not null,
  id_owner          NUMBER
)
;
comment on table CFG
  is 'Конфигурация БД';
comment on column CFG.id
  is 'ИД';
comment on column CFG.version
  is 'Версия БД';
comment on column CFG.id_region
  is 'ИД региона - свой регион';
comment on column CFG.change_zone_name
  is 'Изменять название зоны при загрузке тарифов';
comment on column CFG.soft_version
  is 'Версия ПО';
comment on column CFG.report_number
  is 'Номер контрольного отчёта';
comment on column CFG.archive_date
  is 'Дата архивации данных';
comment on column CFG.last_monitor_date
  is 'Дата последнего мониторинга ';
comment on column CFG.period_monitor
  is 'Период мониторинга в днях';
comment on column CFG.hh_monitor
  is 'Час';
comment on column CFG.mi_monitor
  is 'Минута';
comment on column CFG.ss_monitor
  is 'Секунда';
alter table CFG
  add constraint PK_CFG primary key (ID);
alter table CFG
  add constraint FK_CFG_ID_REGION foreign key (ID_REGION)
  references PRIVILEGE_GROUP (ID);
alter table CFG
  add constraint CHK_CFG_CHANGE_ZONE_NAME
  check (CHANGE_ZONE_NAME in (0,1));
alter table CFG
  add constraint CHK_CFG_HH
  check (HH_MONITOR between 0 and 23);
alter table CFG
  add constraint CHK_CFG_ID
  check (ID = 1);
alter table CFG
  add constraint CHK_CFG_MI
  check (MI_MONITOR between 0 and 59);
alter table CFG
  add constraint CHK_CFG_SS
  check (SS_MONITOR between 0 and 59);

prompt
prompt Creating table CHANGE_SERIES
prompt ============================
prompt
create table CHANGE_SERIES
(
  id              NUMBER(38) not null,
  id_file_load    NUMBER(38) not null,
  date_of         DATE not null,
  series_from     VARCHAR2(5) not null,
  series_to       VARCHAR2(5) not null,
  card_kind       NUMBER(1) not null,
  travel_doc_kind NUMBER(1) not null
)
;
comment on table CHANGE_SERIES
  is 'Таблица смены серий';
comment on column CHANGE_SERIES.id
  is 'ИД';
comment on column CHANGE_SERIES.id_file_load
  is 'ИД Файла';
comment on column CHANGE_SERIES.date_of
  is 'Дата создания файла';
comment on column CHANGE_SERIES.series_from
  is 'Серия с';
comment on column CHANGE_SERIES.series_to
  is 'Серия на';
comment on column CHANGE_SERIES.card_kind
  is 'Тип 1-персональная, 2-на предъявителя';
comment on column CHANGE_SERIES.travel_doc_kind
  is 'Тип проездного документа: 1- EP электронный кошелек, 2 - SU сезонный проездной без ограничения количества поездок, 3 - SL сезонный проездной с ограничением количества поездок, 4- ET электронные поездки (т.н. Ивановская схема,  сезонного проездного с ограничением количества поездок), 5 - CT билет для проезда в кредит (сезонного проездного без ограничения количества поездок),  6-SC ? сезонный проездной с поездками в кредит, 0 - BL Пустой';
alter table CHANGE_SERIES
  add constraint PK_CHANGE_SERIES primary key (ID);
alter table CHANGE_SERIES
  add constraint UQ_CHANGE_SERIES unique (SERIES_FROM, SERIES_TO, CARD_KIND, TRAVEL_DOC_KIND);
alter table CHANGE_SERIES
  add constraint FK_CHANGE_SERIES_ID_FILE_LOAD foreign key (ID_FILE_LOAD)
  references FILE_LOAD (ID) on delete cascade;
alter table CHANGE_SERIES
  add constraint CHK_CHANGE_SERIES_CARD_KIND
  check (CARD_KIND in (1, 2));
alter table CHANGE_SERIES
  add constraint CHK_CHANGE_SERIES_TDK
  check (TRAVEL_DOC_KIND in (0,1,2,3,4,5,6));

prompt
prompt Creating table REF_OBL
prompt ======================
prompt
create table REF_OBL
(
  id          NUMBER(38) not null,
  name        VARCHAR2(255 CHAR) not null,
  ins_date    DATE default sysdate not null,
  ins_id_user NUMBER(38) not null,
  upd_date    DATE default sysdate not null,
  upd_id_user NUMBER(38) not null,
  d           NUMBER(1) default 0 not null
)
;
comment on table REF_OBL
  is 'Справочник. Область';
comment on column REF_OBL.id
  is 'ИД';
comment on column REF_OBL.name
  is 'Наименование';
comment on column REF_OBL.ins_date
  is 'Дата создания записи';
comment on column REF_OBL.ins_id_user
  is 'Кто создал';
comment on column REF_OBL.upd_date
  is 'Дата изменения записи';
comment on column REF_OBL.upd_id_user
  is 'Кто изменил';
comment on column REF_OBL.d
  is 'Признак удаления = 1';
alter table REF_OBL
  add constraint PK_REF_OBL primary key (ID);
alter table REF_OBL
  add constraint UQ_REF_OBL unique (NAME);
alter table REF_OBL
  add constraint FK_REF_OBL_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table REF_OBL
  add constraint FK_REF_OBL_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table REF_OBL
  add constraint CHK_REF_OBL_D
  check (D in (0,1));

prompt
prompt Creating table REF_POST
prompt =======================
prompt
create table REF_POST
(
  id          NUMBER(38) not null,
  name        VARCHAR2(255 CHAR) not null,
  ins_date    DATE default sysdate not null,
  ins_id_user NUMBER(38) not null,
  upd_date    DATE default sysdate not null,
  upd_id_user NUMBER(38) not null,
  d           NUMBER(1) default 0 not null
)
;
comment on table REF_POST
  is 'Справочник. Должность(пост)';
comment on column REF_POST.id
  is 'ИД';
comment on column REF_POST.name
  is 'Наименование';
comment on column REF_POST.ins_date
  is 'Дата создания записи';
comment on column REF_POST.ins_id_user
  is 'Кто создал';
comment on column REF_POST.upd_date
  is 'Дата изменения записи';
comment on column REF_POST.upd_id_user
  is 'Кто изменил';
comment on column REF_POST.d
  is 'Признак удаления = 1';
alter table REF_POST
  add constraint PK_REF_POST primary key (ID);
alter table REF_POST
  add constraint UQ_REF_POST unique (NAME);
alter table REF_POST
  add constraint FK_REF_POST_INS_ID_USR foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table REF_POST
  add constraint FK_REF_POST_UPD_ID_USR foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table REF_POST
  add constraint CHK_REF_POST_D
  check (d in (0,1));

prompt
prompt Creating table REF_RAYON
prompt ========================
prompt
create table REF_RAYON
(
  id          NUMBER(38) not null,
  name        VARCHAR2(255 CHAR) not null,
  ins_date    DATE default sysdate not null,
  ins_id_user NUMBER(38) not null,
  upd_date    DATE default sysdate not null,
  upd_id_user NUMBER(38) not null,
  d           NUMBER(1) default 0 not null
)
;
comment on table REF_RAYON
  is 'Справочник. Район';
comment on column REF_RAYON.id
  is 'ИД';
comment on column REF_RAYON.name
  is 'Наименование';
comment on column REF_RAYON.ins_date
  is 'Дата создания записи';
comment on column REF_RAYON.ins_id_user
  is 'Кто создал';
comment on column REF_RAYON.upd_date
  is 'Дата изменения записи';
comment on column REF_RAYON.upd_id_user
  is 'Кто изменил';
comment on column REF_RAYON.d
  is 'Признак удаления = 1';
alter table REF_RAYON
  add constraint PK_REF_RAYON primary key (ID);
alter table REF_RAYON
  add constraint UQ_REF_RAYON unique (NAME);
alter table REF_RAYON
  add constraint FK_REF_RAYON_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table REF_RAYON
  add constraint FK_REF_RAYON_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table REF_RAYON
  add constraint CHK_REF_RAYON_D
  check (D in (0,1));

prompt
prompt Creating table REF_STREET
prompt =========================
prompt
create table REF_STREET
(
  id          NUMBER(38) not null,
  name        VARCHAR2(255 CHAR) not null,
  ins_date    DATE default sysdate not null,
  ins_id_user NUMBER(38) not null,
  upd_date    DATE default sysdate not null,
  upd_id_user NUMBER(38) not null,
  d           NUMBER(1) default 0 not null
)
;
comment on table REF_STREET
  is 'Справочник. Улица';
comment on column REF_STREET.id
  is 'ИД';
comment on column REF_STREET.name
  is 'Наименование';
comment on column REF_STREET.ins_date
  is 'Дата создания записи';
comment on column REF_STREET.ins_id_user
  is 'Кто создал';
comment on column REF_STREET.upd_date
  is 'Дата изменения записи';
comment on column REF_STREET.upd_id_user
  is 'Кто изменил';
comment on column REF_STREET.d
  is 'Признак удаления = 1';
alter table REF_STREET
  add constraint PK_REF_STREET primary key (ID);
alter table REF_STREET
  add constraint UQ_REF_STREET unique (NAME);
alter table REF_STREET
  add constraint FK_REF_STREET_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table REF_STREET
  add constraint FK_REF_STREET_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table REF_STREET
  add constraint CHK_REF_STREET_D
  check (D in (0,1));

prompt
prompt Creating table REF_CITY
prompt =======================
prompt
create table REF_CITY
(
  id          NUMBER(38) not null,
  name        VARCHAR2(255 CHAR) not null,
  ins_date    DATE default sysdate not null,
  ins_id_user NUMBER(38) not null,
  upd_date    DATE default sysdate not null,
  upd_id_user NUMBER(38) not null,
  d           NUMBER(1) default 0 not null
)
;
comment on table REF_CITY
  is 'Справочник. Район';
comment on column REF_CITY.id
  is 'ИД';
comment on column REF_CITY.name
  is 'Наименование';
comment on column REF_CITY.ins_date
  is 'Дата создания записи';
comment on column REF_CITY.ins_id_user
  is 'Кто создал';
comment on column REF_CITY.upd_date
  is 'Дата изменения записи';
comment on column REF_CITY.upd_id_user
  is 'Кто изменил';
comment on column REF_CITY.d
  is 'Признак удаления = 1';
alter table REF_CITY
  add constraint PK_REF_CITY primary key (ID);
alter table REF_CITY
  add constraint UQ_REF_CITY unique (NAME);
alter table REF_CITY
  add constraint FK_REF_CITY_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table REF_CITY
  add constraint FK_REF_CITY_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table REF_CITY
  add constraint CHK_REF_CITY_D
  check (D in (0,1));

prompt
prompt Creating table REF_COUNTRY
prompt ==========================
prompt
create table REF_COUNTRY
(
  id          NUMBER(38) not null,
  name        VARCHAR2(255 CHAR) not null,
  ins_date    DATE default sysdate not null,
  ins_id_user NUMBER(38) not null,
  upd_date    DATE default sysdate not null,
  upd_id_user NUMBER(38) not null,
  d           NUMBER(1) default 0 not null
)
;
comment on table REF_COUNTRY
  is 'Справочник. Страна';
comment on column REF_COUNTRY.id
  is 'ИД';
comment on column REF_COUNTRY.name
  is 'Наименование';
comment on column REF_COUNTRY.ins_date
  is 'Дата создания записи';
comment on column REF_COUNTRY.ins_id_user
  is 'Кто создал';
comment on column REF_COUNTRY.upd_date
  is 'Дата изменения записи';
comment on column REF_COUNTRY.upd_id_user
  is 'Кто изменил';
comment on column REF_COUNTRY.d
  is 'Признак удаления = 1';
alter table REF_COUNTRY
  add constraint PK_REF_COUNTRY primary key (ID);
alter table REF_COUNTRY
  add constraint UQ_REF_COUNTRY unique (NAME);
alter table REF_COUNTRY
  add constraint FK_REF_COUNTRY_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table REF_COUNTRY
  add constraint FK_REF_COUNTRY_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table REF_COUNTRY
  add constraint CHK_REF_COUNTRY_D
  check (D in (0,1));

prompt
prompt Creating table REF_BANK
prompt =======================
prompt
create table REF_BANK
(
  id              NUMBER(38) not null,
  name            VARCHAR2(255 CHAR) not null,
  location        VARCHAR2(255 CHAR),
  bic             VARCHAR2(20 CHAR),
  corresp_account VARCHAR2(20 CHAR),
  post_address    VARCHAR2(255 CHAR),
  phone           VARCHAR2(255 CHAR),
  ins_date        DATE default sysdate not null,
  upd_date        DATE default sysdate not null,
  d               NUMBER(1) default 0 not null,
  ins_id_user     NUMBER(38) not null,
  upd_id_user     NUMBER(38) not null
)
;
comment on table REF_BANK
  is 'Справочник. Банк';
comment on column REF_BANK.id
  is 'Идентификатор';
comment on column REF_BANK.name
  is 'Наименование';
comment on column REF_BANK.location
  is 'Местоположение';
comment on column REF_BANK.bic
  is 'БИК';
comment on column REF_BANK.corresp_account
  is 'Корреспондентский счет';
comment on column REF_BANK.post_address
  is 'Почтовый адрес';
comment on column REF_BANK.phone
  is 'Телефоны';
comment on column REF_BANK.ins_date
  is 'Дата создания записи';
comment on column REF_BANK.upd_date
  is 'Дата изменения записи';
comment on column REF_BANK.d
  is 'Признак удаления = 1';
comment on column REF_BANK.ins_id_user
  is 'Кто создал';
comment on column REF_BANK.upd_id_user
  is 'Кто изменил';
create index SI_REF_BANK_NAME on REF_BANK (NAME);
alter table REF_BANK
  add constraint PK_REF_BANK primary key (ID);
alter table REF_BANK
  add constraint FK_REF_BANK_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table REF_BANK
  add constraint FK_REF_BANK_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table REF_BANK
  add constraint CHK_REF_BANK_D
  check (d in (0,1));

prompt
prompt Creating table REF_JPERSON
prompt ==========================
prompt
create table REF_JPERSON
(
  id                 NUMBER(38) not null,
  name               VARCHAR2(255 CHAR) not null,
  inn                VARCHAR2(20 CHAR),
  kpp                VARCHAR2(20 CHAR),
  settlement_account VARCHAR2(20 CHAR),
  id_bank_account    NUMBER(38),
  id_bank_corresp    NUMBER(38),
  director           VARCHAR2(255 CHAR),
  accountant_general VARCHAR2(255 CHAR),
  phone              VARCHAR2(12 CHAR),
  fax                VARCHAR2(12 CHAR),
  e_mail             VARCHAR2(255 CHAR),
  description        VARCHAR2(255 CHAR),
  d                  NUMBER(1) default 0 not null,
  ins_date           DATE default sysdate not null,
  upd_date           DATE default sysdate not null,
  ins_id_user        NUMBER(38) not null,
  upd_id_user        NUMBER(38) not null,
  jur_adr_index      VARCHAR2(10 CHAR),
  jur_adr_country    NUMBER(38),
  jur_adr_obl        NUMBER(38),
  jur_adr_rayon      NUMBER(38),
  jur_adr_city       NUMBER(38),
  jur_adr_street     NUMBER(38),
  jur_adr_house      VARCHAR2(50 CHAR),
  jur_adr_build      VARCHAR2(50 CHAR),
  jur_adr_flat       VARCHAR2(50 CHAR),
  post_adr_index     VARCHAR2(10 CHAR),
  post_adr_country   NUMBER(38),
  post_adr_obl       NUMBER(38),
  post_adr_rayon     NUMBER(38),
  post_adr_city      NUMBER(38),
  post_adr_street    NUMBER(38),
  post_adr_house     VARCHAR2(50 CHAR),
  post_adr_build     VARCHAR2(50 CHAR),
  post_adr_flat      VARCHAR2(50 CHAR),
  id_director_post   NUMBER(38),
  boss               VARCHAR2(255 CHAR),
  kbe                VARCHAR2(3 CHAR)
)
;
comment on table REF_JPERSON
  is 'Справочник. Юридические лица';
comment on column REF_JPERSON.id
  is 'ИД';
comment on column REF_JPERSON.name
  is 'Наименование';
comment on column REF_JPERSON.inn
  is 'ИНН';
comment on column REF_JPERSON.kpp
  is 'КПП';
comment on column REF_JPERSON.settlement_account
  is 'Расчетный счет';
comment on column REF_JPERSON.id_bank_account
  is 'Банк';
comment on column REF_JPERSON.id_bank_corresp
  is 'Банк-корреспондент';
comment on column REF_JPERSON.director
  is 'Первое лицо';
comment on column REF_JPERSON.accountant_general
  is 'Главный бухгалтер';
comment on column REF_JPERSON.phone
  is 'Телефон';
comment on column REF_JPERSON.fax
  is 'Факс';
comment on column REF_JPERSON.e_mail
  is 'е-майл';
comment on column REF_JPERSON.description
  is 'Примечание';
comment on column REF_JPERSON.d
  is 'Признак удаления = 1';
comment on column REF_JPERSON.ins_date
  is 'Дата создания записи';
comment on column REF_JPERSON.upd_date
  is 'Дата изменения записи';
comment on column REF_JPERSON.ins_id_user
  is 'Кто создал';
comment on column REF_JPERSON.upd_id_user
  is 'Кто изменил';
comment on column REF_JPERSON.jur_adr_index
  is 'Юр.адрес: индекс';
comment on column REF_JPERSON.jur_adr_country
  is 'Юр.адрес: страна';
comment on column REF_JPERSON.jur_adr_obl
  is 'Юр.адрес: область';
comment on column REF_JPERSON.jur_adr_rayon
  is 'Юр.адрес: район';
comment on column REF_JPERSON.jur_adr_city
  is 'Юр.адрес: город';
comment on column REF_JPERSON.jur_adr_street
  is 'Юр.адрес: улица';
comment on column REF_JPERSON.jur_adr_house
  is 'Юр.адрес: дом';
comment on column REF_JPERSON.jur_adr_build
  is 'Юр.адрес: корпус';
comment on column REF_JPERSON.jur_adr_flat
  is 'Юр.адрес: квартира';
comment on column REF_JPERSON.post_adr_index
  is 'Почтовый адрес: индекс';
comment on column REF_JPERSON.post_adr_country
  is 'Почтовый адрес: страна';
comment on column REF_JPERSON.post_adr_obl
  is 'Почтовый адрес: область';
comment on column REF_JPERSON.post_adr_rayon
  is 'Почтовый адрес: район';
comment on column REF_JPERSON.post_adr_city
  is 'Почтовый адрес: город';
comment on column REF_JPERSON.post_adr_street
  is 'Почтовый адрес: улица';
comment on column REF_JPERSON.post_adr_house
  is 'Почтовый адрес: дом';
comment on column REF_JPERSON.post_adr_build
  is 'Почтовый адрес: корпус';
comment on column REF_JPERSON.post_adr_flat
  is 'Почтовый адрес: квартира';
comment on column REF_JPERSON.id_director_post
  is 'Название должности первого лица';
comment on column REF_JPERSON.boss
  is 'Хозяин (владелец)';
comment on column REF_JPERSON.kbe
  is 'Код бенефициара';
create index SI_REF_JPERSON_NAME on REF_JPERSON (NAME);
alter table REF_JPERSON
  add constraint PK_REF_JPERSON primary key (ID);
alter table REF_JPERSON
  add constraint FK_REF_JPERSON_ID_BANK_ACCOUNT foreign key (ID_BANK_ACCOUNT)
  references REF_BANK (ID);
alter table REF_JPERSON
  add constraint FK_REF_JPERSON_ID_BANK_CORRESP foreign key (ID_BANK_CORRESP)
  references REF_BANK (ID);
alter table REF_JPERSON
  add constraint FK_REF_JPERSON_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table REF_JPERSON
  add constraint FK_REF_JPERSON_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table REF_JPERSON
  add constraint FK_REF_JP_ID_DIRECTOR_POST foreign key (ID_DIRECTOR_POST)
  references REF_POST (ID);
alter table REF_JPERSON
  add constraint FK_REF_JP_JUR_ADR_CITY foreign key (JUR_ADR_CITY)
  references REF_CITY (ID);
alter table REF_JPERSON
  add constraint FK_REF_JP_JUR_ADR_COUNTRY foreign key (JUR_ADR_COUNTRY)
  references REF_COUNTRY (ID);
alter table REF_JPERSON
  add constraint FK_REF_JP_JUR_ADR_OBL foreign key (JUR_ADR_OBL)
  references REF_OBL (ID);
alter table REF_JPERSON
  add constraint FK_REF_JP_JUR_ADR_RAYON foreign key (JUR_ADR_RAYON)
  references REF_RAYON (ID);
alter table REF_JPERSON
  add constraint FK_REF_JP_JUR_ADR_STREET foreign key (JUR_ADR_STREET)
  references REF_STREET (ID);
alter table REF_JPERSON
  add constraint FK_REF_JP_POST_ADR_CITY foreign key (POST_ADR_CITY)
  references REF_CITY (ID);
alter table REF_JPERSON
  add constraint FK_REF_JP_POST_ADR_COUNTRY foreign key (POST_ADR_COUNTRY)
  references REF_COUNTRY (ID);
alter table REF_JPERSON
  add constraint FK_REF_JP_POST_ADR_OBL foreign key (POST_ADR_OBL)
  references REF_OBL (ID);
alter table REF_JPERSON
  add constraint FK_REF_JP_POST_ADR_RAYON foreign key (POST_ADR_RAYON)
  references REF_RAYON (ID);
alter table REF_JPERSON
  add constraint FK_REF_JP_POST_ADR_STREET foreign key (POST_ADR_STREET)
  references REF_STREET (ID);

prompt
prompt Creating table OPERATOR
prompt =======================
prompt
create table OPERATOR
(
  id                 NUMBER(38) not null,
  id_privilege_group NUMBER(38) not null,
  code               VARCHAR2(4 CHAR) default '0000' not null,
  role               NUMBER(1) default 1 not null,
  name               VARCHAR2(255 CHAR) not null,
  id_jperson         NUMBER(38),
  ins_date           DATE default sysdate not null,
  ins_id_user        NUMBER(38) not null,
  upd_date           DATE default sysdate not null,
  upd_id_user        NUMBER(38) not null,
  d                  NUMBER(1) default 0 not null
)
;
comment on table OPERATOR
  is 'Транспортный оператор/предприятие-агент';
comment on column OPERATOR.id
  is 'ИД';
comment on column OPERATOR.id_privilege_group
  is 'ИД региона';
comment on column OPERATOR.code
  is 'Код';
comment on column OPERATOR.role
  is 'Роль: 1-транспортный оператор, 2-агент по продажам';
comment on column OPERATOR.name
  is 'Наименование';
comment on column OPERATOR.id_jperson
  is 'ИД юр.лица';
comment on column OPERATOR.ins_date
  is 'Дата создания';
comment on column OPERATOR.ins_id_user
  is 'Кто создал';
comment on column OPERATOR.upd_date
  is 'Дата редактирования';
comment on column OPERATOR.upd_id_user
  is 'Кто редактировал';
comment on column OPERATOR.d
  is 'Признак удаления=1';
alter table OPERATOR
  add constraint PK_OPERATOR primary key (ID);
alter table OPERATOR
  add constraint UQ_OPERATOR unique (ID_PRIVILEGE_GROUP, CODE, ROLE);
alter table OPERATOR
  add constraint FK_OPERATOR_ID_PRIVILEGE_GROUP foreign key (ID_PRIVILEGE_GROUP)
  references PRIVILEGE_GROUP (ID);
alter table OPERATOR
  add constraint FK_OPERATOR_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table OPERATOR
  add constraint FK_OPERATOR_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table OPERATOR
  add constraint FK_REF_JPERSON foreign key (ID_JPERSON)
  references REF_JPERSON (ID);
alter table OPERATOR
  add constraint CHK_OPERATOR_CODE
  check (code between '0000' and '9999');
alter table OPERATOR
  add constraint CHK_OPERATOR_D
  check (d in (0,1));
alter table OPERATOR
  add constraint CHK_OPERATOR_ROLE
  check (role in (1,2));

prompt
prompt Creating table DIVISION
prompt =======================
prompt
create table DIVISION
(
  id          NUMBER(38) not null,
  id_operator NUMBER(38) not null,
  code        VARCHAR2(4 CHAR) default '0000' not null,
  name        VARCHAR2(255 CHAR) not null,
  id_jperson  NUMBER(38),
  ins_date    DATE default sysdate not null,
  ins_id_user NUMBER(38) not null,
  upd_date    DATE default sysdate not null,
  upd_id_user NUMBER(38) not null,
  d           NUMBER(1) default 0 not null,
  phone       VARCHAR2(255 CHAR),
  fax         VARCHAR2(255 CHAR),
  e_mail      VARCHAR2(255 CHAR),
  adr_index   VARCHAR2(10 CHAR),
  description VARCHAR2(255 CHAR),
  director    VARCHAR2(255 CHAR),
  adr_country NUMBER(38),
  adr_obl     NUMBER(38),
  adr_rayon   NUMBER(38),
  adr_city    NUMBER(38),
  adr_street  NUMBER(38),
  adr_house   VARCHAR2(50 CHAR),
  adr_build   VARCHAR2(50 CHAR),
  adr_flat    VARCHAR2(50 CHAR)
)
;
comment on table DIVISION
  is 'Подразделение транспортного оператора/предприятия-агента';
comment on column DIVISION.id
  is 'ИД';
comment on column DIVISION.id_operator
  is 'ИД оператора';
comment on column DIVISION.code
  is 'Код';
comment on column DIVISION.name
  is 'Наименование';
comment on column DIVISION.id_jperson
  is 'ИД юр.лица';
comment on column DIVISION.ins_date
  is 'Дата создания';
comment on column DIVISION.ins_id_user
  is 'Кто создал';
comment on column DIVISION.upd_date
  is 'Дата редактирования';
comment on column DIVISION.upd_id_user
  is 'Кто редактировал';
comment on column DIVISION.d
  is 'Признак удаления=1';
comment on column DIVISION.phone
  is 'Телефон';
comment on column DIVISION.fax
  is 'Факс';
comment on column DIVISION.e_mail
  is 'e-mail';
comment on column DIVISION.adr_index
  is 'Почтовый индекс';
comment on column DIVISION.description
  is 'Примечание';
comment on column DIVISION.director
  is 'Директор';
comment on column DIVISION.adr_country
  is 'Страна';
comment on column DIVISION.adr_obl
  is 'Область';
comment on column DIVISION.adr_rayon
  is 'Район';
comment on column DIVISION.adr_city
  is 'Город';
comment on column DIVISION.adr_street
  is 'Улица';
comment on column DIVISION.adr_house
  is 'Дом ';
comment on column DIVISION.adr_build
  is 'Корпус, строение';
comment on column DIVISION.adr_flat
  is 'Квартира (офис)';
alter table DIVISION
  add constraint PK_DIVISION primary key (ID);
alter table DIVISION
  add constraint UQ_DIVISION unique (ID_OPERATOR, CODE);
alter table DIVISION
  add constraint FK_DIVISION_ADR_CITY foreign key (ADR_CITY)
  references REF_CITY (ID);
alter table DIVISION
  add constraint FK_DIVISION_ADR_COUNTRY foreign key (ADR_COUNTRY)
  references REF_COUNTRY (ID);
alter table DIVISION
  add constraint FK_DIVISION_ADR_OBL foreign key (ADR_OBL)
  references REF_OBL (ID);
alter table DIVISION
  add constraint FK_DIVISION_ADR_RAYON foreign key (ADR_RAYON)
  references REF_RAYON (ID);
alter table DIVISION
  add constraint FK_DIVISION_ADR_STREET foreign key (ADR_STREET)
  references REF_STREET (ID);
alter table DIVISION
  add constraint FK_DIVISION_ID_OPERATOR foreign key (ID_OPERATOR)
  references OPERATOR (ID) on delete cascade;
alter table DIVISION
  add constraint FK_DIVISION_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table DIVISION
  add constraint FK_DIVISION_REF_JPERSON foreign key (ID_JPERSON)
  references REF_JPERSON (ID);
alter table DIVISION
  add constraint FK_DIVISION_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table DIVISION
  add constraint CHK_DIVISION_CODE
  check (code between '0000' and '9999');
alter table DIVISION
  add constraint CHK_DIVISION_D
  check (d in (0,1));

prompt
prompt Creating table REF_CODE_MSG
prompt ===========================
prompt
create table REF_CODE_MSG
(
  id          NUMBER(38) not null,
  code        VARCHAR2(3 CHAR) not null,
  name        VARCHAR2(255 CHAR) not null,
  ins_date    DATE default sysdate not null,
  ins_id_user NUMBER(38) not null,
  upd_date    DATE default sysdate not null,
  upd_id_user NUMBER(38) not null,
  d           NUMBER(1) default 0 not null
)
;
comment on table REF_CODE_MSG
  is 'Справочник кодов сообщений';
comment on column REF_CODE_MSG.id
  is 'ИД';
comment on column REF_CODE_MSG.code
  is 'Код сообщения';
comment on column REF_CODE_MSG.name
  is 'Описание кода сообщения';
comment on column REF_CODE_MSG.ins_date
  is 'Дата создания записи';
comment on column REF_CODE_MSG.ins_id_user
  is 'Кто создал';
comment on column REF_CODE_MSG.upd_date
  is 'Дата изменения записи';
comment on column REF_CODE_MSG.upd_id_user
  is 'Кто изменил';
comment on column REF_CODE_MSG.d
  is 'Признак удаления = 1';
alter table REF_CODE_MSG
  add constraint PK_REF_CODE_MSG primary key (ID);
alter table REF_CODE_MSG
  add constraint UN_REF_CODE_MSG_CODE unique (CODE);
alter table REF_CODE_MSG
  add constraint FK_REF_CODE_MSG_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table REF_CODE_MSG
  add constraint FK_REF_CODE_MSG_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table REF_CODE_MSG
  add constraint CHK_REF_CODE_MSG_D
  check (d in (0, 1));

prompt
prompt Creating table DIV_AGREE
prompt ========================
prompt
create table DIV_AGREE
(
  id          NUMBER(38) not null,
  id_division NUMBER(38) not null,
  id_code_msg NUMBER(38) not null,
  num_agree   VARCHAR2(40 CHAR) not null,
  date_agree  DATE,
  ins_date    DATE default SYSDATE not null,
  ins_id_user NUMBER(38) default 100000001 not null,
  upd_date    DATE default SYSDATE not null,
  upd_id_user NUMBER(38) default 100000001 not null,
  d           NUMBER(1) default 0 not null
)
;
comment on table DIV_AGREE
  is 'Договора для подразделений по кодам сообщений';
comment on column DIV_AGREE.id
  is 'ИД';
comment on column DIV_AGREE.id_division
  is 'ИД подразделения';
comment on column DIV_AGREE.id_code_msg
  is 'ИД кода сообщения';
comment on column DIV_AGREE.num_agree
  is 'Номер договора';
comment on column DIV_AGREE.date_agree
  is 'Дата договора';
comment on column DIV_AGREE.ins_date
  is 'Дата добавлния';
comment on column DIV_AGREE.ins_id_user
  is 'Кто добавил';
comment on column DIV_AGREE.upd_date
  is 'Дата изменения';
comment on column DIV_AGREE.upd_id_user
  is 'Кто изменил';
comment on column DIV_AGREE.d
  is 'Признак удаления = 1';
alter table DIV_AGREE
  add constraint PK_DIV_AGREE primary key (ID);
alter table DIV_AGREE
  add constraint UQ_DIV_AGREE unique (ID_DIVISION, ID_CODE_MSG);
alter table DIV_AGREE
  add constraint FK_D_A_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table DIV_AGREE
  add constraint FK_D_A_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table DIV_AGREE
  add constraint FK_DIV_AGREE_CODE_MSG foreign key (ID_CODE_MSG)
  references REF_CODE_MSG (ID);
alter table DIV_AGREE
  add constraint FK_DIV_AGREE_DIVISION foreign key (ID_DIVISION)
  references DIVISION (ID);
alter table DIV_AGREE
  add constraint CHK_DIV_AGREE_D
  check (d in (0, 1));

prompt
prompt Creating table EVENT_LOG
prompt ========================
prompt
create table EVENT_LOG
(
  id           NUMBER(38) not null,
  name         VARCHAR2(255 CHAR) not null,
  kind         NUMBER(1) not null,
  state        NUMBER(1) not null,
  ins_date     TIMESTAMP(6) not null,
  ins_id_user  NUMBER(38) not null,
  upd_date     DATE not null,
  upd_id_user  NUMBER(38) not null,
  e_mail       VARCHAR2(255 CHAR),
  id_file_load NUMBER(32)
)
;
comment on table EVENT_LOG
  is 'Журнал событий';
comment on column EVENT_LOG.id
  is 'ИД';
comment on column EVENT_LOG.name
  is 'Наименование события';
comment on column EVENT_LOG.kind
  is 'Тип события (1-ошибка, 2-предупреждение, 3-информация)';
comment on column EVENT_LOG.state
  is 'Состояние события(0-новое, 1-отправлено оператору)';
comment on column EVENT_LOG.ins_date
  is 'Дата создания';
comment on column EVENT_LOG.ins_id_user
  is 'Кто создал';
comment on column EVENT_LOG.upd_date
  is 'Дата изменения';
comment on column EVENT_LOG.upd_id_user
  is 'Кто изменил';
comment on column EVENT_LOG.e_mail
  is 'e-mail получателя';
comment on column EVENT_LOG.id_file_load
  is 'Файл - источник';
alter table EVENT_LOG
  add constraint PK_EVENT_LOG primary key (ID);
alter table EVENT_LOG
  add constraint FK_EVENT_LOG_ID_FILE_LOAD foreign key (ID_FILE_LOAD)
  references FILE_LOAD (ID) on delete cascade;
alter table EVENT_LOG
  add constraint FK_EVENT_LOG_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table EVENT_LOG
  add constraint FK_EVENT_LOG_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table EVENT_LOG
  add constraint CHK_EVENT_LOG_KIND
  check (KIND in (1,2,3));
alter table EVENT_LOG
  add constraint CHK_EVENT_LOG_STATE
  check (STATE in (0, 1));

prompt
prompt Creating table FILE_EXP
prompt =======================
prompt
create table FILE_EXP
(
  id          NUMBER(38) not null,
  date_exp    DATE default sysdate not null,
  black_cnt   NUMBER(38) default 0 not null,
  white_cnt   NUMBER(38) default 0 not null,
  is_manually NUMBER(1) default 0 not null,
  ins_date    DATE default sysdate not null,
  ins_id_user NUMBER(38) not null,
  upd_date    DATE default sysdate not null,
  upd_id_user NUMBER(38) not null,
  d           NUMBER(1) default 0 not null,
  listtype    INTEGER
)
;
comment on table FILE_EXP
  is 'Выгрузка черного и белого списков';
comment on column FILE_EXP.id
  is 'ИД';
comment on column FILE_EXP.date_exp
  is 'Дата выгрузки';
comment on column FILE_EXP.black_cnt
  is 'Количество в ЧС';
comment on column FILE_EXP.white_cnt
  is 'Количество в БД';
comment on column FILE_EXP.is_manually
  is 'Подготовлен вручную';
comment on column FILE_EXP.ins_date
  is 'Дата создания';
comment on column FILE_EXP.ins_id_user
  is 'Кто создал';
comment on column FILE_EXP.upd_date
  is 'Дата изменения';
comment on column FILE_EXP.upd_id_user
  is 'Кто изменил ';
comment on column FILE_EXP.d
  is 'Признак удаления (1)';
comment on column FILE_EXP.listtype
  is 'Тип листа (0 - карта, 1 - терминал)';
alter table FILE_EXP
  add constraint PK_FILE_EXP primary key (ID);
alter table FILE_EXP
  add constraint FK_FILE_EXP_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table FILE_EXP
  add constraint FK_FILE_EXP_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table FILE_EXP
  add constraint CHK_FILE_EXP_D
  check (d in (0,1));
alter table FILE_EXP
  add constraint CHK_FILE_EXP_IS_MANUALLY
  check (IS_MANUALLY in (0,1));
alter table FILE_EXP
  add constraint CHK_FILE_EXP_LISTTYPE
  check (LISTTYPE in (0, 1));

prompt
prompt Creating table FILELOADER_CFG
prompt =============================
prompt
create table FILELOADER_CFG
(
  backup_fldr      VARCHAR2(255) default '.\backup\' not null,
  bad_fldr         VARCHAR2(255) default '.\bad\' not null,
  source_fldr      VARCHAR2(255) default '.\source\' not null,
  temp_fldr        VARCHAR2(255) default '.\temp\' not null,
  unknow_fldr      VARCHAR2(255) default '.\unknown\' not null,
  min_route_time   NUMBER default -1 not null,
  save_tmp_files   NUMBER default 1 not null,
  max_thread_count NUMBER default 5 not null
)
;

prompt
prompt Creating table SCHED_TRIGGER
prompt ============================
prompt
create table SCHED_TRIGGER
(
  id          NUMBER not null,
  seconds     VARCHAR2(255),
  minutes     VARCHAR2(255),
  hours       VARCHAR2(255),
  dayofmonth  VARCHAR2(255),
  month       VARCHAR2(255),
  dayofweek   VARCHAR2(255),
  starttime   DATE,
  endtime     DATE,
  ins_date    DATE default SYSDATE not null,
  ins_id_user NUMBER(38) not null,
  upd_date    DATE default SYSDATE not null,
  upd_id_user NUMBER(38) not null,
  name        VARCHAR2(255),
  descr       VARCHAR2(1000),
  firetype    NUMBER
)
;
comment on table SCHED_TRIGGER
  is 'Описание триггера, когда его запускать и через какокй интервал выполнять';
comment on column SCHED_TRIGGER.seconds
  is 'Cron Trig. Seconds';
comment on column SCHED_TRIGGER.minutes
  is 'Cron Trig. Minutes';
comment on column SCHED_TRIGGER.hours
  is 'Cron Trig. Hours';
comment on column SCHED_TRIGGER.dayofmonth
  is 'Cron Trig. Day-of-Month';
comment on column SCHED_TRIGGER.month
  is 'Cron Trig. Month';
comment on column SCHED_TRIGGER.dayofweek
  is 'Cron Trig. Day-of-Week';
comment on column SCHED_TRIGGER.starttime
  is 'Simple Trig. Время запуска';
comment on column SCHED_TRIGGER.endtime
  is 'Simple Trig. Время окончания';
comment on column SCHED_TRIGGER.ins_date
  is 'Дата добавления';
comment on column SCHED_TRIGGER.ins_id_user
  is 'Пользователь добавивший';
comment on column SCHED_TRIGGER.upd_date
  is 'Дата редактирования';
comment on column SCHED_TRIGGER.upd_id_user
  is 'Пользователь редактировавший';
comment on column SCHED_TRIGGER.name
  is 'Название триггера';
comment on column SCHED_TRIGGER.descr
  is 'Описание триггера';
comment on column SCHED_TRIGGER.firetype
  is 'тип запуска триггера';
alter table SCHED_TRIGGER
  add constraint SCHED_TRIGGER_PK primary key (ID);

prompt
prompt Creating table JOB_LIST
prompt =======================
prompt
create table JOB_LIST
(
  id          NUMBER not null,
  taskid      NUMBER not null,
  triggerid   NUMBER not null,
  ins_date    DATE default localtimestamp,
  ins_id_user NUMBER,
  upd_date    DATE default localtimestamp,
  upd_id_user NUMBER,
  name        VARCHAR2(255),
  descr       VARCHAR2(255)
)
;
comment on table JOB_LIST
  is 'Таблица хранящая список всех заданий добавленных в планировщик';
comment on column JOB_LIST.id
  is 'Идентификатор';
comment on column JOB_LIST.taskid
  is 'задание';
comment on column JOB_LIST.triggerid
  is 'триггер';
comment on column JOB_LIST.ins_date
  is 'Дата добавления';
comment on column JOB_LIST.ins_id_user
  is 'Пользователь добавивший';
comment on column JOB_LIST.upd_date
  is 'Дата редактирования';
comment on column JOB_LIST.upd_id_user
  is 'Пользователь редактировавший';
comment on column JOB_LIST.name
  is 'Название задачи';
comment on column JOB_LIST.descr
  is 'Описание задачи';
alter table JOB_LIST
  add constraint JOB_LIST_PK primary key (ID);
alter table JOB_LIST
  add constraint JOB_LIST_R02 foreign key (TRIGGERID)
  references SCHED_TRIGGER (ID);

prompt
prompt Creating table SYS_USER
prompt =======================
prompt
create table SYS_USER
(
  id          NUMBER(38) not null,
  name        VARCHAR2(100) not null,
  pass        VARCHAR2(32),
  fullname    VARCHAR2(255),
  description VARCHAR2(255),
  ins_date    DATE default sysdate,
  ins_id_user NUMBER(38),
  upd_date    DATE default sysdate,
  upd_id_user NUMBER(38),
  d           NUMBER(1) default 0 not null
)
;
comment on table SYS_USER
  is 'Пользователи';
comment on column SYS_USER.id
  is 'Идентификатор';
comment on column SYS_USER.name
  is 'Имя';
comment on column SYS_USER.pass
  is 'Хэш пароля';
comment on column SYS_USER.fullname
  is 'Полное имя';
comment on column SYS_USER.description
  is 'Описание';
comment on column SYS_USER.ins_date
  is 'Дата создания записи';
comment on column SYS_USER.ins_id_user
  is 'Кто создал';
comment on column SYS_USER.upd_date
  is 'Дата изменения записи';
comment on column SYS_USER.upd_id_user
  is 'Кто изменил';
comment on column SYS_USER.d
  is 'Признак удаления';
alter table SYS_USER
  add constraint PK_SYS_USER primary key (ID);
alter table SYS_USER
  add constraint UI_SYS_USER_NAME unique (NAME);
alter table SYS_USER
  add constraint FK_SYS_USER_ID_INS_USER foreign key (INS_ID_USER)
  references SYS_USER (ID);
alter table SYS_USER
  add constraint FK_SYS_USER_ID_UPD_USER foreign key (UPD_ID_USER)
  references SYS_USER (ID);
alter table SYS_USER
  add constraint CHK_SYS_USER_D
  check (D in (0,1));

prompt
prompt Creating table JOB_SETTINGS
prompt ===========================
prompt
create table JOB_SETTINGS
(
  id          NUMBER not null,
  jobid       NUMBER not null,
  key         VARCHAR2(255) not null,
  value       VARCHAR2(2255),
  ins_id_user NUMBER not null,
  ins_date    DATE default localtimestamp not null,
  bvalue      BLOB
)
;
comment on table JOB_SETTINGS
  is 'Таблица содержащая настройки заданий';
comment on column JOB_SETTINGS.id
  is 'Идентификатор';
comment on column JOB_SETTINGS.jobid
  is 'job к которому относится данная настройка';
comment on column JOB_SETTINGS.key
  is 'ключ, по которому идентефицируется натсройка';
comment on column JOB_SETTINGS.value
  is 'значение настройки';
comment on column JOB_SETTINGS.ins_id_user
  is 'пользователь добавивший настройку';
comment on column JOB_SETTINGS.ins_date
  is 'Дата добавления';
comment on column JOB_SETTINGS.bvalue
  is 'Р—РЅР°С‡РµРЅРёРµ РЅР°СЃС‚СЂРѕР№РєРё BLOB';
alter table JOB_SETTINGS
  add constraint JOB_SETTINGS_PK primary key (ID);
alter table JOB_SETTINGS
  add constraint JOB_SETTINGS_R01 foreign key (JOBID)
  references JOB_LIST (ID);
alter table JOB_SETTINGS
  add constraint JOB_SETTINGS_R02 foreign key (INS_ID_USER)
  references SYS_USER (ID);

prompt
prompt Creating table REF_TRANSPORT_MODE
prompt =================================
prompt
create table REF_TRANSPORT_MODE
(
  id          NUMBER(38) not null,
  code        VARCHAR2(30 CHAR) not null,
  name        VARCHAR2(255 CHAR),
  ins_date    DATE default SYSDATE not null,
  ins_id_user NUMBER(38) not null,
  upd_date    DATE default SYSDATE not null,
  upd_id_user NUMBER(38) not null,
  d           NUMBER(1) default 0 not null
)
;
comment on table REF_TRANSPORT_MODE
  is 'Справочник виды транспорта';
comment on column REF_TRANSPORT_MODE.id
  is 'ИД';
comment on column REF_TRANSPORT_MODE.code
  is 'Код';
comment on column REF_TRANSPORT_MODE.name
  is 'Наименование';
comment on column REF_TRANSPORT_MODE.ins_date
  is 'Дата создания записи';
comment on column REF_TRANSPORT_MODE.ins_id_user
  is 'Кто создал';
comment on column REF_TRANSPORT_MODE.upd_date
  is 'Дата изменения записи';
comment on column REF_TRANSPORT_MODE.upd_id_user
  is 'Кто изменил';
comment on column REF_TRANSPORT_MODE.d
  is 'Признак удаления = 1';
alter table REF_TRANSPORT_MODE
  add constraint PK_REF_TRANSPORT_MODE primary key (ID);
alter table REF_TRANSPORT_MODE
  add constraint UN_REF_TRANSPORT_MODE_CODE unique (CODE);
alter table REF_TRANSPORT_MODE
  add constraint FK_REF_TRN_MODE_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table REF_TRANSPORT_MODE
  add constraint FK_REF_TRN_MODE_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table REF_TRANSPORT_MODE
  add constraint CHK_REF_TRANSPORT_MODE_D
  check (d IN (0, 1));

prompt
prompt Creating table REP_GROUP
prompt ========================
prompt
create table REP_GROUP
(
  id          NUMBER(38) not null,
  id_parent   NUMBER(38),
  name        VARCHAR2(255 CHAR),
  ins_date    DATE default SYSDATE not null,
  ins_id_user NUMBER(38) not null,
  upd_date    DATE default SYSDATE not null,
  upd_id_user NUMBER(38) not null,
  d           NUMBER(1) default 0 not null
)
;
comment on table REP_GROUP
  is 'Группа отчётов';
comment on column REP_GROUP.id
  is 'ИД';
comment on column REP_GROUP.id_parent
  is 'ИД родительской группы';
comment on column REP_GROUP.name
  is 'Название группы';
comment on column REP_GROUP.ins_date
  is 'Дата добавлния';
comment on column REP_GROUP.ins_id_user
  is 'Кто добавил';
comment on column REP_GROUP.upd_date
  is 'Дата изменения';
comment on column REP_GROUP.upd_id_user
  is 'Кто изменил';
comment on column REP_GROUP.d
  is 'Признак удаления = 1';
alter table REP_GROUP
  add constraint PK_REP_GROUP primary key (ID);
alter table REP_GROUP
  add constraint UQ_REP_GROUP_NAME unique (NAME, ID_PARENT);
alter table REP_GROUP
  add constraint FK_ID_PARENT_REP_GROUP foreign key (ID_PARENT)
  references REP_GROUP (ID) on delete cascade;
alter table REP_GROUP
  add constraint FK_REP_GROUP_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table REP_GROUP
  add constraint FK_REP_GROUP_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table REP_GROUP
  add constraint CHK_REP_GROUP_D
  check (d in (0, 1));

prompt
prompt Creating table REP
prompt ==================
prompt
create table REP
(
  id           NUMBER(38) not null,
  id_rep_group NUMBER(38) not null,
  name         VARCHAR2(255 CHAR) not null,
  guid         VARCHAR2(38 CHAR) not null,
  description  VARCHAR2(2000 CHAR),
  ins_date     DATE default SYSDATE not null,
  ins_id_user  NUMBER(38) default 100000001 not null,
  upd_date     DATE default SYSDATE not null,
  upd_id_user  NUMBER(38) default 100000001 not null,
  d            NUMBER(1) default 0 not null
)
;
comment on table REP
  is 'отчёты';
comment on column REP.id
  is 'ИД';
comment on column REP.id_rep_group
  is 'ИД группы';
comment on column REP.name
  is 'Наименование';
comment on column REP.guid
  is 'ГУИД';
comment on column REP.description
  is 'описание отчёта';
comment on column REP.ins_date
  is 'Дата добавлния';
comment on column REP.ins_id_user
  is 'Кто добавил';
comment on column REP.upd_date
  is 'Дата изменения';
comment on column REP.upd_id_user
  is 'Кто изменил';
comment on column REP.d
  is 'Признак удаления = 1';
alter table REP
  add constraint PK_REP primary key (ID);
alter table REP
  add constraint FK_REP_ID_GROUP foreign key (ID_REP_GROUP)
  references REP_GROUP (ID);
alter table REP
  add constraint FK_REP_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table REP
  add constraint FK_REP_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table REP
  add constraint CHK_REP_D
  check (d in (0, 1));

prompt
prompt Creating table REPORT
prompt =====================
prompt
create table REPORT
(
  id          NUMBER not null,
  report_type VARCHAR2(20) not null,
  classname   VARCHAR2(1000),
  ins_date    DATE default localtimestamp not null,
  ins_id_user NUMBER,
  upd_date    DATE default localtimestamp,
  upd_id_user NUMBER,
  name        VARCHAR2(1000),
  blob_text   BLOB,
  query_text  BLOB
)
;
comment on column REPORT.id
  is 'Идентификатор';
comment on column REPORT.report_type
  is 'тип отчета
JAVA_BEAN - внутренний
QUERY - внешний подключаемый на основе запроса к БД';
comment on column REPORT.classname
  is 'имя класса JavaBean которым заполняется отчет';
comment on column REPORT.ins_date
  is 'Дата создания';
comment on column REPORT.ins_id_user
  is 'Пользователь добавивший запись';
comment on column REPORT.upd_date
  is 'Дата редактирования';
comment on column REPORT.upd_id_user
  is 'Последний пользователь редактировавший запись';
comment on column REPORT.blob_text
  is 'Текст шаблона отчета';
comment on column REPORT.query_text
  is 'Текст запроса';
alter table REPORT
  add constraint REPORT_PK primary key (ID);
alter table REPORT
  add constraint REPORT_CLASSNAME_UK1 unique (CLASSNAME);
alter table REPORT
  add constraint REPORT_SYS_USER_FK1 foreign key (INS_ID_USER)
  references SYS_USER (ID);
alter table REPORT
  add constraint REPORT_SYS_USER_FK2 foreign key (UPD_ID_USER)
  references SYS_USER (ID);

prompt
prompt Creating table ROUTE
prompt ====================
prompt
create table ROUTE
(
  id                NUMBER(38) not null,
  id_division       NUMBER(38) not null,
  code              VARCHAR2(6 CHAR) not null,
  name              VARCHAR2(255 CHAR) not null,
  ins_date          DATE default sysdate not null,
  ins_id_user       NUMBER(38) not null,
  upd_date          DATE default sysdate not null,
  upd_id_user       NUMBER(38) not null,
  d                 NUMBER(1) default 0 not null,
  id_code_msg       NUMBER(38) not null,
  id_transport_mode NUMBER(38)
)
;
comment on table ROUTE
  is 'Маршрут';
comment on column ROUTE.id
  is 'ИД';
comment on column ROUTE.id_division
  is 'ИД подразделения';
comment on column ROUTE.code
  is 'Код';
comment on column ROUTE.name
  is 'Наименование';
comment on column ROUTE.ins_date
  is 'Дата создания';
comment on column ROUTE.ins_id_user
  is 'Кто создал';
comment on column ROUTE.upd_date
  is 'Дата редактирования';
comment on column ROUTE.upd_id_user
  is 'Кто редактировал';
comment on column ROUTE.d
  is 'Признак удаления=1';
comment on column ROUTE.id_code_msg
  is 'ИД кода сообщения';
comment on column ROUTE.id_transport_mode
  is 'ИД вида транспорта';
alter table ROUTE
  add constraint PK_ROUTE primary key (ID);
alter table ROUTE
  add constraint UQ_ROUTE unique (ID_DIVISION, CODE);
alter table ROUTE
  add constraint FK_ROUTE_ID_CODE_MSG foreign key (ID_CODE_MSG)
  references REF_CODE_MSG (ID);
alter table ROUTE
  add constraint FK_ROUTE_ID_DIVISION foreign key (ID_DIVISION)
  references DIVISION (ID) on delete cascade;
alter table ROUTE
  add constraint FK_ROUTE_ID_TRANSPORT_MODE foreign key (ID_TRANSPORT_MODE)
  references REF_TRANSPORT_MODE (ID) on delete set null;
alter table ROUTE
  add constraint FK_ROUTE_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table ROUTE
  add constraint FK_ROUTE_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table ROUTE
  add constraint CHK_ROUTE_D
  check (d in (0,1));

prompt
prompt Creating table ROUTE_ZONE
prompt =========================
prompt
create table ROUTE_ZONE
(
  id          NUMBER(38) not null,
  id_route    NUMBER(38) not null,
  code        VARCHAR2(2 CHAR) default '00' not null,
  name        VARCHAR2(255 CHAR) not null,
  ins_date    DATE default sysdate not null,
  ins_id_user NUMBER(38) not null,
  upd_date    DATE default sysdate not null,
  upd_id_user NUMBER(38) not null,
  d           NUMBER(1) default 0 not null
)
;
comment on table ROUTE_ZONE
  is 'Зоны маршрута';
comment on column ROUTE_ZONE.id
  is 'ИД';
comment on column ROUTE_ZONE.id_route
  is 'ИД маршрута';
comment on column ROUTE_ZONE.code
  is 'Код';
comment on column ROUTE_ZONE.name
  is 'Наименование';
comment on column ROUTE_ZONE.ins_date
  is 'Дата создания';
comment on column ROUTE_ZONE.ins_id_user
  is 'Кто создал';
comment on column ROUTE_ZONE.upd_date
  is 'Дата редактирования';
comment on column ROUTE_ZONE.upd_id_user
  is 'Кто редактировал';
comment on column ROUTE_ZONE.d
  is 'Признак удаления=1';
alter table ROUTE_ZONE
  add constraint PK_ROUTE_ZONE primary key (ID);
alter table ROUTE_ZONE
  add constraint UQ_ROUTE_ZONE unique (ID_ROUTE, CODE);
alter table ROUTE_ZONE
  add constraint FK_ROUTE_ZONE_ID_ROUTE foreign key (ID_ROUTE)
  references ROUTE (ID) on delete cascade;
alter table ROUTE_ZONE
  add constraint FK_ROUTE_ZONE_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table ROUTE_ZONE
  add constraint FK_ROUTE_ZONE_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table ROUTE_ZONE
  add constraint CHK_ROUTE_ZONE_CODE
  check (code between '00' and '99');
alter table ROUTE_ZONE
  add constraint CHK_ROUTE_ZONE_D
  check (d in (0,1));

prompt
prompt Creating table STAFF
prompt ====================
prompt
create table STAFF
(
  id          NUMBER(38) not null,
  id_division NUMBER(38) not null,
  code        VARCHAR2(6 CHAR) default '000000' not null,
  name        VARCHAR2(255 CHAR) not null,
  id_card     NUMBER(38) not null,
  ins_date    DATE default sysdate not null,
  ins_id_user NUMBER(38) not null,
  upd_date    DATE default sysdate not null,
  upd_id_user NUMBER(38) not null,
  d           NUMBER(1) default 0 not null
)
;
comment on table STAFF
  is 'Сотрудники';
comment on column STAFF.id
  is 'ИД';
comment on column STAFF.id_division
  is 'ИД подразделения';
comment on column STAFF.code
  is 'Код (табельный номер)';
comment on column STAFF.name
  is 'ФИО';
comment on column STAFF.id_card
  is 'ИД карты';
comment on column STAFF.ins_date
  is 'Дата создания';
comment on column STAFF.ins_id_user
  is 'Кто создал';
comment on column STAFF.upd_date
  is 'Дата редактирования';
comment on column STAFF.upd_id_user
  is 'Кто редактировал';
comment on column STAFF.d
  is 'Признак удаления=1';
alter table STAFF
  add constraint PK_STAFF primary key (ID);
alter table STAFF
  add constraint UQ_STAFF unique (ID_DIVISION, CODE);
alter table STAFF
  add constraint FK_STAFF_ID_CARD foreign key (ID_CARD)
  references CARD (ID);
alter table STAFF
  add constraint FK_STAFF_ID_DIVISION foreign key (ID_DIVISION)
  references DIVISION (ID) on delete cascade;
alter table STAFF
  add constraint FK_STAFF_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table STAFF
  add constraint FK_STAFF_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table STAFF
  add constraint CHK_STAFF_CODE
  check (code between '000000' and '999999');
alter table STAFF
  add constraint CHK_STAFF_D
  check (d in (0,1));

prompt
prompt Creating table SYS_APP
prompt ======================
prompt
create table SYS_APP
(
  id   NUMBER(38) not null,
  guid VARCHAR2(40) not null,
  name VARCHAR2(255) not null
)
;
comment on table SYS_APP
  is 'Модули АРМ';
comment on column SYS_APP.id
  is 'ИД';
comment on column SYS_APP.guid
  is 'GUID модуля';
comment on column SYS_APP.name
  is 'Название модуля';
alter table SYS_APP
  add constraint PK_SYS_APP primary key (ID);

prompt
prompt Creating table SYS_ACTION
prompt =========================
prompt
create table SYS_ACTION
(
  id     NUMBER(38) not null,
  name   VARCHAR2(255) not null,
  guid   VARCHAR2(40) not null,
  id_app NUMBER(38) not null
)
;
comment on table SYS_ACTION
  is 'Действия';
comment on column SYS_ACTION.id
  is 'Идентификатор';
comment on column SYS_ACTION.name
  is 'Имя';
comment on column SYS_ACTION.guid
  is 'GUID';
comment on column SYS_ACTION.id_app
  is 'ИД модуля';
alter table SYS_ACTION
  add constraint PK_SYS_ACTION primary key (ID);
alter table SYS_ACTION
  add constraint UI_SYS_ACTION_GUID unique (GUID);
alter table SYS_ACTION
  add constraint FK_SYS_ACTION_ID_APP foreign key (ID_APP)
  references SYS_APP (ID) on delete cascade;

prompt
prompt Creating table SYS$ACTIONS
prompt ==========================
prompt
create table SYS$ACTIONS
(
  id          NUMBER(38) not null,
  name        VARCHAR2(255 CHAR) not null,
  guid        VARCHAR2(40 CHAR) not null,
  ins_date    DATE default sysdate not null,
  ins_id_user NUMBER(38) not null,
  upd_date    DATE default sysdate not null,
  upd_id_user NUMBER(38) not null,
  d           NUMBER(1) default 0 not null
)
;
comment on table SYS$ACTIONS
  is 'Действия';
comment on column SYS$ACTIONS.id
  is 'Идентификатор';
comment on column SYS$ACTIONS.name
  is 'Имя';
comment on column SYS$ACTIONS.guid
  is 'GUID';
comment on column SYS$ACTIONS.ins_date
  is 'Дата создания записи';
comment on column SYS$ACTIONS.ins_id_user
  is 'Кто создал';
comment on column SYS$ACTIONS.upd_date
  is 'Дата изменения записи';
comment on column SYS$ACTIONS.upd_id_user
  is 'Кто изменил';
comment on column SYS$ACTIONS.d
  is 'Признак удаления = 1';
alter table SYS$ACTIONS
  add constraint PK_SYS$ACTIONS primary key (ID);
alter table SYS$ACTIONS
  add constraint UI_SYS$ACTIONS_GUID unique (GUID);
alter table SYS$ACTIONS
  add constraint FK_SYS$ACTIONS_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table SYS$ACTIONS
  add constraint FK_SYS$ACTIONS_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table SYS$ACTIONS
  add constraint CHK_SYS$ACTIONS_D
  check (d in (0,1));

prompt
prompt Creating table SYS$APP
prompt ======================
prompt
create table SYS$APP
(
  id          NUMBER(38) not null,
  name        VARCHAR2(255 CHAR) not null,
  guid        VARCHAR2(40 CHAR) not null,
  ins_date    DATE default sysdate not null,
  ins_id_user NUMBER(38) not null,
  upd_date    DATE default sysdate not null,
  upd_id_user NUMBER(38) not null,
  d           NUMBER(1) default 0 not null
)
;
comment on table SYS$APP
  is 'Приложения';
comment on column SYS$APP.id
  is 'Идентификатор';
comment on column SYS$APP.name
  is 'Имя';
comment on column SYS$APP.guid
  is 'GUID';
comment on column SYS$APP.ins_date
  is 'Дата создания записи';
comment on column SYS$APP.ins_id_user
  is 'Кто создал';
comment on column SYS$APP.upd_date
  is 'Дата изменения записи';
comment on column SYS$APP.upd_id_user
  is 'Кто изменил';
comment on column SYS$APP.d
  is 'Признак удаления = 1';
alter table SYS$APP
  add constraint PK_SYS$APP primary key (ID);
alter table SYS$APP
  add constraint UI_SYS$APP_GUID unique (GUID);
alter table SYS$APP
  add constraint FK_SYS$APP_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table SYS$APP
  add constraint FK_SYS$APP_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table SYS$APP
  add constraint CHK_SYS$APP_D
  check (d in (0,1));

prompt
prompt Creating table SYS$APPACTS
prompt ==========================
prompt
create table SYS$APPACTS
(
  id          NUMBER(38) not null,
  id_app      NUMBER(38) not null,
  id_action   NUMBER(38) not null,
  ins_date    DATE default sysdate not null,
  ins_id_user NUMBER(38),
  upd_date    DATE default sysdate not null,
  upd_id_user NUMBER(38),
  d           NUMBER(1) default 0 not null
)
;
comment on table SYS$APPACTS
  is 'Действия приложения';
comment on column SYS$APPACTS.id
  is 'Идентификатор';
comment on column SYS$APPACTS.id_app
  is 'Идентифкатор приложения';
comment on column SYS$APPACTS.id_action
  is 'Идентификатор действия';
comment on column SYS$APPACTS.ins_date
  is 'Дата создания записи';
comment on column SYS$APPACTS.ins_id_user
  is 'Кто создал';
comment on column SYS$APPACTS.upd_date
  is 'Дата изменения записи';
comment on column SYS$APPACTS.upd_id_user
  is 'Кто изменил';
comment on column SYS$APPACTS.d
  is 'Признак удаления = 1';
alter table SYS$APPACTS
  add constraint PK_SYS$APPACTS primary key (ID);
alter table SYS$APPACTS
  add constraint UI_SYS$APPACTS_ID_APP_ACT unique (ID_APP, ID_ACTION);
alter table SYS$APPACTS
  add constraint FK_SYS$APPACTS_ID_ACTION foreign key (ID_ACTION)
  references SYS$ACTIONS (ID);
alter table SYS$APPACTS
  add constraint FK_SYS$APPACTS_ID_APP foreign key (ID_APP)
  references SYS$APP (ID);
alter table SYS$APPACTS
  add constraint FK_SYS$APPACTS_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table SYS$APPACTS
  add constraint FK_SYS$APPACTS_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table SYS$APPACTS
  add constraint CHK_SYS$APPACTS_D
  check (d in (0,1));

prompt
prompt Creating table SYS$CFG
prompt ======================
prompt
create table SYS$CFG
(
  db_number    NUMBER(8) default 0 not null,
  scheme       VARCHAR2(30 CHAR) default SYS_CONTEXT( 'USERENV', 'CURRENT_SCHEMA') not null,
  project_name VARCHAR2(50 CHAR) default '' not null
)
;
comment on table SYS$CFG
  is 'Конфигурация';
comment on column SYS$CFG.db_number
  is 'Номер БД';
comment on column SYS$CFG.scheme
  is 'Схема БД';
comment on column SYS$CFG.project_name
  is 'Название проекта - LOTOS, CPTT';
alter table SYS$CFG
  add constraint UQ_SYS$CFG_DB_NUMBER unique (DB_NUMBER);
alter table SYS$CFG
  add constraint CHK_LOTOS_CONFIG_DB_NUMBER
  check (db_number between 0 and 99999999);
alter table SYS$CFG
  add constraint CHK_SYS$CFG_PROJECT_NAME
  check (upper(project_name) in ('LOTOS', 'CPTT'));

prompt
prompt Creating table SYS$DATA_GROUP
prompt =============================
prompt
create table SYS$DATA_GROUP
(
  id          VARCHAR2(32 CHAR) not null,
  id_parent   VARCHAR2(32 CHAR),
  name        VARCHAR2(255 CHAR) not null,
  ins_date    DATE default sysdate not null,
  ins_id_user NUMBER(38) not null,
  upd_date    DATE default sysdate not null,
  upd_id_user NUMBER(38) not null,
  kind        NUMBER(1) default 0 not null
)
;
comment on table SYS$DATA_GROUP
  is 'Группы фильтров';
comment on column SYS$DATA_GROUP.id
  is 'id';
comment on column SYS$DATA_GROUP.id_parent
  is 'id родителя';
comment on column SYS$DATA_GROUP.name
  is 'Название группы';
comment on column SYS$DATA_GROUP.ins_date
  is 'Дата создания записи';
comment on column SYS$DATA_GROUP.ins_id_user
  is 'Кто создал';
comment on column SYS$DATA_GROUP.upd_date
  is 'Дата изменения записи';
comment on column SYS$DATA_GROUP.upd_id_user
  is 'Кто изменил';
comment on column SYS$DATA_GROUP.kind
  is '1 - группы фильтров, 2 - группы деревьев функций';
create index SI_SYS$FILTER_GRP_ID_PARENT on SYS$DATA_GROUP (ID_PARENT);
alter table SYS$DATA_GROUP
  add constraint PK_SYS$DATA_GROUP primary key (ID);
alter table SYS$DATA_GROUP
  add constraint FK_SYS$DATA_GROUP_ID_PARENT foreign key (ID_PARENT)
  references SYS$DATA_GROUP (ID) on delete cascade;
alter table SYS$DATA_GROUP
  add constraint FK_SYS$DATA_GROUP_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table SYS$DATA_GROUP
  add constraint FK_SYS$DATA_GROUP_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);

prompt
prompt Creating table SYS$DATA_SECTION
prompt ===============================
prompt
create table SYS$DATA_SECTION
(
  id          VARCHAR2(32 CHAR) not null,
  name        VARCHAR2(255 CHAR) not null,
  ins_date    DATE default sysdate not null,
  ins_id_user NUMBER(38) not null,
  upd_date    DATE default sysdate not null,
  upd_id_user NUMBER(38) not null,
  description VARCHAR2(255 CHAR),
  id_parent   VARCHAR2(32 CHAR),
  id_group    VARCHAR2(32 CHAR),
  kind        NUMBER(1) default 0 not null
)
;
comment on table SYS$DATA_SECTION
  is 'Фильтры, деревья фуекций и их секционный состав';
comment on column SYS$DATA_SECTION.id
  is 'id';
comment on column SYS$DATA_SECTION.name
  is 'Наименование фильтра или дерева функций';
comment on column SYS$DATA_SECTION.ins_date
  is 'Дата создания записи';
comment on column SYS$DATA_SECTION.ins_id_user
  is 'Кто создал';
comment on column SYS$DATA_SECTION.upd_date
  is 'Дата изменения записи';
comment on column SYS$DATA_SECTION.upd_id_user
  is 'Кто изменил';
comment on column SYS$DATA_SECTION.description
  is 'Описание фильтра';
comment on column SYS$DATA_SECTION.id_parent
  is 'id предка, если NULL, то см. kind, иначе его секция';
comment on column SYS$DATA_SECTION.id_group
  is 'id группы';
comment on column SYS$DATA_SECTION.kind
  is 'тип записи 1 - фильтры, 2 - деревья функций';
alter table SYS$DATA_SECTION
  add constraint PK_SYS$DATA_SECTION_ID primary key (ID);
alter table SYS$DATA_SECTION
  add constraint FK_SYS$DATA_SECTION_ID_GROUP foreign key (ID_GROUP)
  references SYS$DATA_GROUP (ID);
alter table SYS$DATA_SECTION
  add constraint FK_SYS$DATA_SECTION_ID_PARENT foreign key (ID_PARENT)
  references SYS$DATA_SECTION (ID) on delete cascade;
alter table SYS$DATA_SECTION
  add constraint FK_SYS$DATA_SECTION_INS_ID_US foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table SYS$DATA_SECTION
  add constraint FK_SYS$DATA_SECTION_UPD_ID_US foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table SYS$DATA_SECTION
  add constraint CHK_SYS$DATA_SECTION_KIND
  check (kind in (0, 1, 2));

prompt
prompt Creating table SYS$META_TABLE
prompt =============================
prompt
create table SYS$META_TABLE
(
  id          VARCHAR2(32 CHAR) not null,
  name        VARCHAR2(255 CHAR) not null,
  alias       VARCHAR2(255 CHAR) not null,
  ins_date    DATE default sysdate not null,
  ins_id_user NUMBER(38) not null,
  upd_date    DATE default sysdate not null,
  upd_id_user NUMBER(38) not null,
  sql_text    VARCHAR2(30 CHAR) not null,
  d           NUMBER(38) default 0 not null
)
;
comment on table SYS$META_TABLE
  is 'Таблицы, по которым будут строиться фильтры';
comment on column SYS$META_TABLE.id
  is 'id';
comment on column SYS$META_TABLE.name
  is 'Наименование таблицы';
comment on column SYS$META_TABLE.alias
  is 'Псевдоним';
comment on column SYS$META_TABLE.ins_date
  is 'Дата создания записи';
comment on column SYS$META_TABLE.ins_id_user
  is 'Кто создал';
comment on column SYS$META_TABLE.upd_date
  is 'Дата изменения записи';
comment on column SYS$META_TABLE.upd_id_user
  is 'Кто изменил';
comment on column SYS$META_TABLE.sql_text
  is 'Имя таблицы БД';
comment on column SYS$META_TABLE.d
  is 'Признак удаления = 1';
alter table SYS$META_TABLE
  add constraint PK_SYS$META_TABLE_ID primary key (ID);
alter table SYS$META_TABLE
  add constraint UK_SYS$META_TABLE_ALIAS unique (ALIAS);
alter table SYS$META_TABLE
  add constraint FK_SYS$META_TABLE_INS_ID_USR foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table SYS$META_TABLE
  add constraint FK_SYS$META_TABLE_UPD_ID_USR foreign key (UPD_ID_USER)
  references SYS$USERS (ID);

prompt
prompt Creating table SYS$META_GROUP
prompt =============================
prompt
create table SYS$META_GROUP
(
  id          VARCHAR2(32 CHAR) not null,
  id_parent   VARCHAR2(32 CHAR),
  name        VARCHAR2(255 CHAR) not null,
  ins_date    DATE default sysdate not null,
  ins_id_user NUMBER(38) not null,
  upd_date    DATE default sysdate not null,
  upd_id_user NUMBER(38) not null,
  d           NUMBER(1) default 0 not null
)
;
comment on table SYS$META_GROUP
  is 'Группы функций для сообщений';
comment on column SYS$META_GROUP.id
  is 'id';
comment on column SYS$META_GROUP.id_parent
  is 'id предка';
comment on column SYS$META_GROUP.name
  is 'Название группы';
comment on column SYS$META_GROUP.ins_date
  is 'Дата создания записи';
comment on column SYS$META_GROUP.ins_id_user
  is 'Кто создал';
comment on column SYS$META_GROUP.upd_date
  is 'Дата изменения записи';
comment on column SYS$META_GROUP.upd_id_user
  is 'Кто изменил';
comment on column SYS$META_GROUP.d
  is 'Признак удаления = 1';
create index SI_SYS$META_GROUP_ID_PARENT on SYS$META_GROUP (ID_PARENT);
alter table SYS$META_GROUP
  add constraint PK_SYS$META_GROUP_GRP primary key (ID);
alter table SYS$META_GROUP
  add constraint FK_SYS$META_GROUP_ID_PARENT foreign key (ID_PARENT)
  references SYS$META_GROUP (ID) on delete cascade;
alter table SYS$META_GROUP
  add constraint FK_SYS$META_GROUP_INS foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table SYS$META_GROUP
  add constraint FK_SYS$META_GROUP_UPD foreign key (UPD_ID_USER)
  references SYS$USERS (ID);

prompt
prompt Creating table SYS$META_ITEM
prompt ============================
prompt
create table SYS$META_ITEM
(
  id          VARCHAR2(32 CHAR) not null,
  name        VARCHAR2(255 CHAR) not null,
  ins_date    DATE default sysdate not null,
  ins_id_user NUMBER(38) not null,
  upd_date    DATE default sysdate not null,
  upd_id_user NUMBER(38) not null,
  out_type    NUMBER(2) not null,
  ref_name    VARCHAR2(255 CHAR),
  sql_text    VARCHAR2(2000 CHAR) not null,
  kind        NUMBER(1) default 0 not null,
  id_group    VARCHAR2(32 CHAR),
  id_table    VARCHAR2(32 CHAR),
  precision   NUMBER(38) default 0 not null,
  dialog      NUMBER(38) default 1 not null,
  d           NUMBER(1) default 0 not null,
  def_size    NUMBER(38) default 1 not null,
  show_dialog NUMBER(1) default 1 not null
)
;
comment on table SYS$META_ITEM
  is 'Столбцы и функции, по которым строяться фильтры и сообщения';
comment on column SYS$META_ITEM.id
  is 'id';
comment on column SYS$META_ITEM.name
  is 'Наименование столбца (функции)';
comment on column SYS$META_ITEM.ins_date
  is 'Дата создания записи';
comment on column SYS$META_ITEM.ins_id_user
  is 'Кто создал';
comment on column SYS$META_ITEM.upd_date
  is 'Дата изменения записи';
comment on column SYS$META_ITEM.upd_id_user
  is 'Кто изменил';
comment on column SYS$META_ITEM.out_type
  is 'Тип столбца (функции) 1- строка, 2 - число, 3 - дата, 4 - справочник';
comment on column SYS$META_ITEM.ref_name
  is 'Справочник';
comment on column SYS$META_ITEM.sql_text
  is 'Текст функции (или имя столбца)';
comment on column SYS$META_ITEM.kind
  is 'Тип функции 1 - для фильтров, 2 - для сообщений';
comment on column SYS$META_ITEM.id_group
  is 'id группы метаданных';
comment on column SYS$META_ITEM.id_table
  is 'id таблицы, если NULL, то функция';
comment on column SYS$META_ITEM.precision
  is 'Точность числа (кол-во знаков после запятой)';
comment on column SYS$META_ITEM.dialog
  is 'Диалог';
comment on column SYS$META_ITEM.d
  is 'Признак удаления = 1';
comment on column SYS$META_ITEM.def_size
  is 'Размер значения default';
comment on column SYS$META_ITEM.show_dialog
  is 'Выводить диалог';
alter table SYS$META_ITEM
  add constraint PK_SYS$META_ITEM_ID primary key (ID);
alter table SYS$META_ITEM
  add constraint FK_SYS$META_ITEM_ID_GROUP foreign key (ID_GROUP)
  references SYS$META_GROUP (ID);
alter table SYS$META_ITEM
  add constraint FK_SYS$META_ITEM_ID_TABLE foreign key (ID_TABLE)
  references SYS$META_TABLE (ID);
alter table SYS$META_ITEM
  add constraint FK_SYS$META_ITEM_INS_ID_USR foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table SYS$META_ITEM
  add constraint FK_SYS$META_ITEM_UPD_ID_USR foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table SYS$META_ITEM
  add constraint CHK_SYS$META_ITEM_KIND
  check (kind in (0, 1, 2));
alter table SYS$META_ITEM
  add constraint CHK_SYS$META_ITEM_OUT_TYPE
  check (out_type in (1, 2, 3, 4));

prompt
prompt Creating table SYS$DATA_ITEM
prompt ============================
prompt
create table SYS$DATA_ITEM
(
  id          VARCHAR2(32 CHAR) not null,
  id_item     VARCHAR2(32 CHAR) not null,
  ins_date    DATE default sysdate not null,
  ins_id_user NUMBER(38) not null,
  upd_date    DATE default sysdate not null,
  upd_id_user NUMBER(38) not null,
  id_section  VARCHAR2(32 CHAR),
  position    NUMBER(3) default 0 not null
)
;
comment on table SYS$DATA_ITEM
  is 'Элементы фильтра или дерева функций';
comment on column SYS$DATA_ITEM.id
  is 'id';
comment on column SYS$DATA_ITEM.id_item
  is 'id колонки (или функции)';
comment on column SYS$DATA_ITEM.ins_date
  is 'Дата создания записи';
comment on column SYS$DATA_ITEM.ins_id_user
  is 'Кто создал';
comment on column SYS$DATA_ITEM.upd_date
  is 'Дата изменения записи';
comment on column SYS$DATA_ITEM.upd_id_user
  is 'Кто изменил';
comment on column SYS$DATA_ITEM.id_section
  is 'id секции';
comment on column SYS$DATA_ITEM.position
  is 'Позиция элемента в секции (только для фильтров)';
alter table SYS$DATA_ITEM
  add constraint PK_SYS$DATA_ITEM_ID primary key (ID);
alter table SYS$DATA_ITEM
  add constraint FK_SYS$DATA_ITEM_ID_ITEM foreign key (ID_ITEM)
  references SYS$META_ITEM (ID) on delete cascade;
alter table SYS$DATA_ITEM
  add constraint FK_SYS$DATA_ITEM_ID_SECTION foreign key (ID_SECTION)
  references SYS$DATA_SECTION (ID) on delete cascade;
alter table SYS$DATA_ITEM
  add constraint FK_SYS$DATA_ITEM_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table SYS$DATA_ITEM
  add constraint FK_SYS$DATA_ITEM_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table SYS$DATA_ITEM
  add constraint CHK_SYS$DATA_ITEM_POSITION
  check (position >= 0);

prompt
prompt Creating table SYS$GRPGRANT
prompt ===========================
prompt
create table SYS$GRPGRANT
(
  id          NUMBER(38) not null,
  id_group    NUMBER(38) not null,
  id_action   NUMBER(38) not null,
  ins_date    DATE default sysdate not null,
  ins_id_user NUMBER(38) not null,
  upd_date    DATE default sysdate not null,
  upd_id_user NUMBER(38) not null,
  d           NUMBER(1) default 0 not null
)
;
comment on table SYS$GRPGRANT
  is 'Разрешения группы пользователей';
comment on column SYS$GRPGRANT.id
  is 'Идентификатор';
comment on column SYS$GRPGRANT.id_group
  is 'Идентифкатор группы';
comment on column SYS$GRPGRANT.id_action
  is 'Действие';
comment on column SYS$GRPGRANT.ins_date
  is 'Дата создания записи';
comment on column SYS$GRPGRANT.ins_id_user
  is 'Кто создал';
comment on column SYS$GRPGRANT.upd_date
  is 'Дата изменения записи';
comment on column SYS$GRPGRANT.upd_id_user
  is 'Кто изменил';
comment on column SYS$GRPGRANT.d
  is 'Признак удаления = 1';
alter table SYS$GRPGRANT
  add constraint PK_SYS$GRPGRANT primary key (ID);
alter table SYS$GRPGRANT
  add constraint UI_SYS$GRPGRANT_ID_G_A unique (ID_GROUP, ID_ACTION);
alter table SYS$GRPGRANT
  add constraint FK_SYS$GRPGRANT_ID_ACTION foreign key (ID_ACTION)
  references SYS$ACTIONS (ID);
alter table SYS$GRPGRANT
  add constraint FK_SYS$GRPGRANT_ID_GROUP foreign key (ID_GROUP)
  references SYS$GROUPS (ID) on delete cascade;
alter table SYS$GRPGRANT
  add constraint FK_SYS$GRPGRANT_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table SYS$GRPGRANT
  add constraint FK_SYS$GRPGRANT_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table SYS$GRPGRANT
  add constraint CHK_SYS$GRPGRANT_D
  check (d in (0,1));

prompt
prompt Creating table SYS$LOG
prompt ======================
prompt
create table SYS$LOG
(
  msg      VARCHAR2(2000),
  ins_date DATE default sysdate not null
)
;
comment on column SYS$LOG.msg
  is 'Сообщение';
comment on column SYS$LOG.ins_date
  is 'Дата + время добавления';

prompt
prompt Creating table SYS_USERGRANT
prompt ============================
prompt
create table SYS_USERGRANT
(
  id          NUMBER(38) not null,
  id_user     NUMBER(38) not null,
  id_action   NUMBER(38) not null,
  ins_date    DATE default sysdate not null,
  ins_id_user NUMBER(38) not null
)
;
comment on table SYS_USERGRANT
  is 'Разрешения пользователя';
comment on column SYS_USERGRANT.id
  is 'Идентификатор';
comment on column SYS_USERGRANT.id_user
  is 'Идентифкатор пользователя';
comment on column SYS_USERGRANT.id_action
  is 'Действие';
comment on column SYS_USERGRANT.ins_date
  is 'Дата создания записи';
comment on column SYS_USERGRANT.ins_id_user
  is 'Кто создал';
alter table SYS_USERGRANT
  add constraint PK_SYS_USERGRANT primary key (ID);
alter table SYS_USERGRANT
  add constraint UI_SYS_USERGRANT_ID_U_A unique (ID_USER, ID_ACTION);
alter table SYS_USERGRANT
  add constraint FK_SYS_USERGRANT_ID_ACTION foreign key (ID_ACTION)
  references SYS_ACTION (ID) on delete cascade;
alter table SYS_USERGRANT
  add constraint FK_SYS_USERGRANT_ID_USER foreign key (ID_USER)
  references SYS_USER (ID) on delete cascade;
alter table SYS_USERGRANT
  add constraint FK_SYS_USERGRANT_INS_ID_USER foreign key (INS_ID_USER)
  references SYS_USER (ID);

prompt
prompt Creating table SYS$USRGRANT
prompt ===========================
prompt
create table SYS$USRGRANT
(
  id          NUMBER(38) not null,
  id_user     NUMBER(38) not null,
  id_action   NUMBER(38) not null,
  ins_date    DATE default sysdate not null,
  ins_id_user NUMBER(38) not null,
  upd_date    DATE default sysdate not null,
  upd_id_user NUMBER(38) not null,
  d           NUMBER(1) default 0 not null
)
;
comment on table SYS$USRGRANT
  is 'Разрешения пользователя';
comment on column SYS$USRGRANT.id
  is 'Идентификатор';
comment on column SYS$USRGRANT.id_user
  is 'Идентифкатор пользователя';
comment on column SYS$USRGRANT.id_action
  is 'Действие';
comment on column SYS$USRGRANT.ins_date
  is 'Дата создания записи';
comment on column SYS$USRGRANT.ins_id_user
  is 'Кто создал';
comment on column SYS$USRGRANT.upd_date
  is 'Дата изменения записи';
comment on column SYS$USRGRANT.upd_id_user
  is 'Кто изменил';
comment on column SYS$USRGRANT.d
  is 'Признак удаления = 1';
alter table SYS$USRGRANT
  add constraint PK_SYS$USRGRANT primary key (ID);
alter table SYS$USRGRANT
  add constraint UI_SYS$USRGRANT_ID_U_A unique (ID_USER, ID_ACTION);
alter table SYS$USRGRANT
  add constraint FK_SYS$USRGRANT_ID_ACTION foreign key (ID_ACTION)
  references SYS$ACTIONS (ID);
alter table SYS$USRGRANT
  add constraint FK_SYS$USRGRANT_ID_USER foreign key (ID_USER)
  references SYS$USERS (ID) on delete cascade;
alter table SYS$USRGRANT
  add constraint FK_SYS$USRGRANT_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table SYS$USRGRANT
  add constraint FK_SYS$USRGRANT_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);

prompt
prompt Creating table TARIFF
prompt =====================
prompt
create table TARIFF
(
  id              NUMBER(38) not null,
  id_route        NUMBER(38) not null,
  begin_date      DATE default sysdate not null,
  ins_date        DATE default sysdate not null,
  ins_id_user     NUMBER(38) not null,
  upd_date        DATE default sysdate not null,
  upd_id_user     NUMBER(38) not null,
  d               NUMBER(1) default 0 not null,
  is_used         NUMBER not null,
  price_distance  NUMBER default 0 not null,
  amount_distance NUMBER default 0 not null,
  ol_pricecity    NUMBER default 0 not null,
  ol_pricesuburb  NUMBER default 0 not null
)
;
comment on table TARIFF
  is 'Тариф';
comment on column TARIFF.id
  is 'ИД';
comment on column TARIFF.id_route
  is 'ИД маршрута';
comment on column TARIFF.begin_date
  is 'Дата начала действия';
comment on column TARIFF.ins_date
  is 'Дата создания';
comment on column TARIFF.ins_id_user
  is 'Кто создал';
comment on column TARIFF.upd_date
  is 'Дата редактирования';
comment on column TARIFF.upd_id_user
  is 'Кто редактировал';
comment on column TARIFF.d
  is 'Признак удаления =1';
comment on column TARIFF.is_used
  is 'Используется';
comment on column TARIFF.price_distance
  is 'Цена за 1 км';
comment on column TARIFF.amount_distance
  is 'Количество километров на поездку (тариф поездок)';
comment on column TARIFF.ol_pricecity
  is 'Кол-во денег возвращаемых за поездку по OL в городе';
comment on column TARIFF.ol_pricesuburb
  is 'Кол-во денег возвращаемых за поездку по OL в пригороде';
alter table TARIFF
  add constraint PK_TARIFF primary key (ID);
alter table TARIFF
  add constraint FK_TARIFF_ID_ROUTE foreign key (ID_ROUTE)
  references ROUTE (ID) on delete cascade;
alter table TARIFF
  add constraint FK_TARIFF_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table TARIFF
  add constraint FK_TARIFF_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table TARIFF
  add constraint CHK_TARIFF_D
  check (d in (0,1));
alter table TARIFF
  add constraint CHK_TARIFF_IS_USED
  check (IS_USED in (0,1));

prompt
prompt Creating table TARIFF_SERIES
prompt ============================
prompt
create table TARIFF_SERIES
(
  id          NUMBER(38) not null,
  series      VARCHAR2(512 CHAR) not null,
  description VARCHAR2(2048 CHAR),
  id_tariff   NUMBER(38) not null
)
;
comment on table TARIFF_SERIES
  is 'Серии тарифов';
comment on column TARIFF_SERIES.id
  is 'ИД';
comment on column TARIFF_SERIES.series
  is 'Название серии тарифа';
comment on column TARIFF_SERIES.description
  is 'Описание';
comment on column TARIFF_SERIES.id_tariff
  is 'ИД тарифа';
alter table TARIFF_SERIES
  add constraint PK_TARIFF_SERIES primary key (ID);
alter table TARIFF_SERIES
  add constraint UQ_TARIFF_SERIES unique (SERIES, ID_TARIFF);
alter table TARIFF_SERIES
  add constraint FK_TARIFF_SERIES_ID_TARIFF foreign key (ID_TARIFF)
  references TARIFF (ID) on delete cascade;

prompt
prompt Creating table TARIFF_ZONE
prompt ==========================
prompt
create table TARIFF_ZONE
(
  id                NUMBER(38) not null,
  id_tariff         NUMBER(38) not null,
  id_zone_begin     NUMBER(38) not null,
  id_zone_end       NUMBER(38) not null,
  distance          NUMBER default 0 not null,
  price             NUMBER default 0 not null,
  ins_date          DATE default sysdate not null,
  ins_id_user       NUMBER(38) not null,
  upd_date          DATE default sysdate not null,
  upd_id_user       NUMBER(38) not null,
  d                 NUMBER(1) default 0 not null,
  price_ep          NUMBER default 0 not null,
  price_amount_trip NUMBER default 0 not null
)
;
comment on table TARIFF_ZONE
  is 'Стоимость проезда и дистанция';
comment on column TARIFF_ZONE.id
  is 'ИД';
comment on column TARIFF_ZONE.id_tariff
  is 'ИД тарифа';
comment on column TARIFF_ZONE.id_zone_begin
  is 'ИД зоны начальной';
comment on column TARIFF_ZONE.id_zone_end
  is 'ИД зоны конечной';
comment on column TARIFF_ZONE.distance
  is 'Дистанция (км)';
comment on column TARIFF_ZONE.price
  is 'Стоимость проезда (руб)';
comment on column TARIFF_ZONE.ins_date
  is 'Дата создания';
comment on column TARIFF_ZONE.ins_id_user
  is 'Кто создал';
comment on column TARIFF_ZONE.upd_date
  is 'Дата редактирования';
comment on column TARIFF_ZONE.upd_id_user
  is 'Кто редактировал';
comment on column TARIFF_ZONE.d
  is 'Признак удаления=1';
comment on column TARIFF_ZONE.price_ep
  is 'Стоимость в единицах электронного кошелька';
comment on column TARIFF_ZONE.price_amount_trip
  is 'Стоимость в количествах поездок';
alter table TARIFF_ZONE
  add constraint PK_TARIFF_ZONE primary key (ID);
alter table TARIFF_ZONE
  add constraint UQ_TARIFF_ZONE unique (ID_TARIFF, ID_ZONE_BEGIN, ID_ZONE_END);
alter table TARIFF_ZONE
  add constraint FK_TARIFF_ZONE_ID_TARIFF foreign key (ID_TARIFF)
  references TARIFF (ID) on delete cascade;
alter table TARIFF_ZONE
  add constraint FK_TARIFF_ZONE_ID_Z_BEG foreign key (ID_ZONE_BEGIN)
  references ROUTE_ZONE (ID);
alter table TARIFF_ZONE
  add constraint FK_TARIFF_ZONE_ID_Z_END foreign key (ID_ZONE_END)
  references ROUTE_ZONE (ID);
alter table TARIFF_ZONE
  add constraint FK_TARIFF_ZONE_INS_ID_USR foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table TARIFF_ZONE
  add constraint FK_TARIFF_ZONE_UPD_ID_USR foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table TARIFF_ZONE
  add constraint CHK_TARIFF_ZONE_D
  check (d in (0,1));

prompt
prompt Creating table TARIFF_SERIES_ZONE
prompt =================================
prompt
create table TARIFF_SERIES_ZONE
(
  id               NUMBER(38) not null,
  id_tariff_series NUMBER(38) not null,
  id_tariff_zone   NUMBER(38) not null,
  price            NUMBER,
  amount           NUMBER
)
;
comment on table TARIFF_SERIES_ZONE
  is 'Разделение тарифа по сериям и зонам';
comment on column TARIFF_SERIES_ZONE.id
  is 'ИД';
comment on column TARIFF_SERIES_ZONE.id_tariff_series
  is 'Ссылка на серию';
comment on column TARIFF_SERIES_ZONE.id_tariff_zone
  is 'Ссылка на зону в тарифе';
comment on column TARIFF_SERIES_ZONE.price
  is 'Цена по тарифу';
comment on column TARIFF_SERIES_ZONE.amount
  is 'Количество поездок по тарифу';
alter table TARIFF_SERIES_ZONE
  add constraint PK_TARIFF_SERIES_ZONE primary key (ID);
alter table TARIFF_SERIES_ZONE
  add constraint UQ_TARIFF_SERIES_ZONE unique (ID_TARIFF_SERIES, ID_TARIFF_ZONE);
alter table TARIFF_SERIES_ZONE
  add constraint FK_T_S_Z_ID_TARIFF_SERIES foreign key (ID_TARIFF_SERIES)
  references TARIFF_SERIES (ID) on delete cascade;
alter table TARIFF_SERIES_ZONE
  add constraint FK_T_S_Z_ID_TARIFF_ZONE foreign key (ID_TARIFF_ZONE)
  references TARIFF_ZONE (ID) on delete cascade;
alter table TARIFF_SERIES_ZONE
  add constraint CHK_TARIFF_SERIES_ZONE
  check ((PRICE IS NOT NULL) OR (AMOUNT IS NOT NULL));

prompt
prompt Creating table TERM
prompt ===================
prompt
create table TERM
(
  id                NUMBER(38) not null,
  id_division       NUMBER(38),
  code              VARCHAR2(8 CHAR) default '00000001' not null,
  ins_date          DATE default sysdate not null,
  ins_id_user       NUMBER(38) not null,
  upd_date          DATE default sysdate not null,
  upd_id_user       NUMBER(38) not null,
  d                 NUMBER(1) default 0 not null,
  kind              NUMBER(1) default 1 not null,
  id_data_last      NUMBER(38),
  state             NUMBER(1) default 4 not null,
  id_file_load_last NUMBER(38),
  last_unload_date  DATE
)
;
comment on table TERM
  is 'Терминалы';
comment on column TERM.id
  is 'ИД';
comment on column TERM.id_division
  is 'ИД подразделения';
comment on column TERM.code
  is 'Код';
comment on column TERM.ins_date
  is 'Дата создания';
comment on column TERM.ins_id_user
  is 'Кто создал';
comment on column TERM.upd_date
  is 'Дата редактирования';
comment on column TERM.upd_id_user
  is 'Кто редактировал';
comment on column TERM.d
  is 'Признак удаления=1';
comment on column TERM.kind
  is '1-кассовый, 2-транспортный, 3-служебный АРМ';
comment on column TERM.id_data_last
  is 'ид последней транзакции';
comment on column TERM.state
  is 'статус (1-рабочий, 2-в ремонте, 3-выбыл из строя, 4-в резерве, 5-в блокирующем списке терминалов. )';
comment on column TERM.id_file_load_last
  is 'ИД последнего выгруженого файла';
comment on column TERM.last_unload_date
  is 'Дата последней выгрузки';
alter table TERM
  add constraint PK_TERM primary key (ID);
alter table TERM
  add constraint UQ_TERM unique (CODE);
alter table TERM
  add constraint FK_TERM_ID_DIVISION foreign key (ID_DIVISION)
  references DIVISION (ID) on delete cascade;
alter table TERM
  add constraint FK_TERM_ID_FILE_LOAD_LAST foreign key (ID_FILE_LOAD_LAST)
  references FILE_LOAD (ID);
alter table TERM
  add constraint FK_TERM_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table TERM
  add constraint FK_TERM_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table TERM
  add constraint CHK_TERM_D
  check (d in (0,1));
alter table TERM
  add constraint CHK_TERM_KIND
  check (kind in (1, 2, 3));
alter table TERM
  add constraint CHK_TERM_STATE
  check (state in (1, 2, 3, 4, 5));

prompt
prompt Creating table VEHICLE
prompt ======================
prompt
create table VEHICLE
(
  id          NUMBER(38) not null,
  id_division NUMBER(38) not null,
  code        VARCHAR2(8) not null,
  ins_date    DATE default sysdate not null,
  ins_id_user NUMBER(38) not null,
  upd_date    DATE default sysdate not null,
  upd_id_user NUMBER(38) not null,
  d           NUMBER(1) default 0 not null
)
;
comment on table VEHICLE
  is 'Подвижной состав';
comment on column VEHICLE.id
  is 'ИД';
comment on column VEHICLE.id_division
  is 'ИД подразделения';
comment on column VEHICLE.code
  is 'Код';
comment on column VEHICLE.ins_date
  is 'Дата создания';
comment on column VEHICLE.ins_id_user
  is 'Кто создал';
comment on column VEHICLE.upd_date
  is 'Дата редактирования';
comment on column VEHICLE.upd_id_user
  is 'Кто редактировал';
comment on column VEHICLE.d
  is 'Признак удаления=1';
alter table VEHICLE
  add constraint PK_VEHICLE primary key (ID);
alter table VEHICLE
  add constraint UQ_VEHICLE unique (ID_DIVISION, CODE);
alter table VEHICLE
  add constraint FK_VEHICLE_ID_DIVISION foreign key (ID_DIVISION)
  references DIVISION (ID) on delete cascade;
alter table VEHICLE
  add constraint FK_VEHICLE_INS_ID_USER foreign key (INS_ID_USER)
  references SYS$USERS (ID);
alter table VEHICLE
  add constraint FK_VEHICLE_UPD_ID_USER foreign key (UPD_ID_USER)
  references SYS$USERS (ID);
alter table VEHICLE
  add constraint CHK_VEHICLE_D
  check (d in (0,1));

prompt
prompt Creating table T_DATA
prompt =====================
prompt
create table T_DATA
(
  id                   NUMBER(38) not null,
  kind                 NUMBER(38) not null,
  date_of              DATE not null,
  file_rn              VARCHAR2(12 CHAR),
  tape_rn              VARCHAR2(3 CHAR),
  id_division          NUMBER(38),
  id_term              NUMBER(38),
  id_card              NUMBER(38),
  date_to              DATE,
  travel_doc_kind      NUMBER(1),
  ep_balance           NUMBER,
  ep_discount          NUMBER,
  st_zone_begin        VARCHAR2(2 CHAR),
  st_zone_end          VARCHAR2(2 CHAR),
  st_limit             NUMBER,
  id_card_sec          NUMBER(38),
  id_tariff_zone       NUMBER(38),
  amount               NUMBER,
  amount_bail          NUMBER,
  amount_discount      NUMBER,
  amount_privilege     NUMBER,
  ticket_num           VARCHAR2(4 CHAR),
  bank_card            VARCHAR2(19 CHAR),
  id_route             NUMBER(38),
  route_begin          DATE,
  id_route_zone_begin  NUMBER(38),
  id_route_zone_end    NUMBER(38),
  id_staff             NUMBER(38),
  id_vehicle           NUMBER(38),
  train_table          VARCHAR2(8 CHAR),
  shift_begin          DATE,
  shift_end            DATE,
  trip_begin           DATE,
  trip_end             DATE,
  ins_date             DATE not null,
  ins_id_user          NUMBER(38) not null,
  upd_date             DATE not null,
  upd_id_user          NUMBER(38) not null,
  d                    NUMBER(1) default 0 not null,
  amount_travel        NUMBER(38) default 0,
  add_text             VARCHAR2(1000 CHAR),
  card_state           NUMBER(1),
  card_activated       NUMBER(1),
  term_state           NUMBER(1),
  id_privilege         NUMBER(38),
  id_file_load         NUMBER(38),
  privilege_begin_date DATE,
  source_kind          NUMBER(1) default 1,
  id_emission_operator NUMBER(38),
  date_from            DATE,
  card_series          VARCHAR2(5),
  card_num             VARCHAR2(13),
  card_series_sec      VARCHAR2(5),
  card_num_sec         VARCHAR2(13),
  new_card_series      VARCHAR2(5),
  card_kind            NUMBER(1),
  card_chip            VARCHAR2(20),
  st_limit_ol          NUMBER,
  amount_travel_ol     NUMBER,
  price_city_ol        NUMBER,
  price_suburb_ol      NUMBER,
  id_travel_zone_begin NUMBER(38),
  id_travel_zone_end   NUMBER(38)
)
;
comment on table T_DATA
  is 'Данные (транзакции)';
comment on column T_DATA.id
  is 'ИД';
comment on column T_DATA.kind
  is 'Тип транзакции';
comment on column T_DATA.date_of
  is 'Дата + время на терминале';
comment on column T_DATA.file_rn
  is '№ файла';
comment on column T_DATA.tape_rn
  is '№ ленты';
comment on column T_DATA.id_division
  is 'ИД подразделения';
comment on column T_DATA.id_term
  is 'ИД терминала';
comment on column T_DATA.id_card
  is 'ИД карты';
comment on column T_DATA.date_to
  is 'Срок действия статуса карты до';
comment on column T_DATA.travel_doc_kind
  is 'Тип проездного документа: 1- EP электронный кошелек, 2 - SU сезонный проездной без ограничения количества поездок, 3 - SL сезонный проездной с ограничением количества поездок, 4- ET электронные поездки (т.н. Ивановская схема,  сезонного проездного с ограничением количества поездок), 5 - CT билет для проезда в кредит (сезонного проездного без ограничения количества поездок),  6-SC ? сезонный проездной с поездками в кредит, 7-LT сезонный лимитный с фиксированным количеством поездок, 8-OL Омский электронный проездной с лимитом поездок, 0 - BL Пустой';
comment on column T_DATA.ep_balance
  is 'Электронный кошелек: баланс';
comment on column T_DATA.ep_discount
  is 'Электронный кошелек: скидка';
comment on column T_DATA.st_zone_begin
  is 'Сезонный проездной: начальная зона';
comment on column T_DATA.st_zone_end
  is 'Сезонный проездной: конечная зона';
comment on column T_DATA.st_limit
  is 'Сезонный проездной: лимит. Для OL лимит для городских поездок';
comment on column T_DATA.id_card_sec
  is 'ИД карты оператора';
comment on column T_DATA.id_tariff_zone
  is 'ИД тарифной ячейки';
comment on column T_DATA.amount
  is 'Сумма операции';
comment on column T_DATA.amount_bail
  is 'Сумма залога';
comment on column T_DATA.amount_discount
  is 'Сумма скидки';
comment on column T_DATA.amount_privilege
  is 'Сумма льготы';
comment on column T_DATA.ticket_num
  is '№ квитанции';
comment on column T_DATA.bank_card
  is '№ банковской карты';
comment on column T_DATA.id_route
  is 'ИД маршрута';
comment on column T_DATA.route_begin
  is 'Дата установки маршрута';
comment on column T_DATA.id_route_zone_begin
  is 'ИД начальной зоны маршрута';
comment on column T_DATA.id_route_zone_end
  is 'ИД конечной зоны маршрута';
comment on column T_DATA.id_staff
  is 'ИД сотрудника';
comment on column T_DATA.id_vehicle
  is 'ИД подвижного состава';
comment on column T_DATA.train_table
  is 'Код строки расписания';
comment on column T_DATA.shift_begin
  is 'Дата+время открытия смены';
comment on column T_DATA.shift_end
  is 'Дата+время закрытия смены';
comment on column T_DATA.trip_begin
  is 'Дата+время начала рейса';
comment on column T_DATA.trip_end
  is 'Дата+время конца рейса';
comment on column T_DATA.ins_date
  is 'Дата создания';
comment on column T_DATA.ins_id_user
  is 'Кто создал';
comment on column T_DATA.upd_date
  is 'Дата редактирования';
comment on column T_DATA.upd_id_user
  is 'Кто редактировал';
comment on column T_DATA.d
  is 'Признак удаления=1';
comment on column T_DATA.amount_travel
  is 'Количество поездок (для СП с ограничением числа поездок), которые списываются или зачисляются на карту, для OL поездки по городу';
comment on column T_DATA.add_text
  is 'Дополнительный текст';
comment on column T_DATA.card_state
  is 'Состояние карты(1-в обращении, 2-в блок списке, 3-заблокирована, 4-в деблок списке, 5-изъята, 8-Заблокирована по списку терминалов)';
comment on column T_DATA.card_activated
  is 'Признак активизированной карты';
comment on column T_DATA.term_state
  is 'статус терминала (1-рабочий, 2-в ремонте, 3-выбыл из строя, 4-в резерве)';
comment on column T_DATA.id_privilege
  is 'ид льготы';
comment on column T_DATA.id_file_load
  is 'ид файла';
comment on column T_DATA.privilege_begin_date
  is 'Дата начала действия льготы';
comment on column T_DATA.source_kind
  is 'Тип источника (0 - вручную, 1 - загрузка, 2 - транзакция)';
comment on column T_DATA.id_emission_operator
  is 'Предприятие для которого выпущена служебная карта';
comment on column T_DATA.date_from
  is 'Срок действия статуса карты c';
comment on column T_DATA.card_series
  is 'Серия карты';
comment on column T_DATA.card_num
  is 'Номер карты';
comment on column T_DATA.card_series_sec
  is 'Серия карты оператора';
comment on column T_DATA.card_num_sec
  is 'Номер карты оператора';
comment on column T_DATA.new_card_series
  is 'Новая серия карты';
comment on column T_DATA.card_kind
  is 'Тип карты (1 - персональная транспортная карта,  2 - транспортная карта на предъявителя)';
comment on column T_DATA.card_chip
  is 'Чип';
comment on column T_DATA.st_limit_ol
  is 'Сезонный проездной: лимит для пригородных поездок OL';
comment on column T_DATA.amount_travel_ol
  is 'Количество поездок (для СП с ограничением числа поездок), которые списываются или зачисляются на карту операции для пригородных поездок OL';
comment on column T_DATA.price_city_ol
  is 'Сумма для компенсации поездок по городу для OL ';
comment on column T_DATA.price_suburb_ol
  is 'Сумма для компенсации поездок по пригороду для OL ';
comment on column T_DATA.id_travel_zone_begin
  is 'ИД начальной зоны поездки';
comment on column T_DATA.id_travel_zone_end
  is 'ИД конечной зоны поездки';
create index SI_T_DATA_TRN on T_DATA (KIND, DATE_OF, ID_CARD);
alter table T_DATA
  add constraint PK_T_DATA primary key (ID);
alter table T_DATA
  add constraint UQ_T_DATA unique (KIND, DATE_OF, FILE_RN, TAPE_RN, ID_TERM, ID_CARD, ID_PRIVILEGE, CARD_STATE);
alter table T_DATA
  add constraint FK_T_DATA_ID_CARD foreign key (ID_CARD)
  references CARD (ID) on delete cascade;
alter table T_DATA
  add constraint FK_T_DATA_ID_CARD_SEC foreign key (ID_CARD_SEC)
  references CARD (ID);
alter table T_DATA
  add constraint FK_T_DATA_ID_DIVISION foreign key (ID_DIVISION)
  references DIVISION (ID);
alter table T_DATA
  add constraint FK_T_DATA_ID_FILE_LOAD foreign key (ID_FILE_LOAD)
  references FILE_LOAD (ID) on delete cascade;
alter table T_DATA
  add constraint FK_T_DATA_ID_ID_EMISS_OPER foreign key (ID_EMISSION_OPERATOR)
  references OPERATOR (ID) on delete set null;
alter table T_DATA
  add constraint FK_T_DATA_ID_PRIVILEGE foreign key (ID_PRIVILEGE)
  references PRIVILEGE (ID) on delete cascade;
alter table T_DATA
  add constraint FK_T_DATA_ID_ROUTE foreign key (ID_ROUTE)
  references ROUTE (ID);
alter table T_DATA
  add constraint FK_T_DATA_ID_ROUTE_ZONE_B foreign key (ID_ROUTE_ZONE_BEGIN)
  references ROUTE_ZONE (ID);
alter table T_DATA
  add constraint FK_T_DATA_ID_ROUTE_ZONE_E foreign key (ID_ROUTE_ZONE_END)
  references ROUTE_ZONE (ID);
alter table T_DATA
  add constraint FK_T_DATA_ID_STAFF foreign key (ID_STAFF)
  references STAFF (ID);
alter table T_DATA
  add constraint FK_T_DATA_ID_TARIFF_ZONE foreign key (ID_TARIFF_ZONE)
  references TARIFF_ZONE (ID);
alter table T_DATA
  add constraint FK_T_DATA_ID_TERM foreign key (ID_TERM)
  references TERM (ID) on delete cascade;
alter table T_DATA
  add constraint FK_T_DATA_ID_VEHICLE foreign key (ID_VEHICLE)
  references VEHICLE (ID);
alter table T_DATA
  add constraint CHK_T_DATA_CARD_ACTIVATED
  check (card_activated IN (0,1));
alter table T_DATA
  add constraint CHK_T_DATA_CARD_KIND
  check (CARD_KIND IN (1,2));
alter table T_DATA
  add constraint CHK_T_DATA_CARD_STATE
  check (CARD_STATE IN (1,2,3,4,5,6,7,8));
alter table T_DATA
  add constraint CHK_T_DATA_D
  check (d IN (0,1));
alter table T_DATA
  add constraint CHK_T_DATA_KIND
  check (kind BETWEEN 1 AND 34);
alter table T_DATA
  add constraint CHK_T_DATA_SOURCE_KIND
  check (source_kind IN (0, 1, 2));
alter table T_DATA
  add constraint CHK_T_DATA_ST_ZONE_BEGIN
  check (ST_ZONE_BEGIN BETWEEN '00' AND '99');
alter table T_DATA
  add constraint CHK_T_DATA_ST_ZONE_END
  check (ST_ZONE_END BETWEEN '00' AND '99');
alter table T_DATA
  add constraint CHK_T_DATA_TERM_STATE
  check (term_state IN (1, 2, 3, 4, 5));
alter table T_DATA
  add constraint CHK_T_DATA_TICKET_NUM
  check (TICKET_NUM BETWEEN '0000' AND '9999');
alter table T_DATA
  add constraint CHK_T_DATA_TRAVEL_DOC_KIND
  check (TRAVEL_DOC_KIND IN (0,1,2,3,4,5,6,7,8));

prompt
prompt Creating table T_DATA_ARCHIVE
prompt =============================
prompt
create table T_DATA_ARCHIVE
(
  id                   NUMBER(38) not null,
  kind                 NUMBER(38) not null,
  date_of              DATE not null,
  file_rn              VARCHAR2(12 CHAR),
  tape_rn              VARCHAR2(3 CHAR),
  id_division          NUMBER(38),
  id_term              NUMBER(38),
  id_card              NUMBER(38),
  date_to              DATE,
  travel_doc_kind      NUMBER(1),
  ep_balance           NUMBER,
  ep_discount          NUMBER,
  st_zone_begin        VARCHAR2(2 CHAR),
  st_zone_end          VARCHAR2(2 CHAR),
  st_limit             NUMBER,
  id_card_sec          NUMBER(38),
  id_tariff_zone       NUMBER(38),
  amount               NUMBER,
  amount_bail          NUMBER,
  amount_discount      NUMBER,
  amount_privilege     NUMBER,
  ticket_num           VARCHAR2(4 CHAR),
  bank_card            VARCHAR2(19 CHAR),
  id_route             NUMBER(38),
  route_begin          DATE,
  id_route_zone_begin  NUMBER(38),
  id_route_zone_end    NUMBER(38),
  id_staff             NUMBER(38),
  id_vehicle           NUMBER(38),
  train_table          VARCHAR2(8 CHAR),
  shift_begin          DATE,
  shift_end            DATE,
  trip_begin           DATE,
  trip_end             DATE,
  ins_date             DATE not null,
  ins_id_user          NUMBER(38) not null,
  upd_date             DATE not null,
  upd_id_user          NUMBER(38) not null,
  d                    NUMBER(1) default 0 not null,
  amount_travel        NUMBER(38) default 0,
  add_text             VARCHAR2(1000 CHAR),
  card_state           NUMBER(1),
  card_activated       NUMBER(1),
  term_state           NUMBER(1),
  id_privilege         NUMBER(38),
  id_file_load         NUMBER(38),
  privilege_begin_date DATE,
  source_kind          NUMBER(1) default 1,
  id_emission_operator NUMBER(38),
  date_from            DATE,
  card_series          VARCHAR2(5),
  card_num             VARCHAR2(13),
  card_series_sec      VARCHAR2(5),
  card_num_sec         VARCHAR2(13),
  new_card_series      VARCHAR2(5),
  card_kind            NUMBER(1),
  card_chip            VARCHAR2(20 CHAR),
  st_limit_ol          NUMBER,
  amount_travel_ol     NUMBER,
  price_city_ol        NUMBER,
  price_suburb_ol      NUMBER,
  id_travel_zone_begin NUMBER(38),
  id_travel_zone_end   NUMBER(38)
)
;
comment on table T_DATA_ARCHIVE
  is 'Данные (транзакции)';
comment on column T_DATA_ARCHIVE.id
  is 'ИД';
comment on column T_DATA_ARCHIVE.kind
  is 'Тип транзакции';
comment on column T_DATA_ARCHIVE.date_of
  is 'Дата + время на терминале';
comment on column T_DATA_ARCHIVE.file_rn
  is '№ файла';
comment on column T_DATA_ARCHIVE.tape_rn
  is '№ ленты';
comment on column T_DATA_ARCHIVE.id_division
  is 'ИД подразделения';
comment on column T_DATA_ARCHIVE.id_term
  is 'ИД терминала';
comment on column T_DATA_ARCHIVE.id_card
  is 'ИД карты';
comment on column T_DATA_ARCHIVE.date_to
  is 'Срок действия статуса карты до';
comment on column T_DATA_ARCHIVE.travel_doc_kind
  is 'Тип проездного документа: 1- EP электронный кошелек, 2 - SU сезонный проездной без ограничения количества поездок, 3 - SL сезонный проездной с ограничением количества поездок, 4- ET электронные поездки (т.н. Ивановская схема,  сезонного проездного с ограничением количества поездок), 5 - CT билет для проезда в кредит (сезонного проездного без ограничения количества поездок),  6-SC ? сезонный проездной с поездками в кредит, 7-LT сезонный лимитный с фиксированным количеством поездок, 8-OL Омский электронный проездной с лимитом поездок, 0 - BL Пустой';
comment on column T_DATA_ARCHIVE.ep_balance
  is 'Электронный кошелек: баланс';
comment on column T_DATA_ARCHIVE.ep_discount
  is 'Электронный кошелек: скидка';
comment on column T_DATA_ARCHIVE.st_zone_begin
  is 'Сезонный проездной: начальная зона';
comment on column T_DATA_ARCHIVE.st_zone_end
  is 'Сезонный проездной: конечная зона';
comment on column T_DATA_ARCHIVE.st_limit
  is 'Сезонный проездной: лимит. Для OL лимит для городских поездок';
comment on column T_DATA_ARCHIVE.id_card_sec
  is 'ИД карты оператора';
comment on column T_DATA_ARCHIVE.id_tariff_zone
  is 'ИД тарифной ячейки';
comment on column T_DATA_ARCHIVE.amount
  is 'Сумма операции';
comment on column T_DATA_ARCHIVE.amount_bail
  is 'Сумма залога';
comment on column T_DATA_ARCHIVE.amount_discount
  is 'Сумма скидки';
comment on column T_DATA_ARCHIVE.amount_privilege
  is 'Сумма льготы';
comment on column T_DATA_ARCHIVE.ticket_num
  is '№ квитанции';
comment on column T_DATA_ARCHIVE.bank_card
  is '№ банковской карты';
comment on column T_DATA_ARCHIVE.id_route
  is 'ИД маршрута';
comment on column T_DATA_ARCHIVE.route_begin
  is 'Дата установки маршрута';
comment on column T_DATA_ARCHIVE.id_route_zone_begin
  is 'ИД начальной зоны маршрута';
comment on column T_DATA_ARCHIVE.id_route_zone_end
  is 'ИД конечной зоны маршрута';
comment on column T_DATA_ARCHIVE.id_staff
  is 'ИД сотрудника';
comment on column T_DATA_ARCHIVE.id_vehicle
  is 'ИД подвижного состава';
comment on column T_DATA_ARCHIVE.train_table
  is 'Код строки расписания';
comment on column T_DATA_ARCHIVE.shift_begin
  is 'Дата+время открытия смены';
comment on column T_DATA_ARCHIVE.shift_end
  is 'Дата+время закрытия смены';
comment on column T_DATA_ARCHIVE.trip_begin
  is 'Дата+время начала рейса';
comment on column T_DATA_ARCHIVE.trip_end
  is 'Дата+время конца рейса';
comment on column T_DATA_ARCHIVE.ins_date
  is 'Дата создания';
comment on column T_DATA_ARCHIVE.ins_id_user
  is 'Кто создал';
comment on column T_DATA_ARCHIVE.upd_date
  is 'Дата редактирования';
comment on column T_DATA_ARCHIVE.upd_id_user
  is 'Кто редактировал';
comment on column T_DATA_ARCHIVE.d
  is 'Признак удаления=1';
comment on column T_DATA_ARCHIVE.amount_travel
  is 'Количество поездок (для СП с ограничением числа поездок), которые списываются или зачисляются на карту, для OL поездки по городу';
comment on column T_DATA_ARCHIVE.add_text
  is 'Дополнительный текст';
comment on column T_DATA_ARCHIVE.card_state
  is 'Состояние карты(1-в обращении, 2-в блок списке, 3-заблокирована, 4-в деблок списке, 5-изъята, 8-Заблокирована по списку терминалов)';
comment on column T_DATA_ARCHIVE.card_activated
  is 'Признак активизированной карты';
comment on column T_DATA_ARCHIVE.term_state
  is 'статус терминала (1-рабочий, 2-в ремонте, 3-выбыл из строя, 4-в резерве)';
comment on column T_DATA_ARCHIVE.id_privilege
  is 'ид льготы';
comment on column T_DATA_ARCHIVE.id_file_load
  is 'ид файла';
comment on column T_DATA_ARCHIVE.privilege_begin_date
  is 'Дата начала действия льготы';
comment on column T_DATA_ARCHIVE.source_kind
  is 'Тип источника (0 - вручную, 1 - загрузка, 2 - транзакция)';
comment on column T_DATA_ARCHIVE.id_emission_operator
  is 'Предприятие для которого выпущена служебная карта';
comment on column T_DATA_ARCHIVE.date_from
  is 'Срок действия статуса карты c';
comment on column T_DATA_ARCHIVE.card_series
  is 'Серия карты';
comment on column T_DATA_ARCHIVE.card_num
  is 'Номер карты';
comment on column T_DATA_ARCHIVE.card_series_sec
  is 'Серия карты оператора';
comment on column T_DATA_ARCHIVE.card_num_sec
  is 'Номер карты оператора';
comment on column T_DATA_ARCHIVE.new_card_series
  is 'Новая серия карты';
comment on column T_DATA_ARCHIVE.card_kind
  is 'Тип карты (1 - персональная транспортная карта,  2 - транспортная карта на предъявителя)';
comment on column T_DATA_ARCHIVE.card_chip
  is 'Чип';
comment on column T_DATA_ARCHIVE.st_limit_ol
  is 'Сезонный проездной: лимит для пригородных поездок OL';
comment on column T_DATA_ARCHIVE.amount_travel_ol
  is 'Количество поездок (для СП с ограничением числа поездок), которые списываются или зачисляются на карту операции для пригородных поездок OL';
comment on column T_DATA_ARCHIVE.price_city_ol
  is 'Сумма для компенсации поездок по городу для OL ';
comment on column T_DATA_ARCHIVE.price_suburb_ol
  is 'Сумма для компенсации поездок по пригороду для OL ';
comment on column T_DATA_ARCHIVE.id_travel_zone_begin
  is 'ИД начальной зоны поездки';
comment on column T_DATA_ARCHIVE.id_travel_zone_end
  is 'ИД конечной зоны поездки';

prompt
prompt Creating table T_DATA_BUFFER
prompt ============================
prompt
create table T_DATA_BUFFER
(
  id              NUMBER(38) not null,
  id_card         NUMBER(38) not null,
  travel_doc_kind NUMBER(1) not null,
  ins_date        DATE not null,
  date_of         DATE not null,
  bal_e_f         NUMBER,
  bal_l_f         NUMBER,
  date_to         DATE,
  kind            NUMBER(2) not null,
  amount_e        NUMBER,
  amount_l        NUMBER,
  card_series     VARCHAR2(5) not null
)
;
comment on table T_DATA_BUFFER
  is 'Таблица изменений балансов карт';
comment on column T_DATA_BUFFER.id
  is 'ИД';
comment on column T_DATA_BUFFER.id_card
  is 'Идентификатор карты.';
comment on column T_DATA_BUFFER.travel_doc_kind
  is 'Тип проездного документа: 1- EP электронный кошелек, 2 - SU сезонный проездной без ограничения количества поездок, 3 - SL сезонный проездной с ограничением количества поездок, 4- ET электронные поездки (т.н. Ивановская схема,  сезонного проездного с ограничением количества поездок), 5 - CT билет для проезда в кредит (сезонного проездного без ограничения количества поездок),  6-SC ? сезонный проездной с поездками в кредит, 7-LT сезонный лимитный с фиксированным количеством поездок, 8-OL Омский электронный проездной с лимитом поездок, 0 - BL Пустой';
comment on column T_DATA_BUFFER.ins_date
  is 'Дата регистрации в БД';
comment on column T_DATA_BUFFER.date_of
  is 'Дата транзакции на терминале';
comment on column T_DATA_BUFFER.bal_e_f
  is 'Баланс электронного кошелька фактический после транзакции';
comment on column T_DATA_BUFFER.bal_l_f
  is 'Баланс поездок фактический после транзакции';
comment on column T_DATA_BUFFER.date_to
  is 'Дата окончания действия';
comment on column T_DATA_BUFFER.kind
  is 'Тип транзакции';
comment on column T_DATA_BUFFER.amount_e
  is 'Сумма операции кошелёк';
comment on column T_DATA_BUFFER.amount_l
  is 'Сумма операции поездки';
comment on column T_DATA_BUFFER.card_series
  is 'Серия карты в транзакции';
alter table T_DATA_BUFFER
  add constraint PK_T_DATA_BUFFER primary key (ID);
alter table T_DATA_BUFFER
  add constraint FK_T_DATA_BUFFER_ID_CARD foreign key (ID_CARD)
  references CARD (ID) on delete cascade;
alter table T_DATA_BUFFER
  add constraint CHK_T_DATA_BUFFER_CARD_SERIES
  check ((CARD_SERIES between '00' and '99') OR (CARD_SERIES between '00000' and '99999'));
alter table T_DATA_BUFFER
  add constraint CHK_T_DATA_BUFFER_KIND
  check (kind between 1 and 34);
alter table T_DATA_BUFFER
  add constraint CHK_T_DATA_BUFFER_TDK
  check (travel_doc_kind IN (0,1,2,3,4,5,6,7,8));

prompt
prompt Creating table T_DATA_SDP
prompt =========================
prompt
create table T_DATA_SDP
(
  id            NUMBER not null,
  sys_num       NUMBER not null,
  counter_value NUMBER not null,
  operation_sum NUMBER not null,
  date_of       TIMESTAMP(6) not null,
  id_t_data     NUMBER not null,
  state         NUMBER not null,
  oper_result   NUMBER not null
)
;
comment on column T_DATA_SDP.sys_num
  is 'РЎРёСЃС‚РµРјР°С‚РёС‡РµСЃРєРёР№ РЅРѕРјРµСЂ РєР°СЂС‚С‹';
comment on column T_DATA_SDP.counter_value
  is 'Р—РЅР°С‡РµРЅРёРµ СЃС‡РµС‚РєР° РѕС‚Р»РѕР¶РµРЅРЅС‹С… С‚СЂР°РЅР·Р°РєС†РёР№';
comment on column T_DATA_SDP.operation_sum
  is 'РЎСѓРјРјР° Р·Р°РїРёСЃР°РЅРЅР°СЏ РЅР° Р±Р°Р»Р°РЅСЃ РєР°СЂС‚';
comment on column T_DATA_SDP.date_of
  is 'Р”Р°С‚Р° СЃРѕРІРµСЂС€РµРЅРёСЏ РѕРїРµСЂР°С†РёРё РЅР° С‚РµСЂРјРёРЅР°Р»Рµ';
comment on column T_DATA_SDP.id_t_data
  is 'ID Р·Р°РїРёСЃРё РІ  T_DATA РїРѕСЂРѕРґРёРІС€РµР№ РґР°РЅРЅСѓСЋ';
comment on column T_DATA_SDP.state
  is 'СЃС‚Р°С‚СѓСЃ РѕР±СЂР°Р±РѕС‚РєРё С‚СЂР°РЅР·Р°РєС†РёРё 0- РЅРµ РІС‹РіСЂР°Р¶Р°Р»Р°СЃСЊ. 1 РІС‹РіСЂСѓР¶Р°Р»Р°СЃСЊ. 2 СѓСЃРїРµС€РЅР°СЏ РѕР±СЂР°Р±РѕС‚РєР° РЅР° СЃС‚СЂРѕРЅРµ SDP (РїРѕРґС‚РІРµСЂР¶РґРµРЅРёРµ)
';
comment on column T_DATA_SDP.oper_result
  is 'СЂРµР·СѓР»СЊС‚Р°С‚ РїСЂРёРјРµРЅРµРЅРёСЏ РѕС‚Р»РѕР¶РµРЅРЅРѕР№ С‚СЂР°РЅР·Р°РєС†РёРё: 0 РїСЂРёРјРµРЅРµРЅРёСЏ РІСЃРµР№ СЃСѓРјРјС‹, 1 С‡Р°СЃС‚РёС‡РЅРѕРµ РїСЂРёРјРµРЅРµРЅРёРµ, 2 РЅРµСѓСЃРїРµС€РЅРѕРµ РїСЂРёРјРµРЅРµРЅРёРµ РѕРїРµСЂР°С†РёРё (РѕС‚РєР°Р·)';
alter table T_DATA_SDP
  add constraint T_DATA_SDP_PK primary key (ID);
alter table T_DATA_SDP
  add constraint T_DATA_SDP_FK1 foreign key (ID_T_DATA)
  references T_DATA (ID);

prompt
prompt Creating table TERM_DIVISION_HISTORY
prompt ====================================
prompt
create table TERM_DIVISION_HISTORY
(
  id           NUMBER(38) not null,
  id_term      NUMBER(38) not null,
  id_division  NUMBER(38) not null,
  date_of      DATE not null,
  id_file_load NUMBER(38),
  id_t_data    NUMBER(38)
)
;
comment on table TERM_DIVISION_HISTORY
  is 'Журнал истории принадлежности терминала подразделению';
comment on column TERM_DIVISION_HISTORY.id
  is 'ИД';
comment on column TERM_DIVISION_HISTORY.id_term
  is 'ИД терминала';
comment on column TERM_DIVISION_HISTORY.id_division
  is 'ИД подразделения';
comment on column TERM_DIVISION_HISTORY.date_of
  is 'Дата операции';
comment on column TERM_DIVISION_HISTORY.id_file_load
  is 'ИД файла';
comment on column TERM_DIVISION_HISTORY.id_t_data
  is 'ИД транзакции';
alter table TERM_DIVISION_HISTORY
  add constraint PK_TERM_DIVISION_HISTORY primary key (ID);
alter table TERM_DIVISION_HISTORY
  add constraint UQ_TERM_DIVISION_HISTORY unique (ID_TERM, ID_DIVISION, DATE_OF);
alter table TERM_DIVISION_HISTORY
  add constraint FK_TERM_DIV_HIST_ID_DIVISION foreign key (ID_DIVISION)
  references DIVISION (ID);
alter table TERM_DIVISION_HISTORY
  add constraint FK_TERM_DIV_HIST_ID_FILE foreign key (ID_FILE_LOAD)
  references FILE_LOAD (ID) on delete set null;
alter table TERM_DIVISION_HISTORY
  add constraint FK_TERM_DIV_HIST_ID_TERM foreign key (ID_TERM)
  references TERM (ID) on delete cascade;

prompt
prompt Creating table TERM_STATE_HISTORY
prompt =================================
prompt
create table TERM_STATE_HISTORY
(
  id           NUMBER(38) not null,
  id_term      NUMBER(38) not null,
  id_file_load NUMBER(38),
  state        NUMBER(1) default 4 not null,
  date_of      DATE not null,
  date_from    DATE not null,
  source_kind  NUMBER(1) default 1 not null
)
;
comment on table TERM_STATE_HISTORY
  is 'Журнал изменений статусов терминалов';
comment on column TERM_STATE_HISTORY.id
  is 'ИД';
comment on column TERM_STATE_HISTORY.id_term
  is 'ИД терминала';
comment on column TERM_STATE_HISTORY.id_file_load
  is 'ИД файла';
comment on column TERM_STATE_HISTORY.state
  is 'Cтатус (1-рабочий, 2-в ремонте, 3-выбыл из строя, 4-в резерве, 5-в блокирующем списке терминалов. )';
comment on column TERM_STATE_HISTORY.date_of
  is 'Дата операции';
comment on column TERM_STATE_HISTORY.date_from
  is 'Дата начала действия';
comment on column TERM_STATE_HISTORY.source_kind
  is 'Тип источника (0 - вручную, 1 - загрузка, 2 - транзакция)';
alter table TERM_STATE_HISTORY
  add constraint PK_TERM_STATE_HISTORY primary key (ID);
alter table TERM_STATE_HISTORY
  add constraint UQ_TERM_STATE_HISTORY unique (ID_TERM, DATE_FROM);
alter table TERM_STATE_HISTORY
  add constraint FK_TERM_STATE_HIST_ID_FILE foreign key (ID_FILE_LOAD)
  references FILE_LOAD (ID) on delete set null;
alter table TERM_STATE_HISTORY
  add constraint FK_TERM_STATE_HIST_ID_TERM foreign key (ID_TERM)
  references TERM (ID) on delete cascade;
alter table TERM_STATE_HISTORY
  add constraint CHK_FK_TERM_STATE_HIST_STATE
  check (STATE in (1, 2, 3, 4, 5));
alter table TERM_STATE_HISTORY
  add constraint CHK_FK_TERM_ST_H_SOURCE_KIND
  check (SOURCE_KIND in (0, 1, 2));

prompt
prompt Creating table TMP_74_10
prompt ========================
prompt
create global temporary table TMP_74_10
(
  card_num        VARCHAR2(20) not null,
  ep_balance_prev NUMBER not null,
  date_of_prev    DATE not null,
  term_code_prev  VARCHAR2(20) not null,
  ep_balance_curr NUMBER not null,
  date_of_curr    DATE not null,
  term_code_curr  VARCHAR2(20) not null,
  delta           NUMBER not null
)
on commit delete rows;
comment on table TMP_74_10
  is 'Временная таблица для 10 отчёта Снежинск';

prompt
prompt Creating table X$CLOB
prompt =====================
prompt
create global temporary table X$CLOB
(
  id         NUMBER(38) not null,
  data       CLOB,
  class_name VARCHAR2(255 CHAR) not null
)
on commit delete rows;
comment on table X$CLOB
  is 'Временный CLOB';
comment on column X$CLOB.id
  is 'ИД';
comment on column X$CLOB.data
  is 'Данные';
comment on column X$CLOB.class_name
  is 'Имя класса';
alter table X$CLOB
  add constraint PK_X$CLOB primary key (ID, CLASS_NAME);

prompt
prompt Creating table X$SYS_APPACTION
prompt ==============================
prompt
create global temporary table X$SYS_APPACTION
(
  id_app    NUMBER(38) not null,
  id_action NUMBER(38) not null
)
on commit delete rows;
comment on table X$SYS_APPACTION
  is 'Временная таблица действий модуля';
comment on column X$SYS_APPACTION.id_app
  is 'Идентифкатор модуля';
comment on column X$SYS_APPACTION.id_action
  is 'Идентификатор действия';
alter table X$SYS_APPACTION
  add constraint PK_X$SYS_APPACTION primary key (ID_APP, ID_ACTION);

prompt
prompt Creating table X$SYS$APPACTS
prompt ============================
prompt
create global temporary table X$SYS$APPACTS
(
  id        NUMBER(38) not null,
  id_app    NUMBER(38) not null,
  id_action NUMBER(38) not null
)
on commit delete rows;
comment on table X$SYS$APPACTS
  is 'Временная таблица действий плагина';
comment on column X$SYS$APPACTS.id
  is 'Идентификатор';
comment on column X$SYS$APPACTS.id_app
  is 'Идентифкатор приложения';
comment on column X$SYS$APPACTS.id_action
  is 'Идентификатор действия';
alter table X$SYS$APPACTS
  add constraint PK_X$SYS$APPACTS primary key (ID);
alter table X$SYS$APPACTS
  add constraint UI_X$SYS$APPACTS_ID_APP_ACT unique (ID_APP, ID_ACTION);

prompt
prompt Creating view VW_BANK
prompt =====================
prompt
CREATE OR REPLACE VIEW VW_BANK AS
SELECT
  t.id,
  t.NAME,
  t.location,
  t.bic,
  t.corresp_account,
  t.post_address,
  t.phone,
  t.ins_date,
  t.ins_id_user,
  u1.NAME AS ins_user_name,
  u1.fullname AS ins_user_fullname,
  t.upd_date,
  t.upd_id_user,
  u2.NAME AS upd_user_name,
  u2.fullname AS upd_user_fullname,
  t.d
FROM ref_bank t, SYS$users u1, SYS$users u2
WHERE t.ins_id_user = u1.ID(+)
  AND t.upd_id_user = u2.id(+)
ORDER BY t.NAME;

prompt
prompt Creating view VW_JPERSON
prompt ========================
prompt
CREATE OR REPLACE VIEW VW_JPERSON AS
SELECT
  j.id,
  j.NAME,
  j.inn,
  j.kpp,
  j.settlement_account,
  j.director,
  j.id_director_post,
  ref_post.NAME AS director_post_name,
  j.accountant_general,
  j.phone,
  j.fax,
  j.e_mail,
  j.description,
  j.boss,
  j.ins_date,
  u1.NAME AS ins_user_name,
  u1.fullname AS ins_user_fullname,
  j.upd_date,
  j.upd_id_user,
  u2.NAME AS upd_user_name,
  u2.fullname AS upd_user_fullname,
  j.d,
  j.jur_adr_index,
  j.jur_adr_country,
  ref_c1.NAME AS jur_adr_country_name,
  ref_c1.d AS jur_adr_country_d,
  j.jur_adr_obl,
  ref_o1.NAME AS jur_adr_obl_name,
  ref_o1.d AS jur_adr_obl_d,
  j.jur_adr_rayon,
  ref_r1.NAME AS jur_adr_rayon_name,
  ref_r1.d AS jur_adr_rayon_d,
  j.jur_adr_city,
  ref_ci1.NAME AS jur_adr_city_name,
  ref_ci1.d AS jur_adr_city_d,
  j.jur_adr_street,
  ref_s1.NAME AS jur_adr_street_name,
  ref_s1.d AS jur_adr_street_d,
  j.jur_adr_house,
  j.jur_adr_build,
  j.jur_adr_flat,
  j.post_adr_index,
  j.post_adr_country,
  ref_c2.NAME AS post_adr_country_name,
  ref_c2.d AS post_adr_country_d,
  j.post_adr_obl,
  ref_o2.NAME AS post_adr_obl_name,
  ref_o2.d AS post_adr_obl_d,
  j.post_adr_rayon,
  ref_r2.NAME AS post_adr_rayon_name,
  ref_r2.d AS post_adr_rayon_d,
  j.post_adr_city,
  ref_ci2.NAME AS post_adr_city_name,
  ref_ci2.d AS post_adr_city_d,
  j.post_adr_street,
  ref_s2.NAME AS post_adr_street_name,
  ref_s2.d AS post_adr_street_d,
  j.post_adr_house,
  j.post_adr_build,
  j.post_adr_flat,
  j.id_bank_account,
  j.kbe,
  b1.NAME AS bank_account_name,
  b1.location AS bank_account_location,
  b1.bic AS bank_account_bic,
  b1.corresp_account AS bank_account_corresp_account,
  b1.post_address AS bank_account_post_address,
  b1.phone AS bank_account_phone,
  b1.ins_date AS bank_account_ins_date,
  b1.ins_id_user AS bank_account_ins_id_user,
  b1.ins_user_name AS bank_account_ins_user_name,
  b1.ins_user_fullname AS bank_account_ins_user_fullname,
  b1.upd_date AS bank_account_upd_date,
  b1.upd_id_user AS bank_account_upd_id_user,
  b1.upd_user_name AS bank_account_upd_user_name,
  b1.upd_user_fullname AS bank_account_upd_user_fullname,
  b1.d AS bank_account_d,
  j.id_bank_corresp,
  b2.NAME AS bank_corresp_name,
  b2.location AS bank_corresp_location,
  b2.bic AS bank_corresp_bic,
  b2.corresp_account AS bank_corresp_corresp_account,
  b2.post_address AS bank_corresp_post_address,
  b2.phone AS bank_corresp_phone,
  b2.ins_date AS bank_corresp_ins_date,
  b2.ins_id_user AS bank_corresp_ins_id_user,
  b2.ins_user_name AS bank_corresp_ins_user_name,
  b2.ins_user_fullname AS bank_corresp_ins_user_fullname,
  b2.upd_date AS bank_corresp_upd_date,
  b2.upd_id_user AS bank_corresp_upd_id_user,
  b2.upd_user_name AS bank_corresp_upd_user_name,
  b2.upd_user_fullname AS bank_corresp_upd_user_fullname,
  b2.d AS bank_corresp_d
FROM ref_jperson j, SYS$users u1, SYS$users u2,
  vw_bank b1, vw_bank b2,
  ref_country ref_c1, ref_obl ref_o1, ref_rayon ref_r1, ref_city ref_ci1, ref_street ref_s1,
  ref_country ref_c2, ref_obl ref_o2, ref_rayon ref_r2, ref_city ref_ci2, ref_street ref_s2,
  ref_post
WHERE j.ins_id_user = u1.ID(+)
  AND j.upd_id_user = u2.id(+)
  AND j.id_bank_account = b1.id(+)
  AND j.id_bank_corresp = b2.id(+)
  AND j.jur_adr_country = ref_c1.id(+)
  AND j.jur_adr_obl = ref_o1.id(+)
  AND j.jur_adr_rayon = ref_r1.id(+)
  AND j.jur_adr_city = ref_ci1.id(+)
  AND j.jur_adr_street = ref_s1.id(+)
  AND j.post_adr_country = ref_c2.id(+)
  AND j.post_adr_obl = ref_o2.id(+)
  AND j.post_adr_rayon = ref_r2.id(+)
  AND j.post_adr_city = ref_ci2.id(+)
  AND j.post_adr_street = ref_s2.id(+)
  AND j.id_director_post = ref_post.id(+)
ORDER BY j.NAME;

prompt
prompt Creating view VW_REGION
prompt =======================
prompt
CREATE OR REPLACE VIEW VW_REGION AS
SELECT
  t."ID",t."CODE",t."NAME",t."INS_DATE",t."INS_ID_USER",t."UPD_DATE",t."UPD_ID_USER",t."D",t."ID_PARENT",t."KIND",
  decode( cfg_pack.get_id_region(),
    t.id, 0, 1) AS alien,
  u1.NAME AS ins_user_name,
  u1.fullname AS ins_user_fullname,
  u2.NAME AS upd_user_name,
  u2.fullname AS upd_user_fullname
FROM privilege_group t,
   sys$users u1,
   sys$users u2
WHERE t.kind = 0
  AND t.ins_id_user = u1.id
  AND t.upd_id_user = u2.id
ORDER BY t.code, t.name;

prompt
prompt Creating view VW_SYS$APP
prompt ========================
prompt
CREATE OR REPLACE VIEW VW_SYS$APP AS
SELECT 
 t.id,
 t.name,
 t.guid,
 t.ins_date,
 t.ins_id_user,
 u1.NAME AS ins_user_name,
 u1.fullname AS ins_user_fullname,
 t.upd_date,
 t.upd_id_user,
 u2.NAME AS upd_user_name,
 u2.fullname AS upd_user_fullname,
 t.d,
 (SELECT
    COUNT(*)
  FROM SYS$APPACTS a
  WHERE a.id_app = t.ID) AS action_cnt
FROM sys$app t, sys$users u1, sys$users u2
WHERE t.ins_id_user = u1.id(+)
 AND t.upd_id_user = u2.id(+)
ORDER BY t.NAME;

prompt
prompt Creating view VW_SYS$GROUP
prompt ==========================
prompt
CREATE OR REPLACE VIEW VW_SYS$GROUP AS
SELECT 
  t.id,
  t.name,
  t.description,
  t.id_menu,
  m.NAME AS menu_name,
  t.ins_date,
  t.ins_id_user,
  u1.NAME AS ins_user_name,
  u1.fullname AS ins_user_fullname,
  t.upd_date,
  t.upd_id_user,
  u2.NAME AS upd_user_name,
  u2.fullname AS upd_user_fullname,
  t.d
FROM sys$groups t, sys$menu m,
  sys$users u1, sys$users u2
WHERE t.id_menu = m.id(+)
  AND t.ins_id_user = u1.id(+)
  AND t.upd_id_user = u2.id(+)
ORDER BY t.NAME;

prompt
prompt Creating view VW_SYS$MENU
prompt =========================
prompt
CREATE OR REPLACE VIEW VW_SYS$MENU AS
SELECT
   t.id,
   t.NAME,
   t.ins_date,
   t.ins_id_user,
   u1.NAME AS ins_user_name,
   u1.fullname AS ins_user_fullname,
   t.upd_date,
   t.upd_id_user,
   u2.NAME AS upd_user_name,
   u2.fullname AS upd_user_fullname,
   t.d,
   decode(
     (SELECT
        COUNT(*)
      FROM SYS$users a
      WHERE a.id_menu = t.ID) +
     (SELECT
        COUNT(*)
      FROM SYS$groups b
      WHERE b.id_menu = t.ID), 0, 0, 1) AS is_used  
 FROM sys$menu t, sys$users u1, sys$users u2
 WHERE t.ins_id_user = u1.id
   AND t.upd_id_user = u2.id
 ORDER BY upper( t.NAME);

prompt
prompt Creating view VW_SYS$USERS
prompt ==========================
prompt
CREATE OR REPLACE VIEW VW_SYS$USERS AS
SELECT
   u.id,
   u.NAME,
   u.fullname,
   u.description,
   u.id_group,
   g.NAME AS name_group,
   decode( u.id_menu,
     NULL, g.id_menu,
     u.id_menu) AS id_menu,
   decode( u.id_menu,
     NULL, mg.NAME,
     m.NAME) AS name_menu,
   decode(
     (SELECT
        COUNT(*)
      FROM all_users au
      WHERE au.username = upper( u.NAME)), 0, 0, 1) AS is_exists_ora_user,
   u.ins_date,
   u.ins_id_user,
   u1.NAME AS ins_user_name,
   u1.fullname AS ins_user_fullname,
   u.upd_date,
   u.upd_id_user,
   u2.NAME AS upd_user_name,
   u2.fullname AS upd_user_fullname,
   u.d,
   u.db_number,
   decode( u.db_number,
     (select a.db_number
      from sys$cfg a), 0, 1) AS ro,
   decode( u.name, 
     (select a.scheme
      from sys$cfg a), 1, 0) AS is_default_admin
 FROM sys$users u, sys$menu m, sys$groups g, 
   sys$menu mg, SYS$users u1, SYS$users u2
 WHERE u.id_menu = m.id(+)
   AND u.id_group = g.id(+)
   AND g.id_menu = mg.id(+)
   AND u.ins_id_user = u1.ID
   AND u.upd_id_user = u2.id
 ORDER BY u.NAME;

prompt
prompt Creating view VW_T_DATA
prompt =======================
prompt
CREATE OR REPLACE VIEW VW_T_DATA AS
SELECT "ID","KIND","DATE_OF","FILE_RN","TAPE_RN","ID_DIVISION","ID_TERM","ID_CARD","DATE_TO","TRAVEL_DOC_KIND","EP_BALANCE","EP_DISCOUNT","ST_ZONE_BEGIN","ST_ZONE_END","ST_LIMIT","ID_CARD_SEC","ID_TARIFF_ZONE","AMOUNT","AMOUNT_BAIL","AMOUNT_DISCOUNT","AMOUNT_PRIVILEGE","TICKET_NUM","BANK_CARD","ID_ROUTE","ROUTE_BEGIN","ID_ROUTE_ZONE_BEGIN","ID_ROUTE_ZONE_END","ID_STAFF","ID_VEHICLE","TRAIN_TABLE","SHIFT_BEGIN","SHIFT_END","TRIP_BEGIN","TRIP_END","INS_DATE","INS_ID_USER","UPD_DATE","UPD_ID_USER","D","AMOUNT_TRAVEL","ADD_TEXT","CARD_STATE","CARD_ACTIVATED","TERM_STATE","ID_PRIVILEGE","ID_FILE_LOAD","PRIVILEGE_BEGIN_DATE","SOURCE_KIND","ID_EMISSION_OPERATOR","DATE_FROM","CARD_SERIES","CARD_NUM","CARD_SERIES_SEC","CARD_NUM_SEC","NEW_CARD_SERIES","CARD_KIND","CARD_CHIP", "AMOUNT_TRAVEL_OL", "ST_LIMIT_OL", "PRICE_CITY_OL", "PRICE_SUBURB_OL", "ID_TRAVEL_ZONE_BEGIN", "ID_TRAVEL_ZONE_END" FROM t_data
--UNION ALL
--SELECT "ID","KIND","DATE_OF","FILE_RN","TAPE_RN","ID_DIVISION","ID_TERM","ID_CARD","DATE_TO","TRAVEL_DOC_KIND","EP_BALANCE","EP_DISCOUNT","ST_ZONE_BEGIN","ST_ZONE_END","ST_LIMIT","ID_CARD_SEC","ID_TARIFF_ZONE","AMOUNT","AMOUNT_BAIL","AMOUNT_DISCOUNT","AMOUNT_PRIVILEGE","TICKET_NUM","BANK_CARD","ID_ROUTE","ROUTE_BEGIN","ID_ROUTE_ZONE_BEGIN","ID_ROUTE_ZONE_END","ID_STAFF","ID_VEHICLE","TRAIN_TABLE","SHIFT_BEGIN","SHIFT_END","TRIP_BEGIN","TRIP_END","INS_DATE","INS_ID_USER","UPD_DATE","UPD_ID_USER","D","AMOUNT_TRAVEL","ADD_TEXT","CARD_STATE","CARD_ACTIVATED","TERM_STATE","ID_PRIVILEGE","ID_FILE_LOAD","PRIVILEGE_BEGIN_DATE","SOURCE_KIND","ID_EMISSION_OPERATOR","DATE_FROM","CARD_SERIES","CARD_NUM","CARD_SERIES_SEC","CARD_NUM_SEC","NEW_CARD_SERIES","CARD_KIND","CARD_CHIP", "AMOUNT_TRAVEL_OL", "ST_LIMIT_OL", "PRICE_CITY_OL", "PRICE_SUBURB_OL", "ID_TRAVEL_ZONE_BEGIN", "ID_TRAVEL_ZONE_END" FROM t_data_archive;;


spool off
