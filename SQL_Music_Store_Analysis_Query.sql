/* Q1: Who is the senior most employee based on job title? */
SELECT title, first_name, last_name
FROM employee
ORDER BY levels DESC
LIMIT 1;


/* Q2: Which countries have the most Invoices? */
SELECT COUNT(*) AS ci, billing_country
FROM invoice
GROUP BY billing_country
ORDER BY ci DESC;

/* Q3: What are top 3 values of total invoice? */
SELECT total 
FROM invoice
ORDER BY total DESC

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city
we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */
SELECT billing_city, SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT customer.customer_id, first_name, last_name, SUM(total) AS TotalSpending
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
GROUP BY customer.customer_id, first_name, last_name
ORDER BY TotalSpending DESC
LIMIT 1;


/* Q6: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

SELECT DISTINCT c.email, c.first_name, c.last_name
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
WHERE il.track_id IN (
	SELECT t.track_id FROM track t
	JOIN genre g ON t.genre_id = g.genre_id
	WHERE g.name LIKE 'Rock'
)
ORDER BY c.email;

/* Method 2 */

SELECT DISTINCT email AS Email,first_name AS FirstName, last_name AS LastName, genre.name AS Name
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoiceline ON invoiceline.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoiceline.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;

/* Q7: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;

/* Q8: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
SELECT name, milliseconds
FROM track
WHERE milliseconds > (
    SELECT AVG(milliseconds) AS song_length
    FROM track
)
ORDER BY milliseconds DESC;


/* Q9: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name
and total spent */

with best_selling_artist as (
	select  artist.artist_id AS artist_id, artist.name AS artist_name, sum(invoice_line.unit_price*invoice_line.quantity) as Total_sales
	from invoice_line
	join track on track.track_id = invoice_line.track_id
	join album on album.album_id = track.album_id
	join artist on artist.artist_id = album.artist_id
	GROUP by 1
	order by 3 desc
	LIMIT 1
)
select c.customer_id, c.first_name , c.last_name, bsa.artist_name,sum(il.unit_price*il.quantity) as amount_spent
from invoice i
join customer c on c.customer_id = i.customer_id
join invoice_line il on il.invoice_id = i.invoice_id
join track t on t.track_id = il.track_id
join album alb on alb.album_id = t.album_id
join best_selling_artist bsa on bsa.artist_id = alb.artist_id
group by 1,2,3,4
order by 5 DESC;

/* Q10: We want to find out the most popular music Genre for each country. We determine the most popular genre
as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. 
For countries where 
the maximum number of purchases is shared return all Genres. */
with popular_genre as (
	select count(invoice_line.quantity) as purchase ,customer.country, genre.genre_id, genre.name,
    row_number() over(PARTITION by customer.country order by count(invoice_line.quantity)DESC) as rowno
	from invoice_line
	join invoice on invoice.invoice_id = invoice_line.invoice_id
	join customer on customer.customer_id = invoice.customer_id
	join track on track.track_id = invoice_line.track_id
	join genre on genre.genre_id = track.genre_id
	group by 2,3,4
	order by 2 ASC, 3 desc	
	
)
SELECT * FROM popular_genre WHERE RowNo <= 1

/* Q11: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */
with Customter_with_country as (
	SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	row_number() over(PARTITION by billing_country order by sum(total) DESC) AS RowNo
	from invoice
	join customer on customer.customer_id = invoice.customer_id
	group by 1,2,3,4
	ORDER BY 4 ASC,5 DESC
)
SELECT * FROM Customter_with_country WHERE RowNo <= 1