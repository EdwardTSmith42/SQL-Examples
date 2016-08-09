--query to analyze if customers who reserved bought more or less...
create temp table t_pickup as
select *
from external 'C:\\pickup.csv'
(store_id integer, pickup_trans_id integer, line_num integer)
using (
delimiter ','
remotesource 'odbc'
logdir 'C:\\temp'
skiprows 1
maxerrors 0
fillrecord);

--mad max reservation transactions
create temp table t_trans_max as
select d.POS_TRANS_ID, d.STORE_ID
from sales_fact_dtl d
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('G') )
join t_pickup t
	on(t.pickup_trans_id= d.POS_TRANS_ID and t.store_id= d.STORE_ID and t.line_num= d.LINE_NUM)
join lu_item i
	on(i.ITEM_KEY=d.item_key)
where d.IS_OVRNG='N'
and d.STORE_ID<>9000
and d.IS_GOSHP_ID=0
and d.STORE_ID between 9303 and 9346
and i.GRP_DEPT_ID not in(-1,-2,13)
and (l.CLOSE_DATE>='2015-09-20'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  and d.ITEM_KEY in(40257467751,40257467752,40257805089,40257569343)
group by 1,2;

--mad max reservation ring
select count( distinct d.POS_TRANS_ID || d.STORE_ID) as distinct_trans,
sum(d.NET_SALES_AMT + d.COUP_AMT) revenue,
sum((d.NET_SALES_AMT + d.COUP_AMT)- d.NET_COST) margin_dlr,
sum((d.NET_SALES_AMT + d.COUP_AMT)- d.NET_COST) / count(distinct d.POS_TRANS_ID || d.STORE_ID) avg_margin,
sum((d.NET_SALES_AMT + d.COUP_AMT)) / count(distinct d.POS_TRANS_ID || d.STORE_ID) avg_ring,
sum(d.QTY_SOLD) / count(distinct d.POS_TRANS_ID || d.STORE_ID) avg_QTY_sold
from sales_fact_dtl d
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('G') )
join t_trans_max t
	on(t.pos_trans_id=d.pos_trans_id and t.store_id=d.store_id)
join lu_item i
	on(i.ITEM_KEY=d.item_key)
where d.IS_OVRNG='N'
and d.STORE_ID<>9000
and d.IS_GOSHP_ID=0

and i.GRP_DEPT_ID not in(-1,-2,13)
and (l.CLOSE_DATE>='2015-09-20'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;
  
  --mad max non reservations
 create temp table t_trans_max_non as
select d.POS_TRANS_ID, d.STORE_ID
from sales_fact_dtl d
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('G') )

join lu_item i
	on(i.ITEM_KEY=d.item_key)
where d.IS_OVRNG='N'
and d.STORE_ID<>9000
and d.IS_GOSHP_ID=0
and d.STORE_ID between 9303 and 9346
and i.GRP_DEPT_ID not in(-1,-2,13)
and (l.CLOSE_DATE>='2015-09-20'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE between '2015-08-30' and '2015-09-05'
  and d.BUS_DATE>=l.Comp_date
  and d.ITEM_KEY in(40257467751,40257467752,40257805089,40257569343)
and d.POS_TRANS_ID || d.STORE_ID not in(select pos_trans_id || store_id from t_trans_max group by 1)
group by 1,2;

--mad_max non reservation ring
select count( distinct d.POS_TRANS_ID || d.STORE_ID) as distinct_trans,
sum(d.NET_SALES_AMT + d.COUP_AMT) revenue,
sum((d.NET_SALES_AMT + d.COUP_AMT)- d.NET_COST) margin_dlr,
sum((d.NET_SALES_AMT + d.COUP_AMT)- d.NET_COST) / count(distinct d.POS_TRANS_ID || d.STORE_ID) avg_margin,
sum((d.NET_SALES_AMT + d.COUP_AMT)) / count(distinct d.POS_TRANS_ID || d.STORE_ID) avg_ring,
sum(d.QTY_SOLD) / count(distinct d.POS_TRANS_ID || d.STORE_ID) avg_QTY_sold
from sales_fact_dtl d
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('G') )
join t_trans_max_non t
	on(t.pos_trans_id=d.pos_trans_id and t.store_id=d.store_id)
join lu_item i
	on(i.ITEM_KEY=d.item_key)
where d.IS_OVRNG='N'
and d.STORE_ID<>9000
and d.IS_GOSHP_ID=0
and i.GRP_DEPT_ID not in(-1,-2,13)
and (l.CLOSE_DATE>='2015-09-20'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;

--furious 7 reservations trans
create temp table t_trans as
select d.POS_TRANS_ID, d.STORE_ID
from sales_fact_dtl d
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('G') )
join t_pickup t
	on(t.pickup_trans_id= d.POS_TRANS_ID and t.store_id= d.STORE_ID and t.line_num= d.LINE_NUM)
join lu_item i
	on(i.ITEM_KEY=d.item_key)
where d.IS_OVRNG='N'
and d.STORE_ID<>9000
and d.IS_GOSHP_ID=0
and d.STORE_ID between 9303 and 9346
and i.GRP_DEPT_ID not in(-1,-2,13)
and (l.CLOSE_DATE>='2015-09-20'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  and d.ITEM_KEY in(40257244047,40257244048,40257244045,40257244046)
group by 1,2;
--furious 7 reservation ring
select count( distinct d.POS_TRANS_ID || d.STORE_ID) as distinct_trans,
sum(d.NET_SALES_AMT + d.COUP_AMT) revenue,
sum((d.NET_SALES_AMT + d.COUP_AMT)- d.NET_COST) margin_dlr,
sum((d.NET_SALES_AMT + d.COUP_AMT)- d.NET_COST) / count(distinct d.POS_TRANS_ID || d.STORE_ID) avg_margin,
sum((d.NET_SALES_AMT + d.COUP_AMT)) / count(distinct d.POS_TRANS_ID || d.STORE_ID) avg_ring,
sum(d.QTY_SOLD) / count(distinct d.POS_TRANS_ID || d.STORE_ID) avg_QTY_sold
from sales_fact_dtl d
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('G') )
join t_trans t
	on(t.pos_trans_id=d.pos_trans_id and t.store_id=d.store_id)
join lu_item i
	on(i.ITEM_KEY=d.item_key)
where d.IS_OVRNG='N'
and d.STORE_ID<>9000
and d.IS_GOSHP_ID=0
and i.GRP_DEPT_ID not in(-1,-2,13)
and (l.CLOSE_DATE>='2015-09-20'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;
--godzilla  
  create temp table t_trans2 as
select d.POS_TRANS_ID, d.STORE_ID
from sales_fact_dtl d
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('G') )

join lu_item i
	on(i.ITEM_KEY=d.item_key)
where d.IS_OVRNG='N'
and d.STORE_ID<>9000
and d.STORE_ID between 9303 and 9346
and d.IS_GOSHP_ID=0
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.BUS_DATE between '2014-09-14' and '2014-09-20'
and (l.CLOSE_DATE>='2015-09-20'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  and d.ITEM_KEY in(40237092955,40237092957,40237092956,40237204853)
group by 1,2;
--godzilla ring
select count( distinct d.POS_TRANS_ID || d.STORE_ID) as distinct_trans,
sum(d.NET_SALES_AMT + d.COUP_AMT) revenue,
sum((d.NET_SALES_AMT + d.COUP_AMT)- d.NET_COST) margin_dlr,
sum((d.NET_SALES_AMT + d.COUP_AMT)- d.NET_COST) / count(distinct d.POS_TRANS_ID || d.STORE_ID) avg_margin,
sum((d.NET_SALES_AMT + d.COUP_AMT)) / count(distinct d.POS_TRANS_ID || d.STORE_ID) avg_ring,
sum(d.QTY_SOLD) / count(distinct d.POS_TRANS_ID || d.STORE_ID) avg_QTY_sold
from sales_fact_dtl d
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('G') )
join t_trans2 t
	on(t.pos_trans_id=d.pos_trans_id and t.store_id=d.store_id)
join lu_item i
	on(i.ITEM_KEY=d.item_key)
where d.IS_OVRNG='N'
and d.STORE_ID<>9000
and d.IS_GOSHP_ID=0
and i.GRP_DEPT_ID not in(-1,-2,13)
and (l.CLOSE_DATE>='2015-09-20'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;
--furious 7 non reservations
 create temp table t_trans3 as
select d.POS_TRANS_ID, d.STORE_ID
from sales_fact_dtl d
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('G') )

join lu_item i
	on(i.ITEM_KEY=d.item_key)
where d.IS_OVRNG='N'
and d.STORE_ID<>9000
and d.STORE_ID between 9303 and 9346
and d.IS_GOSHP_ID=0
and i.GRP_DEPT_ID not in(-1,-2,13)
and (l.CLOSE_DATE>='2015-09-20'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  and d.ITEM_KEY in(40257244047,40257244048,40257244045,40257244046)
and d.POS_TRANS_ID || d.STORE_ID not in(select pos_trans_id || store_id from t_trans group by 1)
group by 1,2;

--furious 7 non reservation ring
select count( distinct d.POS_TRANS_ID || d.STORE_ID) as distinct_trans,
sum(d.NET_SALES_AMT + d.COUP_AMT) revenue,
sum((d.NET_SALES_AMT + d.COUP_AMT)- d.NET_COST) margin_dlr,
sum((d.NET_SALES_AMT + d.COUP_AMT)- d.NET_COST) / count(distinct d.POS_TRANS_ID || d.STORE_ID) avg_margin,
sum((d.NET_SALES_AMT + d.COUP_AMT)) / count(distinct d.POS_TRANS_ID || d.STORE_ID) avg_ring,
sum(d.QTY_SOLD) / count(distinct d.POS_TRANS_ID || d.STORE_ID) avg_QTY_sold
from sales_fact_dtl d
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('G') )
join t_trans3 t
	on(t.pos_trans_id=d.pos_trans_id and t.store_id=d.store_id)
join lu_item i
	on(i.ITEM_KEY=d.item_key)
where d.IS_OVRNG='N'
and d.STORE_ID<>9000
and d.IS_GOSHP_ID=0
and i.GRP_DEPT_ID not in(-1,-2,13)
and (l.CLOSE_DATE>='2015-09-20'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;