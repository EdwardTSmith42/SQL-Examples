--This report creates multi-layered hierarchical comps at both the dept level, grp dept level, and store level.


--create comp sales for this year at the prod_dept level

create temp table sales_ty as
select 
pd.PROD_DEPT_ID,
pd.PROD_DEPT_DESCR,
a11.STORE_ID,
sum(a11.NET_SALES_AMT + a11.COUP_AMT)  Revenue_ty,
count(distinct a11.ITEM_KEY ) ttls_sold_ty,
sum(a11.NET_SALES_AMT+ a11.COUP_AMT - a11.NET_COST) margin_dlr_ty
from	SALES_FACT_DTL	a11
left join	REL_IS_GOSHP_ALL	a12
	  on 	(a11.IS_GOSHP_ID = a12.IS_GOSHP_ID)
left join	DBA1.LU_COMP_STORE	a13
	  on 	(a11.STORE_ID = a13.STORE_ID)
left join	REL_STORE_GRP_ALL	a14
	  on 	(a11.STORE_ID = a14.STORE_ID)
left join	LU_ITEM	a15
	  on 	(a11.ITEM_KEY = a15.ITEM_KEY)
left join lu_prod_dept pd
	 	on(pd.PROD_DEPT_ID= a15.PROD_DEPT_ID and pd.GRP_DEPT_ID= a15.GRP_DEPT_ID)
left join lu_grp_dept gd
	on(gd.GRP_DEPT_ID = a15.GRP_DEPT_ID)
left join lu_date dd
		on(a11.BUS_DATE=dd.date)
left join lu_prod_code pc
	on(pc.PROD_CODE = a15.PROD_CODE)
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
--and a11.STORE_ID=9604 
--and a15.PROD_DEPT_ID not in(116,89,113)
and a11.STORE_ID not between 9303 and 9347
 and a11.BUS_DATE between To_Date('1/01/2015', 'mm/dd/yyyy') and To_Date('12/31/2015', 'mm/dd/yyyy')
 and (a13.CLOSE_DATE >=  current_date-1
 or a13.CLOSE_DATE is null))
group by 1,2,3
;
--create comp sales ly at the prod dept level
create temp table sales_ly as
select 
pd.PROD_DEPT_ID,
pd.PROD_DEPT_DESCR,
a11.STORE_ID,
sum(a11.NET_SALES_AMT + a11.COUP_AMT)  Revenue_ly,
count(distinct a11.ITEM_KEY ) ttls_sold_ly,
sum(a11.NET_SALES_AMT+ a11.COUP_AMT - a11.NET_COST) margin_dlr_ly
from	SALES_FACT_DTL	a11
left join	REL_IS_GOSHP_ALL	a12
	  on 	(a11.IS_GOSHP_ID = a12.IS_GOSHP_ID)
left join	DBA1.LU_COMP_STORE	a13
	  on 	(a11.STORE_ID = a13.STORE_ID)
left join	REL_STORE_GRP_ALL	a14
	  on 	(a11.STORE_ID = a14.STORE_ID)
left join	LU_ITEM	a15
	  on 	(a11.ITEM_KEY = a15.ITEM_KEY)
left join lu_prod_dept pd
	 	on(pd.PROD_DEPT_ID= a15.PROD_DEPT_ID and pd.GRP_DEPT_ID= a15.GRP_DEPT_ID)
left join lu_grp_dept gd
	on(gd.GRP_DEPT_ID = a15.GRP_DEPT_ID)
left join lu_date dd
		on(a11.BUS_DATE=dd.date)
left join lu_prod_code pc
	on(pc.PROD_CODE = a15.PROD_CODE)
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
 and a13.COMP_FLG in ('LY')
 and a12.IS_GOSHP_ALL_ID=40
 and comp_type in(0)
--and a11.STORE_ID=9604 
and a11.STORE_ID not between 9303 and 9347
 and a11.BUS_DATE between To_Date('1/01/2014', 'mm/dd/yyyy') and To_Date('12/31/2014', 'mm/dd/yyyy')
 and (a13.CLOSE_DATE >=  current_date-1
 or a13.CLOSE_DATE is null))
group by 1,2,3
;

--find all prod depts in either year
create temp table prod_dept_union as
select PROD_DEPT_ID,
PROD_DEPT_DESCR, store_id
from sales_ty t
group by 1,2,3
union 
select PROD_DEPT_ID,
PROD_DEPT_DESCR, store_id
from sales_ly t
group by 1,2,3
;
create temp table total_sales_ty as
select store_id, sum(revenue_ty) revenue_tyt
from sales_ty
group by 1;

create temp table total_sales_ly as
select store_id, sum(revenue_ly) revenue_lyt
from sales_ly
group by 1;


--Group prod dept data together


create temp table t_comp as
select p.PROD_DEPT_ID,
p.PROD_DEPT_DESCR,
p.STORE_ID,
pd.grp_dept_id,
nvl(Revenue_ty,0) revenue_ty,
nvl(Revenue_ly,0) revenue_ly,
case when revenue_ly =0 then 0 when (revenue_ly is null or revenue_ly=0) then 0 when  ((nvl(revenue_ty,revenue_ly) -nvl(revenue_ly , revenue_ty))/ nvl(revenue_ly , revenue_ty))=0 then 0 
	else ((nvl(revenue_ty,revenue_ly) -nvl(revenue_ly , revenue_ty))/ nvl(revenue_ly , revenue_ty)) end sales_comp,
nvl(Revenue_ty,0) / ttty.revenue_tyt	pct_to_total_ty,
nvl(Revenue_ly,0) / ttly.revenue_lyt	pct_to_total_ly,
nvl(ttls_sold_ty,0) ttls_sold_ty,
nvl(ttls_sold_ly,0) ttls_sold_ly,
nvl(margin_dlr_ty,0) margin_dlr_ty,
nvl(margin_dlr_ly,0) margin_dlr_ly
from prod_dept_union p
left join sales_ty ty
on(ty.prod_dept_id=p.prod_dept_id and ty.store_id=p.store_id)
left join sales_ly ly
on(ly.prod_dept_id=p.prod_dept_id and ly.store_id=p.store_id)
left join lu_prod_Dept pd
on(pd.prod_dept_id=p.prod_dept_id)
left join total_sales_ty ttty
on(ttty.store_id=p.store_id)
left join total_sales_ly ttly
on(ttly.store_id=p.store_id)
;


------start grp dept here
--create comp sales for this year at the grp_dept level

create temp table sales_ty_g as
select 
gd.GRP_DEPT_ID,
gd.GRP_DEPT_DESCR,
a11.STORE_ID,
sum(a11.NET_SALES_AMT + a11.COUP_AMT)  Revenue_ty,
count(distinct a11.ITEM_KEY ) ttls_sold_ty,
sum(a11.NET_SALES_AMT+ a11.COUP_AMT - a11.NET_COST) margin_dlr_ty
from	SALES_FACT_DTL	a11
left join	REL_IS_GOSHP_ALL	a12
	  on 	(a11.IS_GOSHP_ID = a12.IS_GOSHP_ID)
left join	DBA1.LU_COMP_STORE	a13
	  on 	(a11.STORE_ID = a13.STORE_ID)
left join	REL_STORE_GRP_ALL	a14
	  on 	(a11.STORE_ID = a14.STORE_ID)
left join	LU_ITEM	a15
	  on 	(a11.ITEM_KEY = a15.ITEM_KEY)
left join lu_prod_dept pd
	 	on(pd.PROD_DEPT_ID= a15.PROD_DEPT_ID and pd.GRP_DEPT_ID= a15.GRP_DEPT_ID)
left join lu_grp_dept gd
	on(gd.GRP_DEPT_ID = a15.GRP_DEPT_ID)
left join lu_date dd
		on(a11.BUS_DATE=dd.date)
left join lu_prod_code pc
	on(pc.PROD_CODE = a15.PROD_CODE)
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
--and a11.STORE_ID=9604 
--and a15.PROD_DEPT_ID not in(116,89,113)
and a11.STORE_ID not between 9303 and 9347
 and a11.BUS_DATE between To_Date('1/01/2015', 'mm/dd/yyyy') and To_Date('12/31/2015', 'mm/dd/yyyy')
 and (a13.CLOSE_DATE >=  current_date-1
 or a13.CLOSE_DATE is null))
group by 1,2,3
;
--create comp sales ly at the prod dept level
create temp table sales_ly_G as
select 
gd.GRP_DEPT_ID,
gd.GRP_DEPT_DESCR,
a11.STORE_ID,
sum(a11.NET_SALES_AMT + a11.COUP_AMT)  Revenue_ly,
count(distinct a11.ITEM_KEY ) ttls_sold_ly,
sum(a11.NET_SALES_AMT+ a11.COUP_AMT - a11.NET_COST) margin_dlr_ly
from	SALES_FACT_DTL	a11
left join	REL_IS_GOSHP_ALL	a12
	  on 	(a11.IS_GOSHP_ID = a12.IS_GOSHP_ID)
left join	DBA1.LU_COMP_STORE	a13
	  on 	(a11.STORE_ID = a13.STORE_ID)
left join	REL_STORE_GRP_ALL	a14
	  on 	(a11.STORE_ID = a14.STORE_ID)
left join	LU_ITEM	a15
	  on 	(a11.ITEM_KEY = a15.ITEM_KEY)
left join lu_prod_dept pd
	 	on(pd.PROD_DEPT_ID= a15.PROD_DEPT_ID and pd.GRP_DEPT_ID= a15.GRP_DEPT_ID)
left join lu_grp_dept gd
	on(gd.GRP_DEPT_ID = a15.GRP_DEPT_ID)
left join lu_date dd
		on(a11.BUS_DATE=dd.date)
left join lu_prod_code pc
	on(pc.PROD_CODE = a15.PROD_CODE)
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
 and a13.COMP_FLG in ('LY')
 and a12.IS_GOSHP_ALL_ID=40
 and comp_type in(0)
--and a11.STORE_ID=9604 
and a11.STORE_ID not between 9303 and 9347
 and a11.BUS_DATE between To_Date('1/01/2014', 'mm/dd/yyyy') and To_Date('12/31/2014', 'mm/dd/yyyy')
 and (a13.CLOSE_DATE >=  current_date-1
 or a13.CLOSE_DATE is null))
group by 1,2,3
;

--find all prod depts in either year
create temp table grp_dept_union as
select GRP_DEPT_ID,
GRP_DEPT_DESCR, store_id
from sales_ty_g t
group by 1,2,3
union 
select GRP_DEPT_ID,
GRP_DEPT_DESCR,  store_id
from sales_ly_g t
group by 1,2,3
;

insert into t_comp
select null placeholder,
p.GRP_DEPT_DESCR,
p.STORE_ID,
p.grp_dept_id,
nvl(Revenue_ty,0) revenue_ty,
nvl(Revenue_ly,0) revenue_ly,
case when revenue_ly =0 then 0 when (revenue_ly is null or revenue_ly=0) then 0 when  ((nvl(revenue_ty,revenue_ly) -nvl(revenue_ly , revenue_ty))/ nvl(revenue_ly , revenue_ty))=0 then 0 
	else ((nvl(revenue_ty,revenue_ly) -nvl(revenue_ly , revenue_ty))/ nvl(revenue_ly , revenue_ty)) end sales_comp,
nvl(Revenue_ty,0) / ttty.revenue_tyt	pct_to_total_ty,
nvl(Revenue_ly,0) / ttly.revenue_lyt	pct_to_total_ly,
nvl(ttls_sold_ty,0) ttls_sold_ty,
nvl(ttls_sold_ly,0) ttls_sold_ly,
nvl(margin_dlr_ty,0) margin_dlr_ty,
nvl(margin_dlr_ly,0) margin_dlr_ly
from grp_dept_union p
left join sales_ty_g ty
on(ty.grp_dept_id=p.grp_dept_id and ty.store_id=p.store_id)
left join sales_ly_g ly
on(ly.grp_dept_id=p.grp_dept_id and ly.store_id=p.store_id)
left join total_sales_ty ttty
on(ttty.store_id=p.store_id)
left join total_sales_ly ttly
on(ttly.store_id=p.store_id)
;

--get data for store total
create temp table grp_dept_final as
select null placeholder,
p.GRP_DEPT_DESCR,
p.STORE_ID,
p.grp_dept_id,
nvl(Revenue_ty,0) revenue_ty,
nvl(Revenue_ly,0) revenue_ly,
case when revenue_ly =0 then 0 when (revenue_ly is null or revenue_ly=0) then 0 when  ((nvl(revenue_ty,revenue_ly) -nvl(revenue_ly , revenue_ty))/ nvl(revenue_ly , revenue_ty))=0 then 0 
	else ((nvl(revenue_ty,revenue_ly) -nvl(revenue_ly , revenue_ty))/ nvl(revenue_ly , revenue_ty)) end sales_comp,
nvl(Revenue_ty,0) / (select sum(revenue_ty) from sales_ty)	pct_to_total_ty,
nvl(Revenue_ly,0) / (select sum(revenue_ly) from sales_ly)	pct_to_total_ly,
nvl(ttls_sold_ty,0) ttls_sold_ty,
nvl(ttls_sold_ly,0) ttls_sold_ly,
nvl(margin_dlr_ty,0) margin_dlr_ty,
nvl(margin_dlr_ly,0) margin_dlr_ly
from grp_dept_union p
left join sales_ty_g ty
on(ty.grp_dept_id=p.grp_dept_id and ty.store_id=p.store_id)
left join sales_ly_g ly
on(ly.grp_dept_id=p.grp_dept_id and ly.store_id=p.store_id)
;
--get grp_dept_total
--select *
--from grp_Dept_final;

--get store total
insert into t_comp
select placeholder, 'Store Total' as grp_dept_descr, store_id, 22 as grp_dept_id, sum(revenue_ty) revenue_ty,
sum(revenue_ly) revenue_ly, (sum(revenue_ty) - sum(revenue_ly)) /sum(revenue_ly) sales_comp,1 pct_to_total_ty,1 pct_to_total_ly, sum(ttls_sold_ty) ttls_sold_ty, sum(ttls_sold_ly) ttls_sold_ly, sum(margin_dlr_ty) margin_dlr_ty, sum(margin_dlr_ly) margin_dlr_ly
from grp_dept_final
group by 1,2,3,4;

select store_id, prod_dept_id, prod_dept_descr, grp_dept_id, revenue_ty, revenue_ly, sales_comp, pct_to_total_ty, pct_to_total_ly, ttls_sold_ty, ttls_sold_ly, margin_dlr_ty, margin_dlr_ly
from t_comp
order by 1,4,5





