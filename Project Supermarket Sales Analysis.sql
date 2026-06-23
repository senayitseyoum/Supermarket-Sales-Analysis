create database supermarket_db;
use supermarket_db;

/*
Project: Supermarket Sales Analysis

Objective:
Analyze supermarket sales transactions to identify:
- Revenue trends
- Customer purchasing behavior
- Product performance
- Branch performance
- Payment preferences

Tools used:
- MySQL Workbench 
- SQL
Dataset:
- 1000 supermarket transactions from January to March 2019.
*/

-- ===============================
-- Data Exploration 
-- ===============================
select *
From sales
limit 10;

select count(*) as Total_Rows
from sales;

describe sales;

alter table sales 
add column sale_date date;
update sales 
set sale_date= str_to_date(date, '%m/%d/%Y');

-- =================================
-- Sales Analysis
-- =================================

-- Total sales
select sum(sales) as Total_Sales
from sales;
-- The total revenue of the company is 322967.43. 

-- Sales by Branch
select branch,
		round(sum(sales),2) as total_sales
from sales
group by branch
order by total_sales desc;
-- Giza branch generates the highest sales. 

-- Sales by city
select city,
round(sum(sales),2) as total_sales
from sales 
group by city
order by total_sales desc;
-- Insights
-- Naypyitaw generated the highest sales revenue of the company. However, sales are relatively balanced across the cities, suggesting that the supermarket has a strong and consistent customer based in all locations. 
-- Recommendation:
-- The company should continue supporting all cities by investigating the factors contributing to Naypyitaw's slightly higher performance.
-- Best practices identified in Naypyitaw could be implemented in Yangon and Mandalay to further increase revenue.  

-- Sales by product line
select product_line,
round(sum(sales),2) as total_sales
from sales
group by product_line
order by total_sales desc;
-- Insight: 
-- Food and beverages are the most purchased products followed by Sports and travel and Electronics products.
-- Health and beauty are the least purchased products. 
-- Recommendation: 
-- The need for food and beverage is higher so the company have to provide more of this products in the future
-- The company should also work on how to improve the sales of health and beauty since it is the least sold product
 
-- ===================================
-- Customer Analysis
-- ===================================

-- Sales by Gender  
select gender, 
round(sum(sales),2) as total_sales
from sales
group by gender
order by total_sales desc;
-- Female customers contributes to the highest (60%) sales of the company. 

-- Average rating by gender
select gender, 
round(avg(rating),2) as avg_rating
from sales
group by gender
order by avg_rating desc;
--  The customer rating for males and females is almost the same. Both genders are similarly satisfied by the products of the company.

-- Customer type analysis
select customer_type,
count(invoice_id) as transactions
from sales
group by customer_type;
-- From 1000 of customers 56.5% are members. 

-- ==================================
-- Product Analysis
-- ==================================

-- Average rating by product line 
select product_line,
round(avg(rating),2) as avg_rating
from sales
group by product_line
order by avg_rating desc;
-- Insight:
-- Food and Beverages receives the highest customers rating indicating a high level of customer satisfaction with these products.
-- Home and lifestyle receives the lowest average rating, suggesting there may be opportunities for improvement in product quality, pricing, or customer experience.
-- Recommendation:
-- The supermarket should maintain the quality and availability of food and beverage products to preserve customer satisfaction.
-- Management should investigate customer feedback for home and lifestyle products and identify areas of improvement.

-- Payment method analysis
select payment,
count(*) as transactions, 
sum(sales) as revenue
from sales 
group by payment
order by revenue desc;
-- Insight:
-- The number of customers who used the three payment methods is similar. 
-- Cash method generates the highest revenue, but the difference is small.
-- Recommendation:
-- The supermarket should continue supporting all payment methods since customers usage is well balanced. 
  
-- ============================
-- Time Analysis
-- ============================

-- Monthly Sales 
select 
date_format(sale_date, '%Y-%m') as month,
round(sum(sales),2) as revenue  
from sales 
group by month
order by month;
-- Insight:
-- The highest sale is made in January and the lowest in February.
-- Recommendation:
-- The reason for the lowest sale in February should be identified and measure should be taken to improve the sales. 

-- Weekday Sales
select
dayname(sale_date) as weekday,
count(*) as transations,
round(sum(sales),2) as total_sales,
round(avg(sales),2) as avg_transaction
from sales
group by weekday
order by total_sales desc;
-- The highest transaction is made on Saturday with an average sales of 342.2 and the lowest on Monday with an average sales of 303.19. 

-- ================================
-- Advanced SQL
-- ================================

-- Subqueries 
 -- Product lines generating above average revenue of the company
select product_line, round(sum(sales),2) as total_sales
from sales
group by product_line
having sum(sales)>
(
select avg(product_sales)
from 
(
select sum(sales) as product_sales
from sales
group by product_line
)x
);
-- All except health and beauty generated a total sales above the average sales of the company.

-- Best performing city
select city, sum(sales) as total_sales
from sales
group by city
having sum(sales)=
(
select max(city_sales)
from (
select sum(sales) as city_sales
from sales
group by city
)x
);
-- Naypyitaw city generated the maximum revenue (110568.86) for the company. 

-- CTEs
-- Top 3 product lines
with ranked_products as 
(
select product_line, 
sum(sales) as total_sales, 
rank() over(
order by sum(sales) desc
) as sales_rank
from sales
group by product_line
)
select *
from ranked_products
where sales_rank<=3;

--  Highest selling products from each city with CTE
with city_product_sales as (
select city, 
product_line, round(sum(sales),2) as total_sales
from sales 
group by city, product_line
)
select *
from (
select city, 
product_line, 
total_sales,
row_number() over (
partition by city
order by total_sales desc) as rn
from city_product_sales
order by total_sales desc
)x 
where rn=1;
-- The highest selling product in Mandalay is Sports and travel with a total revenue of 19988.26.
-- The highest selling product in Naypyitaw is Food and beverages with a toptal revenue of 23766.88.
-- The highest selling product in yangon is Home and lifestyle with a total revenue of 22417.21.

-- Product lines generating above average sales
with product_sales as 
(
select product_line,
round(sum(sales),2) as total_sales
from sales 
group by product_line
order by total_sales desc
)
select *
from product_sales
where total_sales >
(
select avg(total_sales)
from product_sales
);

-- Best branch by month
with monthly_branch_sales as 
(
select month(sale_date) as sales_month, branch,  sum(sales) as total_sales
from sales 
group by sales_month, branch
)
select *
from 
(
select sales_month, branch, total_sales, row_number() over(
partition by sales_month order by total_sales desc) as rn
from monthly_branch_sales
)x
where rn=1;
-- Giza Branch generates the highest revenue in January.
-- Cairo branch generates the highest revenue in february.
-- Alex branch generates the highest revenue in March.

-- ==============================
-- Windows Functions
-- ==============================

-- Rank product lines by sales
select * 
from (
select city, 
round(sum(sales),2) as total_sales, 
rank() over(
order by sum(sales) desc
) as city_rank
from sales 
group by city
) x
where city_rank=1;

select product_line, round(sum(sales),2) as tota_sales,
dense_rank() over (
order by sum(sales) desc
) as sales_rank
from sales
group by product_line;

select *
from(
select city, 
invoice_id, 
sales, 
row_number() over (
partition by city
order by sales desc
) as rn
from sales
)x
where rn=1;

-- Highest selling products from each city 
select *
from (
select city, 
product_line, 
round(sum(sales),2) as total_sales,
row_number() over (
partition by city
order by sum(sales) desc
) as rn
from sales 
group by city, product_line
)x
where rn=1;


/* FINAL BUSINESS FINDINGS
1. Total sales reached 322,967.43.
2. Food & Beverages generated the highest revenue.
3. Female customers contributed the largest share of sales.
4. Cash was the most used payment method, though payment usage was balanced.
5. Saturday generated the highest revenue.
6. Giza branch achieved the highest average customer rating.
7. Health & Beauty generated the lowest sales and may require attention.

BUSINESS RECOMMENDATIONS
1. Maintain strong inventory levels for Food & Beverages.
2. Investigate causes of low Health & Beauty sales.
3. Leverage weekend demand through targeted promotions.
4. Study Giza branch practices and replicate successful strategies.
*/

/*
PROJECT CONCLUSION
This project analyzed 1,000 supermarket transactions
from January to March 2019 using SQL.

The analysis identified key revenue drivers,
customer purchasing patterns, product performance,
branch performance, and sales trends.

SQL techniques demonstrated:
- Aggregations
- Filtering
- Subqueries
- Window Functions
- CTEs
- Date Analysis
- Business Reporting

The findings provide actionable insights that can
support inventory management, marketing strategies,
and operational decision-making.
*/