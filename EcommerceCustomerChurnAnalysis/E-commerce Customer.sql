USE ecomm;
#Data Cleaning: (5 marks)
#Handling Missing Values and Outliers:
#➢ Impute mean for the following columns, and round off to the nearest integer if
#required: WarehouseToHome, HourSpendOnApp, OrderAmountHikeFromlastYear,DaySinceLastOrder.
SELECT WarehouseToHome, HourSpendOnApp, OrderAmountHikeFromlastYear, DaySinceLastOrder from customer_churn;
SELECT WarehouseToHome from customer_churn WHERE WarehouseToHome IS NULL;
SELECT HourSpendOnApp from customer_churn WHERE HourSpendOnApp IS NULL;
SELECT OrderAmountHikeFromlastYear from customer_churn WHERE OrderAmountHikeFromlastYear IS NULL;
SELECT DaySinceLastOrder from customer_churn WHERE DaySinceLastOrder IS NULL;
#SELECT COALESCE(WarehouseToHome ,round(avg(WarehouseToHome)))as Warehouse_To_Home from customer_churn;
#Coalesce() and ifnull() do not calculate mean values.
UPDATE customer_churn SET WarehouseToHome=(
    SELECT Average_val FROM (
SELECT round(avg(WarehouseToHome)) as Average_val FROM customer_churn WHERE WarehouseToHome is NOT NULL) as tmp )
WHERE WarehouseToHome IS NULL ;

UPDATE customer_churn SET HourSpendOnApp=(
    SELECT Avg_val FROM (
SELECT round(avg(HourSpendOnApp)) as Avg_val FROM customer_churn WHERE HourSpendOnApp is NOT NULL) as tmp1 )
WHERE HourSpendOnApp IS NULL ;
#(SELECT round(avg(HourSpendOnApp)) as Average_val FROM customer_churn WHERE HourSpendOnApp is NOT NULL);

UPDATE customer_churn SET OrderAmountHikeFromlastYear=
(select avg_val FROM (
    SELECT ROUND(avg(OrderAmountHikeFromlastYear)) as avg_val FROM customer_churn 
    WHERE OrderAmountHikeFromlastYear  IS NOT NULL) as tmp
) WHERE OrderAmountHikeFromlastYear IS NULL;

UPDATE customer_churn SET DaySinceLastOrder=
(select avg_val from(
    select ROUND(avg(DaySinceLastOrder)) AS avg_val FROM customer_churn 
    WHERE DaySinceLastOrder IS NOT NULL)as tmp
) WHERE DaySinceLastOrder IS NULL;

#Impute mode for the following columns: Tenure, CouponUsed, OrderCount.
SELECT tenure FROM customer_churn;
SELECT tenure FROM customer_churn where Tenure is NULL;
SELECT CouponUsed FROM customer_churn where CouponUsed is NULL;
SELECT OrderCount FROM customer_churn where OrderCount is NULL;

SELECT tenure,COUNT(*) FROM customer_churn 
WHERE Tenure is NOT NULL
 GROUP BY Tenure 
 ORDER BY COUNT(*) DESC
limit 1;

UPDATE customer_churn SET tenure=(
    SELECT mode_val FROM(
      SELECT tenure as mode_val FROM customer_churn 
      WHERE Tenure is NOT NULL
      GROUP BY Tenure 
      ORDER BY COUNT(*) DESC
      limit 1 
    )as tmp
) WHERE tenure is NULL;


SELECT CouponUsed,COUNT(*) FROM customer_churn 
WHERE CouponUsed is NOT NULL
 GROUP BY CouponUsed 
 ORDER BY COUNT(*) DESC
limit 1;
UPDATE customer_churn SET CouponUsed=(
    SELECT mode_val FROM(
        SELECT CouponUsed as mode_val FROM customer_churn
        WHERE CouponUsed is NOT NULL
        GROUP BY CouponUsed
        ORDER BY count(*) DESC
        limit 1
    )as tmp
) where CouponUsed is null;

SELECT OrderCount as mode_val FROM customer_churn
        WHERE OrderCount is NOT NULL
        GROUP BY OrderCount
        ORDER BY COUNT(*) DESC
        LIMIT 1;

UPDATE customer_churn SET OrderCount=(
    SELECT mode_val FROM(
        SELECT OrderCount as mode_val FROM customer_churn
        WHERE OrderCount is NOT NULL
        GROUP BY OrderCount
        ORDER BY COUNT(*) DESC
        LIMIT 1
    )as tmp
)WHERE OrderCount is NULL;


#Handle outliers in the 'WarehouseToHome' column by deleting rows where the values are greater than 100.
DELETE  FROM customer_churn WHERE WarehouseToHome>100;
SELECT count(*) FROM customer_churn WHERE WarehouseToHome>100;

#Dealing with Inconsistencies:
#➢ Replace occurrences of “Phone” in the 'PreferredLoginDevice' column and “Mobile” in the 'PreferedOrderCat' 
#column with “Mobile Phone” to ensure uniformity.
SELECT PreferredLoginDevice FROM customer_churn WHERE PreferredLoginDevice='Phone';
SELECT count(*) FROM customer_churn WHERE PreferredLoginDevice='Phone';
SELECT count(*) FROM customer_churn WHERE PreferedOrderCat='Mobile';
UPDATE customer_churn SET PreferredLoginDevice="Mobile Phone"
 WHERE PreferredLoginDevice='Phone';
UPDATE customer_churn SET PreferedOrderCat="Mobile Phone"
 WHERE PreferedOrderCat='Mobile';
#➢ Standardize payment mode values: Replace "COD" with "Cash on Delivery" and "CC" with "Credit Card" in the PreferredPaymentMode column.
SELECT count(*) FROM customer_churn WHERE PreferredPaymentMode='COD';
SELECT count(*) FROM customer_churn WHERE PreferredPaymentMode='CC';
UPDATE customer_churn SET PreferredPaymentMode="Cash on Delivery"
 WHERE PreferredPaymentMode='COD';
UPDATE customer_churn SET PreferredPaymentMode="Credit Card"
 WHERE PreferredPaymentMode='CC';

 #Data Transformation: (3 marks)
#Column Renaming:
#➢ Rename the column "PreferedOrderCat" to "PreferredOrderCat".
ALTER TABLE customer_churn RENAME COLUMN PreferedOrderCat TO PreferredOrderCat;

#➢ Rename the column "HourSpendOnApp" to "HoursSpentOnApp".
ALTER TABLE customer_churn RENAME COLUMN HourSpendOnApp TO HoursSpentOnApp;
DESCRIBE customer_churn;

#Creating New Columns:
#➢ Create a new column named ‘ComplaintReceived’ with values "Yes" if the corresponding value in the ‘Complain’ is 1, and "No" otherwise.
ALTER TABLE customer_churn ADD COLUMN ComplaintReceived VARCHAR(3);
UPDATE customer_churn SET ComplaintReceived=
CASE 
    WHEN Complain=1 THEN 'Yes'
    ELSE 'No'
END  ;

#➢ Create a new column named 'ChurnStatus'. Set its value to “Churned” if the corresponding value in the 'Churn' column is 1, else assign “Active”.
ALTER TABLE customer_churn ADD COLUMN  ChurnStatus VARCHAR(10);
UPDATE customer_churn SET ChurnStatus=
CASE
  WHEN Churn=1 THEN 'Churned'
  ELSE 'Active'
END;

SELECT Complain,ComplaintReceived,Churn,ChurnStatus FROM customer_churn LIMIT 50;

#Column Dropping:
#➢ Drop the columns "Churn" and "Complain" from the table.
ALTER TABLE customer_churn DROP COLUMN Churn , DROP COLUMN Complain;
DESCRIBE customer_churn;

#Data Exploration and Analysis: (17 marks)
#➢ Retrieve the count of churned and active customers from the dataset.
SELECT ChurnStatus,count(*) as Count_Of_Customers FROM customer_churn
GROUP by ChurnStatus;
#➢ Display the average tenure and total cashback amount of customers who churned.
SELECT ROUND(avg(tenure)) as Avg_Tenure, 
SUM(cashbackAmount) as total_cashback_Amount
from customer_churn
WHERE churnstatus='Churned';
#➢ Determine the percentage of churned customers who complained.
SELECT ROUND(
    COUNT(case 
            when complaintReceived='Yes'
            then 1
             end )*100/ COUNT(*),2
    ) AS ComplaintPercentage 
FROM customer_churn
WHERE churnstatus='Churned';
#➢ Identify the city tier with the highest number of churned customers whose preferred order category is Laptop & Accessory.
SELECT cityTier,count(*) As Customer_Count
FROM customer_churn
WHERE churnstatus='Churned' AND preferredOrderCat='Laptop & Accessory'
GROUP BY citytier
ORDER BY count(*) DESC
LIMIT 1;
#➢ Identify the most preferred payment mode among active customers.
SELECT PreferredPaymentMode, COUNT(*) AS No_Of_Customers
FROM customer_churn
WHERE churnstatus='Active'
GROUP by PreferredPaymentMode
ORDER BY No_Of_Customers DESC
limit 1;
#➢ Calculate the total order amount hike from last year for customers who are single and prefer mobile phones for ordering.
SELECT SUM(OrderAmountHikeFromlastYear) AS Total_OrderAmount_Hike 
FROM customer_churn
WHERE maritalStatus='Single' AND preferredOrderCat='Mobile Phone';
#➢ Find the average number of devices registered among customers who used UPI as their preferred payment mode.
SELECT ROUND(avg(NumberOfDeviceRegistered),2) AS Avg_Registered_Devices 
FROM customer_churn
WHERE PreferredPaymentMode='UPI';
#➢ Determine the city tier with the highest number of customers.
SELECT citytier,Count(*) AS Customer_Count
FROM customer_churn
GROUP BY citytier
ORDER BY Customer_Count DESC
limit 1;
#➢ Identify the gender that utilized the highest number of coupons.
SELECT gender, sum(CouponUsed) as Highest_No_Of_Coupons
FROM customer_churn
GROUP BY gender
ORDER BY Highest_No_Of_Coupons DESC
LIMIT 1;

#➢ List the number of customers and the maximum hours spent on the app in each preferred order category.
SELECT preferredorderCat,count(*) AS No_Of_Customers, MAX(HoursSpentOnApp) AS Maximum_hours_Spent
FROM customer_churn
GROUP BY preferredorderCat;
#➢ Calculate the total order count for customers who prefer using credit cards and have the maximum satisfaction score.
#select max(SatisfactionScore) FROM customer_churn;
SELECT SUM(OrderCount) AS Total_OrderCount 
FROM customer_churn
WHERE preferredpaymentmode='Credit Card'
AND SatisfactionScore=(select max(SatisfactionScore) FROM customer_churn);

#➢ What is the average satisfaction score of customers who have complained?
SELECT ROUND(avg(SatisfactionScore),2) AS Avg_Satisfaction_Score 
FROM customer_churn
WHERE complaintReceived ='Yes';
#➢ List the preferred order category among customers who used more than 5 coupons.
#SELECT preferredorderCat FROM customer_churn WHERE CouponUsed>5 GROUP BY preferredorderCat;
SELECT DISTINCT preferredorderCat FROM customer_churn WHERE CouponUsed>5 ;
#➢ List the top 3 preferred order categories with the highest average cashback amount.
SELECT preferredorderCat,round(avg(CashbackAmount),2) AS Avg_Cashback_Amount
FROM customer_churn
GROUP BY preferredorderCat
ORDER BY Avg_Cashback_Amount DESC
LIMIT 3;

#➢ Find the preferred payment modes of customers whose average tenure is 10 months and have placed more than 500 orders.
SELECT PreferredPaymentMode ,round(avg(tenure)) as AverageTenure, SUM(ordercount) as TotalOrders
FROM customer_churn
GROUP BY PreferredPaymentMode
HAVING AverageTenure=10 AND TotalOrders>500;
#➢ Categorize customers based on their distance from the warehouse to home such as 'Very Close Distance' for distances <=5km,
# 'Close Distance' for <=10km, 'Moderate Distance' for <=15km, and 'Far Distance' for >15km. Then, display the 
#churn status breakdown for each distance category.
SELECT 
CASE WHEN WarehouseToHome <=5 THEN 'Very Close Distance'
     When WarehouseToHome <=10 THEN 'Close Distance'
     WHEN WarehouseToHome <=15 THEN 'Moderate Distance'
     ELSE 'Far Distance'
END AS Distance_category,
churnStatus, Count(*) as No_Of_Customers
FROM customer_churn
GROUP BY Distance_category,churnStatus 
ORDER BY Distance_category;


#➢ List the customer’s order details who are married, live in City Tier-1, and their order counts are more than the 
#average number of orders placed by all customers.
SELECT * FROM customer_churn
 WHERE MaritalStatus ='married'
 AND CityTier=1
 AND OrderCount >(select avg(ordercount)from customer_churn);
#➢ a) Create a ‘customer_returns’ table in the ‘ecomm’ database and insert the following data:
/*ReturnID CustomerID ReturnDate RefundAmount
1001 50022 2023-01-01 2130
1002 50316 2023-01-23 2000
1003 51099 2023-02-14 2290
1004 52321 2023-03-08 2510
1005 52928 2023-03-20 3000
1006 53749 2023-04-17 1740
1007 54206 2023-04-21 3250
1008 54838 2023-04-30 1990*/
CREATE TABLE customer_returns(
    ReturnID INT PRIMARY KEY,
    CustomerID INT,
    ReturnDate DATE,
    RefundAmount DECIMAL(10,2)
);
INSERT INTO customer_returns VALUES(1001,50022,'2023-01-01',2130),
(1002,50316,'2023-01-23',2000),
(1003,51099,'2023-02-14',2290),
(1004,52321,'2023-03-08',2510),
(1005,52928,'2023-03-20',3000),
(1006,53749,'2023-04-17',1740),
(1007,54206,'2023-04-21',3250),
(1008,54838,'2023-04-30',1990);

DESCRIBE customer_returns;
SELECT * FROM customer_returns;

#b) Display the return details along with the customer details of those who have churned and have made complaints.
SELECT Ret.*,churn.* FROM customer_returns Ret 
JOIN customer_churn  churn 
ON ret.customerid=churn.customerid
WHERE churn.ChurnStatus='Churned' AND churn.complaintReceived='Yes';
