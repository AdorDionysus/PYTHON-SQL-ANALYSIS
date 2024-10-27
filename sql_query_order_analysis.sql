
-- FIND TOP 10 HIGHEST PROFIT GENERATING PRODUCTS (MY FORMULA ON GETTING HIGHEST PROFIT IS SUM(TOTAL_PROFITT)
-- INSTEAD OF SUM(QUANTITY) * SALE_PRICE
-- SO THIS IS WHY I CREATE TOTAL PROFIT COLUMNS USING PANDAS COZ I THINK IT CAN BE HELPFUL IN THE FUTURE
SELECT product_id,sub_category,sum(total_profit)  AS revenue from order_analysis group by 
	product_id,sub_category ORDER  BY revenue DESC LIMIT 10 ;









-- TOP 10 HIGHEST REVENUE GENERATING PRODUCTS 
-- MY FORMULA ON THIS TO GET REVENUE IS  AVG SALES PRICE MULTIPLY BY TOTAL QUANTITY SALES 

WITH avgcte AS (select product_id,AVG(sale_price) as avgsale from order_analysis 
	group by product_id ORDER BY avgsale DESC LIMIT 10),
 	 total_quantity_sales as 
	(SELECT product_id,SUM(quantity) as total_quantity from order_analysis
	group by product_id	),
	total_revenue as 
	(select avgcte.product_id, totalsales.total_quantity * avgcte.avgsale as rev from avgcte  INNER JOIN total_quantity_sales totalsales
	on totalsales.product_id = avgcte.product_id  group by avgcte.product_id,rev order by rev DESC LIMIT 10)
 


select total_revenue.product_id,order_analysis.sub_category,total_revenue.rev from order_analysis
	INNER JOIN total_revenue on order_analysis.product_id = total_revenue.product_id
	group by total_revenue.product_id,order_analysis.sub_category,total_revenue.rev ORDER BY total_revenue.rev DESC LIMIT 10;







-- TOP 3 HIGHEST PROFITABLE PRODUCT ON EACH REGION
SELECT * FROM(
WITH CTE AS (select region,product_id,sum(total_profit) as profit_on_this_region from order_analysis group by region,product_id
order by profit_on_this_region DESC)
select *,row_number() over(partition by region order by profit_on_this_region DESC) as rn from CTE) where rn <=3





-- PROFIT COMPARISON BY EACH MONTH AND YEAR

WITH cte as (SELECT EXTRACT(YEAR FROM order_date) as order_year,
	EXTRACT(MONTH FROM order_date) as order_month , SUM(total_profit) as sales   from order_analysis 
group by order_year,order_month)



select order_month, sum(case when order_year = 2022 then sales else 0 end) as YEAR_2022,
	SUM(case when order_year = 2023 then sales else 0 end) as YEAR_2023
	from cte
group by order_month ORDER by order_month;





--- 2023 SUB CATEGORY THAT HAVE HIGHEST PROFIT GROWTH  COMPARED TO 2022 PROFIT



with cte as (SELECT sub_category, EXTRACT(YEAR FROM order_date) as the_year,SUM(sale_price) as sales FROM order_analysis group by sub_category, the_year),
cte2022 as (SELECT * FROM cte where the_year = 2022),
cte2023 as (SELECT * FROM cte where the_year = 2023)

SELECT *, cte2023.sales - cte2022.sales as growth_sales FROM cte2023 INNER JOIN cte2022 on cte2023.sub_category = cte2022.sub_category  where 
cte2023.sales > cte2022.sales;
