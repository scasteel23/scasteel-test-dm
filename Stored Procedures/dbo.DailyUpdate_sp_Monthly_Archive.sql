SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 1/18/2024
CREATE PROC [dbo].[DailyUpdate_sp_Monthly_Archive] 
AS
	BEGIN
		BEGIN TRY
        
			DECLARE @cutoff_date DATETIME, @count_delete INT, @count_archive INT, @max_avail_date DATETIME
			SET @cutoff_date = DATEADD(mm,-8, GETDATE())

			SELECT  @count_delete=COUNT(*)
            FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
			WHERE Create_Datetime < @cutoff_date

			SELECT @max_avail_date=MAX(create_datetime)
			FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees_History

			INSERT INTO DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees_History
			(
				   [EDW_PERS_ID]
				  ,[UIN]
				  ,[Network_ID]
				  ,[EDW_Database]
				  ,[PERS_PREFERRED_FNAME]
				  ,[PERS_FNAME]
				  ,[PERS_MNAME]
				  ,[PERS_LNAME]
				  ,[BIRTH_DT]
				  ,[SEX_CD]
				  ,[RACE_ETH_CD]
				  ,[RACE_ETH_DESC]
				  ,[PERS_CITZN_TYPE_DESC]
				  ,[EMPEE_CAMPUS_CD]
				  ,[EMPEE_CAMPUS_NAME]
				  ,[EMPEE_COLL_CD]
				  ,[EMPEE_COLL_NAME]
				  ,[EMPEE_DEPT_CD]
				  ,[EMPEE_DEPT_NAME]
				  ,[JOB_DETL_TITLE]
				  ,[JOB_DETL_FTE]
				  ,[JOB_CNTRCT_TYPE_DESC]
				  ,[JOB_DETL_DATA_STATUS_DESC]
				  ,[JOB_DETL_COLL_CD]
				  ,[JOB_DETL_COLL_NAME]
				  ,[JOB_DETL_DEPT_CD]
				  ,[JOB_DETL_DEPT_NAME]
				  ,[COA_CD]
				  ,[ORG_CD]
				  ,[EMPEE_ORG_TITLE]
				  ,[EMPEE_CLS_CD]
				  ,[EMPEE_CLS_LONG_DESC]
				  ,[EMPEE_GROUP_CD]
				  ,[EMPEE_GROUP_DESC]
				  ,[EMPEE_RET_IND]
				  ,[EMPEE_LEAVE_CATGRY_CD]
				  ,[EMPEE_LEAVE_CATGRY_DESC]
				  ,[BNFT_CATGRY_CD]
				  ,[BNFT_CATGRY_DESC]
				  ,[HR_CAMPUS_CD]
				  ,[HR_CAMPUS_NAME]
				  ,[EMPEE_STATUS_CD]
				  ,[EMPEE_STATUS_DESC]
				  ,[CAMPUS_JOB_DETL_FTE]
				  ,[COLLEGE_JOB_DETL_FTE]
				  ,[Univ_Sum_FTE]
				  ,[Sum_FTE]
				  ,[FAC_RANK_CD]
				  ,[FAC_RANK_DESC]
				  ,[FAC_RANK_ACT_DT]
				  ,[FAC_RANK_DECN_DT]
				  ,[FAC_RANK_ACAD_TITLE]
				  ,[FAC_RANK_EMRTS_STATUS_IND]
				  ,[TENURE_INDICATOR]
				  ,[FIRST_HIRE_DT]
				  ,[CUR_HIRE_DT]
				  ,[FIRST_WORK_DT]
				  ,[LAST_WORK_DT]
				  ,[EMPEE_TERMN_DT]
				  ,[JOB_SUFFIX]
				  ,[POSN_NBR]
				  ,[JOB_DETL_EEO_SKILL_CD]
				  ,[JOB_DETL_EEO_SKILL_DESC]
				  ,[JOB_DETL_EFF_DT]
				  ,[POSN_EMPEE_CLS_CD]
				  ,[POSN_EMPEE_CLS_LONG_DESC]
				  ,[EMPEE_SUB_DEPT_LEVEL_6_CD]
				  ,[EMPEE_SUB_DEPT_LEVEL_6_NAME]
				  ,[EMPEE_SUB_DEPT_LEVEL_7_CD]
				  ,[EMPEE_SUB_DEPT_LEVEL_7_NAME]
				  ,[NATION_CD]
				  ,[Banner_EMPEE_GROUP_CD]
				  ,[Banner_EMPEE_GROUP_DESC]
				  ,[Banner_EMPEE_CLS_CD]
				  ,[Banner_EMPEE_CLS_LONG_DESC]
				  ,[Update_Employee_Indicator]
				  ,[New_Download_Indicator]
				  ,[DM_Upload_Done_Indicator]
				  ,[Create_Datetime]
			)
			SELECT  [EDW_PERS_ID]
				  ,[UIN]
				  ,[Network_ID]
				  ,[EDW_Database]
				  ,[PERS_PREFERRED_FNAME]
				  ,[PERS_FNAME]
				  ,[PERS_MNAME]
				  ,[PERS_LNAME]
				  ,[BIRTH_DT]
				  ,[SEX_CD]
				  ,[RACE_ETH_CD]
				  ,[RACE_ETH_DESC]
				  ,[PERS_CITZN_TYPE_DESC]
				  ,[EMPEE_CAMPUS_CD]
				  ,[EMPEE_CAMPUS_NAME]
				  ,[EMPEE_COLL_CD]
				  ,[EMPEE_COLL_NAME]
				  ,[EMPEE_DEPT_CD]
				  ,[EMPEE_DEPT_NAME]
				  ,[JOB_DETL_TITLE]
				  ,[JOB_DETL_FTE]
				  ,[JOB_CNTRCT_TYPE_DESC]
				  ,[JOB_DETL_DATA_STATUS_DESC]
				  ,[JOB_DETL_COLL_CD]
				  ,[JOB_DETL_COLL_NAME]
				  ,[JOB_DETL_DEPT_CD]
				  ,[JOB_DETL_DEPT_NAME]
				  ,[COA_CD]
				  ,[ORG_CD]
				  ,[EMPEE_ORG_TITLE]
				  ,[EMPEE_CLS_CD]
				  ,[EMPEE_CLS_LONG_DESC]
				  ,[EMPEE_GROUP_CD]
				  ,[EMPEE_GROUP_DESC]
				  ,[EMPEE_RET_IND]
				  ,[EMPEE_LEAVE_CATGRY_CD]
				  ,[EMPEE_LEAVE_CATGRY_DESC]
				  ,[BNFT_CATGRY_CD]
				  ,[BNFT_CATGRY_DESC]
				  ,[HR_CAMPUS_CD]
				  ,[HR_CAMPUS_NAME]
				  ,[EMPEE_STATUS_CD]
				  ,[EMPEE_STATUS_DESC]
				  ,[CAMPUS_JOB_DETL_FTE]
				  ,[COLLEGE_JOB_DETL_FTE]
				  ,[Univ_Sum_FTE]
				  ,[Sum_FTE]
				  ,[FAC_RANK_CD]
				  ,[FAC_RANK_DESC]
				  ,[FAC_RANK_ACT_DT]
				  ,[FAC_RANK_DECN_DT]
				  ,[FAC_RANK_ACAD_TITLE]
				  ,[FAC_RANK_EMRTS_STATUS_IND]
				  ,[TENURE_INDICATOR]
				  ,[FIRST_HIRE_DT]
				  ,[CUR_HIRE_DT]
				  ,[FIRST_WORK_DT]
				  ,[LAST_WORK_DT]
				  ,[EMPEE_TERMN_DT]
				  ,[JOB_SUFFIX]
				  ,[POSN_NBR]
				  ,[JOB_DETL_EEO_SKILL_CD]
				  ,[JOB_DETL_EEO_SKILL_DESC]
				  ,[JOB_DETL_EFF_DT]
				  ,[POSN_EMPEE_CLS_CD]
				  ,[POSN_EMPEE_CLS_LONG_DESC]
				  ,[EMPEE_SUB_DEPT_LEVEL_6_CD]
				  ,[EMPEE_SUB_DEPT_LEVEL_6_NAME]
				  ,[EMPEE_SUB_DEPT_LEVEL_7_CD]
				  ,[EMPEE_SUB_DEPT_LEVEL_7_NAME]
				  ,[NATION_CD]
				  ,[Banner_EMPEE_GROUP_CD]
				  ,[Banner_EMPEE_GROUP_DESC]
				  ,[Banner_EMPEE_CLS_CD]
				  ,[Banner_EMPEE_CLS_LONG_DESC]
				  ,[Update_Employee_Indicator]
				  ,[New_Download_Indicator]
				  ,[DM_Upload_Done_Indicator]
				  ,[Create_Datetime]

			FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
			WHERE Create_Datetime < @cutoff_date
			ORDER BY Create_Datetime desc

			SELECT @count_archive=COUNT(*)
			FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees_History
			WHERE create_datetime > @max_avail_date AND create_datetime < @cutoff_date	

			PRINT 'Deleted'
			PRINT @count_delete
			PRINT 'Archived:'
			PRINT @count_archive
			PRINT 'Cut-off Date Time'
			PRINT @cutoff_date


			IF @count_delete = @count_archive

				DELETE FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
				WHERE Create_Datetime < @cutoff_date

			ELSE
				BEGIN
					DECLARE @message VARCHAR(1000)

					SET @message = 'Custom Error: Number of archived records does not match with those to delete: '
					SET @message = @message + ' Records archived ' + CAST(@count_archive AS VARCHAR(6)) + '.'
					SET @message = @message + ' Records to delete ' + CAST(@count_delete AS VARCHAR(6)) + '.'
					SET @message = @message + ' End Date to archive ' + convert( varchar(30), @cutoff_date, 100) + '.'

					 RAISERROR (@message, -- Message text.
						16, -- Severity.
						1 -- State.
						)
				END

		END TRY
        
		BEGIN CATCH

			PRINT 'Error while Archiving'
			PRINT ERROR_MESSAGE()

		END CATCH
        
	END


--SELECT COUNT(*)
--FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees




GO
