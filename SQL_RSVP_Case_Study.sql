/* -------   READ ME FIRST -------
- I have completed all 29 questions with comments and insights in inline comments.
- I have ensured that commenting and query formatting best practices are followed. 
- In some scenarios multiple values had exacts same ranks because of same avg_ratings, so I decided to use row number.
- Wherever count is expected, I have added comments right in front of column name for ease of reading. 
- Questions are separated using "Next Question Block" for ease of reading 
*/

USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/

-- Segment 1:

/* *************************
		NEXT QUESTION
        
*************************** */

-- Q1. Find the total number of rows in each table of the schema?

-- My approach
-- Total six tables - movie, genre, director_mapping, role_mapping, names, ratings
-- We need to count rows for each table

SELECT COUNT(*) FROM movie; -- 7997 rows found
SELECT COUNT(*) FROM genre; -- 14662 rows found
SELECT COUNT(*) FROM director_mapping; -- 3867 rows found
SELECT COUNT(*) FROM role_mapping; -- 15615 rows found
SELECT COUNT(*) FROM names; -- 25735 rows found
SELECT COUNT(*) FROM ratings; -- 7997 rows found

/* *************************
		NEXT QUESTION
        
*************************** */


-- Q2. Which columns in the movie table have null values?

-- My Approach
-- I have mentioned two approaches as alternative 1 and 2
-- Type your code below:

-- Alternative Solution 1
SELECT COUNT(*)-COUNT(id) As id_nulls, -- zero null values
       COUNT(*)-COUNT(title) As title_nulls, -- zero null values
       COUNT(*)-COUNT(year) As year_nulls, -- zero null values
	   COUNT(*)-COUNT(date_published) AS date_published_nulls, -- zero null values
       COUNT(*)-COUNT(duration) AS duration_nulls, -- zero null values
       COUNT(*)-COUNT(country) AS country_nulls, -- 20 null values
       COUNT(*)-COUNT(worlwide_gross_income) AS worlwide_gross_income, -- 3724 null values
       COUNT(*)-COUNT(languages) AS languages_nulls, -- 194 null values
       COUNT(*)-COUNT(production_company) AS production_company_nulls -- 528 null values
FROM movie;

-- ALternative Solution 2
SELECT * FROM movie;
SELECT 
count(*) AS total_rec  -- 7997
,count(title) AS c_title  -- 7997 
,count(year) AS c_year   -- 7997  
,count(date_published) AS c_dp -- 7997 
,count(duration) AS c_duration -- 7997 
,count(country) AS c_country -- 7977  
,count(worlwide_gross_income) AS c_worlwide_gross_income  -- 4273
,count(languages) AS c_languages  -- 7803
,count(production_company) AS c_production_company -- 7469
 FROM movie;

-- It turns out, 4 out of 10 columns 'Country', 'worlwide_gross_income','languages','production_company' from Movie table, have null values.


/* *************************
		NEXT QUESTION
        
*************************** */
-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- First Part 'movies released each year'
SELECT 
    year AS Year, COUNT(id) AS number_of_movies
FROM
    movie
GROUP BY year
ORDER BY year;

-- In the year of 2017, around 3052 (highest in the list) movies were released

-- second part ' movies released month wise'
SELECT 
    MONTH(date_published) AS month_num,
    COUNT(id) AS number_of_movies
FROM
    movie
GROUP BY MONTH(date_published)
ORDER BY MONTH(date_published);

-- Maximum Number of Movies(824) were released in March and December is the lowest(438) in the list.


/* *************************
		NEXT QUESTION
        
*************************** */

/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- My Approach
-- We need to add filter for country and year.

SELECT
m.year, m.country, COUNT(*) AS number_of_movies
FROM
    movie m
WHERE
    m.country  IN ('India', 'USA')
        AND m.year = 2019
GROUP BY m.country
ORDER BY m.year;

-- In total, 887 movies were produced in the USA and India in the year 2019.
-- Out of which 592 movies were produced in USA and 295 movies were produced in India.


/* *************************
		NEXT QUESTION
        
*************************** */

/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?

SELECT 
      ROW_NUMBER() OVER (ORDER BY genre) AS No, 
      genre 
FROM genre 
GROUP BY genre 
ORDER BY Genre;
-- Total 13 unique genres present in the genre table.


/* *************************
		NEXT QUESTION
        
*************************** */

/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?

-- My Approach
-- We shall perform join on movie table and genre table
-- Then count movies for each genre

-- 
SELECT 
     g.genre, COUNT(m.id) AS number_of_movies
FROM
    movie m
        INNER JOIN
    genre g ON m.id = g.movie_id
GROUP BY genre
ORDER BY number_of_movies DESC;

-- The genre 'Drama' has the highest number(4285) of movies releasing under it. 


/* *************************
		NEXT QUESTION
        
*************************** */

/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?

-- My Approach
-- We can query movie ids and count how many genres are registered with it
-- We can get the movie ids with 1 genre_count and get the count
-- As we know, there are movies which belongs to multiple genre type. i.e, - (Horror, Comedy) or (Scifi, action and comedy)


WITH count_genre AS -- Creating a CTE with two columns only, movie_id and genre count using Genre table
(
   SELECT
      movie_id,
      COUNT(genre) AS count_of_genre 
   FROM
      genre 
   GROUP BY
      movie_id
)
SELECT
   COUNT(movie_id) AS Movies_With_One_Genre 
FROM
   count_genre 
WHERE
   count_of_genre = 1; 
   
   -- 3289 movies in total belong to only one genre type.


/* *************************
		NEXT QUESTION
        
*************************** */

/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)

-- My Approach
-- We need to differentiate movies by genre and find their avg duration from movie table
-- We need to join movie and genre on movie_id
/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- We need two columns genre and avg_duration
-- We are going to perform inner join on movie_id 
-- We need to group by the output with reference to genre
-- Let's order the avg_duration in ascending order

SELECT 
    g.genre, ROUND(AVG(m.duration),2) AS avg_duration 
FROM
    movie m
        INNER JOIN
    genre g ON m.id = g.movie_id 
GROUP BY g.genre 
ORDER BY avg_duration; 

-- Horror genre movies has the lowest avg_duration with 92.72
-- Action genre has the highest avg_duration of 112.88
-- Drama, the highest released movie genre, has avg_duration around 106.7


/* *************************
		NEXT QUESTION
        
*************************** */

/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)

/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/

-- My Approach
-- We'll first create a CTE to rank all the genres 
-- Then we'll just extract the 'Thiller' using select query


WITH cte 
AS 
(
SELECT  g.genre, count(m.title) AS movie_count, 
        RANK() OVER (ORDER BY count(g.genre) desc) AS genre_rank
FROM 
	movie m
INNER JOIN genre g ON m.id =  g.movie_id
GROUP BY genre
)
SELECT * FROM cte WHERE genre='Thriller';

-- From the result, Thriller is the 3rd highest (1484 movies) in terms of number of movies produced. 


/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/


/* *************************
		NEXT QUESTION
        
*************************** */


-- Segment 2:


-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/

-- My Approach
-- There are four columns in the table 'ratings'
-- We need to find min average and max avg for three columns - Avg_Rating, total_votes, median_rating
-- we are going to use min(), max() here
SELECT MIN(avg_rating) AS min_avg_rating,             -- 1.0 is the min_avg_rating
       MAX(avg_rating) AS max_avg_rating,             -- 10.0 is the max_avg_rating
       MIN(total_votes) AS min_total_votes,           -- 100 is the min_total_votes
       MAX(total_votes) AS max_total_votes,           -- 725138 is the max_total_votes
       MIN(median_rating) AS min_median_rating,       -- 1 is min_median_rating
       MAX(median_rating) AS max_median_rating        -- 10 is max_median_rating
FROM ratings;

/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/


/* *************************
		NEXT QUESTION
        
*************************** */

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- It's ok if RANK() or DENSE_RANK() is used too

-- My Approach
-- We need to find top 10 movies with highest avg_rating
-- We are going to need title of the movie from movie table
-- We need to join movie table and ratings on movie_id
-- Then we can rank them in descending order
-- We are going to use CTE here as well


WITH cte AS
(
SELECT m.title, r.avg_rating,
       DENSE_RANK() OVER (ORDER BY avg_rating DESC) AS movie_rank
FROM movie m 
       INNER JOIN ratings r ON m.id = r.movie_id
) 
SELECT * FROM cte WHERE movie_rank<=10;

-- Kirket has the highest avg_rating with 10.0 in the list
-- Fan is in the 4th highest position with avg_rating 9.6

/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/


/* *************************
		NEXT QUESTION
        
*************************** */

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */

-- My Approach
-- We can run a select query in ratings table itself
-- We can then count number of movies with respecting median_rating
-- Order by is good to have

SELECT 
    r.median_rating, COUNT(r.movie_id) AS movie_count
FROM
    ratings r
GROUP BY r.median_rating
ORDER BY r.median_rating;
-- Movies with rating 1 are lowest(94) and with rating 7 are highest(2257)

/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/


/* *************************
		NEXT QUESTION
        
*************************** */

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/

-- My Approach
-- We shall create a CTE and join movie, and ratings table
-- We need three columns, name of production house, number of hit movies produced, and give them a rank
-- We need to add a filter to count hit movies i.e., avg_rating >8
-- Then, we'll just run a select query to get the results with rank value 1

WITH cte AS 
(
SELECT m.production_company, COUNT(m.id) AS movie_count, 
       DENSE_RANK() OVER(ORDER BY COUNT(m.id) desc) AS prod_company_denserank
FROM movie m 
	   INNER JOIN ratings r ON m.id = r.movie_id
WHERE avg_rating >8 AND m.production_company IS NOT NULL
GROUP BY m.production_company 
ORDER BY movie_count DESC
)
SELECT * FROM cte 
         WHERE prod_company_denserank = 1;
         
-- Dream Warrior Pictures and National Theatre Live, both, have 3 movies with all three movies rating >8


/* *************************
		NEXT QUESTION
        
*************************** */

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */

-- My Approach
-- We need to join 3 tables here. Movie, Genre, and ratings
-- We need to get month, year and country from movie
-- Group them by each genre
-- Then put filter on the total_votes column from ratings table, i.e., total_votes >1000
-- We're going to use CTE to form a temp table with the required filtered data from movie table


-- Alternative 1

WITH movie_filter AS 
(
   SELECT id 
   FROM Movie 
   WHERE country = 'USA' 
         AND MONTH(date_published) = 3 
         AND year = '2017' 
)
SELECT g.genre, COUNT(id) as movie_count 
FROM movie_filter 
   INNER JOIN genre g ON movie_filter.id = g.movie_id 
         INNER JOIN ratings r ON g.movie_id = r.movie_id 
WHERE r.total_votes > 1000 
GROUP BY genre 
ORDER BY genre;
   
   
   -- Alternative 2 
   SELECT 
    g.genre, COUNT(m.id) AS movie_count
FROM
    movie m
        INNER JOIN
    genre g ON m.id = g.movie_id
        INNER JOIN
    ratings r ON m.id = r.movie_id
WHERE
    m.year = '2017'
        AND MONTH(m.date_published) = 3
        AND m.country = 'USA'
        AND r.total_votes > 1000
GROUP BY g.genre
order by 2;

-- In USA during Month of March 2017, around 16 movies with genre 'drama' was made which is highest in the list
-- Only 1 Family genre movie was produced during that time which was lowest

-- Lets try to analyse with a unique problem statement.


/* *************************
		NEXT QUESTION
        
*************************** */


-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/

-- My Approach 
-- We are going to use CTE here to create a temp table with id and title(starting with 'the') from movie table 
-- Then join them with ratings and genre table 
-- Then filter them with condition avg_rating >8
-- I have mentioned two approaches as alternative 1 and 2
   
-- Alternative 1
WITH movie_title 
AS 
(
   SELECT title, id 
   FROM Movie 
   WHERE title LIKE 'The%' 
)
SELECT Title, r.avg_rating, g.genre 
FROM
   movie_title 
   INNER JOIN genre g ON movie_title.id = g.movie_id 
		INNER JOIN ratings r ON g.movie_id = r.movie_id 
WHERE r.avg_rating > 8 
GROUP BY genre 
ORDER BY avg_rating desc;
   
   -- Alternative 2
SELECT m.title, r.avg_rating, g.genre
FROM   movie m 
       INNER JOIN genre g ON m.id = g.movie_id
			 INNER JOIN ratings r ON m.id = r.movie_id
WHERE title REGEXP '^The' AND r.avg_rating > 8;

-- The Blue Elephant 2 has highest rating of 8.8 
-- and The King and I has lowest rating 8.2 among movies with title starting with 'the' and avg_rating >8

/* *************************
		NEXT QUESTION
        
*************************** */



-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?

-- My Approach
-- We need to use 'between' here to filter our data
-- We need to count no. of movies with median rating = 8
-- We need to join movie table with ratings table

-- Alternative 1
WITH movies_april
AS(
SELECT id, title, date_published 
FROM movie
WHERE date_published BETWEEN '2018-04-01' AND '2019-04-01'
)
SELECT COUNT(title) AS Total_movies , r.median_rating  -- date_published
FROM movies_april 
INNER JOIN ratings r ON id = r.movie_id
WHERE r.median_rating = 8
GROUP BY r.median_rating;

   -- Alternative Solution 2
SELECT count(DISTINCT m.id) AS movie_count
FROM movie m 
     INNER JOIN ratings r ON m.id = r.movie_id
WHERE date_published BETWEEN '2018-04-01' AND '2019-04-01'
					 AND r.median_rating = 8;

-- Total 361 movies were released between 1st april 2018 to 1st april 2019 with median_rating = 8

/* *************************
		NEXT QUESTION
        
*************************** */

-- Q17. Do German movies get more votes than Italian movies? 

-- My Approach 
-- Here we have to filter the data using language german/italian
-- Total_votes should come from ratings table
-- So, we need to join Movie and ratings table again here.

SELECT 
    m.languages, 
    SUM(r.total_votes) AS sum_total_vote_count, 
    r.total_votes AS total_vote_count
FROM movie m INNER JOIN ratings r ON m.id = r.movie_id
WHERE m.languages in ('German', 'Italian')
GROUP BY m.languages;

/* Please read this
 Answer is Yes, If We take "total_votes" as it gives values of only 1 movie
 However Answer is No, in our opinion, because we should be considering SUM(total_votes) in this scenario
 We have taken SUM(r.total_votes) AS sum_total_vote_count. Plz run the query. 
 */


-- Segment 3:


/* *************************
		NEXT QUESTION
        
*************************** */

-- Q18. Which columns in the names table have null values??

/*
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- We can directly count the columns like we did before


SELECT COUNT(*)-COUNT(name) As name_nulls, -- zero
       COUNT(*)-COUNT(height) As height_nulls, -- 17335 null values
       COUNT(*)-COUNT(date_of_birth) As date_of_birth_nulls, -- 13431 null values
	   COUNT(*)-COUNT(known_for_movies) AS known_for_movies_nulls -- 15226 null values
FROM names;
-- cross verification
-- SELECT COUNT(*) FROM names WHERE height IS NULL; -- 17335 Null values
-- There are no Null value in the column 'name'.


/* *************************
		NEXT QUESTION
        
*************************** */

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?

/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- My Approach

-- WITH top_three_genre
-- sub query to fetch data and join the tables one by one
-- We shall join movie, genre and ratings table to get filtered result where avg_rating >8

-- (We can use CTE to solve this problem)
USE imdb;
WITH cte1 AS
(
	SELECT g.genre, COUNT(g.movie_id) AS movie_count
	FROM genre AS g	INNER JOIN ratings AS r ON g.movie_id = r.movie_id
	WHERE avg_rating > 8
    GROUP BY genre
    ORDER BY movie_count desc
    LIMIT 3
),
cte2 AS
(
SELECT n.name AS director_name,
		COUNT(g.movie_id) AS movie_count,
        ROW_NUMBER() OVER(ORDER BY COUNT(g.movie_id) DESC) AS director_row_rank
FROM names AS n INNER JOIN director_mapping AS dm ON n.id = dm.name_id 
				INNER JOIN genre AS g ON dm.movie_id = g.movie_id 
				INNER JOIN ratings AS r ON r.movie_id = g.movie_id,
cte1
WHERE g.genre in (cte1.genre) AND avg_rating>8
GROUP BY director_name
ORDER BY movie_count DESC
)
SELECT director_name, movie_count
FROM cte2
WHERE director_row_rank <= 3;

-- Answer is James Mangold (4), Soubin Shahir(3), Joe Russo (3)


/* *************************
		NEXT QUESTION
        
*************************** */

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- My Approach 
-- We need to join tables movie, rating, role_mapping, and names
-- First we need to find movies with median rating >= 8
-- Then we need to get the actor name with associated movie counts

SELECT n.name AS actor_name, 
       COUNT(m.id) AS movie_count
FROM movie m 
		INNER JOIN ratings r ON m.id = r.movie_id
		     INNER JOIN role_mapping rm ON r.movie_id = rm.movie_id
                  INNER JOIN names n ON rm.name_id = n.id
WHERE r.median_rating >= 8
GROUP BY actor_name
ORDER BY movie_count desc
LIMIT 2;

-- Mohanlal is in second position with movie count of 5 having median rating >= 8

/* *************************
		NEXT QUESTION
        
*************************** */

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- My Approach

-- We need three columns production_company, total_votes, and vote_count
-- Let's perform JOIN on movie and ratings table 
-- We can order the result using sum of total_vote 

SELECT m.production_company, SUM(r.total_votes) as vote_count,
RANK() OVER(
    ORDER BY 
    SUM(r.total_votes) DESC
    ) prod_comp_rank
FROM movie as m
INNER JOIN ratings as r
ON m.id = r.movie_id
WHERE m.production_company IS NOT NULL -- m.production_company = 'Marvel studios'
GROUP BY production_company
LIMIT 3;
-- Marvel Studios, Twentieth Century Fox, Warner Bros Are in the 1st, 2nd, and 3rd position

/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/


/* *************************
		NEXT QUESTION
        
*************************** */

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- My Approach 
-- We need three important factors here, category = actor, country = 'India' and movie_count should be >= 5
-- We need to perform join on movie, ratings, role_mapping, and names
-- We also need to order and rank them as per the ratings

WITH cte AS 
(SELECT id AS actor_id, name AS actor_name,
        COUNT(known_for_movies) AS movie_count
FROM names n  
       INNER JOIN role_mapping rm ON n.id = rm.name_id
                                  AND category = 'actor'
GROUP BY name
HAVING COUNT(known_for_movies) >= 5
) 
SELECT cte.actor_name, SUM(r.total_votes) AS total_votes,
       COUNT(m.id) AS movie_count,
	   ROUND(SUM((avg_rating*total_votes))/SUM(total_votes),2) AS actor_avg_rating,
       RANK() OVER (ORDER BY ROUND(SUM((avg_rating*total_votes))/SUM(total_votes),2) DESC) AS actor_rank
FROM ratings r 
       INNER JOIN movie m ON m.id = r.movie_id
			INNER JOIN role_mapping rm ON rm.movie_id = m.id
				INNER JOIN cte ON cte.actor_id = rm.name_id
GROUP BY cte.actor_name;

-- Top actor is Vijay Sethupathi ,  Fahadh Faasil is in Second place


/* *************************
		NEXT QUESTION
        
*************************** */

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- My approach 
-- We need three important factors here, category = actress, country = 'India' and movie_count should be >= 3
-- We need to perform join on movie, ratings, role_mapping, and names
-- We also need to order and rank them as per the ratings and need only the top 5
WITH cte AS 
(SELECT id AS actor_id, name AS actor_name,
	    COUNT(known_for_movies) AS movie_count
FROM  names n 
       INNER JOIN role_mapping rm ON n.id = rm.name_id AND category = 'actress'
GROUP BY name
HAVING count(known_for_movies) >= 5
) 
SELECT cte.actor_name, SUM(r.total_votes) AS total_votes, COUNT(m.id) AS movie_count,
       ROUND(SUM((avg_rating*total_votes))/SUM(total_votes),2) AS actor_avg_rating,
       RANK() OVER (ORDER BY ROUND(SUM((avg_rating*total_votes))/SUM(total_votes),2) DESC) AS actor_rank
FROM ratings r 
        INNER JOIN movie m ON m.id = r.movie_id
			INNER JOIN role_mapping rm ON rm.movie_id = m.id
				INNER JOIN cte ON cte.actor_id = rm.name_id
GROUP BY cte.actor_name;

-- Taapsee Pannu tops with average rating 7.7



/* *************************
		NEXT QUESTION
        
*************************** */


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/


SELECT 
    m.title,
    r.avg_rating,
    CASE
        WHEN r.avg_rating < 5 THEN 'Flop'
        WHEN r.avg_rating >= 5 AND r.avg_rating < 7 THEN 'One-time-watch'
        WHEN r.avg_rating >= 7 AND r.avg_rating < 8 THEN 'Hit'
        WHEN r.avg_rating >= 8 THEN 'Superhit'
    END AS 'Final_Status'
FROM
    movie m
        INNER JOIN
    ratings r ON m.id = r.movie_id
        INNER JOIN
    genre g ON m.id = g.movie_id
WHERE
    g.genre = 'Thriller'
ORDER BY 2 DESC;
    

-- Total 39 no of superhit movies comes under genre 'Thriller'


/* *************************
		NEXT QUESTION
        
*************************** */

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- We'll use two windows, w1(running_total) one with unbounded preceding 
-- and w2(moving_avg) with 10 rows preceding


select
g.genre
,avg(duration) as avg_duration
,sum(avg(duration)) over w1 as running_total_duration
,avg(avg(duration)) over w2 as moving_avg_duration
from movie m inner join genre as g on m.id = g.movie_id
group by g.genre
window w1 as  (order by genre rows unbounded preceding),
	   w2 as   (order by genre rows 10 preceding)
ORDER BY g.genre;

-- Action genre has highest moving_avg_duration




/* *************************
		NEXT QUESTION
        
*************************** */

-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- My Approach 

-- One CTE to get each genre and total count genre wise
-- Second CTE to get genre, year realesed, movie name, ww_gross_incm by joining movie and genre table
-- Then get top 3 rank movies

-- Top 3 Genres based on most number of movies
WITH cte AS 
(
SELECT g.genre, COUNT(m.id) AS movie_count
FROM movie m 
     INNER JOIN genre g ON m.id = g.movie_id
GROUP BY genre
ORDER BY count(m.id) DESC
LIMIT 3
), 
 cte2 AS
(
SELECT g.genre, m.year, 
       m.title AS movie_name, m.worlwide_gross_income,
       DENSE_RANK() OVER (PARTITION BY m.year ORDER BY m.worlwide_gross_income DESC) AS movie_rank
FROM movie m 
	INNER JOIN genre g ON m.id = g.movie_id
WHERE g.genre IN (SELECT genre FROM cte)
)
SELECT DISTINCT * FROM cte2 WHERE movie_rank<=5;

-- In INR,  Shatamanam Bhavati is the movie with highest gross income world wide(2017)
-- In USD, Thank you for your service is the movie with highest gross income world wide(2017)


/* *************************
		NEXT QUESTION
        
*************************** */
-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/

-- My Approach
-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language

SELECT production_company, COUNT(m.id) AS movie_count,
       RANK() OVER (ORDER BY COUNT(m.id) DESC) AS prod_comp_rank
FROM movie m 
        INNER JOIN ratings r ON m.id = r.movie_id
WHERE languages regexp ','
      AND median_rating >=8
      AND production_company IS NOT NULL
GROUP BY production_company 
LIMIT  2;

-- The top 2 Production houses (Highest multi-lingual hits) are - Star Cinema and Twentieth Century Fox


/* *************************
		NEXT QUESTION
        
*************************** */

-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- My Approach 
-- Let's join name, movie, ratings, role_mapping tables.
-- We need to filter the data under category 'actress' first.
-- We can rank them using the avg_rating.
-- We want top 3 so we'll use Limit here as well.

SELECT  n.name AS actress_name, r.total_votes, COUNT(m.id) AS movie_count, r.avg_rating AS actress_avg_rating, 
-- dense_rank() OVER (PARTITION BY rm.category = 'actress' ORDER BY r.avg_rating DESC) AS actress_denserank 
/*Result contains multiple actress with 9.5 and 9.4 rating thats why we are using ROW_NUMBER instead*/
ROW_NUMBER() OVER (PARTITION BY rm.category = 'actress' ORDER BY r.avg_rating DESC) AS actress_rank
FROM  movie m INNER JOIN ratings r ON m.id = r.movie_id    
INNER JOIN role_mapping rm ON r.movie_id = rm.movie_id     
INNER JOIN names n ON n.id = rm.name_id          
WHERE rm.category = 'actress' 
GROUP BY actress_name
HAVING r.avg_rating > 8
ORDER BY actress_rank, r.avg_rating ASC
limit 3;

-- Sangeetha Bhat has secured the first place in the list with actress_avg_rating 9.6


/* *************************
		NEXT QUESTION
        
*************************** */

/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:

-- We can count the known_for_movies column from names table to get number of movies
-- We can take the round of avg rating from ratings table to get AVG(avg_ratings)
-- We are Unable to figure out value for "avg_inter_movie_days",skip. 
-- We can sum the total_votes
-- We can get MIN() and MAX() of avg_rating
-- We can calculate sum of total duration from movies table
-- We need to perform JOIN on Names, Ratings, Movie and director_mapping table
-- After this we can group by names  

SELECT DISTINCT dm.name_id AS director_id,
				n.name AS director_name,
                COUNT(n.known_for_movies) AS number_of_movies,
                -- Unable to figure out value for "avg_inter_movie_days",skip. 
                ROUND(AVG(r.avg_rating),2) AS avg_rating,
                SUM(r.total_votes) AS total_votes,
				MIN(r.avg_rating) AS min_rating,
                MAX(r.avg_rating) AS max_rating,
                SUM(m.duration) AS total_duration
FROM director_mapping dm 
         INNER JOIN names n ON dm.name_id = n.id
			INNER JOIN movie m ON dm.movie_id = m.id
				INNER JOIN ratings r ON r.movie_id = m.id
GROUP BY dm.name_id , n.name
ORDER BY 3 DESC
LIMIT 9;

-- The top 9 directors are Andrew Jones, A.L. Vijay, Sam Liu, Özgür Bakar, Justin Price, Onur Ünlü, Yûichi Fukuda, Danny J. Boyle, Johannes Roberts. 





