Voting Systems Project

-- DATABASE CLEARANCE (Safely dropping tables from child to parent) 

DROP TABLE IF EXISTS Vote;
DROP TABLE IF EXISTS Candidate;
DROP TABLE IF EXISTS Election;
DROP TABLE IF EXISTS Position;

-- Drop Subtype Entities
DROP TABLE IF EXISTS Resident;
DROP TABLE IF EXISTS Zone;
DROP TABLE IF EXISTS Student;
DROP TABLE IF EXISTS Course;
DROP TABLE IF EXISTS Staff;
DROP TABLE IF EXISTS Department;
GO

-- STAFF ENTITIES (Campus Elections)
CREATE TABLE Department (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName VARCHAR(100) NOT NULL
);

CREATE TABLE Staff (
    StaffID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50) NOT NULL, LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL, PhoneNumber VARCHAR(20) UNIQUE,
    DepartmentID INT FOREIGN KEY REFERENCES Department(DepartmentID)
);

-- STUDENT ENTITIES (Campus Elections)
CREATE TABLE Course (
    CourseID INT PRIMARY KEY IDENTITY(1,1),
    CourseName VARCHAR(100) NOT NULL, Department VARCHAR(100) NOT NULL
);

CREATE TABLE Student (
    StudentID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50) NOT NULL, LastName VARCHAR(50) NOT NULL,
    RegistrationNumber VARCHAR(20) UNIQUE NOT NULL, PhoneNumber VARCHAR(20) UNIQUE,
    CourseID INT FOREIGN KEY REFERENCES Course(CourseID)
);

--RESIDENT ENTITIES (Election 3 - Geographic)
CREATE TABLE Zone (
    ZoneID INT PRIMARY KEY IDENTITY(1,1),
    ZoneName VARCHAR(100) NOT NULL
);

CREATE TABLE Resident (
    ResidentID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50) NOT NULL, LastName VARCHAR(50) NOT NULL,
    NationalID VARCHAR(20) UNIQUE NOT NULL, PhoneNumber VARCHAR(20) UNIQUE,
    ZoneID INT FOREIGN KEY REFERENCES Zone(ZoneID)
);

--CORE ELECTION ENTITIES
CREATE TABLE Election (
    ElectionID INT PRIMARY KEY IDENTITY(1,1),
    ElectionName VARCHAR(100) NOT NULL, StartDate DATETIME NOT NULL, EndDate DATETIME NOT NULL
);

CREATE TABLE Position (
    PositionID INT PRIMARY KEY IDENTITY(1,1),
    PositionName VARCHAR(100) NOT NULL
);

-- ASSOCIATIVE ENTITIES (ERD Supertype/Subtype)
-- A candidate/vote MUST be exactly ONE of the following: Staff, Student, OR Resident.
CREATE TABLE Candidate (
    CandidateID INT PRIMARY KEY IDENTITY(1,1),
    ElectionID INT FOREIGN KEY REFERENCES Election(ElectionID),
    PositionID INT FOREIGN KEY REFERENCES Position(PositionID),
    
    -- Subtype Foreign Keys
    StaffID INT FOREIGN KEY REFERENCES Staff(StaffID) NULL,
    StudentID INT FOREIGN KEY REFERENCES Student(StudentID) NULL,
    ResidentID INT FOREIGN KEY REFERENCES Resident(ResidentID) NULL,

    -- ERD CONSTRAINT: Ensures a candidate is only one type of person
    CONSTRAINT CHK_CandidateType CHECK (
        (StaffID IS NOT NULL AND StudentID IS NULL AND ResidentID IS NULL) OR 
        (StaffID IS NULL AND StudentID IS NOT NULL AND ResidentID IS NULL) OR 
        (StaffID IS NULL AND StudentID IS NULL AND ResidentID IS NOT NULL)
    )
);

CREATE TABLE Vote (
    VoteID INT PRIMARY KEY IDENTITY(1,1),
    CandidateID INT FOREIGN KEY REFERENCES Candidate(CandidateID),
    PositionID INT FOREIGN KEY REFERENCES Position(PositionID),
    ElectionID INT FOREIGN KEY REFERENCES Election(ElectionID),
    VoteTime DATETIME DEFAULT GETDATE(),
    
    -- Subtype Foreign Keys
    StaffID INT FOREIGN KEY REFERENCES Staff(StaffID) NULL,
    StudentID INT FOREIGN KEY REFERENCES Student(StudentID) NULL,
    ResidentID INT FOREIGN KEY REFERENCES Resident(ResidentID) NULL,

    -- ERD CONSTRAINT: Ensures a vote comes from exactly one type of voter
    CONSTRAINT CHK_VoterType CHECK (
        (StaffID IS NOT NULL AND StudentID IS NULL AND ResidentID IS NULL) OR 
        (StaffID IS NULL AND StudentID IS NOT NULL AND ResidentID IS NULL) OR 
        (StaffID IS NULL AND StudentID IS NULL AND ResidentID IS NOT NULL)
    ),
    -- Prevent Double Voting per demographic
    CONSTRAINT UQ_Staff_Vote UNIQUE(StaffID, PositionID, ElectionID),
    CONSTRAINT UQ_Student_Vote UNIQUE(StudentID, PositionID, ElectionID),
    CONSTRAINT UQ_Resident_Vote UNIQUE(ResidentID, PositionID, ElectionID)
);
GO 

-- 3. DATA INSERTION: BASE ENTITIES

-- (Staff and Student Inserts kept brief for this script's execution speed)
INSERT INTO Department (DepartmentName) VALUES ('HR'), ('IT'), ('Finance');
INSERT INTO Staff (FirstName, LastName, Email, PhoneNumber, DepartmentID) VALUES
('Kamau', 'Njoroge', 'kamau@co.ke', '0711000001', 1), ('Wanjiku', 'Mwangi', 'wanjiku@co.ke', '0711000002', 2),
('Omondi', 'Ochieng', 'omondi@co.ke', '0711000003', 3), ('Akinyi', 'Odhiambo', 'akinyi@co.ke', '0711000004', 1);

INSERT INTO Course (CourseName, Department) VALUES ('Computer Science', 'ICT'), ('Business', 'Commerce');
INSERT INTO Student (FirstName, LastName, RegistrationNumber, PhoneNumber, CourseID) VALUES
('Brian', 'Kipruto', 'CS/001', '0722000001', 1), ('Alice', 'Wanjiru', 'BM/002', '0722000002', 2),
('Kevin', 'Otieno', 'CS/003', '0722000003', 1), ('Mercy', 'Akinyi', 'BM/004', '0722000004', 2);

--(KILIMANI RESIDENTS ASSOCIATION)
INSERT INTO Zone (ZoneName) VALUES ('Kilimani Zone A'), ('Kilimani Zone B'), ('Kilimani Zone C'), ('Kilimani Zone D');

--Residents
INSERT INTO Resident (FirstName, LastName, NationalID, PhoneNumber, ZoneID) VALUES
('John', 'Njuguna', 'ID20001', '0733000001', 1), ('Mary', 'Wambui', 'ID20002', '0733000002', 2),
('Peter', 'Ouko', 'ID20003', '0733000003', 3), ('Jane', 'Anyango', 'ID20004', '0733000004', 4),
('David', 'Kiprono', 'ID20005', '0733000005', 1), ('Sarah', 'Chebet', 'ID20006', '0733000006', 2),
('Daniel', 'Mutisya', 'ID20007', '0733000007', 3), ('Esther', 'Mwikali', 'ID20008', '0733000008', 4),
('Joseph', 'Wekesa', 'ID20009', '0733000009', 1), ('Gladys', 'Nekesa', 'ID20010', '0733000010', 2),
('Samuel', 'Kamau', 'ID20011', '0733000011', 3), ('Ruth', 'Njeri', 'ID20012', '0733000012', 4),
('George', 'Otieno', 'ID20013', '0733000013', 1), ('Grace', 'Akinyi', 'ID20014', '0733000014', 2),
('Evans', 'Cheruiyot', 'ID20015', '0733000015', 3), ('Faith', 'Jepkogei', 'ID20016', '0733000016', 4),
('Michael', 'Kioko', 'ID20017', '0733000017', 1), ('Ann', 'Mutua', 'ID20018', '0733000018', 2),
('Simon', 'Sikuku', 'ID20019', '0733000019', 3), ('Naomi', 'Nasimiyu', 'ID20020', '0733000020', 4),
('Paul', 'Kazungu', 'ID20021', '0733000021', 1), ('Halima', 'Salim', 'ID20022', '0733000022', 2),
('Isaac', 'Maina', 'ID20023', '0733000023', 3), ('Lucy', 'Muthoni', 'ID20024', '0733000024', 4),
('Charles', 'Onyango', 'ID20025', '0733000025', 1), ('Rose', 'Awino', 'ID20026', '0733000026', 2),
('Philip', 'Koech', 'ID20027', '0733000027', 3), ('Lydia', 'Jelagat', 'ID20028', '0733000028', 4),
('Stephen', 'Musyoka', 'ID20029', '0733000029', 1), ('Irene', 'Mwende', 'ID20030', '0733000030', 2),
('Victor', 'Barasa', 'ID20031', '0733000031', 3), ('Diana', 'Naliaka', 'ID20032', '0733000032', 4),
('Edward', 'Muriithi', 'ID20033', '0733000033', 1), ('Florence', 'Wawira', 'ID20034', '0733000034', 2),
('Kevin', 'Ochieng', 'ID20035', '0733000035', 3), ('Beatrice', 'Atieno', 'ID20036', '0733000036', 4),
('Martin', 'Kipchoge', 'ID20037', '0733000037', 1), ('Alice', 'Moraa', 'ID20038', '0733000038', 2),
('Richard', 'Makori', 'ID20039', '0733000039', 3), ('Zuleikha', 'Ali', 'ID20040', '0733000040', 4);
GO

-- 4. ELECTIONS, POSITIONS, AND CANDIDATES
INSERT INTO Election (ElectionName, StartDate, EndDate) VALUES 
('Staff Welfare Election', '2026-03-25', '2026-03-26'),
('Campus Student Council', '2026-04-10', '2026-04-11'),
('Kilimani Residents Association Election', '2026-05-01', '2026-05-02'); -- Election 3

-- Insert Positions
INSERT INTO Position (PositionName) VALUES 
('Chairperson'), ('Secretary General'), -- Staff (1,2)
('Student President'), ('Vice President'), -- Student (3,4)
('Estate Chairman'), ('Estate Treasurer'), ('Security Secretary'), ('Environment Secretary'); -- Resident (5,6,7,8)

--(Candidates, positions)
INSERT INTO Candidate (ResidentID, PositionID, ElectionID) VALUES 
(1, 5, 3), (3, 5, 3),   -- John Njuguna vs Peter Ouko for Estate Chairman
(5, 6, 3), (7, 6, 3),   -- David Kiprono vs Daniel Mutisya for Estate Treasurer
(9, 7, 3), (11, 7, 3),  -- Joseph Wekesa vs Samuel Kamau for Security Secretary
(13, 8, 3), (15, 8, 3); -- George Otieno vs Evans Cheruiyot for Environment Secretary
GO

-- 5. ACID TRANSACTIONS & RELATIONAL ALGEBRA

-- TRANSACTION: Simulating a secure resident vote
BEGIN TRY
    BEGIN TRANSACTION ResidentVote;
    -- Resident 2 (Mary) votes for Candidate 1 (John) for Estate Chairman
    INSERT INTO Vote (ResidentID, CandidateID, PositionID, ElectionID) VALUES (2, 1, 5, 3);
    COMMIT TRANSACTION ResidentVote;
    PRINT 'Resident transaction committed successfully.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION ResidentVote;
    PRINT 'Transaction rolled back to prevent anomaly.';
END CATCH
GO

-- RELATIONAL ALGEBRA (UNION): Create a Universal Voter Demographics View
SELECT FirstName, LastName, 'Staff' AS Category FROM Staff
UNION ALL
SELECT FirstName, LastName, 'Student' AS Category FROM Student
UNION ALL
SELECT FirstName, LastName, 'Resident' AS Category FROM Resident;
GO