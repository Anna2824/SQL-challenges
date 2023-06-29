--Case Study #1 - Danny's Diner Questions and Answers

-- The main idea of this project is to help Danny find answers to a few simple questions like his customers' visiting patterns,
-- how much money they have spent and also their favourite item on the menu.

--First let's visualize all the three tables

SELECT * FROM members;

SELECT * FROM menu;

SELECT * FROM sales;

--We have so far used Inner joins, Group by, order by, sum, distinct, as, count, min, partition by, dense_rank() functions and CTEs.

--1. What is the total amount each customer spent at the restaurant?

SELECT sal.customer_id, sum(men.price) as Total_amount
FROM sales sal
JOIN menu men ON sal.product_id = men.product_id
GROUP BY sal.customer_id;

--We take a look at the total amount spent by each customer at the restaurant by adding the overall amount spent at the restaurant and group them by each customer.
--We perform an inner join on the sales and menu table to get the required details.

--2. How many days has each customer visited the restaurant?

SELECT customer_id, COUNT(DISTINCT(order_date)) as number_of_days
FROM sales
GROUP BY customer_id;

--This is a simple code which looks at the number of days each customer has visited the restaurant so far.
--We take distinct count of the order dates and then group them by customer id to answer this question.


--3. What was the first item from the menu purchased by each customer?

SELECT  sal.customer_id, MIN(sal.order_date) as first_order_date, min(men.product_name) as purchased_item
FROM sales sal
JOIN menu men ON sal.product_id = men.product_id
GROUP BY sal.customer_id;

--In this code snippet we look at the first item purchased by each customer looking at their first order date and also at the first item purchased on that day by
--using the min command to find the first order date as well as the first item. We get the customer_id and order_date from sales table and
--the product name from the menu table. The end result is displayed by using inner join on both the tables.


--4. What is the most purchased item on the menu and how many times was it purchased by all customers?

select men.product_name, count(sal.product_id) as most_purchased_item
from sales sal
join menu men on sal.product_id = men.product_id
group by men.product_name
order by count(sal.product_id) desc;

--This code displays the most purchased item on the menu based on the count of the product which is decided by counting the product_id which is in the sales table.
--We get the name of the product from the menu table and the end result is obtained by performing inner join on the sales and menu table to display the 
--most purchased item and how many times it was purchased.


--5. Which item was the most popular for each customer?

with Rank as 
(
select sal.customer_id, men.product_name, count(sal.product_id) as order_count,
dense_rank() over(partition by sal.customer_id 
order by count(sal.customer_id) desc) as rank
from sales sal
join menu men on sal.product_id = men.product_id
group by sal.customer_id, men.product_name
)
select customer_id, product_name, order_count
from Rank
where rank = 1


--In this code we look at the inner loop first. The inner loop displays the number of times a particular item was ordered by a customer and higher the number, higher is the rank.
--The outer loop displays the most popular product for a particular customer based on the rank given to the order count.
--We use CTEs to have a common table from which it becomes easier to extract required information.


--6. Which item was purchased first by the customer after they became a member?

select * from members;
select * from sales;
select * from menu;

with Rank as
(select sal.customer_id, men.product_name, dense_rank() over(partition by sal.customer_id order by sal.order_date) as rank
from sales sal
join menu men on sal.product_id= men.product_id
join members mem
on mem.Customer_id = sal.customer_id
where sal.order_date >= mem.join_date 
)select customer_id, product_name
from Rank
where Rank = 1

--The code works by displaying customer_id, product_name and assigning a rank to the products purchased based on the order date just after they became customers.
--Rank is 1 when the order_date is right after the date they became members. Based on the value of the rank we then filter out the products that was just purchased the date after they became members by giving the filter value as being equal to 1.
--We use CTEs to have a common table from which it becomes easier to extract required information.


--7. Which item was purchased just before the customer became a member?

with Rank as
(select sal.customer_id, men.product_name, sal.order_date, dense_rank() over(partition by sal.customer_id order by sal.order_date desc) as rank
from sales sal
join menu men on sal.product_id= men.product_id
join members mem
on mem.Customer_id = sal.customer_id
where sal.order_date < mem.join_date 
)select customer_id, product_name, order_date
from Rank
where Rank = 1

--The code works by first starting from the inner loop. In the inner loop customer_id, product_name,order_date and rank is displayed. 
--The rank is decided based on order date just before the customers became members and date just before they became members is assigned the rank 1 and so on.
--In the outer loop based on the rank being equal to 1 we get the item that was purchased by the customer on the date just before they became a member.
--We use CTEs to have a common table from which it becomes easier to extract required information.


--8. What is the total items and amount spent for each member before they became a member?

select * from members;
select * from sales;
select * from menu;



select sal.customer_id, count(sal.product_id) as total_items, sum(men.price) as total_amount
from sales sal
join members mem on sal.customer_id = mem.customer_id
join menu men on sal.product_id = men.product_id
where sal.order_date < mem.join_date
group by sal.customer_id;

-- This code looks at the total number of items purchased by each member of the restaurant as well as the total amount spent 
--by each member in the restaurant before becoming a member. This is done by combining all the three tables using inner joins based on
--certain conditions. Members table and sales table is combined based on the customer id. The menu and sales table is combined based on 
--the product_id and based on the order_date being before member joining date we filter out the total count of items and look at the total
-- amount spent by each customer and group them based on the customers who are members.


--9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select * from members;
select * from sales;
select * from menu;

 select sal.customer_id, 
       sum(case
           when men.product_id = 1 THEN (men.price* 20)
           ELSE (men.price * 10)
       END) AS total_points
from sales sal
join menu men on sal.product_id = men.product_id
group by sal.customer_id


--This code snippet looks to generate points for the customer based on the items purchased. 
--If the item purchased by the customer is sushi then for each dollar spent they earn 20 ponts each 
--else they earn 10 points each for each dollar spent. We use case statement to bring about a conditional arrangement wherein if the 
--product is sushi then the menu proce is multiplied by 20 points else with 10 for the other products. We then sum the total points and 
--group them based on the customer id.


--10.In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
--not just sushi - how many points do customer A and B have at the end of January?



with dates as 
(
   select *, 
      dateadd(day, 6, join_date) as valid_date, 
      eomonth('2021-01-31') as last_date
   from members 
)
Select sal.Customer_id, 
       sum(
	   case 
		When men.product_id = 1 then men.price*20
		When sal.order_date between D.join_date and D.valid_date Then men.price*20
		Else men.price*10
	  end 
	  ) as Points
From Dates D
join Sales sal
On D.customer_id = sal.customer_id
Join menu men
On men.product_id = sal.product_id
Where sal.order_date < d.last_date
Group by sal.customer_id


--In this code snippet, we first find the week for which the offer of 2x points for any item ordered by the member works.
--We then select the customer based on the dates table and apply the menu price accordingly by joining all the three tables
--i.e. dates, sales and menu table. Then based on the last date i.e. end of January, points are calculated for the 
--customers A and B who are members.