/*SELECT*
FROM Grants
WHERE startedDate >= '2025-07-01' AND startedDate < '2025-08-01' AND
	endedDate = DATEADD(MONTH, 6, startedDate)*/

/*SELECT*
FROM Programs
WHERE (
	(name LIKE '__B%'
	OR name LIKE '____B%')
	AND name LIKE '%B___'
)*/

/*SELECT*
FROM Grants
WHERE amount BETWEEN 100000 AND 300000*/

/*SELECT TOP 2 name
FROM Researchers*/

/*SELECT *
FROM Grants G
JOIN GrantResearchers GR ON G.id = GR.grantId
JOIN Researchers R ON GR.Researcherid = R.id

WHERE (R.name LIKE '%Q' OR R.name LIKE '%q')
ORDER BY G.amount DESC, G.id ASC
OFFSET 2 ROWS FETCH NEXT 1 ROW ONLY*/


/*SELECT DISTINCT name
FROM Organization O
JOIN Grants ON O.id = orgId
WHERE amount > (
	SELECT AVG(amount) FROM Grants
)*/

/*SELECT name FROM Researchers
INTERSECT
SELECT name FROM Managers*/


/*SELECT DISTINCT name FROM Programs
JOIN GrantPrograms ON Programs.id = GrantPrograms.programId
JOIN Grants ON GrantPrograms.GrantId = Grants.id
WHERE (startedDate BETWEEN '2024-07-01' AND '2025-06-01') OR
	(endedDate BETWEEN '2024-07-01' AND '2025-06-01')*/

/*SELECT amount FROM Grants
JOIN GrantResearchers ON Grants.id = GrantResearchers.grantId
JOIN Researchers ON GrantResearchers.Researcherid = Researchers.id
WHERE Researchers.name = 'Tahreem'
ORDER BY amount*/

/*SELECT name FROM Researchers
EXCEPT
SELECT name FROM Managers*/

/*SELECT * FROM Grants
JOIN Managers ON Grants.managerId = Managers.id
WHERE Managers.name LIKE 'a%' OR Managers.name LIKE '%a'*/

/*SELECT* FROM Grants
WHERE amount < (SELECT MAX(amount) FROM Grants)*/