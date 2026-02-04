SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- STC 11/9/19
--		Set awarded degree term code for graduated PhD students
-- NS 4/25/2019
--		UPDATE FSDB_Faculty_Basic from FSDB_EDW_Current_Employees
-- NS 11/6/2018
--		SET Active Indicator to 1 for those currently under Gies payroll
--		but on 11/6/2018 we added criteria not to set it for those who were added manually
-- NS 11/6/2018: make sure a unique new record to be added to FSDB_Facstaff_Basic
--		 check uniqueness of the first and second round addition
-- NS 11/6/2018 Commented out, this part of codes to populate _UPLOAD_DM_BANNER is already done at
--		DailyUpdate_sp_DM_Step04_New_Employees_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees
-- NS 9/27/2017: Start to run Step 1,2, and 3 side by side with FSDB version, 
--	new records at FSDB_Facstaff_ID starts from Facstaff_ID=102394
-- NS 4/20/2017: 
--	Must take off comments on EXEC dbo.DailyUpdate_sp_DM_Step03sub_*

CREATE PROCEDURE [dbo].[DailyUpdate_sp_DM_Step03_Update_Add_and_Terminate_Employees_at_FSDB_Facstaff_Basic]
AS

	BEGIN TRY

		-- 1) INSERT new employees into FSDB_Facstaff_Basic in order to get FACSTAFF_ID
		-- 2) DEACTIVATE employees that are already left COB

		DECLARE @cdate datetime
		SET @cdate = getdate()

		TRUNCATE TABLE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER

		DECLARE @jobdate datetime
		SET @jobdate = getdate()

		--DECLARE @email_body varchar(4000), @from varchar(500),@to_admin varchar(500) ,@reply_to varchar(500)
		--	,@email_subject varchar(500), @Header varchar(500)

		DECLARE  @from varchar(500),@to_admin varchar(500) ,@reply_to varchar(500)
			,@email_subject varchar(500)
		DECLARE @Header varchar (MAX), @Footer varchar(MAX)
		DECLARE @Email_Body varchar(MAX)

		SET @from = 'appsmonitor@business.illinois.edu'
		SET @to_admin = 'appsmonitor@business.illinois.edu, nhadi@illinois.edu'
		SET @reply_to = 'appsmonitor@business.illinois.edu'
		SET @email_subject = '[DM] Step-by-Step Activity step 3 as of ' + cast(getdate() as varchar) 

		SET @header = '<HTML><B>[DM] Step By step Process Activity as of ' + cast(getdate() as varchar) + '</B><BR><R>'
					+ 'DailyUpdate_sp_DM_Step03_Update_Add_and_Terminate_Employees_at_FSDB_Facstaff_Basic' + '</B><BR><BR>'

		INSERT INTO Database_Maintenance.dbo.Download_Process_Monitor_Logs
					(Table_Name, Copy_Datetime, [Status]) 
		VALUES('FSDB_EDW_Current_Employees 3', @jobdate, 0)

		-- >>>>>>>>>>>>>> 0) UPDATE FSDB_Facstaff_Basic data

		-- Get the most relevant contract type to pull
		SELECT edw_pers_id, JOB_CNTRCT_TYPE_DESC
		INTO #Temp_Contracts
		FROM dbo.FSDB_EDW_Current_Employees
		WHERE JOB_CNTRCT_TYPE_DESC='Primary'
				AND New_Download_Indicator=1

		INSERT INTO #Temp_Contracts (edw_pers_id, JOB_CNTRCT_TYPE_DESC)
		SELECT edw_pers_id, JOB_CNTRCT_TYPE_DESC
		FROM dbo.FSDB_EDW_Current_Employees
		WHERE JOB_CNTRCT_TYPE_DESC='Secondary'
				AND edw_pers_id NOT IN (SELECT edw_pers_id from #Temp_Contracts)
				AND New_Download_Indicator=1

		INSERT INTO #Temp_Contracts (edw_pers_id, JOB_CNTRCT_TYPE_DESC)
		SELECT edw_pers_id, JOB_CNTRCT_TYPE_DESC
		FROM dbo.FSDB_EDW_Current_Employees
		WHERE JOB_CNTRCT_TYPE_DESC='Overload'
				AND edw_pers_id NOT IN (SELECT edw_pers_id from #Temp_Contracts)
				AND New_Download_Indicator=1

		INSERT INTO #Temp_Contracts (edw_pers_id, JOB_CNTRCT_TYPE_DESC)
		SELECT edw_pers_id, JOB_CNTRCT_TYPE_DESC
		FROM dbo.FSDB_EDW_Current_Employees
		WHERE JOB_CNTRCT_TYPE_DESC is not null
				AND edw_pers_id NOT IN (SELECT edw_pers_id from #Temp_Contracts)
				AND New_Download_Indicator=1

		UPDATE dbo.FSDB_Facstaff_Basic
		SET JOB_CNTRCT_TYPE_DESC = #Temp_Contracts.JOB_CNTRCT_TYPE_DESC
		FROM dbo.FSDB_Facstaff_Basic, #Temp_Contracts 
		WHERE #Temp_Contracts.edw_pers_id = FSDB_Facstaff_Basic.edw_pers_id 

		-- select * from #Temp_Contracts

		-- update FSDB_Facstaff_Basic
		UPDATE dbo.FSDB_Facstaff_Basic
		-- STC Review Tenure
		SET Tenure_Track_Status_Indicator=FSDB_EDW_Current_Employees.Tenure_Indicator
			,Tenure_Status_Indicator=FSDB_EDW_Current_Employees.Tenure_Indicator
			,College_Sum_FTE=FSDB_EDW_Current_Employees.Sum_FTE 
			,Appointment_Percent=FSDB_EDW_Current_Employees.Sum_FTE
			,Univ_Sum_FTE=FSDB_EDW_Current_Employees.Univ_Sum_FTE 
			,Campus_Wide_Appointment_Percent=FSDB_EDW_Current_Employees.Univ_Sum_FTE

			,Last_Name=FSDB_EDW_Current_Employees.PERS_LNAME		-- allBANNER's names
			,PERS_MNAME=FSDB_EDW_Current_Employees.PERS_MNAME
			,First_Name=FSDB_EDW_Current_Employees.PERS_FNAME
			,PERS_PREFERRED_FNAME=FSDB_EDW_Current_Employees.PERS_PREFERRED_FNAME

			,FAC_RANK_CD=FSDB_EDW_Current_Employees.FAC_RANK_CD
			,FAC_RANK_DESC=FSDB_EDW_Current_Employees.FAC_RANK_DESC
			,FAC_RANK_ACT_DT=FSDB_EDW_Current_Employees.FAC_RANK_ACT_DT
			,FAC_RANK_DECN_DT=FSDB_EDW_Current_Employees.FAC_RANK_DECN_DT
			,FAC_RANK_ACAD_TITLE=FSDB_EDW_Current_Employees.FAC_RANK_ACAD_TITLE
			,FAC_RANK_EMRTS_STATUS_IND=FSDB_EDW_Current_Employees.FAC_RANK_EMRTS_STATUS_IND
			,PERS_CITZN_TYPE_DESC=FSDB_EDW_Current_Employees.PERS_CITZN_TYPE_DESC
			,JOB_DETL_DEPT_CD=FSDB_EDW_Current_Employees.JOB_DETL_DEPT_CD
			,JOB_DETL_DEPT_NAME=FSDB_EDW_Current_Employees.JOB_DETL_DEPT_NAME
			,JOB_DETL_FTE=FSDB_EDW_Current_Employees.JOB_DETL_FTE
			,JOB_SUFFIX=FSDB_EDW_Current_Employees.JOB_SUFFIX
			,JOB_DETL_TITLE=FSDB_EDW_Current_Employees.JOB_DETL_TITLE
			,JOB_CNTRCT_TYPE_DESC=FSDB_EDW_Current_Employees.JOB_CNTRCT_TYPE_DESC


			,EMPEE_GROUP_CD=FSDB_EDW_Current_Employees.EMPEE_GROUP_CD
			,EMPEE_GROUP_DESC=FSDB_EDW_Current_Employees.EMPEE_GROUP_DESC
			,EMPEE_CLS_CD=FSDB_EDW_Current_Employees.EMPEE_CLS_CD
			,EMPEE_CLS_LONG_DESC=FSDB_EDW_Current_Employees.EMPEE_CLS_LONG_DESC
			,EMPEE_DEPT_CD=FSDB_EDW_Current_Employees.EMPEE_DEPT_CD
			,EMPEE_DEPT_NAME=FSDB_EDW_Current_Employees.EMPEE_DEPT_NAME

			,POSN_EMPEE_CLS_CD=FSDB_EDW_Current_Employees.POSN_EMPEE_CLS_CD
			,POSN_EMPEE_CLS_LONG_DESC=FSDB_EDW_Current_Employees.POSN_EMPEE_CLS_LONG_DESC
			,POSN_NBR=FSDB_EDW_Current_Employees.POSN_NBR

			,Gender=FSDB_EDW_Current_Employees.SEX_CD
			,Birth_Date=FSDB_EDW_Current_Employees.BIRTH_DT
			,Ethnicity_ID=FSDB_EDW_Current_Employees.RACE_ETH_CD
			,Citizenship_ID=FSDB_EDW_Current_Employees.NATION_CD
			,Network_ID=FSDB_EDW_Current_Employees.Network_ID
			,Email_Address=FSDB_EDW_Current_Employees.Network_ID + '@illinois.edu'
			,UIN=FSDB_EDW_Current_Employees.UIN
			,DM_Department_Name=dbo.DailyUpdate_fn_Get_DM_Department_Name_By_Banner_Dept_CD (FSDB_EDW_Current_Employees.JOB_DETL_DEPT_CD)
			,Rank_ID=dbo.DailyUpdate_fn_Convert_FAC_RANK_CD_TO_RANK_ID(FSDB_EDW_Current_Employees.FAC_RANK_CD)

			,Active_Indicator =1
			,Current_Status_Indicator=1
			,Last_Update_Datetime=GETDATE()
			,Last_EDW_Update_Datetime=GETDATE()
		FROM dbo.FSDB_EDW_Current_Employees, dbo.FSDB_Facstaff_Basic 
		WHERE FSDB_EDW_Current_Employees.edw_pers_id = FSDB_Facstaff_Basic.edw_pers_id 
				AND FSDB_EDW_Current_Employees.JOB_CNTRCT_TYPE_DESC = FSDB_Facstaff_Basic.JOB_CNTRCT_TYPE_DESC 
				AND FSDB_EDW_Current_Employees.New_Download_Indicator = 1 


		-- >>>>>>>>>>>>>> 1) INSERT NEW employees into dbo.FSDB_Facstaff_Basic in order to create identity index FACSTAFF_ID

		-- We will have unique fulltime employee because we distinct them by (JOB_DETL_DEPT_NAME,EMPEE_GROUP_CD,EMPEE_CLS_CD)
		--	but for students this way to get unique employees is not true
		INSERT INTO dbo.FSDB_Facstaff_Basic
			(
			UIN, Network_ID,
			Email_address,
			EDW_PERS_ID, 
			JOB_DETL_DEPT_CD, 
			JOB_DETL_DEPT_NAME, 
			JOB_DETL_FTE,
			EMPEE_GROUP_CD, 
			EMPEE_GROUP_DESC, 
			EMPEE_CLS_CD,
			EMPEE_CLS_LONG_DESC,
			POSN_EMPEE_CLS_CD, 
			POSN_EMPEE_CLS_LONG_DESC,
			FAC_RANK_CD,
			FAC_RANK_DESC,
			FAC_RANK_DECN_DT,
			FAC_RANK_EMRTS_STATUS_IND,
			FAC_RANK_ACT_DT,
			JOB_DETL_TITLE,
			JOB_CNTRCT_TYPE_DESC,
			EMPEE_DEPT_CD,
			EMPEE_DEPT_NAME,	
			POSN_NBR,
			First_Name,
			Last_Name, 
			Middle_Name, 
			PERS_PREFERRED_FNAME,
			DM_Department_Name, 
			Appointment_Percent, 
			Campus_Wide_Appointment_Percent, 
			Bus_Person_Manual_Entry_Indicator,
			BUS_Person_Indicator,
			Faculty_Staff_Indicator, 
			Staff_Classification_ID,
			Rank_ID,
			Active_Indicator, Current_Status_Indicator, College_List_Indicator, Department_List_Indicator,
			Gender,
			Birth_Date,
			Ethnicity_ID,
			Citizenship_ID,
			Hired_Date,
			Create_Datetime,
			Last_Update_Datetime,
			Last_EDW_Update_Datetime,

			PERS_CITZN_TYPE_DESC,
			-- STC Review Tenure
			Tenure_Track_Status_Indicator,
			College_Sum_FTE,
			Univ_Sum_FTE

			)

		SELECT 
			DISTINCT UIN, Network_ID,
			Network_ID + '@illinois.edu' as Email_address,
			fsdb.edw_pers_id,
			JOB_DETL_DEPT_CD, 
			JOB_DETL_DEPT_NAME, 
			JOB_DETL_FTE,
			EMPEE_GROUP_CD, 
			EMPEE_GROUP_DESC, 
			EMPEE_CLS_CD,
			EMPEE_CLS_LONG_DESC,
			POSN_EMPEE_CLS_CD,	 
			POSN_EMPEE_CLS_LONG_DESC,
			FAC_RANK_CD,
			FAC_RANK_DESC,
			FAC_RANK_DECN_DT,
			FAC_RANK_EMRTS_STATUS_IND,
			FAC_RANK_ACT_DT,
			JOB_DETL_TITLE,
			fsdb.JOB_CNTRCT_TYPE_DESC,
			EMPEE_DEPT_CD,
			EMPEE_DEPT_NAME,
			POSN_NBR,
			PERS_FNAME,
			PERS_LNAME,
			PERS_MNAME, 
			PERS_PREFERRED_FNAME,
			dbo.DailyUpdate_fn_Get_DM_Department_Name_By_Banner_Dept_CD (JOB_DETL_DEPT_CD) as DM_Department_Name,
			Sum_FTE * 100,
			Univ_Sum_FTE * 100,
			0,	--Bus_Person_Manual_Entry_Indicator
			1,  -- BUS_Person_Indicator
			-- STC Review Faculty
			-- STC 12/19/19 - Do not set to 1 for all employees!
			case when empee_group_cd = 'A' then 1 else 0 end,  -->>>> faculty
			null,  -->>>> staff classification
			dbo.DailyUpdate_fn_Convert_FAC_RANK_CD_TO_RANK_ID(FAC_RANK_CD),
			1, 1, 1, 1,  -- Active_Indicator, Current_Status_Indicator, College_List_Indicator, Department_List_Indicator,
			SEX_CD,
			BIRTH_DT,
			RACE_ETH_CD,
			NATION_CD,
			FIRST_HIRE_DT,
			@cdate,
			@cdate,
			@cdate,   -- use to identify the latest records after a checkpoint time '2/1/1920'

			PERS_CITZN_TYPE_DESC,
			-- STC Review Tenure
			Tenure_Indicator,
			Sum_FTE,
			Univ_Sum_FTE

		FROM dbo.FSDB_EDW_Current_Employees fsdb
					INNER JOIN #Temp_Contracts contracts
					ON fsdb.EDW_PERS_ID = contracts.EDW_PERS_ID
							AND fsdb.JOB_CNTRCT_TYPE_DESC = contracts.JOB_CNTRCT_TYPE_DESC
							AND fsdb.New_Download_Indicator = 1
		WHERE New_Download_Indicator = 1
			AND fsdb.EDW_PERS_ID not in
	 			(SELECT EDW_PERS_ID
       			 FROM dbo.FSDB_Facstaff_Basic
				 WHERE EDW_PERS_ID is not NULL		
				)

		/*
		-- NS 11/6/2018: check duplicates

		SELECT edw_pers_id
		FROM FSDB_EDW_Current_Employees
		WHERE  new_download_indicator = 1
			AND EDW_PERS_ID not in
	 			(SELECT EDW_PERS_ID
       			 FROM dbo.FSDB_Facstaff_Basic
				 WHERE EDW_PERS_ID is not NULL	
					AND Create_Datetime <= '8/3/2018'	
				)
		GROUP BY edw_pers_id
		HAVING COUNT(*) > 1

		SELECT * FROM FSDB_Facstaff_Basic where edw_pers_ID in (2575,293619)
		SELECT *  FROM FSDB_EDW_Current_Employees where edw_pers_ID in (2575,293619) and new_download_indicator = 1

		*/

		-- NS 11/6/2018
		-- RESET Active Indicator to 1 for those currently under Gies payroll
		--		except those who were added manually
		UPDATE dbo.FSDB_Facstaff_Basic
		SET Active_Indicator = 1, Current_Status_Indicator=1, College_List_Indicator=1, Department_List_Indicator=1
		FRoM dbo.FSDB_Facstaff_Basic fb, dbo.FSDB_EDW_Current_Employees edw
		WHERE fb.EDW_PERS_ID is not NULL	
				AND fb.EDW_PERS_ID = edw.EDW_PERS_ID
				AND edw.New_Download_Indicator = 1
				AND fb.Bus_Person_Manual_Entry_Indicator=0

		
		-- >>>>>>>>>>>>>>>>> 2. DEACTIVATE employees that are already left COB

		-- >>>>>>>>>>>>>>
		-- Find out terminated employees at EDW by comparing the edw_pers_id
		--	between
		--	dbo.FSDB_EDW_Current_Employees
		--	Where New_Download_Indicator = 1 
		--		AND empee_cls_cd not in ('GA','GB')
		--		AND (empee_cls_cd <> 'TR' OR faculty_staff_indicator = 0)
		--		AND JOB_DETL_COLL_CD='KM' 
		--	and
		--	dbo.FSDB_Facstaff_Basic 
		--	where EDW_PERS_ID is not NULL AND active_indicator=1 AND bus_person_indicator=1 and AND Bus_Person_Manual_Entry_Indicator=0
		--		NOTE: GA/GB may still be active even though it is in intersession (during intersession Grads may not be set as "hired" in Banner),
		--			TR faculty may be on leave for a term or a year but still as TR
		--			TR staff may be removed
		--
		--	When those terminated employees are found, then do the following when the count is <= @EMP_Deletion_Threshold
		--		1) add to FSDB_Facstaff_Basic_Deactivated, and set Update_Status = 'MARKED
		--		2) update to FSDB_Facstaff_Basic, set Active_Indicator=0 and find their respective Leaving_Date
		--		3) insert into dbo._UPLOAD_DM_BANNER with Record_Status='SAVED'
		--
		--	For each one of the terminated employee, compose a line of information
		--		(first, last name), FSDB department, Banner Department, Network_ID,  employee group, termination date
		--	Send an email to the admin

		--	For safety, we will do the above only when the number of persons terminated is below the threshold.

		-- At the start of each term, we will postpone termination in Business Depts for a number of days (15 or 30)
		-- This is done to prevent premature termination in case of delayed entry of renewed appointments in Banner
	
		-- FSDB_EDW_Current_Employees is all Business employees that we extract from Decision_Support_HR at busdbsrv\sqlprod1 in the morning,
		-- This is a cummulative list of all employees. New download is indicated by New_Download_Indicator = 1
		-- We run a daily process at about 7 AM to run DailyUpdate_sp_Get_Current_College_Of_Business_Employees_From_EDW

	
		DECLARE @CRLF varchar(2)

		DECLARE @reset_count integer
		DECLARE @term_count integer
		DECLARE @GA_Deletion_Threshold integer
		DECLARE @EMP_Deletion_Threshold integer
		DECLARE @today datetime
		DECLARE @delay_start_date datetime
		DECLARE @delay_end_date datetime
		DECLARE @delay_length integer
		DECLARE @delay_indicator bit

		SET @CRLF = char(10) + char(13)
		SET @GA_Deletion_Threshold = 70    -- default 70
		--SET @GA_Deletion_Threshold = 160    -- default 70
		SET @EMP_Deletion_Threshold = 30	 -- default 30
		--SET @EMP_Deletion_Threshold = 300	 -- temporarily increase threshold after delay period ends


		SELECT DISTINCT Facstaff_id, EDW_PERS_ID, Network_ID, 0 as Delay_Indicator
		INTO #TERMINATED_EMPS
		FROM  DM_Shadow_Staging.dbo.FSDB_Facstaff_Basic
		WHERE Bus_Person_Manual_Entry_Indicator = 0 and bus_person_indicator = 1 
				and active_indicator = 1 
		--		and empee_cls_cd not in ('TR','GA','GB') 
				and empee_cls_cd not in ('GA','GB') 
				and (empee_cls_cd <> 'TR' or faculty_staff_indicator = 0)
				and edw_pers_id not in
					(SELECT edw_pers_id
					FROM	dbo.FSDB_EDW_Current_Employees
					WHERE	(New_Download_Indicator = 1))

		SELECT @term_count = COUNT(*)
		FROM #TERMINATED_EMPS

		-- Get date range for delayed terminations at start/end of each term
		SET @today = GETDATE()

		SET @delay_length = 30	-- default delay is 30 days, used at start of fall/spring

		IF MONTH(@today) = 12
		BEGIN
			SET @delay_start_date = CONVERT(datetime, '12/15/' + convert(varchar(4), year(@today)))
			SET @delay_end_date = DATEADD(d, @delay_length + 1, @delay_start_date)
		END
		ELSE IF MONTH(@today) < 5
		BEGIN
			SET @delay_start_date = CONVERT(datetime, '12/15/' + convert(varchar(4), year(@today)-1))
			SET @delay_end_date = DATEADD(d, @delay_length + 1, @delay_start_date)
		END
		ELSE IF MONTH(@today) < 8
		BEGIN
			SET @delay_length = 15	-- for now, delay of 15 days may be sufficient in May
			SET @delay_start_date = CONVERT(datetime, '5/15/' + convert(varchar(4), year(@today)))
			SET @delay_end_date = DATEADD(d, @delay_length + 1, @delay_start_date)
		END
		ELSE
		BEGIN
			SET @delay_start_date = CONVERT(datetime, '8/15/' + convert(varchar(4), year(@today)))
			SET @delay_end_date = DATEADD(d, @delay_length + 1, @delay_start_date)
		END

		-- STC 8/31/12 - Temporarily extend August 2012 delay period by 1 day
		--IF @today < '9/1/12'
		--	SET @delay_end_date = DATEADD(d, 1, @delay_end_date)

		-- STC 8/24/12 - Mark selected employees for delayed termination
		-- STC 9/15/15 - We will not report any terminations during delay period, so just set @delay_indicator,
		--					no need to mark individual employees for delay
		IF @today >= @delay_start_date AND @today < @delay_end_date
		BEGIN
			SET @reset_count = 0
			SET @delay_indicator = 1

			--UPDATE #TERMINATED_EMPS
			--SET Delay_Indicator = 1
			--FROM #TERMINATED_EMPS E
			--INNER JOIN DM_Shadow_Staging.dbo.FSDB_Facstaff_Basic FSB
			--	ON E.Facstaff_id = FSB.Facstaff_ID
			--INNER JOIN dbo.Departments D
			--	ON FSB.EMPEE_DEPT_CD = D.EDW_Dept_CD
			--		AND D.EDW_Dept_CD IS NOT NULL
			--		AND D.Active_Indicator = 1
		END
		ELSE BEGIN
			SELECT @reset_count = COUNT(*)
			FROM #TERMINATED_EMPS

			SET @delay_indicator = 0
		END



		SELECT @reset_count = COUNT(*)
		FROM #TERMINATED_EMPS

		-- nhadi 5/23/2019
		-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>
		-- Nullify the DELAY effect
		--SET @delay_indicator = 0


		--select * , .dbo.DailyUpdate_fn_Get_Termination_date(edw_pers_id) as term_date
		--from #TERMINATED_EMPS 

		-- STC 5/21/15 -- Moved this to ELSE statement above
		--SELECT @reset_count = COUNT(*)
		--FROM #TERMINATED_EMPS
		--WHERE Delay_Indicator = 0

		--print @reset_count
 
		-- STC 9/15/15
		-- If not in delay period, process terminations or send email if threshold is exceeded
		PRINT 'DELAY_INDICATOR'
		PRINT @delay_indicator

		IF @delay_indicator = 0
		BEGIN
			-- Guard from accidental failed download that will incorrectly update all records 
			IF @reset_count <= @EMP_Deletion_Threshold  AND  @reset_count >= 1
			BEGIN

	

				Update DM_Shadow_Staging.dbo.FSDB_Facstaff_Basic
				--set Leaving_Date= Decision_Support_HR.dbo.DailyUpdate_sp_Get_Termination_Date_by_EDW_PERS_ID(E.edw_pers_id)
				set Leaving_Date = dbo.DailyUpdate_fn_Get_Termination_date(E.edw_pers_id)
						,active_indicator=0
				FROM  #TERMINATED_EMPS E, dbo.FSDB_Facstaff_Basic F
				WHERE E.facstaff_Id = F.facstaff_id and e.facstaff_id is not null
					AND E.Delay_Indicator = 0

				INSERT INTO DM_Shadow_Staging.dbo.FSDB_Facstaff_Basic_Deactivated 
					(Facstaff_ID, Update_Status, EDW_PERS_ID, Network_ID, Leaving_Date, create_Datetime)
				SELECT F.Facstaff_ID, 'MARKED', F.EDW_PERS_ID, F.Network_ID, F.Leaving_Date, getdate()
				FROM  #TERMINATED_EMPS E
						INNER JOIN  dbo.FSDB_Facstaff_Basic F
						ON E.Facstaff_ID = F.Facstaff_ID

				-- NS 4/20/2017 commented out
				--EXEC dbo.DailyUpdate_sp_DM_Step03sub_Send_Email_About_Terminated_Employees

				-- NS 11/6/2018 Commented out, this part of codes to populate _UPLOAD_DM_BANNER is already done at
				--		DailyUpdate_sp_DM_Step04_New_Employees_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees
				/*
				INSERT INTO DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
					(USERNAME
					  ,ID
					  ,FACSTAFFID
					  ,EDWPERSID
					  ,UIN
					  ,EDW_Database
					  ,PERS_PREFERRED_FNAME
					  ,PERS_FNAME
					  ,PERS_MNAME
					  ,PERS_LNAME
					  ,EMPEE_TERMN_DT
					  ,LAST_WORK_DT
    				  ,Record_Status
					  ,Create_Datetime
					  ,Last_Update_Datetime
					)
				SELECT B.USERNAME
				  ,B.ID
				  ,B.FACSTAFFID
				  ,B.EDWPERSID
				  ,B.UIN
				  ,B.EDW_Database
				  ,B.PERS_PREFERRED_FNAME
				  ,B.PERS_FNAME
				  ,B.PERS_MNAME
				  ,B.PERS_LNAME
				  ,T.Leaving_Date
				  ,T.Leaving_Date
				  ,'OUT'  -- was LEAVE-EMP
				  ,getdate()
				  ,getdate()

				FROM DM_Shadow_Staging.dbo._DM_BANNER B, DM_Shadow_Staging.dbo.FSDB_Facstaff_Basic_Deactivated  T
				WHERE B.EDWPERSID = T.EDW_PERS_ID
						AND T.Update_Status = 'MARKED'
				*/

				-- SEND EMAIL on Terminated employees
				/*
				-- NS 6/4/2019 COMMENTED OUT
				--		Replaced by dbo.DailyUpdate_sp_DM_Step07sub_Send_Email_New_And_Termination_Emps SP

				DECLARE @listStr VARCHAR(MAX)
		
				SET @header = '<HTML><B>[FSDB-HR] List of Terminated Employees as of ' + cast(getdate() as varchar) + '<BR><BR>'
				SET @header = @header + '>>>  Procedure: DM_Shadow_Staging.dbo.DailyUpdate_sp_DM_Step03_Add_and_Terminate_Employees_at_Facstaff_Basic <BR><BR>' + @CRLF
				SET @footer = '<BR></HTML>'

				SELECT @listStr = COALESCE(@listStr+'<BR/>' ,'') + EDW_PERS_ID + ' : ' + USERNAME + '@illinois.edu' + ' : ' + PERS_LNAME + ', ' + PERS_FNAME 
						+ ' : ' +  ISNULL(EMPEE_DEPT_NAME,'No Department') + ' : ' + ISNULL(JOB_DETL_TITLE,'No Job Title')
						+ ' : ' +  ISNULL(empee_group_desc,'No Emp Group') +  ' : Leaving ' 
						+ CASE WHEN EMPEE_TERMN_DT IS NOT NULL
									THEN convert(varchar(30), EMPEE_TERMN_DT,101)
							 ELSE 'has no date' END 
				FROM DM_Shadow_Staging.dbo._DM_BANNER B, DM_Shadow_Staging.dbo.FSDB_Facstaff_Basic_Deactivated  T
				WHERE B.EDWPERSID = T.EDW_PERS_ID
						AND T.Update_Status = 'MARKED'
				ORDER BY PERS_LNAME, PERS_FNAME
			
				SET @email_subject = '[DM-UPLOAD] Employee Termination notification'
				SET @email_body = @Header 
					+ @listStr + '<BR><BR>'
					+ @Footer
		
				-- NS 4/28/2017 commented out
				-- EXEC dbo.DailyUpdate_sp_Send_Email 'research@business.illinois.edu'
				--  ,'research@business.illinois.edu, novianto@illinois.edu, meaganh@illinois.edu, cmporter@illinois.edu, kacoop@illinois.edu'
				--	,'research@business.illinois.edu',@email_subject, @email_body

				 EXEC dbo.DailyUpdate_sp_Send_Email 'research@business.illinois.edu'
					,'nhadi@illinois.edu'
					,'research@business.illinois.edu',@email_subject, @email_body

				print @email_subject
				print @email_body
				*/


				UPDATE DM_Shadow_Staging.dbo.FSDB_Facstaff_Basic_Deactivated 
				SET Update_Status = 'SAVED'
				WHERE Update_Status = 'MARKED'

		

			END
			-- STC 5/24/10 - Send notification in case of too many apparent terminations so we can run manually if not the result of a failed download
			ELSE IF @reset_count > @EMP_Deletion_Threshold
			BEGIN
				SET @email_body = '<HTML><B>[DM-UPLOAD] Found ' + cast(@reset_count as varchar) + ' employees to be terminated as of ' + cast(getdate() as varchar)
					+ '</b><BR><BR>The number of employees marked for termination exceeds the limit of '
					+ cast(@EMP_Deletion_Threshold as varchar) + '.  '
					+ 'Check for EDW download failure to ensure the accuracy of this list.  If the list is correct, '
					+ 'please re-run the termination manually to bypass this limit.  If incorrect, determine the '
					+ 'reason for download failure and correct any errors / re-run downloads as necessary.<br><br>'
					+ 'Procedures: ' 
					+ '<BR>DM_Shadow_Staging.dbo.DailyUpdate_sp_DM_Step03_Update_Add_and_Terminate_Employees_at_FSDB_Facstaff_Basic<BR>, and '
					+ '<BR><BR></HTML>'
				-- NS 4/20/2017 commented out

				--EXEC dbo.DailyUpdate_sp_Send_Email 'research@business.illinois.edu','research@business.illinois.edu','research@business.illinois.edu','[DM-UPLOAD] Employee Termination limit exceeded', @email_body
				EXEC dbo.DailyUpdate_sp_Send_Email 'appsmonitor@business.illinois.edu','nhadi@illinois.edu,appsmonitor@business.illinois.edu,scasteel@illinois.edu','appsmonitor@business.illinois.edu','[DM-UPLOAD] Employee Termination limit exceeded', @email_body

				--EXEC dbo.DailyUpdate_sp_DM_Step03sub_Send_Email_About_Terminated_Employees_Due
			END
		END
		ELSE
		BEGIN
			-- During delay period, send email report listing employees to be terminated after period expires
			-- NS 4/20/2017 commented out
			--EXEC dbo.DailyUpdate_sp_DM_Step03sub_Send_Email_About_Terminated_Employees_Pending @delay_end_date
			print 'This print command is put here to avoid an empty begin-end block'
		END

		-- Processing FSDB RECORDS whose empee_cls_cd is  in ('GA')
		-- Run Grad Assistants REMOVAL process only in Spring and Fall terms
		-- NS 7/31/2013: Add 'GB'

		DECLARE @termname VARCHAR(20)
		SET @termname = Decision_Support.dbo.FSD_fn_Identify_Term(getdate())

		DECLARE @term_cd varchar(6)
		DECLARE @ddate datetime
		SET @ddate = getdate()
		SET @term_cd = dbo.DailyUpdate_fn_Get_Current_Term(@ddate)


		IF @termname = 'SPRING' OR @termname = 'FALL'
		BEGIN
	
	
			SELECT @reset_count = count(*)
			--select *
			FROM  dbo.FSDB_Facstaff_Basic
			WHERE Bus_Person_Manual_Entry_Indicator = 0 AND bus_person_indicator = 1 
				AND active_indicator = 1 AND empee_cls_cd in ('GA', 'GB') 
				and edw_pers_id not in
					(SELECT edw_pers_id
					FROM	FSDB_EDW_Current_Employees
					-- compared to the today's (current) employee list
					WHERE     (New_Download_Indicator = 1))
					-- compared to Spring 2013's employee list
					-- WHERE Create_Datetime < '5/9/2013' and Create_Datetime > '5/8/2013' )
			--print @reset_count
	
	
			-- Guard from accidental failed download that will incorrectly update all records 
			IF @reset_count <= @GA_Deletion_Threshold  AND  @reset_count >= 1
				 BEGIN
	
				--IF OBJECT_ID('TempDB..#TERMINATED_EMPS2') IS NOT NULL 
				--	DROP TABLE #TERMINATED_EMPS2
			
				--CREATE TABLE #TERMINATED_EMPS2 (
				--		[Facstaff_id] [int] NULL,
				--		[EDW_PERS_ID] [varchar] (12)  NULL,
				--		[Network_ID] [varchar] (30)  NULL,
				--) ON [PRIMARY] 
	
				-- >>>> GET all EDW_PERS_ID of terminated Grad RA (GA) employees from College_Of_Business
				--INSERT INTO #TERMINATED_EMPS2 (Facstaff_id, EDW_PERS_ID, Network_ID)
				SELECT DISTINCT Facstaff_id, EDW_PERS_ID, Network_ID
				INTO #TERMINATED_EMPS2
				FROM  dbo.FSDB_Facstaff_Basic
				WHERE Bus_Person_Manual_Entry_Indicator = 0  
					AND bus_person_indicator = 1 
					AND active_indicator =1 
					AND empee_cls_cd in ('GA', 'GB') 
					AND edw_pers_id not in
					   (SELECT     edw_pers_id
						FROM         FSDB_EDW_Current_Employees
						-- compared to the today's (current) employee list
						WHERE     (New_Download_Indicator = 1))
						-- compared to Spring 2013's employee list
						--WHERE Create_Datetime < '5/9/2013' and Create_Datetime > '5/8/2013' )
			
				/*
				select * from #TERMINATED_EMPS2
				select * , dbo.DailyUpdate_fn_Get_Termination_date(edw_pers_id) as term_date
				from #TERMINATED_EMPS2 
				*/

				-- STC 4/24/15 -- Staff_Classification_ID is no longer updated to be accurate for
				--	GAs, PhDs; do not limit deactivations based on this value
				Update dbo.FSDB_Facstaff_Basic
				SET Leaving_Date = dbo.DailyUpdate_fn_Get_Termination_Date(E.edw_pers_id)
				FROM  #TERMINATED_EMPS2 E, FSDB_facstaff_basic F
				WHERE E.facstaff_Id = F.facstaff_id 
					AND e.facstaff_id is not null
		--			AND F.Staff_Classification_ID = 6
	
				--Do not need to report termination of Grad assistants
				-- 	If need to report take a look this code first
				--EXEC dbo.DailyUpdate_sp_Send_Email_About_Terminated_Employees
	
				/*
		
				-- ALL GRADUATED PHD STUDENTS THAT ARE NO LONGER EMPLOYED
				SELECT F.Facstaff_id, f.EDW_PERS_ID, f.Network_ID, f.Last_Name, f.First_Name, f.last_Update_Datetime
				FROM  dbo.FSDB_Facstaff_Basic F
				WHERE f.Active_Indicator = 0
					and f.Staff_Classification_ID in (6,11)
					AND f.EDW_PERS_ID not in
					( SELECT EDW_PERS_ID 
						FROM Decision_Support.dbo.EDW_T_STUDENT_AH_DEG_HIST
						WHERE Deg_Status_CD = 'AW' AND COLL_CD='KM' AND GRAD_TERM_CD >= '120118'
							  AND EDW_PERS_ID IS NOT NULL		
					)
					AND f.EDW_PERS_ID  in
					( SELECT edw_pers_id
						FROM	FSDB_EDW_Current_Employees
						WHERE	(New_Download_Indicator = 1)		
					)
				ORDER BY f.last_Update_Datetime DESC
		
				-- ALL PHD STUDENTS THAT ARE NOT GRADUATED AND REGISTERD IN SPRING
				SELECT F.Facstaff_id, f.EDW_PERS_ID, f.Network_ID, f.Last_Name, f.First_Name, f.last_Update_Datetime
				FROM  dbo.FSDB_Facstaff_Basic F
				WHERE  f.edw_pers_id in 
					(select distinct EDW_PERS_ID
						FROM Decision_Support.dbo.EDW_T_STUDENT_TERM DH
						WHERE STUDENT_CURR_1_DEG_CD = 'PHD'	
							AND DH.TERM_CD = '120131')
					AND f.EDW_PERS_ID not in
					( SELECT EDW_PERS_ID 
						FROM Decision_Support.dbo.EDW_T_STUDENT_AH_DEG_HIST
						WHERE Deg_Status_CD = 'AW' AND COLL_CD='KM' AND GRAD_TERM_CD >= '120118'
							  AND EDW_PERS_ID IS NOT NULL		
					)
		  				
		
				*/
		
					
				----  >>>> Update the employee data in dbo.FSDB_Facstaff_Basic: deactivate records of Grad Assistant (Staff_Classification_ID = 6)
				Update dbo.FSDB_Facstaff_Basic
				SET active_indicator=0, Last_Update_Datetime = GETDATE()
				FROM  #TERMINATED_EMPS2 E, dbo.FSDB_Facstaff_Basic F
				WHERE  E.facstaff_Id = F.facstaff_id 
					AND e.facstaff_id is not null
		--			AND F.Staff_Classification_ID = 6
		
					
				--  >>>> Update the employee data in dbo.FSDB_Facstaff_Basic: reset Staff_Classification_ID code from 11 to 5 (from Grad Assistant & Doctoral to Doctoral only)
				Update dbo.FSDB_Facstaff_Basic
				SET Staff_Classification_ID=5, Last_Update_Datetime = GETDATE()
				FROM  #TERMINATED_EMPS2 E, dbo.FSDB_Facstaff_Basic F
				WHERE E.facstaff_Id = F.facstaff_id 
					AND e.facstaff_id is not null
					AND F.Staff_Classification_ID = 11

				-- NS 7/31/2013
				--  >>>> Update the employee data in dbo.FSDB_Facstaff_Basic: deactivate records of students who has graduated and no longer employed
				Update dbo.FSDB_Facstaff_Basic
				SET active_indicator=0, Last_Update_Datetime = GETDATE(),
					Leaving_Date = dbo.DailyUpdate_fn_Get_Termination_Date(E.edw_pers_id)
				FROM  #TERMINATED_EMPS2 E, dbo.FSDB_Facstaff_Basic F
				WHERE E.facstaff_Id = F.facstaff_id 
					AND e.facstaff_id is not null
					AND e.EDW_PERS_ID in
					( SELECT EDW_PERS_ID 
					  FROM Decision_Support.dbo.EDW_T_STUDENT_AH_DEG_HIST
					  WHERE Deg_Status_CD = 'AW' AND COLL_CD='KM' AND GRAD_TERM_CD >= '120128'		
					)
	
				-- NS 7/31/2013
				--  >>>> Update the employee data in dbo.FSDB_Facstaff_Basic: activate records of students 
				--			who happened deactivated but still a student and has not graduated

				UPDATE dbo.FSDB_Facstaff_Basic
				SET Active_Indicator = 1
				WHERE Active_Indicator = 0
					AND edw_pers_id in 
					(select distinct EDW_PERS_ID
						FROM Decision_Support.dbo.EDW_T_STUDENT_TERM DH
						WHERE STUDENT_CURR_1_DEG_CD = 'PHD'	
							 AND COLL_CD = 'KM'
							 AND DH.TERM_CD = @term_cd
							 AND EDW_PERS_ID IS NOT NULL	)
					AND EDW_PERS_ID not in
					( SELECT EDW_PERS_ID 
						FROM Decision_Support.dbo.EDW_T_STUDENT_AH_DEG_HIST
						WHERE Deg_Status_CD = 'AW' AND COLL_CD='KM' AND GRAD_TERM_CD >= '120118'
							  AND EDW_PERS_ID IS NOT NULL		
					)				
		
		
			
				--INSERT INTO Log_EDW_Activities   (Facstaff_id, EDW_PERS_ID, Network_ID, Create_Datetime, EDW_Download_Activity)
				--SELECT Facstaff_id, EDW_PERS_ID, Network_ID, getdate(), 'Terminate DOCS'
				--FROM  #TERMINATED_EMPS2
	
			 END

			-- STC 5/24/10 - Send notification in case of too many apparent terminations so we can run manually if not the result of a failed download
			ELSE IF @reset_count > @GA_Deletion_Threshold
				BEGIN
					SET @email_body = '<HTML><B>[DM-UPLOAD] Found ' + cast(@reset_count as varchar) + ' GAs to be terminated as of ' + cast(getdate() as varchar)
						+ '</b><BR><BR>The number of GAs marked for termination exceeds the limit of '
						+ cast(@GA_Deletion_Threshold as varchar) + '.  '
						+ 'Check for EDW download failure to ensure the accuracy of this list.  If the list is correct, '
						+ 'please re-run the termination manually to bypass this limit.  If incorrect, determine the '
						+ 'reason for download failure and correct any errors / re-run downloads as necessary.<br><br>'
						+ 'Procedures: (1) DM_Shadow_Staging.dbo.DailyUpdate_sp_DM_Step03_Update_in_Facstaff_Basic_Send_Termination_Email<BR>, and '
						+ '<BR>(2) DM_Shadow_Staging.dbo.DailyUpdate_sp_DM_Step06_Terminate_Employees_UPLOAD_DM_BANNER_FromFSDB_EDW_Current_Employees'
						+ '<BR><BR></HTML>'
					-- NS 4/20/2017 commented out
					--EXEC dbo.DailyUpdate_sp_Send_Email 'research@business.illinois.edu','research@business.illinois.edu','research@business.illinois.edu','[DM-UPLOAD] Employee Termination (GA) limit exceeded', @email_body
					EXEC dbo.DailyUpdate_sp_Send_Email 'appsmonitor@business.illinois.edu','nhadi@illinois.edu,appsmonitor@business.illinois.edu,scasteel@illinois.edu,ctidrick@illinois.edu','appsmonitor@business.illinois.edu','[DM-UPLOAD] Employee Termination (GA) limit exceeded', @email_body

				END

			-- NS 7/31/2013
			--  >>>> Update the employee data in dbo.FSDB_Facstaff_Basic: Awarded Doctoral & current doctoral
			-- STC 10/25/13 - Check only for awarded PHD degrees
			-- STC 9/15/15 - Only update Doctoral_Flag if value is not already correct
			UPDATE  dbo.FSDB_Facstaff_Basic 
			SET Doctoral_Flag = 2    -- AWARDED KM DOCTORAL
			WHERE Doctoral_Flag <> 2
				AND Staff_Classification_ID in (6,11)
				AND EDW_PERS_ID in
				( SELECT EDW_PERS_ID 
					FROM Decision_Support.dbo.EDW_T_STUDENT_AH_DEG_HIST
					WHERE Deg_Status_CD = 'AW' AND GRAD_TERM_CD >= '120118'
						  AND DEG_CD = 'PHD'
						  AND COLL_CD ='KM'
						  AND EDW_PERS_ID IS NOT NULL		
				)

			-- STC 11/8/19 - Set graduation term for awarded PHD degrees
			UPDATE dbo.FSDB_Facstaff_Basic
			SET Doctoral_Award_Term_CD = DH.GRAD_TERM_CD
			FROM FSDB_Facstaff_Basic FB
			INNER JOIN Decision_Support.dbo.EDW_T_STUDENT_AH_DEG_HIST DH
				ON FB.EDW_PERS_ID = DH.EDW_PERS_ID
			WHERE FB.Doctoral_Award_Term_CD is NULL
				AND FB.Doctoral_Flag = 2
				AND DH.DEG_STATUS_CD = 'AW'
				AND DH.DEG_CD = 'PHD'
				AND DH.COLL_CD = 'KM'
				AND DH.DEPT_CD <> '1405'	-- Economics
				AND DH.STUDENT_AH_DEG_CUR_INFO_IND = 'Y'

		
			UPDATE  dbo.FSDB_Facstaff_Basic 
			SET Doctoral_Flag = 1	-- CURRENT KM DOCTORAL
			WHERE Doctoral_Flag <> 1
				AND Staff_Classification_ID in (6,11)
				AND EDW_PERS_ID in
				( select distinct EDW_PERS_ID
					FROM Decision_Support.dbo.EDW_T_STUDENT_TERM DH
					WHERE STUDENT_CURR_1_DEG_CD = 'PHD'	
						  AND COLL_CD ='KM'
						  AND DH.TERM_CD = @term_cd
						  AND EDW_PERS_ID IS NOT NULL		
				)
				AND EDW_PERS_ID not in
				( SELECT EDW_PERS_ID 
					FROM Decision_Support.dbo.EDW_T_STUDENT_AH_DEG_HIST
					WHERE Deg_Status_CD = 'AW' AND COLL_CD='KM' AND GRAD_TERM_CD >= '120118'
						  AND DEG_CD = 'PHD'
						  AND EDW_PERS_ID IS NOT NULL		
				)	

			END


			UPDATE	Database_Maintenance.dbo.Download_Process_Monitor_Logs
			SET		Status = 2
			WHERE	Table_Name = 'FSDB_EDW_Current_Employees 3'
				AND	Copy_Datetime = @jobdate
				
			SET @email_subject =  @email_subject + ' - Success'
			SET @email_body = @header + 'Success<BR><BR>'
			EXEC dbo.DailyUpdate_sp_Send_Email @from,@to_admin,@reply_to,@email_subject, @email_body


	END TRY

	BEGIN CATCH
			SET @email_subject =  @email_subject + ' - Error'
			SET @email_body = @header + ERROR_Message() + '<BR><BR>'
			EXEC dbo.DailyUpdate_sp_Send_Email @from,@to_admin,@reply_to,@email_subject, @email_body
	END CATCH
	/*
		SELECT * FROM FSDB_Facstaff_Basic where Active_Indicator=1 and BUS_Person_Indicator=1	-- 1139
	*/
GO
