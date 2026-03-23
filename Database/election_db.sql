/* ============================================================================
   SECURE MULTI-ELECTION SYSTEM - MASTER UNIFIED SCRIPT (ELECTIONS 1 & 2)
   Concepts: 3NF, Schema Evolution, Transactions, Relational Algebra
   ============================================================================ */

-- 1. DATABASE CLEARANCE (Safely dropping tables from child to parent)
DROP TABLE IF EXISTS Vote;
DROP TABLE IF EXISTS Candidate;
DROP TABLE IF EXISTS Election;
DROP TABLE IF EXISTS Position;
DROP TABLE IF EXISTS Student;
DROP TABLE IF EXISTS Course;
DROP TABLE IF EXISTS Staff;
DROP TABLE IF EXISTS Department;
GO

-- ============================================================================
-- 2. PHASE 1: STAFF ELECTION SCHEMA (3NF)
-- ============================================================================
CREATE TABLE Department (
    DepartmentID INT PRIMARY KEY IDENTITY(1,1),
    DepartmentName VARCHAR(100) NOT NULL
);

CREATE TABLE Staff (
    StaffID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE NOT NULL,
    PhoneNumber VARCHAR(20),
    DepartmentID INT FOREIGN KEY REFERENCES Department(DepartmentID),
    RegistrationDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE Election (
    ElectionID INT PRIMARY KEY IDENTITY(1,1),
    ElectionName VARCHAR(100) NOT NULL,
    StartDate DATETIME NOT NULL,
    EndDate DATETIME NOT NULL
);

CREATE TABLE Position (
    PositionID INT PRIMARY KEY IDENTITY(1,1),
    PositionName VARCHAR(100) NOT NULL
);

CREATE TABLE Candidate (
    CandidateID INT PRIMARY KEY IDENTITY(1,1),
    StaffID INT FOREIGN KEY REFERENCES Staff(StaffID),
    PositionID INT FOREIGN KEY REFERENCES Position(PositionID),
    ElectionID INT FOREIGN KEY REFERENCES Election(ElectionID)
);

CREATE TABLE Vote (
    VoteID INT PRIMARY KEY IDENTITY(1,1),
    StaffID INT FOREIGN KEY REFERENCES Staff(StaffID),
    CandidateID INT FOREIGN KEY REFERENCES Candidate(CandidateID),
    PositionID INT FOREIGN KEY REFERENCES Position(PositionID),
    ElectionID INT FOREIGN KEY REFERENCES Election(ElectionID),
    VoteTime DATETIME DEFAULT GETDATE(),
    CONSTRAINT UQ_Staff_Position_Election UNIQUE(StaffID, PositionID, ElectionID)
);
GO -- (Executes Phase 1 schema creation)

-- ============================================================================
-- 3. PHASE 2: SCHEMA EVOLUTION FOR CAMPUS ELECTION
-- ============================================================================
CREATE TABLE Course (
    CourseID INT PRIMARY KEY IDENTITY(1,1),
    CourseName VARCHAR(100) NOT NULL,
    Department VARCHAR(100) NOT NULL
);

CREATE TABLE Student (
    StudentID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    RegistrationNumber VARCHAR(20) UNIQUE NOT NULL,
    PhoneNumber VARCHAR(20) UNIQUE NOT NULL,
    CourseID INT FOREIGN KEY REFERENCES Course(CourseID),
    RegistrationDate DATETIME DEFAULT GETDATE()
);
GO -- (Executes Student tables before altering foreign keys)

-- Alter existing tables to allow Students to run and vote
ALTER TABLE Candidate ALTER COLUMN StaffID INT NULL;
ALTER TABLE Candidate ADD StudentID INT FOREIGN KEY REFERENCES Student(StudentID);

ALTER TABLE Vote ALTER COLUMN StaffID INT NULL;
ALTER TABLE Vote ADD StudentID INT FOREIGN KEY REFERENCES Student(StudentID);

-- Relational Domain Constraint: A vote is cast by EITHER a Staff OR a Student
ALTER TABLE Vote ADD CONSTRAINT CHK_VoterType CHECK (
    (StaffID IS NOT NULL AND StudentID IS NULL) OR 
    (StaffID IS NULL AND StudentID IS NOT NULL)
);

-- Prevent double-voting for students
ALTER TABLE Vote ADD CONSTRAINT UQ_Student_Position_Election UNIQUE(StudentID, PositionID, ElectionID);
GO -- (Schema is now fully evolved and compiled)

-- ============================================================================
-- 4. AUTHENTIC DATA INSERTION (Staff & Students)
-- ============================================================================
-- Insert Staff Data
INSERT INTO Department (DepartmentName) VALUES 
('Human Resources'), ('Information Technology'), ('Finance'), ('Operations'), ('Marketing');

INSERT INTO Staff (FirstName, LastName, Email, PhoneNumber, DepartmentID) VALUES
('Kamau', 'Njoroge', 'kamau.n@company.co.ke', '0711000001', 1),
('Wanjiku', 'Mwangi', 'wanjiku.m@company.co.ke', '0711000002', 2),
('Omondi', 'Ochieng', 'omondi.o@company.co.ke', '0711000003', 3),
('Akinyi', 'Odhiambo', 'akinyi.o@company.co.ke', '0711000004', 4),
('Kipkemboi', 'Ruto', 'kipkemboi.r@company.co.ke', '0711000005', 5),
('Chebet', 'Kipkorir', 'chebet.k@company.co.ke', '0711000006', 2),
('Mutua', 'Musyoka', 'mutua.m@company.co.ke', '0711000007', 3),
('Mwikali', 'Kioko', 'mwikali.k@company.co.ke', '0711000008', 4),
('Hassan', 'Ali', 'hassan.a@company.co.ke', '0711000009', 1),
('Fatuma', 'Abdi', 'fatuma.a@company.co.ke', '0711000010', 5),
('Nekesa', 'Wanjala', 'nekesa.w@company.co.ke', '0711000011', 2),
('Wafula', 'Simiyu', 'wafula.s@company.co.ke', '0711000012', 3),
('Njeri', 'Karanja', 'njeri.k@company.co.ke', '0711000013', 4),
('Onyango', 'Otieno', 'onyango.o@company.co.ke', '0711000014', 2),
('Muthoni', 'Ndungu', 'muthoni.n@company.co.ke', '0711000015', 1),
('Kariuki', 'Maina', 'kariuki.m@company.co.ke', '0711000016', 5),
('Achieng', 'Owuor', 'achieng.o@company.co.ke', '0711000017', 3),
('Kiprop', 'Koech', 'kiprop.k@company.co.ke', '0711000018', 4),
('Jelagat', 'Kiptoo', 'jelagat.k@company.co.ke', '0711000019', 2),
('Odera', 'Ooko', 'odera.o@company.co.ke', '0711000020', 1),
('Atieno', 'Nyongesa', 'atieno.n@company.co.ke', '0711000021', 5),
('Moraa', 'Nyaboke', 'moraa.n@company.co.ke', '0711000022', 3),
('Osoro', 'Makori', 'osoro.m@company.co.ke', '0711000023', 4),
('Wawira', 'Njagi', 'wawira.n@company.co.ke', '0711000024', 2),
('Kinyua', 'Muriithi', 'kinyua.m@company.co.ke', '0711000025', 1),
('Halima', 'Said', 'halima.s@company.co.ke', '0711000026', 5),
('Mwende', 'Kilonzo', 'mwende.k@company.co.ke', '0711000027', 3),
('Wamalwa', 'Barasa', 'wamalwa.b@company.co.ke', '0711000028', 4),
('Naliaka', 'Wekesa', 'naliaka.w@company.co.ke', '0711000029', 2),
('Otiende', 'Amollo', 'otiende.a@company.co.ke', '0711000030', 1);

-- Insert Student Data
INSERT INTO Course (CourseName, Department) VALUES 
('BSc Computer Science', 'ICT'),
('Diploma in Business Management', 'Business Studies'),
('Bachelor of Education (Arts)', 'Education'),
('BSc Nursing', 'Health Sciences'),
('Diploma in Hospitality', 'Hospitality & Tourism');

INSERT INTO Student (FirstName, LastName, RegistrationNumber, PhoneNumber, CourseID) VALUES
('Brian', 'Kipruto', 'CS/26/001', '0722000001', 1), ('Alice', 'Wanjiku', 'BM/26/002', '0722000002', 2),
('Kevin', 'Otieno', 'ED/26/003', '0722000003', 3), ('Mercy', 'Akinyi', 'NS/26/004', '0722000004', 4),
('Ian', 'Mutua', 'HP/26/005', '0722000005', 5), ('Faith', 'Musyoka', 'CS/26/006', '0722000006', 1),
('Dennis', 'Wekesa', 'BM/26/007', '0722000007', 2), ('Diana', 'Nekesa', 'ED/26/008', '0722000008', 3),
('Evans', 'Kipchoge', 'NS/26/009', '0722000009', 4), ('Gladys', 'Chebet', 'HP/26/010', '0722000010', 5),
('Hillary', 'Ochieng', 'CS/26/011', '0722000011', 1), ('Irene', 'Awino', 'BM/26/012', '0722000012', 2),
('John', 'Maina', 'ED/26/013', '0722000013', 3), ('Jane', 'Njeri', 'NS/26/014', '0722000014', 4),
('Kelvin', 'Muriithi', 'HP/26/015', '0722000015', 5), ('Lydia', 'Wawira', 'CS/26/016', '0722000016', 1),
('Martin', 'Onyango', 'BM/26/017', '0722000017', 2), ('Naomi', 'Achieng', 'ED/26/018', '0722000018', 3),
('Oscar', 'Kipkorir', 'NS/26/019', '0722000019', 4), ('Pauline', 'Jelagat', 'HP/26/020', '0722000020', 5),
('Quincy', 'Odera', 'CS/26/021', '0722000021', 1), ('Ruth', 'Atieno', 'BM/26/022', '0722000022', 2),
('Samuel', 'Njoroge', 'ED/26/023', '0722000023', 3), ('Teresia', 'Muthoni', 'NS/26/024', '0722000024', 4),
('Victor', 'Kariuki', 'HP/26/025', '0722000025', 5), ('Winnie', 'Moraa', 'CS/26/026', '0722000026', 1),
('Xavier', 'Osoro', 'BM/26/027', '0722000027', 2), ('Yvonne', 'Kinyua', 'ED/26/028', '0722000028', 3),
('Zachary', 'Halima', 'NS/26/029', '0722000029', 4), ('Ann', 'Mwende', 'HP/26/030', '0722000030', 5),
('Ben', 'Wamalwa', 'CS/26/031', '0722000031', 1), ('Catherine', 'Naliaka', 'BM/26/032', '0722000032', 2),
('David', 'Otiende', 'ED/26/033', '0722000033', 3), ('Esther', 'Nyongesa', 'NS/26/034', '0722000034', 4),
('Felix', 'Makori', 'HP/26/035', '0722000035', 5), ('Grace', 'Njagi', 'CS/26/036', '0722000036', 1),
('Henry', 'Said', 'BM/26/037', '0722000037', 2), ('Ivy', 'Kilonzo', 'ED/26/038', '0722000038', 3),
('James', 'Barasa', 'NS/26/039', '0722000039', 4), ('Zablon', 'Wekesa', 'HP/26/040', '0722000040', 5);
GO

-- Insert Elections
INSERT INTO Election (ElectionName, StartDate, EndDate) VALUES 
('Staff Welfare Committee Election 2026', '2026-03-25', '2026-03-26'),
('Kenya Institute of Applied Sciences - Student Council 2026', '2026-04-10', '2026-04-11');

-- Insert Positions
INSERT INTO Position (PositionName) VALUES 
('Committee Chairperson'), ('Staff Secretary General'), -- Staff Positions (1, 2)
('Student President'), ('Vice President'), ('Academic Secretary'), ('Sports Rep'), ('Finance Secretary'); -- Student Positions (3-7)

-- Insert Candidates
INSERT INTO Candidate (StaffID, PositionID, ElectionID) VALUES 
(1, 1, 1), (3, 1, 1), (6, 1, 1), -- Staff Chairperson
(8, 2, 1), (10, 2, 1), (12, 2, 1), (15, 2, 1); -- Staff Sec Gen

INSERT INTO Candidate (StudentID, PositionID, ElectionID) VALUES 
(1, 3, 2), (11, 3, 2), -- Student Pres
(4, 4, 2), (14, 4, 2), -- Vice Pres
(7, 5, 2), (17, 5, 2), -- Academic Sec
(9, 6, 2), (19, 6, 2), -- Sports Rep
(2, 7, 2), (22, 7, 2); -- Finance Sec
GO

-- ============================================================================
-- 5. ACID TRANSACTIONS (Testing the Integrity)
-- ============================================================================
BEGIN TRY
    BEGIN TRANSACTION LiveVoting;
    
    -- Staff Vote
    INSERT INTO Vote (StaffID, CandidateID, PositionID, ElectionID) VALUES (2, 1, 1, 1);
    
    -- Student Vote
    INSERT INTO Vote (StudentID, CandidateID, PositionID, ElectionID) VALUES (3, 10, 4, 2);

    COMMIT TRANSACTION LiveVoting;
    PRINT 'SUCCESS: Transactions committed safely.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION LiveVoting;
    PRINT 'FAILED: Transaction rolled back.';
END CATCH
GO

-- ============================================================================
-- 6. RELATIONAL ALGEBRA PROOFS
-- ============================================================================

-- A. UNION (Set Theory): Combining domain sets into a single voter registry
SELECT FirstName, LastName, 'Staff Member' AS Demographics FROM Staff
UNION ALL
SELECT FirstName, LastName, 'Student' AS Demographics FROM Student
ORDER BY Demographics, FirstName;

-- B. CROSS JOIN (Cartesian Product): Showing all theoretical voting permutations for students
SELECT s.RegistrationNumber, p.PositionName
FROM Student s
CROSS JOIN Position p
WHERE p.PositionID >= 3;
GO