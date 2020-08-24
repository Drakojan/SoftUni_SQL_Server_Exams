CREATE DATABASE [WMS]
 
CREATE TABLE Clients(
    ClientId BigInt Primary Key Identity,
    FirstName varchar(50) NOT NULL,
    LastName varchar(50) NOT NULL,
    Phone CHAR(12) CHECK (LEN (Phone) = 12)
 
)
CREATE TABLE Mechanics(
    MechanicId BigInt Primary Key Identity,
    FirstName varchar(50) NOT NULL,
    LastName varchar(50) NOT NULL,

    [Address] varchar(255) NOT NULL
)
 
CREATE TABLE Models(
    ModelId BigInt Primary Key Identity,
    [Name] varchar(50) UNIQUE NOT NULL
    )
 
CREATE TABLE Jobs(
    JobId BigInt Primary Key Identity,
    ModelId BigInt Foreign Key References Models(ModelId),
    [Status] varchar(11) CHECK([Status] in ('Pending','In Progress''Finished')) DEFAULT 'Pending' NOT NULL,
    ClientId BigInt Foreign Key References Clients(ClientId) NOT NULL,
    MechanicId BigInt Foreign Key References Mechanics(MechanicId),
    IssueDate DATE NOT NULL,
    FinishDate DATE
)
 
CREATE TABLE Orders(
    OrderId BigInt Primary Key Identity,
    JobId BigInt Foreign Key References Jobs(JobId) NOT NULL,
    IssueDate DATE,
    Delivered BIT DEFAULT 0
)
 
CREATE TABLE Vendors(
    VendorId BigInt Primary Key Identity,
    [Name] varchar(50) UNIQUE NOT NULL
)
 
CREATE TABLE Parts(
    PartId BigInt Primary Key Identity,
    SerialNumber varchar(50) UNIQUE NOT NULL,
    [Description] varchar(255),
    Price MONEY CHECK(Price > 0) NOT NULL,
    VendorId BigInt Foreign Key References Vendors(VendorId) NOT NULL,
    StockQty BIGINT CHECK(StockQty >= 0) DEFAULT 0 NOT NULL
    )
 
CREATE TABLE PartsNeeded(
 
        JobId BigInt Foreign Key References Jobs(JobId) NOT NULL,
        PartId BigInt Foreign Key References Parts(PartId) NOT NULL,
        Quantity BIGINT CHECK(Quantity > 0) DEFAULT 1,
        PRIMARY KEY (JobId, PartId)
   
)
 
CREATE TABLE OrderParts(
    OrderId BigInt Foreign Key References Orders(OrderId) NOT NULL,
    PartId BigInt Foreign Key References Parts(PartId) NOT NULL,
    Quantity BIGINT CHECK(Quantity > 0) DEFAULT 1,
    PRIMARY KEY(OrderId, PartId)
   
)



INSERT INTO Clients (FirstName, LastName, Phone) VALUES
('Teri'		,'Ennaco'	,'570-889-5187'),
('Merlyn'	,'Lawler'	,'201-588-7810'),
('Georgene'	,'Montezuma','925-615-5185'),
('Jettie'	,'Mconnell'	,'908-802-3564'),
('Lemuel'	,'Latzke'	,'631-748-6479'),
('Melodie'	,'Knipp'	,'805-690-1682'),
('Candida'	,'Corbley'	,'908-275-8357')

INSERT INTO Parts (SerialNumber, Description, Price,VendorId) VALUES
('WP8182119',	'Door Boot Seal',	117.86,		2),	
('W10780048',	'Suspension Rod',	42.81,		1),
('W10841140',	'Silicone Adhesive', 	6.77,	4),
('WPY055980',	'High Temperature Adhesive',13.94,	3)

Update Jobs
SET MechanicId = 3, [status] = 'In Progress'
where [status] = 'Pending'

Delete from OrderParts
where OrderId = 19

Delete from Orders
where OrderId = 19

--5--
Select 
FirstName + ' ' + LastName as Mechanic,
j.Status, 
j.IssueDate
from Mechanics as m JOIN Jobs as j ON
m.MechanicId = j.MechanicId
order by m.MechanicId, j.IssueDate, j.JobId


--6--
select 
c.FirstName + ' ' + c.LastName as Client,
DATEDIFF(DAY, j.IssueDate, '2017-04-24') as [Days Going],
j.[Status]
from Clients as c
join jobs as j ON c.ClientId = j.ClientId
where j.Status != 'Finished'
order by DATEDIFF(DAY, j.IssueDate, '2017-04-24') DESC,c.ClientId

--7--
Select
FirstName + ' ' + LastName as Mechanic,
AVG(DATEDIFF(DAY, j.IssueDate, j.FinishDate)) as [Average Days]
from Mechanics as m
join jobs as j ON j.MechanicId = m.MechanicId
group by (FirstName + ' ' + LastName), m.MechanicId
order by m.MechanicId

--8--

select 
FirstName + ' ' + LastName as Mechanic
from Mechanics as m
left join jobs as j ON j.MechanicId = m.MechanicId
--where NOT EXISTS
--(SELECT j.Status FROM jobs WHERE j.Status='finished')
group by (FirstName + ' ' + LastName), m.MechanicId
having max(j.Status) =Null 
order by m.MechanicId
1,3,4 

		select FirstName + ' ' + LastName as Mechanic
		from Mechanics
		where MechanicId not in(
				select 
				m.MechanicId
				from Mechanics as m
				left join jobs as j ON j.MechanicId = m.MechanicId
				where FinishDate is null
				group by m.MechanicId)
		order by MechanicId




--below one gives 3/7--
select FirstName + ' ' + LastName as Available
from Mechanics as m
left join jobs as j ON j.MechanicId = m.MechanicId
where m.MechanicId in (1,3,4)
group by (FirstName + ' ' + LastName), m.MechanicId
order by m.MechanicId

--9--

select 
jobId,
SUM(TotalPartPrice) as Total
from
		(SELECT j.JobId,
		Quantity * Price AS TotalPartPrice
		FROM Jobs AS j
		JOIN Partsneeded as pn ON j.JobId = pn.JobId
		JOIN Parts as p ON p.PartId = pn.PartId
		where j.Status = 'finished') as temp
group by JobId
ORDER BY Total DESC, JobId ASC

--10--

select * from jobs as j

		JOIN Partsneeded as pn ON j.JobId = pn.JobId
		JOIN Parts as p ON p.PartId = pn.PartId
		join OrderParts as op ON op.PartId = pn.PartId
		join Orders as o on o.OrderId = op.OrderId
		where Status !='Finished'

select PartId, Description,
sum(partsNeeded) as [Required],
sum(actualPartsPresent) as InStock
from
		(select *,
		CASE
			WHEN Delivered=0 THEN PartsPresent + PartsOrdered
			ELSE PartsPresent
		END as actualPartsPresent 
		from
					(select 
					pn.PartId,
					Description,
					pn.Quantity as PartsNeeded,
					StockQty as PartsPresent,
					op.Quantity as PartsOrdered,
					Delivered

					from jobs as j

							JOIN Partsneeded as pn ON j.JobId = pn.JobId
							JOIN Parts as p ON p.PartId = pn.PartId
							join OrderParts as op ON op.PartId = pn.PartId
							join Orders as o on o.OrderId = op.OrderId
					where Status !='Finished'
					) as temp
			) as temp2
group by PartId, Description
having sum(partsNeeded) > sum(actualPartsPresent)
order by PartId
		
