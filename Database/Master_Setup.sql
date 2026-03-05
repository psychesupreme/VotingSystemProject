/* ================================================================
PROJECT: Secure Multi-Election Voting System
DESCRIPTION: Run this script to setup the database, 100 voters, 
             and candidates for testing.
================================================================
*/

-- 1. Create Tables
CREATE TABLE Voter (
    VoterID INT PRIMARY KEY IDENTITY(1,1),
    FirstName VARCHAR(50),
    LastName VARCHAR(50),
    DateOfBirth DATE,
    Email VARCHAR(100),
    PhoneNumber VARCHAR(20),
    Location VARCHAR(100),
    RegistrationDate DATETIME DEFAULT GETDATE()
);

CREATE TABLE Election (
    ElectionID INT PRIMARY KEY IDENTITY(1,1),
    ElectionName VARCHAR(100),
    StartDate DATETIME,
    EndDate DATETIME
);

CREATE TABLE Position (
    PositionID INT PRIMARY KEY IDENTITY(1,1),
    PositionName VARCHAR(100)
);

CREATE TABLE Candidate (
    CandidateID INT PRIMARY KEY IDENTITY(1,1),
    VoterID INT FOREIGN KEY REFERENCES Voter(VoterID),
    PositionID INT FOREIGN KEY REFERENCES Position(PositionID),
    ElectionID INT FOREIGN KEY REFERENCES Election(ElectionID)
);

CREATE TABLE Vote (
    VoteID INT PRIMARY KEY IDENTITY(1,1),
    VoterID INT FOREIGN KEY REFERENCES Voter(VoterID),
    CandidateID INT FOREIGN KEY REFERENCES Candidate(CandidateID),
    PositionID INT FOREIGN KEY REFERENCES Position(PositionID),
    VoteTime DATETIME DEFAULT GETDATE(),
    CONSTRAINT UQ_Voter_Position UNIQUE(VoterID, PositionID)
);
GO

-- 2. Insert Core Data
INSERT INTO Election (ElectionName, StartDate, EndDate) VALUES 
('Kenya General Election 2027', '2027-08-10', '2027-08-11'),
('University Student Elections 2026', '2026-05-01', '2026-05-02');

INSERT INTO Position (PositionName) VALUES 
('President of Kenya'), ('Governor of Nairobi'), 
('Student Body President'), ('Secretary General');
GO

-- 3. Generate 100 Realistic Voters
DECLARE @i INT = 1;
WHILE @i <= 100
BEGIN
    INSERT INTO Voter (FirstName, LastName, DateOfBirth, Email, PhoneNumber, Location)
    VALUES ('Voter', 'Person_' + CAST(@i AS VARCHAR), '2000-01-01', 
            'voter' + CAST(@i AS VARCHAR) + '@example.com', '0700000000', 'Kenya');
    SET @i = @i + 1;
END;
GO

-- 4. Create Audit View
CREATE VIEW vw_VotingAudit AS
SELECT 
    v.VoteTime, e.ElectionName, p.PositionName,
    vr.FirstName + ' ' + vr.LastName AS VoterName,
    cv.FirstName + ' ' + cv.LastName AS CandidateName
FROM Vote v
JOIN Voter vr ON v.VoterID = vr.VoterID
JOIN Candidate c ON v.CandidateID = c.CandidateID
JOIN Voter cv ON c.VoterID = cv.VoterID
JOIN Position p ON c.PositionID = p.PositionID
JOIN Election e ON c.ElectionID = e.ElectionID;
GO