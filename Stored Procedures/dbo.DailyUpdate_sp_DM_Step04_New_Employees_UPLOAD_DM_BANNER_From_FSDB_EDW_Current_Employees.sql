SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

-- 6/7/2019 Took off emailing, move the function to dbo.DailyUpdate_sp_DM_Step07_sub_Send_Email_New_And_Termination_Emps
--
-- NS 3/25/2019
--		Found out that create and update _DM_UPLOAD_USERS table is done at
--			DailyUpdate_sp_DM_Step06_Update_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees
--
--		UPDATE dbo._UPLOAD_DM_users
--		SET DEP = dbo.DailyUpdate_fn_Get_DM_Department_Name_By_Banner_Dept_CD(ban.empee_dept_cd)
--		FROM dbo._UPLOAD_DM_users usr, dbo._UPLOAD_DM_BANNER ban
--		WHERE usr.FacstaffID = ban.FACSTAFFID
--
-- NS 11/6/2018: make sure a unique new record to be added to _UPLOAD_DM_BANNER table
--		 check uniqueness of the first and second round addition
--		 ADD RECORDS TO _DM_UPLOAD_banner,_UPLOAD_DM_Web_Ids, _DM_UPLOAD_USERS, _DM_UPLOAD_PCI
--		 AT
--		 DailyUpdate_sp_DM_Step06_Update_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees
-- NS 10/4/2017: runs well
-- NS 5/11/2017: Send emails to admin regarding (1) new emps (2) emps with no network  ids
--		Must take comments out from all EXEC dbo.DailyUpdate_sp_Send_Email
-- NS 4/28/2017: Do not upload those who do not have Network_ID (hence cannot create the USERNAME)

-- NS 4/11/2017: Revisited, worked!
-- NS 3/30/2017: Revisited. Created FSDB_EDW_Current_Employees table at DM_Shadow_Staging database functioning
--		as EDW_Current_Employees table in Facukty_Staff_Holder database
--
-- NS 3/28/2017: Moved related SP and tables (for downloadinging from EDW) to DM_Shadow_Staging database
--			These are on SP DailyUpdate_sp_DM_Step06_Update_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees
--				CREATE RECORDS in _UPLOAD_DM_PCI when there are new emps; changes in emp termination, names, UIN
--				CREATE RECORDS in _UPLOAD_DM_USERS when there are new emps; changes in emp termination, names, UIN

-- NS 11/26/2016: Determine NEW and CUR emps in _UPLOAD_DM_BANNER based on _DM_USERS table
--				CREATE RECORDS in _UPLOAD_DM_BANNER

CREATE  Procedure [dbo].[DailyUpdate_sp_DM_Step04_New_Employees_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees]
as
-- NS 11/16/2016
--		Codes on FSDB_EDW_Current_Employees table
--			SEX_CD   F or M
--			College_JOB_DETL_FTE   0-100
--			Campus_JOB_DETL_FTE    0-100
--			FAC_RANK_EMRTS_STATUS_IND  Y or N
--			EMPEE_RET_IND  Y or N
--
--		Codes on _UPLOAD_DM_BANNER, _UPLOAD_DM_PCI
--			SEX_CD   Female or Male
--			College_JOB_DETL_FTE   0-100
--			Campus_JOB_DETL_FTE    0-100
--			FAC_RANK_EMRTS_STATUS_IND  Yes or No
--			EMPEE_RET_IND Yes or No

-- >>>>>>>>>>>>>> PROCESS
--		Populate _UPLOAD_DM_BANNER from FSDB_EDW_Current_Employees
--		start from Job contract type = Primary, Secondary, and then overload
--
--		1. Get Primary Jobs, EXCEPT student workers and those who do not have Network_ID
--			Mark FSDB_EDW_Current_Employees.Update_Employee_Indicator = 'DM-PRIMARY' OR 'DM-NO-USERNAME'
--			Insert into _UPLOAD_DM_BANNER table
--			Mark FSDB_EDW_Current_Employees.DM_UPLOAD_Done_Indicator=1
--
--		2. Get Secondary Jobs, EXCEPT student workers and those who do not have Network_ID
--			Mark FSDB_EDW_Current_Employees.Update_Employee_Indicator = 'DM-SECONDARY'  OR 'DM-NO-USERNAME'
--			Insert into _UPLOAD_DM_BANNER table
--			Mark FSDB_EDW_Current_Employees.DM_UPLOAD_Done_Indicator=1
--
--		3. Get Doctoral students EXCEPT those who do not have Network_ID
--			Mark FSDB_EDW_Current_Employees.Update_Employee_Indicator = 'DOCTORAL' OR 'DM-NO-USERNAME'
--			Insert into _UPLOAD_DM_BANNER table
--			Mark FSDB_EDW_Current_Employees.DM_UPLOAD_Done_Indicator=1
--
--		4. Get FACSTAFFID
--		   Find out new and current emps, and mark them
--			_UPLOAD_DM_BANNER.Record_Status = 'NEW'  or 
--			_UPLOAD_DM_BANNER.Record_Status = 'CUR' 
--
--		5. Send email to admins
--				(1) new emps
--				(2) emps having no network ids
--
--	INPUT TABLES
--			DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
--			Decision_Support.dbo.
--	OUTPUT TABLES
--			_UPLOAD_DM_USERS, _UPLOAD_DM_PCI, _UPLOAD_DM_Web_IDs

-- >>>>>>>>>>>>>> INCLUDE
-- (EMPEE_GROUP_CD)
--	1 Primary Jobs: Group A (faculty & other academics)
--	  Primary Jobs: Group B (Academic Professionals)
--	  Primary Jobs: Group H (Academic Hourly & Grad Hourly)
--	  Primary Jobs: Group C (Civil Service Dept)
--	  Primary Jobs: Group E (Civil Service Extra Help)
--	  Primary Jobs: Group G (Graduate Assistants)
--	  Primary Jobs: Group S (Undergraduate Hourly)
--	  Primary Jobs: Group T (Retiree/Annuitant)
--	  Primary Jobs: Group U (Unpaid, Ignore don't put into FSDB)
--    Primary Jobs: Group P (Postdoc Fellows, Research Associates & Interns)

--	2 Other (Secondary, and so on) Jobs: Group (EMPEE_GROUP_CD) A (faculty & other academics)
--	  Other Jobs: Group B (Academic Professionals)
--	  Other Jobs: Group H (Academic Hourly & Grad Hourly)
--	  Other Jobs: Group C (Civil Service Dept)
--	  Other Jobs: Group E (Civil Service Extra Help)
--	  Other Jobs: Group G (Graduate Assistants)
--	  Other Jobs: Group S (Undergraduate Hourly)
--	  Other Jobs: Group T (Retiree/Annuitant)
--	  Other Jobs: Group U (Unpaid, Ignore don't put into FSDB)
--	  Other Jobs: Group P (Postdoc Fellows, Research Associates & Interns)
--
--	3 Doctoral students from PRR and RTA EDW increments
--
-- >>>>>>>>>>>>> EXCLUDE
--
-- (EMPEE_CLS_CD)	(EMPEE_CLS_LONG_DESC)
--	HG				Grad Hourly
--	SA				Student
--	GA				Graduate Assistants


	BEGIN TRY

			-- >>>>>>>>>>>>>> Set Mailing Addresses

			DECLARE @jobdate datetime
			SET @jobdate = getdate()

			DECLARE @email_body varchar(4000), @from varchar(500),@to_admin varchar(500) ,@reply_to varchar(500)
				,@email_subject varchar(500), @Header varchar(500)

			SET @from = 'appsmonitor@business.illinois.edu'
			SET @to_admin = 'appsmonitor@business.illinois.edu, nhadi@illinois.edu'
			SET @reply_to = 'appsmonitor@business.illinois.edu'
			SET @email_subject = '[DM] Step-by-Step Activity step 4 as of ' + cast(getdate() as varchar) 

			SET @header = '<HTML><B>[DM] Step By step Process Activity as of ' + cast(getdate() as varchar) + '</B><BR><R>'
						+ 'DailyUpdate_sp_DM_Step04_New_Employees_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees' + '</B><BR><BR>'

			INSERT INTO Database_Maintenance.dbo.Download_Process_Monitor_Logs
					(Table_Name, Copy_Datetime, [Status]) 
			VALUES('FSDB_EDW_Current_Employees 4', @jobdate, 0)

			-- >>>>>>>>>>>>>> Initialize table

			-- Might have already been done in STEP 3 dbo.DailyUpdate_sp_DM_Step03_Add_and_Terminate_Employees_at_Facstaff_Basic
			TRUNCATE TABLE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER

			-- RESET Update_Employee_Indicator, DM_UPLOAD_Done_Indicator for newly downloaded records

			UPDATE  DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
			SET Update_Employee_Indicator='', DM_UPLOAD_Done_Indicator = 0
			--FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees E1
			WHERE  new_download_indicator = 1


			-- >>>>>>>>>>>>>> 1. GET PRIMARY JOBS

			--	1.  Set 'DM-PRIMARY' to Update_Employee_Indicator for all  Group ('A','B','C','E','G','H','P','S','T','U') new employees
			--			Except students (EMPEE_CLS_CD IN ('GA','SA', 'HG'))
			--			Set 'DM-NO-USERNAME' to those in the group that do not have Network-ID
			--	2.  Insert those records marked with 'DM-PRIMARY' into _UPLOAD_DM_BANNER
			--	3.  Set DM_UPLOAD_Done_Indicator = 1 for those records


			DECLARE @cdate datetime
			SET @cdate = getdate()

			-- STC 5/24/12 -- Only mark record for insertion in FSDB if no other records exist for the
			--		same employee with lower position or suffix #s (to prevent duplicates)

			-- >>>>>>>>>>>>>>>>>>>>> PRIMARY Jobs

			--Print '  Add into _UPLOAD_DM_BANNER: Primary Jobs'

			/*
			>>>>>> DEBUG RESET FSDB_EDW_Current_Employees table to replay step 03 thru 10 

				UPDATE  DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
				SET DM_UPLOAD_Done_Indicator=0, Update_Employee_Indicator = ''
				WHERE New_Download_Indicator=1
			*/


			-- Mark employees whose Primary jobs in the college
			UPDATE  DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
			SET Update_Employee_Indicator='DM-PRIMARY'
			FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees E1
			WHERE (Network_ID is NOT NULL AND Network_ID <> '')
				AND DM_UPLOAD_Done_Indicator = 0
				AND new_download_indicator = 1
				AND JOB_CNTRCT_TYPE_DESC = 'Primary'
				AND EMPEE_GROUP_CD in ('A','B','C','E','G','H','P','S','T','U')
				AND JOB_DETL_COLL_CD='KM' 
				AND NOT EXISTS (SELECT EDW_PERS_ID
								FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees E2
								WHERE DM_UPLOAD_Done_Indicator = 0
									AND JOB_CNTRCT_TYPE_DESC = 'Primary'
									AND EMPEE_GROUP_CD in ('A','B','C','E','G','H','P','S','T','U')
									AND JOB_DETL_COLL_CD='KM'
									AND E1.EDW_PERS_ID = E2.EDW_PERS_ID
									AND (E1.POSN_NBR > E2.POSN_NBR 
										OR E1.JOB_SUFFIX > E2.JOB_SUFFIX)  
								)

			/*

			Check both tables for missing persons

			select * from DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
			where  new_download_indicator = 1
				--AND Update_Employee_Indicator='DM-PRIMARY'
			order by PERS_LNAME

			select * from Faculty_Staff_Holder.dbo.EDW_Current_Employees 
			where  new_download_indicator = 1
				--AND Update_Employee_Indicator='DM-PRIMARY'
			order by PERS_LNAME
			*/
			-- Unmark those who are Students
			UPDATE DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
			SET Update_Employee_Indicator='DM-STUDENTS'
			WHERE Update_Employee_Indicator = 'DM-PRIMARY' 
					AND EMPEE_CLS_CD IN ('GA','SA', 'HG')
					AND new_download_indicator = 1

			-- Mark those of primary jobs who does not have Network_ID and not student
			-- STC 11/19/18 - Added WHERE new_download_indicator = 1 for selection from E2

			UPDATE  DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
			SET Update_Employee_Indicator='DM-NO-USERNAME'
			FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees E1
			WHERE (Network_ID is NULL OR Network_ID = '')
				AND DM_UPLOAD_Done_Indicator = 0
				AND new_download_indicator = 1
				AND JOB_CNTRCT_TYPE_DESC = 'Primary'
				AND EMPEE_GROUP_CD in ('A','B','C','E','G','H','P','S','T','U')
				AND JOB_DETL_COLL_CD='KM' 
				AND NOT EXISTS (SELECT EDW_PERS_ID
								FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees E2
								WHERE new_download_indicator = 1
									AND DM_UPLOAD_Done_Indicator = 0
									AND JOB_CNTRCT_TYPE_DESC = 'Primary'
									AND EMPEE_GROUP_CD in ('A','B','C','E','G','H','P','S','T','U')
									AND JOB_DETL_COLL_CD='KM'
									AND E1.EDW_PERS_ID = E2.EDW_PERS_ID
									AND (E1.POSN_NBR > E2.POSN_NBR 
										OR E1.JOB_SUFFIX > E2.JOB_SUFFIX)  
								);

			/*
			-- NS 11/6/2018: make sure a unique new record to be added to FSDB_Facstaff_Basic
			-- check uniqueness of the first round addition
			SELECT edw_pers_id
			FROM FSDB_EDW_Current_Employees
			WHERE Update_Employee_Indicator='DM-PRIMARY' 
				AND new_download_indicator = 1
			GROUP BY edw_pers_id
			HAVING COUNT(*) > 1
			*/

			-- Insert the 'D' records into DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			-- Use  '2/1/1920' to indicate that this is a new record added to DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			--	This date will be updated at the end with the current date

			-- Just get the DM-PRIMARY records, avoid DM_NO_USERNAME  and DM-SECONDARY
			WITH uniquerecord1 AS
			(
				SELECT DISTINCT EDW_PERS_ID,UIN
				--FROM Faculty_Staff_Holder.dbo.EDW_Current_Employees
				--				WHERE  new_download_indicator = 1
				FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
				WHERE Update_Employee_Indicator='DM-PRIMARY'
					AND new_download_indicator = 1	


				/*
					SELECT DISTINCT EDW_PERS_ID,UIN
					FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
					WHERE Update_Employee_Indicator='DM-PRIMARY'
						AND new_download_indicator = 1	
		
					-- Some records in Faculty_Staff_Holder.dbo.EDW_Current_Employees not exist in DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees 
					--		atre all those student workers
					SELECT DISTINCT EDW_PERS_ID,UIN
					FROM Faculty_Staff_Holder.dbo.EDW_Current_Employees
					WHERE  new_download_indicator = 1	
							AND edw_pers_id in (
								SELECT DISTINCT EDW_PERS_ID
								FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
								WHERE Update_Employee_Indicator='DM-PRIMARY'
									AND new_download_indicator = 1	
							)
	
					-- DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees must be subset of Faculty_Staff_Holder.dbo.EDW_Current_Employees
					SELECT DISTINCT EDW_PERS_ID
					FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
					WHERE Update_Employee_Indicator='DM-PRIMARY'
						AND new_download_indicator = 1	
						AND edw_pers_id not in (
								SELECT DISTINCT EDW_PERS_ID
								FROM Faculty_Staff_Holder.dbo.EDW_Current_Employees
								WHERE  new_download_indicator = 1
						)

				*/
				/*
				SELECT DISTINCT EDW_PERS_ID,UIN, sex_cd, Network_ID
				FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
				WHERE Update_Employee_Indicator='DM-PRIMARY'
					AND new_download_indicator = 1	
				ORDER BY Network_ID
				*/
			)

			INSERT INTO DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
				 (USERNAME
				  --,ID
				  --,FACSTAFFID
				  ,EDWPERSID
				  ,UIN
				  ,EDW_Database
				  ,Network_ID
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
				  --,Record_Status
				  ,Create_Datetime
				  ,Last_Update_Datetime
			)

			SELECT DISTINCT s.Network_ID
				  --,ID
				  --,FB.FACSTAFF_ID
				  ,s.EDW_PERS_ID
				  ,s.UIN
				  ,s.EDW_Database
				  ,s.Network_ID
				  ,s.PERS_PREFERRED_FNAME
				  ,s.PERS_FNAME
				  ,s.PERS_MNAME
				  ,s.PERS_LNAME
				  ,s.BIRTH_DT
				  ,CASE WHEN s.SEX_CD='M' THEN 'Male' ELSE 'Female' END as SEX_CD  
				  ,s.RACE_ETH_DESC
				  ,s.PERS_CITZN_TYPE_DESC
				  ,s.EMPEE_CAMPUS_CD
				  ,s.EMPEE_CAMPUS_NAME
				  ,s.EMPEE_COLL_CD
				  ,s.EMPEE_COLL_NAME
				  ,s.EMPEE_DEPT_CD
				  ,s.EMPEE_DEPT_NAME
				  ,s.JOB_DETL_TITLE
				  ,s.JOB_DETL_FTE
				  ,s.JOB_CNTRCT_TYPE_DESC
				  ,s.JOB_DETL_COLL_CD
				  ,s.JOB_DETL_COLL_NAME
				  ,s.JOB_DETL_DEPT_CD
				  ,s.JOB_DETL_DEPT_NAME
				  ,s.COA_CD
				  ,s.ORG_CD
				  ,s.EMPEE_ORG_TITLE
				  ,s.EMPEE_CLS_CD
				  ,s.EMPEE_CLS_LONG_DESC
				  ,s.EMPEE_GROUP_CD
				  ,s.EMPEE_GROUP_DESC
				  ,CASE WHEN EMPEE_RET_IND = 'Y' THEN 'Yes' ELSE 'No' END as EMPEE_RET_IND 
				  ,s.EMPEE_LEAVE_CATGRY_CD
				  ,s.EMPEE_LEAVE_CATGRY_DESC
				  ,s.BNFT_CATGRY_CD
				  ,s.BNFT_CATGRY_DESC
				  ,s.HR_CAMPUS_CD
				  ,s.HR_CAMPUS_NAME
				  ,s.EMPEE_STATUS_CD
				  ,s.EMPEE_STATUS_DESC
				  ,s.CAMPUS_JOB_DETL_FTE
				  ,s.COLLEGE_JOB_DETL_FTE
				  ,s.FAC_RANK_CD
				  ,s.FAC_RANK_DESC
				  ,s.FAC_RANK_ACT_DT
				  ,s.FAC_RANK_DECN_DT
				  ,s.FAC_RANK_ACAD_TITLE
				  ,CASE WHEN s.FAC_RANK_EMRTS_STATUS_IND = 'Y' THEN 'Yes' ELSE 'No' END as FAC_RANK_EMRTS_STATUS_IND
				  ,s.FIRST_HIRE_DT
				  ,s.CUR_HIRE_DT
				  ,s.FIRST_WORK_DT
				  ,s.LAST_WORK_DT
				  ,s.EMPEE_TERMN_DT
				  --,'NEW'
				  ,@cdate
				  ,'2/1/1920'
			FROM uniquerecord1 u
				--CROSS APPLY (SELECT TOP 1 * FROM Faculty_Staff_Holder.dbo.EDW_Current_Employees	s1 WHERE u.UIN = s1.uin AND s1.new_download_indicator = 1) s
				CROSS APPLY (SELECT TOP 1 * FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees s1 WHERE u.UIN = s1.uin AND s1.New_Download_Indicator=1) s	

			--WHERE  DM_UPLOAD_Done_Indicator = 0
			--	AND  Update_Employee_Indicator='DM'
			--	AND JOB_CNTRCT_TYPE_DESC = 'Primary'
			--	AND EMPEE_GROUP_CD in ('A','B','C','E','G','H','P','S','T','U')
			--	AND JOB_DETL_COLL_CD = 'KM'
			--	AND EDW_PERS_ID not in
			--	 	(SELECT EDW_PERS_ID
			--       	 FROM DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			--		 WHERE EDW_PERS_ID is not NULL		
			--		)

			-- Log the activity
			-- DEBUG uncomment on production!

			--INSERT INTO DM_Shadow_Staging.dbo.Log_EDW_Activities   (Facstaff_id, EDW_PERS_ID, Network_ID, Create_Datetime, EDW_Download_Activity)
			--SELECT Facstaffid, EDWPERSID, Network_ID, @cdate, 'NewDM'
			--FROM dbo.DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			--WHERE Last_Update_Datetime = '2/1/1920'

			UPDATE  DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			SET Last_Update_Datetime = @cdate
			WHERE Last_Update_Datetime = '2/1/1920'


			-- DEBUG
			--EXEC dbo.Adhoc_Get_Duplicates_UPLOAD_DM_BANNER

			--  Set 'N' to Update_Employee_Indicator, and set DM_UPLOAD_Done_Indicator all new employees
			UPDATE  dbo.FSDB_EDW_Current_Employees
			SET DM_UPLOAD_Done_Indicator = 1
			WHERE DM_UPLOAD_Done_Indicator = 0
				AND Update_Employee_Indicator = 'DM-PRIMARY'
				--AND JOB_CNTRCT_TYPE_DESC = 'Primary'
				--AND EMPEE_GROUP_CD in ('A','B','C','E','G','H','P','S','T','U')
				--AND JOB_DETL_COLL_CD='KM' 


			-- >>>>>>>>>>>>>>>>>>>>> 2. GET SECONDARY Jobs

			--	1.  Set 'DM-SECONDARY' to Update_Employee_Indicator for all  Group ('A','B','C','E','G','H','P','S','T','U') new employees
			--			Except students (EMPEE_CLS_CD IN ('GA','SA', 'HG'))
			--			Set 'DM-NO-USERNAME' to those in the group that do not have Network-ID
			--	2.  Insert those records marked with 'DM-SECONDARY' into _UPLOAD_DM_BANNER
			--	3.  Set DM_UPLOAD_Done_Indicator = 1 for those records


			-- Set 'DM-SECONDARY' to Update_Employee_Indicator for all new Group A, B, C, ... employees
			UPDATE  DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
			SET Update_Employee_Indicator='DM-SECONDARY'
			WHERE (Network_ID is NOT NULL AND Network_ID <> '')
				AND DM_UPLOAD_Done_Indicator = 0
				AND EDW_PERS_ID not in
					(SELECT EDWPERSID
					 FROM DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
					 WHERE EDWPERSID is not NULL		
					)
				AND JOB_CNTRCT_TYPE_DESC <> 'Primary'
				AND EMPEE_GROUP_CD in ('A','B','C','E','G','H','P','S','T','U')
				AND JOB_DETL_COLL_CD='KM' 
				AND (Update_Employee_Indicator is NULL OR Update_Employee_Indicator = '')

			-- Unmark those who are Students
			UPDATE DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
			SET Update_Employee_Indicator='DM-STUDENTS'
			WHERE Update_Employee_Indicator = 'DM-SECONDARY' 
					AND EMPEE_CLS_CD IN ('GA','SA', 'HG')
					AND new_download_indicator = 1

			-- Mark those of secondary jobs who does not have Network_ID and not student
			UPDATE  DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
			SET Update_Employee_Indicator='DM-NO-USERNAME'
			WHERE (Network_ID is  NULL OR Network_ID = '')
				AND DM_UPLOAD_Done_Indicator = 0
				AND EDW_PERS_ID not in
					(SELECT EDWPERSID
					 FROM DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
					 WHERE EDWPERSID is not NULL		
					)
				AND JOB_CNTRCT_TYPE_DESC <> 'Primary'
				AND EMPEE_GROUP_CD in ('A','B','C','E','G','H','P','S','T','U')
				AND JOB_DETL_COLL_CD='KM' 
				AND (Update_Employee_Indicator is NULL OR Update_Employee_Indicator = '')


			--Print '  Add into _UPLOAD_DM_BANNER: Secondary Jobs'

			/*
			-- NS 11/6/2018: make sure a unique new record to be added to FSDB_Facstaff_Basic
			-- check uniqueness of the first round addition
			SELECT edw_pers_id
			FROM FSDB_EDW_Current_Employees
			WHERE Update_Employee_Indicator='DM-SECONDARY' 
				AND new_download_indicator = 1
			GROUP BY edw_pers_id
			HAVING COUNT(*) > 1
			*/


			SET @cdate = getdate();

			--  Insert those 'DM-SECONDARY' records into _UPLOAD_DM_BANNER, avoid DM-PRIMARY and DM-NO-USERNAME
			--  An employee might have multiple SECONDARY job, get just one, unfortunately

			WITH uniquerecord2 AS
			(
				SELECT DISTINCT EDW_PERS_ID,UIN
				FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
				WHERE Update_Employee_Indicator = 'DM-SECONDARY'
					AND new_download_indicator = 1
					AND UIN NOT IN (SELECT UIN FROM dbo._UPLOAD_DM_BANNER) 
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
				  --,Record_Status
				  ,Network_ID	
				  ,Create_Datetime
				  ,Last_Update_Datetime
			)

			SELECT DISTINCT s.Network_ID
				  --,ID
				  --,FB.FACSTAFF_ID
				  ,s.EDW_PERS_ID
				  ,s.UIN
				  ,s.EDW_Database
				  ,s.PERS_PREFERRED_FNAME
				  ,s.PERS_FNAME
				  ,s.PERS_MNAME
				  ,s.PERS_LNAME
				  ,s.BIRTH_DT
				  ,CASE WHEN s.SEX_CD='M' THEN 'Male' ELSE 'Female' END as SEX_CD  
				  ,s.RACE_ETH_DESC
				  ,s.PERS_CITZN_TYPE_DESC
				  ,s.EMPEE_CAMPUS_CD
				  ,s.EMPEE_CAMPUS_NAME
				  ,s.EMPEE_COLL_CD
				  ,s.EMPEE_COLL_NAME
				  ,s.EMPEE_DEPT_CD
				  ,s.EMPEE_DEPT_NAME
				  ,s.JOB_DETL_TITLE
				  ,s.JOB_DETL_FTE
				  ,s.JOB_CNTRCT_TYPE_DESC
				  ,s.JOB_DETL_COLL_CD
				  ,s.JOB_DETL_COLL_NAME
				  ,s.JOB_DETL_DEPT_CD
				  ,s.JOB_DETL_DEPT_NAME
				  ,s.COA_CD
				  ,s.ORG_CD
				  ,s.EMPEE_ORG_TITLE
				  ,s.EMPEE_CLS_CD
				  ,s.EMPEE_CLS_LONG_DESC
				  ,s.EMPEE_GROUP_CD
				  ,s.EMPEE_GROUP_DESC
				  ,s.EMPEE_RET_IND
				  ,s.EMPEE_LEAVE_CATGRY_CD
				  ,s.EMPEE_LEAVE_CATGRY_DESC
				  ,s.BNFT_CATGRY_CD
				  ,s.BNFT_CATGRY_DESC
				  ,s.HR_CAMPUS_CD
				  ,s.HR_CAMPUS_NAME
				  ,s.EMPEE_STATUS_CD
				  ,s.EMPEE_STATUS_DESC
				  ,s.CAMPUS_JOB_DETL_FTE
				  ,s.COLLEGE_JOB_DETL_FTE
				  ,s.FAC_RANK_CD
				  ,s.FAC_RANK_DESC
				  ,s.FAC_RANK_ACT_DT
				  ,s.FAC_RANK_DECN_DT
				  ,s.FAC_RANK_ACAD_TITLE
				  ,s.FAC_RANK_EMRTS_STATUS_IND
				  ,s.FIRST_HIRE_DT
				  ,s.CUR_HIRE_DT
				  ,s.FIRST_WORK_DT
				  ,s.LAST_WORK_DT
				  ,s.EMPEE_TERMN_DT
				  --,'NEW'
				  ,s.Network_ID
				  ,getdate()
				  ,'2/1/1920'
			FROM uniquerecord2 u
				CROSS APPLY (SELECT TOP 1 * FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees s1 WHERE u.UIN = s1.uin AND s1.New_Download_Indicator=1) s	

			UPDATE  dbo.FSDB_EDW_Current_Employees
			SET DM_UPLOAD_Done_Indicator = 1
			WHERE Update_Employee_Indicator = 'DM-SECONDARY'
						AND New_Download_Indicator=1

			--WHERE DM_UPLOAD_Done_Indicator = 0
			--	AND Update_Employee_Indicator = 'DM'
			--	AND JOB_CNTRCT_TYPE_DESC <> 'Primary'
			--	AND EMPEE_GROUP_CD in ('A','B','C','E','G','H','P','S','T','U')
			--	AND JOB_DETL_COLL_CD='KM' 
			--	AND EDW_PERS_ID not in
			--	 	(SELECT EDWPERSID
			--		 FROM DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			--		 WHERE EDWPERSID is not NULL		
			--		)

			--- GET the ID and FACSTAFFID if presence based on EDWPERSID key
			--	This will help in resolving issues of USERNAME changes

			UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			SET ID = DMB.ID
				,FACSTAFFID = DMB.FACSTAFFID
			FROM DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER UDMB, DM_Shadow_Staging.dbo._DM_BANNER DMB
			WHERE UDMB.EDWPERSID = DMB.EDWPERSID
		

			-- Log the activity
			-- DEBUG uncomment on production!

			--INSERT INTO DM_Shadow_Staging.dbo.Log_EDW_Activities   (Facstaff_id, EDW_PERS_ID, Network_ID, Create_Datetime, EDW_Download_Activity)
			--SELECT Facstaffid, EDWPERSID, Network_ID, @cdate, 'NewDM'
			--FROM dbo.DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			--WHERE Last_Update_Datetime = '2/1/1920'

			UPDATE  DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			SET Last_Update_Datetime = @cdate
			WHERE Last_Update_Datetime = '2/1/1920'






			-- >>>>>>>>>>>>>>>>>>>> 3. GET DOCTORALS Students

			--	1.  Set 'DOCTORAL' to Update_Employee_Indicator for new employees whose EDW_Database IN ('PRRDOC', 'RTADOC')
			--			Set 'DM-NO-USERNAME' to those in the group that do not have Network-ID
			--	2.  Insert those records marked with 'DOCTORAL' into _UPLOAD_DM_BANNER
			--	3.  Set DM_UPLOAD_Done_Indicator = 1 for those records

			-- Set 'DOCTORAL' to Update_Employee_Indicator for all new doctoral students
			UPDATE  DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
			SET Update_Employee_Indicator='DOCTORAL'
			WHERE (Network_ID is NOT NULL AND RTRIM(Network_ID) <> '')
						AND EDW_Database IN ('PRRDOC', 'RTADOC')
						AND New_Download_Indicator=1
						AND UIN NOT IN (SELECT UIN FROM dbo._UPLOAD_DM_BANNER) 

			UPDATE  DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
			SET Update_Employee_Indicator='DM-NO-USERNAME'
			WHERE (Network_ID is NULL OR RTRIM(Network_ID) = '')
						AND EDW_Database IN ('PRRDOC', 'RTADOC')
						AND New_Download_Indicator=1
						AND UIN NOT IN (SELECT UIN FROM dbo._UPLOAD_DM_BANNER) 

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
				  --,Record_Status
				  ,Network_ID	
				  ,Create_Datetime
				  ,Last_Update_Datetime)

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
				  --,'NEW' 
				  ,Network_ID
				  ,@cdate
				  ,'2/1/1920'
			FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
			WHERE New_Download_Indicator = 1
				  AND Update_Employee_Indicator='DOCTORAL'

			UPDATE  DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			SET Last_Update_Datetime = @cdate
			WHERE Last_Update_Datetime = '2/1/1920'

			UPDATE  dbo.FSDB_EDW_Current_Employees
			SET DM_UPLOAD_Done_Indicator = 1
				,Update_Employee_Indicator = 'DOCTORAL'
			WHERE EDW_Database IN ('PRRDOC', 'RTADOC') 
					AND New_Download_Indicator = 1


			-- >>>>>>>>>>>>>>>>>>>>  4. Get FACSTAFFID, MARK new and Current employees
			--- 1.  GET the ID and FACSTAFFID into _UPLOAD_DM_BANNER based on EDWPERSID key
			--			This will help in resolving issues of USERNAME changes
			--	2.	SET Record_Status = 'NEW' if not in _DM_USERS

			--- GET the ID and FACSTAFFID if presence based on EDWPERSID key
			--	This will help in resolving issues of USERNAME changes
			UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			SET FACSTAFFID = DMB.FACSTAFF_ID
			FROM DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER UDMB, DM_Shadow_Staging.dbo.FSDB_Facstaff_Basic DMB
			WHERE UDMB.EDWPERSID = DMB.EDW_PERS_ID

			-- Since the default Record_Status = 'CURR', just set the 'NEW'
			UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			SET Record_Status = 'NEW' 
			WHERE EDWPERSID NOT IN
					(SELECT EDWPERSID
						FROM DM_Shadow_Staging.dbo._DM_USERS 
						WHERE Enabled_Indicator=1)


			UPDATE	Database_Maintenance.dbo.Download_Process_Monitor_Logs
			SET		Status = 2
			WHERE	Table_Name = 'FSDB_EDW_Current_Employees 4'
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
select * from DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
WHERE EDWPERSID NOT IN
		(SELECT EDWPERSID
			FROM DM_Shadow_Staging.dbo._DM_USERS 
			WHERE Enabled_Indicator=1)

select username, pers_fname, pers_mname, pers_lname
from DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
WHERE EDWPERSID NOT IN
		(SELECT EDWPERSID
			FROM DM_Shadow_Staging.dbo._DM_USERS 
			WHERE Enabled_Indicator=1)

select * from DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
WHERE EDWPERSID NOT IN
		(SELECT EDWPERSID
			FROM DM_Shadow_Staging.dbo._DM_USERS )


*/


	/*
		TRUNCATE TABLE _UPLOAD_DM_BANNER
		EXEC dbo.[DailyUpdate_sp_DM_Step03_New_Employees_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees]

		select * from DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER where record_status='new'
		select * from DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER where record_status<>''
	*/








-- >>>>>>>>>>>>>>>>>>>>  5. SEND EMAILS to ADMINS
--		(1) new emps
--		(2) emps with no network ids

--DECLARE @EDWPERSID as VARCHAR(12)
--DECLARE @PERS_LNAME varchar(120), @PERS_FNAME varchar(120), @PERS_MNAME varchar(120),@NETWORK_ID varchar(120)
--DECLARE @EMPEE_DEPT_NAME varchar(120), @EMPEE_GROUP_DESC varchar(120), @JOB_DETL_DEPT_NAME varchar(120)
--DECLARE @JOB_CNTRCT_TYPE_DESC varchar(120), @FAC_RANK_DESC varchar(120), @JOB_DETL_TITLE varchar(120), @COLLEGE_JOB_DETL_FTE varchar(120)
----DECLARE @FIRST_HIRE_DT varchar(120), @CUR_HIRE_DT varchar(120), @FIRST_WORK_DT varchar(120)
--DECLARE @FIRST_HIRE_DT datetime, @CUR_HIRE_DT datetime, @FIRST_WORK_DT datetime
--DECLARE @Email_Body varchar(MAX), @email_subject varchar(500)

--DECLARE @insert varchar(500)

-- (1) new emps

/*
Print '>> Prepare Email of new emps'

SET @Insert = '<HTML><BR><B>New Employees</B><BR>Procedure: DailyUpdate_sp_DM_Step04_New_Employees_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees<BR><BR>'
SET @Insert = @Insert + 'Departmental Offices, Administrative Office and Office for Research need to fill up Title, Education, Rank, Addresses, Phone Number, Biosketches, and Photos <BR><BR> '
SET @Email_Body = ''

DECLARE email1  CURSOR READ_ONLY FOR
	SELECT distinct  EDWPERSID, PERS_LNAME, PERS_FNAME, PERS_MNAME, isnull(EMPEE_DEPT_NAME,'') as EMPEE_DEPT_NAME, 
		isnull(EMPEE_GROUP_DESC,'') as EMPEE_GROUP_DESC, isnull(JOB_CNTRCT_TYPE_DESC,''), 
		isnull(JOB_DETL_DEPT_NAME,'') as JOB_DETL_DEPT_NAME, isnull(FAC_RANK_DESC,'(No Rank Info)') as FAC_RANK_DESC,
		isnull(FIRST_HIRE_DT,'1/1/1900') as FIRST_HIRE_DT, 
		isnull(CUR_HIRE_DT,'1/1/1900') as CUR_HIRE_DT,
		isnull(FIRST_WORK_DT,'1/1/1900') as FIRST_WORK_DT, 
		isnull(NETWORK_ID,'') as NETWORK_ID,
		isnull(JOB_DETL_TITLE,'') as JOB_DETL_TITLE, COLLEGE_JOB_DETL_FTE
	FROM  DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
	WHERE Record_Status = 'NEW'
			AND EMPEE_GROUP_CD IN ('A','B','C','E','G','H','P','S','T','U')
			AND EMPEE_CLS_CD NOT IN ('GA','SA', 'HG')	-- exclude student workers
			AND Send_Email_Update_New_Emp_Status =  0
	ORDER BY EMPEE_GROUP_DESC DESC, FAC_RANK_DESC DESC, JOB_DETL_DEPT_NAME DESC

	--SELECT distinct  PERS_LNAME, PERS_FNAME, PERS_MNAME, isnull(EMPEE_DEPT_NAME,''), 
	--	isnull(EMPEE_GROUP_DESC,''), isnull(JOB_CNTRCT_TYPE_DESC,''), 
	--	isnull(JOB_DETL_DEPT_NAME,''), isnull(FAC_RANK_DESC,'(No Rank Info)'),
	--	isnull(FIRST_HIRE_DT,'1/1/1900'), 
	--	isnull(CUR_HIRE_DT,'1/1/1900'),
	--	isnull(FIRST_WORK_DT,'1/1/1900'), 
	--	isnull(NETWORK_ID,''),
	--	isnull(JOB_DETL_TITLE,''), Sum_FTE
	--FROM  dbo.EDW_Current_Employees
	--WHERE New_Download_Indicator = 1 
	--	AND FSDB_Update_Employee_Indicator = 'T'
	--	AND JOB_CNTRCT_TYPE_DESC = 'Primary'
	--	AND EMPEE_GROUP_CD = 'A'
	--	AND JOB_DETL_COLL_CD='KM' 
				
OPEN email1
FETCH email1 INTO  @EDWPERSID, @PERS_LNAME, @PERS_FNAME, @PERS_MNAME, @EMPEE_DEPT_NAME, @EMPEE_GROUP_DESC, 
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
	
		UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
		SET Send_Email_Update_New_Emp_Status = 1
		WHERE EDWPERSID = @EDWPERSID

		SET @insert = ''
		FETCH  email1 INTO @EDWPERSID, @PERS_LNAME, @PERS_FNAME, @PERS_MNAME, @EMPEE_DEPT_NAME, @EMPEE_GROUP_DESC, 
			@JOB_CNTRCT_TYPE_DESC, @JOB_DETL_DEPT_NAME, @FAC_RANK_DESC, @FIRST_HIRE_DT, @CUR_HIRE_DT, @FIRST_WORK_DT, @NETWORK_ID,
			@JOB_DETL_TITLE, @COLLEGE_JOB_DETL_FTE
     END

CLOSE email1
DEALLOCATE email1


SET @email_subject = '[DM-UPLOAD] New Employee(s)'
IF @Email_Body <> ''
	-- has at least a new emp to report
	BEGIN
		-- NS 5/11/2017 DEBUG commented out
		--EXEC dbo.DailyUpdate_sp_Send_Email 'research@business.illinois.edu','research@business.illinois.edu','research@business.illinois.edu',@email_subject, @email_body
		EXEC dbo.DailyUpdate_sp_Send_Email @from,@to,@reply_to,@email_subject, @email_body
		print 'send email for new emp(s)'

	END


print @email_subject
print @email_body
*/



--  (2) emps with no network ids
/*
Print '>> Prepare Email of emps with no network ids'

DECLARE @listStr VARCHAR(MAX), @count as INT

SET @email_subject = '[DM-UPLOAD] Employee(s) without Network ID'

SELECT @count=count(*)
FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
WHERE New_Download_Indicator=1
		AND Update_Employee_Indicator = 'DM-NO-USERNAME'
		--New_Download_Indicator=1
		--AND Update_Employee_Indicator='DM-PRIMARY'
		--AND (  (Network_ID is NULL OR Network_ID = '')
		--	    AND EDW_Database IN ('PRRDOC', 'RTADOC')
		--	OR (Update_Employee_Indicator = 'DM-NO-USERNAME' )
		--  )

SELECT @listStr = COALESCE(@listStr+'<BR/>' ,'') + EDW_PERS_ID + ' : ' + PERS_LNAME + ', ' + PERS_FNAME 
		+ ' : ' +  ISNULL(EMPEE_DEPT_NAME,'No Department') + ' : ' + ISNULL(JOB_DETL_TITLE,'No Job Title')
FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
WHERE New_Download_Indicator=1
		AND Update_Employee_Indicator = 'DM-NO-USERNAME'
	  --New_Download_Indicator=1
	  --AND (  (Network_ID is NULL OR Network_ID = '')
	  --    AND EDW_Database IN ('PRRDOC', 'RTADOC')
	  --OR (Update_Employee_Indicator = 'DM-NO-USERNAME' )
	  -- )
ORDER BY PERS_LNAME, PERS_FNAME

SET @email_body = ''	
IF @count <> 0
	BEGIN
		SET @email_body = '<HTML><B>[DM-UPLOAD] As of ' + cast(getdate() as varchar) + ' Found the following records having no Network_ID, cannot be saved to these DM Shadow tables and neither uploaded to Activity Insight '
			+ '<BR>'
			+ '_UPLOAD_DM_BANNER <BR>'
			+ '_UPLOAD_DM_USERS <BR>'
			+ '_UPLOAD_DM_PCI <BR>'
			+ '<BR><BR></B>'
			+ @listStr + '<BR><BR>'
			+ 'Procedures: DM_Shadow_Staging.dbo.DailyUpdate_sp_DM_Step04_New_Employees_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees'
			+ '<BR><BR></HTML>'
		/*
		ALTER	PROCEDURE [dbo].[DailyUpdate_sp_Send_Email]
			(
				@From varchar(100), 
				@To varchar(500), 
				@ReplyTo varchar(100), 
				@EmailSubject varchar(200) = ' ', 
				@EmailBody varchar(MAX) = ' '
			)
		*/
		EXEC dbo.DailyUpdate_sp_Send_Email 'research@business.illinois.edu','nhadi@illinois.edu','research@business.illinois.edu',@email_subject, @email_body
	END

print @email_subject
print @email_body
*/
/*
select * from DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER	order by username -- 514 records (including 2 from BEL)
select * from DM_Shadow_Staging.dbo._UPLOAD_DM_USERS
*/

GO
