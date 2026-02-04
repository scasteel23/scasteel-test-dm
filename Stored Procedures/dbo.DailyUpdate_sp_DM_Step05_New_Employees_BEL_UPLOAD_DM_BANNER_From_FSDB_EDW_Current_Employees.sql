SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

-- 6/11/2019 Took off emailing, move the function to dbo.DailyUpdate_sp_DM_Step07_sub_Send_Email_New_And_Termination_Emps
--
-- NS 3/25/2019
--		Found out that create and update _DM_UPLOAD_USERS table is done at
--			DailyUpdate_sp_DM_Step06_Update_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees
--
-- NS 4/20/2017: revisited, worked!
--		Need to send email regarding new emps from BEL
-- NS 3/30/2017: Revisited. Created FSDB_EDW_Current_Employees table at DM_Shadow_Staging database functioning
--		as EDW_Current_Employees table in Facukty_Staff_Holder database
--		Renamed _UPLOADED_DM_USERS, _UPLOADED_DM_PCI, and _UPLOADED_DM_BANNER to
--		_UPLOAD_DM_USERS, _UPLOAD_DM_PCI, and _UPLOAD_DM_BANNER  tables
--
-- NS 3/28/2017: Moved related SP and tables (for downloadinging from EDW) to DM_Shadow_Staging database

CREATE  Procedure [dbo].[DailyUpdate_sp_DM_Step05_New_Employees_BEL_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees]
as
-- NS 11/30/2016
--		Codes on EDW_Current_Employees table
--			SEX_CD   F or M
--			College_JOB_DETL_FTE   0-100
--			Campus_JOB_DETL_FTE    0-100
--			FAC_RANK_EMRTS_STATUS_IND  Y or N
--			EMPEE_RET_IND  Y or N
--
--		Codes on _UPLOAD_DM_BANNER
--			SEX_CD   Female or Male
--			College_JOB_DETL_FTE   0-100
--			Campus_JOB_DETL_FTE    0-100
--			FAC_RANK_EMRTS_STATUS_IND  Yes or No
--			EMPEE_RET_IND Yes or No
--
--		Derived from DailyUpdate_sp_Add_Employees_To_Facstaff_Basic_From_EDW_Current_Employees_BEL
--		Changed the crotera
--			from	JOB_DETL_DEPT_NAME like 'Library%' 
--			to		EMPEE_ORG_TITLE like '%BEL%' 
--
-- Special downloads for Business and Economic Library employees 
-- STC 6/6/12 -- Updated to prevent duplicate insertion of employee with multiple primary job records

-- >>>>>>>>>>>>>> BEL related JOBS

-- >>>>>>>>>>>>>> PROCESS
--		1. Get Primary Jobs in BEL, except student workers
--			Mark FSDB_EDW_Current_Employees.Update_Employee_Indicator = 'DM-BEL'
--			Insert into _UPLOAD_DM_BANNER table
--			Mark FSDB_EDW_Current_Employees.DM_Upload_Done_Indicator=1
--
--		2. Get FACSTAFFID
--		   Find out new and current emps, and mark them
--			_UPLOAD_DM_BANNER.Record_Status = 'NEW'  or 
--			_UPLOAD_DM_BANNER.Record_Status = 'CUR' 
--

	BEGIN TRY

		DECLARE @jobdate datetime
		SET @jobdate = getdate()

		DECLARE @email_body varchar(6000), @from varchar(500),@to_admin varchar(500) ,@reply_to varchar(500)
			,@email_subject varchar(500), @Header varchar(500)

		SET @from = 'appsmonitor@business.illinois.edu'
		SET @to_admin = 'appsmonitor@business.illinois.edu, nhadi@illinois.edu'
		SET @reply_to = 'appsmonitor@business.illinois.edu'
		SET @email_subject = '[DM] Step-by-Step Activity step 5 as of ' + cast(getdate() as varchar) 

		SET @header = '<HTML><B>[DM] Step By step Process Activity as of ' + cast(getdate() as varchar) + '</B><BR><R>'
					+ 'DailyUpdate_sp_DM_Step05_New_Employees_BEL_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees' + '</B><BR><BR>'

		DECLARE @Insert varchar(100)
		DECLARE @PERS_LNAME varchar(30)
		DECLARE @PERS_FNAME varchar(30)	
		DECLARE @PERS_MNAME varchar(30)	
		DECLARE @FAC_RANK_DESC varchar(35)	
		DECLARE @EMPEE_DEPT_NAME varchar(30)	
		DECLARE @EMPEE_GROUP_DESC varchar(30)	
		DECLARE @NETWORK_ID varchar(25)
		DECLARE @FIRST_HIRE_DT datetime, @CUR_HIRE_DT datetime, @FIRST_WORK_DT datetime
		DECLARE @JOB_DETL_TITLE varchar(30)
		DECLARE @JOB_DETL_DEPT_NAME varchar(30), @JOB_CNTRCT_TYPE_DESC varchar(20), @COLLEGE_JOB_DETL_FTE varchar(30)
		DECLARE @Sum_FTE Decimal(9,3)

		DECLARE @cdate datetime
		SET @cdate = getdate()


		INSERT INTO Database_Maintenance.dbo.Download_Process_Monitor_Logs
					(Table_Name, Copy_Datetime, [Status]) 
		VALUES('FSDB_EDW_Current_Employees 5', @jobdate, 0)


		-- STC 6/6/12 -- Only mark record for insertion in FSDB if no other records exist for the
		--		same employee with lower position or suffix #s (to prevent duplicates)

		-- Set 'T' to Update_Employee_Indicator for all new Group A,B,C from Library
		/*
		UPDATE  dbo.FSDB_EDW_Current_Employees
		SET Update_Employee_Indicator='T'
		WHERE New_Download_Indicator = 1
			AND FSDB_Processed_Indicator = 0
			AND  EDW_PERS_ID not in
	 			(SELECT EDW_PERS_ID
					 FROM dbo.Facstaff_Basic
				 WHERE EDW_PERS_ID is not NULL		
				)
			AND JOB_CNTRCT_TYPE_DESC = 'Primary'
			AND EMPEE_GROUP_CD in ('A','B','C')
			AND JOB_DETL_DEPT_NAME like 'Library%' 
		*/

		UPDATE  dbo.FSDB_EDW_Current_Employees
		SET Update_Employee_Indicator='DM-BEL'
		--SELECT e1.*
		FROM dbo.FSDB_EDW_Current_Employees E1
		WHERE New_Download_Indicator = 1
			AND  EDW_PERS_ID not in
				(SELECT EDWPERSID
					 FROM DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
				 WHERE EDWPERSID is not NULL		
				)
			AND JOB_CNTRCT_TYPE_DESC = 'Primary'
			AND EMPEE_GROUP_CD in ('A','B','C')
			AND EMPEE_ORG_TITLE like '%BEL%' 
			AND NOT EXISTS (SELECT EDW_PERS_ID
							FROM dbo.FSDB_EDW_Current_Employees E2
							WHERE New_Download_Indicator = 1
								AND  EDW_PERS_ID not in
	 								(SELECT EDWPERSID
										 FROM DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
									 WHERE EDWPERSID is not NULL		
									)
								AND JOB_CNTRCT_TYPE_DESC = 'Primary'
								AND EMPEE_GROUP_CD in ('A','B','C')
								AND EMPEE_ORG_TITLE like '%BEL%' 
								AND E1.EDW_PERS_ID = E2.EDW_PERS_ID
								AND (E1.POSN_NBR > E2.POSN_NBR 
									OR E1.JOB_SUFFIX > E2.JOB_SUFFIX)  
							)
	

		INSERT INTO DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			 (USERNAME
			  --,ID
			  --,FACSTAFFID
			  ,EDWPERSID
			  ,UIN
			  ,EDW_Database
			  ,PERS_PREFERRED_FNAME
			  ,PERS_FNAME
			  ,PERS_MNAME
			  ,PERS_LNAME
			  ,BIRTH_DT
			  ,SEX_CD
			  ,RACE_ETH_DESC
			  ,PERS_CITZN_TYPE_DESC
			  ,EMPEE_CAMPUS_CD
			  ,EMPEE_CAMPUS_NAME
			  ,EMPEE_COLL_CD
			  ,EMPEE_COLL_NAME
			  ,EMPEE_DEPT_CD
			  ,EMPEE_DEPT_NAME
			  ,JOB_DETL_TITLE
			  ,JOB_DETL_FTE
			  ,JOB_CNTRCT_TYPE_DESC
			  ,JOB_DETL_COLL_CD
			  ,JOB_DETL_COLL_NAME
			  ,JOB_DETL_DEPT_CD
			  ,JOB_DETL_DEPT_NAME
			  ,COA_CD
			  ,ORG_CD
			  ,EMPEE_ORG_TITLE
			  ,EMPEE_CLS_CD
			  ,EMPEE_CLS_LONG_DESC
			  ,EMPEE_GROUP_CD
			  ,EMPEE_GROUP_DESC
			  ,EMPEE_RET_IND
			  ,EMPEE_LEAVE_CATGRY_CD
			  ,EMPEE_LEAVE_CATGRY_DESC
			  ,BNFT_CATGRY_CD
			  ,BNFT_CATGRY_DESC
			  ,HR_CAMPUS_CD
			  ,HR_CAMPUS_NAME
			  ,EMPEE_STATUS_CD
			  ,EMPEE_STATUS_DESC
			  ,CAMPUS_JOB_DETL_FTE
			  ,COLLEGE_JOB_DETL_FTE
			  ,FAC_RANK_CD
			  ,FAC_RANK_DESC
			  ,FAC_RANK_ACT_DT
			  ,FAC_RANK_DECN_DT
			  ,FAC_RANK_ACAD_TITLE
			  ,FAC_RANK_EMRTS_STATUS_IND
			  ,FIRST_HIRE_DT
			  ,CUR_HIRE_DT
			  ,FIRST_WORK_DT
			  ,LAST_WORK_DT
			  ,EMPEE_TERMN_DT
			  ,Network_ID
		--	  ,Record_Status
			  ,Create_Datetime
			  ,Last_Update_Datetime
		)

		SELECT DISTINCT Network_ID
			  --,ID
			  --,FACSTAFFID
			  ,EDW_PERS_ID
			  ,UIN
			  ,EDW_Database
			  ,PERS_PREFERRED_FNAME
			  ,PERS_FNAME
			  ,PERS_MNAME
			  ,PERS_LNAME
			  ,BIRTH_DT
			  ,CASE WHEN SEX_CD='M' THEN 'Male' ELSE 'Female' END as SEX_CD  
			  ,RACE_ETH_DESC
			  ,PERS_CITZN_TYPE_DESC
			  ,EMPEE_CAMPUS_CD
			  ,EMPEE_CAMPUS_NAME
			  ,EMPEE_COLL_CD
			  ,EMPEE_COLL_NAME
			  ,EMPEE_DEPT_CD
			  ,EMPEE_DEPT_NAME
			  ,JOB_DETL_TITLE
			  ,JOB_DETL_FTE
			  ,JOB_CNTRCT_TYPE_DESC
			  ,JOB_DETL_COLL_CD
			  ,JOB_DETL_COLL_NAME
			  ,JOB_DETL_DEPT_CD
			  ,JOB_DETL_DEPT_NAME
			  ,COA_CD
			  ,ORG_CD
			  ,EMPEE_ORG_TITLE
			  ,EMPEE_CLS_CD
			  ,EMPEE_CLS_LONG_DESC
			  ,EMPEE_GROUP_CD
			  ,EMPEE_GROUP_DESC
			  ,EMPEE_RET_IND
			  ,EMPEE_LEAVE_CATGRY_CD
			  ,EMPEE_LEAVE_CATGRY_DESC
			  ,BNFT_CATGRY_CD
			  ,BNFT_CATGRY_DESC
			  ,HR_CAMPUS_CD
			  ,HR_CAMPUS_NAME
			  ,EMPEE_STATUS_CD
			  ,EMPEE_STATUS_DESC
			  ,CAMPUS_JOB_DETL_FTE
			  ,COLLEGE_JOB_DETL_FTE
			  ,FAC_RANK_CD
			  ,FAC_RANK_DESC
			  ,FAC_RANK_ACT_DT
			  ,FAC_RANK_DECN_DT
			  ,FAC_RANK_ACAD_TITLE
			  ,FAC_RANK_EMRTS_STATUS_IND
			  ,FIRST_HIRE_DT
			  ,CUR_HIRE_DT
			  ,FIRST_WORK_DT
			  ,LAST_WORK_DT
			  ,EMPEE_TERMN_DT
			  ,Network_ID
		--	  ,'NEW'
			  ,@cdate
			  ,'2/1/1920'
		FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
		WHERE  New_Download_Indicator = 1
			AND  Update_Employee_Indicator='DM-BEL'
			-- AND DM_Upload_Done_Indicator = 0
			--AND JOB_CNTRCT_TYPE_DESC = 'Primary'
			--AND EMPEE_GROUP_CD in ('A','B','C')
			--AND EMPEE_ORG_TITLE like '%BEL%' 
			--AND EDW_PERS_ID not in
			-- 	(SELECT EDW_PERS_ID
		 --      	 FROM DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			--	 WHERE EDW_PERS_ID is not NULL		
			--	)

		--  Set 'N' to Update_Employee_Indicator, and set FSDB_Processed_Indicator all new Group A employees
		UPDATE  dbo.FSDB_EDW_Current_Employees
		SET DM_Upload_Done_Indicator = 1
		WHERE New_Download_Indicator = 1 
			AND Update_Employee_Indicator = 'DM-BEL'
			--AND JOB_CNTRCT_TYPE_DESC = 'Primary'
			--AND EMPEE_GROUP_CD in ('A','B','C')
			--AND EMPEE_ORG_TITLE like '%BEL%' 

		-- STC added 11/19/18
		-- >>>>>>>>>>>>>>>>>>>>  2. Get FACSTAFFID, MARK new and Current employees
		--- 1.  GET the ID and FACSTAFFID into _UPLOAD_DM_BANNER based on EDWPERSID key
		--			This will help in resolving issues of USERNAME changes
		--	2.	SET Record_Status = 'NEW' if not in _DM_USERS

		--- GET the ID and FACSTAFFID if presence based on EDWPERSID key
		--	This will help in resolving issues of USERNAME changes
		UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
		SET FACSTAFFID = DMB.FACSTAFF_ID
		FROM DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER UDMB, DM_Shadow_Staging.dbo.FSDB_Facstaff_Basic DMB
		WHERE UDMB.EDWPERSID = DMB.EDW_PERS_ID
			AND EDWPERSID IN (
				SELECT EDW_PERS_ID
				FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
				WHERE  New_Download_Indicator = 1
					AND  Update_Employee_Indicator='DM-BEL'
				)

		-- MARK new and Current employees
		-- Since the default Record_Status = 'CURR', just set the 'NEW'
		UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
		SET Record_Status = 'NEW' 
		WHERE EDWPERSID NOT IN
				(SELECT EDWPERSID
					FROM DM_Shadow_Staging.dbo._DM_USERS
					WHERE Enabled_Indicator=1)

		UPDATE	Database_Maintenance.dbo.Download_Process_Monitor_Logs
		SET		Status = 2
		WHERE	Table_Name = 'FSDB_EDW_Current_Employees 5'
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

-- >>>>>>>>>>>>>>>>>>>>  5. SEND EMAILS to ADMINS
/*
Print '>> Prepare Email of new emps'

SET @Insert = '<HTML><BR><B>BEL New Employees</B><BR>Procedure: DailyUpdate_sp_DM_Step04_New_Employees_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees<BR><BR>'
SET @Insert = @Insert + 'Departmental Offices, Administrative Office and Office for Research need to fill up Title, Education, Rank, Addresses, Phone Number, Biosketches, and Photos <BR><BR> '
SET @Email_Body = ''

DECLARE email1  CURSOR READ_ONLY FOR
	SELECT distinct  PERS_LNAME, PERS_FNAME, PERS_MNAME, isnull(EMPEE_DEPT_NAME,'') as EMPEE_DEPT_NAME, 
		isnull(EMPEE_GROUP_DESC,'') as EMPEE_GROUP_DESC, isnull(JOB_CNTRCT_TYPE_DESC,''), 
		isnull(JOB_DETL_DEPT_NAME,'') as JOB_DETL_DEPT_NAME, isnull(FAC_RANK_DESC,'(No Rank Info)') as FAC_RANK_DESC,
		isnull(FIRST_HIRE_DT,'1/1/1900') as FIRST_HIRE_DT, 
		isnull(CUR_HIRE_DT,'1/1/1900') as CUR_HIRE_DT,
		isnull(FIRST_WORK_DT,'1/1/1900') as FIRST_WORK_DT, 
		isnull(NETWORK_ID,'') as NETWORK_ID,
		isnull(JOB_DETL_TITLE,'') as JOB_DETL_TITLE, COLLEGE_JOB_DETL_FTE
	FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
	WHERE  New_Download_Indicator = 1
		AND  Update_Employee_Indicator='DM-BEL'
	ORDER BY EMPEE_GROUP_DESC DESC, FAC_RANK_DESC DESC, JOB_DETL_DEPT_NAME DESC

				
OPEN email1
FETCH email1 INTO  @PERS_LNAME, @PERS_FNAME, @PERS_MNAME, @EMPEE_DEPT_NAME, @EMPEE_GROUP_DESC, 
	@JOB_CNTRCT_TYPE_DESC, @JOB_DETL_DEPT_NAME, @FAC_RANK_DESC, @FIRST_HIRE_DT, @CUR_HIRE_DT, @FIRST_WORK_DT, @NETWORK_ID,
	@JOB_DETL_TITLE, @COLLEGE_JOB_DETL_FTE

WHILE @@FETCH_STATUS = 0
	
     BEGIN
		SET @Email_Body = @Email_Body + @Insert + '<BR><b>' + @NETWORK_ID + '@illinois.edu : </b> (' + 
			@EMPEE_GROUP_DESC + ', ' +
			@JOB_DETL_DEPT_NAME + cast(@COLLEGE_JOB_DETL_FTE as varchar(7)) +'%) ' +
			 dbo.Compose_Fullname(@PERS_LNAME,@PERS_FNAME, @PERS_MNAME) + ', ' + 
			@EMPEE_DEPT_NAME+ ', ' + 
			@FAC_RANK_DESC + ', ' + @JOB_DETL_TITLE  + '<BR>Campus First Hire ' +  convert(varchar(30), @FIRST_HIRE_DT,101) + 
			'<BR>Current Employment First Hire ' +  convert(varchar(30), @CUR_HIRE_DT,101) +
			'<BR>Current Employment First Work ' +  convert(varchar(30), @FIRST_WORK_DT,101) + '<BR> '
	
		SET @insert = ''
		FETCH  email1 INTO @PERS_LNAME, @PERS_FNAME, @PERS_MNAME, @EMPEE_DEPT_NAME, @EMPEE_GROUP_DESC, 
			@JOB_CNTRCT_TYPE_DESC, @JOB_DETL_DEPT_NAME, @FAC_RANK_DESC, @FIRST_HIRE_DT, @CUR_HIRE_DT, @FIRST_WORK_DT, @NETWORK_ID,
			@JOB_DETL_TITLE, @COLLEGE_JOB_DETL_FTE
     END

CLOSE email1
DEALLOCATE email1

SET @email_subject = '[DM-UPLOAD] BEL New Employee(s)'
IF @insert = ''
	-- has at least a new emp to report
	BEGIN
		-- NS 5/11/2017 DEBUG commented out
		--EXEC dbo.DailyUpdate_sp_Send_Email 'research@business.illinois.edu','research@business.illinois.edu','research@business.illinois.edu',@email_subject, @email_body
		print 'send email for new emp(s)'

	END


print @email_subject
print @email_body

*/

--  (2) emps with no network ids
GO
