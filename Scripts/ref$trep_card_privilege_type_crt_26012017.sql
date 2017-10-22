-- Create table
create table ref$trep_card_privilege_type
(
  id         number not null,
  short_name varchar2(100) not null,
  name_long  varchar2(2000) not null
)
;
-- Add comments to the table 
comment on table ref$trep_card_privilege_type
  is 'Вид привилегии карты';
-- Add comments to the columns 
comment on column ref$trep_card_privilege_type.id
  is 'ID вида привилегии';
comment on column ref$trep_card_privilege_type.short_name
  is 'Ключ вида привилегии';
comment on column ref$trep_card_privilege_type.name_long
  is 'Наименование вида привилегии';
-- Create/Recreate primary, unique and foreign key constraints 
alter table ref$trep_card_privilege_type
  add constraint PK_CARDPRIVILEGETYPE_ID primary key (ID);
alter table ref$trep_card_privilege_type
  add constraint UK_CARD_PRIVILEGTYPE_SHORTNAME unique (SHORT_NAME);
