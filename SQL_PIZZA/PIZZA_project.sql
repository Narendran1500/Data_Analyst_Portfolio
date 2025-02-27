select * from pizzas;
select * from order_details;
select * from orders;
select * from pizza_types;

-- Retrieve the total number of orders placed.
select count(order_id) from orders;

-- Identify the lowest-priced pizza.
select min(price) from pizzas;

-- Write an SQL query to find the total quantity ordered for each pizza
SELECT 
    pizza_id,
    SUM(quantity) AS total_quantity
FROM 
    order_details od
GROUP BY 
    pizza_id
ORDER BY 
    total_quantity DESC;


-- Calculate the total revenue generated from pizza sales.
select sum(piz.PRICE * od.QUANTITY)as total_revenue from pizzas piz
join order_details od 
on piz.pizza_id = od.pizza_id;

--Write an SQL query to determine the number of orders placed for each pizza size
select p.PIZZA_SIZE ,count(o.order_details_id) from pizzas p
join order_details o
on p.pizza_id = o.pizza_id
group by p.PIZZA_SIZE
order by count(o.order_details_id)desc;


--Write an SQL query to find the total quantity ordered for each pizza, along with the pizza name and category.
SELECT
    pt.name AS pizza_name,
    pt.category AS pizza_category,
    SUM(od.quantity) AS total_quantity
FROM
    pizzas piz
    JOIN order_details od ON piz.pizza_id = od.pizza_id
    JOIN pizza_types pt ON piz.pizza_type_id = pt.pizza_type_id
GROUP BY
    pt.name, pt.category;

-- Write an SQL query to find the rank of each pizza type based on the average price of pizzas
SELECT 
    pt.name AS pizza_name,
    pt.category AS pizza_category,
    round(AVG(p.price),2) AS average_price,
    DENSE_RANK() OVER (ORDER BY AVG(p.price) DESC) AS pizza_type_rank
FROM 
    pizza_types pt
JOIN 
    pizzas p ON pt.pizza_type_id = p.pizza_type_id 
GROUP BY 
    pt.name, pt.category
ORDER BY 
    pizza_type_rank ASC;

-- Write an SQL query to find the top 3 pizzas based on the total quantity ordered.
SELECT 
    pizza_name,
    pizza_category,
    total_quantity,
    pizza_rank
FROM (
    SELECT 
        pt.name AS pizza_name,
        pt.category AS pizza_category,
        SUM(od.quantity) AS total_quantity,
        DENSE_RANK() OVER (ORDER BY SUM(od.quantity) DESC) AS pizza_rank
    FROM 
        pizza_types pt
    JOIN 
        pizzas p ON pt.pizza_type_id = p.pizza_type_id  
    JOIN 
        order_details od ON p.pizza_id = od.pizza_id 
    GROUP BY 
        pt.name, pt.category
    ORDER BY 
        pizza_rank ASC
) ranked_pizzas
WHERE ROWNUM <= 3;  

--Write an SQL query to find the total quantity of each pizza category ordered,
SELECT pt.category AS pizza_category, 
       SUM(od.quantity) AS total_quantity_ordered
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id 
JOIN order_details od ON p.pizza_id = od.pizza_id  
GROUP BY pt.category
ORDER BY total_quantity_ordered DESC;

--Write an SQL query to find the total number of orders placed for each hour of the day.    
select SUBSTR(order_time,1,2) as hour,count(order_id) as total_orders from orders
group by SUBSTR(order_time,1,2)
order by SUBSTR(order_time,1,2) asc;



--Write a query to find the order that contains the most expensive pizza using CTE
WITH Most_Expensive_Pizza AS (
    SELECT od.order_id, MAX(p.price) AS max_price
    FROM order_details od
    JOIN pizzas p ON od.pizza_id = p.pizza_id
    GROUP BY od.order_id
)
SELECT order_id, max_price from 
(
    SELECT order_id, max_price
FROM Most_Expensive_Pizza
ORDER BY max_price DESC
)
where rownum =1;

--Write an SQL query to calculate the percentage contribution of each pizza type to the total revenue
SELECT 
    pt.name AS pizza_type,
    round(SUM(od.quantity * p.price),2) AS total_revenue,
    
    round((SUM(od.quantity * p.price) / 
     (SELECT SUM(od2.quantity * p2.price) 
      FROM order_details od2 
      JOIN pizzas p2 ON od2.pizza_id = p2.pizza_id)
    ) * 100,2) AS percentage_contribution
FROM 
    order_details od
JOIN 
    pizzas p ON od.pizza_id = p.pizza_id
JOIN 
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY 
    pt.name
ORDER BY 
    percentage_contribution DESC;

