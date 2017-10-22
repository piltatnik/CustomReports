-- Create table
create table ref$trep_transport_type
(
  id         number not null,
  short_name varchar2(100) not null,
  name_long  varchar2(2000) not null
)
;
-- Add comments to the table 
comment on table ref$trep_transport_type
  is 'Тип транспорта';
-- Add comments to the columns 
comment on column ref$trep_transport_type.id
  is 'ID типа транспорта';
comment on column ref$trep_transport_type.short_name
  is 'Ключ типа транспорта';
comment on column ref$trep_transport_type.name_long
  is 'Наименование типа транспорта';
-- Create/Recreate primary, unique and foreign key constraints 
alter table ref$trep_transport_type
  add constraint PK_TRANSPORTTYPE_ID primary key (ID);
alter table ref$trep_transport_type
  add constraint UK_TRANSPORTTYPE_SHORTNAME unique (SHORT_NAME);
