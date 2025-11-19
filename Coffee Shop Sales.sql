CREATE DATABASE Coffee_Shop;
USE Coffee_Shop;

 SELECT *
 FROM coffee_shop_sales;

DESCRIBE coffee_shop_sales; -- Describes the attributes and their data types. 

-- I. DATA CLEANING

-- Changing(UPDATE in the table) to correct format. i.e., date-month-year
UPDATE coffee_shop_sales
SET transaction_date = STR_TO_DATE(transaction_date, '%d-%m-%Y');

-- Now changing(ALTER the table) the datatype to date.
ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_date DATE;

-- same with the time, updating the format of time in the table.
-- Even though the particular column data is in perfect format, it is better to update to proper format.
UPDATE coffee_shop_sales
SET transaction_time = STR_TO_DATE(transaction_time, '%H:%i:%s'); 

-- Now we ALTER the table by modifying the column datatype
ALTER TABLE coffee_shop_sales
MODIFY COLUMN transaction_time TIME;

-- changing field name, which is not correct
ALTER TABLE coffee_shop_sales
CHANGE COLUMN ï»¿transaction_id transaction_id INT;

DESCRIBE coffee_shop_sales;

-- II. QUERY FOR BUSINESS REQUIREMENT.
-- Based on the problem statement given.

-- A. Total sales analysis
-- 1. calculate the total sales for each respective month.
SELECT MONTH(transaction_date) AS MONTH, CONCAT(ROUND((ROUND(SUM(transaction_qty * unit_price))) / 1000), "K") AS TOTAL_SALES
FROM coffee_shop_sales
GROUP BY MONTH;

-- 2. Determine the month-on-month increase or decrease in sales.
SELECT MONTH(transaction_date) AS MONTH, CONCAT(ROUND(ROUND(SUM(transaction_qty * unit_price))/1000), "K") AS TOTAL_SALES,
		COALESCE(ROUND(
        (SUM(transaction_qty * unit_price) - LAG(SUM(transaction_qty * unit_price), 1)
        OVER(ORDER BY MONTH(transaction_date))) 
        
        / LAG(SUM(transaction_qty * unit_price), 1)
        OVER(ORDER BY MONTH(transaction_date)) * 100 
        ,1), "FIRST_MONTH")
        AS mom_increase_percentage
FROM coffee_Shop_sales
GROUP BY MONTH
ORDER BY MONTH ;

-- 3. Calculate teh difference in sales between teh selected month and the previous month.
SELECT MONTH(transaction_date) AS MONTH, CONCAT(ROUND((ROUND(SUM(transaction_qty * unit_price))) / 1000), "K") AS TOTAL_SALES,
		ROUND(ROUND(SUM(transaction_qty * unit_price))/1000) - LAG(ROUND(ROUND(SUM(transaction_qty * unit_price))/1000))
			OVER(ORDER BY MONTH(transaction_date)) AS DIFFERENCE_BETWEEN_MONTH_SALES
FROM coffee_shop_sales
GROUP BY MONTH;

-- Selected month / current month(CM) - May = 5
-- previous month (PM) - April = 4



-- B. TOTAL ORDER ANALYSIS
-- 1. Calculate the total number of orders for each respective month
SELECT DISTINCT MONTH(transaction_date) AS MONTH, COUNT(transaction_id) OVER(PARTITION BY MONTH(transaction_date)) AS Total_Orders
FROM coffee_shop_sales;

-- 2. Determine the month-on-month increase or decrease in the number of orders.
SELECT MONTH(transaction_date) AS MONTH, COUNT(*) AS TOTAL_ORDERS, 
		ROUND((COUNT(transaction_id) - LAG(COUNT(transaction_id), 1) OVER(ORDER BY MONTH(transaction_date))) 
        
        / LAG(COUNT(transaction_id), 1) OVER(ORDER BY MONTH(transaction_date)) * 100, 1) AS INCREASE_PERCENTAGE
FROM coffee_shop_sales
GROUP BY MONTH;

-- 3. Calculate the difference in the number of orders between the selected month and the previous month.
SELECT MONTH(transaction_date) AS MONTH, COUNT(transaction_id) AS TOTAL_ORDERS, 
		COUNT(transaction_id) - LAG(COUNT(transaction_id), 1) OVER(ORDER BY MONTH(transaction_date))  AS INCREASE_IN_ORDERS
FROM coffee_shop_sales
GROUP BY MONTH;


-- C. TOTAL ORDER ANALYSIS
-- 1. Calculate the total Quantity for each respective month
SELECT MONTH(transaction_date) AS MONTH, SUM(transaction_qty)
FROM coffee_shop_sales
GROUP BY MONTH;

-- 2. Determine the month-on-month increase or decrease in the total quantity.
SELECT MONTH(transaction_date) AS MONTH, SUM(transaction_qty), 
		COALESCE(ROUND((SUM(transaction_qty) - LAG(SUM(transaction_qty)) OVER(ORDER BY MONTH(transaction_date))) 
        /
        LAG(SUM(transaction_qty)) OVER(ORDER BY MONTH(transaction_date)) * 100, 1), "First_Month") AS INCREASE_PERCENTAGE
FROM coffee_shop_sales
GROUP BY MONTH;

-- 3. Calculate the difference in the total quantity between the selected month and the previous month.
SELECT MONTH(transaction_date) AS MONTH, SUM(transaction_qty)
FROM coffee_shop_sales
GROUP BY MONTH;

-- ||
-- ||
-- ||

-- CHARTS REQUIREMENTS -- This can be done in POWER BI
-- A. Calender Heat Map
-- 1. Implement a calender heat map that dynamically adjusts based on the selected month from a slicer.
-- 2. Each day on the calender ill be color-coded to represent sales volume, with darker shades indicating higher sales.
-- 3. Implement tooltips to display detailed metrics(sales, orders, quantity) when hovering over a specific day.

SELECT DATE(transaction_date) AS DATE, CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000, 1), "K") AS Total_Sales,
		SUM(transaction_qty) AS Total_Qty_Sold,
        COUNT(transaction_id) AS Total_Orders
FROM coffee_shop_sales
GROUP BY DATE
ORDER BY Total_Sales;

-- B. SALES ANALYSIS BY WEEKDAYS AND WEEKENDS
-- 1. Segment sales data into weekdays and weekends to analyze performance variations.
-- 2. Provide insights into whether sales patterns differ signficantly between weekdays and weekends.

-- weekends - Sat and Sun
-- weeksdays - Mon to Fri
-- Sun = 1
-- Mon = 2
-- .
-- .
-- Sat = 7

-- Using CASE SATTEMENT to write a query for this statement.
SELECT 
	MONTH(transaction_date) AS MONTH,
	CASE WHEN DAYOFWEEK(transaction_date) IN (1, 7) THEN 'Weekends'
    ELSE 'Weekdays'
    END AS Day_Type,
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000 , 1), "K") AS Total_Sales
FROM coffee_shop_sales
GROUP BY MONTH, Day_Type;


-- C. SALES ANALYSIS BY STORE LOCATION
-- 1. Visualize sales data by different store locations.
-- 2. Include month-over-month (MoM) difference metrics based on the selected month in the slicer.
-- 3. Highlight MoM sales increase or decrease for each store location to identify trends.alter
SELECT store_location, CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000, 1), "K")AS Total_Sales
FROM coffee_shop_sales
GROUP BY store_location
ORDER BY Total_Sales DESC;


SELECT MONTH(transaction_date) AS MONTH, store_location, CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000, 1), "K")AS Total_Sales
FROM coffee_shop_sales
GROUP BY MONTH, store_location
ORDER BY Total_Sales DESC;


-- D. DAILY SALES ANALYSIS WITH AVERAGE LINE
-- 1. Display daiily sales for the sleected month with a line chart.
-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
SELECT MONTH(transaction_date) AS MONTH, AVG(unit_price * transaction_qty) AS AVG_SALES
FROM coffee_shop_sales
GROUP BY MONTH;
-- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
SELECT 
	MONTH, CONCAT(ROUND(AVG(total_sales)/1000, 1), "K") AS AVG_SALES
    FROM (SELECT MONTH(transaction_date) AS MONTH, SUM(unit_price * transaction_qty) AS total_sales
			FROM coffee_shop_sales
            GROUP BY transaction_date) AS SALES
	GROUP BY MONTH;
    
-- 2. Incorporate an average line on the chart to represent the average daily sales.
SELECT DATE(transaction_date) AS DATE, MONTH(transaction_date) AS MONTH, SUM(unit_price * transaction_qty) AS total_sales
FROM coffee_shop_sales
GROUP BY DATE, MONTH;

-- 3. Highlight bars exceeding or falling below the average sales to identify exceptional sales days.
SELECT DAY, MONTH, 
		(CASE 
			WHEN TOTAL_SALES > AVG_SALES THEN 'ABOVE AVERAGE'
            WHEN TOTAL_SALES < AVG_SALES THEN 'BELOW AVERAGE'
            ELSE 'EQUAL TO AVERAGE' 
            END) AS STATUS, TOTAL_SALES
FROM 
	(
    SELECT DAY(transaction_date) AS DAY, MONTH(transaction_date) AS MONTH, SUM(unit_price * transaction_qty) AS TOTAL_SALES, AVG(SUM(unit_price * transaction_qty)) OVER() AS AVG_SALES
    FROM coffee_shop_sales
    WHERE MONTH(transaction_date) = 5 -- filter for may
    GROUP BY DAY, MONTH
    ) AS SALES_REPORT
ORDER BY DAY;

-- E. SALES ANALYSIS BY PRODUCT CATEGORY
-- 1. Analyze sales performance across different product categories.
-- 2. Provide insights into which product categories contribute the most to overall sales.

SELECT 
	MONTH(transaction_date) AS MONTH,
    product_category, 
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000, 1), "K") AS TOTAL_SALES
FROM coffee_shop_sales
GROUP BY MONTH, product_category
-- HAVING MONTH = 5
ORDER BY SUM(unit_price * transaction_qty)/1000 DESC;

-- F. TOP 10 PRODUCTS BY SALES
-- 1. Idenytify an display the top 10 products based on sales volume.
-- 2. Allow users to quickly visualize the best-performing products in terms of sales. 
SELECT 
	MONTH(transaction_date) AS MONTH,
    product_type, 
    CONCAT(ROUND(SUM(unit_price * transaction_qty)/1000, 1), "K") AS TOTAL_SALES
FROM coffee_shop_sales
WHERE product_category = 'coffee'
GROUP BY MONTH, product_type
HAVING MONTH = 5 
ORDER BY SUM(unit_price * transaction_qty)/1000 DESC
LIMIT 10;

-- G. SALES ANALYSIS BY DAYS AND HOURS
-- 1. Utilize a heap map to visualize sales patterns by days and hours.
-- 2. Implement tooltips to display detaied metrics (Sales, Orders, Quantity) when hovering over a specific day-hour.

-- USING HAVING IS FILTERING AFTER AGGREGATING ON ALL THE GROUP WISE DIVIDED DATA, WHICH IS A LONG PROCESS, AND Consumes MORE MEMORY. 
SELECT 
	HOUR(transaction_time) AS HOUR,
    DAYOFWEEK(transaction_date) AS DAY_OF_WEEK,
    MONTH(transaction_date) AS MONTH,
	SUM(unit_price * transaction_qty) AS TOTAL_SALES,
    SUM(transaction_qty) AS TOTAL_QTY_SOLD
FROM coffee_shop_sales
-- WHERE MONTH(transaction_date) = 5 -- May
-- AND DAYOFWEEK(transaction_date) = 2 -- Monday
-- AND HOUR(transaction_time) = 8; -- HOUR NO. 8
GROUP BY HOUR, DAY_OF_WEEK, MONTH
HAVING HOUR = 8 AND DAY_OF_WEEK = 2 AND MONTH = 5;

-- OR
-- USING WHERE BEFORE GROUPING-- IT ONLY AGGREGATES ON THE NEEDED INDIVIDUAL ROWS, AND EFFICIENT IN OUR CASE.
SELECT 
	HOUR(transaction_time) AS HOUR,
    DAYOFWEEK(transaction_date) AS DAY_OF_WEEK,
    MONTH(transaction_date) AS MONTH,
    SUM(unit_price * transaction_qty) AS TOTAL_SALES,
    SUM(transaction_qty) AS TOTAL_QTY_SOLD, 
    COUNT(*) AS TOTAL_ORDERS
FROM coffee_shop_sales 
WHERE MONTH(transaction_date) = 5  -- May
  AND DAYOFWEEK(transaction_date) = 2  -- Monday
  AND HOUR(transaction_time) = 8
GROUP BY HOUR, DAY_OF_WEEK, MONTH;  -- HOUR 8 AM

-- DAY_OF_WEEK -- DAY IN WEEK (1, 7), DAY -- DAY IN MONTH (1, 28 OR 29 OR 30 OR 31), DATE -- FULL DATE PROVIDED.


-- HOURLY SALES LIST
SELECT 
	HOUR(transaction_time) AS HOUR, 
    SUM(unit_price * transaction_qty) AS TOTAL_SALES
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5
GROUP BY HOUR
ORDER BY HOUR;

SELECT 
	CASE 
		WHEN DAYOFWEEK(transaction_date) = 2 THEN 'MONDAY'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'TUESDAY'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'WEDNESDAY'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'THURSDAY'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'FRIDAY'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'SATURDAY'
        ELSE 'SUNDAY'
        END AS DAY_OF_WEEK,
        ROUND(SUM(unit_price * transaction_qty)) AS TOTAL_SALES
FROM coffee_shop_sales
WHERE MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY DAY_OF_WEEK;