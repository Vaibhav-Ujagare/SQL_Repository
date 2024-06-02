create database pizza_sales;

use pizza_sales;

create table orders(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id)
);

create table order_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id)
);


-- Basic:
--  Q1. Retrieve the total number of orders placed.

SELECT 
    COUNT(*)
FROM
    orders;
    

-- Q2. Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(order_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    order_details
        JOIN
    pizzas USING (pizza_id);
    
    
-- Q3. Identify the highest-priced pizza.

SELECT 
    pizza_types.name, pizzas.price AS max_price
FROM
    pizza_types
        JOIN
    pizzas USING (pizza_type_id)
ORDER BY max_price DESC
LIMIT 1;


-- Q4.Identify the most common pizza size ordered.

SELECT 
    size, COUNT(quantity) AS order_count
FROM
    order_details
        JOIN
    pizzas USING (pizza_id)
GROUP BY size
ORDER BY order_count DESC
LIMIT 1;
 

-- Q5 List the top 5 most ordered pizza types along with their quantities.

SELECT 
    name, sum(quantity) AS order_quantity
FROM
    pizzas
        JOIN
    order_details USING (pizza_id)
        JOIN
    pizza_types USING (pizza_type_id)
GROUP BY name
ORDER BY order_quantity DESC
LIMIT 5;

-- Q6 Join the necessary tables to find the total quantity of each pizza category ordered.

select category,sum(quantity) as total from orders
join order_details using(order_id)
join pizzas using(pizza_id)
join pizza_types using(pizza_type_id)
group by category
order by total desc;

-- Q7 Determine the distribution of orders by hour of the day

SELECT 
    HOUR(order_time) AS hours, COUNT(order_id) AS total
FROM
    orders
GROUP BY hours
ORDER BY hours DESC;


-- Q8 Join relevant tables to find the category-wise distribution of pizzas.

SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;


-- Q9 Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    round(avg(total_count),0) as avg_pizza_ordered_per_day
FROM
    (SELECT 
        order_date, SUM(quantity) AS total_count
    FROM
        orders
    JOIN order_details USING (order_id)
    GROUP BY order_date) AS order_quantity;


-- Q10 Determine the top 3 most ordered pizza types based on revenue. 

SELECT 
    name, SUM(price*quantity) AS price
FROM
    pizza_types
        JOIN
    pizzas USING (pizza_type_id)
    join order_details using(pizza_id)
GROUP BY name
ORDER BY price DESC
LIMIT 3;

-- Q11 Calculate the percentage contribution of each pizza type to total revenue. 

SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * pizzas.price),
                                2) AS total_revenue
                FROM
                    order_details
                        JOIN
                    pizzas USING (pizza_id)) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas USING (pizza_type_id)
        JOIN
    order_details USING (pizza_id)
GROUP BY pizza_types.category;
    

-- Q12 Analyze the cumulative revenue generated over time.

select order_date,sum(revenue) 
over(order by order_date) as cum_revenue from
(select orders.order_date,sum(order_details.quantity*pizzas.price) as revenue from orders 
join order_details using(order_id)
join pizzas using(pizza_id)
group by orders.order_date) as sales;

-- Q13 Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, revenue from
(select category,name,revenue,
rank() over(partition by category order by revenue desc) as Ranking from(
select category,name,sum(price*quantity) as revenue from pizza_types
join pizzas using(pizza_type_id)
join order_details using(pizza_id)
group by category,name) as a) as b where ranking <= 3;










 
