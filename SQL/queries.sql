

#I have first loaded the file into Jupyter, cleaned the headers (changed it to lower case, removed spaces and '#'),
#then I have saved the file to csv and imported it to SQL via import wizard.

use credit_card_classification;

# 4. Select all the data from table credit_card_data to check if the data was imported correctly.

SELECT *
FROM credit_card_data;

#5. Use the alter table command to drop the column q4_balance from the database, as we would not use it in the analysis with SQL. 
#Select all the data from the table to verify if the command worked. Limit your returned results to 10.

ALTER TABLE credit_card_data 
	DROP COLUMN q4_balance;

SELECT *
FROM credit_card_data
LIMIT 10;

# 6. Use sql query to find how many rows of data you have.

SELECT COUNT(customer_number)
FROM credit_card_data;
  
#I have 17976 rows (24 rows missing compared to the original dataset, however rows missing are not so much decided to proceed)

#7. Now we will try to find the unique values in some of the categorical columns:
# What are the unique values in the column `Offer_accepted`? A: YES/NO

SELECT DISTINCT offer_accepted
FROM credit_card_data;

# What are the unique values in the column `Reward`? A: Air Miles, Cash Back, Points

SELECT DISTINCT reward
FROM credit_card_data;

# What are the unique values in the column `mailer_type`? A: Letter, Postcard

SELECT DISTINCT mailer_type
FROM credit_card_data;

# What are the unique values in the column `credit_cards_held`? A: 1,2,3,4

SELECT DISTINCT credit_cards_held
FROM credit_card_data;

# What are the unique values in the column `household_size`? A: 1,2,3,4,5,6,7,8,9

SELECT DISTINCT household_size
FROM credit_card_data;

#8. Arrange the data in a decreasing order by the average_balance of the house. 
# Return only the customer_number of the top 10 customers with the highest average_balances in your data.

SELECT customer_number, rank() over(order by average_balance desc) as rank1
FROM credit_card_data
LIMIT 10;

#9. What is the average balance of all the customers in your data? A: 940,515

SELECT avg(average_balance) as avg1
from credit_card_data;

#10. In this exercise we will use group by to check the properties of some of the categorical variables in our data. 
# Note wherever average_balance is asked in the questions below, please take the average of the column average_balance:

# What is the average balance of the customers grouped by `Income Level`? The returned result should have only two columns, 
#income level and `Average balance` of the customers. Use an alias to change the name of the second column.

SELECT income_level, avg(average_balance) avgb_by_income
FROM credit_card_data
GROUP BY income_level;


# What is the average balance of the customers grouped by `number_of_bank_accounts_open`? 
#The returned result should have only two columns, `number_of_bank_accounts_open` and `Average balance` of the customers. 
#Use an alias to change the name of the second column.

SELECT bank_accounts_open, avg(average_balance) as avgb_by_nacc
FROM credit_card_data
GROUP BY bank_accounts_open;

# What is the average number of credit cards held by customers for each of the credit card ratings? 
#The returned result should have only two columns, rating and average number of credit cards held. 
#Use an alias to change the name of the second column.

SELECT credit_rating, avg(credit_cards_held) as avg_n_cc
FROM credit_card_data
GROUP BY credit_rating;

# Is there any correlation between the columns `credit_cards_held` and `number_of_bank_accounts_open`? 
#You can analyse this by grouping the data by one of the variables and then aggregating the results of the other column. 
#Visually check if there is a positive correlation or negative correlation or no correlation between the variables.
#You might also have to check the number of customers in each category (ie number of credit cards held) to assess if that 
#category is well represented in the dataset to include it in your analysis. 
#For eg. If the category is under-represented as compared to other categories, ignore that category in this analysis

SELECT credit_cards_held, sum(bank_accounts_open) as n_accounts_open
FROM credit_card_data
GROUP BY credit_cards_held
ORDER BY credit_cards_held

#### Correlation: the leass amount of accounts open more credit cards the customer has. 

#11. Your managers are only interested in the customers with the following properties:
# Credit rating medium or high
# Credit cards held 2 or less
# Owns their own home
# Household size 3 or more
#For the rest of the things, they are not too concerned. Write a simple query to find what are the options available for them? 
#Can you filter the customers who accepted the offers here?

SELECT customer_number, credit_rating, credit_cards_held, own_your_home, household_size, offer_accepted
FROM credit_card_data
WHERE credit_rating IN ('Medium', 'High') AND 
credit_cards_held <= 2 AND own_your_home = 'Yes' AND
household_size >= 3 AND offer_accepted = 'Yes';

#I've got 167 rows.

#12. Your managers want to find out the list of customers whose average balance is less than the average balance of all the customers 
#in the database. Write a query to show them the list of such customers. You might need to use a subquery for this problem.

SELECT customer_number, average_balance
FROM credit_card_data
WHERE average_balance < (SELECT avg(average_balance) FROM credit_card_data)
ORDER BY average_balance;

#13. Since this is something that the senior management is regularly interested in, create a view called Customers__Balance_View1 
#of the same query.

CREATE VIEW customers_balance_view1 AS
SELECT customer_number, average_balance
FROM credit_card_data
WHERE average_balance < (SELECT avg(average_balance) FROM credit_card_data)
ORDER BY average_balance;

SELECT * 
FROM customers_balance_view1;

#14. What is the number of people who accepted the offer vs number of people who did not?

SELECT 
	sum(case when offer_accepted = 'Yes' then 1 else 0 end) as oa_yes,
    sum(case when offer_accepted = 'No' then 1 else 0 end) as oa_no
FROM credit_card_data;

    
#16. In the database, which all types of communication (mailer_type) were used and with how many customers?

SELECT DISTINCT mailer_type,
COUNT(customer_number) over (partition by mailer_type order by mailer_type) as count_cust
FROM credit_card_data;

# 17. Provide the details of the customer that is the 11th least Q1_balance in your database.

SELECT * 
FROM (SELECT *, dense_rank() over (order by q1_balance ASC) as rank_2
FROM credit_card_data) as sub1
WHERE rank_2 = 11;

#There's 3 customers with same q1_balance, and it was the reason why I used dense rank instead of rank.

