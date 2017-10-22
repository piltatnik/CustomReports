-- Create table
create table ref$trep_payment_type
(
  id         number not null,
  short_name varchar2(100) not null,
  name_long  varchar2(2000) not null
)
;
-- Add comments to the table 
comment on table ref$trep_payment_type
  is 'Тип оплаты';
-- Add comments to the columns 
comment on column ref$trep_payment_type.id
  is 'ID типа оплаты';
comment on column ref$trep_payment_type.short_name
  is 'Ключ типа оплаты';
comment on column ref$trep_payment_type.name_long
  is 'Наименование типа оплаты';
-- Create/Recreate primary, unique and foreign key constraints 
alter table ref$trep_payment_type
  add constraint PK_PAYMENTTYPE_ID primary key (ID);
alter table ref$trep_payment_type
  add constraint UK_PAYMENTTTYPE_SHORTNAME unique (SHORT_NAME);
