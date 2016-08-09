--association rules by brute force:  find the items bought together and rank by frequency

select d.item_key, i.TITLE,  count(distinct d.STORE_ID ||d.pos_trans_id) times_together,
	count( distinct case when d.ITEM_KEY=40219931312 then d.STORE_ID || d.POS_TRANS_ID else null end) total_times_bought
from	SALES_FACT_DTL	d
join lu_item i
	on(d.ITEM_KEY=i.item_key)

where	((d.POS_TRANS_ID,
	d.STORE_ID)
 in	(select	r11.POS_TRANS_ID,
		r11.STORE_ID
	from	SALES_FACT_DTL	r11
		join	LU_ITEM	r12
		  on 	(r11.ITEM_KEY = r12.ITEM_KEY)
	where	(r11.ITEM_KEY = 40219931312
	 and r11.IS_OVRNG in ('N')
	 and r12.GRP_DEPT_ID not in (-2, -1, 13)
	 and r11.IS_GOSHP_ID=0

	 and r11.store_id>9000)
	group by	r11.POS_TRANS_ID,
		r11.STORE_ID))
		and d.IS_OVRNG='N' and 
		i.GRP_DEPT_ID not in(-2,-1,13)
		and d.IS_GOSHP_ID=0
		and d.STORE_ID>9000

		group by 1,2
		order by 3 desc


