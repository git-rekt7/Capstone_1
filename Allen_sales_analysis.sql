
-- Shruti info
SELECT
    *
FROM
    sample_sales.management
WHERE
    SalesManager LIKE '%Shruti Reddy%';
    
-- What is total revenue overall for sales in the assigned territory, plus the start date and end date
-- that tell you what period the data covers?

SELECT 
FORMAT
    (SUM(s.Sale_Amount), 2) AS total_revenue,
    MIN(s.Transaction_Date) AS start_date,
    MAX(s.Transaction_Date) AS end_date
FROM 
	store_sales s
JOIN 
	store_locations l 
    ON s.Store_ID = l.StoreId
WHERE 
	l.State = 'Maryland';

-- What is the month by month revenue breakdown for the sales territory?

SELECT 
    DATE_FORMAT(s.Transaction_Date, '%Y-%m') AS month,
FORMAT 
		(SUM(s.Sale_Amount), 2) AS monthly_revenue
FROM 
	store_sales s
JOIN 
	store_locations l 
    ON l.StoreId = s.Store_ID
WHERE 
	l.State = 'Maryland'
GROUP BY 
	DATE_FORMAT(s.Transaction_Date, '%Y-%m')
ORDER BY month;

-- Provide a comparison of total revenue for the specific sales territory and the region it belongs to.

SELECT 
    l.State,
    m.Region,

    FORMAT (SUM(s.Sale_Amount), 2) AS Total_Revenue,

    (
        SELECT 
			FORMAT (SUM(s2.Sale_Amount), 2)
        FROM 
			Store_Sales s2
        JOIN 
			Store_Locations l2 
            ON s2.Store_ID = l2.StoreId
        JOIN 
			Management m2
            ON l2.State = m2.State
        WHERE 
			m2.Region = m.Region
    ) AS Region_Revenue

FROM 
	Store_Sales s
JOIN 
	Store_Locations l 
    ON s.Store_ID = l.StoreId

JOIN 
	Management m
    ON l.State = m.State

WHERE 
	l.State = 'Maryland'

GROUP BY 
	l.State, m.Region; 

-- What is the number of transactions per month and average transaction size by product category
-- for the sales territory?

SELECT
	l.State,
    c.Category,
    COUNT(*) AS 'transaction#',
    DATE_FORMAT(s.Transaction_Date, '%Y-%m') AS Month,
    AVG(s.Sale_Amount) AS Avg_Transaction_Size
FROM
	Store_Sales s
JOIN
	Store_Locations l
    ON s.Store_ID = l.StoreId
JOIN
	products p
    ON s.Prod_Num = p.ProdNum
JOIN
	inventory_categories c
    ON p.CategoryID = c.Categoryid

WHERE l.state = 'Maryland'

GROUP BY
	l.state,
    Month,
    c.Category
ORDER BY
	Month,
    c.Category;
    
-- Can you provide a ranking of in-store sales performance by each store in the sales territory, or a
-- ranking of online sales performance by state within an online sales territory?

SELECT
    Sales_Territory,
    Online_Revenue,
    RANK() OVER (
				ORDER BY Online_Revenue DESC
		) AS State_Rank
FROM (
    SELECT
        o.ShiptoState AS Sales_Territory,
        SUM(o.SalesTotal) AS Online_Revenue
    FROM 
		Online_Sales o
    JOIN 
		Management m
        ON o.ShiptoState = m.State
    WHERE 
		m.Region = 'Northeast'
    GROUP BY 
		o.ShiptoState
) totals
ORDER BY 
	State_Rank;

/*Corey's Analysis and Recommendation

The data shows us that 66% the monthly revenue in Maryland is generated from 
"Technology & Accessories". Technology tends to contain higher ticket priced items,   which would account for the bias towards those sales. The second largest category would be the "Textbooks" category which comprises 23% of the monthly revenue.

We can focus on these two areas to maximize profit by offering a seasonal promotion that offers reduced priced technology/accessories with the purchase of textbooks. This will bring even more revenue from our two largest segments, raising our overall revenue.

Another solution could be bundling lower ticket items with the higher ticket items, to clear out stock and promote more buying activity for each.*/
