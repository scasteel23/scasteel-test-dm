SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- 3/28/2018: replaced table name from _1PHASE1_UPLOAD_DM_USERS to _UPLOAD_DM_USERS,
--	_1PHASE1_DM_USERS to _DM_USERS
-- NS 3/20/2018: NS Revised #1, #2, and #3
-- NS 9/29/2017
-- NS 9/26/2017
CREATE PROC [dbo].[Adhoc_sp__Transition_01Add_DM_With_New_Users_From_Facstaff_Basic_old]

 AS
	-- FSDB site: 
	--		_DM_USERS is the table that holds USERS already in DM site
	--			This table should not be touched by this SP since it is updated by dbo.shadow_USERS SP
	--		_UPLOAD_DM_USERS is the table that holds new users to upload to DM site 
	--			This table must always be cleared at the beginning of this SP
	--
	-- DM site: We need to upload just these fields to DM
	--		SELECT  USERNAME,UIN, CAST(FACSTAFFID as varchar) as FACSTAFFID, CAST(EDWPERSID as varchar) as EDWPERSID 
	--			,DEP ,FIRST_NAME,MIDDLE_NAME,LAST_NAME,Record_Status
	--		FROM DM_Shadow_Staging.dbo._UPLOAD_DM_USERS		

	DECLARE @today datetime
	SET @today = getdate()

	TRUNCATE TABLE DM_Shadow_Staging.dbo._UPLOAD_DM_USERS

	/*
	-- NS 9/26/2017
	-- ALL Facstaff_Basic that have not made into DM because they were not part of tested accounts
	-- 1260+ records

	INSERT INTO DM_Shadow_Staging.dbo._UPLOAD_DM_USERS(
		   username
		  --,userid
		  ,FacstaffID
		  ,EDWPERSID
		  ,UIN
		  ,First_Name
		  ,Middle_Name
		  ,Last_Name
		  ,DEP
		  ,Email_Address
		  ,Enabled_Indicator
		  ,Record_Status
		  ,Update_Datetime)
		SELECT   Network_ID
		  --,userid
		  ,Facstaff_ID
		  ,EDW_PERS_ID
		  ,UIN
		  ,First_name
		  ,Middle_Name
		  ,Last_Name
		  ,Faculty_Staff_Holder.dbo.__DM_fn_Get_Department(Department_ID) as DEP

		  --,dbo.DailyUpdate_fn_Get_DM_Department_Name_By_Banner_Dept_CD(EMPEE_DEPT_CD) as DEP
		  ,Network_ID + '@illinois.edu'
		  ,active_Indicator
		  ,'NEW'
		  ,getdate()
		FROM  Faculty_Staff_Holder.dbo.facstaff_Basic
		-- STC 3/28 - remove all students (G, S), only add HA from group H
		--WHERE 	EMPEE_GROUP_CD in ('A','B','C','E','G','H','P','S','T','U')
		--			AND EMPEE_CLS_CD NOT IN ('GA','SA', 'HG')
		WHERE (EMPEE_GROUP_CD in ('A','B','C','E','P','T','U')
					OR EMPEE_CLS_CD IN ('HA'))
				AND BUS_Person_Indicator=1
				AND Network_ID NOT IN
					(
						SELECT USERNAME FROM _DM_USERS
					)
			
		ORDER BY Network_ID asc

		*/

	-- NS 9/29/2017
	-- ALL Facstaff_Basic that have not made into DM because 
	--		1) admins set BUS_PERSON_INDICATOR = 0 instead of Active_Indicator = 0
	--		2) PHD students or graduated PHD
	--	419 records

	-- NS 3/20/2018: restructure the data pull
	-- 1) All Employees with 
	--			EMPEE_GROUP_CD in ('A','B','C','E','P','T','U')
	--			OR EMPEE_CLS_CD IN ('HA')
	-- 2) Doctoral students
	-- 3) COB Emps that are in BUS_EDW_T_FAC_INSTRN_ASSIGN table

	-- >>>>>>>> 1) All Employees with 
	--			   EMPEE_GROUP_CD in ('A','B','C','E','G','H','P','S','T','U')
	--			   AND EMPEE_CLS_CD NOT IN ('GA','SA', 'HG')
	INSERT INTO DM_Shadow_Staging.dbo._UPLOAD_DM_USERS(
		   username
		  --,userid
		  ,FacstaffID
		  ,EDWPERSID
		  ,UIN
		  ,First_Name
		  ,Middle_Name
		  ,Last_Name
		  ,DEP
		  ,Email_Address
		  --,Enabled_Indicator
		  ,Record_Status
		 
		  ,Update_Datetime)
	SELECT   Network_ID
		  --,userid
		  ,Facstaff_ID
		  ,EDW_PERS_ID
		  ,UIN
		  ,First_name
		  ,Middle_Name
		  ,Last_Name
		  ,Faculty_Staff_Holder.dbo.__DM_fn_Get_Department(Department_ID) as DEP

		  --,dbo.DailyUpdate_fn_Get_DM_Department_Name_By_Banner_Dept_CD(EMPEE_DEPT_CD) as DEP
		  ,Network_ID + '@illinois.edu'
		  --,0 -- set active_Indicator=0 to all
		  ,'NEW'
		  ,@today
	FROM  Faculty_Staff_Holder.dbo.facstaff_Basic
	-- STC 3/28 - remove all students (G, S), only add HA from group H
	--WHERE 	EMPEE_GROUP_CD in ('A','B','C','E','G','H','P','S','T','U')
	--			AND EMPEE_CLS_CD NOT IN ('GA','SA', 'HG')
	WHERE (EMPEE_GROUP_CD in ('A','B','C','E','P','T','U')
				OR EMPEE_CLS_CD IN ('HA'))
				--AND Active_Indicator=1
				--AND BUS_Person_Indicator=1		-- see notes on 9/26/2017 
				AND EDW_PERS_ID IS NOT NULL
				AND Network_ID is not NULL
				AND Network_ID <> ''
				AND Network_ID NOT IN
					(
						SELECT USERNAME FROM dbo._DM_USERS
					)	
	
	UNION
	
	-- >>>>>>>>> -- 2) Doctoral students
	SELECT   Network_ID
		  --,userid
		  ,Facstaff_ID
		  ,EDW_PERS_ID
		  ,UIN
		  ,First_name
		  ,Middle_Name
		  ,Last_Name
		  ,Faculty_Staff_Holder.dbo.__DM_fn_Get_Department(Department_ID) as DEP

		  --,dbo.DailyUpdate_fn_Get_DM_Department_Name_By_Banner_Dept_CD(EMPEE_DEPT_CD) as DEP
		  ,Network_ID + '@illinois.edu'
		  --,active_Indicator
		  ,'NEW'		
		  ,@today
		  --,Create_Datetime
		  --,Doctoral_Award_Term_CD
		  --,Doctoral_Award_Term_CD
		  --,Doctoral_Flag
	FROM  Faculty_Staff_Holder.dbo.facstaff_Basic
	WHERE 	(Doctoral_Flag=1 OR Doctoral_Award_Term_CD is not null OR Doctoral_Department_ID is not null)
				--AND BUS_Person_Indicator=1		-- see notes on 9/26/2017 
				AND EDW_PERS_ID IS NOT NULL
				AND Network_ID is not NULL
				AND Network_ID <> ''
				AND Network_ID NOT IN
					(
						SELECT USERNAME FROM dbo._DM_USERS
					)	
							
	UNION

	-- 3) COB Emps that are in EDW_T_FAC_INSTRN_ASSIGN and EDW_T_FAC_SECT_INSTRN_ASSIGN tables
	SELECT   Network_ID
		  --,userid
		  ,Facstaff_ID
		  ,EDW_PERS_ID
		  ,UIN
		  ,First_name
		  ,Middle_Name
		  ,Last_Name
		  ,Faculty_Staff_Holder.dbo.__DM_fn_Get_Department(Department_ID) as DEP

		  --,dbo.DailyUpdate_fn_Get_DM_Department_Name_By_Banner_Dept_CD(EMPEE_DEPT_CD) as DEP
		  ,Network_ID + '@illinois.edu'
		  --,active_Indicator
		  ,'NEW'	
		  ,@today
		  --,Create_Datetime
		  --,Doctoral_Award_Term_CD
		  --,Doctoral_Award_Term_CD
		  --,Doctoral_Flag
	FROM  Faculty_Staff_Holder.dbo.facstaff_Basic
	-- STC 3/28 - Use Courses_BUS to limit by enrollment + subject
	--WHERE EDW_PERS_ID IN (SELECT EDW_PERS_ID
	--			  FROM Decision_Support.dbo.EDW_T_FAC_INSTRN_ASSIGN fi
	--			  WHERE fi.TERM_CD >= '120138' AND EDW_PERS_ID IS NOT NULL)
	WHERE Facstaff_ID IN (
				SELECT Facstaff_ID
				FROM Faculty_Staff_Holder.dbo.Courses_BUS
				WHERE CRS_SUBJ_CD IN ('ACCY', 'BADM', 'BUS', 'FIN', 'MBA', 'TMGT')
					AND TERM_CD >= '120138'
				)
			AND Network_ID is not NULL
			AND Network_ID <> ''
			AND Network_ID NOT IN
				(
					SELECT USERNAME FROM dbo._DM_USERS
				)	
				
	ORDER BY Network_ID asc

	UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_USERS
	SET Enabled_Indicator = 1

	UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_USERS
	SET Enabled_Indicator = 0
	WHERE  EDWPERSID IN (SELECT EDW_PERS_ID FROM  Faculty_Staff_Holder.dbo.facstaff_Basic
							WHERE (Active_Indicator = 0 OR BUS_Person_Indicator = 0)
									AND EDW_PERS_ID IS NOT NULL )

	UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_USERS
	SET RECORD_SOURCE = 'PRI', Record_FTPT = 'FT'
	WHERE  EDWPERSID IN (SELECT EDW_PERS_ID FROM  Faculty_Staff_Holder.dbo.facstaff_Basic
							WHERE 	EMPEE_GROUP_CD in ('A','B','C','E','G','H','P','S','T','U')
										AND EMPEE_CLS_CD NOT IN ('GA','SA', 'HG') 
										AND EDW_PERS_ID IS NOT NULL )

	UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_USERS
	SET RECORD_SOURCE = 'DOC', Record_FTPT = 'PT'
	WHERE  RECORD_SOURCE IS NULL
		AND EDWPERSID IN (SELECT EDW_PERS_ID FROM  Faculty_Staff_Holder.dbo.facstaff_Basic
							WHERE 	(Doctoral_Flag=1 OR Doctoral_Award_Term_CD is not null OR Doctoral_Department_ID is not null)
								 	 AND EDW_PERS_ID IS NOT NULL)

	UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_USERS
	SET RECORD_SOURCE = 'INS', Record_FTPT = 'PT'
	WHERE RECORD_SOURCE IS NULL
		AND EDWPERSID IN (SELECT EDW_PERS_ID FROM  Decision_Support.dbo.EDW_T_FAC_INSTRN_ASSIGN fi
				  WHERE fi.TERM_CD >= '120138' AND EDW_PERS_ID IS NOT NULL)

	UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_USERS
	SET Record_FTPT = 'PT'
	WHERE Record_FTPT IS NULL
		AND EDWPERSID IN (SELECT EDW_PERS_ID FROM  Faculty_Staff_Holder.dbo.facstaff_Basic
				  WHERE EMPEE_CLS_CD IN ('GA','SA', 'HG') AND EDW_PERS_ID IS NOT NULL)

	/*
		-- All PRI group = 605
		SELECT * FROM DM_Shadow_Staging.dbo._UPLOAD_DM_USERS WHERE Record_Source = 'PRI'

		-- All active = 605
		SELECT * FROM DM_Shadow_Staging.dbo._UPLOAD_DM_USERS WHERE Enabled_Indicator = 1

		-- Checks
		SELECT * FROM DM_Shadow_Staging.dbo._UPLOAD_DM_USERS WHERE Enabled_Indicator = 1 AND Record_FTPT IS NULL

		-- All from courses
		SELECT * FROM DM_Shadow_Staging.dbo._UPLOAD_DM_USERS WHERE Record_Source='INS'

		-- All active from courses = 32
		SELECT * FROM DM_Shadow_Staging.dbo._UPLOAD_DM_USERS WHERE Record_Source='INS' and Enabled_Indicator = 1

		-- All users=2068, All inacrtive users=1463, all active users=605, all active full-time=501, all active part-time=104
		SELECT COUNT(*) as all_users FROM DM_Shadow_Staging.dbo._UPLOAD_DM_USERS 
		SELECT COUNT(*) as all_active_users FROM DM_Shadow_Staging.dbo._UPLOAD_DM_USERS WHERE Enabled_Indicator = 1
		SELECT COUNT(*) as all_active_ft_users FROM DM_Shadow_Staging.dbo._UPLOAD_DM_USERS WHERE Enabled_Indicator = 1 AND Record_FTPT='fT'
		SELECT COUNT(*) as all_active_pt_users FROM DM_Shadow_Staging.dbo._UPLOAD_DM_USERS WHERE Enabled_Indicator = 1 AND Record_FTPT='PT'
		SELECT COUNT(*) as all_inactive_users FROM DM_Shadow_Staging.dbo._UPLOAD_DM_USERS WHERE Enabled_Indicator = 0
	*/
	--EXEC dbo.[produce_XML_USERS_add_update] @submit = 1 

	--EXEC dbo.DailyUpdate_sp_DM_Step10_Run_DTSX

	--EXEC dbo.DailyUpdate_sp_DM_Step11_Report_DTSX_Errors
GO
