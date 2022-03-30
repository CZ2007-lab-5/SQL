-- query 4
-- Find the average latency for each employee
WITH COMPLAINT_LATENCY AS (
      SELECT EID, AVG(datediff(second, Handled_date_time, Addressed_date_time)) as Latency   -- not sure about the latency
      FROM COMPLAINTS
      WHERE Status = 'Addressed'
      GROUP BY EID)
SELECT CL.EID
FROM COMPLAINT_LATENCY AS CL
WHERE CL.Latency = (SELECT MIN(CL.Latency)
                    FROM COMPLAINT_LATENCY AS CL)


-- query 5
SELECT P.PName, COUNT(*) AS Num_of_shops
FROM PRODUCTS AS P, PRODUCT_IN_SHOPS AS PS
WHERE P.PID = PS.PID AND
      P.Maker = 'Samsung'
GROUP BY P.PName;


-- query 6
-- Find the revenue in August 2021 for each shop
WITH SHOP_REVENUE AS (
      SELECT PO.SID, SUM(PO.OPrice * PO.OQuantity) AS Total_revenue
      FROM PRODUCT_IN_ORDERS AS PO, ORDERS AS O
      WHERE PO.OID = O.OID AND 
            O.Date_time BETWEEN '2021-08-01' AND '2021-08-31'
      GROUP BY PO.SID
)
SELECT SID
FROM SHOP_REVENUE AS SR
WHERE SR.Total_revenue = (SELECT MAX(Total_revenue)
                          FROM SHOP_REVENUE);


-- query 7
-- Find the user that made the most amount of complaints
WITH COMPLAINT_COUNT AS (
      SELECT UID
      FROM COMPLAINTS
      GROUP BY UID
      HAVING COUNT(*) >= ALL (SELECT COUNT(*)
                              FROM COMPLAINTS
                              GROUP BY UID)),
-- Find all the products the user purchased before
USER_PRODUCT AS (
      SELECT O.UID, PO.PID, PO.Oprice
      FROM PRODUCT_IN_ORDERS AS PO, ORDERS AS O, COMPLAINT_COUNT AS CC
      WHERE PO.OID = O.OID AND
            O.UID = CC.UID)
SELECT UP1.UID, UP1.PID
FROM USER_PRODUCT AS UP1
WHERE UP1.OPrice >= ALL (SELECT OPrice
                         FROM USER_PRODUCT AS UP2
                         WHERE UP1.UID = UP2.UID);


-- query 8
-- Find the number of users who purchased each product before in 2021 Auguest
WITH PRODUCT_USER AS (
      SELECT P.PName, COUNT(*) AS Num_of_users
      FROM PRODUCTS AS P, PRODUCT_IN_ORDERS AS PO, ORDERS AS O
      WHERE P.PID = PO.PID AND
            O.OID = PO.OID AND
            O.Date_time BETWEEN '2021-08-01' AND '2021-08-31'
      GROUP BY P.PName
)
SELECT TOP 5 PName
FROM PRODUCT_USER AS PU
WHERE PU.Num_of_users != (SELECT COUNT(*)
                          FROM USERS)
ORDER BY PU.Num_of_users DESC;


-- query 9
-- Convert order made time into yyyy-mm format
WITH ORDER_TIME_IN_MONTH AS (
      SELECT P.PID, P.PName, convert(varchar(7), O.Date_time, 126) AS Sale_month, PO.OQuantity
      FROM PRODUCTS AS P, ORDERS AS O, PRODUCT_IN_ORDERS AS PO
      WHERE O.OID = PO.OID AND
            P.PID = PO.PID
),
-- Find the monthly sale quantities for each products
MONTHLY_SALE AS (
      SELECT PName, Sale_month, SUM(OQuantity) AS Monthly_sale
      FROM ORDER_TIME_IN_MONTH
      GROUP BY PName, Sale_month
),
-- Find the monthly sale for consecutive 3 months for all products 
THREE_MONTH_SALE AS (
      SELECT PName, Sale_month,
             LAG(Monthly_sale) OVER (ORDER BY PName, Sale_month) as QPrev,
             Monthly_sale AS QCurrent, 
             LEAD(Monthly_sale) OVER (ORDER BY PName, Sale_month) as QNext
      FROM MONTHLY_SALE
)
SELECT DISTINCT PName
FROM THREE_MONTH_SALE
WHERE QPrev < QCurrent AND
      QCurrent < QNext AND
      Sale_month BETWEEN '2021-02' AND '2021-11'  -- since the first and last month cannot form 3 effective consecutive months  