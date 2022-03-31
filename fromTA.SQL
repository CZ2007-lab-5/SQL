-- Find the last date in all orders and the start date of last 30 days
WITH ORDER_DATE AS (
      SELECT MAX(Date_time) AS Max_date, DATEADD(day, -30, MAX(Date_time)) AS Min_date
      FROM ORDERS
),
-- Find users who bought more than 2 items per shop in last 30 days
USER_SHOP AS (
    SELECT O.UID, PO.SID
    FROM ORDERS AS O, PRODUCT_IN_ORDERS AS PO
    WHERE O.OID = PO.OID AND
            O.Date_time <= (SELECT Max_date
                                FROM ORDER_DATE ) and
            O.Date_time >= (SELECT Min_date
                                FROM ORDER_DATE)
    GROUP BY O.UID, PO.SID
    HAVING COUNT(*) > 2    -- more than 2 items per shop per user
), 
-- Find frequent shoppers 
FREQUENT_USER AS (
    SELECT UID
    FROM USER_SHOP
    GROUP BY UID
    HAVING COUNT(*) >= 5    -- more than 5 shops
)
-- Find top 3 frequent shoppers in terms of the total cost of the items they have purchased
SELECT TOP 3 FU.UID, SUM(PO.OPrice*PO.OQuantity) AS Cost
FROM FREQUENT_USER AS FU, ORDERS AS O, PRODUCT_IN_ORDERS AS PO
WHERE FU.UID = O.UID AND
        PO.OID = O.OID AND
        O.Date_time <= (SELECT Max_date         -- calculate cost only on orders within last 30 days
                            FROM ORDER_DATE ) and
        O.Date_time >= (SELECT Min_date
                            FROM ORDER_DATE)
GROUP BY FU.UID
ORDER BY Cost DESC
