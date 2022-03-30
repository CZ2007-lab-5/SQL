with iPhoneXs_PIDS as ( -- select those record with PName = 'iPhone Xs'
  select PName, PID
  from PRODUCTS
  where PName = 'iPhone Xs'
),
 -- join with PRICE_HISTORY to get all records of 'iPhone Xs' which (partially) contains
 -- price records from 2021-08-01 to 2021-08-31
PH_records as (
  select I.PID, I.PName, PH.price, PH.Start_date, PH.End_date
  from iPhoneXs_PIDS as I inner join PRICE_HISTORY as PH on (I.PID = PH.PID)
  where not (End_date < '2021-08-01' or Start_date > '2021-08-31')
),
-- for each record, calculate price*duration
price_times_date_record as (
  select PID, PName, price, (datediff(day, 
                              IIF('2021-08-01' > Start_date, '2021-08-01', Start_date), 
                              IIF('2021-08-31' < End_date, '2021-08-31', End_date)
                              )
                      + 1) as price_times_date
  from PH_records
)
-- sum up the price*duration and get the average.
select PID, PName, sum(price_times_date*price)/(datediff(day, '2021-08-01', '2021-08-31') + 1) as price_avg
from price_times_date_record
group by PID, PName;
-- the result is shown for each product in shops
-- if the avg price of the whole website is needed, take average on price_avg again


-- query 2
-- select those product(pid) have 100+ 5-star feedback in August
with five_star_in_june as (
  select PID
  from FEEDBACK as F
  where (
    '2021-08-01' <= F.Date_time 
      and F.Date_time < '2021-09-01'
      and rating = '5'
  )
),
selected_product_pname as (
  select P.PName, count(P.PID) as rating_count
  from PRODUCTS as P join five_star_in_june on (P.PID = five_star_in_june.PID)
  group by PName
),
selected_product_pid as (
  select P.PID, P.PName
  from PRODUCTS as P join selected_product_pname on (P.PName = selected_product_pname.PName)
),
-- for the selected product(pid), calculate average ratings
rating_info as (
  select PName, avg(rating) as rating_avg
  from (
    FEEDBACK as F
    inner join 
    selected_product_pid 
    on (F.PID = selected_product_pid.PID)
  )
  group by PName
)
-- order by average ratings
select *
from rating_info
order by rating_avg

-- query 3
-- calculate the date between Delivery_date and ordered_date (Date_time)
select avg(datediff(day, A.Date_time, A.Delivery_date)+1) as delivery_time_avg
from (
  select P.PID, P.OID, Date_time, Delivery_date, Status
  from  PRODUCT_IN_ORDERS as P
        inner join ORDERS as O 
        on (P.OID = O.OID)
  where '2021-06-01' <= Date_time -- filter the orders which are created in June,
      and Date_time < '2021-07-01' --  and have been delivered.
      and Status = 'Delivered'
) as A


