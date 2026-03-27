-- Q1
CREATE VIEW v_ManagerDepth AS
WITH HierarchyCTE AS (
    SELECT ssn, 0 AS supervisor_count
    FROM doctor
    WHERE superssn IS NULL
    UNION ALL
    SELECT d.ssn, h.supervisor_count + 1
    FROM doctor d
    INNER JOIN HierarchyCTE h ON d.superssn = h.ssn
)
SELECT 
    d.fname + ' ' + d.lname AS full_name, 
    s.sname AS spec_name, 
    hc.supervisor_count
FROM doctor d
JOIN specialization s ON d.sno = s.snumber
JOIN HierarchyCTE hc ON d.ssn = hc.ssn;
GO

-- Q2. v_CrossSpecDoctors
CREATE VIEW v_CrossSpecDoctors AS
SELECT
    d.fname + ' ' + d.lname AS doc_name,
    s.sname                  AS doc_spec,
    COUNT(pb.sno)            AS cross_surg_count
FROM performed_by pb
JOIN doctor         d  ON pb.essn = d.ssn
JOIN surgery        sr ON pb.sno  = sr.snumber
JOIN specialization s  ON d.sno   = s.snumber
WHERE d.sno <> sr.snum
GROUP BY d.ssn, d.fname, d.lname, s.sname;
GO
-- Q3. v_InvalidSurgeryLocations
CREATE VIEW v_InvalidSurgeryLocations AS
SELECT
    sr.sname     AS surg_name,
    sr.slocation AS surg_loc,
    sp.sname     AS spec_name,
    CASE
        WHEN sl.slocation IS NOT NULL THEN 'VALID'
        ELSE 'INVALID'
    END          AS loc_status
FROM surgery sr
JOIN specialization  sp ON sr.snum     = sp.snumber
LEFT JOIN spec_locations sl
    ON  sl.snumber   = sr.snum
    AND sl.slocation = sr.slocation;
GO
-- Q4. v_OverloadedManagers
CREATE VIEW v_OverloadedManagers AS
SELECT
    mgr.fname + ' ' + mgr.lname AS mgr_name,
    COUNT(DISTINCT sub.ssn)      AS team_size,
    ISNULL(SUM(pb.hours), 0)     AS team_total_hrs
FROM doctor mgr
JOIN doctor        sub ON sub.superssn = mgr.ssn
LEFT JOIN performed_by pb ON pb.essn   = sub.ssn
WHERE EXISTS (
    SELECT 1 FROM specialization sp WHERE sp.mgrssn = mgr.ssn
)
GROUP BY mgr.ssn, mgr.fname, mgr.lname;
GO
-- Q5. v_DependencyBurden
CREATE VIEW v_DependencyBurden AS
SELECT TOP (100) PERCENT
    d.fname + ' ' + d.lname AS doc_name,
    d.salary,
    COUNT(dep.dependent_name) AS dep_count,
    CASE
        WHEN d.salary = 0 THEN NULL
        ELSE CAST(COUNT(dep.dependent_name) AS DECIMAL(10,6)) / d.salary
    END AS burden_idx
FROM doctor d
LEFT JOIN dependent dep ON dep.essn = d.ssn
GROUP BY d.ssn, d.fname, d.lname, d.salary
ORDER BY burden_idx DESC;
GO
-- Q6. sp_ReassignToBalancedSpec
CREATE PROCEDURE sp_ReassignToBalancedSpec
    @doc_ssn CHAR(9)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @target_sno INT, @target_mgr CHAR(9), @curr_sno INT;

    SELECT @curr_sno = sno FROM doctor WHERE ssn = @doc_ssn;

    SELECT TOP 1
        @target_sno = sp.snumber,
        @target_mgr = sp.mgrssn
    FROM specialization sp
    LEFT JOIN doctor d ON d.sno = sp.snumber
    WHERE sp.snumber <> @curr_sno
    GROUP BY sp.snumber, sp.mgrssn
    ORDER BY COUNT(d.ssn) ASC;

    UPDATE doctor
    SET sno = @target_sno, superssn = @target_mgr
    WHERE ssn = @doc_ssn;
END;
GO
-- Q7. sp_RedistributeSurgeryHours
CREATE PROCEDURE sp_RedistributeSurgeryHours
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @e_ssn CHAR(9), @s_no INT, @cur_hrs DECIMAL(4,1),
            @cut_hrs DECIMAL(6,2), @others_cnt INT, @share DECIMAL(6,2);

    DECLARE over_cur CURSOR FOR
        SELECT essn, sno, hours FROM performed_by WHERE hours > 30;

    OPEN over_cur;
    FETCH NEXT FROM over_cur INTO @e_ssn, @s_no, @cur_hrs;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @cut_hrs = @cur_hrs * 0.20;

        SELECT @others_cnt = COUNT(*)
        FROM performed_by
        WHERE sno = @s_no AND essn <> @e_ssn;

        UPDATE performed_by
        SET hours = hours - @cut_hrs
        WHERE essn = @e_ssn AND sno = @s_no;

        IF @others_cnt > 0
        BEGIN
            SET @share = @cut_hrs / @others_cnt;
            UPDATE performed_by
            SET hours = hours + @share
            WHERE sno = @s_no AND essn <> @e_ssn;
        END

        FETCH NEXT FROM over_cur INTO @e_ssn, @s_no, @cur_hrs;
    END

    CLOSE over_cur;
    DEALLOCATE over_cur;
END;
GO
-- Q8. sp_FixSupervisorCycles
CREATE PROCEDURE sp_FixSupervisorCycles
AS
BEGIN
    SET NOCOUNT ON;

    WITH ChainCTE AS (
        SELECT
            ssn AS origin_ssn, superssn AS next_ssn, ssn AS current_ssn,
            0 AS steps, CAST(ssn AS VARCHAR(MAX)) AS visited_path
        FROM doctor WHERE superssn IS NOT NULL
        UNION ALL
        SELECT
            c.origin_ssn, d.superssn, d.ssn, c.steps + 1,
            c.visited_path + ',' + d.ssn
        FROM ChainCTE c
        JOIN doctor d ON d.ssn = c.next_ssn
        WHERE d.superssn IS NOT NULL
          AND c.steps < 20
          AND CHARINDEX(d.ssn, c.visited_path) = 0
    )
    UPDATE doctor
    SET superssn = NULL
    WHERE ssn IN (
        SELECT current_ssn FROM ChainCTE
        WHERE next_ssn = origin_ssn
    );
END;
GO
-- Q9. sp_ReplaceManager
CREATE PROCEDURE sp_ReplaceManager
    @spec_no     INT,
    @new_mgr_ssn CHAR(9)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @old_mgr_ssn CHAR(9), @new_mgr_sno INT;

    SELECT @new_mgr_sno = sno FROM doctor WHERE ssn = @new_mgr_ssn;

    IF @new_mgr_sno <> @spec_no
    BEGIN
        RAISERROR('New manager does not belong to the specified specialization.', 16, 1);
        RETURN;
    END

    SELECT @old_mgr_ssn = mgrssn FROM specialization WHERE snumber = @spec_no;

    BEGIN TRANSACTION;
    BEGIN TRY
        UPDATE specialization
        SET mgrssn = @new_mgr_ssn
        WHERE snumber = @spec_no;

        UPDATE doctor
        SET superssn = @new_mgr_ssn
        WHERE superssn = @old_mgr_ssn AND sno = @spec_no;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO
-- Q10. sp_DeleteDoctorCascade
CREATE PROCEDURE sp_DeleteDoctorCascade
    @del_ssn CHAR(9)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @supervisor_ssn CHAR(9), @doc_sno INT, @alt_doc_ssn CHAR(9);

    SELECT @supervisor_ssn = superssn, @doc_sno = sno
    FROM doctor WHERE ssn = @del_ssn;

    BEGIN TRANSACTION;
    BEGIN TRY
        IF @supervisor_ssn IS NOT NULL
            UPDATE dependent SET essn = @supervisor_ssn WHERE essn = @del_ssn;
        ELSE
            DELETE FROM dependent WHERE essn = @del_ssn;

        SELECT TOP 1 @alt_doc_ssn = ssn
        FROM doctor WHERE sno = @doc_sno AND ssn <> @del_ssn;

        IF @alt_doc_ssn IS NOT NULL
        BEGIN
            UPDATE performed_by
            SET essn = @alt_doc_ssn
            WHERE essn = @del_ssn
              AND sno NOT IN (SELECT sno FROM performed_by WHERE essn = @alt_doc_ssn);
        END
        DELETE FROM performed_by WHERE essn = @del_ssn;

        UPDATE specialization
        SET mgrssn = @supervisor_ssn
        WHERE mgrssn = @del_ssn;

        UPDATE doctor
        SET superssn = @supervisor_ssn
        WHERE superssn = @del_ssn;

        DELETE FROM doctor WHERE ssn = @del_ssn;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO