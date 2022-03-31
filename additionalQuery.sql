-- query 10
-- Count number of complaints each employee handled
WITH COMPLAINTS_EMPLOYEE AS (
    SELECT EID, COUNT(*) AS Num_of_complaints
    FROM COMPLAINTS
    WHERE Status = 'Addressed'
    GROUP BY EID
)
-- select the employee with maximum handled complainta
SELECT EID
FROM COMPLAINTS_EMPLOYEE AS CE
WHERE CE.Num_of_complaints = (SELECT MAX(Num_of_complaints)
                              FROM COMPLAINTS_EMPLOYEE);

-- query 11
-- Count number of un-addressed complaints for each shop
WITH SHOPS_COMPLAINTS AS (
    SELECT CS.SID, COUNT(*) AS Num_of_complaints
    FROM COMPLAINTS AS C, COMPLAINTS_ON_SHOPS AS CS
    WHERE C.CID = CS.CID AND
          C.Status != 'Addresses' 
    GROUP BY CS.SID
)
-- select the shop with maximum complaints
SELECT SID
FROM SHOPS_COMPLAINTS AS SC
WHERE SC.Num_of_complaints = (SELECT MAX(Num_of_complaints)
                              FROM SHOPS_COMPLAINTS);


-- query 12
SELECT P.Category, AVG(PS.SPrice) AS Average_price -- calculate average price
FROM PRODUCTS AS P, PRODUCT_IN_SHOPS AS PS
WHERE P.PID = PS.PID
GROUP BY P.Category
