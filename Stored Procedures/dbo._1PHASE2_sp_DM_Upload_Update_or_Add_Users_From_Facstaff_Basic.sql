SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 9/18.2018: Run to update DM's USERS
-- NS  4/2/2018 - work on Record_Status of _UPLOAD_DM_USERS:
--		seperate 'NEW' from 'CUR' (users that are in current DM) and 'NEW' (users that are not in current DM yet)
--		add new records of 'OUT' (users that are in current DM but in Upload DM)

-- STC 4/2/18 - updated to use AACSB criteria for enabled + full vs part-time,
--				use FSH.Courses_BUS table to filter instructors based on subject + enrollment
-- 3/28/2018: replaced table name from _1PHASE1_UPLOAD_DM_USERS _UPLOAD_DM_USERS,
--	_1PHASE1_DM_USERS to _DM_USERS
-- NS 3/20/2018: NS Revised #1, #2, and #3
-- NS 9/29/2017
-- NS 9/26/2017


CREATE  PROC [dbo].[_1PHASE2_sp_DM_Upload_Update_or_Add_Users_From_Facstaff_Basic]
AS

	-- FSDB site: 
	--		_DM_USERS is the table that holds USERS already in DM site
	--			This table should not be touched by this SP since it is updated by dbo.shadow_USERS SP
	--		_UPLOAD_DM_USERS is the table that holds  users to upload to DM site 
	--			This table must always be cleared at the beginning of this SP
	--
	-- DM site: We need to upload just these fields to DM
	--		SELECT  USERNAME,UIN, CAST(FACSTAFFID as varchar) as FACSTAFFID, CAST(EDWPERSID as varchar) as EDWPERSID 
	--			,DEP ,FIRST_NAME,MIDDLE_NAME,LAST_NAME,Record_Status
	--		FROM DM_Shadow_Staging.dbo._UPLOAD_DM_USERS	
	--	Exclude accounts in _DM_USERS with Service_Account_Indictaor=1	

	-- STC set @alluers = 1 to add users to _UPLOAD_DM_USERS regardless of existence in _DM_USERS
	DECLARE @allusers bit = 0
	SET @allusers = 1

	DECLARE @today datetime
	SET @today = getdate()

	TRUNCATE TABLE DM_Shadow_Staging.dbo._UPLOAD_DM_USERS

	-- NS 9/29/2017
	-- ALL Facstaff_Basic that have not made into DM because 
	--		1) admins set BUS_PERSON_INDICATOR = 0 instead of Active_Indicator = 0
	--		2) PHD students or graduated PHD
	--	419 records

	-- NS 3/20/2018: restructure the data pull
	-- 1) All Employees with 
	--			EMPEE_GROUP_CD in ('A','B','C','E','G','H','P','S','T','U')
	--			AND EMPEE_CLS_CD NOT IN ('GA','SA', 'HG')
	-- 2) Doctoral students
	-- 3) COB Emps that are in EDW_T_FAC_INSTRN_ASSIGN  tables

	-- STC 4/2/18: restructure the data pull
	-- 1) All Employees with 
	--			EMPEE_GROUP_CD in ('A','B','C','E','P','T','U')
	--			OR EMPEE_CLS_CD IN ('HA')
	-- 2) Doctoral students
	-- 3) COB instructors of record for courses with enrollment


	-- 1) Add all BUS employees from groups A, B, C, E, P, T, U + class HA
	--    Enable current employees except for HA
	--	  Set to part-time by default, will update full-time employees later
	--	  Do not need to include groups G, S, other H

	-->>>>>>>>>>>>> SET Record_Status = 'ALL'
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
		  ,Record_Source
		  ,Record_FTPT
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
		  ,CASE WHEN EMPEE_CLS_CD = 'HA' THEN 0 ELSE active_Indicator END
		  ,'NEW'
		  ,'EMP'
		  ,'PT'
		  ,@today
	FROM  Faculty_Staff_Holder.dbo.facstaff_Basic
	WHERE (EMPEE_GROUP_CD in ('A','B','C','E','P','T','U')
				OR EMPEE_CLS_CD IN ('HA'))
			--AND BUS_Person_Indicator=1		-- see notes on 9/26/2017 
			AND EDW_PERS_ID IS NOT NULL
			AND Network_ID is not NULL
			AND Network_ID <> ''
			AND (@allusers = 1 
					or Network_ID NOT IN ( SELECT USERNAME FROM dbo._DM_USERS )
					)	

	-- 2) Add all current + former doctoral students not already in DM_USERS
	--	  Add all disabled, will enable and set current doctorals to full-time later
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
		  ,Record_Source
		  ,Record_FTPT
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
		  ,0
		  ,'NEW'		
		  ,'DOC'
		  ,''
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
				( SELECT USERNAME FROM dbo._UPLOAD_DM_USERS )	
			AND (@allusers = 1 
				or Network_ID NOT IN ( SELECT USERNAME FROM dbo._DM_USERS )
				)	

	-- 3) Add employees not already in DM_Users that have taught BUS courses since Fall 2013
	--	  Current employees are enabled as part-time
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
		  ,Record_Source
		  ,Record_FTPT
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
		  ,'INS'
		  ,'PT'
		  ,@today
		  --,Create_Datetime
		  --,Doctoral_Award_Term_CD
		  --,Doctoral_Award_Term_CD
		  --,Doctoral_Flag
	FROM  Faculty_Staff_Holder.dbo.facstaff_Basic
	WHERE Facstaff_ID IN (
				SELECT Facstaff_ID
				FROM Faculty_Staff_Holder.dbo.Courses_BUS
				WHERE CRS_SUBJ_CD IN ('ACCY', 'BADM', 'BUS', 'FIN', 'MBA', 'TMGT')
					AND TERM_CD >= '120138'
				)
			AND Network_ID is not NULL
			AND Network_ID <> ''
			AND Network_ID NOT IN
				( SELECT USERNAME FROM dbo._UPLOAD_DM_USERS )	
			AND (@allusers = 1 
				or Network_ID NOT IN ( SELECT USERNAME FROM dbo._DM_USERS )
				)	

	-->>>>>>>>>>>>> modify Record_Status and add more records
	--			1) seperate 'NEW' from 'CUR' (users that are in current DM) and 'NEW' (users that are not in current DM yet)
	--			2) add new records of 'OUT' (users that are in current DM but in Upload DM)
	--				Those who are in current DM but part of Record_Status='ALL' defined above

	-->>>>>>>>	1) seperate 'NEW' from 'CUR' (users that are in current DM) and 'NEW' (users that are not in current DM yet)

	UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_USERS
	SET Record_Status ='CUR'
	WHERE USERNAME IN
		(SELECT USERNAME FROM dbo._DM_USERS WHERE Service_Account_Indicator = 0)

	-->>>>>>>>  2) Add new records of 'OUT' (users that are in current DM but in Upload DM)
	--			   Those who are in current DM but part of Record_Status='ALL' defined above 

	INSERT INTO DM_Shadow_Staging.dbo._UPLOAD_DM_USERS
	(
 		   username
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
		  ,Record_Source
		  ,Record_FTPT
		  ,Update_Datetime
	)
	SELECT username
		  ,FacstaffID
		  ,EDWPERSID
		  ,UIN
		  ,First_Name
		  ,Middle_Name
		  ,Last_Name
		  ,DEP
		  ,Email_Address
		  ,0
		  ,'OUT'
		  ,'DM'
		  ,''
		  ,@today
	FROM DM_Shadow_Staging.dbo._DM_USERS
	WHERE Service_Account_Indicator = 0
			AND USERNAME NOT IN
				(SELECT USERNAME FROM DM_Shadow_Staging.dbo._UPLOAD_DM_USERS)




	-- Set employees other than Retiree/Unpaid to Full-Time if FTE >= 100
	-- (need > to include a few employees who have FTE 200 for some reason)
	UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_USERS
	SET Record_FTPT = 'FT'
	WHERE Record_Source = 'EMP' 
		AND FacstaffID IN (
			SELECT Facstaff_ID
			FROM Faculty_Staff_Holder.dbo.Facstaff_Basic
			WHERE Appointment_Percent >= 100
				AND Active_Indicator = 1
				AND EMPEE_GROUP_CD NOT IN ('T', 'U')
			)

	-- All current doctorals (including employees) should be enabled + full-time
	-- (Doctorals could also be considered part-time, so we may revisit this in
	-- the future if we approach the DM user limit.)
	UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_USERS
	SET Record_FTPT = 'FT', Enabled_Indicator = 1
	WHERE FacstaffID IN (
		SELECT Facstaff_ID
		FROM Faculty_Staff_Holder.dbo.Facstaff_Basic
		WHERE Doctoral_Flag = 1
			AND Active_Indicator = 1
		)

--	/*
	--SELECT Record_Source, Enabled_Indicator, Active_Indicator, Record_FTPT, empee_group_cd, Doctoral_Flag, COUNT(*)
	--from DM_Shadow_Staging.dbo._UPLOAD_DM_USERS dm
	--inner join Faculty_Staff_Holder.dbo.Facstaff_Basic fsb
	--	on dm.FacstaffID = fsb.Facstaff_ID
	--Group By Record_Source, Enabled_Indicator, Active_Indicator, Record_FTPT, empee_group_cd, Doctoral_Flag
	--Order By Record_Source, Enabled_Indicator DESC, Active_Indicator DESC, Record_FTPT DESC, empee_group_cd, Doctoral_Flag

	SELECT Record_Source, Enabled_Indicator, Record_FTPT, COUNT(*)
	from DM_Shadow_Staging.dbo._UPLOAD_DM_USERS dm
	inner join Faculty_Staff_Holder.dbo.Facstaff_Basic fsb
		on dm.FacstaffID = fsb.Facstaff_ID
	Group By Record_Source, Enabled_Indicator, Record_FTPT
	Order By Record_Source, Enabled_Indicator DESC, Record_FTPT DESC

	select COUNT(*)
	from DM_Shadow_Staging.dbo._UPLOAD_DM_USERS

	select COUNT(*)
	from DM_Shadow_Staging.dbo._UPLOAD_DM_USERS
	where Enabled_Indicator = 1

	select COUNT(*)
	from DM_Shadow_Staging.dbo._UPLOAD_DM_USERS
	where Enabled_Indicator = 1
		AND Record_FTPT = 'FT'
--	*/

	/* Counts 4/2/18

	EMP = 321 enabled FT, 130 enabled PT, 1066 disabled	
	DOC = 72 enabled FT, 290 disabled
	INS = 17 enabled PT, 59 disabled

	All users = 1955

	All enabled = 540
	All disabled = 1415

	All full-time = 393
	
	Countable users for DM contract = 393 + 147/3 = 442
	*/

	/*
	
		Manual run
		
		EXEC dbo.[produce_XML_USERS_add_update] @submit = 1 

		EXEC dbo.DailyUpdate_sp_DM_Step10_Run_DTSX

		EXEC dbo.DailyUpdate_sp_DM_Step11_Report_DTSX_Errors

		*/
GO
