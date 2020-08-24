create Database Airport

use Airport

Create table Planes(
Id int Primary Key Identity,
[Name] nvarchar(30) NOT NULL,
Seats int NOT NULL,
[Range] int NOT NULL,
)

Create table Flights(
Id int Primary Key Identity,
DepartureTime datetime2,
ArrivalTime datetime2,
Origin nvarchar(50) NOT NULL,
Destination nvarchar(50) NOT NULL,
PlaneId int references Planes(Id) NOT NULL
)

Create table Passengers(
Id int Primary Key Identity,
[FirstName] nvarchar(30) NOT NULL,
[LastName] nvarchar(30) NOT NULL,
Age int NOT NULL,
Address nvarchar(30) NOT NULL,
PassportId varchar(11) NOT NULL
)

Create table LuggageTypes(
Id int Primary Key Identity,
[Type] nvarchar(30) NOT NULL
)

Create table Luggages(
Id int Primary Key Identity,
LuggageTypeId int references LuggageTypes(Id) NOT NULL,
PassengerId int references Passengers(Id) NOT NULL
)

Create table Tickets(
Id int Primary Key Identity,
PassengerId int references Passengers(Id) NOT NULL,
FlightId int references Flights(Id) NOT NULL,
LuggageId int references Luggages(Id) NOT NULL,
Price decimal(12,2) NOT NULL
)


INSERT INTO Planes ([Name], Seats, [Range]) VALUES
('Airbus 336',	112, 5132),
('Airbus 330',	432, 5325),
('Boeing 369',	231, 2355),
('Stelt 297',	254, 2143),
('Boeing 338',	165, 5111),
('Airbus 558',	387, 1342),
('Boeing 128',	345, 5541)

INSERT INTO LuggageTypes(Type) VALUES
('Crossbody Bag'),
('School Backpack'),
('Shoulder Bag')

select * from Tickets as t
join Flights as f ON f.Id = t.FlightId
where Destination = 'Ayn Halagim' 

Update Tickets
SET Price = Price* 1.13
where FlightId = 41

--4--
delete from Tickets
where FlightId = 30

delete from Flights
where Destination = 'Ayn Halagim' 

--5--

select Id, Name, Seats, Range from Planes
where Name like '%tr%'
Order by Id, Name, Seats, Range 

--6--

select 
FlightId, 
SUM(Price) AS Price
from Flights as f
join tickets as t ON t.FlightId = f.id
group by FlightId
Order by Price DESC , FlightId

--7--
select 
p.FirstName + ' ' + p.LastName AS [Full Name],
Origin,
Destination
from Passengers as p
join tickets as t ON  t.PassengerId = p.Id
join Flights as f ON f.Id = t.FlightId
order by [Full Name], Origin, Destination

--Select the full name of the passengers with their trips (origin - destination). Order them by full name (ascending), origin (ascending) and destination (ascending).

--8--

select FirstName, LastName, Age
from Passengers as p
left join tickets as t ON  t.PassengerId = p.Id
where Price is null
Order by Age DESC,FirstName, LastName

--Select all people who don't have tickets. Select their first name, last name and age .Order them by age (descending), first name (ascending) and last name (ascending).

--9--

select FirstName+ ' ' + LastName AS [Full Name], 
pl.Name AS [Plane Name],
Origin + ' - ' + Destination AS [Trip],
lt.Type AS [Luggage Type]
from Passengers as p
join tickets as t ON  t.PassengerId = p.Id
join Flights as f ON f.Id = t.FlightId
Join Planes as pl ON pl.Id = f.PlaneId
join Luggages as l ON l.Id = t.LuggageId
join LuggageTypes as lt ON lt.Id = l.LuggageTypeId 

Order by [Full Name],Name,Origin, Destination, Type
-- Order the results by full name (ascending), name (ascending), origin (ascending), destination (ascending) and luggage type (ascending).

--10--

select 
Name,
Seats,
count(Price) AS [Passengers Count]

from Planes as p
left join Flights as f ON p.Id = f.PlaneId
left join tickets as t ON  t.FlightId = f.Id
group by Name, Seats
order by [Passengers Count] DESC, Name, Seats

--Select all planes with their name, seats count and passengers count. Order the results by passengers count (descending), plane name (ascending) and seats (ascending) 

select p.Name, Count(*)
from Planes as p
left join Flights as f ON p.Id = f.PlaneId
left join tickets as t ON  t.FlightId = f.Id
group by p.Name
-- left join adds nulls which are then counted by the Count() 
-- whereas judge is looking for zeroes --> Solution - pass argument to account that is a column that has the nulls. Count ignores nulls.

--11--
create alter function udf_CalculateTickets
(@origin nvarchar(50), @destination nvarchar(50), @peopleCount int) 

returns nvarchar(100)
begin
		if(@peopleCount<=0)
		return 'Invalid people count!'

		if(
			(select Count(*) from Flights
			where Origin = @origin AND Destination = @destination)!=1)
		return 'Invalid flight!'
	
	Declare @price decimal(10,2)

	Set @price = @peopleCount *
					(select t.Price from Flights as f
					join Tickets as t ON t.FlightId=f.Id
					where Origin = @origin AND Destination = @destination)

	return 'Total price' + ' ' + CAST(@price as varchar)
			
end
select dbo.udf_CalculateTickets('Kolyshley','Rancabolang', 33)
SELECT dbo.udf_CalculateTickets('Kolyshley','Rancabolang', -1)
SELECT dbo.udf_CalculateTickets('Invalid','Rancabolang', 33)

--12--
go

create procedure usp_CancelFlights
AS

update Flights
SET ArrivalTime = null, DepartureTime= null
where DATEDIFF(SECOND,ArrivalTime,DepartureTime)<=0


--select *,
--DATEDIFF(SECOND, f.DepartureTime,f.ArrivalTime) AS diff
--from Flights as f
--where DATEDIFF(SECOND,f.ArrivalTime,f.DepartureTime)<0
--order by diff dESC

--select * from Flights
GO
