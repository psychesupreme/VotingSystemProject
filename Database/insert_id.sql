-- Insert Staff Candidates (Election 1)
INSERT INTO Candidate (StaffID, PositionID, ElectionID) VALUES 
(1, 1, 1), -- Kamau (Chairperson) - Becomes Candidate ID 9
(3, 1, 1), -- Omondi (Chairperson) - Becomes Candidate ID 10
(2, 2, 1), -- Wanjiku (Sec Gen) - Becomes Candidate ID 11
(4, 2, 1); -- Akinyi (Sec Gen) - Becomes Candidate ID 12

-- Insert Student Candidates (Election 2)
INSERT INTO Candidate (StudentID, PositionID, ElectionID) VALUES 
(1, 3, 2), -- Brian (Student President) - Becomes Candidate ID 13
(2, 3, 2), -- Alice (Student President) - Becomes Candidate ID 14
(3, 4, 2), -- Kevin (Vice President) - Becomes Candidate ID 15
(4, 4, 2); -- Mercy (Vice President) - Becomes Candidate ID 16
GO