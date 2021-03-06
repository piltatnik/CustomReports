PL/SQL Developer Test script 3.0
455
-- Created on 01.07.2017 by PILAR 
DECLARE
  -- Local variables here
  i INTEGER;
BEGIN
  -- Test statements here
  :vActivationHalfBeginDate := add_months(trunc(:pActivationEndDate, 'mm'),
                                          -1) + 22;
  :vActivationHalfEndDate   := add_months(trunc(:pActivationEndDate, 'mm'),
                                          1) - 14;
  select count(distinct card_num) 
  into :vEPSLCount 
  from cptt.t_data   trans,
           cptt.division div
      WHERE trans.kind IN (7, 8, 10, 11, 12, 13, 36, 37) --���������
      AND trans.d = 0 -- �� ������
      AND date_of >= :pActivationBeginDate
      AND date_of < trunc(:pActivationEndDate) + 1
      AND nvl(trans.new_card_series, trans.card_series) IN ('10', '90', '60');
  
  OPEN :cur FOR
    WITH trans_activepass AS
     (SELECT nvl(amount, 0) - nvl(amount_bail, 0) AS amount,
             nvl(trans.new_card_series, trans.card_series) AS series,
             decode(nvl(trans.new_card_series, trans.card_series),
                    '17',
                    trans.id_privilege,
                    NULL) AS id_privilege,
             CASE
               WHEN trans.kind IN (7, 8, 10, 11, 12, 13, 36, 37) THEN
                'ACTIVE'
               WHEN trans.kind IN (32, 14, 16, 17, 20) THEN
                'PASS'
             END AS trans_type,
             div.id_operator,
             trans.kind,
             trans.card_num
      FROM cptt.t_data   trans,
           cptt.division div
      WHERE (trans.kind IN (7, 8, 10, 11, 12, 13, 36, 37) --���������
            OR -- ���� �� ��������
            trans.kind IN (32, 14, 16, 17, 20) --������
            )
      AND trans.d = 0 -- �� ������
      AND date_of >= CASE
              WHEN trans.kind IN (32, 14, 16, 17, 20) THEN
               :pPassBeginDate
              WHEN trans.kind IN (7, 8, 10, 11, 12, 13, 36, 37) THEN
               CASE
                 WHEN nvl(trans.new_card_series, trans.card_series) IN
                      ('50', '52', '53') THEN
                  :vActivationHalfBeginDate
                 ELSE
                  :pActivationBeginDate
               END
            END
      AND date_of < CASE
              WHEN trans.kind IN (32, 14, 16, 17, 20) THEN
               :pPassEndDate
              WHEN (trans.kind IN (7, 8, 10, 11, 12, 13,36, 37)) THEN
               CASE
                 WHEN nvl(trans.new_card_series, trans.card_series) IN
                      ('50', '52', '53') THEN
                  :vActivationHalfEndDate
                 ELSE
                  trunc(:pActivationEndDate) + 1
               END
            END
      AND (nvl(trans.new_card_series, trans.card_series) IN
            ('11',
             '12',
             '13',
             '14',
             '15',
             '16',
             '17',
             '19',
             '50',
             '41',
             '44',
             '21',
             '22',
             '24',
             '25',
             '29',
             '52',
             '42',
             '45',
             '31',
             '32',
             '34',
             '35',
             '39',
             '53',
             '43',
             '46',
             '96',
             '10',
             '90',
             '60') OR nvl(trans.new_card_series, trans.card_series) IS NULL)
      AND trans.id_division = div.id --����������� ��������������� ���������� � ��������������� ������������
      AND div.id_operator NOT IN
            (SELECT id
             FROM cptt.ref$trep_agents_locked
             UNION
             SELECT id
             FROM cptt.ref$trep_commcarrier_locked)),
    trans_grouped_first as (SELECT trans_type,
           series,
           id_privilege,
           id_operator,
           kind,
           nvl(case 
                  when trans_type = 'PASS' then SUM(1)
                  when trans_type = 'ACTIVE' then 
                    case when series in ('10', '90', '60') then 0 else SUM(1) end 
               end, 0) as count_trans,
--           nvl(case when series in ('10', '90', '60') then count(distinct card_num) else SUM(1) end, 0) as count_trans,
           nvl(SUM(amount), 0) as sum_trans
    FROM trans_activepass ta
    GROUP BY trans_type,
             series,
             id_privilege,
             id_operator,
             kind),
     contents as 
     (select '1.' as key, '' as parent_key, '���������� ������������������� ������������ �����, ����� � ��� �����:' as caption from dual
     union all
     select '1.1.' as key, '1.' as parent_key, '������������ ����� "��������"' as caption from dual
     union all
     select '1.1.1.' as key, '1.1.' as parent_key, '�� 1 ���' as caption from dual
     union all
     select '1.1.1.1.' as key, '1.1.1.' as parent_key, '��������' as caption from dual
     union all
     select '1.1.1.2.' as key, '1.1.1.' as parent_key, '��������' as caption from dual
     union all
     select '1.1.2.' as key, '1.1.' as parent_key, '�� 2 ���� ����������' as caption from dual
     union all
     select '1.1.2.1.' as key, '1.1.2.' as parent_key, '��������' as caption from dual
     union all
     select '1.1.2.2.' as key, '1.1.2.' as parent_key, '��������' as caption from dual
     union all
     select '1.1.2.3.' as key, '1.1.2.' as parent_key, '����������' as caption from dual
     union all
     select '1.2.' as key, '1.' as parent_key, '������������ ����� "������������"' as caption from dual
     union all
     select '1.2.1.' as key, '1.2.' as parent_key, '�� 1 ���' as caption from dual
     union all
     select '1.2.1.1.' as key, '1.2.1.' as parent_key, '��������' as caption from dual
     union all
     select '1.2.1.2.' as key, '1.2.1.' as parent_key, '��������' as caption from dual
     union all
     select '1.2.2.' as key, '1.2.' as parent_key, '�� 2 ���� ����������' as caption from dual
     union all
     select '1.2.2.1.' as key, '1.2.2.' as parent_key, '��������' as caption from dual
     union all
     select '1.2.2.2.' as key, '1.2.2.' as parent_key, '��������' as caption from dual
     union all
     select '1.2.2.3.' as key, '1.2.2.' as parent_key, '����������' as caption from dual
     union all
     select '1.3.' as key, '1.' as parent_key, '������������ ����� "��������"' as caption from dual
     union all
     select '1.3.1.' as key, '1.3.' as parent_key, '��������� ���������' as caption from dual
     union all
     select '1.3.1.'||row_number() over(order by code)||'.' as key, '1.3.1.' as parent_key, lower(name) || ' (' || code || ')' as caption  from cptt.privilege where code LIKE '000000__'
     union all
     select '1.3.2.' as key, '1.3.' as parent_key, '����������� ���������' as caption from dual
     union all
     select '1.3.3.' as key, '1.3.' as parent_key, '������������ ���������' as caption from dual
     union all
     select '1.3.3.'||row_number() over(order by code)||'.' as key, '1.3.3.' as parent_key, lower(name) || ' (' || code || ')' as caption  from cptt.privilege where code LIKE '100000__'
     union all
     select '2.' as key, '' as parent_key, '������������ ����� "���������", � ��� �����:' as caption from dual
     union all
     select '2.1.' as key, '2.' as parent_key, '��������� ����� �� ����� (����������� ����� �������� Mifare)' as caption from dual
     union all
     select '2.1.1.' as key, '2.1.' as parent_key, '�� 1 ��� � �.�����' as caption from dual
     union all
     select '2.1.1.1.' as key, '2.1.1.' as parent_key, '�������� ������' as caption from dual
     union all
     select '2.1.1.2.' as key, '2.1.1.' as parent_key, '�������� (�� ���������)' as caption from dual
     union all
     select '2.1.1.3.' as key, '2.1.1.' as parent_key, '�����������' as caption from dual
     union all
     select '2.1.2.' as key, '2.1.' as parent_key, '�� 2 ���� � �.�����' as caption from dual
     union all
     select '2.1.2.1.' as key, '2.1.2.' as parent_key, '�������� ������' as caption from dual
     union all
     select '2.1.2.2.' as key, '2.1.2.' as parent_key, '�������� (�� ���������)' as caption from dual
     union all
     select '2.1.2.3.' as key, '2.1.2.' as parent_key, '�����������' as caption from dual
     union all
     select '2.2.' as key, '2.' as parent_key, '������������ ����� ��������� Ultralight (������������� �������� �����)' as caption from dual
     union all
     select '3.' as key, '' as parent_key, '�� �������� �������� ��������, �����' as caption from dual
     union all
     select '4.' as key, '' as parent_key, '����� VISA/����������� �������' as caption from dual),
trans_grouped_second as(     
     select case
              when series in ('24', '34') then '1.1.1.1.'
              when series in ('25', '35') then '1.1.1.2.'
              when series in ('14') then '1.1.2.1.'
              when series in ('15') then '1.1.2.2.'
              when series in ('16') then '1.1.2.3.'
              when series in ('21', '31') then '1.2.1.1.'
              when series in ('22', '32') then '1.2.1.2.'
              when series in ('11') then '1.2.2.1.'
              when series in ('12') then '1.2.2.2.'
              when series in ('13') then '1.2.2.3.'
              when series in ('17') then case
                                         when priv.code LIKE '000000__' then '1.3.1.'||to_char(priv.num)||'.'
                                         when priv.code LIKE '200%' then '1.3.2.'
                                         when priv.code LIKE '100000__' then '1.3.3.'||to_char(priv.num)||'.'    
                                         end
              when series in ('29', '39') then '2.1.1.1.'
              when series in ('52', '53') then '2.1.1.2.'
              when series in ('42', '45', '43', '46') then '2.1.1.3.'
              when series in ('19') then '2.1.2.1.'
              when series in ('50') then '2.1.2.2.'
              when series in ('41', '44') then '2.1.2.3.'  
              when series is null then '3.'
              when series in ('10', '90', '60', '96') then '4.'
            end as key,
           tgf.trans_type,
           tgf.series,
           tgf.id_privilege,
           tgf.id_operator,
           tgf.kind,
           tgf.count_trans,
           tgf.sum_trans 
           from trans_grouped_first tgf 
                left outer join (select id, code, 
                                            row_number() over(partition by case when code LIKE '000000__' then 1 when code LIKE '200%' then 2 when code LIKE '100000__' then 3 else 4 end order by code) as num 
                                 from cptt.privilege where code LIKE '000000__' or code LIKE '200%' or code LIKE '100000__') priv 
                             on tgf.id_privilege = priv.id),
     carriers as 
     (SELECT id, name
        FROM operator
        WHERE id NOT IN (SELECT id
                            FROM cptt.ref$trep_agents_locked
                        UNION
                        SELECT id
                            FROM cptt.ref$trep_commcarrier_locked)
               AND role = 1),
     contents_trans as
     (select con.key, con.parent_key, con.caption, 
             tgs.trans_type,
             tgs.series,
             tgs.id_privilege,
             tgs.id_operator,
             tgs.kind,
             tgs.count_trans,
             tgs.sum_trans 
     from contents con
          left outer join trans_grouped_second tgs
               on (tgs.key = con.key))/*,
     page1_pre1 as
     (select ct.key, ct.parent_key, ct.caption, 
            sum(case when ct.trans_type='ACTIVE' then count_trans else 0 end) + decode(key, '4.', :vEPSLCount, 0) as count_active_all,
            sum(case when ct.trans_type='ACTIVE' AND (car.id not in (400246845, 500246845)) then count_trans else null end) as count_active_other,
            sum(case when (ct.trans_type='ACTIVE') AND (car.id is null OR car.id in (500246845)) AND (series in ('31', '32', '34', '35', '36', '39', '53', '43', '46')) then count_trans else null end) as count_active_ak,
            sum(case when (ct.trans_type='ACTIVE') AND (car.id is null OR car.id in (400246845)) AND (series in ('21', '22', '24', '25', '26', '29', '52', '42', '45')) then count_trans else null end) as count_active_urt,
            sum(case when ct.trans_type='PASS' then decode(kind, 20, -count_trans, count_trans) else 0 end) as count_pass_all,
            sum(case when ct.trans_type='PASS' AND car.id not in (400246845, 500246845) then decode(kind, 20, -count_trans, count_trans) else 0 end) as count_pass_other,
            sum(case when ct.trans_type='PASS' AND car.id in (500246845) then decode(kind, 20, -count_trans, count_trans) else 0 end) as count_pass_ak,
            sum(case when ct.trans_type='PASS' AND car.id in (400246845) then decode(kind, 20, -count_trans, count_trans) else 0 end) as count_pass_urt
     from contents_trans ct
          left outer join carriers car 
               on ct.id_operator = car.id     
     group by ct.key, ct.parent_key, ct.caption),
     page1_pre2 as (select *
     from page1_pre1
     start with parent_key is null
     connect by prior key = parent_key
     model 
     dimension by (key, parent_key, caption, rownum r)
     measures(count_active_all, count_active_other, count_active_ak, count_active_urt, count_pass_all, count_pass_other, count_pass_ak, count_pass_urt)
     rules 
     (
       count_active_all[any, any, any, any] order by r desc = nvl(count_active_all[cv(), cv(), cv(), cv()], 0) + nvl(sum(count_active_all)[any, cv(key), any, any], 0),
       count_active_other[any, for parent_key in ('1.1.1.', '1.2.1.', '2.1.1.'), any, any] = nvl(count_active_other[cv(), cv(), cv(), cv()], 0),
       count_active_other[for key in ('1.1.1.', '1.2.1.', '2.1.1.'), any, any, any] order by r desc = nvl(count_active_other[cv(), cv(), cv(), cv()], 0) + nvl(sum(count_active_other)[any, cv(key), any, any], 0),
       count_active_ak[any, for parent_key in ('1.1.1.', '1.2.1.', '2.1.1.'), any, any] = nvl(count_active_ak[cv(), cv(), cv(), cv()], 0),
       count_active_ak[for key in ('1.1.1.', '1.2.1.', '2.1.1.'), any, any, any] order by r desc = nvl(count_active_ak[cv(), cv(), cv(), cv()], 0) + nvl(sum(count_active_ak)[any, cv(key), any, any], 0),
       count_active_urt[any, for parent_key in ('1.1.1.', '1.2.1.', '2.1.1.'), any, any] = nvl(count_active_urt[cv(), cv(), cv(), cv()], 0),
       count_active_urt[for key in ('1.1.1.', '1.2.1.', '2.1.1.'), any, any, any] order by r desc = nvl(count_active_urt[cv(), cv(), cv(), cv()], 0) + nvl(sum(count_active_urt)[any, cv(key), any, any], 0),
       count_pass_all[any, any, any, any] order by r desc = nvl(count_pass_all[cv(), cv(), cv(), cv()], 0) + nvl(sum(count_pass_all)[any, cv(key), any, any], 0),
       count_pass_other[any, any, any, any] order by r desc = nvl(count_pass_other[cv(), cv(), cv(), cv()], 0) + nvl(sum(count_pass_other)[any, cv(key), any, any], 0),
       count_pass_ak[any, any, any, any] order by r desc = nvl(count_pass_ak[cv(), cv(), cv(), cv()], 0) + nvl(sum(count_pass_ak)[any, cv(key), any, any], 0),
       count_pass_urt[any, any, any, any] order by r desc = nvl(count_pass_urt[cv(), cv(), cv(), cv()], 0) + nvl(sum(count_pass_urt)[any, cv(key), any, any], 0)
     )),
     page1_pre3 as
     (select key, parent_key, caption, 
            count_active_all, count_active_other, count_active_ak, count_active_urt, 
            count_pass_all, count_pass_other, count_pass_ak, count_pass_urt,
            round(case
                    when key in ('3.') 
                      then 1
                    when (key in ('1.1.1.', '1.2.1.', '2.1.1.') OR parent_key in ('1.1.1.', '1.2.1.', '2.1.1.'))
                      then decode(count_pass_other + count_pass_ak, 0, 0, count_pass_other/(count_pass_other + count_pass_ak))
                    when count_pass_all > 0
                      then count_pass_other/count_pass_all
                    else 0
                  end, 4) as coeff_other,
            round(case
                    when key in ('3.') 
                      then 1
                    when (key in ('1.1.1.', '1.2.1.', '2.1.1.') OR parent_key in ('1.1.1.', '1.2.1.', '2.1.1.'))
                      then decode(count_pass_other + count_pass_ak, 0, 0, count_pass_ak/(count_pass_other + count_pass_ak))
                    when count_pass_all > 0
                      then count_pass_ak/count_pass_all
                    else 0
                  end, 4) as coeff_ak,
            round(case
                    when key in ('3.') 
                      then 1
                    when (key in ('1.1.1.', '1.2.1.', '2.1.1.') OR parent_key in ('1.1.1.', '1.2.1.', '2.1.1.'))
                      then 1
                    when count_pass_all > 0 --����� ����� ����������� �� 0.0001 ��-�� ����������
                      then 1 - round(count_pass_other/count_pass_all, 4) - round(count_pass_ak/count_pass_all, 4)
                    else 0
                  end, 4) as coeff_urt
     from page1_pre2),
     page1_final as (
     select key, parent_key, caption,
            count_active_all, count_active_other, count_active_ak, count_active_urt, 
            count_pass_all, count_pass_other, count_pass_ak, count_pass_urt,
            coeff_other + coeff_ak + coeff_urt as coeff_all, coeff_other, coeff_ak, coeff_urt
     from page1_pre3)*/,
     page_carrier_pre1 as
     (select ct.key, ct.parent_key, ct.caption, car.id as id_carrier,
            sum(case 
                    when ct.trans_type='ACTIVE' and series is not null and series not in ('96')
                      then case
                             when car.id in (500246845) AND (series not in ('21', '22', '24', '25', '26', '29', '52', '42', '45') or series is null) then count_trans 
                             when car.id in (400246845) AND (series not in ('31', '32', '34', '35', '36', '39', '53', '43', '46') or series is null) then count_trans
                             when car.id not in (400246845, 500246845) AND (series not in ('21', '22', '24', '25', '26', '29', '52', '42', '45') /*or series is null*/) then count_trans
                             else 0
                           end
                    when ct.trans_type='PASS' and (series is null OR series in ('96')) and ct.id_operator = car.id
                         then decode(kind, 20, -count_trans, count_trans)
                    else 0 end)  /*������� EP/SL*/
             + decode(key, '4.', :vEPSLCount, 0) as count_active_carrier,
             sum(case 
                    when ct.trans_type='ACTIVE' and series is not null and series not in ('96')
                      then case
                             when car.id in (500246845) AND (series not in ('21', '22', '24', '25', '26', '29', '52', '42', '45') or series is null) then sum_trans 
                             when car.id in (400246845) AND (series not in ('31', '32', '34', '35', '36', '39', '53', '43', '46') or series is null) then sum_trans
                             when car.id not in (400246845, 500246845) AND (series not in ('21', '22', '24', '25', '26', '29', '52', '42', '45') or series is null) then sum_trans
                             else 0
                           end
                    when ct.trans_type='PASS' and (series is null OR series in ('96')) and ct.id_operator = car.id
                         then decode(kind, 20, -sum_trans, sum_trans)
                    else 0 end)  as sum_active_carrier,
             sum(case
                    when ct.trans_type='PASS' and ct.id_operator = car.id 
                      then decode(kind, 20, -count_trans, count_trans)            
                    else 0
                 end) as count_pass_carrier
     from contents_trans ct
          cross join carriers car
       group by ct.key, ct.parent_key, ct.caption, car.id),
     page_carrier_pre2 as 
     (select pcp.key, pcp.parent_key, pcp.caption, pcp.id_carrier, 
            pcp.count_active_carrier, pcp.sum_active_carrier, 
            pcp.count_pass_carrier, 
            SUM(pcp.count_pass_carrier) OVER (partition by pcp.key, pcp.parent_key) as count_pass_all,
            pcp_akother.count_pass_akother
     from page_carrier_pre1 pcp
          left outer join (select key, SUM(count_pass_carrier) as count_pass_akother from page_carrier_pre1 where id_carrier <> 400246845 group by key) pcp_akother
               on pcp.key = pcp_akother.key),
     page_carrier_pre3 as
     (select key, parent_key, caption, id_carrier,
            count_active_carrier, sum_active_carrier,
            count_pass_carrier,
            round(case when key in ('3.')
                       then 1
                  when (key in ('1.1.1.', '1.2.1.', '2.1.1.') OR parent_key in ('1.1.1.', '1.2.1.', '2.1.1.')) then
                    case
                      when id_carrier = 400246845
                        then 1
                      when count_pass_akother > 0 
                        then count_pass_carrier/count_pass_akother
                    end
                  when count_pass_all > 0 
                    then count_pass_carrier/count_pass_all
             end, 7) as coeff
     from page_carrier_pre2),
     page_carrier_pre4 as
     (select key, parent_key, caption, id_carrier,
            count_active_carrier, sum_active_carrier,
            count_pass_carrier, 
            coeff,
            sum(coeff) OVER (partition by key, parent_key) as coeff_sum
     from page_carrier_pre3),
     page_carrier_pre5 as 
     (select key, parent_key, caption, id_carrier,
            count_active_carrier, sum_active_carrier,
            count_pass_carrier,
            coeff as coeff_old,
            coeff_sum,
            case id_carrier
                      when 500246845 then
                        coeff+round(coeff_sum)-coeff_sum
                      else
                        coeff
                    end as coeff
     from page_carrier_pre4),
     page_carrier_pre6 as
     (select key, parent_key, caption, id_carrier,
            count_active_carrier, 
            count_pass_carrier,
            coeff,
            case when count_active_carrier > 0
              then sum_active_carrier/count_active_carrier
            end as pass_doc_cost,
            sum_active_carrier * coeff as sum_total
     from page_carrier_pre5),
     page_carrier_pre7 as
     (select key, parent_key, caption, id_carrier,
             count_active_carrier,
            count_pass_carrier,
            coeff,
            case 
              when key in ('4.') 
                then lag(pass_doc_cost) over(order by id_carrier, key)
              else
                pass_doc_cost
            end as pass_doc_cost,
            round(sum_total, 2) as sum_total,
            round(sum_total * 0.0298, 2) as sum_total_investor 
     from page_carrier_pre6),
     page_carrier_pre8 as
     (select *
     from page_carrier_pre7
     model 
     dimension by (key, parent_key, caption, id_carrier, rownum r)
     measures(count_active_carrier, count_pass_carrier, coeff, pass_doc_cost, sum_total, sum_total_investor)
     rules(
         count_active_carrier[any, any, any, any, any] order by r desc = nvl(count_active_carrier[cv(), cv(), cv(), cv(), cv()], 0) + nvl(sum(count_active_carrier)[any, cv(key), any, cv(id_carrier), any], 0),
         sum_total[any, any, any, any, any] order by r desc = nvl(sum_total[cv(), cv(), cv(), cv(), cv()], 0) + nvl(sum(sum_total)[any, cv(key), any, cv(id_carrier), any], 0),
         sum_total_investor[any, any, any, any, any] order by r desc = nvl(sum_total_investor[cv(), cv(), cv(), cv(), cv()], 0) + nvl(sum(sum_total_investor)[any, cv(key), any, cv(id_carrier), any], 0)
     )),
     page_carrier_final as
     (select key, parent_key, caption, 
            id_carrier,
            dense_rank() over(order by case when id_carrier in (400246845, 500246845) then 1 else 2 end, id_carrier)+1 as list_num,
            count_active_carrier, count_pass_carrier, 
            coeff, pass_doc_cost, sum_total, 
            sum_total_investor
     from page_carrier_pre8)
     select * from page_carrier_final
     order by id_carrier, key
     ;
END;
9
cur
1
<Cursor>
116
vEPSLCount
1
111
3
vCashCost
1
19
-3
pActivationBeginDate
1
16.05.2017
12
pActivationEndDate
1
15.06.2017
12
pPassBeginDate
1
01.06.2017 3:00:00
12
pPassEndDate
1
01.07.2017 3:00:00
12
vActivationHalfBeginDate
1
23.05.2017
12
vActivationHalfEndDate
1
17.06.2017
12
0
