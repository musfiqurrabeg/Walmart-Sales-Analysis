SELECT * FROM walmart;

DROP TABLE walmart;

-- 
SELECT COUNT(*) FROM walmart;

SELECT DISTINCT payment_method FROM walmart;

SELECT 
	payment_method
	FROM walmart
	GROUP BY payment_method;
	

SELECT COUNT(DISTINCT branch) FROM walmart;

-- Walmart Business Problems
-- Q-1. What are the different payment methods, and how many transactions and items were sold with each method?

SELECT 
	payment_method, 
	COUNT(*) AS no_payments,
	SUM(quantity) AS no_qty_sold
FROM walmart GROUP BY payment_method;

--Q-2. Which category received the highest average rating in each branch?

SELECT 
	branch,
	category,
	AVG(rating) AS avg_rating,
	RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
FROM walmart 
GROUP BY 1, 2
ORDER BY 1, 3 DESC;

SELECT *
FROM 
(		SELECT 
		branch,
		category,
		AVG(rating) AS avg_rating,
		RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
	FROM walmart 
	GROUP BY 1, 2
	ORDER BY 1, 3 
) 
WHERE rank=1;

--Q-3. What is the busiest day of the week for each branch based on transaction volume?

SELECT *
FROM (
	SELECT 
		branch,
		TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') AS day_name,
		COUNT(*) AS no_transactions,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS RANK
	FROM walmart
	GROUP BY 1, 2
)
WHERE rank=1;
-- ORDER BY 1, 3 DESC;


-- Q-4. How many items were sold through each payment method?

SELECT 
	payment_method,
	SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;


-- Q-5. What are the average, minimum, and maximum ratings for each category in each city?

SELECT 
	city,
	category,
	MAX(rating) AS max_rating,
	AVG(rating) AS avg_rating,
	MIN(rating) AS min_rating
FROM walmart
GROUP BY 1, 2;

-- Q-6. What is the total profit for each category, ranked from highest to lowest?

SELECT 
	category,
	SUM(total) AS total_revenue,
	SUM(total * profit_margin) AS total_profit
FROM walmart
GROUP BY 1;


--Q-7. What is the most frequently used payment method in each branch?

WITH cte
AS
(
	SELECT
		branch,
		payment_method AS pay_method,
		COUNT(*) AS total_trans,
		RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS RANK
	FROM walmart
	GROUP BY 1, 2
)
SELECT *
FROM cte
WHERE RANK=1;


--Q-8. How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?

SELECT
	branch,
	CASE 
		WHEN EXTRACT(HOUR FROM(time::time)) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM(time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END day_time,
	COUNT(*)
FROM walmart
GROUP BY 1, 2
ORDER BY 1, 3 DESC;


-- Q-9. Which branches experienced the largest decrease in revenue compared to the previous year?
-- rdr = last_year_rev - current_year_rev / last_year_rev 

SELECT
	*,
	EXTRACT (YEAR FROM TO_DATE(date, 'DD/MM/YY')) AS formated_date
FROM walmart;

-- 2022
WITH revenue_2022
AS
(
	SELECT 
		branch,
		SUM(total) AS revenue
	FROM walmart
	WHERE EXTRACT (YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
	GROUP BY 1
),
-- 2023
revenue_2023
AS
(
	SELECT 
		branch,
		SUM(total) AS revenue
	FROM walmart
	WHERE EXTRACT (YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
	GROUP BY 1
)
SELECT
	ls.branch,
	ls.revenue as last_year_rev,
	cs.revenue as current_year_rev,
	ROUND(
		(ls.revenue - cs.revenue)::numeric/
		ls.revenue::numeric * 100, 
		2) as rev_dec_ratio
FROM revenue_2022 as ls
JOIN revenue_2023 as cs
ON ls.branch = cs.branch
WHERE ls.revenue > cs.revenue
ORDER BY 4 DESC
LIMIT 5;





