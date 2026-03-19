CREATE TABLE Organization (
    id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    streetAddress VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(50),
    zip VARCHAR(20),
    phone VARCHAR(20)
);

CREATE TABLE Programs (
    id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    directorate VARCHAR(255)
);

CREATE TABLE Managers (
    id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE Fields (
    id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE Researchers (
    id INT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    orgId INT,
    FOREIGN KEY (orgId) REFERENCES Organization(id)
);

CREATE TABLE Grants (
    id INT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    amount DECIMAL(15, 2),
    orgId INT,
    principaIInvestigator INT,
    managerId INT,
    startedDate DATE,
    endedDate DATE,
    FOREIGN KEY (orgId) REFERENCES Organization(id),
    FOREIGN KEY (principaIInvestigator) REFERENCES Researchers(id),
    FOREIGN KEY (managerId) REFERENCES Managers(id)
);

CREATE TABLE GrantResearchers (
    Researcherid INT,
    grantId INT,
    PRIMARY KEY (Researcherid, grantId),
    FOREIGN KEY (Researcherid) REFERENCES Researchers(id),
    FOREIGN KEY (grantId) REFERENCES Grants(id)
);

CREATE TABLE GrantFields (
    GrantId INT,
    fieldId INT,
    PRIMARY KEY (GrantId, fieldId),
    FOREIGN KEY (GrantId) REFERENCES Grants(id),
    FOREIGN KEY (fieldId) REFERENCES Fields(id)
);

CREATE TABLE GrantPrograms (
    GrantId INT,
    programId INT,
    PRIMARY KEY (GrantId, programId),
    FOREIGN KEY (GrantId) REFERENCES Grants(id),
    FOREIGN KEY (programId) REFERENCES Programs(id)
);

INSERT INTO Organization (id, name, streetAddress, city, state, zip, phone) VALUES
(1, 'Tech University', '123 Campus Dr', 'Lahore', 'Punjab', '54000', '123-456-7890'),
(2, 'Global Research Inst', '45 Science Way', 'Lahore', 'Punjab', '54000', '098-765-4321');

INSERT INTO Programs (id, name, directorate) VALUES
(1, 'AI Innovation', 'Computer Science'),
(2, 'Quantum Computing', 'Physics');

INSERT INTO Managers (id, name) VALUES
(1, 'Alice Smith'),
(2, 'James Doe');

INSERT INTO Fields (id, name) VALUES
(1, 'Machine Learning'),
(2, 'Data Science');

INSERT INTO Researchers (id, name, orgId) VALUES
(1, 'Dr. Bob Jones', 1),
(2, 'Sarah Connor', 1),
(3, 'Dr. Emily Chen', 2);

INSERT INTO Grants (id, title, amount, orgId, principaIInvestigator, managerId, startedDate, endedDate) VALUES
(1, 'Neural Networks Study', 50000.00, 1, 1, 1, '2026-01-01', '2026-12-31'),
(2, 'Data Privacy Framework', 75000.00, 2, 3, 2, '2026-03-15', '2027-03-14');

INSERT INTO GrantResearchers (Researcherid, grantId) VALUES
(1, 1),
(2, 1),
(3, 2);

INSERT INTO GrantFields (GrantId, fieldId) VALUES
(1, 1),
(2, 2);

INSERT INTO GrantPrograms (GrantId, programId) VALUES
(1, 1),
(2, 1);

INSERT INTO Organization (id, name, streetAddress, city, state, zip, phone) VALUES
(3, 'Health Foundation', '789 Med Ln', 'Karachi', 'Sindh', '75000', '111-222-3333'),
(4, 'Science Institute', '101 Data Dr', 'Islamabad', 'Federal', '44000', '444-555-6666');

INSERT INTO Programs (id, name, directorate) VALUES
(3, 'Isbah', 'General Sciences'),
(4, 'RoBoBtic', 'Engineering'), 
(5, 'Edu 2024', 'Education'),
(6, 'SpaceXploration', 'Astronomy');

INSERT INTO Managers (id, name) VALUES
(3, 'Aisha Khan'),
(4, 'Tariq'),
(5, 'Safa');

INSERT INTO Fields (id, name) VALUES
(3, 'Robotics'),
(4, 'Public Health');

INSERT INTO Researchers (id, name, orgId) VALUES
(4, 'Tariq', 1),
(5, 'Shafiq', 2),
(6, 'Faruq', 3),
(7, 'Tahreem', 1),
(8, 'Ali', 2),
(9, 'Aisha Khan', 3);

INSERT INTO Grants (id, title, amount, orgId, principaIInvestigator, managerId, startedDate, endedDate) VALUES
(3, 'Summer 2025 Study', 150000.00, 1, 8, 3, '2025-07-05', '2026-01-05'),
(4, 'Early Ed Grant', 250000.00, 3, 7, 5, '2024-08-01', '2025-05-01'),
(5, 'Tahreem Second Grant', 50000.00, 1, 7, 1, '2026-01-01', '2026-12-31'),
(6, 'Q Grant 1', 600000.00, 2, 4, 3, '2026-01-01', '2026-12-31'),
(7, 'Q Grant 2', 500000.00, 1, 5, 2, '2026-01-01', '2026-12-31'),
(8, 'Q Grant 3', 400000.00, 3, 6, 1, '2026-01-01', '2026-12-31'),
(9, 'Massive Project', 1500000.00, 2, 8, 3, '2026-01-01', '2026-12-31'),
(10, 'Small Research', 25000.00, 4, 9, 4, '2025-07-15', '2026-01-15');

INSERT INTO GrantResearchers (Researcherid, grantId) VALUES
(8, 3),
(7, 4),
(7, 5),
(4, 6),
(5, 7),
(6, 8),
(8, 9),
(9, 10);

INSERT INTO GrantFields (GrantId, fieldId) VALUES
(3, 3),
(4, 4),
(5, 1),
(6, 3),
(7, 2),
(8, 4),
(9, 1),
(10, 2);

INSERT INTO GrantPrograms (GrantId, programId) VALUES
(3, 6),
(4, 5),
(5, 3),
(6, 4),
(7, 4),
(8, 3),
(9, 6),
(10, 5);

--1.
SELECT * 
FROM Grants
WHERE YEAR(startedDate) = 2025
AND MONTH(startedDate) = 7
AND YEAR(endedDate) = 2026
AND MONTH(endedDate) = 1

SELECT *
FROM Grants
WHERE startedDate >= '2025-07-01'
AND startedDate < '2025-08-01'
AND endedDate >= '2026-01-01'
AND endedDate < '2026-02-01';

--2.
SELECT *
FROM Programs
WHERE (name LIKE '__B%' 
	OR name LIKE '____B%')
	AND name LIKE '%B___'

--3.
SELECT *
FROM Grants
WHERE amount > 100000 AND amount < 300000

--4.
SELECT TOP 2 name 
FROM Researchers

--5
SELECT *
FROM Grants
WHERE amount = (
    SELECT MIN(amount)
    FROM (
        SELECT DISTINCT TOP 3 amount
        FROM Grants G
        JOIN Researchers R ON G.principaIInvestigator = R.id
        WHERE R.name LIKE '%Q' OR R.name LIKE '%q'
        ORDER BY amount DESC
    ) AS TopThreeAmounts
);

--Write a query to get the names of organizations 
--which administers grants with amount 
--greater than the average grant amount
SELECT DISTINCT Organization.name
FROM Organization
JOIN Grants ON Organization.id = Grants.orgId
WHERE Grants.amount > (SELECT AVG(amount) FROM Grants);

--7
SELECT name FROM Researchers
INTERSECT
SELECT name FROM Managers;

--8
SELECT DISTINCT Programs.name
FROM Programs
JOIN GrantPrograms ON Programs.id = GrantPrograms.programId
JOIN Grants ON GrantPrograms.GrantId = Grants.id
WHERE (Grants.startedDate BETWEEN '2024-07-01' AND '2025-06-30')
   OR (Grants.endedDate BETWEEN '2024-07-01' AND '2025-06-30');

--9
SELECT Grants.amount
FROM Grants
JOIN GrantResearchers ON Grants.id = GrantResearchers.grantId
JOIN Researchers ON GrantResearchers.Researcherid = Researchers.id
WHERE Researchers.name = 'Tahreem'
ORDER BY Grants.amount;

--10
SELECT name 
FROM Researchers
WHERE name NOT IN (SELECT name FROM Managers);

--11
SELECT Grants.*
FROM Grants
JOIN Managers ON Grants.managerId = Managers.id
WHERE Managers.name LIKE 'a%' OR Managers.name LIKE '%a';

--12
SELECT * 
FROM Grants
WHERE amount < (SELECT MAX(amount) FROM Grants);