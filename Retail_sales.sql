-- Retail sales analysis
SELECT * FROM RETAIL_SALES;

-- Data analysis

SELECT COUNT(*) FROM RETAIL_SALES;

-- Find the different payment methods?

SELECT
	PAYMENT_METHOD,
	COUNT(INVOICE_ID) AS COUNT
FROM RETAIL_SALES
GROUP BY PAYMENT_METHOD
ORDER BY COUNT DESC;

-- Find total number of branches for the retail store?

SELECT 
	COUNT(DISTINCT BRANCH)
FROM RETAIL_SALES;


-- Business problem
--Q.1 Find different payment method and number of transactions, number of quantity sold?

SELECT
	DISTINCT PAYMENT_METHOD,
	COUNT(INVOICE_ID) AS TOTAL_TRANSACTION,
	SUM(QUANTITY) AS QUANTITY_SOLD
FROM RETAIL_SALES
GROUP BY PAYMENT_METHOD;


-- Identify the highest-rated category in each branch, displaying the branch, category?

WITH HIGHEST_RATED AS(
	SELECT
		BRANCH,
		CATEGORY,
		MAX(RATING) AS MAX_RATING,
		RANK() OVER(PARTITION BY BRANCH ORDER BY MAX(RATING) DESC) AS RANKING
	FROM RETAIL_SALES
	GROUP BY BRANCH, CATEGORY
)
SELECT 
	BRANCH,
	CATEGORY,
	MAX_RATING
FROM HIGHEST_RATED 
WHERE RANKING <= 1;


-- Q.3 Identify the busiest day for each branch based on the number of transactions

SELECT *
FROM
	(
		SELECT
		BRANCH,
		TO_CHAR(TO_DATE(DATE, 'DD-MM-YY'),'DAY') AS DAY,
		COUNT(*) AS NO_TRANSACTIONS,
		RANK() OVER(PARTITION BY BRANCH ORDER BY COUNT(*) DESC) AS RANK
		FROM RETAIL_SALES
		GROUP BY BRANCH,DAY
	)
WHERE RANK=1;


-- Q.4 Calculate the total quantity of items sold per payment method. List payment_method and total_quantity.

SELECT 
	PAYMENT_METHOD,
	SUM(QUANTITY) AS TOTAL_QUANTITY
FROM RETAIL_SALES
GROUP BY PAYMENT_METHOD;


-- Q.5 Determine the average, minimum, and maximum rating of category for each city. 
-- List the city, average_rating, min_rating, and max_rating.

SELECT 
	CITY,
	CATEGORY,
	AVG(RATING) AS AVERAGE_RATING,
	MIN(RATING) AS MINIMUM_RATING,
	MAX(RATING) AS MAXIMUM_RATING
FROM RETAIL_SALES
GROUP BY CITY, CATEGORY
ORDER BY 1, 2;


-- Q.6 Calculate the total profit for each category by considering total_profit as (unit_price * quantity * profit_margin). 
-- List category and total_profit, ordered from highest to lowest profit.

SELECT 
	CATEGORY,
	SUM((TOTAL * PROFIT_MARGIN)) AS TOTAL_PROFIT
FROM RETAIL_SALES
GROUP BY CATEGORY
ORDER BY TOTAL_PROFIT DESC;


-- Q.7 Determine the most common payment method for each Branch. 
-- Display Branch and the preferred_payment_method.

WITH COMMON_PAYMENT AS
	(
		SELECT 
			BRANCH,
			PAYMENT_METHOD,
			COUNT(PAYMENT_METHOD) AS COUNT_PAYMENT_METHOD,
			ROW_NUMBER() OVER(PARTITION BY BRANCH ORDER BY COUNT(PAYMENT_METHOD) DESC) AS RANK
		FROM RETAIL_SALES
		GROUP BY BRANCH, PAYMENT_METHOD
	)
SELECT 
	BRANCH,
	PAYMENT_METHOD,
	COUNT_PAYMENT_METHOD
FROM COMMON_PAYMENT
WHERE RANK = 1;


-- Q.8 Categorize sales into 3 group MORNING, AFTERNOON, EVENING 
-- Find out each of the shift and number of invoices

SELECT 
	BRANCH,
	CASE
		WHEN EXTRACT(HOUR FROM TIME::TIME) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM TIME::TIME) BETWEEN 12 AND 17 THEN 'Evening'
		ELSE 'Night'
	END AS DAY_PARTITION,
	COUNT(*) AS TOTAL_TRANSACTION
FROM RETAIL_SALES
GROUP BY BRANCH, DAY_PARTITION
ORDER BY 1, 3 DESC;


/* Q9. Identify 5 branch with highest decrese ratio in 
revevenue compare to last year(current year 2023 and last year 2022)
ratio of decrease(rdr) == last_rev-cr_rev/ls_rev*100*/

WITH REVENUE_2022 AS (
    SELECT 
        BRANCH,
        SUM(TOTAL) AS REVENUE
    FROM RETAIL_SALES
    WHERE EXTRACT(YEAR FROM TO_DATE(DATE, 'DD/MM/YY')) = 2022
    GROUP BY BRANCH
), 

REVENUE_2023 AS (
    SELECT 
        BRANCH,
        SUM(TOTAL) AS REVENUE
    FROM RETAIL_SALES
    WHERE EXTRACT(YEAR FROM TO_DATE(DATE, 'DD/MM/YY')) = 2023
    GROUP BY BRANCH
)

SELECT 
    LS.BRANCH,
    LS.REVENUE AS LAST_YEAR_REVENUE,
    CS.REVENUE AS CURRENT_YEAR_REVENUE,
    ROUND(
        (LS.REVENUE - CS.REVENUE)::NUMERIC / LS.REVENUE::NUMERIC * 100, 
        2
    ) AS REV_DEC_RATIO
FROM REVENUE_2023 AS LS
INNER JOIN 
REVENUE_2022 AS CS
ON LS.BRANCH = CS.BRANCH
WHERE LS.REVENUE > CS.REVENUE
ORDER BY REV_DEC_RATIO DESC
LIMIT 5;




