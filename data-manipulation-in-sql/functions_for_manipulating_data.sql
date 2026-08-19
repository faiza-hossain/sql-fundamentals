---Getting information about your database
 -- Select all columns from the TABLES system database
 SELECT * 
 FROM INFORMATION_SCHEMA.TABLES
 -- Filter by schema
 WHERE table_schema = 'public';
 -- Select all columns from the COLUMNS system database
 SELECT * 
 FROM INFORMATION_SCHEMA.COLUMNS 
 WHERE table_name = 'actor';
 ---Determining data types
-- Get the column name and data type
SELECT
 	column_name, 
    data_type
-- From the system database information schema
FROM INFORMATION_SCHEMA.COLUMNS 
-- For the customer table
WHERE table_name = 'customer';
--Interval data types
SELECT
 	-- Select the rental and return dates
	rental_date,
	return_date,
 	-- Calculate the expected_return_date
	rental_date + INTERVAL '3 DAYS' AS expected_return_date
FROM rental;
-- Accessing data in an ARRAY
-- Select the title and special features column 
SELECT 
  title, 
  special_features 
FROM film
-- Use the array for first index of the special_features column
WHERE special_features[1] = 'Trailers';
-- Select the title and special features column 
SELECT 
  title, 
  special_features 
FROM film
-- Use the array index of the special_features column
WHERE special_features[2] = 'Deleted Scenes';

-- Searching an ARRAY with ANY
SELECT
  title, 
  special_features 
FROM film 
-- Modify the query to use the ANY function 
WHERE 'Trailers' = ANY (special_features);

-- Searching an ARRAY with @> alternative of ANY function
SELECT 
  title, 
  special_features 
FROM film 
-- Filter where special_features contains 'Deleted Scenes'
WHERE special_features @> ARRAY['Deleted Scenes'];

-- Adding and subtracting date and time values
SELECT f.title, f.rental_duration,
    -- Calculate the number of days rented
    r.return_date - r.rental_date AS days_rented
FROM film AS f
     INNER JOIN inventory AS i ON f.film_id = i.film_id
     INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
ORDER BY f.title;
-----same but with AGE function
SELECT f.title, f.rental_duration,
    -- Calculate the number of days rented
	AGE(r.return_date, r.rental_date) AS days_rented
FROM film AS f
	INNER JOIN inventory AS i ON f.film_id = i.film_id
	INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
ORDER BY f.title;

-----INTERVAL arithmetic
SELECT
	f.title,
 	-- Convert the rental_duration to an interval
    INTERVAL '1 day' * f.rental_duration,
 	-- Calculate the days rented as we did previously
    r.return_date - r.rental_date AS days_rented
FROM film AS f
    INNER JOIN inventory AS i ON f.film_id = i.film_id
    INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
-- Filter the query to exclude outstanding rentals
WHERE r.return_date is NOT NULL
ORDER BY f.title;

----Calculating the expected return date
SELECT
    f.title,
	r.rental_date,
    f.rental_duration,
    -- Add the rental duration to the rental date
    INTERVAL '1' day * f.rental_duration + r.rental_date AS expected_return_date,
    r.return_date
FROM film AS f
    INNER JOIN inventory AS i ON f.film_id = i.film_id
    INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
ORDER BY f.title;

-- Select the current timestamp
SELECT NOW();

-- Select the current date
SELECT CURRENT_DATE;

--Select the current timestamp without a timezone
SELECT CAST( NOW() AS timestamp )

SELECT 
	-- Select the current date
	current_date,
    -- CAST the result of the NOW() function to a date
    CAST( NOW() AS date )

--Select the current timestamp without timezone
SELECT CURRENT_TIMESTAMP::TIMESTAMP AS right_now;

SELECT
	CURRENT_TIMESTAMP(0)::timestamp AS right_now,
    interval '5 days' + CURRENT_TIMESTAMP(0) AS five_days_from_now;

---EXTRACT()
-- Extract day of week from rental_date
SELECT 
  EXTRACT(dow FROM rental_date) AS dayofweek, 
  -- Count the number of rentals
  count(*) as rentals 
FROM rental 
GROUP BY 1;

--Using DATE_TRUNC
-- Truncate rental_date by year
SELECT DATE_TRUNC('year', rental_date) AS rental_year
FROM rental;
-- Truncate rental_date by month
SELECT date_trunc('month', rental_date) AS rental_month
FROM rental;
-- Truncate rental_date by day of the month 
SELECT date_trunc('day', rental_date) AS rental_day 
FROM rental;

SELECT 
  DATE_TRUNC('day', rental_date) AS rental_day,
  -- Count total number of rentals 
  Count(*) AS rentals 
FROM rental
GROUP BY 1;
SELECT 
  -- Extract the day of week date part from the rental_date
  EXTRACT(dow from rental_date) AS dayofweek,
  AGE(return_date, rental_date) AS rental_days
FROM rental AS r 
WHERE 
  -- Use an INTERVAL for the upper bound of the rental_date 
  rental_date BETWEEN CAST('2005-05-01' AS Date)
   AND CAST('2005-05-01' AS Date) + INTERVAL '90 day';
SELECT 
  c.first_name || ' ' || c.last_name AS customer_name,
  f.title,
  r.rental_date,
  -- Extract the day of week date part from the rental_date
  EXTRACT(dow FROM r.rental_date) AS dayofweek,
  AGE(r.return_date, r.rental_date) AS rental_days,
  -- Use DATE_TRUNC to get days from the AGE function
  CASE WHEN DATE_TRUNC('day', AGE(r.return_date, r.rental_date)) > 
  -- Calculate number of d
    f.rental_duration * INTERVAL '1' day 
  THEN TRUE 
  ELSE FALSE END AS past_due 
FROM 
  film AS f 
  INNER JOIN inventory AS i 
  	ON f.film_id = i.film_id 
  INNER JOIN rental AS r 
  	ON i.inventory_id = r.inventory_id 
  INNER JOIN customer AS c 
  	ON c.customer_id = r.customer_id 
WHERE 
  -- Use an INTERVAL for the upper bound of the rental_date 
  r.rental_date BETWEEN CAST('2005-05-01' AS DATE) 
  AND CAST('2005-05-01' AS DATE) + INTERVAL '90 day';