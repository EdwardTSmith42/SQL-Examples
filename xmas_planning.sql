--ranking all product sold during holiday for xmas planning purposes
create temp table t_rank as	
	select 
	a15.ITEM_KEY,
	nvl(ib.BARCODE,'') item_no,
	nvl(a15.UPC,'') upc ,
	nvl(a15.EAN,'') ean,
	a15.ARTIST_LNAME,
	a15.ARTIST_FNAME,
	a15.TITLE,
	a15.PROD_CODE,
gd.GRP_DEPT_DESCR,
pd.PROD_DEPT_DESCR,
pp1.PROD_CAT1_DESCR,
pp2.PROD_CAT2_DESCR,
m.NAME mfr,
v.NAME buy_vendor,
a15.COST,
a15.MSRP,
a15.STREET_DATE,
a15.STATUS,
a15.AVAILABILITY,
a15.RETURNABLE,
case when a15.STREET_DATE> '2015-09-01' then 'New Release' else 'Not New Release' end nr_flag,
sum(case when a11.MKT_PLC_ID =3 and a11.BUS_DATE between '2015-11-01' and '2015-11-30' then a11.QTY_SOLD else 0 end) str_nov_u_sls,
sum(case when a11.MKT_PLC_ID =3 and a11.BUS_DATE between '2015-11-01' and '2015-11-30' then a11.NET_SALES_AMT + a11.COUP_AMT  else 0 end) str_nov_dlr_sls,
sum(case when a11.MKT_PLC_ID =3 and a11.BUS_DATE between '2015-12-01' and '2015-12-31' then a11.QTY_SOLD end) str_dec_u_sls,
sum(case when a11.MKT_PLC_ID =3 and a11.BUS_DATE between '2015-12-01' and '2015-12-31' then a11.NET_SALES_AMT + a11.COUP_AMT   else 0 end) str_dec_dlr_sls,
sum(case when a11.MKT_PLC_ID =3 and a11.BUS_DATE between '2015-11-26' and '2015-11-28' then a11.QTY_SOLD  else 0 end) str_bf_u_sls,
sum(case when a11.MKT_PLC_ID =3 and a11.BUS_DATE between '2015-11-26' and '2015-11-28' then a11.NET_SALES_AMT + a11.COUP_AMT  else 0 end) str_bf_dlr_sls,
sum(case when a11.MKT_PLC_ID !=3 and a11.BUS_DATE between '2015-11-01' and '2015-11-30' then a11.QTY_SOLD  else 0 end) online_nov_u_sls,
sum(case when a11.MKT_PLC_ID !=3 and a11.BUS_DATE between '2015-11-01' and '2015-11-30' then a11.NET_SALES_AMT + a11.COUP_AMT  else 0 end) online_nov_dlr_sls,
sum(case when a11.MKT_PLC_ID !=3 and a11.BUS_DATE between '2015-12-01' and '2015-12-31' then a11.QTY_SOLD  else 0 end) online_dec_u_sls,
sum(case when a11.MKT_PLC_ID !=3 and a11.BUS_DATE between '2015-12-01' and '2015-12-31' then a11.NET_SALES_AMT + a11.COUP_AMT   else 0 end) online_dec_dlr_sls,
sum(case when a11.MKT_PLC_ID !=3 and a11.BUS_DATE between '2015-11-26' and '2015-11-28' then a11.QTY_SOLD  else 0 end) online_bf_u_sls,
sum(case when a11.MKT_PLC_ID !=3 and a11.BUS_DATE between '2015-11-26' and '2015-11-28' then a11.NET_SALES_AMT + a11.COUP_AMT  else 0 end) online_bf_dlr_sls,
sum(case when a11.MKT_PLC_ID =3 and a11.BUS_DATE between '2015-11-01' and '2015-12-31' then a11.QTY_SOLD  else 0 end) str_nov_dec_u_sls,
sum(case when a11.MKT_PLC_ID =3 and a11.BUS_DATE between '2015-11-01' and '2015-12-31' then a11.NET_SALES_AMT + a11.COUP_AMT  else 0 end) str_nov_dec_dlr_sls,
sum(case when a11.MKT_PLC_ID !=3 and a11.BUS_DATE between '2015-11-01' and '2015-12-31' then a11.QTY_SOLD  else 0 end) online_nov_dec_u_sls,
sum(case when a11.MKT_PLC_ID !=3 and a11.BUS_DATE between '2015-11-01' and '2015-12-31' then a11.NET_SALES_AMT + a11.COUP_AMT else 0  end) online_nov_dec_dlr_sls,
nvl(t.story_name,'No Story') story,
nvl(t.STORY_TYPE, 'No Story Type') story_type,
sum(a11.NET_SALES_AMT + a11.COUP_AMT)  Total_Revenue,
sum(a11.QTY_SOLD) Total_qty_sold,
sum(a11.NET_SALES_AMT+ a11.COUP_AMT - a11.NET_COST) Total_margin_dlr





	
from	SALES_FACT_DTL	a11
	join	REL_IS_GOSHP_ALL	a12
	  on 	(a11.IS_GOSHP_ID = a12.IS_GOSHP_ID)
	join	DBA1.LU_COMP_STORE	a13
	  on 	(a11.STORE_ID = a13.STORE_ID)
	join	REL_STORE_GRP_ALL	a14
	  on 	(a11.STORE_ID = a14.STORE_ID)
	join	LU_ITEM	a15
	  on 	(a11.ITEM_KEY = a15.ITEM_KEY)
	 join lu_prod_dept pd
	 	on(pd.PROD_DEPT_ID= a15.PROD_DEPT_ID and pd.GRP_DEPT_ID= a15.GRP_DEPT_ID)
	join lu_grp_dept gd
	on(gd.GRP_DEPT_ID = a15.GRP_DEPT_ID)
	join lu_date dd
		on(a11.BUS_DATE=dd.date)
	join lu_prod_code pc
	on(pc.PROD_CODE = a15.PROD_CODE)
	left join lu_mfr m
	on(m.VENDOR_ID = a15.MFR_ID)
	left join dw_Stage..ITEM_BARCODE ib
	on(ib.ITEM_ID = a15.ITEM_ID and ib.BARCODE_TYPE_ID=4)
	left join story t
	on(t.item_key= a11.ITEM_KEY)
	left join lu_vendor v
	on(v.VENDOR_ID = a15.BUY_VENDOR_ID)
left join dw_stage..PROD_CAT1_stg2 pp1 
on(pp1.PROD_CAT1_KEY= a15.PROD_CAT1_KEY )
 left join dw_stage..PROD_CAT2_stg2 pp2
on(pp2.PROD_CAT2_KEY= a15.PROD_CAT2_KEY )
 left join dw_stage..PROD_CAT3_STG2 pp3
on(pp3.PROD_CAT3_KEY =a15.PROD_CAT3_KEY)	
where	(a15.GRP_DEPT_ID not in (-2, -1, 13)
 and a11.IS_OVRNG in ('N')
 and a14.STORE_GRP_ALL_ID in (1000)

 and a11.BUS_DATE >=  a13.COMP_DATE
 and a13.COMP_FLG in ('TY')
 and a12.IS_GOSHP_ALL_ID=40
 and comp_type in(0)
--and a11.POSTED_CLASS=75
and a11.STORE_ID not between 9303 and 9346
 and a11.BUS_DATE between To_Date('11/01/2015', 'mm/dd/yyyy') and To_Date('12/31/2015', 'mm/dd/yyyy')
 and (a13.CLOSE_DATE >=  current_date-1
 or a13.CLOSE_DATE is null))
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,38,39
having sum(a11.QTY_SOLD) >10
;

select *
from t_rank;
create temp table t_recv as
select item_id, lst_rcvd_Date
from dw_stage..PROD_DATES pd
where item_id in(select item_key from t_rank)
 and pd.STORE_ID=7100
 group by 1,2;
 
 create temp table t_inv as
 select v.ITEM_KEY,
 sum( case when date='2015-12-01' then v.ON_HAND else 0 end) nov_oh,
 sum( case when date='2016-01-01' then v.ON_HAND else 0 end) dec_oh
 from v_store_inv_Fact v

 where v.DATE in('2015-12-01','2016-01-01')
group by 1;

select t.*, r.lst_rcvd_Date as dc_last_receipt_date,
nvl(tt.nov_oh,0) nov_oh, nvl(tt.dec_oh,0) dec_oh
from t_rank t
left join t_recv r
on(r.item_id=t.item_key)
left join t_inv tt
on(tt.item_key=t.item_key)
