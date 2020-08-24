create database Service

use service

Create table Users (
Id int Identity Primary Key,
Username varchar(30) Unique NOT NULL,
Password varchar(50) NOT NULL,
Name varchar(50),
BirthDate datetime2,
Age int,
Check (Age between 14 AND 110),
Email varchar(50) NOT NULL,
)

Create table Departments (
Id int Identity Primary Key,
Name varchar(50) NOT NULL
)

Create table Employees (
Id int Identity Primary Key,
FirstName varchar(25),
LastName varchar(25),
BirthDate datetime2,
Age int,
Check (Age between 18 AND 110),
DepartmentId int references Departments(Id)
)

Create table Categories (
Id int Identity Primary Key,
Name varchar(50) NOT NULL,
DepartmentId int references Departments(Id) NOT NULL
)

Create table [Status] (
Id int Identity Primary Key,
Label varchar(30) NOT NULL
)

Create table Reports (
Id int Identity Primary Key,
CategoryId int references Categories(Id) NOT NULL,
StatusId int references Status(Id) NOT NULL,
OpenDate datetime2 NOT NULL,
CloseDate datetime2,
Description varchar(200) NOT NULL,
UserId int references Users(Id) NOT NULL,
EmployeeId int references employees(Id)
)


INSERT INTO Employees(FirstName,LastName,Birthdate, DepartmentId) VALUES 
('Marlo', 'O''Malley', '1958-9-21', 1),
('Niki' ,'Stanaghan',	'1969-11-26',4),
('Ayrton'	,'Senna',	'1960-03-21',9),
('Ronnie'	,'Peterson','1944-02-14',9),
('Giovanna'	,'Amati',	'1959-07-20',5)

INSERT INTO Reports(CategoryId,StatusId, OpenDate, CloseDate,Description,UserId, EmployeeId) VALUES
(1  ,1	,'2017-04-13',	NULL,	        'Stuck Road on Str.133'	,6	,2				 ),
(6	,3	,'2015-09-05',	'2015-12-06',	'Charity trail running'	,3	,5		 ),
(14	,2	,'2015-09-07',	NULL,	        'Falling bricks on Str.58'	,5	,2	),
(4	,3	,'2017-07-03',	'2017-07-06',	'Cut off streetlight on Str.11'	,1	,1)

Update Reports
SET CloseDate=GETDATE()
where CloseDate is null

Delete Reports
Where StatusId = 4


--5--
select 
Description,
Format(OpenDate, 'dd-MM-yyyy') AS OpenDate
from Reports as r
where EmployeeId is null
Order by r.OpenDate ASC,  [Description]

--6--
select 
Description, 
Name as CategoryName
from Reports as r
join categories as c on r.CategoryId=c.Id
order by Description, Name
 
 --7--

select top(5)
Name AS CategoryName,
count(Name) AS ReportsNumber
from Reports as r
join categories as c on r.CategoryId=c.Id
group by Name
order by ReportsNumber DESC, Name

 --8--

select 
Username,
c.Name AS CategoryName
from Reports as r
join categories as c ON r.CategoryId=c.Id
join Users as u ON u.Id = r.UserId
--where SUBSTRING(Cast(BirthDate as nvarchar),6,5) = SUBSTRING(Cast(OpenDate as nvarchar),6,5)
where DATEPART(month, OpenDate) = DATEPART(month, BirthDate) AND
DATEPART(DAY, OpenDate) = DATEPART(DAY, BirthDate)
Order by Username, CategoryName

 --Select the user's username and category name in all reports in which users have submitted a report on their birthday. Order them by username (ascending) and then by category name (ascending).

 --9--
 select FullName, count(UserId) AS UsersCount
 FROM 
		(select 
		e.FirstName + ' ' + e.LastName AS FullName,
		UserId
		from Employees as e
		left join Reports as r ON e.Id = r.EmployeeId
		left join Users as u ON u.Id = r.UserId
		Group by e.FirstName,e.LastName, UserId) as temp

group by FullName
Order by UsersCount DESC, FullName

--10--

select 
ISNULL(e.FirstName + ' ' + e.LastName, 'None') AS Employee,
ISNULL(d.Name, 'None') AS Department,
c.Name AS Category,
Description,
FORMAT(OpenDate, 'dd.MM.yyyy') AS OpenDate,
s.Label AS Status,
u.Name AS [User] 
from Reports as r
left join Status as s ON r.StatusId = s.Id
left join users as u ON u.Id = r.UserId
left join Employees as e ON e.Id = r.EmployeeId
left join Categories as c ON c.Id = r.CategoryId
left join Departments as d ON d.Id = e.DepartmentId
order by FirstName DESC, LastName DESC, d.Name, c.Name,Description,r.OpenDate, s.Label,u.Name


--11--
go
create alter function udf_HoursToComplete(@StartDate DAtetime, @EndDate datetime) 
returns int
begin
		if(@StartDate is null OR @EndDate is NULL)
		return 0

		return DATEDIFF(hour, @StartDate, @EndDate)
end 

go
SELECT dbo.udf_HoursToComplete(OpenDate, CloseDate) AS TotalHours
   FROM Reports

   go

   --12--
   create alter procedure usp_AssignEmployeeToReport(@EmployeeId INT, @ReportId INT) 
   AS
	
	if( 

		(select d.Name from Employees as e
		join Departments as d ON d.Id = e.DepartmentId
		where e.Id = @EmployeeId) =

		(select d.Name from Reports as r
		join Categories as c ON c.Id = r.CategoryId
		join Departments as d ON d.Id = c.DepartmentId
		where r.Id = @ReportId)
	)
	begin
			update Reports
			SET EmployeeId = @EmployeeId
			where Id = @ReportId
    end

	else 
	THROW 51000, 'Employee doesn''t belong to the appropriate department!', 1;   
   go


   EXEC usp_AssignEmployeeToReport 30, 1
   EXEC usp_AssignEmployeeToReport 17, 2