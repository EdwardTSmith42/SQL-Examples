--SQL to analyze multiple licenses from a customer perspective.
--This answered questions like: How much do customers spend in certain licenses?  Are they a collector?
--What level of purchases defines a collector?


--Game of Thrones
create temp table t_item as
select item_key, 'gameofthrones                                 ', title, artist_lname
from lu_item
where (item_key in(select item_id
from tbrand
where lower(brand) like '%game%throne%') or title like '%GAME OF THRONES%' or artist_lname like '%GAME OF THRONES%'
or title like '%SONG OF ICE AND FIRE%' or artist_lname like 
'%SONG OF ICE AND FIRE%'
or title like '%SONG OF ICE & FIRE%' or artist_lname like '%SONG OF ICE & FIRE%'
or title like '%CLASH OF KINGS%' or artist_lname like '%CLASH OF KINGS%'
or title like '%STORM OF SWORDS%' or artist_lname like '%STORM OF SWORDS%'
or title like '%FEAST OF CROWS%' or artist_lname like '%FEAST OF CROWS%'
or title like '%DANCE WITH DRAGONS%' or artist_lname like '%DANCE WITH DRAGONS%'
or title like '%WINTER IS COMING%' or artist_lname like '%WINTER IS COMING%'
or title like '%TYRION%' or artist_lname like '%TYRION%'
or title like '%CERSEI%' or artist_lname like '%CERSEI%'
or title like '%TARGARYEN%' or artist_lname like '%TARGARYEN%'
or title like '%DAENERYS%' or artist_lname like '%DAENERYS%'
or title like '%JON SNOW%' or artist_lname like '%JON SNOW%'
or title like '%GREYJOY%' or artist_lname like '%GREYJOY%'
or title like '%HOUSE STARK%' or artist_lname like '%HOUSE STARK%'
or title like '%WINTERFELL%' or artist_lname like '%WINTERFELL%'
or title like '%BARATHEON%' or artist_lname like '%BARATHEON%'
or title like '%KHALEESI%' or artist_lname like '%KHALEESI%')
;

--create license specific information
create temp table t_license as
select
count(distinct d.CUST_ID) number_of_customers, 
	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_license_transactions,
	sum(d.NET_SALES_AMT+d.coup_amt) total_license_revenue,
	sum(d.NET_SALES_AMT+d.coup_amt-d.net_cost) total_license_margin,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_license_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_license_margin_per_customer,
	sum(d.QTY_SOLD) as total_qty_sold,
	round(sum(d.QTY_SOLD) / count(distinct d.CUST_ID),2) as avg_license_items_bought,
	count(distinct d.item_key) as item_count,
	count(distinct c.CUST_EMAIL_ADDR) as email_addresses
from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
;
--create customer table
create temp table t_cust as
select d.cust_id
from  sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  group by 1;
  --create total customer table
  create temp table t_total as
  select

	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_total_transactions,

	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) total_passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) total_passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_total_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_total_margin_per_customer



from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_cust t
	on(t.cust_id=d.cust_id)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;

  --create summary table
  
  create temp table license_summary as
  select *, 'game_of_thrones                   ' as license
  from t_total, t_license;
  
  
  
drop table t_item;
drop table t_license;
drop table t_cust;
drop table t_total;
  
  
  --star wars


--create item table

create temp table t_item as
select item_key, 'starwars                                 ', title, artist_lname
from lu_item
where (item_key in(select item_id
from tbrand
where lower(brand) like '%star%war%') or title like 'STAR WARS' or title like '%STAR WARS' or title like '%STAR WARS%' or title like 'STAR WARS%'
or title like'HAN SOLO' or title like '%HAN SOLO%' or title like 'HAN SOLO%'
or title like'CARBONITE' or title like '%CARBONITE%' or title like 'CARBONITE%'
or title like' LEIA' or title like '% LEIA%' or title like 'LEIA%'
or ((title like' JABBA' or title like '% JABBA%' or title like 'JABBA%') AND title NOT LIKE '%JABBAR%' AND title NOT LIKE '%JABBAW%' AND title NOT LIKE 'JABBA ROCK')
or title like' PADME AMIDAL' or title like '% PADME AMIDAL%' or title like 'PADME AMIDAL%'
or title like' JAR JAR' or title like '% JAR JAR%' or title like 'JAR JAR%'
or title like' C3PO' or title like '% C3PO%' or title like 'C3PO%'
or title like' C-3PO' or title like '% C-3PO%' or title like 'C-3PO%'
or title like' CALRISSIAN' or title like '% CALRISSIAN%' or title like 'CALRISSIAN%'
or title like' CHEWBACCA' or title like '% CHEWBACCA%' or title like 'CHEWBACCA%'
or title like' COUNT DOOKU' or title like '% COUNT DOOKU%' or title like 'COUNT DOOKU%'
or title like' BOBA FETT' or title like '% BOBA FETT%' or title like 'BOBA FETT%'
or title like' JANGO FETT' or title like '% JANGO FETT%' or title like 'JANGO FETT%'
or artist_lname like' STAR WARS' or artist_lname like '% STAR WARS%' or artist_lname like 'STAR WARS%' OR artist_lname LIKE 'STAR WARS'
or title like' GENERAL GRIEVOUS' or title like '% GENERAL GRIEVOUS%' or title like 'GENERAL GRIEVOUS%'
or title like' QUI-GON' or title like '% QUI-GON%' or title like 'QUI-GON%'
or title like' OBI-WAN' or title like '% OBI-WAN%' or title like 'OBI-WAN%'
or title like' OBI WAN' or title like '% OBI WAN%' or title like 'OBI WAN%'
or title like' PLO KOON' or title like '% PLO KOON%' or title like 'PLO KOON%'
or title like' DARTH MAUL' or title like '% DARTH MAUL%' or title like 'DARTH MAUL%'
or title like' PALPATINE' or title like '% PALPATINE%' or title like 'PALPATINE%'
or title like' R2%D2' or title like '% R2%D2%' or title like 'R2%D2%'
or title like'CLONE WARS' or title like '%CLONE WARS%' or title like 'CLONE%WARS%'
or title like' DARTH SIDIOUS' or title like '% DARTH SIDIOUS%' or title like 'DARTH SIDIOUS%'
or title like' LUKE SKYWALKER' or title like '% LUKE SKYWALKER%' or title like 'LUKE SKYWALKER%'
or title like' AHSOKA' or title like '% AHSOKA%' or title like 'AHSOKA%'
or title like' DARTH VADER' or title like '% DARTH VADER%' or title like 'DARTH VADER%'
or title like' ASAJJ' or title like '% ASAJJ%' or title like 'ASAJJ%'
or title like' EWOK' or title like '% EWOK%' or title like 'EWOK%'
or title like' MACE WINDU' or title like '% MACE WINDU%' or title like 'MACE WINDU%'
or ((title like' YODA' or title like '% YODA %' or title like 'YODA %') and (title not like '%YODAS%' or title not like 'DJ%YODA%'))
or title like' XWING' or title like '% X-WING%' or title like 'XWING%'
or title like' JEDI' or title like '% JEDI %' or title like 'JEDI %'
or title like' SW TROOPER' or title like 'SW %TROOPER %' or title like 'SW TROOPER %'
or title like' SW EPISODE' or title like 'SW %EPISODE %' or title like 'SW EPISODE %'
or title like' SW KNIGHTS%OLD' or title like 'SW %KNIGHTS%OLD %' or title like 'SW KNIGHTS%OLD %'
or title like' SW ANAKIN' or title like 'SW %ANAKIN %' or title like 'SW ANAKIN %'
or artist_lname like '%STAR%WARS%')
;

--create license specific information
create temp table t_license as
select
count(distinct d.CUST_ID) number_of_customers, 
	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_license_transactions,
	sum(d.NET_SALES_AMT+d.coup_amt) total_license_revenue,
	sum(d.NET_SALES_AMT+d.coup_amt-d.net_cost) total_license_margin,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_license_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_license_margin_per_customer,
	sum(d.QTY_SOLD) as total_qty_sold,
	round(sum(d.QTY_SOLD) / count(distinct d.CUST_ID),2) as avg_license_items_bought,
	count(distinct d.item_key) as item_count,
	count(distinct c.CUST_EMAIL_ADDR) as email_addresses
from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
;
--create customer table
create temp table t_cust as
select d.cust_id
from  sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  group by 1;
  --create total customer table
  create temp table t_total as
  select

	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_total_transactions,

	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) total_passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) total_passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_total_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_total_margin_per_customer



from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_cust t
	on(t.cust_id=d.cust_id)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;

  --create summary table
  
  insert into license_summary
  select *, 'star_wars                   ' as license
  from t_total, t_license;
  
  
  
drop table t_item;
drop table t_license;
drop table t_cust;
drop table t_total;

--doctorwho

--create item table

create temp table t_item as
select item_key, 'doctorwho                                 ', title, artist_lname, prod_code
from lu_item
where (item_key in(select item_id
from tbrand
where lower(brand) like '%doctor%who%') or title like '%DR %WHO%' and title not like '%GDR%'
or title like '%DR.%WHO%'
or artist_lname like '%DR %WHO%'
or artist_lname like '%DOCTOR WHO%'
or title like '%DOCTOR WHO%'
or title like 'DW %DOCTOR%'
or title like '%TARDIS%'
or title like '% DALEK %'
or (title like'DW %' and title not like 'DW 1 %' and title not like '%DW       %'
	 and title not like 'DW 2 %' and title not like '%DW K %' and title not like 'DW %PICKY %'
	 and title not like '%DW THINKS BIG%' and artist_lname not like '%ARTHUR%' and artist_lname not like '%BARRY%'
	 and artist_lname not like '%BROWN%' and artist_lname not like '%Brown%'  and artist_lname not like '%Graham%' 
	 and artist_lname not like '%Stokes%' and artist_lname not like '%SKATE%'
	and artist_lname not like '%SAS%' and title not like '%DW GRIFF%' and title not like '%DW GO TO YOUR%'
	and title not like '%DW GRIFF%' and artist_lname not like '%NO NAME%'))
;

--create license specific information
create temp table t_license as
select
count(distinct d.CUST_ID) number_of_customers, 
	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_license_transactions,
	sum(d.NET_SALES_AMT+d.coup_amt) total_license_revenue,
	sum(d.NET_SALES_AMT+d.coup_amt-d.net_cost) total_license_margin,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_license_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_license_margin_per_customer,
	sum(d.QTY_SOLD) as total_qty_sold,
	round(sum(d.QTY_SOLD) / count(distinct d.CUST_ID),2) as avg_license_items_bought,
	count(distinct d.item_key) as item_count,
	count(distinct c.CUST_EMAIL_ADDR) as email_addresses
from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
;
--create customer table
create temp table t_cust as
select d.cust_id
from  sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  group by 1;
  --create total customer table
  create temp table t_total as
  select

	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_total_transactions,

	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) total_passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) total_passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_total_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_total_margin_per_customer



from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_cust t
	on(t.cust_id=d.cust_id)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;

  --create summary table
  
  insert into license_summary
  select *, 'doctor_who                   ' as license
  from t_total, t_license;
  
  
  
drop table t_item;
drop table t_license;
drop table t_cust;
drop table t_total;

-- Dragon Ball Z

--create item table

create temp table t_item as
select item_key, 'dbz                                 ', title, artist_lname
from lu_item
where (item_key in(select item_id
from tbrand
where lower(license) like '%dragon%ball%') or title like '%DBZ%' or artist_lname like '%DBZ' or
	title like '%DRAGON%BALL%' or artist_lname like '%DRAGON%BALL%' or
	title like'%DRAGB %' or artist_lname like '%DRAGB %' or
	title like'%SAIYAN%' or artist_lname like'%SAIYAN%' or
	title like'% GOKU %' or artist_lname like '% GOKU %')
;

--create license specific information
create temp table t_license as
select
count(distinct d.CUST_ID) number_of_customers, 
	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_license_transactions,
	sum(d.NET_SALES_AMT+d.coup_amt) total_license_revenue,
	sum(d.NET_SALES_AMT+d.coup_amt-d.net_cost) total_license_margin,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_license_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_license_margin_per_customer,
	sum(d.QTY_SOLD) as total_qty_sold,
	round(sum(d.QTY_SOLD) / count(distinct d.CUST_ID),2) as avg_license_items_bought,
	count(distinct d.item_key) as item_count,
	count(distinct c.CUST_EMAIL_ADDR) as email_addresses
from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
;
--create customer table
create temp table t_cust as
select d.cust_id
from  sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  group by 1;
  --create total customer table
  create temp table t_total as
  select

	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_total_transactions,

	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) total_passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) total_passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_total_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_total_margin_per_customer



from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_cust t
	on(t.cust_id=d.cust_id)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;

  --create summary table
  
  insert into license_summary
  select *, 'dragon_ball_z                   ' as license
  from t_total, t_license;
  
  
  
drop table t_item;
drop table t_license;
drop table t_cust;
drop table t_total;

--magic the gathering


--create item table

create temp table t_item as
select item_key, 'mtg                                 ', title, artist_lname
from lu_item
where (item_key in(select item_id
from tbrand
where lower(brand) like '%magic%') or (title like'MTG %' or title like '% MTG %' or artist_lname like'%MTG%'
	or title like 'MAGIC%GATHERING%' or artist_lname like '%MAGIC%GATHER%')
	and artist_lname not like '%AMERICAN%BAR%' and artist_lname not like'%FODORS%' and artist_lname not like '%DRAGON%LANCE%'
	and artist_lname not like '%MILOW%'
	and artist_lname not like '%MOBIL%'
	and artist_lname not like'%VARIO%'
	and artist_lname not like '%XREF%')
;

--create license specific information
create temp table t_license as
select
count(distinct d.CUST_ID) number_of_customers, 
	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_license_transactions,
	sum(d.NET_SALES_AMT+d.coup_amt) total_license_revenue,
	sum(d.NET_SALES_AMT+d.coup_amt-d.net_cost) total_license_margin,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_license_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_license_margin_per_customer,
	sum(d.QTY_SOLD) as total_qty_sold,
	round(sum(d.QTY_SOLD) / count(distinct d.CUST_ID),2) as avg_license_items_bought,
	count(distinct d.item_key) as item_count,
	count(distinct c.CUST_EMAIL_ADDR) as email_addresses
from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
;
--create customer table
create temp table t_cust as
select d.cust_id
from  sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  group by 1;
  --create total customer table
  create temp table t_total as
  select

	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_total_transactions,

	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) total_passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) total_passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_total_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_total_margin_per_customer



from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_cust t
	on(t.cust_id=d.cust_id)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;

  --create summary table
  
  insert into license_summary
  select *, 'magic_the_gathering                   ' as license
  from t_total, t_license;
  
  
  
drop table t_item;
drop table t_license;
drop table t_cust;
drop table t_total;


--walking dead


create temp table t_item as
select item_key, 'walkingdead                                 ', title, artist_lname
from lu_item
where (item_key in(select item_id
from tbrand
where lower(brand) like '%walking%') or artist_lname like '%WALKING DEAD%' or 
title like '%WALKING DEAD%' and (artist_lname like '%BLU%' or artist_lname like '%WALKING DEAD%' or artist_lname like '%DVD%'
    or artist_lname like '%FCBD%' or artist_lname like '%GAMES%' or artist_lname like '%HUNTER%' or artist_lname like '%IMAGE%' or artist_lname like '%INSIGHT ED%'
    or artist_lname like '%KIRKAMAN%' or artist_lname like '%MOVIE POD%' or artist_fname like '%GUITAR%' or artist_lname like '%NECA%'
    or artist_lname like '%QUIZ BOOK%' or artist_lname like '%RENTAL%' or artist_lname like '%EXCL%' or artist_lname like '%SELLERS%'
    or artist_lname like '%SOUND%' or artist_lname like '%VIDEO%' or artist_lname like '%T-SHIRT%' or artist_lname like '%TRENDS%'
    or artist_lname like '%TV%' or artist_lname like '%COMIC%' or artist_lname like '%VARIOUS%' or artist_lname like '%WHEEL%'
    or artist_lname like '%YUEN%')
or (title like 'WD %' and (artist_lname like '%HALLOWEEN%' or 
        artist_lname like '%MOVIE%WD%' or artist_lname like '%TRENDS%' or artist_lname like '%WALKING%DEAD%'))
or (title like '% WD %' and (artist_lname like '%TRENDS VINYL%')))
;

--create license specific information
create temp table t_license as
select
count(distinct d.CUST_ID) number_of_customers, 
	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_license_transactions,
	sum(d.NET_SALES_AMT+d.coup_amt) total_license_revenue,
	sum(d.NET_SALES_AMT+d.coup_amt-d.net_cost) total_license_margin,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_license_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_license_margin_per_customer,
	sum(d.QTY_SOLD) as total_qty_sold,
	round(sum(d.QTY_SOLD) / count(distinct d.CUST_ID),2) as avg_license_items_bought,
	count(distinct d.item_key) as item_count,
	count(distinct c.CUST_EMAIL_ADDR) as email_addresses
from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
;
--create customer table
create temp table t_cust as
select d.cust_id
from  sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  group by 1;
  --create total customer table
  create temp table t_total as
  select

	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_total_transactions,

	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) total_passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) total_passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_total_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_total_margin_per_customer



from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_cust t
	on(t.cust_id=d.cust_id)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;

  --create summary table
  
  insert into license_summary
  select *, 'walking_dead                   ' as license
  from t_total, t_license;
  
  
  
drop table t_item;
drop table t_license;
drop table t_cust;
drop table t_total;


--minecraft


create temp table t_item as
select item_key, 'minecraft                                 ', title, artist_lname
from lu_item
where (item_key in(select item_id
from tbrand
where lower(license) like '%minecraft%') or title like'%MINE%CRAFT%' or artist_lname like '%MINE%CRAFT%') 
;

--create license specific information
create temp table t_license as
select
count(distinct d.CUST_ID) number_of_customers, 
	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_license_transactions,
	sum(d.NET_SALES_AMT+d.coup_amt) total_license_revenue,
	sum(d.NET_SALES_AMT+d.coup_amt-d.net_cost) total_license_margin,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_license_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_license_margin_per_customer,
	sum(d.QTY_SOLD) as total_qty_sold,
	round(sum(d.QTY_SOLD) / count(distinct d.CUST_ID),2) as avg_license_items_bought,
	count(distinct d.item_key) as item_count,
	count(distinct c.CUST_EMAIL_ADDR) as email_addresses
from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
;
--create customer table
create temp table t_cust as
select d.cust_id
from  sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  group by 1;
  --create total customer table
  create temp table t_total as
  select

	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_total_transactions,

	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) total_passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) total_passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_total_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_total_margin_per_customer



from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_cust t
	on(t.cust_id=d.cust_id)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;

  --create summary table
  
  insert into license_summary
  select *, 'minecraft                   ' as license
  from t_total, t_license;
  
  
  
drop table t_item;
drop table t_license;
drop table t_cust;
drop table t_total;

--sons of anarchy


create temp table t_item as
select item_key, 'soa                                 ', title, artist_lname
from lu_item
where (item_key in(select item_id
from tbrand
where lower(brand) like '%soa%') or ((title like '%SONS OF ANARCHY%' or artist_lname like '%SONS OF ANARCHY%') or
		title like'% SAMCRO %' or artist_lname like '% SAMCRO %' or
 		(title like 'SOA %'	and (artist_lname like '%TREND%' 
		or artist_lname like '%T%SHIRT%' or artist_lname like '%MOVIE POD%' or artist_lname like '%DIECAST%')))) 
;

--create license specific information
create temp table t_license as
select
count(distinct d.CUST_ID) number_of_customers, 
	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_license_transactions,
	sum(d.NET_SALES_AMT+d.coup_amt) total_license_revenue,
	sum(d.NET_SALES_AMT+d.coup_amt-d.net_cost) total_license_margin,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_license_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_license_margin_per_customer,
	sum(d.QTY_SOLD) as total_qty_sold,
	round(sum(d.QTY_SOLD) / count(distinct d.CUST_ID),2) as avg_license_items_bought,
	count(distinct d.item_key) as item_count,
	count(distinct c.CUST_EMAIL_ADDR) as email_addresses
from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
;
--create customer table
create temp table t_cust as
select d.cust_id
from  sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  group by 1;
  --create total customer table
  create temp table t_total as
  select

	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_total_transactions,

	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) total_passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) total_passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_total_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_total_margin_per_customer



from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_cust t
	on(t.cust_id=d.cust_id)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;

  --create summary table
  
  insert into license_summary
  select *, 'sons_of_anarchy                   ' as license
  from t_total, t_license;
  
  
  
drop table t_item;
drop table t_license;
drop table t_cust;
drop table t_total;

--my little pony


create temp table t_item as
select item_key, 'mlp                                 ', title, artist_lname
from lu_item
where (item_key in(select item_id
from tbrand
where lower(brand) like '%mlp%') or 	title like'%MY%LITTLE%PONY%' or artist_lname like'%MY%LITTLE%PONY%' or
	title like'MLP %') 
;

--create license specific information
create temp table t_license as
select
count(distinct d.CUST_ID) number_of_customers, 
	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_license_transactions,
	sum(d.NET_SALES_AMT+d.coup_amt) total_license_revenue,
	sum(d.NET_SALES_AMT+d.coup_amt-d.net_cost) total_license_margin,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_license_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_license_margin_per_customer,
	sum(d.QTY_SOLD) as total_qty_sold,
	round(sum(d.QTY_SOLD) / count(distinct d.CUST_ID),2) as avg_license_items_bought,
	count(distinct d.item_key) as item_count,
	count(distinct c.CUST_EMAIL_ADDR) as email_addresses
from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
;
--create customer table
create temp table t_cust as
select d.cust_id
from  sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  group by 1;
  --create total customer table
  create temp table t_total as
  select

	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_total_transactions,

	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) total_passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) total_passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_total_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_total_margin_per_customer



from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_cust t
	on(t.cust_id=d.cust_id)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;

  --create summary table
  
  insert into license_summary
  select *, 'my_little_pony                   ' as license
  from t_total, t_license;
  
  
  
drop table t_item;
drop table t_license;
drop table t_cust;
drop table t_total;

--hello kitty



create temp table t_item as
select item_key, 'hello_kitty                                 ', title, artist_lname
from lu_item
where (item_key in(select item_id
from tbrand
where lower(brand) like '%hello%') or 	title like'%HELLO%KITTY%' or artist_lname like '%HELLO%KITTY%' or
	title like 'HK %' or title like '% HK' or artist_lname like '%HK%FRIEND%' or
	title like '%CHOCOCAT%' and title not like'%CARRY%PICKPO%')
	
;

--create license specific information
create temp table t_license as
select
count(distinct d.CUST_ID) number_of_customers, 
	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_license_transactions,
	sum(d.NET_SALES_AMT+d.coup_amt) total_license_revenue,
	sum(d.NET_SALES_AMT+d.coup_amt-d.net_cost) total_license_margin,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_license_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_license_margin_per_customer,
	sum(d.QTY_SOLD) as total_qty_sold,
	round(sum(d.QTY_SOLD) / count(distinct d.CUST_ID),2) as avg_license_items_bought,
	count(distinct d.item_key) as item_count,
	count(distinct c.CUST_EMAIL_ADDR) as email_addresses
from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
;
--create customer table
create temp table t_cust as
select d.cust_id
from  sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  group by 1;
  --create total customer table
  create temp table t_total as
  select

	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_total_transactions,

	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) total_passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) total_passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_total_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_total_margin_per_customer



from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_cust t
	on(t.cust_id=d.cust_id)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;

  --create summary table
  
  insert into license_summary
  select *, 'hello_kitty                   ' as license
  from t_total, t_license;
  
  
  
drop table t_item;
drop table t_license;
drop table t_cust;
drop table t_total;

--pokemon

create temp table t_item as
select item_key, 'pokemon                                 ', title, artist_lname
from lu_item
where (item_key in(select item_id
from tbrand
where lower(brand) like '%poke%') or 	title like '%pokemon%' or artist_lname like '%pokemon%' or
	title like'%PIKACHU%' or artist_lname like '%PIKACHU%'
	or title like 'PKM %' or title like 'PKU %' or title like 'POK %'
	or title like '%CHARMANDER%')
	
;

--create license specific information
create temp table t_license as
select
count(distinct d.CUST_ID) number_of_customers, 
	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_license_transactions,
	sum(d.NET_SALES_AMT+d.coup_amt) total_license_revenue,
	sum(d.NET_SALES_AMT+d.coup_amt-d.net_cost) total_license_margin,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_license_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_license_margin_per_customer,
	sum(d.QTY_SOLD) as total_qty_sold,
	round(sum(d.QTY_SOLD) / count(distinct d.CUST_ID),2) as avg_license_items_bought,
	count(distinct d.item_key) as item_count,
	count(distinct c.CUST_EMAIL_ADDR) as email_addresses
from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
;
--create customer table
create temp table t_cust as
select d.cust_id
from  sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  group by 1;
  --create total customer table
  create temp table t_total as
  select

	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_total_transactions,

	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) total_passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) total_passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_total_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_total_margin_per_customer



from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_cust t
	on(t.cust_id=d.cust_id)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;

  --create summary table
  
  insert into license_summary
  select *, 'pokemon                   ' as license
  from t_total, t_license;
  
  
  
drop table t_item;
drop table t_license;
drop table t_cust;
drop table t_total;

--nbx


create temp table t_item as
select item_key, 'nbx                                 ', title, artist_lname
from lu_item
where (item_key in(select item_id
from tbrand
where lower(brand) like '%nbx%') or 	title like '%NBX%' or artist_lname like '%NBX%')
	
;

--create license specific information
create temp table t_license as
select
count(distinct d.CUST_ID) number_of_customers, 
	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_license_transactions,
	sum(d.NET_SALES_AMT+d.coup_amt) total_license_revenue,
	sum(d.NET_SALES_AMT+d.coup_amt-d.net_cost) total_license_margin,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_license_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_license_margin_per_customer,
	sum(d.QTY_SOLD) as total_qty_sold,
	round(sum(d.QTY_SOLD) / count(distinct d.CUST_ID),2) as avg_license_items_bought,
	count(distinct d.item_key) as item_count,
	count(distinct c.CUST_EMAIL_ADDR) as email_addresses
from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
;
--create customer table
create temp table t_cust as
select d.cust_id
from  sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  group by 1;
  --create total customer table
  create temp table t_total as
  select

	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_total_transactions,

	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) total_passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) total_passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_total_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_total_margin_per_customer



from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_cust t
	on(t.cust_id=d.cust_id)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;

  --create summary table
  
  insert into license_summary
  select *, 'nightmare_before_xmas                   ' as license
  from t_total, t_license;
  
  
  
drop table t_item;
drop table t_license;
drop table t_cust;
drop table t_total;

--adventure time

create temp table t_item as
select item_key, 'adventure_time                                 ', title, artist_lname
from lu_item
where (item_key in(select item_id
from tbrand
where lower(brand) like '%adventure%') or 	artist_lname like '%CARTOON NETWORK%' or title like '%CARTOON NETWORK%'
or artist_lname like '%ADV T%' or title like '%ADV T%'
or artist_lname like '%ADVENTURE TIME%' or title like '%ADVENTURE TIME %'
or artist_lname like '%ADVT%' or title like '%ADVT%'
or TITLE like 'AT FINN%' or title like 'AT JAKE%'
or TITLE like 'AT 4 CH%' or title like 'AT BENDER%'
or TITLE like 'AT CARD%' or title like 'AT BMO %'
or TITLE like 'AT NESTING%'
)
	
;

--create license specific information
create temp table t_license as
select
count(distinct d.CUST_ID) number_of_customers, 
	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_license_transactions,
	sum(d.NET_SALES_AMT+d.coup_amt) total_license_revenue,
	sum(d.NET_SALES_AMT+d.coup_amt-d.net_cost) total_license_margin,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_license_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_license_margin_per_customer,
	sum(d.QTY_SOLD) as total_qty_sold,
	round(sum(d.QTY_SOLD) / count(distinct d.CUST_ID),2) as avg_license_items_bought,
	count(distinct d.item_key) as item_count,
	count(distinct c.CUST_EMAIL_ADDR) as email_addresses
from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
;
--create customer table
create temp table t_cust as
select d.cust_id
from  sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  group by 1;
  --create total customer table
  create temp table t_total as
  select

	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_total_transactions,

	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) total_passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) total_passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_total_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_total_margin_per_customer



from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_cust t
	on(t.cust_id=d.cust_id)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;

  --create summary table
  
  insert into license_summary
  select *, 'adventure_time                   ' as license
  from t_total, t_license;
  
  
  
drop table t_item;
drop table t_license;
drop table t_cust;
drop table t_total;

--tmnt

create temp table t_item as
select item_key, 'tmnt                                 ', title, artist_lname
from lu_item
where (item_key in(select item_id
from tbrand
where lower(brand) like '%tmnt%') or 	title like '%TMNT%' or artist_lname like '%TMNT%' or artist_lname like '%TEENAGE MUTANT NINJA TURTLES%' or title like '%TEENAGE MUTANT NINJA TURTLES%'
	
)
	
;

--create license specific information
create temp table t_license as
select
count(distinct d.CUST_ID) number_of_customers, 
	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_license_transactions,
	sum(d.NET_SALES_AMT+d.coup_amt) total_license_revenue,
	sum(d.NET_SALES_AMT+d.coup_amt-d.net_cost) total_license_margin,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_license_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_license_margin_per_customer,
	sum(d.QTY_SOLD) as total_qty_sold,
	round(sum(d.QTY_SOLD) / count(distinct d.CUST_ID),2) as avg_license_items_bought,
	count(distinct d.item_key) as item_count,
	count(distinct c.CUST_EMAIL_ADDR) as email_addresses
from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
;
--create customer table
create temp table t_cust as
select d.cust_id
from  sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  group by 1;
  --create total customer table
  create temp table t_total as
  select

	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_total_transactions,

	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) total_passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) total_passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_total_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_total_margin_per_customer



from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_cust t
	on(t.cust_id=d.cust_id)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;

  --create summary table
  
  insert into license_summary
  select *, 'tmnt                   ' as license
  from t_total, t_license;
  
  
  
drop table t_item;
drop table t_license;
drop table t_cust;
drop table t_total;

--frozen

create temp table t_item as
select item_key, 'frozen                                 ', title, artist_lname
from lu_item
where (item_key in(select item_id
from tbrand
where lower(license) like '%frozen%') or 	title like 'ANNA AND ELSA %' or title like '%FROZEN ELSA%' or artist_lname like 'FROZEN' or title like '%FROZEN OLAF%' or title like '%FROZEN POP %'or 
	(title like 'FROZEN%' and (artist_lname like '%BLU R%' or artist_lname like '%DVD%' or artist_lname like '%SOUNDT%' or artist_lname like '%DISNEY%' or artist_lname like '%FROZEN%' or artist_lname like '%KIDS%' or title like '%DELUXE%' or title like '%SING%LONG%') and title not like '%ALIVE%' and title not like '%ASSET%' and title not like '%IN FEAR%' and title not like '%IN TIME%' and title not like '%IN TIME%' and title not like '%INERTIA%' and title not like '%KISS%' and title not like '%LAND%' and title not like '%LIMITS%' and title not like '%PLANET%' and title not like '%RIVER%' and title not like '%RAIN%' and title not like '%STARS%')
	
)
	
;

--create license specific information
create temp table t_license as
select
count(distinct d.CUST_ID) number_of_customers, 
	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_license_transactions,
	sum(d.NET_SALES_AMT+d.coup_amt) total_license_revenue,
	sum(d.NET_SALES_AMT+d.coup_amt-d.net_cost) total_license_margin,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_license_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_license_margin_per_customer,
	sum(d.QTY_SOLD) as total_qty_sold,
	round(sum(d.QTY_SOLD) / count(distinct d.CUST_ID),2) as avg_license_items_bought,
	count(distinct d.item_key) as item_count,
	count(distinct c.CUST_EMAIL_ADDR) as email_addresses
from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
;
--create customer table
create temp table t_cust as
select d.cust_id
from  sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  group by 1;
  --create total customer table
  create temp table t_total as
  select

	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_total_transactions,

	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) total_passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) total_passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_total_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_total_margin_per_customer



from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_cust t
	on(t.cust_id=d.cust_id)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;

  --create summary table
  
  insert into license_summary
  select *, 'frozen                   ' as license
  from t_total, t_license;
  
  
  
drop table t_item;
drop table t_license;
drop table t_cust;
drop table t_total;

--big bang theory

create temp table t_item as
select item_key, 'big_bang_theory                                 ', title, artist_lname
from lu_item
where (item_key in(select item_id
from tbrand
where lower(license) like '%big_bang%') or 	title like '%BAZINGA %' 
	or title like 'BBT %'
	or title like 'BIG BANG%BAZINGA%' or title like '%BIG BANG THEORY S%' or title like '%BIG BANG%SOFT%KITTY%'  or title like '%BIG BANG%BAZINGA%'

)
	
;

--create license specific information
create temp table t_license as
select
count(distinct d.CUST_ID) number_of_customers, 
	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_license_transactions,
	sum(d.NET_SALES_AMT+d.coup_amt) total_license_revenue,
	sum(d.NET_SALES_AMT+d.coup_amt-d.net_cost) total_license_margin,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_license_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_license_margin_per_customer,
	sum(d.QTY_SOLD) as total_qty_sold,
	round(sum(d.QTY_SOLD) / count(distinct d.CUST_ID),2) as avg_license_items_bought,
	count(distinct d.item_key) as item_count,
	count(distinct c.CUST_EMAIL_ADDR) as email_addresses
from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
;
--create customer table
create temp table t_cust as
select d.cust_id
from  sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  group by 1;
  --create total customer table
  create temp table t_total as
  select

	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_total_transactions,

	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) total_passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) total_passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_total_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_total_margin_per_customer



from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_cust t
	on(t.cust_id=d.cust_id)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;

  --create summary table
  
  insert into license_summary
  select *, 'big_bang_theory                   ' as license
  from t_total, t_license;
  
  
  
drop table t_item;
drop table t_license;
drop table t_cust;
drop table t_total;

--dc:batman

create temp table t_item as
select item_key, 'batman                                 ', title, artist_lname
from lu_item
where (item_key in(select item_id
from tbrand
where lower(license) like '%batman%') or 	title like '% BATMAN %' or title like 'BATMAN %'or artist_lname like '%BATMAN %' or title like '% ARKHAM %' or title like '%CATWOMAN%' or artist_lname like '%CATWOMAN%' or title like '%TWO%FACE %'
	or title like '%HARLEY%QUINN%' or title like '%BATMOBIL%' or title like '% BAT MAN %' or artist_lname like '%BAT MAN%'
	or (title like '%DARK KNIGHT%' and (artist_lname like '%BATMAN%' or artist_fname like'%BATMAN%' or artist_lname like '%SOUNDT%' or artist_lname like '%DARK KNIGHT%' or title like '%BANE%' or title like '%BAT%POD%' or title like '%BATMAN%' or title like '%BAT%' or title like '%JOKER%' or title like '%RISES%' or artist_lname like '%MILLER%FRANK%' or title like '%TRILOGY%'))
	and title not like'%JOHN BATMAN%'
)
	
;

--create license specific information
create temp table t_license as
select
count(distinct d.CUST_ID) number_of_customers, 
	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_license_transactions,
	sum(d.NET_SALES_AMT+d.coup_amt) total_license_revenue,
	sum(d.NET_SALES_AMT+d.coup_amt-d.net_cost) total_license_margin,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_license_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_license_margin_per_customer,
	sum(d.QTY_SOLD) as total_qty_sold,
	round(sum(d.QTY_SOLD) / count(distinct d.CUST_ID),2) as avg_license_items_bought,
	count(distinct d.item_key) as item_count,
	count(distinct c.CUST_EMAIL_ADDR) as email_addresses
from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
;
--create customer table
create temp table t_cust as
select d.cust_id
from  sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  group by 1;
  --create total customer table
  create temp table t_total as
  select

	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_total_transactions,

	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) total_passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) total_passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_total_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_total_margin_per_customer



from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_cust t
	on(t.cust_id=d.cust_id)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;

  --create summary table
  
  insert into license_summary
  select *, 'batman                   ' as license
  from t_total, t_license;
  
  
  
drop table t_item;
drop table t_license;
drop table t_cust;
drop table t_total;


--yugi-oh

create temp table t_item as
select item_key, 'yugi-oh                                 ', title, artist_lname
from lu_item
where (item_key in(select item_id
from tbrand
where lower(brand) like '%yugi%') or 	title like '%YUGIOH%' or title like '%YUGI%OH%' or artist_lname like '%YUGI%OH%' or title like 'YGO %' 
	
)
	
;

--create license specific information
create temp table t_license as
select
count(distinct d.CUST_ID) number_of_customers, 
	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_license_transactions,
	sum(d.NET_SALES_AMT+d.coup_amt) total_license_revenue,
	sum(d.NET_SALES_AMT+d.coup_amt-d.net_cost) total_license_margin,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_license_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_license_margin_per_customer,
	sum(d.QTY_SOLD) as total_qty_sold,
	round(sum(d.QTY_SOLD) / count(distinct d.CUST_ID),2) as avg_license_items_bought,
	count(distinct d.item_key) as item_count,
	count(distinct c.CUST_EMAIL_ADDR) as email_addresses
from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
;
--create customer table
create temp table t_cust as
select d.cust_id
from  sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  group by 1;
  --create total customer table
  create temp table t_total as
  select

	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_total_transactions,

	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) total_passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) total_passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_total_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_total_margin_per_customer



from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_cust t
	on(t.cust_id=d.cust_id)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;

  --create summary table
  
  insert into license_summary
  select *, 'yugi-oh                   ' as license
  from t_total, t_license;
  
  
  
drop table t_item;
drop table t_license;
drop table t_cust;
drop table t_total;

--star trek


create temp table t_item as
select item_key, 'star_trek                                 ', title, artist_lname
from lu_item
where (item_key in(select item_id
from tbrand
where lower(brand) like '%star t%') or 	title like '%STAR TREK%' or title like '%STAR%TREK%' or title like '%CAPT%KIRK%' or title like '%USS ENTERPRISE%' or title like '%KLINGON%' or title like '%ROMULAN%' or title like '%DEEP SPACE NINE%' or title like '%DEEP SPACE 9%' or
	artist_lname like '%STAR%TREK%'  or title like '% SPOCK %' or title like 'STNG %'
	or item_key in(40229048022,40219935493,40219935492,40047692569,40219901966,40047692568,40219069589,40213937214,40219030594,40214111215,40214267812,40252837393,40237028889,40219868147,40237431840,40219868146,40252865364,40252865366,40219510825,40236897803,40219069841,40237431837,40219030595,40237431832,40213906360,40213244687,40215396056,40235281096,40213601364,40220109524,40037188692,40254913931,40216728641,40237028885,40219583098,40229064022,40219618822,40219736769,40219828036,40229064021,40219882278,40214133711,40214133710,40236302063,40219736770,40211908498,40237986183,40224219835,40235349640,40248728763,40237169844,40213906906,40232233310,40237028887,40237028888,40229062784,40248650865,40216758423,40237211128,40237204593,40237174688,40214111219,40220064094,40236675161,40235349638,40216877733,40219901987,40213402744,40219527432,40254930633,40232258674,40220064096,40220064100,40237224953,40220012078,40046696393,40213715872,40210638695,40219901985,40232300283,40213910866,40213906490,40213715359,40229062791,40214224124,40236901972,40232231459,40232231458,40217947034,40219110007,40214223974,40219206500,40219826174,40210439949,40214223789,40232269688,40232204167,40229062799,40214223448,40236495649,40219412812,40219987111,40214223444,40248631832,40213232415,40213232526,40219884368,40236833918,40047294759,40037150729,40220091264,40214595818,40216728651,40232372500,40238539338,40213715989,40219898935,40219645315,40232300278,40217947929,40037149875,40213743904,40037149880,40037149878,40037149872,40219864881,40232231456,40219810590,40219813507,40232231457,40219972412,40219894594,40219987112,40214224121,40216653677,40214223782,40219327470,40219999405,40215486315,40046698450,40237134346,40214308710,40232117790,40213403075,40214224025,40220074122,40214223830,40214223786,40236901896,40214223494,40219987110,40219119271,40214224128,40214224500,40217867931,40217947922,40236901956,40214223437,40219448315,40217600862,40211868236,40213119931,40214223778,40220079940,40218933686,40219609598,40219507828,40018829978,40214223458,40212690999,40216506296,40238540468,40213402523,40215038714,40219606220,40219935494,40219645319,40219837438,40235681766,40214223674,40214880971,40210966046,40214223978,40232412940,40219909792,40047637690,40232379636,40232176445,40237194179,40219291393,40212391149,40213224802,40047376583,40216736367,40220039280,40214223671,40214308721,40213674762,40214223667,40049919816,40018829986,40214309654,40218053855,40210264240,40214111217,40232109788,40232335059,40237233304,40214223463,40235681106,40213609302,40219201181,40219372377,40047933338,40219498984,40017565839,40212421219,40214223459,40218781071,40219609564,40219725066,40232269689,40018885422,40218662021,40232320335,40214224021,40218616687,40212505655,40219618826,40219892084,40218616692,40219528625,40210868644,40213715871,40219201137,40232260156,40046696509,40237233291,40232109877,40219799686,40219201149,40018996736,40213796376,40232260110,40046715112,40215350229,40218933684,40219475350,40219132452,40046696422,40214223455,40214223490,40232109854,40018830127,40219372357,40212189817,40214223664,40224210307,40220064102,40218705899,40235848137,40213564093,40219073415,40232176399,40214593476,40224210232,40049899213,40237233301,40237233299,40017734899,40018829987,40218662016,40219291366,40018880853,40213324301,40018995171,40214223488,40216742444,40218933953,40219901986,40213409541,40212505394,40214224097,40216184876,40219475412,40219584240,40219725036,40210883269,40237233293,40018830133,40218899393,40219828042,40229062782,40214223492,40214223833,40218498535,40218853482,40219542473,40236755225,40215732034,40018890099,40212479913,40214223457,40214223982,40218788792,40219291353,40219515020,40219125139,40046698934,40216758402,40237134347,40018937107,40214429594,40219359213,40219892162,40237233294,40237233300,40212852612,40214223988,40219999406,40220080022,40215732031,40237233296,40018934252,40214224227,40218498527,40218849069,40219125086,40046698437,40211737978,40214111214,40219892006,40219892685,40235848136,40237233305,40219828043,40219828038,40219828048,40219828040,40046698618,40018889924,40219955479,40236755297,40237233303,40018830251,40018830257,40237224992,40046699414,40210359350,40237233292,40237233295,40237233302,40018941478,40017077782,40214224223,40218053862,40219073417,40237233298,40237233297,40018935100,40218983346,40047846851,40211109722,40216758276,40219542420,40219837439,40219894595,40219125102,40049898876,40245167909,40017133850,40217947923,40047118848,40220064098,40218766667,40046698619,40217947930,40220079941,40232187918,40220012087,40216728638,40211013874,40213564101,40019592302,40017115113,40218616688,40219372346,40219291394,40214223837,40213715360,40216307132,40213666242,40018590667,40216365490,40218053856,40219073416,40219201182,40214223985,40212661924,40216187128,40213564095,40213715424,40213715870,40017505609,40212963496,40212843818,40017876734,40217926932,40218613791,40212656281,40017112052,40019576014,40219372405,40219799687,40220079942,40224210233,40214223793,40214223452,40238539339,40224220002,40219893682,40018517330,40214111213,40213564090,40237763784,40019592921,40019604459,40214234797,40216295748,40218616693,40218849070,40248631911,40217891837,40213564089,40019576373,40019576412,40019602688,40019592922,40019610864,40019575383,40212483687,40019576060,40019576420,40018990767,40019592932,40216294333,40218983347,40219073432,40046854591,40212151736,40046905254,40213715678,40047307052,40019604285,40019585013,40019607375,40019591789,40212674197,40019613767,40017505606,40019601891,40019576108,40019576176,40019576109,40019617659,40019576382,40019615367,40019576427,40019576124,40019604657,40211796954,40215334404,40215699266,40217383541,40217839466,40218899394,40219837440,40220080023,40220080024,40248631910,40215732035,40210096492,40213994452,40019587982,40019575075,40219828051,40213105226,40019126227,40017669192,40019574976,40212673321,40019591142,40019591368,40019576129,40019604656,40211829505,40019612213,40019589551,40047228492,40019575365,40019610889,40019575941,40019604286,40019604460,40212975352,40213600070,40019605706,40210273183,40019616963,40019576236,40213659012,40217891833,40218498528,40219125087,40219201138,40219291355,40219475351,40219725037,40232109790,40232304215,40236755226,40237225044,40218053863,40217883692,40252838853,40238540459,40047097250,40019599879,40018842637,40219828044,40237763738,40212212771,40019575366,40213607147,40211545428,40017078312,40213228420,40018361948,40210282253,40019608093,40019589761,40019590511,40019612407,40019585014,40016470360,40019613822,40019601847,40019606132,40019575720,40213054418,40019575239,40019593845,40019588937,40018587253,40018883443,40019564708,40213833541,40214659813,40215392162,40215615476,40217399975,40217538535,40219799688,40220039281,40218498536,40218849092,40219201150,40219291367,40224220720,40219179825,40237763793,40019591484,40019605039,40019589553,40211944499,40019602689,40019589236,40046852852,40047097248,40019575949,40017854850,40046853485,40019610865,40019575042,40212843819,40019576225,40210594184,40019613358,40019607407,40019590642,40019603399,40019607406,40019616215,40019617658,40211987591,40019126618,40212230334,40019298193,40019576383,40018830186,40019587990,40019591141,40019590640,40217947924,40218053857,40218498529,40218838691,40232109856,40218662022,40219125140,40219372358,40046854592,40018936028,40215732032,40049819089,40213715423,40047097249,40214133734,40049642591,40019612406,40019576010,40019576007,40019588924,40019575751,40019590108,40019620507,40019593575,40019576039,40210749622,40046853486,40019625942,40018829984,40019606750,40211786798,40211957562,40019588926,40019593576,40019575662,40016472321,40019575077,40018147506,40019612394,40019575312,40019606131,40019555499,40019620254,40019076632,40019575765,40019625613,40019575928,40019555498,40211786797,40019574972,40017834922,40214224126,40215149714,40216641116,40217945295,40218616689,40218662018,40218849071,40218983348,40219201139,40219220130,40219999407,40220099322,40232109855,40018189991,40019623781,40019616743,40219917454,40224220119,40213115786,40252838852,40213564100,40047097255,40213349333,40213715361,40213715358,40048105705,40019599817,40019587901,40019599968,40237763766,40237763753,40237763748,40237763818,40237763771,40237763799,40237763762,40019599880,40019576403,40018173824,40019576291,40019620253,40019575805,40019575069,40019208909,40018381488,40019591454,40019575963,40019613823,40046854014,40019576098,40019591792,40019625612,40019589900,40019592301,40019576198,40019614533,40019575642,40019621117,40210768857,40019619410,40019576375,40019611783,40019576223,40016470230,40210621617,40210882462,40018361952,40019593846,40211668104,40019575399,40046856033,40019591450,40047260954,40046854544,40019574897,40212087957,40019610890,40019589237,40019575378,40018585189,40213994613,40214071170,40214224130,40214827725,40215444989,40218486508,40219291354,40219475352,40219725038,40232412941,40236901955,40018189992,40019606749,40019603704,40025927274,40210394342,40025927273,40025983917,40210638704,40219892163,40047097251,40047097254,40247812969,40047916044,40049765050,40049965320,40025912016,40019599846,40019599944,40019599910,40019599914,40237763803,40237763808,40237763789,40237763814,40210606563,40019621982,40018173823,40019620505,40019617109,40019593468,40019621116,40019575746,40019576115,40019589439,40019601680,40019209740,40210111619,40019575161,40019576434,40213235390,40211879972,40047287436,40019589760,40019625387,40018147524,40019588936,40047085366,40019625397,40018203011,40019619409,40018381489,40016471919,40019623528,40019626877,40211421787,40019592317,40019575939,40047846850,40018382958,40019607376,40048514695,40019576191,40018139364,40046878766,40019623168,40213450834,40019593466,40019626649,40019623527,40019574999,40019502928,40019575750,40211108568,40019555496,40019375506,40019603398,40212135615,40019786853,40019575384,40046856032,40019576192,40019624836,40019619720,40019615702,40211823612,40213524898,40211416328,40019891188,40213919138,40214025093,40214025094,40214332256,40215458201,40217867907,40218034999,40218600056,40218788793,40218788794,40218904153,40219584268,40219710969,40219850687,40219891394,40220026450,40217891838,40019618378,40019623793,40019618377,40219125103,40219080703,40219764409,40224220657,40047763273,40224220882,40047568170,40047736245,40210265366,40232133504,40224220408,40214327116,40210044422,40213715488,40212961182,40047118812,40210043748,40210086101,40025912017,40019599974,40212266964,40019610432,40018152769,40019610891,40019576041,40018152170,40019614532,40017083556,40046854994,40019591483,40019575169,40211456477,40047377367,40019622603,40019589899,40018201836,40019624835,40211823613,40018541501,40019625823,40046854995,40019575967,40018326642,40019582891,40210026129,40019590280,40019619089,40019575848,40019575804,40019576064,40019613359,40019622600,40018298360,40019366990,40019576238,40019648309,40211336878,40019575141,40018201835,40019606614,40019623176,40019575162,40019592933,40019574942,40212351920,40019619090,40019648500,40018326645,40018618495,40016470295,40046878765,40018564153,40018326646,40214038631,40214071981,40214086601,40214223835,40214224229,40214307579,40217891835,40218662017,40219557038,40220145854,40220146574,40224210234,40229051626,40237134398,40237194223,40237194224,40237224993,40218849094,40218899417,40219916478,40224221001,40219660153,9736058974,40047225173,40210097017,40219909793,40219823775,40219823778,40219892301,40213402595,40047376584,40047097253,40047097256,40047097257,40047097259,40247812970,4.0041E+11,40210110871,40025911990,40019599803,40019610430,40019599854,40237763832,40248702620,40019567261,40047113469,40047137688,40019576293,40017254888,40018141046,40019589440,40018180915,40019593705,40018168411,40019582893,40019575830,40046853628,40019582868,40019575029,40019601890,40019608094,40211243913,40017280433,40019555501,40018144468,40019601845,40019616221,40018144492,40019293033,40019576112,40019611782,40211191219,40211004487,40019605040,40019602110,40210280562,40019613766,40019617108,40019608647,40019582873,40018934236,40019575219,40210331842,40019626374,40019608932,40019703772,40018326641,40019585012,40047241883,40213185963,40019622085,40019626650,40018154465,40019606876,40018352047,40019590507,40019621983,40019576237,40018830124,40018123481,40018176364,40019568992,40019576909,40019608648,40018199528,40019891182,40019621530,40019575944,40019576040,40019575100,40019576280,40019126153,40211467090,40211124309,40019575771,40019575749,40213453180,40019703769,40019608931,40047804199,40025938705,40019575496,40019602111,40019606613,40214223461,40214223990,40214377508,40215334405,40216397073,40216525387,40217799402,40217817137,40217869723,40218678213,40218704671,40218754027,40218977097,40219126206,40219366580,40219475413,40219478445,40219955964,40219971552,40219971777,40220056481,40232287198,40237134399,40248631913,40025959548,40019207278,40218849093,40218899416,40218983363,40219073433,40217538023,40224220658,40224220120,40224220881,40047610813,40047667556,40047814976,40210529993,40211413899,40215345882,40210786881,40219823781,40047097258,40213564103,40212311656,40248724370,40049887440,4.0041E+11,40025912003,40237763757,40219828049,40018274193,40018189930,40019589940,40210066805,40019126140,40018343414,40018938759,40019604151,40019575747,40210017282,40047097260,40019218383,40019582881,40019621533,40019622588,40212164453,40019576370,40211119239,40019614723,40019575065,40018203019,40019567259,40019576371,40018279930,40018168446,40019576369,40019569904,40019617582,40019587698,40019223341,40019575299,40212133923,40019612422,40211830196,40019582886,40019576479,40210665854,40018941989,40212975359,40018351994,40019963960,40019575558,40019606151,40210241964,40019373856,40019582887,40018199529,40019218112,40019213394,40019123335,40018141045,40018180932,40019582885,40019600394,40211438352,40211381736,40019621529,40019570243,40019616222,40019622084,40018351992,40210735528,40019567260,40019605705,40037092129,40019575824,40019602221,40019575772,40019786859,40018187439,40019368771,40019614943,40211142099,40019576239,40019593658,40018326632,40019555500,40018619658,40019575639,40019587697,40018144488,40019209790,40210415398,40019590279,40211140776,40213237723,40019575379,40019387486,40018152781,40210045265,40019600396,40019287774,40018161313,40019417408,40019582871,40018185157,40019603333,40210461588,40019576224,40019574973,40019218111,40019567258,40018161312,40019186910,40018666161,40018996737,40211879973,40018187426,40018199491,40018801131,40019123553,40019603703,40214126131,40214224122,40214331470,40215142242,40215347542,40216736362,40217652041,40217652860,40217669832,40217700544,40217716897,40217717704,40217766781,40217767000,40217781717,40217781751,40217781781,40217781789,40217782553,40217797773,40218021989,40218348701,40218558356,40218643987,40218662027,40218725851,40218794399,40218877162,40218894436,40219115053,40219154921,40219288830,40219697857,40219768263,40219790772,40219824927,40219842659,40219925857,40229045819,40229062053,40232172572,40232176446,40232187055,40232230582,40236184228,40236908799,40237089077,40237163934,40237228258,40238136170,40217779250,40217698035,40217795248,40217652080,40217668305,40217668306,40217684412,40217684413,40219125141,40219362553,40219485085,40219519462,40219580666,40019129344,40217714241,40217812868,40219367762,40019616745,40210862634,40018361843,40216432449,40217938413,40019045088,40224220768,40046905256,40213374669,40025911999,40219764410,40212654830,40211284509,40219660152,40047859780,40047876778,9736058984,40210786882,40210743257,40016470358,40210571708,40219850959,40220137116,40232338019,40210620892,40210568405,40211738035,40030053633,40216640651,40218573051,40215732033,40238539895,40213564099,40047376587,40047874629,40018826253,40037094145,40220099067,40219823776,40219892085,40047516815,40047550215,40219823780,40237163884,40232244071,40018979631,40212656280,40047097252,40213151573,40247812968,40212503450,40213717312,40025912002,40030043107,40026774752,40210019260,9736050784,40210884991,40049513570,40030053269,40030051614,40216356364,40217539418,40019600056,40019571811,40018861076,40019599015,40019610429,40237763878,40019600008
	)
)
	
;

--create license specific information
create temp table t_license as
select
count(distinct d.CUST_ID) number_of_customers, 
	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_license_transactions,
	sum(d.NET_SALES_AMT+d.coup_amt) total_license_revenue,
	sum(d.NET_SALES_AMT+d.coup_amt-d.net_cost) total_license_margin,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_license_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_license_margin_per_customer,
	sum(d.QTY_SOLD) as total_qty_sold,
	round(sum(d.QTY_SOLD) / count(distinct d.CUST_ID),2) as avg_license_items_bought,
	count(distinct d.item_key) as item_count,
	count(distinct c.CUST_EMAIL_ADDR) as email_addresses
from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
;
--create customer table
create temp table t_cust as
select d.cust_id
from  sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  group by 1;
  --create total customer table
  create temp table t_total as
  select

	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_total_transactions,

	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) total_passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) total_passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_total_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_total_margin_per_customer



from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_cust t
	on(t.cust_id=d.cust_id)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;

  --create summary table
  
  insert into license_summary
  select *, 'star_trek                   ' as license
  from t_total, t_license;
  
  
  
drop table t_item;
drop table t_license;
drop table t_cust;
drop table t_total;

--Marilyn Monroe

create temp table t_item as
select item_key, 'marilyn_monroe                                 ', title, artist_lname
from lu_item
where (item_key in(select item_id
from tbrand
where lower(brand) like '%marilyn%') or 	title like '%MARILYN%MONROE%' or artist_lname like'%MARILYN%MONROE%' or title like '%SHOCKING MISS PIL%' or title like '%DANGEROUS YEARS%' or title like 'ASPHALT JUNG%%'
	or title like '%ALL ABOUT EVE %' or title like 'RIGHT CROSS%' or title like '%HOME TOWN STORY%'
	or title like '%AS YOUNG AS YOU F%' or title like '%LOVE NEST%'
	or title like '%LETS MAKE IT LEGAL%' or title like 'CLASH BY NIGHT%' or title like '%WERE NOT MARRIED%'
	or title like '%DONT BOTHER TO KNOCK%' or (artist_lname like '%MONKEY BUSINESS%' and prod_code =92)
	or title like '%O. HENRY%HOUSE%' or title like '%GENTLEMEN PREFER BLOND%'
	or title like '%HOW TO MARRY A MILL%' or title like 'RIVER OF NO RETU%' or title like '%NO BUSINESS LIKE SHOW%'
	OR title like '%SEVEN YEAR ITCH%' or title like '%PRINCE AND THE SHOW%' or (title like '%SOME LIKE IT HOT %' and (artist_lname like '%RENT%' or artist_lname like '%DVD%' or artist_lname like '%BLU%' or artist_lname like '%MONROE%MAR%' or artist_lname like '%SOUND%'))
	or artist_lname like '%MONROE%MARIL%' or title like '%MARILY%MONROE%'
	or (title like '%LETS MAKE LOVE%' and (artist_lname like '%RENT%' or artist_lname like '%DVD%' or artist_lname like '%BLU%' or artist_lname like '%MONROE%MAR%' or artist_lname like '%SOUND%'))
	
)
	
;

--create license specific information
create temp table t_license as
select
count(distinct d.CUST_ID) number_of_customers, 
	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_license_transactions,
	sum(d.NET_SALES_AMT+d.coup_amt) total_license_revenue,
	sum(d.NET_SALES_AMT+d.coup_amt-d.net_cost) total_license_margin,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_license_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_license_margin_per_customer,
	sum(d.QTY_SOLD) as total_qty_sold,
	round(sum(d.QTY_SOLD) / count(distinct d.CUST_ID),2) as avg_license_items_bought,
	count(distinct d.item_key) as item_count,
	count(distinct c.CUST_EMAIL_ADDR) as email_addresses
from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
;
--create customer table
create temp table t_cust as
select d.cust_id
from  sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  group by 1;
  --create total customer table
  create temp table t_total as
  select

	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_total_transactions,

	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) total_passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) total_passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_total_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_total_margin_per_customer



from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_cust t
	on(t.cust_id=d.cust_id)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;

  --create summary table
  
  insert into license_summary
  select *, 'marilyn_monroe                   ' as license
  from t_total, t_license;
  
  
  
drop table t_item;
drop table t_license;
drop table t_cust;
drop table t_total;

--dc:superman


create temp table t_item as
select item_key, 'dc:superman                                 ', title, artist_lname
from lu_item
where (item_key in(select item_id
from tbrand
where lower(license) like '%superman%') or ((title like 'SUPERMAN %' or title like '% SUPERMAN %' or artist_lname like 'SUPERMAN %' or artist_lname like '% SUPERMAN %'
or title like 'SUPER MAN %' or title like '% SUPER MAN %' or artist_lname like 'SUPER MAN %' or artist_lname like '% SUPER MAN %')
and (artist_lname not like '%ARNAU%' AND ARTIST_LNAME NOT LIKE '%LOVE SUPERMAN%' AND ARTIST_LNAME NOT LIKE '%BOW%' AND ARTIST_LNAME NOT LIKE '%CAREY%'
       AND ARTIST_LNAME NOT LIKE '%CED%' AND ARTIST_LNAME NOT LIKE '%CELI%' AND ARTIST_LNAME NOT LIKE '%CORRE%' AND ARTIST_LNAME NOT LIKE '%DE HAVEN%'  AND ARTIST_LNAME NOT LIKE '%DI MAR%' AND ARTIST_LNAME NOT LIKE '%DJONOL%'
       AND ARTIST_LNAME NOT LIKE '%DONOVAN%'  AND ARTIST_LNAME NOT LIKE '%ETTINGER%'  AND ARTIST_LNAME NOT LIKE '%FCBD%'  AND ARTIST_LNAME NOT LIKE '%FLAMING%'  AND ARTIST_LNAME NOT LIKE '%FOWL%' AND ARTIST_LNAME NOT LIKE '%HART%' 
         AND ARTIST_LNAME NOT LIKE '%HUMPHR%' AND ARTIST_LNAME NOT LIKE '%IDAHOSA%'  AND ARTIST_LNAME NOT LIKE '%JOHNSON%' AND ARTIST_LNAME NOT LIKE '%KHAM%' AND ARTIST_LNAME NOT LIKE '%LICHTEN%' AND ARTIST_LNAME NOT LIKE '%LONGGOM%'
         AND ARTIST_LNAME NOT LIKE '%MACCOLL%' AND ARTIST_LNAME NOT LIKE '%MAILER%' AND ARTIST_LNAME NOT LIKE '%MCCUISTIAN%' AND ARTIST_LNAME NOT LIKE '%MESSENGER%' AND ARTIST_LNAME NOT LIKE '%NEFF%' AND ARTIST_LNAME NOT LIKE '%NETHERCOT%'
         AND ARTIST_LNAME NOT LIKE '%OUSPEN%' AND ARTIST_LNAME NOT LIKE '%PARKER%' AND ARTIST_LNAME NOT LIKE '%PASKO%' AND ARTIST_LNAME NOT LIKE '%POLLARD%'
         AND ARTIST_LNAME NOT LIKE '%ROGERS%' AND ARTIST_LNAME NOT LIKE '%ROMAN%' AND ARTIST_LNAME NOT LIKE '%ROSSEN%' AND ARTIST_LNAME NOT LIKE '%RUCKA%'
         AND ARTIST_LNAME NOT LIKE '%SCHOEN%' AND ARTIST_LNAME NOT LIKE '%SHAW%' AND ARTIST_LNAME NOT LIKE '%Shaw%' AND ARTIST_LNAME NOT LIKE '%SHAZAM%' 
         AND ARTIST_LNAME NOT LIKE '%SKATE%' AND ARTIST_LNAME NOT LIKE '%SKEE%' AND ARTIST_LNAME NOT LIKE '%SKELTON%' AND ARTIST_LNAME NOT LIKE '%SKYBOX%'
         AND ARTIST_LNAME NOT LIKE '%SWAIL%' AND ARTIST_LNAME NOT LIKE '%TEMPERA%' AND ARTIST_LNAME NOT LIKE '%THAYER%' AND ARTIST_LNAME NOT LIKE '%TICK%' AND ARTIST_LNAME NOT LIKE '%TYE%' AND ARTIST_LNAME NOT LIKE '%WALCUTT%'
         AND ARTIST_LNAME NOT LIKE '%WELDON%' AND ARTIST_LNAME NOT LIKE '%LONGGOM%')) 
)
	
;

--create license specific information
create temp table t_license as
select
count(distinct d.CUST_ID) number_of_customers, 
	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_license_transactions,
	sum(d.NET_SALES_AMT+d.coup_amt) total_license_revenue,
	sum(d.NET_SALES_AMT+d.coup_amt-d.net_cost) total_license_margin,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_license_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_license_margin_per_customer,
	sum(d.QTY_SOLD) as total_qty_sold,
	round(sum(d.QTY_SOLD) / count(distinct d.CUST_ID),2) as avg_license_items_bought,
	count(distinct d.item_key) as item_count,
	count(distinct c.CUST_EMAIL_ADDR) as email_addresses
from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
;
--create customer table
create temp table t_cust as
select d.cust_id
from  sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  group by 1;
  --create total customer table
  create temp table t_total as
  select

	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_total_transactions,

	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) total_passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) total_passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_total_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_total_margin_per_customer



from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_cust t
	on(t.cust_id=d.cust_id)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;

  --create summary table
  
  insert into license_summary
  select *, 'dc:wonderwoman                   ' as license
  from t_total, t_license;
  
  
  
drop table t_item;
drop table t_license;
drop table t_cust;
drop table t_total;

--dc:wonderwoman

create temp table t_item as
select item_key, 'dc:wonderwoman                                ', title, artist_lname
from lu_item
where (item_key in(select item_id
from tbrand
where lower(license) like '%wonder woman%') or ((title like 'WONDERWOMAN %' or title like '% WONDERWOMAN %' or artist_lname like 'WONDERWOMAN %' or artist_lname like '% WONDERWOMAN %'
or title like 'WONDER WOMAN %' or title like '% WONDER WOMAN %' or artist_lname like 'WONDER WOMAN %' or artist_lname like '% WONDER WOMAN %')))

	
;

--create license specific information
create temp table t_license as
select
count(distinct d.CUST_ID) number_of_customers, 
	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_license_transactions,
	sum(d.NET_SALES_AMT+d.coup_amt) total_license_revenue,
	sum(d.NET_SALES_AMT+d.coup_amt-d.net_cost) total_license_margin,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_license_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_license_margin_per_customer,
	sum(d.QTY_SOLD) as total_qty_sold,
	round(sum(d.QTY_SOLD) / count(distinct d.CUST_ID),2) as avg_license_items_bought,
	count(distinct d.item_key) as item_count,
	count(distinct c.CUST_EMAIL_ADDR) as email_addresses
from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
;
--create customer table
create temp table t_cust as
select d.cust_id
from  sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  group by 1;
  --create total customer table
  create temp table t_total as
  select

	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_total_transactions,

	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) total_passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) total_passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_total_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_total_margin_per_customer



from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_cust t
	on(t.cust_id=d.cust_id)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;

  --create summary table
  
  insert into license_summary
  select *, 'dc:wonderwoman                   ' as license
  from t_total, t_license;
  
  
  
drop table t_item;
drop table t_license;
drop table t_cust;
drop table t_total;

--dc comics total

create temp table t_item as
select item_key, 'dc comics                                ', title, artist_lname
from lu_item
where (item_key in(select item_id
from tbrand
where lower(brand) like '%dc%') or ((title like 'WONDERWOMAN %' or title like '% WONDERWOMAN %' or artist_lname like 'WONDERWOMAN %' or artist_lname like '% WONDERWOMAN %'
or title like 'WONDER WOMAN %' or title like '% WONDER WOMAN %' or artist_lname like 'WONDER WOMAN %' or artist_lname like '% WONDER WOMAN %'))
or ((title like 'SUPERMAN %' or title like '% SUPERMAN %' or artist_lname like 'SUPERMAN %' or artist_lname like '% SUPERMAN %'
or title like 'SUPER MAN %' or title like '% SUPER MAN %' or artist_lname like 'SUPER MAN %' or artist_lname like '% SUPER MAN %')
and (artist_lname not like '%ARNAU%' AND ARTIST_LNAME NOT LIKE '%LOVE SUPERMAN%' AND ARTIST_LNAME NOT LIKE '%BOW%' AND ARTIST_LNAME NOT LIKE '%CAREY%'
       AND ARTIST_LNAME NOT LIKE '%CED%' AND ARTIST_LNAME NOT LIKE '%CELI%' AND ARTIST_LNAME NOT LIKE '%CORRE%' AND ARTIST_LNAME NOT LIKE '%DE HAVEN%'  AND ARTIST_LNAME NOT LIKE '%DI MAR%' AND ARTIST_LNAME NOT LIKE '%DJONOL%'
       AND ARTIST_LNAME NOT LIKE '%DONOVAN%'  AND ARTIST_LNAME NOT LIKE '%ETTINGER%'  AND ARTIST_LNAME NOT LIKE '%FCBD%'  AND ARTIST_LNAME NOT LIKE '%FLAMING%'  AND ARTIST_LNAME NOT LIKE '%FOWL%' AND ARTIST_LNAME NOT LIKE '%HART%' 
         AND ARTIST_LNAME NOT LIKE '%HUMPHR%' AND ARTIST_LNAME NOT LIKE '%IDAHOSA%'  AND ARTIST_LNAME NOT LIKE '%JOHNSON%' AND ARTIST_LNAME NOT LIKE '%KHAM%' AND ARTIST_LNAME NOT LIKE '%LICHTEN%' AND ARTIST_LNAME NOT LIKE '%LONGGOM%'
         AND ARTIST_LNAME NOT LIKE '%MACCOLL%' AND ARTIST_LNAME NOT LIKE '%MAILER%' AND ARTIST_LNAME NOT LIKE '%MCCUISTIAN%' AND ARTIST_LNAME NOT LIKE '%MESSENGER%' AND ARTIST_LNAME NOT LIKE '%NEFF%' AND ARTIST_LNAME NOT LIKE '%NETHERCOT%'
         AND ARTIST_LNAME NOT LIKE '%OUSPEN%' AND ARTIST_LNAME NOT LIKE '%PARKER%' AND ARTIST_LNAME NOT LIKE '%PASKO%' AND ARTIST_LNAME NOT LIKE '%POLLARD%'
         AND ARTIST_LNAME NOT LIKE '%ROGERS%' AND ARTIST_LNAME NOT LIKE '%ROMAN%' AND ARTIST_LNAME NOT LIKE '%ROSSEN%' AND ARTIST_LNAME NOT LIKE '%RUCKA%'
         AND ARTIST_LNAME NOT LIKE '%SCHOEN%' AND ARTIST_LNAME NOT LIKE '%SHAW%' AND ARTIST_LNAME NOT LIKE '%Shaw%' AND ARTIST_LNAME NOT LIKE '%SHAZAM%' 
         AND ARTIST_LNAME NOT LIKE '%SKATE%' AND ARTIST_LNAME NOT LIKE '%SKEE%' AND ARTIST_LNAME NOT LIKE '%SKELTON%' AND ARTIST_LNAME NOT LIKE '%SKYBOX%'
         AND ARTIST_LNAME NOT LIKE '%SWAIL%' AND ARTIST_LNAME NOT LIKE '%TEMPERA%' AND ARTIST_LNAME NOT LIKE '%THAYER%' AND ARTIST_LNAME NOT LIKE '%TICK%' AND ARTIST_LNAME NOT LIKE '%TYE%' AND ARTIST_LNAME NOT LIKE '%WALCUTT%'
         AND ARTIST_LNAME NOT LIKE '%WELDON%' AND ARTIST_LNAME NOT LIKE '%LONGGOM%'))
	or title like '% BATMAN %' or title like 'BATMAN %'or artist_lname like '%BATMAN %' or title like '% ARKHAM %' or title like '%CATWOMAN%' or artist_lname like '%CATWOMAN%' or title like '%TWO%FACE %'
	or title like '%HARLEY%QUINN%' or title like '%BATMOBIL%' or title like '% BAT MAN %' or artist_lname like '%BAT MAN%'
	or (title like '%DARK KNIGHT%' and (artist_lname like '%BATMAN%' or artist_fname like'%BATMAN%' or artist_lname like '%SOUNDT%' or artist_lname like '%DARK KNIGHT%' or title like '%BANE%' or title like '%BAT%POD%' or title like '%BATMAN%' or title like '%BAT%' or title like '%JOKER%' or title like '%RISES%' or artist_lname like '%MILLER%FRANK%' or title like '%TRILOGY%'))
	and title not like'%JOHN BATMAN%')
	
	
;

--create license specific information
create temp table t_license as
select
count(distinct d.CUST_ID) number_of_customers, 
	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_license_transactions,
	sum(d.NET_SALES_AMT+d.coup_amt) total_license_revenue,
	sum(d.NET_SALES_AMT+d.coup_amt-d.net_cost) total_license_margin,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_license_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_license_margin_per_customer,
	sum(d.QTY_SOLD) as total_qty_sold,
	round(sum(d.QTY_SOLD) / count(distinct d.CUST_ID),2) as avg_license_items_bought,
	count(distinct d.item_key) as item_count,
	count(distinct c.CUST_EMAIL_ADDR) as email_addresses
from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
;
--create customer table
create temp table t_cust as
select d.cust_id
from  sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  group by 1;
  --create total customer table
  create temp table t_total as
  select

	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_total_transactions,

	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) total_passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) total_passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_total_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_total_margin_per_customer



from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_cust t
	on(t.cust_id=d.cust_id)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;

  --create summary table
  
  insert into license_summary
  select *, 'dc_comics                   ' as license
  from t_total, t_license;
  
  
  
drop table t_item;
drop table t_license;
drop table t_cust;
drop table t_total;

--monster high

create temp table t_item as
select item_key, 'monster_high                                ', title, artist_lname
from lu_item
where (item_key in(select item_id
from tbrand
where lower(brand) like '%monster%') or title like '%NEW%GHOUL%SCHOOL%'
	or artist_lname like '%MONSTER%HIGH% '
	or title like'%GHOULS%FALL%LOVE%' or title like '%ESCAPE%SKULL%SHORE%' or title like '%GHOUL%RULE%' or
	title like '%FRIDAY%NIGHT%FRIGH%' or title like '%SCARIS%CITY%FRIGHT%' or title like '%FRIGHTS%CAMERA%ACTION%' or
	title like '%FREAKY%FUSION%' or title like '%MONSTER%HIGH%')
	
	
;

--create license specific information
create temp table t_license as
select
count(distinct d.CUST_ID) number_of_customers, 
	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_license_transactions,
	sum(d.NET_SALES_AMT+d.coup_amt) total_license_revenue,
	sum(d.NET_SALES_AMT+d.coup_amt-d.net_cost) total_license_margin,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_license_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_license_margin_per_customer,
	sum(d.QTY_SOLD) as total_qty_sold,
	round(sum(d.QTY_SOLD) / count(distinct d.CUST_ID),2) as avg_license_items_bought,
	count(distinct d.item_key) as item_count,
	count(distinct c.CUST_EMAIL_ADDR) as email_addresses
from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
;
--create customer table
create temp table t_cust as
select d.cust_id
from  sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  group by 1;
  --create total customer table
  create temp table t_total as
  select

	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_total_transactions,

	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) total_passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) total_passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_total_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_total_margin_per_customer



from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_cust t
	on(t.cust_id=d.cust_id)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;

  --create summary table
  
  insert into license_summary
  select *, 'monster_high                   ' as license
  from t_total, t_license;
  
  
  
drop table t_item;
drop table t_license;
drop table t_cust;
drop table t_total;

--marvel:captain america


create temp table t_item as
select item_key, 'marvel: captain america                                ', title, artist_lname
from lu_item
where (item_key in(select item_id
from tbrand
where lower(license) like '%capt%amer%') or artist_lname like '%CAPTAIN%AMERIC%' 
or (title like '%CA2%' and artist_lname like '%TRENDS%')
or title like '%STEVE ROGERS%'
or title like '%CAPTAIN%AMERIC%' 
or artist_lname like'%WINTER%SOLDIER%'
or title like'%BUCKY%BARNES')
	
	
;

--create license specific information
create temp table t_license as
select
count(distinct d.CUST_ID) number_of_customers, 
	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_license_transactions,
	sum(d.NET_SALES_AMT+d.coup_amt) total_license_revenue,
	sum(d.NET_SALES_AMT+d.coup_amt-d.net_cost) total_license_margin,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_license_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_license_margin_per_customer,
	sum(d.QTY_SOLD) as total_qty_sold,
	round(sum(d.QTY_SOLD) / count(distinct d.CUST_ID),2) as avg_license_items_bought,
	count(distinct d.item_key) as item_count,
	count(distinct c.CUST_EMAIL_ADDR) as email_addresses
from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
;
--create customer table
create temp table t_cust as
select d.cust_id
from  sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  group by 1;
  --create total customer table
  create temp table t_total as
  select

	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_total_transactions,

	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) total_passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) total_passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_total_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_total_margin_per_customer



from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_cust t
	on(t.cust_id=d.cust_id)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;

  --create summary table
  
  insert into license_summary
  select *, 'marvel: captain america                   ' as license
  from t_total, t_license;
  
  
  
drop table t_item;
drop table t_license;
drop table t_cust;
drop table t_total;

--marvel:xmen 

insert into t_item
select item_key, 'marvel: xmen                                ', title, artist_lname
from lu_item
where (item_key in(select item_id
from tbrand
where lower(license) like '%x%men%') or ((title like 'XMEN%' or title like '%XMEN%'
OR title like 'X-MEN%' or title like 'X-MEN%'
OR (title like 'WOLVERINE  %' and (artist_lname like '%DVD%' or artist_lname like '%MARVEL%' or artist_lname like'%X%MEN%')) or title like 'DVD-WOLVERINE  %'
OR ((artist_lname like 'ICEMAN' or artist_lname like ' ICEMAN%') and artist_fname is null)
or title like 'MARVEL GIRL%' or title like 'MARVEL GIRL%'
or ((Artist_LNAME like 'NIGHTCRAWLER' or Artist_LNAME like 'NIGHTCRAWLER') AND artist_FNAME IS NULL)
OR  ((Artist_LNAME like 'NIGHTCRAWLER' or Artist_LNAME like 'NIGHTCRAWLER%') AND artist_FNAME ='MARVEL NOW')
Or title like 'XMEN%' or title like '%XMEN%'
or title like 'X-MEN%' or title like 'X-MEN%')
or artist_lname like '%XMEN%' or artist_lname like '%X-MEN%'))
	
	
;



--create license specific information
create temp table t_license as
select
count(distinct d.CUST_ID) number_of_customers, 
	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_license_transactions,
	sum(d.NET_SALES_AMT+d.coup_amt) total_license_revenue,
	sum(d.NET_SALES_AMT+d.coup_amt-d.net_cost) total_license_margin,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_license_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_license_margin_per_customer,
	sum(d.QTY_SOLD) as total_qty_sold,
	round(sum(d.QTY_SOLD) / count(distinct d.CUST_ID),2) as avg_license_items_bought,
	count(distinct d.item_key) as item_count,
	count(distinct c.CUST_EMAIL_ADDR) as email_addresses
from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
;
--create customer table
create temp table t_cust as
select d.cust_id
from  sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_item ii
	on(ii.item_key=i.item_key)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  group by 1;
  --create total customer table
  create temp table t_total as
  select

	round(count(distinct d.POS_TRANS_ID || d.STORE_ID )/ count(distinct d.cust_id),2) avg_total_transactions,

	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end) total_passport_revenue,
	sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) total_passport_margin,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt else 0 end)/ count(distinct d.CUST_ID),2) avg_total_revenue_per_customer,
	round(sum(case when d.CUST_ID is not null then d.NET_SALES_AMT+d.coup_amt-d.net_cost else 0 end) / count(distinct d.CUST_ID),2) avg_total_margin_per_customer



from sales_fact_dtl D
join lu_item i
	on(i.item_key=d.item_key)
join lu_comp_store l
 on(l.STORE_ID=d.store_id and l.COMP_FLG in('TY') )
join lu_date dc
	on(d.bus_date=dc.date)
join t_cust t
	on(t.cust_id=d.cust_id)
left join lu_customer c
	on(c.CUST_ID=d.cust_id and c.STORE_ID=d.store_id)
where d.IS_OVRNG='N'
and i.GRP_DEPT_ID not in(-1,-2,13)
and d.bus_date between '2014-07-01' and '2015-06-30'
 and d.POS_TRANS_ID not in(select pos_trans_id from buyback_fact_dtl where store_id = d.STORE_ID)
and (l.CLOSE_DATE>='2015-07-15'
  or l.CLOSE_DATE is null)
  and d.BUS_DATE>=l.Comp_date
  ;

  --create summary table
  
  insert into license_summary
  select *, 'marvel: x-men                   ' as license
  from t_total, t_license;
  
  
  
drop table t_item;
drop table t_license;
drop table t_cust;
drop table t_total;

select *
from license_summary;