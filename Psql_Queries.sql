SELECT * FROM walmart

Drop table walmart;

select count (*) from walmart;

select
distinct payment_method,
count(*)
from walmart
group by payment_method;

select
count (distinct branch)
FROM walmart;

select max(quantity)from walmart;

---Business Problem---
--What are the different payment methods, and how many transactions and
--items were sold with each method?--
select
distinct payment_method,
count(*)as no_of_payments,
sum(quantity)as no_qty_sold
from walmart
group by payment_method;

--Which category received the highest average rating in each branch?--
SELECT *
FROM
( select
	branch,
	category,
	AVG(rating)as avg_rating,
	RANK()OVER(PARTITION BY branch ORDER BY AVG(rating)DESC)as rank
FROM walmart
group by 1,2
)
WHERE RANK = 1

--What is the busiest day of the week for each branch based on transaction
--volume?

Select *
from
	(select 
	branch,
	date,
	TO_CHAR(TO_date(date,'DD/MM/YY'), 'DAY') as day_name,
	COUNT(*)as no_transactions,
	rank()over(partition by branch order by COUNT(*)desc)as rank
	FROM walmart
	group by 1,2
)
where rank=1

-- Q. 4 
-- Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.

SELECT * FROM walmart

select
distinct payment_method,
count(*)as no_of_payments,
sum(quantity)as total_quantity
from walmart
group by payment_method


-- Q.5
-- Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.

select
	city,
	category,
	AVG(rating)as avg_rating,
	MIN(rating)as min_rating,
	MAX(rating)as max_rating
from walmart
group by 1,2


 Q.6
-- Calculate the total profit for each category by considering total_profit as
-- (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.

SELECT
CATEGORY,
SUM(total)as total_revenue,
sum(total * profit_margin)as profit
from walmart
group by 1
order by 1 DESC;

-- Q.7
-- Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.
with cte
as
(SELECT 
	branch,
	payment_method,
	count(*) as toal_trans,
	Rank() over(partition by branch order by count(*)desc)as rank
	from walmart
	group by 1,2
	)
	select *
	from cte
	where rank = 1
	
-- Q.8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices

select 
branch,
case
	when extract (hour from(time::time)) < 12 then 'Morning'
	when extract (hour from(time::time)) between 12 and 17 then 'Afternoon'
	else 'Evening'
	End shift_time,
	count(*)
from walmart
group by 1,2
order by 1, 3 desc


-- #9 Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)

-- rdr == last_rev-cr_rev/ls_rev*100 --formula

SELECT *,
        EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY'))as formated_date
FROM walmart


WITH revenue_2022
AS
(
	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022 -- psql
	-- WHERE YEAR(TO_DATE(date, 'DD/MM/YY')) = 2022 -- mysql
	GROUP BY 1
),

revenue_2023
AS
(

	SELECT 
		branch,
		SUM(total) as revenue
	FROM walmart
	WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)

SELECT 
	ls.branch,
	ls.revenue as last_year_revenue,
	cs.revenue as cr_year_revenue,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue::numeric * 100, 
		2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN
revenue_2023 as cs
ON ls.branch = cs.branch
WHERE 
	ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5





