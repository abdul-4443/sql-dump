USE AbdulRehman_24L0725;
GO
-- Q1: Doctor Profiles: Create a view named v_doctor_info that displays a doctor's full name (first and last
-- combined), their specialization name, and their salary.
CREATE VIEW v_doctor_info AS
SELECT 
    d.fname + ' ' + d.lname AS full_name,
    s.sname AS specialization,
    d.salary
FROM doctor d
JOIN specialization s ON d.sno = s.snumber;
GO

-- Q2: Manager Directory: Create a view v_specialization_managers that shows each specialization name
-- alongside the name of the doctor managing it and their management start date.
CREATE VIEW v_specialization_managers AS
SELECT 
    s.sname AS specialization_name,
    d.fname + ' ' + d.lname AS manager_name,
    s.mgrstartdate
FROM specialization s
JOIN doctor d ON s.mgrssn = d.ssn;
GO

-- Q3: Family Support: Create a view v_doctor_dependents that lists all doctors who have dependents,
-- showing the doctor's last name, the dependent's name, and their relationship.
CREATE VIEW v_doctor_dependents AS
SELECT 
    d.lname AS doctor_last_name,
    dep.dependent_name,
    dep.relationship
FROM doctor d
JOIN dependent dep ON d.ssn = dep.essn;
GO

-- Q4: Surgery Overview: Create a view v_surgery_details that joins the surgery table with specialization to
-- show the surgery name, its location, and the name of the specialization it belongs to.
CREATE VIEW v_surgery_details AS
SELECT 
    su.sname AS surgery_name,
    su.slocation AS surgery_location,
    sp.sname AS specialization_name
FROM surgery su
JOIN specialization sp ON su.snum = sp.snumber;
GO

-- Q5: High Earners: Create a view v_senior_doctors that only shows doctors with a salary greater than
-- 60,000. Test if you can insert a new doctor through this view.
CREATE VIEW v_senior_doctors AS
SELECT *
FROM doctor
WHERE salary > 60000;
GO

INSERT INTO v_senior_doctors (fname, minit, lname, ssn, bdate, address, sex, salary, superssn, sno)
VALUES ('Ali', 'Z', 'Khan', '111222333', '1990-01-01', '10 Test St', 'M', 70000.00, NULL, 1);
GO

-- Q6: Get Doctor by Specialization: Create a procedure sp_GetDoctorsBySpec that takes a specialization
-- name as input and returns all doctors working in that field.
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
GO

-- Q8: Surgery Worklog: Create a procedure sp_AddSurgeryPerformance that inserts a new record into the
-- performed_by table. It should accept essn, sno, and hours as parameters.
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

EXEC sp_AddSurgeryPerformance '123456789', 3, 12.5;
GO

-- Q9: Dependent Count: Write a procedure sp_CountDependents that takes a doctor's ssn as an input and
-- returns the total number of dependents they have using an OUTPUT parameter.
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
PRINT @cnt;
GO

-- Q10: Specialization Transfer: Create a procedure sp_TransferDoctor that takes a doctor's ssn and a new
-- snumber. The procedure should update the doctor's specialization and also update their superssn to the
-- manager of that new specialization.
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
GO