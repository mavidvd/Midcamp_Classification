USE W5project;

DROP TABLE ccdata;

CREATE TABLE ccdata (
	CustID int PRIMARY KEY AUTO_INCREMENT,
	Accept varchar(10),
    Reward varchar(10),
    Mailer varchar(10),
    Income varchar(10),
    Accounts int,
    Protection varchar(10),
    Rating varchar(10),
    Cards int,
    Homes int,
    HHSize int,
    HomeOwner varchar(10),
    AvgBal float,
    BalQ1 int,
    BalQ2 int,
    BalQ3 int,
    BalQ4 int
);

# 1. Import the data from the csv file into the table. Before you import the data into the empty table, 
# make sure that you have deleted the headers from the csv file. To not modify the original data, if you want you can create a copy of
# the csv file as well. Note you might have to use the following queries to give permission to SQL to import data from csv files in bulk:
# SHOW VARIABLES LIKE 'local_infile'; -- This query would show you the status of the variable ‘local_infile’. 
# If it is off, use the next command, otherwise you should be good to go
# SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'local_infile';
SET GLOBAL local_infile = 1;

# 2. Select all the data from table credit_card_data to check if the data was imported correctly.
SELECT 
    *
FROM
    ccdata;

# 3. Use the alter table command to drop the column q4_balance from the database, as we would not use it in the analysis with SQL.
# Select all the data from the table to verify if the command worked. Limit your returned results to 10.
ALTER TABLE ccdata 
DROP COLUMN BalQ4;

SELECT 
    *
FROM
    ccdata
LIMIT
	10;

# 4. Use sql query to find how many rows of data you have.
SELECT 
	COUNT(*)
FROM
	ccdata;

# 5. Now we will try to find the unique values in some of the categorical columns:
# a. What are the unique values in the column Offer_accepted?
SELECT DISTINCT
	Accept
FROM
	ccdata;
    
# b. What are the unique values in the column Reward?
SELECT DISTINCT
	Reward
FROM
	ccdata;

# c. What are the unique values in the column mailer_type?
SELECT DISTINCT
	Mailer
FROM
	ccdata;

# d. What are the unique values in the column credit_cards_held?
SELECT DISTINCT
	Cards
FROM
	ccdata;

# e. What are the unique values in the column household_size?
SELECT DISTINCT
	HHSize
FROM
	ccdata;

# 6. Arrange the data in a decreasing order by the average_balance of the house. Return only the customer_number of
# the top 10 customers with the highest average_balances in your data.
SELECT 
	CustID
FROM
	ccdata
ORDER BY
	AvgBal DESC
LIMIT 10;

# 7. What is the average balance of all the customers in your data?
SELECT
	AVG(AvgBal)
FROM
	ccdata;

# 8. In this exercise we will use simple group by to check the properties of some of the categorical variables in our data.
# Note wherever average_balance is asked, please take the average of the column average_balance:
# a. What is the average balance of the customers grouped by Income Level? The returned result should have only two columns,
# income level and Average balance of the customers. Use an alias to change the name of the second column.
SELECT
	Income,
	ROUND(AVG(AvgBal), 2) AS 'Average Balance'
FROM
	ccdata
GROUP BY 1;

# b. What is the average balance of the customers grouped by number_of_bank_accounts_open? The returned result should have only two columns,
# number_of_bank_accounts_open and Average balance of the customers. Use an alias to change the name of the second column.
SELECT
	Accounts,
	ROUND(AVG(AvgBal), 2) AS 'Average Balance'
FROM
	ccdata
GROUP BY 1;

# c. What is the average number of credit cards held by customers for each of the credit card ratings?
# The returned result should have only two columns, rating and average number of credit cards held. Use an alias for the second column.
SELECT
	Rating,
	ROUND(AVG(Cards), 2) AS 'Average Cards'
FROM
	ccdata
GROUP BY 1;

# d. Is there any correlation between the columns credit_cards_held and number_of_bank_accounts_open?
# You can analyse this by grouping the data by one of the variables and then aggregating the results of the other column.
# Visually check if there is a positive correlation or negative correlation or no correlation between the variables.
SELECT
	Cards,
	ROUND(AVG(Accounts), 2) AS 'Average Accounts'
FROM
	ccdata
GROUP BY 1
ORDER BY 1;

# There is apparently no correlation since the average amount of accounts open doesn't change when the amount of cards changes.

# 9. Your managers are only interested in the customers with the following properties:
# - Credit rating medium or high
# - Credit cards held 2 or less
# - Owns their own home
# - Household size 3 or more
# For the rest of the things, they are not too concerned. Write a simple query to find what are the options available for them?
SELECT
	CustID
FROM 
	ccdata
WHERE Rating IN ('High', 'Medium') AND
Cards <= 2 AND
HomeOwner = 'Yes' AND
HHSize >= 3;

# Can you filter the customers who accepted the offers here?
SELECT
	CustID
FROM 
	ccdata
WHERE Rating IN ('High', 'Medium') AND
Cards <= 2 AND
HomeOwner = 'Yes' AND
HHSize >= 3 AND
Accept = 'Yes';

# 10. Your managers want to find out the list of customers whose average balance is less than the average balance of all the customers
# in the database. Write a query to show them the list of such customers. You might need to use a subquery for this problem.
SELECT 
    CustID
FROM
    ccdata
WHERE
    AvgBal < (
		SELECT 
            AVG(AvgBal)
        FROM
            ccdata
		)
;

# 11. Since this is something that the senior management is regularly interested in, create a view of the same query.
CREATE VIEW LowerThanAvgBal AS
    SELECT 
        CustID
    FROM
        ccdata
    WHERE
        AvgBal < (SELECT 
                AVG(AvgBal)
            FROM
                ccdata)
;

# 12. What is the number of people who accepted the offer vs number of people who did not?
SELECT
	Accept,
    COUNT(*)
FROM
	ccdata
GROUP BY 1;

# 13. Your managers are more interested in customers with a credit rating of high or low.
# What is the difference in average balances of the customers with high credit card rating and low credit card rating?
SELECT
	Rating,
	ROUND(AVG(AvgBal), 2) AS 'Average Balance'
FROM 
	ccdata
WHERE Rating IN ('High', 'Low')
GROUP BY 1;

# 14. In the database, which all types of communication (mailer_type) were used and with how many customers?
SELECT
	Mailer,
    COUNT(*)
FROM
	ccdata
GROUP BY 1;

# 15. Provide the details of the customer that is the 11th least Q1_balance in your database.
# First option: Create a subquery with the 11 lowest BalQ1 (by order asc), then order descending and take the 1st one only.
SELECT 
	CustID
FROM (
    SELECT 
		CustID,
        BalQ1
	FROM
		ccdata
	ORDER BY 2 ASC
    LIMIT 11)sq1 
ORDER BY
	BalQ1 DESC
LIMIT 1;

# Second option: Rank the users and take only where rank = 11.
SELECT 
	CustID,
    BalQ1,
    RANK() OVER(
                ORDER BY BalQ1 ASC
			   ) AS 'Q1 Bal Rank'
FROM
	ccdata
WHERE
	'Q1 Bal Rank' = 11;
# If we use the RANK() function, there is no 11th rank, as it skips from 6 to 16.
SELECT 
	CustID,
    BalQ1,
    RANK() OVER(
                ORDER BY BalQ1 ASC
			   ) AS 'Q1 Bal Rank'
FROM
	ccdata;
    
# We can use the DENSE_RANK() function which does not skip any numbers in the rank, but in this case, we get many customers with the same rank.
SELECT
	CustID, 
    Q1Rank
FROM (
	SELECT 
		CustID,
		BalQ1,
		DENSE_RANK() OVER(
					ORDER BY BalQ1 ASC) AS Q1Rank
	FROM
		ccdata
	 ) dt1
WHERE
	Q1Rank = 11;