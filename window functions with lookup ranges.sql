--This one is a neat trick: use window functions to approximate a vlookup in excel.  It lets you
--apply historical data based on a time range.  In the case of this report, I can see how items
--based on a past status performed a year ago vs. now.

create temp table t_item_status as
select *
from external 'C:\\Item_Status_Data.csv'
(row integer, item_id bigint, modf_type char(10), column_updated char(30), old_value char(30),new_value char(30),modf_date timestamp, modf_by char(30) )
using (
delimiter ','
remotesource 'odbc'

skiprows 1
maxerrors 10
fillrecord)
;

create temp table t_item_avail as
select *
from external 'H:\\Adv_Mkt Dept\\Generated_Reports\\Unloads\\Item_Avail_Data.csv'
(row integer, item_id bigint, modf_type char(10), column_updated char(30), old_value char(30),new_value char(30),modf_date timestamp, modf_by char(30) )
using (
delimiter ','
remotesource 'odbc'

skiprows 1
maxerrors 10
fillrecord)
;


--create sales table


create temp table t_sales as
select	
	a15.ITEM_ID,
	a15.STREET_DATE,
	a11.POS_TRANS_ID,
	a11.LINE_NUM,
	a11.STORE_ID,
	a15.BUY_VENDOR_ID,
	a15.prod_code,
	pf.PROD_FMT_DESCR,
	v.NAME vendor_name,
	a15.TITLE,
	a15.ARTIST_LNAME,
	gd.GRP_DEPT_DESCR,
	pd.PROD_DEPT_DESCR,
	p1.PROD_CAT1_DESCR,
	p2.PROD_CAT2_DESCR,
	p3.PROD_CAT3_DESCR,
	status,
	availability,
	a11.BUS_DATE,

	sum(a11.NET_SALES_AMT+a11.coup_amt) revenue,
	sum(a11.NET_SALES_AMT+a11.coup_amt- a11.NET_COST) margin_dlr,
	sum(a11.QTY_SOLD) qty_sold
from	SALES_FACT_DTL	a11
	join	REL_IS_GOSHP_ALL	a12
	  on 	(a11.IS_GOSHP_ID = a12.IS_GOSHP_ID)
	join	DBA1.LU_COMP_STORE	a13
	  on 	(a11.STORE_ID = a13.STORE_ID)
	join	REL_STORE_GRP_ALL	a14
	  on 	(a11.STORE_ID = a14.STORE_ID)
	join	LU_ITEM	a15
	  on 	(a11.ITEM_KEY = a15.ITEM_KEY)


	join lu_prod_fmt pf
		on(pf.PROD_FMT_ID=a15.prod_fmt_id)
	join lu_grp_dept gd
		on(gd.GRP_DEPT_ID=a15.grp_dept_id)
	join lu_prod_dept pd
		on(pd.GRP_DEPT_ID=a15.grp_dept_id and pd.PROD_DEPT_ID=a15.prod_dept_id)
	join lu_prod_cat1 p1
		on(a15.PROD_CAT1_KEY=p1.prod_cat1_key and p1.PROD_CODE=a15.prod_code)
	join lu_prod_cat2 p2
		on(a15.PROD_CAT1_KEY=p2.prod_cat1_key and p2.PROD_CODE=a15.prod_code and p2.PROD_CAT2_KEY=a15.prod_Cat2_key )
	join lu_prod_cat3 p3
		on(a15.PROD_CAT1_KEY=p3.prod_cat1_key and p3.PROD_CODE=a15.prod_code and p3.PROD_CAT2_KEY=a15.prod_Cat2_key and p3.PROD_CAT3_KEY=a15.prod_cat3_key)

	join lu_date dd
		on(a11.BUS_DATE=dd.date)
	left join lu_vendor v
		on(v.VENDOR_ID=a15.buy_vendor_id)
where	(a15.GRP_DEPT_ID not in (-2, -1, 13)
 and a11.IS_OVRNG in ('N')
 and a14.STORE_GRP_ALL_ID in (1000)
and  a15.GRP_DEPT_ID in(2)
 and a15.PROD_DEPT_ID!=94
 and a11.BUS_DATE >=  a13.COMP_DATE
 and a13.COMP_FLG in ( 'LY')
 and a12.IS_GOSHP_ALL_ID=40
 and a13.COMP_TYPE=0
 and (a11.BUS_DATE between '2013-12-01' and '2015-11-30' )     
 and (a13.CLOSE_DATE >=  To_Date('12/09/2015', 'mm/dd/yyyy')
 or a13.CLOSE_DATE is null))



group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19;


--join item status data
create temp table t_Status as
select 
sum(a.revenue) revenue, sum(a.margin_dlr) margin, sum(a.qty_sold) qty_sold,store_id,
 (case when modf_date is null then a.status when a.test=0 then a.old_value when a.test=1 then a.new_value else 'I DONT KNOW' end) real_status,
	a.ITEM_ID,
	a.street_date,
	a.pos_trans_id,
	a.line_num,
	a.BUY_VENDOR_ID,
	a.prod_code,
	a.PROD_FMT_DESCR,
	a.vendor_name,
	a.TITLE,
	a.ARTIST_LNAME,
	a.GRP_DEPT_DESCR,
	a.PROD_DEPT_DESCR,
	a.PROD_CAT1_DESCR,
	a.PROD_CAT2_DESCR,
	a.PROD_CAT3_DESCR,
	a.bus_date,
	a.availability
from(select t.*,tt.old_value, tt.new_value, tt.modf_date, case when t.bus_date>= tt.modf_Date then 1 else 0 end test,
row_number() over(partition by t.item_id, t.bus_date, t.store_id,t.pos_trans_id, t.line_num order by test desc, modf_date desc) rn
from t_sales t
left join t_item_status tt
on(tt.item_id=t.item_id)
order by t.item_id, t.bus_date,t.store_id,t.pos_trans_id, t.line_num, case when t.bus_date>= tt.modf_Date then 1 else 0 end desc, tt.modf_date desc
) as a
join lu_date dd
on(dd.date=a.bus_date)
where (test=1 and a.rn=1) or (test=0 and rn=1) or(rn is null) 
group by 4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22
;

--join item availability data

create temp table t_Status_avail as
select 
sum(a.revenue) revenue, sum(a.margin) margin, sum(a.qty_sold) qty_sold,

a.real_status,
 (case when modf_date is null then a.availability when a.test=0 then a.old_value when a.test=1 then a.new_value else 'I DONT KNOW' end) real_availability,
	a.ITEM_ID,
	a.street_date,
	
	a.BUY_VENDOR_ID,
	a.prod_code,
	a.PROD_FMT_DESCR,
	a.vendor_name,
	a.TITLE,
	a.ARTIST_LNAME,
	a.GRP_DEPT_DESCR,
	a.PROD_DEPT_DESCR,
	a.PROD_CAT1_DESCR,
	a.PROD_CAT2_DESCR,
	a.PROD_CAT3_DESCR,
	dd.FISC_MONTH_ID
from(select t.*,tt.old_value, tt.new_value, tt.modf_date, case when t.bus_date>= tt.modf_Date then 1 else 0 end test,
row_number() over(partition by t.item_id, t.bus_date, t.store_id,t.pos_trans_id, t.line_num order by test desc, modf_date desc) rn
from t_status t
left join t_item_avail tt
on(tt.item_id=t.item_id)
order by t.item_id, t.bus_date,t.store_id,t.pos_trans_id, t.line_num, case when t.bus_date>= tt.modf_Date then 1 else 0 end desc, tt.modf_date desc
) as a
join lu_date dd
on(dd.date=a.bus_date)
where (test=1 and a.rn=1) or (test=0 and rn=1) or(rn is null) 
group by 4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19
;

--select sum(revenue)
--from t_sales;
--
--select sum(revenue)
--from t_status;
--
--select sum(revenue)
--from t_status_avail;

select *
from t_status_avail;



--drop table t_sales;