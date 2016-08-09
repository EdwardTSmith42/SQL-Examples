--analysis of store to store transfers:  did the product actually sell off when we transfered it?

--insert 9830 item data
create temp table t_sts as
select *
from external 'C:\\store_to_store_transfers.unl'
(prod_dept char(50), prod_code smallint, prod_cat1 char(50), prod_cat2 char(50), 
item_id decimal(12,1), upc char(50), isbn char(50), ean char(50), artist_lname char(50), 
artist_fname char(50), title char(50), availability char(10), returnable char(10), 
status char(10), street_Date char(50), shipfrom smallint, shipto smallint, doc_date char(50), 
rtn_comment char(50), qty decimal(12,1), amt decimal(12,2))
using (
delimiter '|'
remotesource 'odbc'
skiprows 1
maxerrors 10
logdir 'C:\'
fillrecord)
;


--select *
--from v_store_inv_fact v
--where item_key=2777802198
--and store_id=9894
--and v.date in('2015-08-24','2015-08-25','2015-08-26','2015-08-27','2015-08-28')
--
--;
create temp table t_item as
select item_id::bigint item_key, shipto, doc_date::date recv_Date, sum(qty) qty, sum(amt) amt
from t_sts
group by 1,2,3;

create temp table t_item_sum as
select item_key, shipto, sum(qty) qty, sum(amt) amt
from t_item
group by 1,2;

select sum(qty), sum(amt)
from t_item_sum;


--get the inventory of the loaded items
create temp table t_inv_before as
select i.item_key, v.STORE_ID, v.DATE,
	sum(v.ON_HAND) units_before_xfer,
	sum(v.ON_HAND * i.COST) ext_cost_before_xfer
from  t_item t
 join v_store_inv_Fact v
on(t.item_key=v.item_key and v.STORE_ID = t.shipto)
 join lu_item i
on (i.ITEM_KEY=t.item_key)

 join lu_prod_dept pd
on(pd.PROD_DEPT_ID = i.PROD_DEPT_ID and pd.GRP_DEPT_ID = i.GRP_DEPT_ID)
 join lu_grp_dept gd
on(gd.GRP_DEPT_ID = i.GRP_DEPT_ID)
 join lu_prod_group pg
on(pg.PROD_GROUP_ID= i.PROD_GROUP_ID)
and i.PROD_DEPT_ID not in(107,-2,9,9999,102,101,-1,89)
and v.STORE_ID = t.shipto
and v.DATE= t.recv_date
group by 1,2,3;

create temp table t_inv_before_final as
select item_key, STORE_ID, min(date) first_xfer, max(date) last_xfer,
	min(units_before_xfer) units_before_xfer_min,
	max(units_before_xfer) units_before_xfer_max,
	min(ext_cost_before_xfer) ext_cost_before_xfer_min,
		max(ext_cost_before_xfer) ext_cost_before_xfer_max
from t_inv_before
group by 1,2;

create temp table t_inv_after as
select i.item_key, v.STORE_ID, v.DATE,
	sum(v.ON_HAND) units_after_xfer,
	sum(v.ON_HAND * i.COST) ext_cost_after_xfer
from  t_item t
 join lu_item i
on (i.ITEM_KEY=t.item_key)
 join v_store_inv_Fact v
on(t.item_key=v.item_key and v.STORE_ID = t.shipto)
 join lu_prod_dept pd
on(pd.PROD_DEPT_ID = i.PROD_DEPT_ID and pd.GRP_DEPT_ID = i.GRP_DEPT_ID)
 join lu_grp_dept gd
on(gd.GRP_DEPT_ID = i.GRP_DEPT_ID)
 join lu_prod_group pg
on(pg.PROD_GROUP_ID= i.PROD_GROUP_ID)
and i.PROD_DEPT_ID not in(107,-2,9,9999,102,101,-1,89)
and v.STORE_ID = t.shipto
and v.DATE= t.recv_date+1
group by 1,2,3;


create temp table t_inv_after_final as
select item_key, STORE_ID, min(date) first_xfer, max(date) last_xfer,
	min(units_before_xfer) units_after_xfer_min,
	max(units_before_xfer) units_after_xfer_max,
	min(ext_cost_before_xfer) ext_cost_after_xfer_min,
		max(ext_cost_before_xfer) ext_cost_after_xfer_max
from t_inv_before
group by 1,2;


create temp table t_sales as
select	  a11.item_key, a11.STORE_ID,


		sum(a11.QTY_SOLD)  units_sold,
	sum(a11.NET_SALES_AMT + a11.COUP_AMT) revenue_dlr,
	sum(a11.NET_SALES_AMT + a11.COUP_AMT - a11.NET_COST) margin_dlr
from	SALES_FACT_DTL	a11
	join t_item t
	on(a11.ITEM_KEY=t.item_key and a11.STORE_ID= t.shipto)
	left outer join	REL_STORE_GRP_ALL	a12
	  on 	(a11.STORE_ID = a12.STORE_ID)
	left outer join	LU_ITEM	a14
	  on 	(a11.ITEM_KEY = a14.ITEM_KEY)
	left outer join lu_prod_group pg
on(pg.PROD_GROUP_ID= a14.PROD_GROUP_ID)
	  join lu_prod_dept pd
on(pd.PROD_DEPT_ID = a14.PROD_DEPT_ID and pd.GRP_DEPT_ID = a14.GRP_DEPT_ID)
join lu_grp_dept gd
on(gd.GRP_DEPT_ID = a14.GRP_DEPT_ID)
 join lu_prod_cat1 p1
on(p1.PROD_CODE = a14.PROD_CODE and p1.PROD_DEPT_ID = a14.PROD_DEPT_ID and p1.PROD_CAT1_KEY = a14.PROD_CAT1_KEY)
 join lu_prod_cat2 p2
on(p2.PROD_CODE = a14.PROD_CODE and p2.PROD_DEPT_ID = a14.PROD_DEPT_ID and p2.PROD_CAT1_KEY = a14.PROD_CAT1_KEY and p2.PROD_CAT2_KEY= a14.PROD_CAT2_KEY)
 join lu_prod_cat3 p3
on(p3.PROD_CODE = a14.PROD_CODE and p3.PROD_DEPT_ID = a14.PROD_DEPT_ID and p3.PROD_CAT1_KEY = a14.PROD_CAT1_KEY and p3.PROD_CAT2_KEY= a14.PROD_CAT2_KEY and p3.PROD_CAT3_KEY= a14.PROD_CAT3_KEY)
join lu_date dd
on(dd.DATE= a11.BUS_DATE)
where	(a12.STORE_GRP_ALL_ID in (1000)

 and a11.IS_OVRNG in ('N')
and a11.BUS_DATE between recv_date+1 and current_date-1)
 group by	1,2;
 
 select t.*, 
 	 units_before_xfer_min,
	units_before_xfer_max,
	 ext_cost_before_xfer_min,
	ext_cost_before_xfer_max,
b.first_xfer,  b.last_xfer,
	 units_after_xfer_min,
	units_after_xfer_max,
	 ext_cost_after_xfer_min,
	ext_cost_after_xfer_max,
 units_sold,
revenue_dlr,
 margin_dlr
 
 from t_item_sum t
 left join t_inv_before_final b
 on(b.item_key=t.item_key and b.store_id=t.shipto)
 left join t_inv_after_final a
 on(a.item_key=t.item_key and a.store_id=t.shipto)
 left join t_sales s
 on(s.item_key=t.item_key and s.store_id=t.shipto)