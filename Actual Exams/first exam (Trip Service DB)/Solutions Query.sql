create database TripService

use tripservice

Create table Cities(
Id INT Primary Key Identity,
[Name] nvarchar(20) NOT NULL,
CountryCode varchar(2) NOT NULL
)

Create table Hotels(
Id INT Primary Key Identity,
[Name] nvarchar(30) NOT NULL,
CityId INT References Cities(Id) NOT NULL,
EmployeeCount INT NOT NULL,
BaseRate decimal (12,2)
)


Create table Rooms(
Id INT Primary Key Identity,
Price decimal (12,2) NOT NULL,
[Type] nvarchar(20) NOT NULL,
Beds INT NOT NULL,
HotelId INT References Hotels(Id) NOT NULL,
)

Create table Trips(
Id INT Primary Key Identity,
RoomId INT References Rooms(Id) NOT NULL,
BookDate date NOT NULL,
ArrivalDate date NOT NULL,
ReturnDate date NOT NULL,
CancelDate date,
Check (BookDate<ArrivalDate),
Check (ArrivalDate<ReturnDate)
)

Create table Accounts(
Id INT Primary Key Identity,
FirstName nvarchar(50) NOT NULL,
MiddleName nvarchar(20),
LastName nvarchar(50) NOT NULL,
CityId INT References Cities(Id) NOT NULL,
BirthDate date NOT NULL,
Email varchar(100) NOT NULL Unique
)

Create table AccountsTrips(
AccountId INT References Accounts(Id) NOT NULL,
TripId INT References Trips(Id) NOT NULL,
Luggage INT NOT NULL,
Check (Luggage>=0),
Primary Key (AccountId,TripId)
)

--2--
INSERT INTO Accounts (FirstName, MiddleName, LastName, CityId, BirthDate, Email) VALUES
('John',	 'Smith'	,	'Smith'			,34	,'1975-07-21',	'j_smith@gmail.com'				  ),
('Gosho',	  NULL	,	'Petrov'		,11	,'1978-05-16',	'g_petrov@gmail.com'			  ),
('Ivan',	 'Petrovich'	,'Pavlov'		,59	,'1849-09-26',	'i_pavlov@softuni.bg'			  ),
('Friedrich','Wilhelm'	,'Nietzsche'	,2	,'1844-10-15',	'f_nietzsche@softuni.bg')


INSERT INTO Trips (RoomId,	BookDate,	ArrivalDate,	ReturnDate,	CancelDate) VALUES
(101,	'2015-04-12',	'2015-04-14',	'2015-04-20',	'2015-02-02' ),
(102,	'2015-07-07',	'2015-07-15',	'2015-07-22',	'2015-04-29' ),
(103,	'2013-07-17',	'2013-07-23',	'2013-07-24',	NULL	   ),
(104,	'2012-03-17',	'2012-03-31',	'2012-04-01',	'2012-01-10' ),
(109,	'2017-08-07',	'2017-08-28',	'2017-08-29',	NULL	   )


--3--
Update Rooms
SET Price = Price *1.14
Where HotelId IN (5,7,9)

--4--

Delete AccountsTrips
Where AccountId = 47

--Delete all of Account ID 47’s account’s trips from the mapping table.


--5--

select
FirstName,
LastName,
Format(BirthDate, 'MM-dd-yyyy') AS BirthDate,
c.Name AS Hometown,
Email
from Accounts as a
join Cities as c ON c.Id = a.CityId
where Email like 'e%'
Order by c.Name

--Select accounts whose emails start with the letter “e”. Select their first and last name, their birthdate in the format "MM-dd-yyyy", and their city name. Order them by city name (ascending)

--6--
select
c.Name,
Count(h.Id) AS Hotels
from Cities as c
join Hotels as h ON c.Id = h.CityId
group by c.Name
Order by Hotels DESC,c.Name


--Select all cities with the count of hotels in them. Order them by the hotel count (descending), then by city name. Do not include cities, which have no hotels in them. // Use left join if they want the 0 hotels cities

--7--
select a.Id as AccountId,
a.FirstName + ' ' + a.LastName AS [FullName],
MAX(DATEDIFF(day,ArrivalDate,ReturnDate)) AS LongestTrip,
MIN(DATEDIFF(day,ArrivalDate,ReturnDate)) AS ShortestTrip
from Accounts as a
join AccountsTrips as [at] ON at.AccountId = a.Id
join Trips as t ON t.Id=at.TripId
where (a.MiddleName is null AND t.CancelDate is null)
group by a.Id,a.FirstName,a.LastName
Order by LongestTrip DESC,ShortestTrip


--Find the longest and shortest trip for each account, in days. Filter the results to accounts with no middle name and trips, which are not cancelled (CancelDate is null). 
--Order the results by Longest Trip days (descending), then by Shortest Trip (ascending).


--8--

select top(10)
c.Id,
c.Name,
c.CountryCode,
count(a.id) AS Accounts
from Cities as c
join Accounts as a ON c.Id = a.CityId
group by c.Id, c.Name, c.CountryCode
Order by Accounts DESC
 
--Find the top 10 cities, which have the most registered accounts in them. Order them by the count of accounts (descending).

--9--

select a.Id,
a.Email,
c.Name AS City,
count(a.CityId) AS Trips
from Accounts as a
join AccountsTrips as [at] ON at.AccountId = a.Id
join Trips as t ON t.Id = at.TripId
join Rooms as r ON t.RoomId = r.Id
join Hotels as h ON h.Id = r.HotelId
join Cities as c ON h.CityId = c.Id
where a.CityId=h.CityId
group by a.Id,a.Email,c.Name
Order by Trips DESC, a.Id

--10--

select 
t.Id,
AccountsTowns.[Full Name],
AccountsTowns.[From],
c.name AS [To],
CASE
    WHEN t.CancelDate is not null THEN 'Canceled'
	else CAST(DATEDIFF(day,ArrivalDate,ReturnDate) as varchar) +' days'
	end AS Duration
from Trips as t
left join AccountsTrips as [at] ON [at].TripId = t.Id

join (
			select
			a.Id,
			a.FirstName + ' ' + ISNULL(a.MiddleName, '') + ' ' + a.LastName AS [Full Name],
			c.Name as [From]
			from Accounts as a
			join Cities as c ON a.CityId = c.Id
) as AccountsTowns ON AccountsTowns.Id = at.AccountId

left join Rooms as r ON r.Id = t.RoomId
left join Hotels as h ON h.Id = r.HotelId
left join Cities as c ON c.Id = h.CityId
order by [Full Name], t.Id

--10 Dancho--
Select actr.TripId,
Concat(RTRIM(LTRIM(CONCAT(a.FirstName,' ',a.MiddleName))),' ',(a.LastName)) as [Full Name],
(c.[Name]) as [From],chtls.[Name] as [To],
case
when t.CancelDate is not null then 'Canceled'
else concat(DATEDIFF(DAY,t.ArrivalDate,t.ReturnDate),' days') 
end
as Duration

 from AccountsTrips as actr
inner join Accounts as a on actr.AccountId=a.Id
inner join Cities as c on c.Id=a.CityId
inner join Trips as t on t.Id = actr.TripId
inner join Rooms as r on r.Id = t.RoomId
inner join Hotels as h on r.HotelId = h.Id
inner join Cities as chtls on chtls.Id=h.CityId
order by [Full Name],actr.TripId

--11--
go
create or alter function udf_GetAvailableRoom(@HotelId int, @Date date, @People int)
returns varchar
begin

declare @roomId int
declare @type varchar(50)
declare @beds int
declare @highestPrice decimal(10,2)

declare @RESULT varchar

Set @roomId = 	(select top(1) 
	RoomId
	from Rooms as r
	left join Hotels as h on h.Id = r.HotelId
	left join Trips as t on t.RoomId = r.Id
	where HotelId = @HotelId -- @HotelId 
	AND ( 
	(	@Date NOT between t.ArrivalDate and t.ReturnDate)
			OR((@Date between t.ArrivalDate and t.ReturnDate) AND CancelDate is not null)
	)
	AND r.Beds>=@People
	order by (h.BaseRate + r.Price) * @People DESC)

---------------------------------------------------------
Set @type = 	(select top(1) 
	r.Type
	from Rooms as r
	left join Hotels as h on h.Id = r.HotelId
	left join Trips as t on t.RoomId = r.Id
	where HotelId = @HotelId -- @HotelId 
	AND ( 
	(	@Date NOT between t.ArrivalDate and t.ReturnDate)
			OR((@Date between t.ArrivalDate and t.ReturnDate) AND CancelDate is not null)
	)
	AND r.Beds>=@People
	order by (h.BaseRate + r.Price) * @People DESC)
	-----------------------------------------------
Set @highestPrice = 	(select top(1) 
	(h.BaseRate + r.Price) * @People AS highestPriceRoom
	from Rooms as r
	left join Hotels as h on h.Id = r.HotelId
	left join Trips as t on t.RoomId = r.Id
	where HotelId = @HotelId -- @HotelId 
	AND ( 
	(	@Date NOT between t.ArrivalDate and t.ReturnDate)
			OR((@Date between t.ArrivalDate and t.ReturnDate) AND CancelDate is not null)
	)
	AND r.Beds>=@People
	order by (h.BaseRate + r.Price) * @People DESC)
---------------------------------------------------------------
Set @beds = 	(select top(1) 
	r.Beds
	from Rooms as r
	left join Hotels as h on h.Id = r.HotelId
	left join Trips as t on t.RoomId = r.Id
	where HotelId = @HotelId -- @HotelId 
	AND ( 
	(	@Date NOT between t.ArrivalDate and t.ReturnDate)
			OR((@Date between t.ArrivalDate and t.ReturnDate) AND CancelDate is not null)
	)
	AND r.Beds>=@People
	order by (h.BaseRate + r.Price) * @People DESC)
	--(select top(1) 
	--RoomId,
	--r.Type,
	--r.Beds,
	--(h.BaseRate + r.Price) * @People AS highestPriceRoom
	--from Rooms as r
	--left join Hotels as h on h.Id = r.HotelId
	--left join Trips as t on t.RoomId = r.Id
	--where HotelId = @HotelId -- @HotelId 
	--AND ( 
	--(	@Date NOT between t.ArrivalDate and t.ReturnDate)
	--		OR(@Date between t.ArrivalDate and t.ReturnDate) AND CancelDate is not null)
	--)
	--AND r.Beds>=2
	--order by highestPriceRoom DESC)

if(@roomId is null)
begin

set @RESULT = 'No rooms available'
return @RESULT

end

set @RESULT = 'Room ' + Cast(@roomId as varchar)+': ' +@type + ' (' + Cast(@beds as varchar) +' beds) - $'+ CAST(@highestPrice as varchar)
return @RESULT
end

SELECT dbo.udf_GetAvailableRoom(112, '2011-12-17', 2)
SELECT dbo.udf_GetAvailableRoom(94, '2015-07-26', 3)

--12--

create or alter procedure usp_SwitchRoom(@TripId int, @TargetRoomId int)
AS
begin
	DECLARE @roombeds int
    DECLARE @TripAccs int

		SET @roombeds = (select Beds from Rooms
						where id=@TargetRoomId)

		set @TripAccs	= (select count(*) from Trips as t
						join AccountsTrips as [at] ON [at].TripId = t.Id
						where t.Id = @TripId)

						if(@roombeds<@TripAccs)
						THROW 51001, 'Not enough beds in target room!', 1;

    DECLARE @roomHotel NVARCHAR(100)
    DECLARE @TripHotel NVARCHAR(100)
    SET @roomHotel =(select h.Name from Rooms as r
						join Hotels as h ON h.Id = r.HotelId
						where r.Id = @TargetRoomId)
 
    SET @TripHotel = (select h.Name from Trips as t
						join Rooms as r on r.Id =t.Id
						join Hotels as h ON h.Id = r.HotelId
						where t.Id = @TripId)

    If(@TripHotel != @roomHotel)
        THROW 51000, 'Target room is in another hotel!', 1;

Update Trips
SET RoomId = @TargetRoomId
where Id = @TripId

end
go
exec usp_SwitchRoom 10,11
EXEC usp_SwitchRoom 10, 11
EXEC usp_SwitchRoom 10, 7
SELECT RoomId FROM Trips WHERE Id = 10

select * from Trips as t
join Rooms as r on r.Id =t.Id
join Hotels as h ON h.Id = r.HotelId
where t.Id = 10

select * from Rooms as r
join Hotels as h ON h.Id = r.HotelId
where r.Id = 11






declare @room int 
set @room = 20
select 'asd' +cast(@room as varchar)