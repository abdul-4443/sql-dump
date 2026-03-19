USE AbdulRehman_24L0725;
GO

-- Q1: Doctor Profiles: Create a view named v_doctor_info that displays a doctor's full name (first and last
-- combined), their specialization name, and their salary.
IF OBJECT_ID('v_doctor_info') IS NOT NULL DROP VIEW v_doctor_info;
GO
CREATE VIEW v_doctor_info AS
SELECT 
    d.fname + ' ' + d.lname AS full_name,
    s.sname AS specialization,
    d.salary
FROM doctor d
JOIN specialization s ON d.sno = s.snumber;
GO
SELECT * FROM v_doctor_info;
GO

-- Q2: Manager Directory: Create a view v_specialization_managers that shows each specialization name
-- alongside the name of the doctor managing it and their management start date.
IF OBJECT_ID('v_specialization_managers') IS NOT NULL DROP VIEW v_specialization_managers;
GO
CREATE VIEW v_specialization_managers AS
SELECT 
    s.sname AS specialization_name,
    d.fname + ' ' + d.lname AS manager_name,
    s.mgrstartdate
FROM specialization s
JOIN doctor d ON s.mgrssn = d.ssn;
GO
SELECT * FROM v_specialization_managers;
GO

-- Q3: Family Support: Create a view v_doctor_dependents that lists all doctors who have dependents,
-- showing the doctor's last name, the dependent's name, and their relationship.
IF OBJECT_ID('v_doctor_dependents') IS NOT NULL DROP VIEW v_doctor_dependents;
GO
CREATE VIEW v_doctor_dependents AS
SELECT 
    d.lname AS doctor_last_name,
    dep.dependent_name,
    dep.relationship
FROM doctor d
JOIN dependent dep ON d.ssn = dep.essn;
GO
SELECT * FROM v_doctor_dependents;
GO

-- Q4: Surgery Overview: Create a view v_surgery_details that joins the surgery table with specialization to
-- show the surgery name, its location, and the name of the specialization it belongs to.
IF OBJECT_ID('v_surgery_details') IS NOT NULL DROP VIEW v_surgery_details;
GO
CREATE VIEW v_surgery_details AS
SELECT 
    su.sname AS surgery_name,
    su.slocation AS surgery_location,
    sp.sname AS specialization_name
FROM surgery su
JOIN specialization sp ON su.snum = sp.snumber;
GO
SELECT * FROM v_surgery_details;
GO

-- Q5: High Earners: Create a view v_senior_doctors that only shows doctors with a salary greater than
-- 60,000. Test if you can insert a new doctor through this view.
IF OBJECT_ID('v_senior_doctors') IS NOT NULL DROP VIEW v_senior_doctors;
GO
CREATE VIEW v_senior_doctors AS
SELECT *
FROM doctor
WHERE salary > 60000;
GO
IF NOT EXISTS (SELECT * FROM doctor WHERE ssn = '111222333')
    INSERT INTO v_senior_doctors (fname, minit, lname, ssn, bdate, address, sex, salary, superssn, sno)
    VALUES ('Ali', 'Z', 'Khan', '111222333', '1990-01-01', '10 Test St', 'M', 70000.00, NULL, 1);
SELECT * FROM v_senior_doctors;
GO

-- Q6: Get Doctor by Specialization: Create a procedure sp_GetDoctorsBySpec that takes a specialization
-- name as input and returns all doctors working in that field.
IF OBJECT_ID('sp_GetDoctorsBySpec') IS NOT NULL DROP PROCEDURE sp_GetDoctorsBySpec;
GO
CREATE PROCEDURE sp_GetDoctorsBySpec
    @sname VARCHAR(25)
AS
BEGIN
    SELECT d.*
    FROM doctor d
    JOIN specialization s ON d.sno = s.snumber
    WHERE s.sname = @sname;
END;
GO
EXEC sp_GetDoctorsBySpec 'Cardiology';
GO

-- Q7: Update Salary: Write a procedure sp_RaiseSalary that takes a Doctor's ssn and a percentage
-- (e.g., 0.10 for 10%) and updates that doctor's salary in the database.
IF OBJECT_ID('sp_RaiseSalary') IS NOT NULL DROP PROCEDURE sp_RaiseSalary;
GO
CREATE PROCEDURE sp_RaiseSalary
    @ssn CHAR(9),
    @pct DECIMAL(5,2)
AS
BEGIN
    UPDATE doctor
    SET salary = salary + (salary * @pct)
    WHERE ssn = @ssn;
END;
GO
EXEC sp_RaiseSalary '123456789', 0.10;
SELECT ssn, salary FROM doctor WHERE ssn = '123456789';
GO

-- Q8: Surgery Worklog: Create a procedure sp_AddSurgeryPerformance that inserts a new record into the
-- performed_by table. It should accept essn, sno, and hours as parameters.
IF OBJECT_ID('sp_AddSurgeryPerformance') IS NOT NULL DROP PROCEDURE sp_AddSurgeryPerformance;
GO
CREATE PROCEDURE sp_AddSurgeryPerformance
    @essn CHAR(9),
    @sno INT,
    @hrs DECIMAL(4,1)
AS
BEGIN
    INSERT INTO performed_by (essn, sno, hours)
    VALUES (@essn, @sno, @hrs);
END;
GO
IF NOT EXISTS (SELECT * FROM performed_by WHERE essn = '456123789' AND sno = 1)
    EXEC sp_AddSurgeryPerformance '456123789', 1, 12.5;
SELECT * FROM performed_by WHERE essn = '456123789' AND sno = 1;
GO

-- Q9: Dependent Count: Write a procedure sp_CountDependents that takes a doctor's ssn as an input and
-- returns the total number of dependents they have using an OUTPUT parameter.
IF OBJECT_ID('sp_CountDependents') IS NOT NULL DROP PROCEDURE sp_CountDependents;
GO
CREATE PROCEDURE sp_CountDependents
    @ssn CHAR(9),
    @cnt INT OUTPUT
AS
BEGIN
    SELECT @cnt = COUNT(*)
    FROM dependent
    WHERE essn = @ssn;
END;
GO
DECLARE @cnt INT;
EXEC sp_CountDependents '123456789', @cnt OUTPUT;
PRINT 'Dependents for 123456789: ' + CAST(@cnt AS VARCHAR);
GO

-- Q10: Specialization Transfer: Create a procedure sp_TransferDoctor that takes a doctor's ssn and a new
-- snumber. The procedure should update the doctor's specialization and also update their superssn to the
-- manager of that new specialization.
IF OBJECT_ID('sp_TransferDoctor') IS NOT NULL DROP PROCEDURE sp_TransferDoctor;
GO
CREATE PROCEDURE sp_TransferDoctor
    @ssn CHAR(9),
    @sno INT
AS
BEGIN
    DECLARE @mgr CHAR(9);

    SELECT @mgr = mgrssn
    FROM specialization
    WHERE snumber = @sno;

    UPDATE doctor
    SET sno = @sno,
        superssn = @mgr
    WHERE ssn = @ssn;
END;
GO
EXEC sp_TransferDoctor '321654987', 3;
SELECT ssn, sno, superssn FROM doctor WHERE ssn = '321654987';
GO