/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, and revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */

SELECT name
FROM Facilities
WHERE membercost !=0

/*Answer:
name
Tennis Court 1
Tennis Court 2
Massage Room 1
Massage Room 2
Squash Court
*/

/* Q2: How many facilities do not charge a fee to members? */

SELECT COUNT( name ) AS "Free facilities"
FROM Facilities
WHERE membercost = 0

/*Answer:
Free facilities
4
*/

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */

SELECT facid, name, membercost, monthlymaintenance
FROM Facilities
WHERE membercost !=0
AND membercost < ( monthlymaintenance * .20 )

/*Answer:
facid  name            membercost   monthlymaintenance
0      Tennis Court 1  5.0          200
1      Tennis Court 2  5.0          200
4      Massage Room 1  9.9          3000
5      Massage Room 2  9.9          3000
6      Squash Court    3.5          80
*/

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

SELECT *
FROM Facilities
WHERE facid
IN ( 1, 5 )

/*Answer:
facid  name              membercost    guestcost    initialoutlay    monthlymaintenance
1      Tennis Court 2    5.0           25.0         8000             200
5      Massage Room      29.9          80.0         4000             3000
*/

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

SELECT name, monthlymaintenance,
CASE
    WHEN monthlymaintenance >100
        THEN 'expensive'
    ELSE 'cheap'
END AS cost
FROM `Facilities`

/*Answer:
name              monthlymaintenance   cost
Tennis Court 1    200                  expensive
Tennis Court 2    200                  expensive
Badminton Court   50                   cheap
Table Tennis      10                   cheap
Massage Room 1    3000                 expensive
Massage Room 2    3000                 expensive
Squash Court      80                   cheap
Snooker Table     15                   cheap
Pool Table        15                   cheap
*/

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

SELECT firstname, surname
FROM Members
WHERE joindate = (
    SELECT MAX( joindate )
    FROM Members )

/*Answer:
firstname   surname
Darren      Smith
*/

/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT f.name AS facility_name, 
m.surname || ', ' || m.firstname AS member_name
FROM Facilities AS f
INNER JOIN Bookings AS b USING ( facid )
INNER JOIN Members AS m USING ( memid )
WHERE 
    f.name LIKE 'Tennis Court%' AND member_name <> 'GUEST, GUEST'
ORDER BY 
    member_name, facility_name
LIMIT 0 , 20

/*Answer:
	facility_name	member_name
0	Tennis Court 1	Bader, Florence
1	Tennis Court 2	Bader, Florence
2	Tennis Court 1	Baker, Anne
3	Tennis Court 2	Baker, Anne
4	Tennis Court 1	Baker, Timothy
5	Tennis Court 2	Baker, Timothy
6	Tennis Court 1	Boothe, Tim
7	Tennis Court 2	Boothe, Tim
8	Tennis Court 1	Butters, Gerald
9	Tennis Court 2	Butters, Gerald
10	Tennis Court 1	Coplin, Joan
11	Tennis Court 1	Crumpet, Erica
12	Tennis Court 1	Dare, Nancy
13	Tennis Court 2	Dare, Nancy
14	Tennis Court 1	Farrell, David
15	Tennis Court 2	Farrell, David
16	Tennis Court 1	Farrell, Jemima
17	Tennis Court 2	Farrell, Jemima
18	Tennis Court 1	Genting, Matthew
19	Tennis Court 1	Hunt, John
*/

/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

SELECT f.name AS facility_name, m.surname || ', ' || m.firstname AS member_name,
CASE
    WHEN b.memid >0
        THEN f.membercost * b.slots
    ELSE f.guestcost * b.slots
END AS cost
FROM Facilities AS f
JOIN Bookings AS b USING ( facid )
JOIN Members AS m USING ( memid )
WHERE 
    DATE( b.starttime ) = '2012-09-14' AND cost >30
ORDER BY cost DESC

/*Answer:
    facility_name	member_name	    cost
0	Massage Room 2	GUEST, GUEST	320.0
1	Massage Room 1	GUEST, GUEST	160.0
2	Massage Room 1	GUEST, GUEST	160.0
3	Massage Room 1	GUEST, GUEST	160.0
4	Tennis Court 2	GUEST, GUEST	150.0
5	Tennis Court 1	GUEST, GUEST	75.0
6	Tennis Court 1	GUEST, GUEST	75.0
7	Tennis Court 2	GUEST, GUEST	75.0
8	Squash Court	GUEST, GUEST	70.0
9	Massage Room 1	Farrell, Jemima	39.6
10	Squash Court	GUEST, GUEST	35.0
11	Squash Court	GUEST, GUEST	35.0
*/

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT facility_name, member_name, cost
FROM (

SELECT f.name AS facility_name, m.surname || ', ' || m.firstname AS member_name,
CASE
    WHEN b.memid >0
        THEN f.membercost * b.slots
    ELSE f.guestcost * b.slots
END AS cost
FROM Facilities AS f
JOIN Bookings AS b USING ( facid )
JOIN Members AS m USING ( memid )
WHERE DATE( b.starttime ) = '2012-09-14'
) AS subquery

WHERE cost >30
ORDER BY cost DESC'

/*Answer:
    facility_name	member_name	    cost
0	Massage Room 2	GUEST, GUEST	320.0
1	Massage Room 1	GUEST, GUEST	160.0
2	Massage Room 1	GUEST, GUEST	160.0
3	Massage Room 1	GUEST, GUEST	160.0
4	Tennis Court 2	GUEST, GUEST	150.0
5	Tennis Court 1	GUEST, GUEST	75.0
6	Tennis Court 1	GUEST, GUEST	75.0
7	Tennis Court 2	GUEST, GUEST	75.0
8	Squash Court	GUEST, GUEST	70.0
9	Massage Room 1	Farrell, Jemima	39.6
10	Squash Court	GUEST, GUEST	35.0
11	Squash Court	GUEST, GUEST	35.0
*/

/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */

SELECT facility_name, SUM(revenue) AS total_revenue
FROM (
SELECT f.name AS facility_name,
CASE
    WHEN b.memid >0
        THEN f.membercost * b.slots
    ELSE f.guestcost * b.slots
END AS revenue
FROM Facilities f
JOIN Bookings b USING(facid)
) AS subq
GROUP BY subq.facility_name
HAVING total_revenue < 1000
ORDER BY total_revenue

/*Answer:
    facility_name	total_revenue
0	Table Tennis	180
1	Snooker Table	240
2	Pool Table	    270
*/

/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */

SELECT m1.memid, m1.surname, m1.firstname, m1.recommendedby AS recommendedby_id, 
m2.surname || ', ' || m2.firstname AS recommendedby_name
FROM Members AS m1
LEFT JOIN Members AS m2 
ON m1.recommendedby = m2.memid
WHERE m1.memid > 0 
ORDER BY m1.surname, m1.firstname

/*Answer:
	memid	surname	firstname	recommendedby_id	recommendedby_name
0	15	    Bader	Florence	9	Stibbons, Ponder
1	12	    Baker	Anne	    9	Stibbons, Ponder
2	16	    Baker	Timothy	13	Farrell, Jemima
3	8	    Boothe	Tim	3	Rownam, Tim
4	5	Butters	Gerald	1	Smith, Darren
5	22	Coplin	Joan	16	Baker, Timothy
6	36	Crumpet	Erica	2	Smith, Tracy
7	7	Dare	Nancy	4	Joplette, Janice
8	28	Farrell	David		None
9	13	Farrell	Jemima		None
10	20	Genting	Matthew	5	Butters, Gerald
11	35	Hunt	John	30	Purview, Millicent
12	11	Jones	David	4	Joplette, Janice
13	26	Jones	Douglas	11	Jones, David
14	4	Joplette	Janice	1	Smith, Darren
15	21	Mackenzie	Anna	1	Smith, Darren
16	10	Owen	Charles	1	Smith, Darren
17	17	Pinker	David	13	Farrell, Jemima
18	30	Purview	Millicent	2	Smith, Tracy
19	3	Rownam	Tim		None
20	27	Rumney	Henrietta	20	Genting, Matthew
21	24	Sarwin	Ramnaresh	15	Bader, Florence
22	1	Smith	Darren		None
23	37	Smith	Darren		None
24	14	Smith	Jack	1	Smith, Darren
25	2	Smith	Tracy		None
26	9	Stibbons	Ponder	6	Tracy, Burton
27	6	Tracy	Burton		None
28	33	Tupperware	Hyacinth		None
29	29	Worthington-Smyth	Henry	2	Smith, Tracy
*/

/* Q12: Find the facilities with their usage by member, but not guests */

SELECT f.name AS facility_name, m.surname || ', ' || m.firstname AS member_name,
sum(b.slots) AS usage_in_30_min_time_slots 
FROM Facilities AS f
JOIN Bookings AS b USING ( facid )
JOIN Members AS m USING ( memid )
WHERE m.memid > 0
GROUP BY member_name

/*Answer:
    facility_name	member_name	usage_in_30_min_time_slots
0	Badminton Court	Bader, Florence	237
1	Tennis Court 1	Baker, Anne	296
2	Tennis Court 2	Baker, Timothy	290
3	Tennis Court 2	Boothe, Tim	440
4	Tennis Court 1	Butters, Gerald	409
5	Snooker Table	Coplin, Joan	106
6	Badminton Court	Crumpet, Erica	17
7	Badminton Court	Dare, Nancy	267
8	Tennis Court 1	Farrell, David	50
9	Table Tennis	Farrell, Jemima	180
10	Massage Room 2	Genting, Matthew	131
11	Tennis Court 1	Hunt, John	40
12	Tennis Court 2	Jones, David	305
13	Badminton Court	Jones, Douglas	37
14	Massage Room 1	Joplette, Janice	326
15	Badminton Court	Mackenzie, Anna	231
16	Tennis Court 1	Owen, Charles	345
17	Snooker Table	Pinker, David	159
18	Badminton Court	Purview, Millicent	32
19	Massage Room 1	Rownam, Tim	660
20	Snooker Table	Rumney, Henrietta	38
21	Tennis Court 2	Sarwin, Ramnaresh	153
22	Table Tennis	Smith, Darren	685
23	Massage Room 1	Smith, Jack	219
24	Tennis Court 1	Smith, Tracy	435
25	Tennis Court 2	Stibbons, Ponder	249
26	Tennis Court 2	Tracy, Burton	366
27	Snooker Table	Tupperware, Hyacinth	28
28	Badminton Court	Worthington-Smyth, Henry	60
*/

/* Q13: Find the facilities usage by month, but not guests */

SELECT f.name AS facility_name, 
    CASE strftime('%m', b.starttime)
        when '01' then 'January' 
        when '02' then 'Febuary' 
        when '03' then 'March' 
        when '04' then 'April' 
        when '05' then 'May' 
        when '06' then 'June' 
        when '07' then 'July' 
        when '08' then 'August' 
        when '09' then 'September' 
        when '10' then 'October' 
        when '11' then 'November' 
        when '12' then 'December' 
        else ''
    END AS month,
    SUM(b.slots) AS usage_in_30_min_time_slots
FROM Facilities AS f
JOIN Bookings AS b USING(facid)
JOIN Members AS m USING(memid)
WHERE memid > 0
GROUP BY facility_name, month
ORDER BY usage_in_30_min_time_slots DESC

/*Answer:
    facility_name	month	usage_in_30_min_time_slots
0	Badminton Court	September	507
1	Pool Table	September	443
2	Tennis Court 1	September	417
3	Badminton Court	August	414
4	Tennis Court 2	September	414
5	Snooker Table	September	404
6	Massage Room 1	September	402
7	Table Tennis	September	400
8	Tennis Court 2	August	345
9	Tennis Court 1	August	339
10	Massage Room 1	August	316
11	Snooker Table	August	316
12	Pool Table	August	303
13	Table Tennis	August	296
14	Tennis Court 1	July	201
15	Squash Court	August	184
16	Squash Court	September	184
17	Massage Room 1	July	166
18	Badminton Court	July	165
19	Snooker Table	July	140
20	Tennis Court 2	July	123
21	Pool Table	July	110
22	Table Tennis	July	98
23	Squash Court	July	50
24	Massage Room 2	September	28
25	Massage Room 2	August	18
26	Massage Room 2	July	8
*/


