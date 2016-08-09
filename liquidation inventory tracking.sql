--add in clearance info

create temp table t_clearance as
select *
from external 'C:\\clearance_04072016.csv'
(store_id smallint, prod_code smallint, upc char(20))
using (
delimiter ','
remotesource 'odbc'
skiprows 1
maxerrors 10
logdir 'C:\'
fillrecord);

create temp table t_clearance_items as
select item_key, t.prod_code
from t_clearance t
join lu_item i
on(i.upc=t.upc) and i.PROD_CODE = t.prod_code
group by 1,2
;


--inventory report for the gordon brothers
create temp table t_prod_code_v as
	select *
	from external 'H:\Adv_Mkt Dept\Generated_Reports\Unloads\prod_code_v.csv'
	(prod_code smallint, prod_dept_id smallint,prod_dept_descr char(50), prod_fmt_id smallint, prod_fmt_descr char(50), prod_type_id smallint, prod_type_descr char(50) )
	using (
	delimiter ','
	remotesource 'odbc'
	skiprows 1
	maxerrors 10
	logdir 'C:\'
	fillrecord);
	
	create temp table t_glr as
	select *
	from external 'H:\Adv_Mkt Dept\Generated_Reports\Unloads\glr_data.csv'
	(item_class bigint)
	using (
	delimiter ','
	remotesource 'odbc'
	skiprows 1
	maxerrors 10
	logdir 'C:\'
	fillrecord);
		create temp table t_store_item as
	select *
	from external 'H:\\Adv_Mkt Dept\\Generated_Reports\\Unloads\\eom_store_item.csv'
	(store_id smallint, item_id bigint, on_hand bigint, sell_prc decimal(10,2), tg_prc decimal(10,2))
	using (
	delimiter ','
	remotesource 'odbc'
	skiprows 1
	maxerrors 10
	logdir 'C:\'
	fillrecord)
	;


create temp table t_inv_fact as
select v.item_key,v.STORE_ID,  sum(v.ON_HAND) units, avg(v.TG_PRC) avg_tg_prc
from v_store_inv_fact v

where v.ON_HAND!=0
and v.STORE_ID not between 9303 and 9346
and v.STORE_ID!=9302
and v.date=current_date
group by 1,2;
--add dc inv
insert into t_inv_fact
select item_key,store_id, sum(v.ON_HAND) units, avg(v.TG_PRC) avg_tg_prc
from v_dc_inv_fact v

where v.ON_HAND!=0
and v.STORE_ID not between 9303 and 9346
and v.date=current_date
and v.STORE_ID in(7100,7200)
group by 1,2;

create temp table t_inv_fact_ as
select t.item_key, t.store_id, sum(units) units, avg(avg_tg_prc) avg_tg_prc, nvl( t.avg_tg_prc, si.tg_prc) sell_prc
from t_inv_fact t
left join lu_calc_price p
on( p.ITEM_KEY = t.item_key)
left join t_Store_item si
on(si.store_id= t.store_id and si.item_id=t.item_key)
group by 1,2,5
;

create temp table t_mkdn_items as
select mf.ITEM_KEY, mf.STORE_ID,min(mf.MKDN_PRC) mkdn_prc
from mkdn_fact mf
join lu_mkdn lm
on(mkdn_date=current_date and current_Date between mkdn_start_date and mkdn_end_date and lm.line_num=mf.line_num and lm.mkdn_key=mf.mkdn_key)
where current_date between lm.MKDN_START_DATE and lm.MKDN_END_DATE
group by 1,2
;

update t_inv_fact_ a
set sell_prc=m.mkdn_prc
from t_mkdn_items m
where a.store_id=m.store_id and a.item_key= m.item_key
;
update t_inv_fact_ a
set sell_prc=nvl(b.sell_price)
from lu_calc_price b

where a.item_key=b.item_key and a.store_id in(7100,7200)
;

create temp table t_inv_final as
select t.item_key,t.store_id, sum(units) units, avg(avg_tg_prc) avg_tg_prc, avg(nvl(sell_prc, i.MSRP)) sell_prc 
from t_inv_fact_ t
left join lu_item i
on(i.ITEM_KEY=t.item_key)
group by 1,2
;

--create the store sku initial table

create temp table t_inv_r as
	select   
	si.store_id,
	gd.GRP_DEPT_DESCR,
	pd.PROD_DEPT_DESCR, 
	pc.PROD_CODE, 
	pc.PROD_CODE_DESCR,
	pp1.PROD_CAT1_DESCR,
	pp2.PROD_CAT2_DESCR,
	pp3.PROD_CAT3_DESCR,
	v.prod_dept_descr prod_dept_descr_old,
	v.prod_fmt_descr,
	si.item_key item_key,
		si.avg_tg_prc,
	si.sell_prc,
	i.TITLE,
	i.ARTIST_LNAME,
	i.STATUS,
	i.AVAILABILITY,
	i.STREET_DATE,
	i.COST current_cost,
	
	i.MSRP,
	sum(units) units, 
	sum(i.COST * si.units) extended_curr_cost ,

	sum(si.avg_tg_prc * units) extended_tg_prc,
	sum(si.sell_prc* units) extended_sell_prc,

case when v.PROD_CODE in(472,477,482,489,492,493
) then 'CONSIGNMENT' else 'NOT CONSIGNMENT' end consign_flag,
case when i.STATUS='STORE UNIQUE' then 'Store Unique' else 'Not Store Unique' end store_unique_flag,
case when i.PROD_CODE in(71,96,97,102,105,106,337,339,376,469) then 'Merchant Designated Goods' else 'Not Merchant Designated Goods' end merchant_designated_goods,

case when i.PROD_CODE =495 then 'Augment Goods' else 'Not Augment Goods' end augment_flag,
case when ci.item_key is not null then 'Clearance' else 'Not Clearance' end clearance_flag
from t_inv_final si
 join lu_item i
on(i.ITEM_key = si.item_key)
join t_prod_code_v v
on(v.prod_code= i.prod_code)
join lu_prod_code pc
on(pc.PROD_CODE = i.prod_code)
join lu_prod_dept pd
on(pd.PROD_DEPT_ID = pc.PROD_DEPT_ID)
join lu_grp_dept gd
on(gd.GRP_DEPT_id = pc.GRP_DEPT_ID)
left join t_clearance_items ci
on(ci.item_key = i.ITEM_KEY and ci.prod_code = i.prod_code)
left join dw_stage..PROD_CAT1_stg2 pp1 
on(pp1.PROD_CAT1_KEY= i.PROD_CAT1_KEY )
 left join dw_stage..PROD_CAT2_stg2 pp2
on(pp2.PROD_CAT2_KEY= i.PROD_CAT2_KEY )
 left join dw_stage..PROD_CAT3_STG2 pp3
on(pp3.PROD_CAT3_KEY =i.PROD_CAT3_KEY)
where 

(i.prod_code in(select item_class from t_glr) or (i.prod_code in(472,477,482,489,492,493) or i.STATUS='STORE UNIQUE'))
and i.prod_Dept_id not in(94,104)
and i.GRP_DEPT_ID not in(-2,-1,13,14)


group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,25,26,27,28,29;

update t_inv_r
set sell_prc=0.75
where clearance_flag='Clearance'
;
create temp table t_inv_district as
select t.*, d.NAME district
from t_inv_r t
left join lu_store s
on(s.store_id = t.store_id)
left join lu_district d
on(d.district_id = s.district_id)
left join lu_calc_price p
on( p.ITEM_KEY = t.item_key)
left join t_Store_item si
on(si.store_id= t.store_id and si.item_id=t.item_key)
;

update t_inv_district
set district='TRADESMART'
where store_id in(9401,9402)
;

update t_inv_district
set district='MALL STORES'
where store_id in(9770,9730)
;

create temp table t_dist_prc as
select item_key, district, sqlext.admin.least(nvl(t.sell_prc,99999), nvl(t.current_cost,99999)) min_cost,
min(nvl(t.sell_prc,99999)) min_prc


from t_inv_district t
group by 1,2,3;

create temp table t_district_final as
select t.*, tt.min_prc district_min_prc, tt.min_prc* t.units district_extended_min_prc, tt.min_cost, tt.min_cost*t.units district_extended_min_cost
from t_inv_district t
left join t_dist_prc tt
on(t.district=tt.district and t.item_key = tt.item_key)
;

select sum(extended_Curr_cost) weekly_file_cost,sum(district_extended_min_cost) no_adchecklist_cost, sum(district_extended_min_prc) district_min_prc,
 sum(extended_sell_prc) weekly_sell_prc

from t_district_final
where consign_flag !='CONSIGNMENT' and status!='STORE UNIQUE';

select store_id, grp_dept_descr, prod_dept_descr, prod_code, prod_code_descr, prod_cat1_Descr, prod_cat2_Descr, prod_cat3_Descr,
prod_dept_descr_old, prod_fmt_descr, item_key, avg_tg_prc tg_prc, sell_prc, title, artist_lname, status,
availability, to_char(street_date, 'MM/DD/YYYY') street_date, current_cost, msrp, units, extended_curr_cost, extended_tg_prc, extended_sell_prc, consign_flag,
store_unique_flag, merchant_designated_goods, augment_flag, clearance_flag, district
from t_district_final
where store_id not in(9348,9668,9742);

select *
from t_district_final

