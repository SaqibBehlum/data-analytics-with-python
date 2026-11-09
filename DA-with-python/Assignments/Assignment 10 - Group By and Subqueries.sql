-- ============================================================
--  ASSIGNMENT 10 — Group By & Subqueries
--  Database : BikeStores
--  Topics   : Aggregate functions, GROUP BY, HAVING,
--             subqueries in WHERE (IN / NOT IN / scalar),
--             subqueries in FROM (derived tables),
--             subqueries in SELECT
-- ============================================================


-- ============================================================
--  Question 1 — Aggregate Functions
--  From sales.order_items, write ONE query that returns:
--    • total number of order lines
--    • total units sold (SUM of quantity)
--    • average, minimum and maximum list_price
--  Give every column a meaningful alias.
-- ============================================================

-- Write your query below:
select
    count(*)           as total_order_lines,
    sum(quantity)      as total_units_sold,
    avg(list_price)    as avg_list_price,
    min(list_price)    as min_list_price,
    max(list_price)    as max_list_price
from sales.order_items;



-- ============================================================
--  Question 2 — COUNT(*) vs COUNT(column)
--  a) How many rows are there in sales.customers?
--  b) How many customers have an email on record, and how many
--     have a phone number on record?
--  c) Using the results above, how many customers have NO phone
--     number? Confirm it with a separate query using IS NULL.
--  Add the numbers you get as comments.
-- ============================================================

-- Part a:
select count(*) AS total_customers
from sales.customers;

-- Part b:
select
    COUNT(email) as customers_with_email,
    count(phone) as customers_with_phone
from sales.customers;

-- Part c:

select count(*) as customers_without_phone
from sales.customers
where phone is null;


-- ============================================================
--  Question 3 — GROUP BY
--  a) Find the total units sold (SUM of quantity) for each
--     product_id in sales.order_items, highest first.
--  b) Count the number of customers in each state, highest
--     first.
--  c) Count the number of orders handled by each staff_id and
--     each order_status combination.
-- ============================================================
-- Part a:
select product_id, sum(quantity) as total_units_sold
from sales.order_items
group by product_id
order by total_units_sold desc;

-- Part b:
select state, count(*) as customer_count
from sales.customers
group by state
order by customer_count desc;

-- Part c:
select staff_id, order_status, count(*) as order_count
from sales.orders
group by staff_id, order_status
order by staff_id, order_status;





-- ============================================================
--  Question 4 — GROUP BY with Joins
--  a) Show category_name and the average list_price of its
--     products (rounded to 2 decimals). Join products and
--     categories.
--  b) Show brand_name and the number of products in each brand,
--     sorted by the product count descending.
--  c) For every customer, show customer_id, first_name,
--     last_name, order_count and total_spent.
--     total_spent = SUM(quantity * list_price * (1 - discount))
--     Hint: use COUNT(DISTINCT order_id) so orders are not
--     counted once per item.
-- ============================================================

-- Part a:
select c.category_name,
       round(avg(p.list_price), 2) as avg_list_price
from production.products p
join production.categories c on c.category_id = p.category_id
group by c.category_name
order by avg_list_price desc;

-- Part b:
select b.brand_name,
       count(p.product_id) as product_count
from production.products p
join production.brands b on b.brand_id = p.brand_id
group by b.brand_name
order by product_count desc;

-- Part c:
select c.customer_id,
       c.first_name,
       c.last_name,
       count(distinct o.order_id) as order_count,
       sum(oi.quantity * oi.list_price * (1 - oi.discount)) as total_spent
from sales.customers c
join sales.orders o       on o.customer_id = c.customer_id
join sales.order_items oi on oi.order_id   = o.order_id
group by c.customer_id, c.first_name, c.last_name
order by total_spent desc;





-- ============================================================
--  Question 5 — HAVING
--  a) List the model_year values that have more than 50
--     products, with the product count.
--  b) List the customers who have placed 2 or more orders
--     (customer_id and order_count).
--  c) List the product_ids that have sold more than 100 units
--     in total.
--  d) In a comment, explain why part (a) cannot be written
--     with WHERE alone.
-- ============================================================

-- Part a:
select model_year, count(*) as product_count
from production.products
group by model_year
having  count(*) > 50;

-- Part b:
select customer_id, count(*) as order_count
from sales.orders
group by customer_id
having count(*) >= 2;

-- Part c:
select product_id, sum(quantity) as total_units_sold
from sales.order_items
group by product_id
having (quantity) > 100;

-- Part d:{coment}
-- WHERE filters individual rows BEFORE grouping, so it cannot see
-- aggregate values such as COUNT(*), which only exist after the
-- rows have been grouped. A condition on an aggregate ("more than
-- 50 products per model_year") must go in HAVING, which filters
-- groups AFTER GROUP BY. Aggregates are not allowed in WHERE.





-- ============================================================
--  Question 6 — WHERE + GROUP BY + HAVING Together
--  Using only orders placed in the year 2017, find the stores
--  (store_id) whose total revenue is above 100000.
--  Show store_id and total_revenue, highest first.
--  Hint: WHERE filters rows before grouping, HAVING filters
--  groups after grouping.
-- ============================================================

select o.store_id,
       sum(oi.quantity * oi.list_price * (1 - oi.discount)) as total_revenue
from sales.orders o
join sales.order_items oi on oi.order_id = o.order_id
where year(o.order_date) = 2017                      
group by o.store_id
having sum(oi.quantity * oi.list_price * (1 - oi.discount)) > 100000  
order by total_revenue desc;

-- ============================================================
--  Question 7 — Subquery in WHERE (IN)
--  a) Return all orders placed by customers who live in
--     'New York'. Use a subquery on sales.customers.
--  b) Return the product_id and product_name of all products
--     that belong to the categories 'Electric Bikes' or
--     'Cruisers Bicycles'. Use a subquery on categories.
--  c) Return the customers (first_name, last_name, city) who
--     have placed at least one order. Use IN with a subquery.
-- ============================================================

-- Part a:
select *
from sales.orders
where customer_id IN (select customer_id from sales.customers where city = 'New York');

-- Part b:
select product_id, product_name
from production.products
where category_id in (select category_id
                      from production.categories
                      where category_name in ('Electric Bikes', 'Cruisers Bicycles'));

-- Part c:
select first_name, last_name, city
from sales.customers
where customer_id in (select customer_id from sales.orders);




-- ============================================================
--  Question 8 — Subquery in WHERE (Scalar & NOT IN)
--  a) Return all products priced ABOVE the overall average
--     list_price. Do not hardcode the average.
--  b) Return all products priced BELOW the overall average
--     list_price, and write a second query that counts how
--     many such products there are.
--  c) Return the customers who have NEVER placed an order,
--     using NOT IN.
--  d) Return the products that have never been ordered
--     (not present in sales.order_items).
--  Hint for c and d: filter out NULLs inside the subquery so
--  NOT IN works correctly.
-- ============================================================


select product_id, product_name, list_price
from production.products
where list_price > (select avg(list_price) from production.products);

-- Part b:
select product_id, product_name, list_price
from production.products
where list_price < (select avg(list_price) from production.products);

select count(*) as products_below_average
from production.products
where list_price < (select avg(list_price) from production.products);

-- Part c:
select customer_id, first_name, last_name
from sales.customers
where customer_id not in (select customer_id
                          from sales.orders
                          where customer_id IS NOT NULL);

-- Part d:
select product_id, product_name
from production.products
where product_id not in (select product_id
                         from sales.order_items
                         where product_id IS NOT NULL);




-- ============================================================
--  Question 9 — Subquery in FROM (Derived Table)
--  a) First find the number of orders handled by each staff
--     member. Then, using that result as a derived table,
--     calculate the average, minimum and maximum order count
--     per staff member.
--  b) Using a derived table of total_spent per customer,
--     return the average total_spent across all customers.
--  Remember: a derived table needs an alias.
-- ============================================================

-- Part a:
select avg(order_count) as avg_orders_per_staff,
       min(order_count) as min_orders_per_staff,
       max(order_count) as max_orders_per_staff
from (
    select staff_id, count(*) as order_count
    from sales.orders
    group by staff_id
) as staff_orders;
-- Note: order_count is an INT, so AVG returns an integer in SQL Server.
-- Use AVG(order_count * 1.0) if you want decimals.

-- Part b:
select avg(total_spent) as avg_total_spent
from (
    select  o.customer_id,
           sum(oi.quantity * oi.list_price * (1 - oi.discount)) as total_spent
    from sales.orders o
    join sales.order_items oi on oi.order_id = o.order_id
    group by o.customer_id
) as  customer_totals;





-- ============================================================
--  Question 10 — Subquery in SELECT
--  a) For each product (product_id, product_name, list_price),
--     show the total quantity sold as a column named
--     units_sold, using a correlated subquery on
--     sales.order_items.
--  b) For each order (order_id, order_date), show the number of
--     items in that order as item_count and the highest
--     list_price in that order as max_item_price.
--  c) Show the difference between each product's list_price and
--     the overall average list_price as price_difference.
-- ============================================================



-- Part a:
select p.product_id,
       p.product_name,
       p.list_price,
       (select sum(oi.quantity)
        from sales.order_items oi
        where oi.product_id = p.product_id) as units_sold   -- NULL if never sold
from production.products p;

-- Part b:
select o.order_id,
       o.order_date,
       (select count(*)
        from sales.order_items oi
        where oi.order_id = o.order_id) as item_count,
       (select max(oi.list_price)
        from sales.order_items oi
        where oi.order_id = o.order_id) as max_item_price
from sales.orders o;
-- item_count = number of order lines. For total units use SUM(oi.quantity).

-- Part c:
select product_id,
       product_name,
       list_price,
       list_price - (select avg(list_price) from production.products) as price_difference
from production.products;



-- ============================================================
--  Question 11 — Challenge
--  Find the customers whose total_spent is higher than the
--  average total_spent of all customers.
--  Show customer_id, first_name, last_name and total_spent,
--  highest first.
--  Hint: combine GROUP BY + HAVING with a scalar subquery
--  (or a derived table) that calculates the average.
-- ============================================================

select c.customer_id,
       c.first_name,
       c.last_name,
       sum(oi.quantity * oi.list_price * (1 - oi.discount)) as total_spent
from sales.customers c
join sales.orders o       on o.customer_id = c.customer_id
join sales.order_items oi on oi.order_id   = o.order_id
group by c.customer_id, c.first_name, c.last_name
having sum(oi.quantity * oi.list_price * (1 - oi.discount)) >
       (select avg(total_spent)
        from (
            select o2.customer_id,
                   sum(oi2.quantity * oi2.list_price * (1 - oi2.discount)) as total_spent
            from sales.orders o2
            join sales.order_items oi2 on oi2.order_id = o2.order_id
            group by o2.customer_id
        ) as customer_totals)
order by total_spent desc;









