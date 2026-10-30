-- ============================================================
--  ASSIGNMENT 09 — Joins & Group By
--  Database : BikeStores
--  Topics   : INNER / LEFT / RIGHT / FULL OUTER JOIN,
--             multi-table joins, aggregate functions,
--             GROUP BY, HAVING
-- ============================================================


-- ============================================================
--  Question 1 — INNER JOIN
--  Return the product_name, brand_name, and list_price of all
--  products by joining production.products with
--  production.brands.
--  Sort the results by brand_name ascending, then list_price
--  descending.
-- ============================================================

-- Write your query below:

select
    p.product_name,
    b.brand_name,
    p.list_price
from production.products as p
inner join production.brands as b
    on p.brand_id = b.brand_id
order by 
    b.brand_name asc,
    p.list_price desc;


-- ============================================================
--  Question 2 — Joining Three Tables
--  Return the product_name, brand_name, category_name, and
--  model_year of every product by joining products, brands and
--  categories.
--  Only include products with a list_price above 1000.
-- ============================================================

-- Write your query below:

select
    p.product_name,
    b.brand_name,
    c.category_name,
    p.model_year
from production.products as p
inner join production.brands as b
    on p.brand_id = b.brand_id
inner join production.categories as c
    on p.category_id = c.category_id
where p.list_price > 1000;


-- ============================================================
--  Question 3 — LEFT JOIN
--  a) List every customer (first_name, last_name, city) along
--     with the order_id and order_date of their orders.
--     Customers who never placed an order must still appear.
--  b) Modify the query to return ONLY the customers who have
--     never placed an order.
--     Hint: filter on a NULL value from the right-hand table.
-- ============================================================

-- Part a:
select
    c.first_name,
    c.last_name,
    c.city,
    o.order_id,
    o.order_date
from sales.customers as c
left join sales.orders as o
    on c.customer_id = o.customer_id
order by 
    c.last_name,
    c.first_name;

-- Part b:
select
    c.first_name,
    c.last_name,
    c.city
from sales.customers as c
left join sales.orders as o
    on c.customer_id = o.customer_id
where o.order_id is null;


-- ============================================================
--  Question 4 — RIGHT JOIN & FULL OUTER JOIN
--  a) Using a RIGHT JOIN, list every store (store_name) with
--     the staff members (first_name, last_name) working there.
--     Join sales.staffs and sales.stores.
--  b) Using a FULL OUTER JOIN between production.products and
--     production.stocks, find the products that have no stock
--     record at all. Return product_name and quantity.
-- ============================================================

-- Part a:
select
    s.store_name,
    st.first_name,
    st.last_name
from sales.staffs as st
right join sales.stores as s
    on st.store_id = s.store_id
order by
    s.store_name,
    st.last_name,
    st.first_name;

-- Part b:
select
    p.product_name,
    stk.quantity
from production.products as p
full outer join production.stocks as stk
    on p.product_id = stk.product_id
where stk.product_id is null;




-- ============================================================
--  Question 5 — Multi-Table Join (Order Details)
--  Build an order-detail report with the following columns:
--    order_id, order_date, customer full name
--    (first_name + last_name), product_name, quantity,
--    and line_total = quantity * order_items.list_price
--                     * (1 - discount)
--  Join sales.orders, sales.customers, sales.order_items and
--  production.products.
--  Sort by order_id, then product_name.
-- ============================================================

-- Write your query below:

select
    o.order_id,
    o.order_date,
    concat(c.first_name, ' ', c.last_name) as customer_full_name,
    p.product_name,
    oi.quantity,
    cast(
        oi.quantity * oi.list_price * (1 - oi.discount)
        as decimal (12, 2)
    ) as line_total
from sales.orders as o
inner join sales.customers as c
    on o.customer_id = c.customer_id
inner join sales.order_items as oi
    on o.order_id = oi.order_id
inner join production.products as p
    on oi.product_id = p.product_id
order by 
    o.order_id,
    p.product_name;


-- ============================================================
--  Question 6 — Aggregate Functions
--  From production.products, write a single query that returns:
--    • total number of products
--    • lowest, highest and average list_price
--      (round the average to 2 decimals)
--  Give every column a meaningful alias.
-- ============================================================

-- Write your query below:
select
    count(*) as total_products,
    min(list_price) as lowest_list_price,
    max(list_price) as highest_list_price,
    cast(round(avg(list_price), 2) as decimal(12, 2))
        as average_list_price
from production.products;



-- ============================================================
--  Question 7 — GROUP BY
--  a) Count the number of products in each category. Show
--     category_name and product_count (join with categories),
--     sorted by product_count descending.
--  b) For each brand_name and model_year combination, find the
--     average list_price. Sort by brand_name, then model_year.
-- ============================================================

-- Part a:
select
    c.category_name,
    count (p.product_id) as product_count
from production.categories as c
left join production.products as p
    on c.category_id = p.category_id
group by c.category_id, c.category_name
order by product_count desc;

-- Part b:
select
    b.brand_name,
    p.model_year,
    cast(round(avg(p.list_price), 2) as decimal(12, 2))
        as average_list_price
from production.products as p
inner join production.brands as b
    on p.brand_id = b.brand_id
group by
    b.brand_id,
    b.brand_name,
    p.model_year
order by
    b.brand_name asc,
    p.model_year asc;



-- ============================================================
--  Question 8 — GROUP BY with Joins
--  a) Find the total number of orders placed by each customer.
--     Show customer_id, full name and total_orders, sorted by
--     total_orders descending.
--  b) Find the total revenue per store.
--     revenue = SUM(quantity * list_price * (1 - discount))
--     Show store_name and total_revenue, highest first.
--     Join orders, order_items and stores.
-- ============================================================

-- Part a:
select
    c.customer_id,
    concat (c.first_name, ' ', c.last_name) as customer_full_name,
    count (o.order_id) as total_orders
from sales.customers as c
left join sales.orders as o
    on c.customer_id = o.customer_id
group by
    c.customer_id,
    c.first_name,
    c.last_name
order by
    total_orders desc,
    c.customer_id asc;

-- Part b:
select
    s.store_name,
    cast(
        sum(oi.quantity * oi.list_price * (1 - oi.discount))
        as decimal(14, 2)
    ) as total_revenue
from sales.stores as s
inner join sales.orders as o
    on s.store_id = o.store_id
inner join sales.order_items as oi
    on o.order_id = oi.order_id
group by
    s.store_id,
    s.store_name
order by total_revenue desc;



-- ============================================================
--  Question 9 — HAVING
--  a) List the brands (brand_name) that have more than 20
--     products.
--  b) List the customers (full name) who have placed 3 or more
--     orders.
--  c) Explain in a comment: what is the difference between
--     WHERE and HAVING?
-- ============================================================

-- Part a:
select
    b.brand_name,
    count(p.product_id) as product_count
from production.brands as b
inner join production.products as p
    on b.brand_id = p.brand_id
group by
    b.brand_id,
    b.brand_name
having count(p.product_id) > 20;

-- Part b:
select
    concat(c.first_name, ' ', c.last_name) as customer_full_name,
    count(o.order_id) as total_orders
from sales.customers as c
inner join  sales.orders as o
    on c.customer_id = o.customer_id
group by
    c.customer_id,
    c.first_name,
    c.last_name
having count (o.order_id) >= 3
order by total_orders desc;

-- Part c (answer as a comment):

-- WHERE: Ye GROUP BY se pehle records ko filter karta hai.
--Matlab jo records hamari condition par poore nahi utarte, unko hata deta hai.
--
-- HAVING: Ye GROUP BY ke baad groups ko filter karta hai. Jab hum COUNT,
--SUM ya AVG use karte hain, to unke result par condition lagane ke liye HAVING use hota hai.




-- ============================================================
--  Question 10 — Combined Challenge
--  Find the top 5 best-selling products by total quantity sold.
--  Show product_name, category_name, total_quantity_sold and
--  total_revenue.
--  Only count orders that are completed (order_status = 4).
--  Hint: join order_items, orders, products and categories,
--  then use WHERE, GROUP BY, ORDER BY and TOP.
-- ============================================================

-- Write your query below:
select top 5
    p.product_name,
    c.category_name,
    sum(oi.quantity) as total_quantity_sold,cast(
        sum(oi.quantity * oi.list_price * (1 - oi.discount))
        as decimal (14, 2)
    ) as total_revenue
from sales.order_items as oi
inner join sales.orders as o
    on oi.order_id = o.order_id
inner join production.products as p
    on oi.product_id = p.product_id
inner join production.categories as c
    on p.category_id = c.category_id
where o.order_status = 4
group by
    p.product_id,
    p.product_name,
    c.category_id,
    c.category_name
order by
    total_quantity_sold desc,
    p.product_name asc;