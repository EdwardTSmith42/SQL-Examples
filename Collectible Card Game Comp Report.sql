--analyze ccg comps year over year:  tool to drive action for poor performing stores.

create temp table t_trans as
select 
a11.POS_TRANS_ID, a11.STORE_ID, a11.CUST_ID, dd.FISC_MONTH_ID
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
left join dw_stage..PROD_CAT1_stg2 pp1 
on(pp1.PROD_CAT1_KEY= a15.PROD_CAT1_KEY )
 left join dw_stage..PROD_CAT2_stg2 pp2
on(pp2.PROD_CAT2_KEY= a15.PROD_CAT2_KEY )
 left join dw_stage..PROD_CAT3_STG2 pp3
on(pp3.PROD_CAT3_KEY =a15.PROD_CAT3_KEY)	

where	(a15.GRP_DEPT_ID not in (-2, -1, 13)
 and a11.IS_OVRNG in ('N')
 and a14.STORE_GRP_ALL_ID in (1000)
 and a13.COMP_FLG in ('TY')
 and a12.IS_GOSHP_ALL_ID=30
 and a11.BUS_DATE>= a13.COMP_DATE
and a11.POSTED_CLASS=129
and (a13.CLOSE_DATE is null or a13.CLOSE_DATE>= current_date-1)
 and comp_type in(0)
 and a11.BUS_DATE between To_Date('01/01/2013', 'mm/dd/yyyy') and To_Date('06/30/2016', 'mm/dd/yyyy')

and a11.STORE_ID not between 9303 and 9346
-- and a11.BUS_DATE between To_Date('1/10/2016', 'mm/dd/yyyy') and To_Date('01/16/2016', 'mm/dd/yyyy')
)
 group by 1,2,3,4
;

create temp table t_cust as
select cust_id, fisc_month_id
from t_trans
group by 1,2
;

create temp table t_trans_2 as
select 
a11.POS_TRANS_ID, a11.STORE_ID, a11.CUST_ID, dd.FISC_MONTH_ID
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
	join t_cust c
	on(c.cust_id = a11.CUST_ID and dd.FISC_MONTH_ID = c.fisc_month_id)
left join dw_stage..PROD_CAT1_stg2 pp1 
on(pp1.PROD_CAT1_KEY= a15.PROD_CAT1_KEY )
 left join dw_stage..PROD_CAT2_stg2 pp2
on(pp2.PROD_CAT2_KEY= a15.PROD_CAT2_KEY )
 left join dw_stage..PROD_CAT3_STG2 pp3
on(pp3.PROD_CAT3_KEY =a15.PROD_CAT3_KEY)	

where	(a15.GRP_DEPT_ID not in (-2, -1, 13)
 and a11.IS_OVRNG in ('N')
 and a14.STORE_GRP_ALL_ID in (1000)
 and a13.COMP_FLG in ('TY')
 and a12.IS_GOSHP_ALL_ID=30
 and a11.BUS_DATE>= a13.COMP_DATE

and (a13.CLOSE_DATE is null or a13.CLOSE_DATE>= current_date-1)
 and comp_type in(0)
 and a11.BUS_DATE between To_Date('01/01/2013', 'mm/dd/yyyy') and To_Date('06/30/2016', 'mm/dd/yyyy')

and a11.STORE_ID not between 9303 and 9346
-- and a11.BUS_DATE between To_Date('1/10/2016', 'mm/dd/yyyy') and To_Date('01/16/2016', 'mm/dd/yyyy')
)
 group by 1,2,3,4
;

create temp table t_trans_all as
select POS_TRANS_ID, STORE_ID, CUST_ID, FISC_MONTH_ID
from t_trans
group by 1,2,3,4
union
select  POS_TRANS_ID, STORE_ID, CUST_ID, FISC_MONTH_ID
from t_trans_2
group by 1,2,3,4
;




create temp table t_ty as
select 
d.name district,
s.STORE_ID,
dd.FISC_MONTH_ID,
sum(case when t.pos_trans_id || t.store_id is not null   then a11.NET_SALES_AMT + a11.COUP_AMT else 0 end) pc_129_revenue_ty,
sum(a11.NET_SALES_AMT + a11.COUP_AMT)  Revenue_ty,

sum(a11.NET_SALES_AMT+ a11.COUP_AMT - a11.NET_COST) margin_dlr_ty,
row_number() over(partition by d.NAME, s.STORE_Id order by d.NAME, s.STORE_ID, dd.FISC_MONTH_ID desc ) rn
from	SALES_FACT_DTL	a11
	join	REL_IS_GOSHP_ALL	a12
	  on 	(a11.IS_GOSHP_ID = a12.IS_GOSHP_ID)
	join	DBA1.LU_COMP_STORE	a13
	  on 	(a11.STORE_ID = a13.STORE_ID)
	  join lu_store s
	  on(s.STORE_ID = a13.STORE_ID)
	  join lu_district d
	  on(d.DISTRICT_ID = s.district_ID)
	join	REL_STORE_GRP_ALL	a14
	  on 	(a11.STORE_ID = a14.STORE_ID)
	join lu_date dd
		on(a11.BUS_DATE=dd.date)
left join t_trans_all t
on(t.pos_trans_id= a11.POS_TRANS_ID and t.store_id = a11.STORE_ID)
left join	LU_ITEM	a15
	  on 	(a11.ITEM_KEY = a15.ITEM_KEY)
left join lu_prod_code pc
	on(pc.PROD_CODE = a15.PROD_CODE)
left join dw_stage..PROD_CAT1_stg2 pp1 
on(pp1.PROD_CAT1_KEY= a15.PROD_CAT1_KEY )
left join lu_grp_dept gd
	on(gd.GRP_DEPT_ID = a15.GRP_DEPT_ID)
left join lu_prod_dept pd
on(pd.PROD_DEPT_ID= a15.PROD_DEPT_ID and pd.GRP_DEPT_ID= a15.GRP_DEPT_ID)
 left join dw_stage..PROD_CAT2_stg2 pp2
on(pp2.PROD_CAT2_KEY= a15.PROD_CAT2_KEY )
 left join dw_stage..PROD_CAT3_STG2 pp3
on(pp3.PROD_CAT3_KEY =a15.PROD_CAT3_KEY)	
where	(a15.GRP_DEPT_ID not in (-2, -1, 13)
 and a11.IS_OVRNG in ('N')
 and a14.STORE_GRP_ALL_ID in (1000)

 and a11.BUS_DATE>= a13.COMP_DATE
 and a13.COMP_FLG in ('TY')
 and a12.IS_GOSHP_ALL_ID=30
 and comp_type in(0)
and (a13.CLOSE_DATE is null or a13.CLOSE_DATE>=current_date-2)
and a11.STORE_ID not between 9303 and 9346
 and a11.BUS_DATE between To_Date('01/01/2013', 'mm/dd/yyyy') and To_Date('06/30/2016', 'mm/dd/yyyy')
)
group by 1,2,3
order by 1,2,3 desc
;

drop table t_trans;
drop table t_trans_2;
drop table t_trans_all;
drop table t_cust;

create temp table t_trans as
select 
a11.POS_TRANS_ID, a11.STORE_ID, a11.CUST_ID, dd.FISC_MONTH_ID
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
left join dw_stage..PROD_CAT1_stg2 pp1 
on(pp1.PROD_CAT1_KEY= a15.PROD_CAT1_KEY )
 left join dw_stage..PROD_CAT2_stg2 pp2
on(pp2.PROD_CAT2_KEY= a15.PROD_CAT2_KEY )
 left join dw_stage..PROD_CAT3_STG2 pp3
on(pp3.PROD_CAT3_KEY =a15.PROD_CAT3_KEY)	

where	(a15.GRP_DEPT_ID not in (-2, -1, 13)
 and a11.IS_OVRNG in ('N')
 and a14.STORE_GRP_ALL_ID in (1000)
 and a13.COMP_FLG in ('LY')
 and a12.IS_GOSHP_ALL_ID=30
 and a11.BUS_DATE>= a13.COMP_DATE
and a11.POSTED_CLASS=129
and (a13.CLOSE_DATE is null or a13.CLOSE_DATE>= current_date-1)
 and comp_type in(0)
 and a11.BUS_DATE between To_Date('01/01/2012', 'mm/dd/yyyy') and To_Date('06/30/2015', 'mm/dd/yyyy')

and a11.STORE_ID not between 9303 and 9346
-- and a11.BUS_DATE between To_Date('1/10/2016', 'mm/dd/yyyy') and To_Date('01/16/2016', 'mm/dd/yyyy')
)
 group by 1,2,3,4
;

create temp table t_cust as
select cust_id, fisc_month_id
from t_trans
group by 1,2
;

create temp table t_trans_2 as
select 
a11.POS_TRANS_ID, a11.STORE_ID, a11.CUST_ID, dd.FISC_MONTH_ID
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
	join t_cust c
	on(c.cust_id = a11.CUST_ID and dd.FISC_MONTH_ID = c.fisc_month_id)
left join dw_stage..PROD_CAT1_stg2 pp1 
on(pp1.PROD_CAT1_KEY= a15.PROD_CAT1_KEY )
 left join dw_stage..PROD_CAT2_stg2 pp2
on(pp2.PROD_CAT2_KEY= a15.PROD_CAT2_KEY )
 left join dw_stage..PROD_CAT3_STG2 pp3
on(pp3.PROD_CAT3_KEY =a15.PROD_CAT3_KEY)	

where	(a15.GRP_DEPT_ID not in (-2, -1, 13)
 and a11.IS_OVRNG in ('N')
 and a14.STORE_GRP_ALL_ID in (1000)
 and a13.COMP_FLG in ('LY')
 and a12.IS_GOSHP_ALL_ID=30
 and a11.BUS_DATE>= a13.COMP_DATE

and (a13.CLOSE_DATE is null or a13.CLOSE_DATE>= current_date-1)
 and comp_type in(0)
 and a11.BUS_DATE between To_Date('01/01/2012', 'mm/dd/yyyy') and To_Date('06/30/2015', 'mm/dd/yyyy')

and a11.STORE_ID not between 9303 and 9346
-- and a11.BUS_DATE between To_Date('1/10/2016', 'mm/dd/yyyy') and To_Date('01/16/2016', 'mm/dd/yyyy')
)
 group by 1,2,3,4
;

create temp table t_trans_all as
select POS_TRANS_ID, STORE_ID, CUST_ID, FISC_MONTH_ID
from t_trans
group by 1,2,3,4
union
select  POS_TRANS_ID, STORE_ID, CUST_ID, FISC_MONTH_ID
from t_trans_2
group by 1,2,3,4
;




create temp table t_ly as
select 
d.name district,
s.STORE_ID,
dd.FISC_MONTH_ID,
sum(case when t.pos_trans_id || t.store_id is not null   then a11.NET_SALES_AMT + a11.COUP_AMT else 0 end) pc_129_revenue_ly,
sum(a11.NET_SALES_AMT + a11.COUP_AMT)  Revenue_ly,

sum(a11.NET_SALES_AMT+ a11.COUP_AMT - a11.NET_COST) margin_dlr_ly,
row_number() over(partition by d.NAME, s.STORE_Id order by d.NAME, s.STORE_ID, dd.FISC_MONTH_ID desc ) rn
from	SALES_FACT_DTL	a11
	join	REL_IS_GOSHP_ALL	a12
	  on 	(a11.IS_GOSHP_ID = a12.IS_GOSHP_ID)
	join	DBA1.LU_COMP_STORE	a13
	  on 	(a11.STORE_ID = a13.STORE_ID)
	  join lu_store s
	  on(s.STORE_ID = a13.STORE_ID)
	  join lu_district d
	  on(d.DISTRICT_ID = s.district_ID)
	join	REL_STORE_GRP_ALL	a14
	  on 	(a11.STORE_ID = a14.STORE_ID)
	join lu_date dd
		on(a11.BUS_DATE=dd.date)
left join t_trans_all t
on(t.pos_trans_id= a11.POS_TRANS_ID and t.store_id = a11.STORE_ID)
left join	LU_ITEM	a15
	  on 	(a11.ITEM_KEY = a15.ITEM_KEY)
left join lu_prod_code pc
	on(pc.PROD_CODE = a15.PROD_CODE)
left join dw_stage..PROD_CAT1_stg2 pp1 
on(pp1.PROD_CAT1_KEY= a15.PROD_CAT1_KEY )
left join lu_grp_dept gd
	on(gd.GRP_DEPT_ID = a15.GRP_DEPT_ID)
left join lu_prod_dept pd
on(pd.PROD_DEPT_ID= a15.PROD_DEPT_ID and pd.GRP_DEPT_ID= a15.GRP_DEPT_ID)
 left join dw_stage..PROD_CAT2_stg2 pp2
on(pp2.PROD_CAT2_KEY= a15.PROD_CAT2_KEY )
 left join dw_stage..PROD_CAT3_STG2 pp3
on(pp3.PROD_CAT3_KEY =a15.PROD_CAT3_KEY)	
where	(a15.GRP_DEPT_ID not in (-2, -1, 13)
 and a11.IS_OVRNG in ('N')
 and a14.STORE_GRP_ALL_ID in (1000)
 and a11.BUS_DATE>= a13.COMP_DATE
 and a13.COMP_FLG in ('LY')
 and a12.IS_GOSHP_ALL_ID=30
 and comp_type in(0)
and (a13.CLOSE_DATE is null or a13.CLOSE_DATE>=current_date-1)
and a11.STORE_ID not between 9303 and 9346
 and a11.BUS_DATE between To_Date('01/01/2012', 'mm/dd/yyyy') and To_Date('06/30/2015', 'mm/dd/yyyy')
)
group by 1,2,3
order by 1,2,3 desc
;



select *
from t_ty
join t_ly
using(rn, store_id, district)

