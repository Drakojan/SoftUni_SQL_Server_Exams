create database Bitbucket
use bitbucket

create table Users
(
Id int Identity Primary key,
check (Id>0),
Username nvarchar(30) NOT NULL,
[Password] nvarchar(30) NOT NULL,
Email nvarchar(50) NOT NULL
)

create table Repositories
(
Id int Identity Primary key,
check (Id>0),
[Name] nvarchar(50) NOT NULL
)

create table RepositoriesContributors
(
RepositoryId int References Repositories(Id) NOT NULL,
check (RepositoryId>0),
ContributorId int References Users(Id) NOT NULL
check (ContributorId>0),
Primary key (RepositoryId,ContributorId)
)

create table Issues
(
Id int Identity Primary key,
check (Id>0),
Title nvarchar(255) NOT NULL,
IssueStatus nvarchar(6) NOT NULL,
RepositoryId int NOT NULL References Repositories(Id),
AssigneeId int NOT NULL References Users(Id)
)

create table Commits
(
Id int Identity Primary key,
check (Id>0),
Message nvarchar(255) NOT NULL,
IssueId int References Issues(Id),
RepositoryId int NOT NULL References Repositories(Id),
ContributorId int NOT NULL References Users(Id)
)

create table Files
(
Id int Identity Primary key,
check (Id>0),
Name nvarchar(100) NOT NULL,
Size decimal(18,2) NOT NULL,
ParentId int References Files(Id),
check (ParentId>0),
CommitId int NOT NULL References Commits(Id),
check (CommitId>0),
)


INSERT INTO Files(Name, Size, ParentId, CommitId)
VALUES
('Trade.idk', 2598.0, 1, 1),
('menu.net', 9238.31, 2, 2),
('Administrate.soshy', 1246.93, 3, 3),
('Controller.php', 7353.15, 4, 4),
('Find.java', 9957.86, 5, 5),
('Controller.json', 14034.87, 3, 6),
('Operate.xix', 7662.92, 7, 7)


INSERT INTO Issues(Title, IssueStatus, RepositoryId, AssigneeId)
VALUES
('Critical Problem with HomeController.cs file', 'open', 1, 4),
('Typo fix in Judge.html', 'open', 4, 3),
('Implement documentation for UsersService.cs', 'closed', 8, 2),
('Unreachable code in Index.cs', 'open', 9, 8)


Update Issues
Set IssueStatus = 'closed' 
where AssigneeId = 6

select * from Repositories as r
join Issues as i on i.RepositoryId = r.Id
where name = 'Softuni-Teamwork'

delete from RepositoriesContributors
where RepositoryId = 3

delete from issues
where RepositoryId = 3

-- 5--
select Id,Message, RepositoryId,ContributorId from Commits
Order by Id,Message, RepositoryId,ContributorId

select Id, Name, Size from Files
where size>1000 AND Name like '%html%'
order by size DESC,id, Name

select * from (
		select i.Id, 
		u.Username + ' : ' + i.Title AS IssueAssignee
		from Issues as i
		join Users as u ON i.AssigneeId=u.Id) as temp
order by Id DESC, IssueAssignee

-- 8 --

select 
f2.id,
f2.name, 
cast(f2.Size as varchar(100)) + 'KB' AS Size
from Files as f1
right join files as f2 ON f1.ParentId = f2.Id
where f1.id is null
Order by f2.Id, f2.Name, f2.Size DESC


-- 9 --
select top (5)
r.Id,
r.Name,
Count(*) as Commits
from Commits as c
join Repositories as r ON c.RepositoryId=r.Id
join RepositoriesContributors as rc on rc.RepositoryId=r.id
group by r.Id, r.Name
Order by Commits DESC,Id,Name


--testing below
select * 
from Commits as c
join Repositories as r ON c.RepositoryId=r.Id
join RepositoriesContributors as rc on rc.RepositoryId=r.id

--testing below
select * 
from Repositories as r 
join RepositoriesContributors as rc on rc.RepositoryId=r.id
where RepositoryId = 1

-- 10 --

select 
u.Username, 
AVG(f.Size) AS Size
from Users as u
join Commits as c ON c.ContributorId = u.Id
join files as f ON f.CommitId = c.Id
group by Username
order by Size DESC, Username

-- 11 -- 

create or alter function udf_UserTotalCommits(@username varchar(100)) 
returns int
begin
	
	if (
		(CAST((select Count(*) AS [count] from Users as u
		join Commits as c ON c.ContributorId = u.Id
		group by Username
		having Username = @username) AS int)) is null)
		return 0


	return CAST((select Count(*) AS [count] from Users as u
	join Commits as c ON c.ContributorId = u.Id
	group by Username
	having (Username = @username)) AS int)

end
go
--12--


create or alter procedure usp_FindByExtension(@extension nvarchar(100))
AS

select 
id,
Name,
cast(Size as varchar(100)) + 'KB' AS Size
from files
where [Name] like ('%.' + @extension)

GO

exec usp_FindByExtension 'txt'

select * from files
