--useful report to find the top 20 items for every department....both this year and last year


create temp table ty as
select 
dd.FISC_WK_ID,
a11.ITEM_KEY,
a15.TITLE,
a15.PROD_CODE,
pd.PROD_DEPT_DESCR,
sum(a11.NET_SALES_AMT + a11.COUP_AMT)  Revenue_ty,
sum(a11.QTY_SOLD) qty_sold_ty,
sum(a11.NET_SALES_AMT+ a11.COUP_AMT - a11.NET_COST) margin_dlr_ty,
count( distinct a11.POS_TRANS_ID || a11.STORE_ID) distinct_transactions_ty,
row_number() over(partition by dd.FISC_WK_ID,  pd.PROD_DEPT_DESCR order by revenue_ty desc nulls last) rn



	
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

 and a11.BUS_DATE >=  a13.COMP_DATE
 and a13.COMP_FLG in ('TY')
 and a12.IS_GOSHP_ALL_ID=30
 and comp_type in(0)
 and a11.STORE_ID<>9000
and a15.PROD_DEPT_ID not in(116,113,89)
and a11.STORE_ID not between 9303 and 9346
 and a11.BUS_DATE between To_Date('12/27/2015', 'mm/dd/yyyy') and To_Date('01/30/2016', 'mm/dd/yyyy')
 and (a13.CLOSE_DATE >=  current_date-1
 or a13.CLOSE_DATE is null))
group by 1,2,3,4,5
;

select *
from ty
where rn<=20
order by fisc_wk_id, prod_dept_descr, rn
;

create temp table ly as
select 
dd.FISC_WK_ID,
a11.ITEM_KEY,
a15.TITLE,
a15.PROD_CODE,
pd.PROD_DEPT_DESCR,
sum(a11.NET_SALES_AMT + a11.COUP_AMT)  Revenue_ly,
sum(a11.QTY_SOLD) qty_sold_ly,
sum(a11.NET_SALES_AMT+ a11.COUP_AMT - a11.NET_COST) margin_dlr_ly,
count( distinct a11.POS_TRANS_ID || a11.STORE_ID) distinct_transactions_ly,
row_number() over(partition by dd.FISC_WK_ID,  pd.PROD_DEPT_DESCR order by revenue_ly desc nulls last) rn




	
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
and a15.PROD_DEPT_ID not in(116,113,89)
 and a11.BUS_DATE >=  a13.COMP_DATE
 and a13.COMP_FLG in ('LY')
 and a12.IS_GOSHP_ALL_ID=30
 and comp_type in(0)
 and a11.STORE_ID<>9000

and a11.STORE_ID not between 9303 and 9346
 and a11.BUS_DATE between To_Date('12/28/2014', 'mm/dd/yyyy') and To_Date('02/28/2015', 'mm/dd/yyyy')
 and (a13.CLOSE_DATE >=  current_date-1
 or a13.CLOSE_DATE is null))
group by 1,2,3,4,5
;


select *
from ly
where rn<=20
order by fisc_wk_id, prod_dept_descr, rn
;
select *
from ty
join ly on(ty.rn=ly.rn)
