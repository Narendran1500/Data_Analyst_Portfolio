select * from orders_data;

-- write a SQL query to list all distict cities where orders have been shipped
SELECT DISTINCT city FROM orders_data;

-- CALCULATE THE TOTAL SELLING PRICE AND PROFITS FOR ALL ORDERS
select Order_Id , CAST(sum(Quantity * Unit_Selling_Price) AS DECIMAL(10,2)) as Total_Selling_Price,
CAST(SUM(Quantity * Unit_Profit) AS DECIMAL(10,2)) AS Total_Profit 
from orders_data
group by Order_Id
order by Total_Profit desc;

-- WRITE A QUERY TO FIND ALL ORDERS FROM THE 'TECHNOLOGY' CATEGORY THAT WERE SHIPPED USING 'SECOND CLASS' SHIP MODE ,ORDERED BY ORDER DATE.
SELECT `ORDER_ID`, `ORDER_DATE`
FROM orders_data
WHERE CATEGORY = 'TECHNOLOGY' AND `SHIP_MODE` = 'SECOND CLASS'
ORDER BY `ORDER_DATE`;

-- WRITE A QUERY TO FIND THE AVERAGE ORDER VALUE
SELECT cast(avg(QUANTITY * UNIT_SELLING_PRICE) AS DECIMAL(10,2)) AS AVg_ord_val
FROM orders_data;

-- FIND THE CITY WITH THE HIGHEST TOTAL QUANTITY OF PRODUCTS ORDERED.
select city,sum(quantity) as total_quantity
from orders_data
group by City
order by total_quantity desc
limit 1;

-- USE A WINDOW FUNCTION TO RANK EACH REGION BY QUANTITY IN DESCENDING ORDER.
select Region, Quantity,
dense_rank() over (partition by region order by Quantity desc) as rnk
from orders_data
order by Region;

-- Write a SQL query to list all orders placed in the first quarter of any year (January to March), including the total cost for these orders.
select * from orders_data where Month between 1 and 3;

select Order_Id, sum(Unit_Selling_Price * Quantity) as total_cost
from orders_data
where Month between 1 and 3 
group by Order_Id
order by total_cost desc;

-- Find top 3 highest selling products in each region
select Region,Product_Id,total_sales,sales_rank
from (
select Region,Product_Id ,sum(Total_Sales) as total_sales,
dense_rank() over (partition by Region order by sum(Total_Sales) desc) as sales_rank
from orders_data
group by Region,Product_Id
) as ranked_sales
where sales_rank<=3
ORDER BY region, sales_rank;

-- Find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
with cte as
(
select year(Order_Date) as order_year, month(Order_Date) as order_month,sum(Total_Sales) as Total_sales
from orders_data
group by year(Order_Date),month(Order_Date)
)
select order_month,
round(sum(case when order_year = 2022 then Total_sales else 0 end),2) as sales_2022,
round(sum(case when order_year = 2023 then Total_sales else 0 end),2) as sales_2023
from cte 
group by order_month
order by order_month;

-- Find the Month with the Highest Sales for Each Category
with monthly_sales as
(
select Category, month(Order_Date) as order_month , year(Order_Date) as order_year, sum(Total_Sales) as total_sales,
dense_rank() over (partition by Category order by sum(Total_Sales) desc) as sales_rank
from orders_data
group by Category, month(Order_Date) , year(Order_Date)
)
select Category,order_month,order_year,total_sales
from monthly_sales 
where sales_rank =1 
order by Category,order_month,order_year