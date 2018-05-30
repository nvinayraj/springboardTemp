/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
A1: select name from Facilities where membercost <> 0;

/* Q2: How many facilities do not charge a fee to members? */
A2: select count(facid) from Facilities where membercost = 0;

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
A3: select facid, name, membercost, monthlymaintenance from Facilities where membercost <> 0 and membercost < (0.2 * monthlymaintenance);

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
A4: select * from Facilities where facid in (1,5);

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
A5: select name, monthlymaintenance, CASE 
WHEN monthlymaintenance > 100 THEN 'expensive'
WHEN monthlymaintenance <= 100 THEN 'cheap'
ELSE NULL 
END AS affordability from Facilities;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
A6: select firstname, surname AS lastname FROM Members where joindate = (select max(joindate) from Members);

/* Q7: How can you produce a list of all members who have used a tennis court? Include in your output the name of the court, and the name of the member formatted as a single column. Ensure no duplicate data, and order by the member name. */ 
A7: SELECT distinct F.name, concat(m.firstname,' ', m.surname) membername
FROM Bookings b
INNER JOIN Facilities F
INNER JOIN Members m
WHERE b.facid = F.facid
AND b.memid = m.memid
AND F.name
IN (
'Tennis Court 1',  'Tennis Court 2'
) order by membername;


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

A8: SELECT f.name, CONCAT (m.firstname, ' ', m.surname) AS membername, CASE m.firstname WHEN 'GUEST' THEN (f.guestcost * b.slots) ELSE (f.membercost * b.slots) END AS cost 
FROM Bookings b, Facilities f, Members m
WHERE DATE( b.starttime ) =  '2012-09-14'
AND b.facid = f.facid
AND b.memid = m.memid 
AND CASE m.firstname WHEN 'GUEST' THEN (f.guestcost * b.slots) ELSE (f.membercost * b.slots) END > 30 order by cost desc;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

A9: SELECT book_fac.name, CONCAT (m.firstname, ' ', m.surname) AS membername, CASE m.firstname WHEN 'GUEST' THEN (book_fac.guestcost * book_fac.slots) ELSE (book_fac.membercost * book_fac.slots) END AS cost 
FROM (select f.guestcost, f.membercost, b.slots, b.memid, b.facid, b.starttime, f.name from Bookings b, Facilities f where b.facid = f.facid)book_fac, Members m
WHERE DATE( book_fac.starttime ) =  '2012-09-14'
AND book_fac.memid = m.memid 
AND CASE m.firstname WHEN 'GUEST' THEN (book_fac.guestcost * book_fac.slots) ELSE (book_fac.membercost * book_fac.slots) END > 30 order by cost desc;

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

A10: SELECT f.name facility_name, sum(CASE m.firstname WHEN 'GUEST' THEN (f.guestcost * b.slots) ELSE (f.membercost * b.slots) END) AS revenue 
FROM Bookings b, Facilities f, Members m
WHERE b.facid = f.facid
AND b.memid = m.memid group by f.name having sum(CASE m.firstname WHEN 'GUEST' THEN (f.guestcost * b.slots) ELSE (f.membercost * b.slots) END) < 1000 order by revenue;
