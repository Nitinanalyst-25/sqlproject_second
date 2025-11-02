-- Q Creating the database named as Air Cargo Analysis
create database air_cargo_analysis;
use air_cargo_analysis;

-- Q1 ER Diagram -- pasted in LMS

-- Q2 create a route_details table 

create table route_details
(
route_id int primary key,
flight_num int check (flight_num between 1111 and 1160),
origin_airport char(5),
aircraft_id text,
distance_miles int check (distance_miles >0)
);

-- Q3 Write a query to display all the passengers (customers) who have 
-- travelled in routes 01 to 25.
-- Take data from the passengers_on_flights table.


select customer_id,aircraft_id,depart,arrival,seat_num,class_id,travel_date,flight_num
from passengers_on_flights
where 
route_id between 1 and 25;

-- Q4 Write a query to identify the number of passengers 
-- and total revenue in business class from the ticket_details table.

alter table ticket_details
add column total_revenue int;

Update ticket_details
set total_revenue=(no_of_tickets*Price_per_ticket);

select count(customer_id) as total_passengers, sum(total_revenue) from ticket_details
where class_id='Bussiness';

-- Q5.Write a query to display the full name of the customer by extracting 
-- the first name and last name from the customer table
select concat(first_name,' ',last_name) as Customer_name from customer;

-- Q6.Write a query to extract the customers who have registered and booked a ticket. 
-- Use data from the customer and ticket_details tables.
select cd.first_name,cd. last_name, cd.gender, td.aircraft_id, td.class_id, td.no_of_tickets,
td.a_code, td.brand
from customer as cd
inner join
ticket_details as td
on cd.customer_id=td.customer_id
order by cd.customer_id;

-- Q7. Write a query to identify the customer’s first name and last name based on their 
-- customer ID and brand (Emirates) from the ticket_details table.

select cd.customer_id, concat(cd.first_name,' ', cd.last_name) as customer_name,
td.brand
from customer as cd 
inner join
ticket_details as td
on cd.customer_id=td.customer_id
where td.brand='Emirates';

-- Q8. Write a query to identify the customers who have travelled 
-- by Economy Plus class using 
-- Group By and Having clause on the passengers_on_flights table. 

select cd.customer_id, concat(cd.first_name,' ',cd.last_name) as customer_name,pf.class_id
from customer as cd
inner join
passengers_on_flights as pf
on cd.customer_id=pf.customer_id
group by cd.customer_id, concat(cd.first_name,' ',cd.last_name),pf.class_id
having pf.class_id='Economy Plus';

-- Q9. Write a query to identify whether the revenue has crossed 10000 
-- using the IF clause on the ticket_details table

Select sum(total_revenue) as total_revenue_generated,
 if(sum(total_revenue)>10000,'Target revenue achieved','Target Revenue not achieved')
 as Revenue_Status
 from ticket_details;
 
 -- Q10. Write a query to create and grant access to 
 -- a new user to perform operations on a database. 
 
 create user 'new_user'@'localhost' identified by 'password123';
 grant all privileges on my_database.* to 'new_user'@'localhost';
 
 -- Q11. Write a query to find the maximum ticket price for each 
 -- class using window functions on the ticket_details table. 
 select class_id,price_per_ticket,
 max(price_per_ticket) over (partition by class_id) as max_price_per_class
FROM ticket_details;
 
 -- Q12. Write a query to extract the passengers whose route ID is 4 by improving the speed
 -- and performance of the passengers_on_flights table.
  create index index_first on passengers_on_flights(route_id);
  select concat(cd.first_name,' ',cd.last_name) as customer_name, pf.aircraft_id,
  pf.depart, pf.arrival, pf.seat_num, pf.class_id, pf.travel_date,pf.flight_num
from customer as cd
inner join
passengers_on_flights as pf
on cd.customer_id=pf.customer_id
where pf.route_id=4;


-- Q13. For the route ID 4, write a query 
-- to view the execution plan of the passengers_on_flights table.

Explain select * from passengers_on_flights where route_id=4;

-- Q14.Write a query to calculate the total price of all tickets booked by a 
-- customer across different aircraft IDs using rollup function. 

 select td.customer_id,td.aircraft_id, sum(td.total_revenue) as total_price
 from ticket_details td
 group by td.customer_id, td.aircraft_id with rollup;
 



-- Q15. 15.	Write a query to create a view with only 
-- business class customers along with the brand of airlines. 

create or replace view  view_one
as
select concat(cd.first_name,' ',cd.last_name) as customer_name, td.class_id, td.brand
from customer as cd
inner join
ticket_details as td
on cd.customer_id=td.customer_id
where td.class_id='Bussiness';

select * from view_one;

-- Q16 Write a query to create a stored procedure to
-- get the details of all passengers flying between a range of routes defined in run time.
-- Also, return an error message if the table doesn't exist.
USE `air_cargo_analysis`;
DROP procedure IF EXISTS `procedure_one`;

DELIMITER $$
USE `air_cargo_analysis`$$
CREATE PROCEDURE `procedure_one` (a1 int,b1 int)
BEGIN
 select cd.customer_id,concat(cd.first_name,' ',cd.last_name) as customer_name, cd.gender,pf.aircraft_id,pf.route_id, pf.depart,pf.arrival,pf.seat_num,pf.class_id,pf.travel_date,pf.flight_num
 from customer as cd
 inner join
 passengers_on_flights as pf
 on cd.customer_id=pf.customer_id
where pf.route_id between a1 and b1;
END$$

DELIMITER ;

drop procedure procedure_one;

-- creating procedure 1 with no checking condition of table
USE `air_cargo_analysis`;
DROP procedure IF EXISTS `procedure_1`;

DELIMITER $$
USE `air_cargo_analysis`$$
CREATE PROCEDURE `procedure_1` (a1 int, b1 int)
BEGIN
 select cd.customer_id,concat(cd.first_name,' ',cd.last_name) as customer_name, cd.gender,pf.aircraft_id,pf.route_id, pf.depart,pf.arrival,pf.seat_num,pf.class_id,pf.travel_date,pf.flight_num
 from customer as cd
 inner join
 passengers_on_flights as pf
 on cd.customer_id=pf.customer_id
where pf.route_id between a1 and b1;
END$$

DELIMITER ;

call procedure_1(4,43);
 -- creating procedure two to check whether table exists or not and return the required output
 
 
 USE `air_cargo_analysis`;
DROP procedure IF EXISTS `procedure_two`;

DELIMITER $$
USE `air_cargo_analysis`$$
CREATE PROCEDURE `procedure_two` (a1 int, b1 int)
BEGIN
 declare table_exists int;
 select count(*) into table_exists
 from information_schema.tables
 where table_name='passengers_on_flights'and table_schema=database();
 
 if table_exists=0 then
 signal sqlstate '45000'
 set message_text='Error: Table doesn\'t exists';
 else
 select cd.customer_id,concat(cd.first_name,' ',cd.last_name) as customer_name, cd.gender,pf.aircraft_id,pf.route_id, pf.depart,pf.arrival,pf.seat_num,pf.class_id,pf.travel_date,pf.flight_num
 from customer as cd
 inner join
 passengers_on_flights as pf
 on cd.customer_id=pf.customer_id
where pf.route_id between a1 and b1;
end if;
END$$

DELIMITER ;

call procedure_two(2,30);

-- Q17.Write a query to create a stored procedure
-- that extracts all the details from the routes table
 -- where the travelled distance is more than 2000 miles.
 USE `air_cargo_analysis`;
DROP procedure IF EXISTS `procedure_three`;

DELIMITER $$
USE `air_cargo_analysis`$$
CREATE PROCEDURE `procedure_three` (a1 int)
BEGIN
select * from routes
where distance_miles>a1;
END$$

DELIMITER ;

call procedure_three(2000);

-- Q18.Write a query to create a stored procedure that
 -- groups the distance travelled by each flight into three categories.
--  The categories are, short distance travel (SDT) for >=0 AND <= 2000 miles, intermediate
 -- distance travel (IDT) for >2000 AND <=6500, and long-distance travel (LDT) for >6500.
 
USE `air_cargo_analysis`;
DROP procedure IF EXISTS `procedure_4`;

DELIMITER $$
USE `air_cargo_analysis`$$
CREATE PROCEDURE `procedure_4` ()
BEGIN
select *,
case
 when distance_miles >=0 and distance_miles <=2000 then 'short distance travel (SDT)'
 when distance_miles>2000 and distance_miles<=6500 then 'intermediate distance travel (IDT)'
 when distance_miles>6500 then 'long-distance travel (LDT)'
 else 'Invalid Case'
 end as Distance_Category
 from routes;
END$$

DELIMITER ;

call procedure_4;

-- Q19.Write a query to extract ticket purchase date, 
-- customer ID, class ID and specify if the complimentary services
-- are provided for the specific class using a stored function in
 -- stored procedure on the ticket_details table. 
-- Condition: 
-- If the class is Business and Economy Plus, 
-- then complimentary services are given as Yes, else it is No
USE `air_cargo_analysis`;
DROP procedure IF EXISTS `procedure_5`;

DELIMITER $$
USE `air_cargo_analysis`$$
CREATE PROCEDURE `procedure_5` ()
BEGIN
 select p_date as ticket_purchase_date, customer_id, class_id,
 case
  when class_id='Bussiness' then 'Yes'
  when class_id='Economy Plus' then 'Yes'
  else 'No'
  end as Complimentary_Services
  from ticket_details;
  END$$

DELIMITER ;

call procedure_5;










 
 
 
 
 
 






