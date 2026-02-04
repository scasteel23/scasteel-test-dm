SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/



-- NS 6/11/2019
CREATE PROC [dbo].[FSDB_DM_Upload_Logs_record_Log]
(
	@EDWPERSID_Table as FSDB_DM_Upload_EDWPERSID_activity READONLY
	,@activity varchar(60)
)
AS

	/*
		CREATE TYPE FSDB_DM_UploAd_EDWPERSID_activity AS TABLE   
		( EDWPERSID VARCHAR(10), Activity varchar(60));  
	*/
	-- @activity  == 'New Employee','Re-Entry','New USERNAME', 'Terminated'
	INSERT INTO dbo.FSDB_DM_Upload_Logs (
			[FACSTAFFID]
			,[UIN]
			,[EDWPERSID]
			,[USERNAME]
			,[USERID]
			,[BANNER_FNAME]
			,[BANNER_MNAME]
			,[BANNER_LNAME]
			,DM_Department_Name
			,[EMPEE_DEPT_NAME]
			,[EMPEE_CLS_LONG_DESC]
			,[EMPEE_GROUP_DESC]
			,[FAC_RANK_DESC]
			--,[FIRST_HIRE_DT]
			--,[CUR_HIRE_DT]
			--,[FIRST_WORK_DT]
			--,[LAST_WORK_DT]
			,[College_Sum_FTE]
			,[Univ_Sum_FTE]
			,Doctoral_Flag
			,[Activity]
			,[Current_Indicator]
			,[Create_Datetime]
	)
	SELECT
			dmpci.[FACSTAFFID]
			,fsdb.[UIN]
			,fsdb.[EDW_PERS_ID]
			,dmpci.[USERNAME]
			,dmpci.[USERID]
			,dmpci.[BANNER_FNAME]
			,dmpci.[BANNER_MNAME]
			,dmpci.[BANNER_LNAME]
			,fsdb.DM_Department_Name
			,fsdb.[EMPEE_DEPT_NAME]
			,fsdb.[EMPEE_CLS_LONG_DESC]
			,fsdb.[EMPEE_GROUP_DESC]
			,fsdb.[FAC_RANK_DESC]
			--,fsdb.[FIRST_HIRE_DT]
			--,fsdb.[CUR_HIRE_DT]
			--,fsdb.[FIRST_WORK_DT]
			--,fsdb.[LAST_WORK_DT]
			,fsdb.[College_Sum_FTE]
			,fsdb.[Univ_Sum_FTE]
			,fsdb.Doctoral_Flag
			,@Activity
			,1
			,GETDATE()
	FROM dbo.FSDB_Facstaff_Basic fsdb
			INNER JOIN dbo._DM_PCI dmpci
			ON dmpci.edwpersid = fsdb.edw_pers_id				
	WHERE fsdb.EDW_PERS_ID IN (SELECT EDWPERSID FROM @EDWPERSID_Table)

	IF @activity = 'Terminated'
		BEGIN
			

			--DECLARE @deptname varchar(300)
			--SET @deptname = NULL
			--SELECT @deptname=COALESCE(@deptname +',','') + m1.DEP
			--FROM DM_Shadow_Staging.dbo._DM_ADMIN_DEP m1
			--		LEFT JOIN DM_Shadow_Staging.dbo._DM_ADMIN_DEP m2
			--		ON m1.USERNAME = m2.USERNAME  AND m1.AC_YEAR < m2.AC_YEAR
			--			AND m1.USERNAME is not NULL		
			--WHERE m2.AC_YEAR is NULL AND m1.EDWPERSID IN (SELECT EDWPERSID FROM @EDWPERSID_Table)

			UPDATE dbo.FSDB_DM_Upload_Logs
			SET DM_Department_Name = dbo.FSDB_DM_Upload_Logs_get_department_names (EDWPERSID)
			WHERE EDWPERSID IN (SELECT EDWPERSID FROM @EDWPERSID_Table)
				 and Current_Indicator = 1


		END
GO
