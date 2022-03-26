-- query 1
with iPhoneXs_PIDS as (
  select PName, PID
  from PRODUCTS
  where PName = 'iPhone Xs'
),
PH_records as (
  select I.PID, I.PName, PH.price, PH.Start_date, PH.End_date
  from iPhoneXs_PIDS as I inner join PRICE_HISTORY as PH on (I.PID = PH.PID)
  where (PH.Start_date between '2021-08-01' and '2021-08-31')
        or (PH.End_date between '2021-08-01' and '2021-08-31')
),
price_times_date_record as (
  select PID, PName, (datediff(day, 
                              IIF('2021-08-01' > Start_date, '2021-08-01', Start_date), 
                              IIF('2021-08-31' < End_date, '2021-08-31', End_date)
                              )
                      + 1) as price_times_date
  from PH_records
)
select PID, PName, sum(price_times_date)/(datediff(day, '2021-08-01', '2021-08-31') + 1) as price_avg
from price_times_date_record
group by PID, PName;


-- query 2
with selected_pids as (
  select PID
  from FEEDBACK as F
  where (
    '2021-08-01' <= F.Date_time 
      and F.Date_time < '2021-09-01'
      and rating = '5'
  )
  group by PID
  having count(rating) >= 100
),
rating_info as (
  select F.PID, avg(rating) as rating_avg
  from (
    FEEDBACK as F
    inner join 
    selected_pids 
    on (F.PID = selected_pids.PID)
  )
  group by F.PID
)
select P.PID, P.Pname, rating_avg
from rating_info inner join PRODUCTS as P on (rating_info.PID = P.PID)
order by rating_avg

-- query 3
select avg(datediff(day, A.Delivery_date, A.Date_time)+1) as delivery_time_avg
from (
  select P.PID, P.OID, Date_time, Delivery_date, Status
  from  PRODUCT_IN_ORDERS as P
        inner join ORDERS as O 
        on (P.OID = O.OID)
  where '2021-06-01' <= Date_time 
      and Date_time < '2021-07-01' 
      and Status = 'delivered'
) as A


