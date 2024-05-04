
---Data Understanding

select * from Pizzas --cols:pizza_id,pizza_type_id,size,price

select * from pizza_types --cols:pizza_type_id,name,category,ingredients

select * from orders --cols:order_id,date,time

select * from order_details --cols:order_details_id,order_id,pizza_id,quantity

---Exploratoy Data Analysis

---retrieve the total number of order placed
select count(order_id) as Total_Orders from orders


----retrieve the total sales  generated from pizza_sales
SELECT Round(SUM(P.price*O.quantity),2) As Total_Sales FROM
order_details O inner join Pizzas P  
on O.pizza_id=P.pizza_id ;

select SUM(P.price*O.quantity)/count(distinct(O.order_id) ) as AVG_over_order
  from 
order_details O inner join Pizzas P  
on O.pizza_id=P.pizza_id ;

---Total_Pizza_Sold 
SELECT SUM(quantity) AS Total_Pizza_Sold 
FROM order_details;


---monthly trend for order
select datename(MONTH,date) as Day ,count(distinct(order_id)) as Count_order from orders
group by datename(MONTH,date) order by Count_order desc



---- identify the highest priced Pizza
select top 1 pt.name as Highest_pizza , round(P.price ,2) as Price
from pizzas P join pizza_types Pt 
on P.pizza_type_id = pt.pizza_type_id
order by P.price desc ;

---identify the most common pizza size ordered
SELECT size,COUNT(order_details_id)  As Order_Counts
FROM order_details O join pizzas P 
ON P.pizza_id=O.pizza_id
GROUP BY(size)
ORDER BY Order_counts DESC;

---List the most common category ordered
select pt.category as Category ,count(order_details_id) as Count_Order 
from order_details o join pizzas p 
on o.pizza_id=p.pizza_id
join pizza_types pt 
on p.pizza_type_id=pt.pizza_type_id 
group by pt.category 
order by Count_Order desc

---List the top 5 most ordered pizza types along with their quantities
select top 5 pt.name as Pizza_name ,sum(o.quantity) as Quantity
from order_details o join pizzas p 
on o.pizza_id=p.pizza_id
join pizza_types pt 
on p.pizza_type_id=pt.pizza_type_id 
group by pt.name 

---Determine the distribution of orders by hour of the day.
select  DATEPART(HOUR , time) as Hours , count(order_id) as count_order
from orders
group by DATEPART(HOUR, time)
order by count_order desc ;
--------------------
SELECT category , COUNT(name) AS count_pizza
FROM pizza_types
GROUP BY category

---Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT avg(quantities) as avg_quantity
FROM (
SELECT date, SUM(od.quantity) as quantities
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
GROUP BY date
) AS daily_quantities;



---Determine the top 3 most ordered pizza types based on revenue.

select top 5(name), sum(price * quantity) as revenue 
from pizza_types pt join pizzas p 
on pt.pizza_type_id = p.pizza_type_id
join  order_details o on p.pizza_id= o.pizza_id
group by name order by revenue desc


---Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pt.category , ROUND(SUM(p.price * o.quantity),2) AS category_revenue,
    ROUND(SUM(p.price * o.quantity) * 100.0 / 
        (SELECT SUM(p.price * o.quantity) 
         FROM order_details o JOIN pizzas p ON o.pizza_id = p.pizza_id), 2) 
		 AS revenue_percentage
FROM 
    order_details o JOIN pizzas p ON o.pizza_id = p.pizza_id
JOIN 
pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY 
    pt.category;


---Analyze the cumulative revenue generated over time.
SELECT 
    date,
    ROUND(SUM(revenue) OVER (ORDER BY date), 2) AS cumulative_revenue
	from(
SELECT  o.date, ROUND(SUM(price*quantity),2) AS revenue 
FROM orders o 
JOIN order_details ot 
   ON o.order_id=ot.order_id
JOIN pizzas 
   ON ot.pizza_id=pizzas.pizza_id 
GROUP BY o.date ) as sales

---Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, name , Revenue,Rank
FROM(
select category,name,Revenue ,
rank() over(partition by category order by Revenue desc) as Rank
From
( select category,name  ,
     ROUND(sum(price*quantity),0) as Revenue
   From
    pizza_types pt join pizzas p 
        ON pt.pizza_type_id = p.pizza_type_id 
   join order_details o 
       ON o.pizza_id=p.pizza_id 
	GROUP BY name ,category ) as a) as b where Rank <=3;