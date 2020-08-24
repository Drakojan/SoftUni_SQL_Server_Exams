create database School
use school

create table Students(
Id int Primary Key Identity,
FirstName nvarchar(30) NOT NULL,
MiddleName nvarchar(25),
LastName nvarchar(30) NOT NULL,
Age int, 
check (Age between 5 and 100),
[Address] nvarchar(50),
Phone nvarchar(10)
)

create table Subjects(
Id int Primary Key Identity,
[Name] nvarchar(20) NOT NULL,
Lessons int,
check (Lessons>0)
)

create table StudentsSubjects(
Id int Primary Key Identity,
StudentId int references Students(Id) NOT NULL,
SubjectId int references Subjects(Id) NOT NULL,
Grade decimal(3,2) NOT NULL,
Check( Grade between 2 and 6)
)

create table Exams(
Id int Primary Key Identity,
Date Datetime2,
SubjectId int references Subjects(Id) NOT NULL,
)

create table StudentsExams(
StudentId int references Students(Id) NOT NULL,
ExamId int references Exams(Id) NOT NULL,
Grade decimal(3,2) NOT NULL,
Check( Grade between 2 and 6),
Primary key (StudentId, ExamId)
)

create table Teachers(
Id int Primary Key Identity,
FirstName nvarchar(20) NOT NULL,
LastName nvarchar(20) NOT NULL,
[Address] nvarchar(20) NOT NULL,
Phone varchar(10),
SubjectId int references Subjects(Id) NOT NULL
)

create table StudentsTeachers(
StudentId int references Students(Id) NOT NULL,
TeacherId int references Teachers(Id) NOT NULL,
Primary key (StudentId, TeacherId)
)


--2--

INSERT INTO Teachers (FirstName, LastName, Address, Phone, SubjectId) VALUES
('Ruthanne', 'Bamb', '84948 Mesta Junction', '3105500146', 6),
('Gerrard', 'Lowin', '370 Talisman Plaza', '3324874824', 2),
('Merrile', 'Lambdin', '81 Dahle Plaza', '4373065154', 5),
('Bert', 'Ivie', '2 Gateway Circle', '4409584510', 4)

INSERT INTO Subjects(Name, Lessons) VALUES

('Geometry',12 ),
('Health'	,10),
('Drama'	,7 ),
('Sports'	,9 )

--3--
Update StudentsSubjects
SET Grade = 6.00
Where (SubjectId IN (1,2) AND Grade>=5.50)

--4--
Delete StudentsTeachers
Where TeacherId IN (select Id from Teachers
					where Phone like '%72%')

Delete Teachers
Where Phone like '%72%'

--5--

select FirstName,LastName, Age from Students
where Age>=12
Order by FirstName,LastName 

-- 6 --
select 
FirstName + ' ' + ISNULL(MiddleName,'') + ' ' + LastName AS [Full Name], 
Address
from Students
where Address like '%road%'
Order by FirstName,LastName,Address
----Select all full names from students, whose address text contains ‘road’.
--Order them by first name (alphabetically), then by last name (alphabetically), then by address text (alphabetically).

--7--

select 
FirstName, 
Address,
Phone
from Students
where phone like '42%' AND MiddleName IS NOT NULL
Order by FirstName


--Select students with middle names whose phones starts with 42. Select their first name, address and phone number. Order them by first name alphabetically.

--8--

select 
s.FirstName, 
s.LastName,
count(t.Id)
from students as s 
left join StudentsTeachers as st ON s.Id= st.StudentId
Left join Teachers as t ON t.Id = st.TeacherId
group by s.FirstName, s.LastName
order by LastName
--Select all students and the count of teachers each one has. 

--9--

select 
t.FirstName + ' ' + t.LastName AS [Full Name], 
s.Name + '-' + CAST(s.Lessons as nvarchar) AS Subjects,
count(st.StudentId) AS Students
from Teachers as t
left join Subjects as s ON s.Id = t.SubjectId
left join StudentsTeachers as st ON st.TeacherId = t.Id
group by t.FirstName, t.LastName, s.Name, s.Lessons
order by Students DESC, [Full Name] ASC, Subjects ASC


--Select all teachers’ full names and the subjects they teach with the count of lessons in each. Finally select the count of students each teacher has. Order them by students count descending, full name (ascending) and subjects (ascending).

--10--
select 
FirstName + ' ' + LastName AS [Full Name]
from Students as s
left join StudentsExams as se ON s.Id = se.StudentId
where ExamId is null
order by [Full Name]
--Find all students, who have not attended an exam. Select their full name (first name + last name).Order the results by full name (ascending).

--11--

select top (10)
FirstName,
LastName,
count(st.StudentId) AS StudentsCount
from Teachers as t
left join StudentsTeachers as st ON st.TeacherId = t.Id
Group by FirstName, LastName
order by StudentsCount DESC,FirstName, LastName


--Find top 10 teachers with most students they teach. Select their first name, last name and the amount of students they have. Order them by students count (descending), then by first name (ascending), then by last name (ascending).

--12--

select top(10)
FirstName,
LastName,
CAST((AVG(Grade)) as decimal(3,2)) AS Grade
from Students as s
left join StudentsExams as se ON s.Id = se.StudentId
group by FirstName, LastName
ORder by Grade DESC,FirstName, LastName

--Find top 10 students, who have highest average grades from the exams.
--Format the grade, two symbols after the decimal point.
--Order them by grade (descending), then by first name (ascending), then by last name (ascending)
