SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 6/11/2019: Ran 5'35"
-- NS 4/24/2019
--	NS Fixed College and Campus FTE counting based on unique position numbers, added TENURE_INDICATOR
--
-- STC 11/19/2018
--		Added JOB_DETL_DATA_STATUS_DESC
--		Get Manual from FSDB until we switch to using FSB in DM -- need to update later!
--
-- NS 11/6/2018
--		Added manually added employess in FSDB_Facstaff_Basic to get fields updated from EDW
--		Need to remove duplicates in newly downloaded records on FSDB_EDW_Current_Employees table
--
-- NS 9/27/2017: Start to run Step 1,2, and 3 side by side with FSDB version, 
--	new records at FSDB_Facstaff_ID starts from Facstaff_ID=102394
--
-- NS 9/26/2017: 102392 (9/26/2017)
-- NS 4/28/2017 Testing: max(Facstaff_ID) from regular FSDB is 101989 (4/26/2017), 102008 (5/11/2017)
--		delete from fsdb_facstaff_basic where facstaff_ID > 101989
--		select max(facstaff_id) from faculty_staff_holder.dbo.facstaff_basic
-- NS 4/28/2017 added conditions to avoid duplicate records for which 
--			   a) primary in COB and secondary is elsewhere
--			   b) secondary in COB and primary is elsewhere, or
--			   c) non-current JOB_HIST records
-- NS 3/30/2017: Revisited. Created FSDB_EDW_Current_Employees table at DM_Shadow_Staging database functioning
--		as EDW_Current_Employees table in Faculty_Staff_Holder database
--
-- NS 3/28/2017: Moved related SP and tables (for downloading from EDW) to DM_Shadow_Staging database
--			These are on SP DailyUpdate_sp_DM_Step06_Update_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees
--				CREATE RECORDS in _UPLOAD_DM_PCI when there are new emps; changes in emp termination, names, UIN
--				CREATE RECORDS in _UPLOAD_DM_USERS when there are new emps; changes in emp termination, names, UIN

-- NS 11/18/2016
--		Rewrites from dbo.DailyUpdate_sp_Get_Current_College_Of_Business_Employees_From_EDW

--		Some codes on FSDB_EDW_Current_Employees table
--			SEX_CD   F or M
--			College_JOB_DETL_FTE   0-100
--			Campus_JOB_DETL_FTE    0-100
--			FAC_RANK_EMRTS_STATUS_IND  Y or N
--			EMPEE_RET_IND  Y or N

-- NS 11/15/2016 Running time is between 3'45" and 4'15"

--		Added DM_Upload_Done_Indicator column, new download will set DM_Upload_Done_Indicator=0
--			When DM upload is done set DM_Upload_Done_Indicator=1
--
--		In order to match EDW fields that we configured on Digital Measures, 
--		we needed to add more fields here (and will be removing some fields in the future) to sync with 
		
		--RACE_ETH_DESC
		--PERS_CITZN_TYPE_DESC
		
		--EMPEE_CAMPUS_CD
		--EMPEE_CAMPUS_NAME
		--EMPEE_COLL_CD
		--EMPEE_COLL_NAME
		
		--COA_CD
		--ORG_CD
		--EMPEE_ORG_TITLE

		--EMPEE_RET_IND
		--EMPEE_LEAVE_CATGRY_CD
		--EMPEE_LEAVE_CATGRY_DESC
		--BNFT_CATGRY_CD
		--BNFT_CATGRY_DESC
		--HR_CAMPUS_CD
		--HR_CAMPUS_NAME
		
		--CAMPUS_JOB_DETL_FTE
		--COLLEGE_JOB_DETL_FTE

		--CUR_HIRE_DT
		--LAST_WORK_DT
		--FIRST_WORK_DT
		--EMPEE_TERMN_DT
	
		--EMPEE_CAMPUS_CD
		--EMPEE_CAMPUS_NAME
		--EMPEE_COLL_CD
		--EMPEE_COLL_NAME
		
		--COA_CD
		--ORG_CD
		--EMPEE_ORG_TITLE

		--EMPEE_RET_IND
		--EMPEE_LEAVE_CATGRY_CD
		--EMPEE_LEAVE_CATGRY_DESC
		--BNFT_CATGRY_CD
		--BNFT_CATGRY_DESC
		--HR_CAMPUS_CD
		--HR_CAMPUS_NAME
		
		--CAMPUS_JOB_DETL_FTE
		--COLLEGE_JOB_DETL_FTE

		--CUR_HIRE_DT
		--LAST_WORK_DT
		--FIRST_WORK_DT
		--EMPEE_TERMN_DT		

-- KA 10/2010: Included monitoring codes for Database_maintenance
--   Ashwini-Stored procedure updated on 26th-july-2007. Table:edw_t_job_detl was eliminated from the stored procedure 
--   since its presence was generating improper results

-- NS 2/21/2007
-- JOB_DETL_DEPT_NAME,	 is now 35 chars, it was 30 chars before hence generating 'String/Binary truncation' error

-- NS 5/19/2006:
-- Add ##EMPS_step01 to get edw_pers_id of employees related to College of Business, we will pull all job information (regardless of Business related) from those persons
-- Get all univ wide jobs, add JOB_DETL_COLL_CD field to indicate colleges
-- Add Univ_Sum_FTE for campus wide positions, it now based on Primary and Secondary only, exclude Overloads
-- Alter Sum_FTE to sum only college of business jobs

-- NS 5/10/2006:
-- Alter Sum_FTE, it now based on Primary and Secondary only, exclude Overloads

-- NS 5/7/2006:
-- Added   POSH.POSN_EMPEE_CLS_CD, 
--  	   POSH.POSN_EMPEE_CLS_LONG_DESC

-- NS 8/6/2007 Get complete info of the FUTURE when there is no current JOB_DETL_DATA_STATUS_DESC in EDW_V_JOB_DETL_HIST_1 table

-- NS 7/252007 get  also FUTURE's EDW_PERS_ID from EDW_V_JOB_DETL_HIST_1 table for on-and-off professors

-- NS 1/20/2006
-- This is the first part of the series:
--	1) DailyUpdate_sp_DM_Step01_Get_Current_College_Of_Business_Employees_From_EDW:
--		Get all current employees from Decision_Support_HR into FSDB_EDW_Current_Employees 
--	2) DailyUpdate_sp_DM_Step02_Get_Current_College_Of_Business_Doctoral_Students_From_EDW
--		Get all current doctoral students
--	3) DailyUpdate_sp_DM_Step03_Add_and_Terminate_Employees_at_Facstaff_Basic
--		Add/update records at FSDB Facstaff_Basic table based on FSDB_EDW_Current_Employees table

-- NS 10/18/2005
--	First revision
-- Task: Get all current employees from Decision_Support_HR into FSDB temporary table:
-- 	Each download will set old data to have new_download_indicator = 0, and new data to have new_download_indicator = 1
--	Create_Datetime is also set for each download
-- Q:	How to get terminated employees?
-- RELATED TABLES
--		EDW_T_EMPEE_PERS
--		EDW_V_EMPEE_PERS_HIST_1
--		EDW_V_EMPEE_HIST_1
--		EDW_T_JOB
--		EDW_T_JOB_HIST
--		EDW_T_JOB_DETL
--		EDW_V_JOB_DETL_HIST_1
--		EDW_T_POSN
--		EDW_T_POSN_HIST





CREATE PROCEDURE [dbo].[DailyUpdate_sp_DM_Step01_Get_Current_College_Of_Business_Employees_From_EDW]
AS

	BEGIN TRY
		DECLARE @jobdate datetime
		SET @jobdate = getdate()

		DECLARE @email_body varchar(4000), @from varchar(500),@to_admin varchar(500) ,@reply_to varchar(500)
			,@email_subject varchar(500), @Header varchar(500)

		SET @from = 'appsmonitor@business.illinois.edu'
		SET @to_admin = 'appsmonitor@business.illinois.edu, nhadi@illinois.edu'
		SET @reply_to = 'appsmonitor@business.illinois.edu'
		SET @email_subject = '[DM] Step-by-Step Activity step 1 as of ' + cast(getdate() as varchar) 

		SET @header = '<HTML><B>[DM] Step By step Process Activity as of ' + cast(getdate() as varchar) + '</B><BR><R>'
					+ 'DailyUpdate_sp_DM_Step01_Get_Current_College_Of_Business_Employees_From_EDW' + '</B><BR><BR>'
/*
	Must check the following if new emps not pulled in from EDW
	1. BUSDBSRV
		  SELECT *  FROM [Decision_Support_HR].[dbo].[EDW_V_EMPEE_PERS_HIST_1]
		  WHERE PERS_LNAME='markel'
		    
		  SELECT * FROM [Decision_Support_HR].[dbo].EDW_V_JOB_DETL_HIST_1
		  WHERE EDW_PERS_ID = 3702331
		  
		  SELECT * FROM [Decision_Support_HR].[dbo].EDW_T_JOB_HIST
		  WHERE EDW_PERS_ID = 3702331
		  
	2. BUSDBUGRAD
		  SELECT *  FROM [Decision_Support_Source].[dbo].[EDW_V_EMPEE_PERS_HIST_1]
		  WHERE PERS_LNAME='markel'
		    
		  SELECT * FROM [Decision_Support_Source].[dbo].EDW_V_JOB_DETL_HIST_1
		  WHERE EDW_PERS_ID = 3702331
		  
		  SELECT * FROM [Decision_Support_Source].[dbo].EDW_T_JOB_HIST
		  WHERE EDW_PERS_ID = 3702331
	
	3. BUSDBUGRAD FOR EDW
	
		SELECT    EDW_PERS_ID,  PERS_LNAME, PERS_FNAME, EMPEE_EFF_DT, EMPEE_GROUP_CD , EMPEE_cls_CD , EMPEE_COLL_CD, EMPEE_COLL_NAME, EMPEE_DEPT_CD, EMPEE_DEPT_NAME
		FROM     OPENQUERY(Decision_Support,
				'SELECT ROUND(PH1.EDW_PERS_ID,0) AS EDW_PERS_ID,  PH1.PERS_LNAME, PH1.PERS_FNAME, EH1.EMPEE_EFF_DT, EH1.EMPEE_GROUP_CD , 
					EH1.EMPEE_cls_CD , EH1.EMPEE_COLL_CD, EH1.EMPEE_DEPT_CD, EH1.EMPEE_DEPT_NAME,  EH1.EMPEE_COLL_NAME
					FROM EDW.V_EMPEE_PERS_HIST_1  PH1, EDW.V_EMPEE_HIST_1  EH1 
				WHERE PH1.edw_pers_id = eh1.edw_pers_id AND ph1.PERS_LNAME = ''Markel''  ')
		ORDER BY EMPEE_EFF_DT DESC

		SELECT    *
		FROM    OPENQUERY(Decision_Support,
				'SELECT ROUND(EDW_PERS_ID,0) AS EDW_PERS_ID,  POSN_NBR, JOB_SUFFIX, JOB_DETL_HIST_EFF_DT
				FROM EDW.V_JOB_DETL_HIST_1
				WHERE edw_pers_id = ''3702331'' ')

		SELECT    *
		FROM    OPENQUERY(Decision_Support,
				'SELECT ROUND(EDW_PERS_ID,0) AS EDW_PERS_ID,  PERS_LNAME, PERS_FNAME
				FROM EDW.V_EMPEE_PERS_HIST_1 
				WHERE edw_pers_id = ''3702331'' ')

		SELECT    *
		FROM    OPENQUERY(Decision_Support,
				'SELECT ROUND(EDW_PERS_ID,0) AS EDW_PERS_ID,  POSN_NBR, JOB_SUFFIX, JOB_HIST_EFF_DT
				FROM EDW.T_JOB_HIST 
				WHERE edw_pers_id = ''3702331'' ')

		SELECT    *
		FROM    OPENQUERY(Decision_Support,
				'SELECT ROUND(EDW_PERS_ID,0) AS EDW_PERS_ID,  FIRST_HIRE_DT, EMPEE_DEPT_CD,	EMPEE_CLS_CD	
				FROM EDW.V_EMPEE_HIST_1 
				WHERE edw_pers_id = ''3702331'' ')
	
*/
		--TRUNCATE TABLE dbo.FSDB_EDW_Current_Employees

		INSERT INTO Database_Maintenance.dbo.Download_Process_Monitor_Logs
					(Table_Name, Copy_Datetime, [Status]) 
		VALUES('FSDB_EDW_Current_Employees 1', @jobdate, 0)

		-- Make all previous downloads OBSOLETE, except ones whose EDW_Database in ('PRRDOC','RTADOC')
		--		since they are on a separate download stored procedure
		update DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
		set new_download_indicator = 0
		where  new_download_indicator = 1 and EDW_Database not in ('PRRDOC','RTADOC')

		update DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
		set DM_Upload_Done_Indicator=1
		where  DM_Upload_Done_Indicator=0 and EDW_Database not in ('PRRDOC','RTADOC')


		IF OBJECT_ID('TempDB..##EMPS_step01') IS NOT NULL 
			DROP TABLE ##EMPS_step01
	
		-- >>>> GET all EDW_PERS_ID working with Gies College_Of_Business
		--			and those who are affiliated (new records added manually not automatically downloaded) with Gies

		CREATE TABLE ##EMPS_step01 (
				[EDW_PERS_ID] [varchar] (12)  NULL
		) ON [PRIMARY] 

		PRINT ' > Get current employees EDW_PERS_ID '
		INSERT INTO ##EMPS_step01 (EDW_PERS_ID)

		-- Current College of Business employees

		SELECT DISTINCT H1.edw_pers_id
		FROM	 Decision_Support_HR.dbo.EDW_V_EMPEE_HIST_1 H1
     				INNER JOIN 
				Decision_Support_HR.dbo.EDW_T_JOB J
					INNER JOIN 
				Decision_Support_HR.dbo.EDW_T_JOB_HIST JH
					ON	J.EDW_PERS_ID=JH.EDW_PERS_ID and 
						J.JOB_SUFFIX=JH.JOB_SUFFIX and 
						J.POSN_NBR=JH.POSN_NBR 

		--Table:edw_t_job_detl is being eliminated from the stored procedure since its presence is generating improper results

				--INNER JOIN Decision_Support_HR.dbo.EDW_T_JOB_DETL JD

					INNER JOIN 
				Decision_Support_HR.dbo.EDW_V_JOB_DETL_HIST_1 JDH1
					ON	JH.EDW_PERS_ID=JDH1.EDW_PERS_ID  AND
						JH.JOB_SUFFIX=JDH1.JOB_SUFFIX AND 
						JH.POSN_NBR=JDH1.POSN_NBR 

							/*
							ON JDH1.EDW_PERS_ID=JD.EDW_PERS_ID  and JDH1.JOB_SUFFIX=JD.JOB_SUFFIX and JDH1.POSN_NBR=JD.POSN_NBR 
								and JDH1.JOB_DETL_CUR_INFO_IND = 'Y'
								and JDH1.JOB_DETL_EFF_DT=JD.JOB_DETL_EFF_DT 
							ON JD.EDW_PERS_ID=J.EDW_PERS_ID and JD.JOB_SUFFIX=J.JOB_SUFFIX and JD.POSN_NBR=J.POSN_NBR 
							*/
					INNER JOIN 
				Decision_Support_HR.dbo.EDW_T_POSN POS
					INNER JOIN 
				Decision_Support_HR.dbo.EDW_T_POSN_HIST POSH
					ON	POS.POSN_NBR=POSH.POSN_NBR 
					ON	J.POSN_NBR=POS.POSN_NBR 
     				ON	H1.EMPEE_CUR_INFO_IND= 'Y' AND 
						J.EDW_PERS_ID = H1.EDW_PERS_ID AND 
						JDH1.JOB_DETL_CUR_INFO_IND = 'Y'

		WHERE	JDH1.JOB_DETL_COLL_CD  =  'KM' AND
				POSH.POSN_DATA_STATUS_DESC  =  'Current' AND 
				JH.JOB_DATA_STATUS_DESC  =  'Current' AND  
				H1.EMPEE_DATA_STATUS_DESC  =  'Current'AND  
				JDH1.JOB_DETL_STATUS_DESC  =  'Active' AND 
				-- NS 7/25/2007 get  also FUTURE's EDW_PERS_ID from EDW_V_JOB_DETL_HIST_1 table for on-and-off professors
				-- JDH1.JOB_DETL_DATA_STATUS_DESC  =  'Current' AND
				JDH1.JOB_DETL_DATA_STATUS_DESC in ( 'Current','Future')  AND
      			JDH1.JOB_DETL_DEPT_CD <> '405' -- Economics

		UNION

		-- Business and Economics Library (BEL) employees: ALL Class A, B, and C
		SELECT DISTINCT	 H1.edw_pers_id
		FROM	Decision_Support_HR.dbo.EDW_V_JOB_DETL_HIST_1 JOB 
					INNER JOIN 
				Decision_Support_HR.dbo.EDW_V_EMPEE_HIST_1 H1
					ON	JOB.EDW_PERS_ID = H1.EDW_PERS_ID AND  
						H1.EMPEE_DATA_STATUS_DESC  =  'Current' AND 
						H1.EMPEE_CUR_INFO_IND= 'Y' 

		WHERE	JOB.job_detl_org_title = 'BEL' and 
				(H1.Empee_CLS_CD LIKE 'A%' OR  H1.Empee_CLS_CD LIKE 'B%' OR  H1.Empee_CLS_CD LIKE 'C%') AND
				JOB.JOB_DETL_DATA_STATUS_DESC  =  'Current' AND
				JOB.JOB_DETL_STATUS_DESC  =  'Active' 

		--UNION

		---- NS 5/23/2019 commented out all this part since we have moced to DM from March 2019:
		---- NS 11/6/2018
		---- Added manually added employess in FSDB_Facstaff_Basic to get fields updated from EDW
		---- STC 11/19/18 - get Manual from FSDB until we switch to using FSB in DM

		--SELECT  DISTINCT edw_pers_id
		----FROM dbo.FSDB_Facstaff_Basic
		--FROM Faculty_Staff_Holder.dbo.Facstaff_Basic
		--WHERE Bus_Person_Manual_Entry_Indicator=1 and Active_Indicator=1 and EDW_PERS_ID is not NULL

		UNION

		-- NS 5/23/2019
		-- Added manually employees in _DM_ADMIN that has to keep active
		-- STC 3/25/21 - Replace _DM_Admin with View to only get KEEP_ACTIVE from the most recent AC_YEAR record

		SELECT DISTINCT edwpersid
		FROM dbo.DM_Employee_Admin_View
		WHERE KEEP_ACTIVE = 'Yes'
		--FROM dbo._DM_ADMIN
		--WHERE AC_YEAR >= '2018-2019' AND KEEP_ACTIVE = 'Yes'





		--SELECT * FROM	##EMPS_step01 ORDER BY EDW_PERS_ID
		---=============================

		--KA: Check to see if there are any records copied into the temp table
		IF EXISTS(SELECT TOP 1 * FROM ##EMPS_step01)

		BEGIN
			--If records found then update status = 1, meaning the job had run but later failed.
			UPDATE	Database_Maintenance.dbo.Download_Process_Monitor_Logs
			SET		Status = 1
			WHERE	Table_Name = 'FSDB_EDW_Current_Employees 1'
				AND	Copy_Datetime = @jobdate
     

			--========================

			PRINT ' > Get employees complete information '
			-- Get all information of all college of business related employees
			INSERT INTO DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees (
			   EDW_PERS_ID
			  ,UIN
			  ,Network_ID
			  ,EDW_Database
			  ,PERS_PREFERRED_FNAME
			  ,PERS_FNAME
			  ,PERS_MNAME
			  ,PERS_LNAME
			  ,BIRTH_DT
			  ,SEX_CD			-- M or F
			  ,RACE_ETH_CD
			  --,RACE_ETH_DESC
			  --,PERS_CITZN_TYPE_DESC
			  ,EMPEE_CAMPUS_CD
			  ,EMPEE_CAMPUS_NAME
			  ,EMPEE_COLL_CD
			  ,EMPEE_COLL_NAME
			  ,EMPEE_DEPT_CD
			  ,EMPEE_DEPT_NAME
			  ,JOB_DETL_TITLE
			  ,JOB_DETL_FTE
			  ,JOB_CNTRCT_TYPE_DESC
			  ,JOB_DETL_DATA_STATUS_DESC
			  ,JOB_DETL_COLL_CD
			  ,JOB_DETL_COLL_NAME
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
			  --,CAMPUS_JOB_DETL_FTE
			  --,COLLEGE_JOB_DETL_FTE
			  --,Univ_Sum_FTE
			  --,Sum_FTE
			  --,FAC_RANK_CD
			  --,FAC_RANK_DESC
			  --,FAC_RANK_ACT_DT
			  --,FAC_RANK_DECN_DT
			  --,FAC_RANK_ACAD_TITLE
			  --,FAC_RANK_EMRTS_STATUS_IND
			  ,FIRST_HIRE_DT
			  ,CUR_HIRE_DT
			  ,FIRST_WORK_DT
			  ,LAST_WORK_DT
			  ,EMPEE_TERMN_DT

      
			  ,JOB_SUFFIX
			  ,POSN_NBR
	 
			  ,JOB_DETL_DEPT_CD
			  ,JOB_DETL_DEPT_NAME
			  ,JOB_DETL_EEO_SKILL_CD
			  ,JOB_DETL_EEO_SKILL_DESC
			  ,JOB_DETL_EFF_DT
			  ,POSN_EMPEE_CLS_CD
			  ,POSN_EMPEE_CLS_LONG_DESC
			  ,EMPEE_SUB_DEPT_LEVEL_6_CD
			  ,EMPEE_SUB_DEPT_LEVEL_6_NAME
			  ,EMPEE_SUB_DEPT_LEVEL_7_CD
			  ,EMPEE_SUB_DEPT_LEVEL_7_NAME
			  ,NATION_CD
       
			  ,New_Download_Indicator
			  ,DM_Upload_Done_Indicator
			  ,Create_Datetime
			)

			-- GET complete information of CURRENT employees 
			SELECT
			  DISTINCT
			  PH1.EDW_PERS_ID,
			  PH1.UIN,
			  Decision_Support_HR.dbo.DailyUpdate_fn_Get_NetID_From_EDW_PERS_ID(PH1.EDW_PERS_ID) as Network_id,
			  'HR',
			  ISNULL(PH1.PERS_PREFERRED_FNAME,'') as  PERS_PREFERRED_FNAME,
			  ISNULL(PH1.PERS_FNAME,'') as  PERS_FNAME, 
			  ISNULL(PH1.PERS_MNAME,'') as  PERS_MNAME, 
			  ISNULL(PH1.PERS_LNAME,'') as  PERS_LNAME, 

			  Decision_Support_HR.dbo.DailyUpdate_fn_Get_Birth_Date_By_EDW_PERS_ID(PH1.EDW_PERS_ID) as Birth_DT,
			  Decision_Support_HR.dbo.DailyUpdate_fn_Get_Gender_By_EDW_PERS_ID(PH1.EDW_PERS_ID) as Gender,
			  Decision_Support_HR.dbo.DailyUpdate_fn_Get_RaceEthnicity_By_EDW_PERS_ID(PH1.EDW_PERS_ID) as RACE_ETH_CD,
			  --Decision_Support_HR.dbo.DailyUpdate_fn_Get_Citizenship_Type_By_EDW_PERS_ID(PH1.EDW_PERS_ID) as PERS_CITZN_TYPE_DESC,
  
			  EMPEE_CAMPUS_CD,
			  EMPEE_CAMPUS_NAME,
			  EMPEE_COLL_CD,
			  EMPEE_COLL_NAME,
			  H1.EMPEE_DEPT_CD,			-- Primary department
			  H1.EMPEE_DEPT_NAME,
			  JDH1.JOB_DETL_TITLE,
			  JDH1.JOB_DETL_FTE,
			  JH.JOB_CNTRCT_TYPE_DESC,
			  JDH1.JOB_DETL_DATA_STATUS_DESC,
			  JDH1.JOB_DETL_COLL_CD,
			  JDH1.JOB_DETL_COLL_NAME,

			  H1.COA_CD,
			  H1.ORG_CD,
			  EMPEE_ORG_TITLE,

			  H1.EMPEE_CLS_CD,			-- Employee class
			  H1.EMPEE_CLS_LONG_DESC,
			  H1.EMPEE_GROUP_CD,		-- Employee group: A (faculty), B (AP), C(Civil Service), T(Retiree), G(Grad assistants)
			  H1.EMPEE_GROUP_DESC,
			  H1.EMPEE_RET_IND,

			  H1.EMPEE_LEAVE_CATGRY_CD,
			  H1.EMPEE_LEAVE_CATGRY_DESC,
			  H1.BNFT_CATGRY_CD,
			  H1.BNFT_CATGRY_DESC,
			  H1.HR_CAMPUS_CD,
			  H1.HR_CAMPUS_NAME,
			  H1.EMPEE_STATUS_CD,
			  H1.EMPEE_STATUS_DESC,

			  H1.FIRST_HIRE_DT,
			  H1.CUR_HIRE_DT,
			  H1.FIRST_WORK_DT,
			  H1.LAST_WORK_DT,
			  H1.EMPEE_TERMN_DT,

			  --Decision_Support_HR.dbo.Adhoc_sp_Get_Fac_Rank_CD_By_EDW_PERS_ID(PH1.EDW_PERS_ID, POSH.POSN_NBR) as FAC_RANK_CD,
			  --Decision_Support_HR.dbo.Adhoc_sp_Get_Fac_Rank_Desc_By_EDW_PERS_ID(PH1.EDW_PERS_ID, POSH.POSN_NBR) as FAC_RANK_DESC,
			  --Decision_Support_HR.dbo.Adhoc_sp_Get_FAC_RANK_ACT_DT_By_EDW_PERS_ID(PH1.EDW_PERS_ID, POSH.POSN_NBR) as FAC_RANK_ACT_DT,
			  --Decision_Support_HR.dbo.Adhoc_sp_Get_FAC_RANK_DECN_DT_By_EDW_PERS_ID(PH1.EDW_PERS_ID, POSH.POSN_NBR) as FAC_RANK_DECN_DT,
			  --Decision_Support_HR.dbo.Adhoc_sp_Get_FAC_RANK_DECN_DT_By_EDW_PERS_ID(PH1.EDW_PERS_ID, POSH.POSN_NBR) as FAC_RANK_DECN_DT,
			  --Decision_Support_HR.dbo.Adhoc_sp_Get_FAC_RANK_EMRTS_STATUS_IND_By_EDW_PERS_ID(PH1.EDW_PERS_ID, POSH.POSN_NBR) as FAC_RANK_EMRTS_STATUS_IND,
  
  
			  JH.JOB_SUFFIX,
			  POSH.POSN_NBR,
  
			  LEFT( JDH1.JOB_DETL_DEPT_CD,3),		-- Departments where the FTE is counted for, it may either be the primary or secondary department
			  JDH1.JOB_DETL_DEPT_NAME , 
 
			  JDH1.JOB_DETL_EEO_SKILL_CD,
			  JDH1.JOB_DETL_EEO_SKILL_DESC,
			  JDH1.JOB_DETL_EFF_DT,
   
 
			  POSH.POSN_EMPEE_CLS_CD, 
			  POSH.POSN_EMPEE_CLS_LONG_DESC,
			  H1.EMPEE_SUB_DEPT_LEVEL_6_CD,
			  H1.EMPEE_SUB_DEPT_LEVEL_6_NAME,
			  H1.EMPEE_SUB_DEPT_LEVEL_7_CD,
			  H1.EMPEE_SUB_DEPT_LEVEL_7_NAME,
			  Decision_Support_HR.dbo.DailyUpdate_fn_Get_Citizenship_Type_By_EDW_PERS_ID(PH1.EDW_PERS_ID) as NATION_CD,
 
			  1,
			  0,
			  getdate()

			FROM	 ##EMPS_step01 P
						inner join 
					Decision_Support_HR.dbo.EDW_V_EMPEE_PERS_HIST_1 PH1
						ON	P.EDW_PERS_ID = PH1.EDW_PERS_ID and 
							PH1.PERS_CUR_INFO_IND='Y'
						inner join 
					Decision_Support_HR.dbo.EDW_V_EMPEE_HIST_1 H1
						ON  H1.EDW_PERS_ID=P.EDW_PERS_ID and 
							H1.EMPEE_CUR_INFO_IND= 'Y' 
						inner join 
					Decision_Support_HR.dbo.EDW_T_JOB J
						inner join 
					Decision_Support_HR.dbo.EDW_T_JOB_HIST JH
						ON	J.EDW_PERS_ID=JH.EDW_PERS_ID  
							AND J.JOB_SUFFIX=JH.JOB_SUFFIX  
							AND J.POSN_NBR=JH.POSN_NBR 
							AND JH.JOB_CUR_INFO_IND='Y' -- -- NS 4/28/2017 added							-- STC different

					--inner join Decision_Support_HR.dbo.EDW_T_JOB_DETL JD

						inner join
					Decision_Support_HR.dbo.EDW_V_JOB_DETL_HIST_1 JDH1
						ON	JH.EDW_PERS_ID=JDH1.EDW_PERS_ID  
							AND JH.JOB_SUFFIX=JDH1.JOB_SUFFIX  
							AND JH.POSN_NBR=JDH1.POSN_NBR 
							AND JDH1.JOB_DETL_CUR_INFO_IND = 'Y'	
							AND JDH1.JOB_DETL_DATA_STATUS_DESC in  ('Current','Future')						-- STC different

							-- STC 11/16/18 cannot filter to only KM or BEL; this will exclude others w/o KM jobs such as Emily Zeigler (MSFE)
							--AND ((JH.PRIMARY_JOB_IND='Y' AND JDH1.JOB_DETL_COLL_CD  =  'KM')
							--	 OR (JH.PRIMARY_JOB_IND='N' AND JDH1.JOB_DETL_COLL_CD =  'KM' )
							--	 OR JDH1.job_detl_org_title = 'BEL')			-- NS 4/28/2017 added

								/*
								on JDH1.EDW_PERS_ID=JD.EDW_PERS_ID  and JDH1.JOB_SUFFIX=JD.JOB_SUFFIX and JDH1.POSN_NBR=JD.POSN_NBR 
												and JDH1.JOB_DETL_CUR_INFO_IND = 'Y'
												and JDH1.JOB_DETL_EFF_DT=JD.JOB_DETL_EFF_DT 
										ON JD.EDW_PERS_ID=J.EDW_PERS_ID and JD.JOB_SUFFIX=J.JOB_SUFFIX and JD.POSN_NBR=J.POSN_NBR 
								*/
						inner join Decision_Support_HR.dbo.EDW_T_POSN POS
						inner join 	Decision_Support_HR.dbo.EDW_T_POSN_HIST POSH
							on	POS.POSN_NBR=POSH.POSN_NBR 
							on	J.POSN_NBR=POS.POSN_NBR 
							on	P.EDW_PERS_ID = J.EDW_PERS_ID



			WHERE --  no need, we need to know the primary that is non KM too: JDH1.JOB_DETL_COLL_CD  =  'KM' AND
					POSH.POSN_DATA_STATUS_DESC  =  'Current'
					AND JH.JOB_DATA_STATUS_DESC  =  'Current'
					AND  H1.EMPEE_DATA_STATUS_DESC  =  'Current'
					AND  JDH1.JOB_DETL_STATUS_DESC  =  'Active'
					AND  JDH1.JOB_DETL_DATA_STATUS_DESC  =  'Current'

					-- 8/18 added
					--AND ((JH.PRIMARY_JOB_IND='Y' AND JDH1.JOB_DETL_COLL_CD  =  'KM')  
					--			 OR (JH.PRIMARY_JOB_IND='N' AND JDH1.JOB_DETL_COLL_CD =  'KM' ) 
					--			 OR JDH1.job_detl_org_title = 'BEL')			-- NS 4/28/2017 added
		

							-- no need, already screened AND  JDH1.JOB_DETL_DEPT_CD <> '405' -- Economics
							--no need, we also want predoc: AND  JDH1.JOB_DETL_TITLE  <>  'PREDOC FELLOW'
							--no need, why? AND JH.COA_CD  =  '9'

			UNION

			-- NS 8/6/2007 
			-- GET complete info of the FUTURE employees when there is no current JOB_DETL_DATA_STATUS_DESC in EDW_V_JOB_DETL_HIST_1 table

			SELECT
			  DISTINCT
			  PH1.EDW_PERS_ID,
			  PH1.UIN,
			  Decision_Support_HR.dbo.Adhoc_sp_Get_NetID_From_EDW_PERS_ID(PH1.EDW_PERS_ID) as Network_id,
			  'HR',
			  ISNULL(PH1.PERS_PREFERRED_FNAME,'') as  PERS_PREFERRED_FNAME,
			  ISNULL(PH1.PERS_FNAME,'') as  PERS_FNAME, 
			  ISNULL(PH1.PERS_MNAME,'') as  PERS_MNAME, 
			  ISNULL(PH1.PERS_LNAME,'') as  PERS_LNAME,

			  Decision_Support_HR.dbo.Adhoc_sp_Get_Birth_Date_By_EDW_PERS_ID(PH1.EDW_PERS_ID) as Birth_DT,
			  Decision_Support_HR.dbo.Adhoc_sp_Get_Gender_By_EDW_PERS_ID(PH1.EDW_PERS_ID) as Gender,
			  Decision_Support_HR.dbo.Adhoc_sp_Get_RaceEthnicity_By_EDW_PERS_ID(PH1.EDW_PERS_ID) as RACE_ETH_CD,

			  EMPEE_CAMPUS_CD,
			  EMPEE_CAMPUS_NAME,
			  EMPEE_COLL_CD,
			  EMPEE_COLL_NAME,
			  H1.EMPEE_DEPT_CD,			-- Primary department
			  H1.EMPEE_DEPT_NAME,
			  JDH1.JOB_DETL_TITLE,
			  JDH1.JOB_DETL_FTE,
			  JH.JOB_CNTRCT_TYPE_DESC,
			  JDH1.JOB_DETL_DATA_STATUS_DESC,
			  JDH1.JOB_DETL_COLL_CD,
			  JDH1.JOB_DETL_COLL_NAME,
			  H1.COA_CD,
			  H1.ORG_CD,
			  EMPEE_ORG_TITLE,

			  H1.EMPEE_CLS_CD,			-- Employee class
			  H1.EMPEE_CLS_LONG_DESC,
			  H1.EMPEE_GROUP_CD,		-- Employee group: A (faculty), B (AP), C(Civil Service), T(Retiree), G(Grad assistants)
			  H1.EMPEE_GROUP_DESC,
			  H1.EMPEE_RET_IND,

			  H1.EMPEE_LEAVE_CATGRY_CD,
			  H1.EMPEE_LEAVE_CATGRY_DESC,
			  H1.BNFT_CATGRY_CD,
			  H1.BNFT_CATGRY_DESC,
			  H1.HR_CAMPUS_CD,
			  H1.HR_CAMPUS_NAME,
			  H1.EMPEE_STATUS_CD,
			  H1.EMPEE_STATUS_DESC,

			  H1.FIRST_HIRE_DT,
			  H1.CUR_HIRE_DT,
			  H1.FIRST_WORK_DT,
			  H1.LAST_WORK_DT,
			  H1.EMPEE_TERMN_DT,

			  --Decision_Support_HR.dbo.Adhoc_sp_Get_Fac_Rank_CD_By_EDW_PERS_ID(PH1.EDW_PERS_ID, POSH.POSN_NBR) as FAC_RANK_CD,
			  --Decision_Support_HR.dbo.Adhoc_sp_Get_Fac_Rank_Desc_By_EDW_PERS_ID(PH1.EDW_PERS_ID, POSH.POSN_NBR) as FAC_RANK_DESC,
			  --Decision_Support_HR.dbo.Adhoc_sp_Get_FAC_RANK_ACT_DT_By_EDW_PERS_ID(PH1.EDW_PERS_ID, POSH.POSN_NBR) as FAC_RANK_ACT_DT,
			  --Decision_Support_HR.dbo.Adhoc_sp_Get_FAC_RANK_DECN_DT_By_EDW_PERS_ID(PH1.EDW_PERS_ID, POSH.POSN_NBR) as FAC_RANK_DECN_DT,
			  --Decision_Support_HR.dbo.Adhoc_sp_Get_FAC_RANK_DECN_DT_By_EDW_PERS_ID(PH1.EDW_PERS_ID, POSH.POSN_NBR) as FAC_RANK_DECN_DT,
			  --Decision_Support_HR.dbo.Adhoc_sp_Get_FAC_RANK_EMRTS_STATUS_IND_By_EDW_PERS_ID(PH1.EDW_PERS_ID, POSH.POSN_NBR) as FAC_RANK_EMRTS_STATUS_IND,
  
			  JH.JOB_SUFFIX,
			  POSH.POSN_NBR,
			  LEFT( JDH1.JOB_DETL_DEPT_CD,3),		-- Departments where the FTE is counted for, it may either be the primary or secondary department
			  JDH1.JOB_DETL_DEPT_NAME , 
 
			  JDH1.JOB_DETL_EEO_SKILL_CD,
			  JDH1.JOB_DETL_EEO_SKILL_DESC,
			  JDH1.JOB_DETL_EFF_DT,
   
 
			  POSH.POSN_EMPEE_CLS_CD, 
			  POSH.POSN_EMPEE_CLS_LONG_DESC,
			  H1.EMPEE_SUB_DEPT_LEVEL_6_CD,
			  H1.EMPEE_SUB_DEPT_LEVEL_6_NAME,
			  H1.EMPEE_SUB_DEPT_LEVEL_7_CD,
			  H1.EMPEE_SUB_DEPT_LEVEL_7_NAME,
			  Decision_Support_HR.dbo.DailyUpdate_fn_Get_Citizenship_Type_By_EDW_PERS_ID(PH1.EDW_PERS_ID) as NATION_CD,
 
			  1,
			  0,
			  getdate()

			FROM 	##EMPS_step01 P
						inner join 
					Decision_Support_HR.dbo.EDW_V_EMPEE_PERS_HIST_1 PH1
						ON	P.EDW_PERS_ID = PH1.EDW_PERS_ID and 
							PH1.PERS_CUR_INFO_IND='Y'
						inner join 
					Decision_Support_HR.dbo.EDW_V_EMPEE_HIST_1 H1
						ON  H1.EDW_PERS_ID=P.EDW_PERS_ID and 
							H1.EMPEE_CUR_INFO_IND= 'Y' 
						inner join 
					Decision_Support_HR.dbo.EDW_T_JOB J
						inner join 
					Decision_Support_HR.dbo.EDW_T_JOB_HIST JH
						ON	J.EDW_PERS_ID=JH.EDW_PERS_ID and 
							J.JOB_SUFFIX=JH.JOB_SUFFIX and 
							J.POSN_NBR=JH.POSN_NBR 

					--inner join Decision_Support_HR.dbo.EDW_T_JOB_DETL JD

						inner join 
					Decision_Support_HR.dbo.EDW_V_JOB_DETL_HIST_1 JDH1
						ON	JH.EDW_PERS_ID=JDH1.EDW_PERS_ID 
							AND JH.JOB_SUFFIX=JDH1.JOB_SUFFIX  
							AND JH.POSN_NBR=JDH1.POSN_NBR 
							AND JDH1.JOB_DETL_CUR_INFO_IND = 'Y'		
							AND JDH1.JOB_DETL_DATA_STATUS_DESC in  ('Current','Future')								-- STC different
					
								/*
								on JDH1.EDW_PERS_ID=JD.EDW_PERS_ID  and JDH1.JOB_SUFFIX=JD.JOB_SUFFIX and JDH1.POSN_NBR=JD.POSN_NBR 
												and JDH1.JOB_DETL_CUR_INFO_IND = 'Y'
												and JDH1.JOB_DETL_EFF_DT=JD.JOB_DETL_EFF_DT 
										ON JD.EDW_PERS_ID=J.EDW_PERS_ID and JD.JOB_SUFFIX=J.JOB_SUFFIX and JD.POSN_NBR=J.POSN_NBR 
								*/
						inner join 
					Decision_Support_HR.dbo.EDW_T_POSN POS
						inner join 
					Decision_Support_HR.dbo.EDW_T_POSN_HIST POSH
						on	POS.POSN_NBR=POSH.POSN_NBR 
						on	J.POSN_NBR=POS.POSN_NBR 
						on	P.EDW_PERS_ID = J.EDW_PERS_ID


			WHERE --  no need, we need to know the primary that is non KM too: JDH1.JOB_DETL_COLL_CD  =  'KM' AND
					POSH.POSN_DATA_STATUS_DESC  =  'Current'
					AND JH.JOB_DATA_STATUS_DESC  =  'Current'
					AND  H1.EMPEE_DATA_STATUS_DESC  =  'Current'
					AND  JDH1.JOB_DETL_STATUS_DESC  =  'Active'
					AND  JDH1.JOB_DETL_DATA_STATUS_DESC  = 'Future'
					AND JDH1.EDW_PERS_ID NOT IN
							(SELECT EDW_PERS_ID
							 FROM Decision_Support_HR.dbo.EDW_V_JOB_DETL_HIST_1
							 WHERE JOB_DETL_DATA_STATUS_DESC  =  'Current' AND
									JOB_DETL_STATUS_DESC  =  'Active'  AND
									JOB_DETL_DEPT_CD <> '405'  AND
									JOB_DETL_CUR_INFO_IND = 'Y'  AND
									JOB_DETL_COLL_CD  =  'KM' )
		

			ORDER BY   PH1.EDW_PERS_ID

			-- Lookup codes, and updates necessary columns
			UPDATE DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees 
			   SET RACE_ETH_DESC = Decision_Support.dbo.DailyUpdate_fn_Lookup_RaceEthnicity(RACE_ETH_CD)  
					,PERS_CITZN_TYPE_DESC = Decision_Support.dbo.DailyUpdate_fn_Lookup_CitizenType (NATION_CD)              
			   FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
			   WHERE  new_download_indicator = 1

			-- >>>>>> SET Rank and Tenure Track information
			-- STC Review Rank
			UPDATE DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees 
				SET  FAC_RANK_CD = F.FAC_RANK_CD
				  ,FAC_RANK_DESC = F.FAC_RANK_DESC
				  ,FAC_RANK_ACT_DT = F.FAC_RANK_ACT_DT
				  ,FAC_RANK_DECN_DT = F.FAC_RANK_DECN_DT
				  ,FAC_RANK_ACAD_TITLE = F.FAC_RANK_ACAD_TITLE
				  ,FAC_RANK_EMRTS_STATUS_IND = F.FAC_RANK_EMRTS_STATUS_IND		-- Y or N
				FROM Decision_Support_HR.dbo.EDW_T_FAC_RANK_HIST F
						INNER JOIN DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees C
						ON  C.New_Download_Indicator=1
								AND C.EDW_PERS_ID=F.EDW_PERS_ID
								AND C.POSN_NBR= F.POSN_NBR
								AND F.FAC_RANK_CUR_INFO_IND='Y'
				-- STC 2/28/18 - Make sure to only update using the most recent rank
				WHERE NOT EXISTS (
					SELECT *
					FROM Decision_Support_HR.dbo.EDW_T_FAC_RANK_HIST F2
					WHERE F2.EDW_PERS_ID = F.EDW_PERS_ID
							AND F2.FAC_RANK_CUR_INFO_IND='Y'
							AND F2.FAC_RANK_ACT_DT > F.FAC_RANK_ACT_DT
					)

			-- STC Review Tenure
			SELECT DISTINCT edw_pers_id, FAC_TENURE_DESC, FAC_TENURE_DECN_DESC
			INTO #Tenure_Track
			FROM [Decision_Support].[dbo].[EDW_T_FAC_TENURE_HIST]
			WHERE [FAC_TENURE_CUR_INFO_IND]='y' 
					AND FAC_TENURE_DSD = 'Current'
					AND FAC_TENURE_DECN_DESC in ('Approved','None')

			UPDATE DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees 
			SET TENURE_INDICATOR = NULL
			WHERE new_download_indicator = 1 

			UPDATE DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees 
			SET TENURE_INDICATOR = 1
			FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees  em
					INNER JOIN #Tenure_Track tt
					ON em.EDW_PERS_ID = tt.EDW_PERS_ID
							AND em.new_download_indicator = 1
							AND em.EDW_Database not in ('PRRDOC','RTADOC')    
			WHERE new_download_indicator = 1 AND EDW_Database not in ('PRRDOC','RTADOC')    



			-- >>>>> Update SUM_FTE for the college of business jobs, for PRIMARY and SECONDARY only; each record of employee will hold the sum
			PRINT ' > Update SUM_FTE for the college of business jobs at FSDB_EDW_Current_Employees table '

			-- Create unique job details for each Primary and Secondary
			SELECT distinct edw_pers_id,JOB_DETL_FTE, JOB_CNTRCT_TYPE_DESC, JOB_DETL_COLL_CD, JOB_DETL_DEPT_CD, POSN_NBR,JOB_DETL_DATA_STATUS_DESC 
			INTO #College_Unique_Job_Details
			FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees e2
			WHERE e2.new_download_indicator = 1
					AND e2.JOB_CNTRCT_TYPE_DESC in ('Primary','Secondary')
					AND e2.JOB_DETL_COLL_CD='KM'
					AND e2.EDW_Database not in ('PRRDOC','RTADOC')         

			-- Do summation on all college JOB_DETL_FTE
			UPDATE DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees 
			SET sum_fte = 
				   ( SELECT SUM(JOB_DETL_FTE)
					 FROM #College_Unique_Job_Details e2
					 WHERE DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees.edw_pers_id = e2.edw_pers_id)
			FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
			WHERE  new_download_indicator = 1 and EDW_Database not in ('PRRDOC','RTADOC')


			--NS 4/24/2019  Decommissioned, updated with a much better codes above
			--UPDATE DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees 
			--SET sum_fte = 
			--      (SELECT SUM(JOB_DETL_FTE)
			--         FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees e2
			--            WHERE DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees.edw_pers_id = e2.edw_pers_id 
			--		and e2.new_download_indicator = 1
			--		and e2.JOB_CNTRCT_TYPE_DESC in ('Primary','Secondary')
			--		and e2.JOB_DETL_COLL_CD='KM'
			--		and e2.EDW_Database not in ('PRRDOC','RTADOC'))          
			--FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
			--WHERE  new_download_indicator = 1 and EDW_Database not in ('PRRDOC','RTADOC')

			UPDATE DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees 
			   SET College_JOB_DETL_FTE = sum_fte * 100					-- in 0 to 100
			   WHERE  new_download_indicator = 1 and sum_fte is not NULL													-- STC different

			-- >>>>> Update SUM_FTE for the campus wide jobs, for PRIMARY and SECONDARY only; each record of employee will hold the sum
			PRINT ' > Update SUM_FTE for the campus wide jobs at FSDB_EDW_Current_Employees table '

			-- Create unique job details for each Primary and Secondary
			SELECT distinct edw_pers_id,JOB_DETL_FTE, JOB_CNTRCT_TYPE_DESC, JOB_DETL_COLL_CD, JOB_DETL_DEPT_CD, POSN_NBR,JOB_DETL_DATA_STATUS_DESC 
			INTO #Campus_Unique_Job_Details
			FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees e2
			WHERE e2.new_download_indicator = 1
					AND e2.JOB_CNTRCT_TYPE_DESC in ('Primary','Secondary')
					AND e2.EDW_Database not in ('PRRDOC','RTADOC')   

			UPDATE DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees 
			SET univ_sum_fte = 
				   ( SELECT SUM(JOB_DETL_FTE)
					 FROM #Campus_Unique_Job_Details e2
					 WHERE DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees.edw_pers_id = e2.edw_pers_id)
			FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
			WHERE  new_download_indicator = 1 and EDW_Database not in ('PRRDOC','RTADOC')

			--NS 4/24/2019  Decommissioned, updated with a much better codes above
			--UPDATE DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees 
			--   SET univ_sum_fte = 
			--      (SELECT SUM(JOB_DETL_FTE)
			--         FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees e2
			--            WHERE DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees.edw_pers_id = e2.edw_pers_id 
			--		and e2.new_download_indicator = 1
			--		and e2.JOB_CNTRCT_TYPE_DESC in ('Primary','Secondary'))
			--   FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
			--   WHERE  new_download_indicator = 1

			UPDATE DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees 
			   SET CAMPUS_JOB_DETL_FTE = univ_sum_fte * 100
			   WHERE  new_download_indicator = 1  and univ_sum_fte is not NULL												-- STC different



			--NS we will update Status=2 at the end of the steps 6 for now, but for production at step 9 or 10
			--UPDATE  Database_Maintenance.dbo.Download_Process_Monitor_Logs
			--SET		Status = 2
			--WHERE	Table_Name = 'FSDB_EDW_Current_Employees'
			--	AND	Copy_Datetime = @jobdate



			-- NS 11/6/2018 MAY NOT Need to remove duplicates in newly downloaded records on FSDB_EDW_Current_Employees table
			--		because  DailyUpdate_sp_DM_Step04_New_Employees_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees
			--		does getting distinct employees based on Primary jobs
			/*
			DECLARE @EDW_PERS_ID as bigint

			DECLARE dups CURSOR READ_ONLY FOR
				SELECT EDW_PERS_ID 
				FROM dbo.FSDB_EDW_Current_Employees
				WHERE new_download_indicator = 1 
					AND EMPEE_GROUP_CD in ('A','B','C','E','G','H','P','S','T','U')
				GROUP BY EDW_PERS_ID 
				HAVING COUNT(*) > 1

			OPEN dups
			FETCH dups INTO @EDW_PERS_ID
			WHILE @@FETCH_STATUS = 0
				BEGIN

					FETCH dups INTO @EDW_PERS_ID
				END

			CLOSE dups
			DEALLOCATE dups

			*/


			DROP TABLE ##EMPS_step01

			/*

			--Run on 8/4/2017
			select * from FSDB_EDW_Current_Employees where new_download_indicator=1   -- 1028
			select * from Faculty_Staff_Holder.dbo.EDW_Current_Employees where new_download_indicator=1 order by UIN  -- 1261

			select * from FSDB_EDW_Current_Employees where new_download_indicator=1 AND EDW_Database in ('PRRDOC','RTADOC')	order by UIN -- 77
			select * from Faculty_Staff_Holder.dbo.EDW_Current_Employees where new_download_indicator=1 AND EDW_Database in ('PRRDOC','RTADOC') order by UIN  -- 83



			--Run on 8/14/2017, 8/16/2017, 8/18/2017
			select * from FSDB_EDW_Current_Employees where new_download_indicator=1   -- 1127
			select * from Faculty_Staff_Holder.dbo.EDW_Current_Employees where new_download_indicator=1  -- 1132
			select distinct UIN from FSDB_EDW_Current_Employees where new_download_indicator=1   -- 808
			select distinct UIN from Faculty_Staff_Holder.dbo.EDW_Current_Employees where new_download_indicator=1  -- 808

			select * from FSDB_EDW_Current_Employees where new_download_indicator=1 AND EDW_Database in ('PRRDOC','RTADOC')		-- 77
			select * from Faculty_Staff_Holder.dbo.EDW_Current_Employees where new_download_indicator=1 AND EDW_Database in ('PRRDOC','RTADOC') -- 82
			select distinct UIN from FSDB_EDW_Current_Employees where new_download_indicator=1 AND EDW_Database in ('PRRDOC','RTADOC')	order by UIN -- 77
			select distinct UIN  from Faculty_Staff_Holder.dbo.EDW_Current_Employees where new_download_indicator=1 AND EDW_Database in ('PRRDOC','RTADOC') order by UIN  -- 77


			--find discrepancy on 8/14/2017, 8/16/2017, 8/18/2017
			select distinct edw_pers_id, uin, pers_fname, pers_mname, pers_lname, sex_cd, empee_coll_name, empee_coll_cd from Faculty_Staff_Holder.dbo.EDW_Current_Employees fsdb
			where new_download_indicator=1 
					and not exists (select * from FSDB_EDW_Current_Employees dm where new_download_indicator=1 and dm.uin=fsdb.uin)

			select * from Faculty_Staff_Holder.dbo.EDW_Current_Employees fsdb
			where new_download_indicator=1 
					and not exists (select * from FSDB_EDW_Current_Employees dm where new_download_indicator=1 and dm.uin=fsdb.uin)
			order by fsdb.uin asc


			*/

			UPDATE	Database_Maintenance.dbo.Download_Process_Monitor_Logs
			SET		Status = 2
			WHERE	Table_Name = 'FSDB_EDW_Current_Employees 1'
				AND	Copy_Datetime = @jobdate

			SET @email_subject =  @email_subject + ' - Success'
			SET @email_body = @header + 'Success<BR><BR>'
			EXEC dbo.DailyUpdate_sp_Send_Email @from,@to_admin,@reply_to,@email_subject, @email_body

		END
	ELSE
		BEGIN
			SET @email_subject =  @email_subject + ' - No emps to process'
			SET @email_body = @header + 'Success<BR><BR>'
			EXEC dbo.DailyUpdate_sp_Send_Email @from,@to_admin,@reply_to,@email_subject, @email_body
		END

	END TRY

	BEGIN CATCH
		BEGIN
			SET @email_subject =  @email_subject + ' - Error'
			SET @email_body = @header + ERROR_Message() + '<BR><BR>'
			EXEC dbo.DailyUpdate_sp_Send_Email @from,@to_admin,@reply_to,@email_subject, @email_body
		END
	END CATCH
GO
