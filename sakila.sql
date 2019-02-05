use sakila;
#1a. Display the first and last names of all actors from the table actor.
SELECT 
    first_name, last_name
FROM
    actor;
#----------------------------------------------------------------------
#1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT 
    UPPER(CONCAT(first_name, ' ', last_name)) AS 'Actor Name'
FROM
    actor;
#----------------------------------------------------------------------
#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
#What is one query would you use to obtain this information?
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    first_name = 'Joe';
#----------------------------------------------------------------------
#2b. Find all actors whose last name contain the letters GEN:
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    last_name LIKE '%GEN%';
#----------------------------------------------------------------------
#2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT 
    actor_id, first_name, last_name
FROM
    actor
WHERE
    last_name LIKE '%LI%'
ORDER BY last_name , first_name;
#----------------------------------------------------------------------
#2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT 
    country_id, country
FROM
    country
WHERE
    country IN ('Afghanistan' , 'Bangladesh', 'China');
#----------------------------------------------------------------------
#3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
#TEXT and BLOB is stored off the table with the table just having a pointer to the location of the actual storage.
#VARCHAR is stored inline with the table.
ALTER TABLE actor
ADD COLUMN description blob;

select * from actor;
#----------------------------------------------------------------------
#3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP COLUMN description;
#----------------------------------------------------------------------
#4a. List the last names of actors, as well as how many actors have that last name.
SELECT 
    last_name, COUNT(*) AS lastname_count
FROM
    actor
GROUP BY last_name;
#----------------------------------------------------------------------
#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT 
    last_name, COUNT(*) AS number_lastname
FROM
    actor
GROUP BY last_name
having number_lastname>=2;
#----------------------------------------------------------------------
#4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor 
SET 
    first_name = 'HARPO'
WHERE
    first_name = 'GROUCHO'
        AND last_name = 'WILLIAMS';
#----------------------------------------------------------------------
#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor 
SET 
    first_name = 'GROUCHO'
WHERE
    first_name = 'HARPO'
        AND last_name = 'WILLIAMS';
#----------------------------------------------------------------------
#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
#Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE address;
#----------------------------------------------------------------------
#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT 
    s.first_name, s.last_name, a.*
FROM
    staff s
        LEFT JOIN
    address a ON s.address_id = a.address_id;
#----------------------------------------------------------------------
#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT 
    s.first_name, s.last_name, sum(p.amount) as total_Amount
FROM
    staff s
        LEFT JOIN
    payment p ON s.staff_id = p.staff_id
where month(p.payment_date)=8 and year(p.payment_date)=2005
group by p.staff_id;
#----------------------------------------------------------------------
#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT 
    f.title,count(fa.actor_id) as  number_of_actors
FROM
    film_actor fa
        inner JOIN
    film f ON f.film_id = fa.film_id
group by fa.film_id;
#----------------------------------------------------------------------
#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT 
    f.title,count(i.inventory_id) as number_copies
FROM
     inventory i
        left JOIN
    film f ON i.film_id = f.film_id
where f.title='Hunchback Impossible';
#----------------------------------------------------------------------
#6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
#List the customers alphabetically by last name:
SELECT 
    c.first_name, c.last_name, sum(p.amount) as 'total paid by customer'
FROM
payment as p
left join 
customer as c on 
	p.customer_id= c.customer_id
group by p.customer_id
ORDER BY c.last_name;
#----------------------------------------------------------------------
#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
#films starting with the letters K and Q have also soared in popularity. 
#Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT 
    title
FROM
    film
WHERE
    title LIKE 'K%'
        OR title LIKE 'Q%'
        AND language_id IN (SELECT language_id FROM language WHERE name = 'English');
#----------------------------------------------------------------------
#7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT 
    *
FROM
    actor
WHERE
    actor_id IN (SELECT 
            actor_id
        FROM
            film_actor
        WHERE
            film_id IN (SELECT 
                    film_id
                FROM
                    film
                WHERE
                    title = 'Alone Trip'));
#----------------------------------------------------------------------
#7c. You want to run an email marketing campaign in Canada, for which you will need 
#the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT 
    c.customer_id,c.first_name, c.last_name,c.email
FROM
     customer c
        LEFT JOIN
    address a ON c.address_id = a.address_id
			LEFT JOIN
				city ci ON a.city_id = ci.city_id
					LEFT JOIN
						country co ON ci.country_id = co.country_id
    where co.country='Canada';
#---------------------------------------------------------------------- 
#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
# Identify all movies categorized as family films.
SELECT 
    f.title,ca.name as categoryName
FROM
    film_category  fc
        LEFT JOIN
    film f ON fc.film_id = f.film_id
			LEFT JOIN
				category ca ON fc.category_id = ca.category_id
    where ca.name='family';
#---------------------------------------------------------------------- 
#7e. Display the most frequently rented movies in descending order.
SELECT 
    f.title, COUNT(*) AS rented
FROM
    payment p
        JOIN
    rental r USING (rental_id)
        JOIN
    inventory i USING (inventory_id)
        JOIN
    film f USING (film_id)
GROUP BY f.film_id
ORDER BY rented DESC;
#---------------------------------------------------------------------- 
#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT 
    s.store_id, SUM(amount) AS gross
FROM
    payment p
        JOIN
    rental r USING (rental_id)
        JOIN
    inventory i USING (inventory_id)
        JOIN
    store s USING (store_id)
GROUP BY s.store_id;   
#---------------------------------------------------------------------- 
#7g. Write a query to display for each store its store ID, city, and country.
SELECT 
    s.store_id,ci.city,co.country
FROM
     store s
        LEFT JOIN
    address a ON s.address_id = a.address_id
			LEFT JOIN
				city ci ON a.city_id = ci.city_id
					LEFT JOIN
						country co ON ci.country_id = co.country_id;
#---------------------------------------------------------------------- 
#7h. List the top five genres in gross revenue in descending order.
# (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

#Top movies in gross revenue in descending order.
SELECT 
    f.title,c.name, SUM(p.amount) AS total_gross
FROM
    payment p
        LEFT JOIN
    rental r ON p.rental_id = r.rental_id
		LEFT JOIN
    inventory i ON r.inventory_id = i.inventory_id
		LEFT JOIN
      film_category AS fc ON i.film_id = fc.film_id
        LEFT JOIN
    category AS c ON fc.category_id = c.category_id
		LEFT JOIN
	film AS f ON fc.film_id = f.film_id
GROUP BY i.film_id
ORDER BY total_gross DESC
LIMIT 5;
#---------------------------------------------------------------------- 
#List the top five genres in gross revenue in descending order.
SELECT 
    c.name, SUM(p.amount) AS total_gross
FROM
    payment p
        LEFT JOIN
    rental r ON p.rental_id = r.rental_id
        LEFT JOIN
    inventory i ON r.inventory_id = i.inventory_id
        LEFT JOIN
    film_category AS fc ON i.film_id = fc.film_id
        LEFT JOIN
    category AS c ON fc.category_id = c.category_id
GROUP BY fc.category_id
ORDER BY total_gross DESC
LIMIT 5;
#----------------------------------------------------------------------
#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue.
# Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Top_Five_Genres_in_gross_revenue AS 
SELECT 
    c.name, SUM(p.amount) AS total_gross
FROM
    payment p
        LEFT JOIN
    rental r ON p.rental_id = r.rental_id
        LEFT JOIN
    inventory i ON r.inventory_id = i.inventory_id
        LEFT JOIN
    film_category AS fc ON i.film_id = fc.film_id
        LEFT JOIN
    category AS c ON fc.category_id = c.category_id
GROUP BY fc.category_id
ORDER BY total_gross DESC
LIMIT 5;
#----------------------------------------------------------------------
#8b. How would you display the view that you created in 8a?
SELECT * FROM Top_Five_Genres_in_gross_revenue;
#----------------------------------------------------------------------
#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW Top_Five_Genres_in_gross_revenue;
#----------------------------------------------------------------------