-- query 4
-- Find the average latency for each employee
WITH COMPLAINT_LATENCY AS (
      SELECT EID, AVG(datediff(second, Handled_date_time, Addressed_date_time)) as Latency
      FROM COMPLAINTS
      WHERE Status = 'Addressed'  -- only complaints have been addressed have above 2 times slot
      GROUP BY EID)
SELECT CL.EID
FROM COMPLAINT_LATENCY AS CL
WHERE CL.Latency = (SELECT MIN(CL.Latency)   -- select employees with smallest latency
                    FROM COMPLAINT_LATENCY AS CL)


-- query 5
SELECT P.PName, COUNT(*) AS Num_of_shops
FROM PRODUCTS AS P, PRODUCT_IN_SHOPS AS PS    -- inner join PRODUCTS & PRODUCT_IN_SHOPS through PID
WHERE P.PID = PS.PID AND
      P.Maker = 'Samsung'         -- filter whose maker is Samsung
GROUP BY P.PName;


-- query 6
-- Find the revenue of each shop in August 2021
WITH SHOP_REVENUE AS (
      SELECT PO.SID, SUM(PO.OPrice * PO.OQuantity) AS Total_revenue
      FROM PRODUCT_IN_ORDERS AS PO, ORDERS AS O    -- inner join through OID
      WHERE PO.OID = O.OID AND 
            O.Date_time BETWEEN '2021-08-01' AND '2021-08-31' -- restric purchasing time to August
      GROUP BY PO.SID
)
SELECT SID
FROM SHOP_REVENUE AS SR
WHERE SR.Total_revenue = (SELECT MAX(Total_revenue)   -- select shop with most revenue
                          FROM SHOP_REVENUE);


-- query 7
-- Find users that made the most amount of complaints
WITH COMPLAINT_COUNT AS (
      SELECT UID
      FROM COMPLAINTS
      GROUP BY UID
      HAVING COUNT(*) >= ALL (SELECT COUNT(*)    -- selected user makes more complaints 
                              FROM COMPLAINTS    -- than any other users
                              GROUP BY UID)),
-- Find all the products the user purchased before with their products
USER_PRODUCT AS (
      SELECT O.UID, PO.PID, PO.Oprice
      FROM PRODUCT_IN_ORDERS AS PO, ORDERS AS O, COMPLAINT_COUNT AS CC
      WHERE PO.OID = O.OID AND                    -- inner join through OID & UID
            O.UID = CC.UID)
SELECT UP1.UID, UP1.PID
FROM USER_PRODUCT AS UP1
WHERE UP1.OPrice >= ALL (SELECT OPrice            -- for each user, find the most
                         FROM USER_PRODUCT AS UP2 -- expensive products he bought
                         WHERE UP1.UID = UP2.UID);


-- query 8 version 1 
-- for products that have never been purchased by some users only in August
-- Find the number of users who purchased each product before in 2021 Auguest
WITH PRODUCT_USER_AUG AS (
      SELECT P.PName, COUNT(*) AS Num_of_users
      FROM PRODUCTS AS P, PRODUCT_IN_ORDERS AS PO, ORDERS AS O
      WHERE P.PID = PO.PID AND                   -- inner join through OID & PID
            O.OID = PO.OID AND
            O.Date_time BETWEEN '2021-08-01' AND '2021-08-31' -- restric purchasing time to August
      GROUP BY P.PName
)
SELECT TOP 5 PA.PName                            -- only select the top 5 most purchased
FROM PRODUCT_USER_AUG AS PA
WHERE PA.Num_of_users != (SELECT COUNT(*)        -- the number of users purchased is not
                          FROM USERS)            -- the total number of users
ORDER BY PA.Num_of_users DESC;


-- query 8 version 2
-- for products that have never been purchased by some users all the time
-- Find the number of users purchased each product in 2021 Auguest
WITH PRODUCT_USER_AUG AS (
      SELECT P.PName, COUNT(*) AS Num_of_users
      FROM PRODUCTS AS P, PRODUCT_IN_ORDERS AS PO, ORDERS AS O
      WHERE P.PID = PO.PID AND                  -- inner join through OID & PID
            O.OID = PO.OID AND
            O.Date_time BETWEEN '2021-08-01' AND '2021-08-31' -- restric purchasing time to August
      GROUP BY P.PName
),
-- Find the number of users purchased each product in all the time
PROUDCT_USER_ALL AS (
      SELECT P.PName, COUNT(*) AS Num_of_users
      FROM PRODUCTS AS P, PRODUCT_IN_ORDERS AS PO, ORDERS AS O
      WHERE P.PID = PO.PID AND                  -- inner join through OID & PID
            O.OID = PO.OID
      GROUP BY P.PName
),
-- Find products that have nerver been purchased by some users
PRODUCTS_NOT_EVERY_USER_PURCHASED AS (
      SELECT PUA.PName
      FROM PROUDCT_USER_ALL AS PUA
      WHERE PUA.Num_of_users != (SELECT COUNT(*)   -- the number of users purchased is not 
                                 FROM USERS)       -- the total number of users
) 
SELECT TOP 5 PA.PName                              -- only select the top 5 most purchased
FROM PRODUCT_USER_AUG AS PA
WHERE PA.PName IN (SELECT PP.PName                 -- products cannot be purchased by every user
                   FROM PRODUCTS_NOT_EVERY_USER_PURCHASED AS PP)
ORDER BY PA.Num_of_users DESC;


-- query 9
-- Convert order made time into yyyy-mm format
WITH ORDER_TIME_IN_MONTH AS (
      SELECT P.PID, P.PName, convert(varchar(7), O.Date_time, 126) AS Sale_month, PO.OQuantity
      FROM PRODUCTS AS P, ORDERS AS O, PRODUCT_IN_ORDERS AS PO  -- inner join through OPI & PID
      WHERE O.OID = PO.OID AND
            P.PID = PO.PID
),
-- Find the monthly sale quantities for each products
MONTHLY_SALE AS (
      SELECT PName, Sale_month, SUM(OQuantity) AS Monthly_sale  -- calculate monthly sale quantities
      FROM ORDER_TIME_IN_MONTH
      GROUP BY PName, Sale_month
),
-- Find the monthly sale for consecutive 3 months for all products 
THREE_MONTH_SALE AS (
      SELECT PName, Sale_month,        -- record the monthly sale quatities for previous, current and next month
             LAG(Monthly_sale) OVER (ORDER BY PName, Sale_month) as QPrev,
             Monthly_sale AS QCurrent, 
             LEAD(Monthly_sale) OVER (ORDER BY PName, Sale_month) as QNext
      FROM MONTHLY_SALE
)                                                       
SELECT DISTINCT PName
FROM THREE_MONTH_SALE
WHERE QPrev < QCurrent AND            -- increasingly purchased 
      QCurrent < QNext AND
      Sale_month BETWEEN '2021-02' AND '2021-11'  -- because the first and last month cannot
                                                  -- form 3 effective consecutive months  
        