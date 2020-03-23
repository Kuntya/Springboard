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
SELECT * FROM `Facilities` WHERE membercost>0

/* Q2: How many facilities do not charge a fee to members? */
SELECT count(*) FROM `Facilities` WHERE membercost=0

/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT `facid`, `name`, `membercost`, `monthlymaintenance` FROM `Facilities` 
where membercost>0 and 0.2*monthlymaintenance>membercost

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
SELECT * FROM `Facilities` 
where facid in (1,5)

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
SELECT `name`, `monthlymaintenance` ,
	case when  `monthlymaintenance`>100 then 'expensive'
	else 'cheap' end as price_label
FROM `Facilities` 


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
select `firstname`,`surname` FROM `Members` 
where `joindate`=(SELECT max(`joindate`) as max_date FROM `Members`)

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
SELECT FM.name as facility, M.fullname
from
(select F.name, B.memid from
	(SELECT `facid`, `name` FROM `Facilities` WHERE facid in (0,1)) F 
	left join
	(SELECT distinct `facid` ,`memid` FROM `Bookings`
		order by facid) B
	on F.facid=B.facid) FM
left join 
(select memid, CONCAT(surname,' ',firstname) as fullname  FROM `Members`) M
on FM.memid=M.memid
order by M.fullname

/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
select facs.name as facility, 
	CONCAT(mems.firstname,' ',mems.surname) as member, 
	case 
		when mems.memid = 0 then
			bks.slots*facs.guestcost
		else
			bks.slots*facs.membercost
	end as cost
        from
                Members mems                
                inner join Bookings bks
                        on mems.memid = bks.memid
                inner join Facilities facs
                        on bks.facid = facs.facid
        where
		bks.starttime >= '2012-09-14' and 
		bks.starttime < '2012-09-15' and (
			(mems.memid = 0 and bks.slots*facs.guestcost > 30) or
			(mems.memid != 0 and bks.slots*facs.membercost > 30)
		)
order by cost desc   
/* Q9: This time, produce the same result as in Q8, but using a subquery. */
select facility, member,  cost from (
	select 
		CONCAT(mems.firstname,' ',mems.surname) as member,
		facs.name as facility,
		case
			when mems.memid = 0 then
				bks.slots*facs.guestcost
			else
				bks.slots*facs.membercost
		end as cost
		from
			Members mems
			inner join Bookings bks
				on mems.memid = bks.memid
			inner join Facilities facs
				on bks.facid = facs.facid
		where
			bks.starttime >= '2012-09-14' and
			bks.starttime < '2012-09-15'
	) as bookings
	where cost > 30
order by cost desc;          

/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
select A.facility, sum(A.cost) as revenue
from
(select bks.bookid, facs.name as facility, 
	case 
		when mems.memid = 0 then
			bks.slots*facs.guestcost
		else
			bks.slots*facs.membercost
	end as cost
from
              	Members mems                
                inner join Bookings bks
                        on mems.memid = bks.memid
                inner join Facilities facs
                        on bks.facid = facs.facid)A
group by A.facility
having revenue<1000