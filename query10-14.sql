-- query 10 cannot do it because of the design of complaints-on-orders


-- query 11
-- Count number of complaints each employee handled
WITH COMPLAINTS_EMPLOYEE AS (
    SELECT EID, COUNT(*) AS Num_of_complaints
    FROM COMPLAINTS
    WHERE Status = 'Addressed'
    GROUP BY EID
)
SELECT EID
FROM COMPLAINTS_EMPLOYEE AS CE
WHERE CE.Num_of_complaints = (SELECT MAX(Num_of_complaints)
                              FROM COMPLAINTS_EMPLOYEE);


-- query 12, extension to query 4


-- query 13
-- Count number of un-addressed complaints for each shop
WITH SHOPS_COMPLAINTS AS (
    SELECT CS.SID, COUNT(*) AS Num_of_complaints
    FROM COMPLAINTS AS C, COMPLAINTS_ON_SHOPS AS CS
    WHERE C.CID = CS.CID AND
          C.Status != 'Addresses' 
    GROUP BY CS.SID
)
SELECT SID
FROM SHOPS_COMPLAINTS AS SC
WHERE SC.Num_of_complaints = (SELECT MAX(Num_of_complaints)
                              FROM SHOPS_COMPLAINTS);


-- query 14, similar to query 6