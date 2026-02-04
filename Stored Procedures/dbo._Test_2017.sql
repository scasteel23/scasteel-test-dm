SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


/****** Script for SelectTopNRows command from SSMS  ******/

-- NS 3/15/2017
-- NS 3/14/2017  
CREATE PROC [dbo].[_Test_2017]

AS

	-- Purposes of this SP
	-- A) 3/7/2017  To test new user(s) creation
	-- B) 3/14/2017 To test shadowing DM screen into FSDB
	-- C) 3/20/2017 To create Publications from all civitas academica past and present in FSDB

		

	/*
		=============================
		B) To shadow DM screen into FSDB

			(1) Run [webservices_initiate] to registrer screens to download
				For example EXEC dbo.webservices_initiate @screen='PRESENT' --> register an individual screen to dwonload
				EXEC dbo.webservices_initiate --> register all available screens
			(2) OLD: Run DMFEED : SSIS FSDB_Downloads_Parallel.dtsx module
			    NEW: EXEC DM_Shadow_Staging.dbo.DailyUpdate_sp_DM_Step10_Run_DTSX
	*/

	/*

	Procedure (1) can be done by runnin the following SP
		EXEC dbo.webservices_initiate @screen='FACDEV'	
	Alternative for Procedure (1) is to reset  ID of the corresponding screen in webservices_requests tableas follow
	
		SELECT * FROM [DM_Shadow_Staging].[dbo].[webservices_requests] ORDER BY created desc

		UPDATE [DM_Shadow_Staging].[dbo].[webservices_requests]
		SET  [responseCode] = NULL
			  ,[response] = NULL
			  ,[process] = NULL
			  ,[initiated] = NULL
			  ,[completed] = NULL
			  ,[processed] = NULL
			  ,dependsOn = null
		WHERE ID in (26325,26324,26323)

		EXEC DM_Shadow_Staging.dbo.DailyUpdate_sp_DM_Step10_Run_DTSX

		1642 - 1665 /login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:xxx/SCHTEACH
		1581 POST	/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:scasteel/PCI
		1563 POST	/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:dsomaya/PCI
		1561 POST	/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:dhkwon/PCI
		1560 POST	/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:cxchen/PCI
				
		1487: /login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/RESPROG
		 486: /login/service/v4/User/INDIVIDUAL-ACTIVITIES-Business (USERS)
		 485: /login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/INNOVATION
		1486: /login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/INTELLCONT
		 483: /login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/CONGRANT
		 481: /login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/PRESENT
		 474: /login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/AWARDHONOR
		 472: /login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/PCI
		 106: /login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/SERVICE_COMMITTEE
		 107: /login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/SERVICE_ACADEMIC
		 108: /login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/SERVICE_PROFESSIONAL
		  96: /login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/EDUCATION
		  97: /login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/FACDEV
		  98: /login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/MEMBER
		  99: /login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/LICCERT
	 */


	-- 3/14/2017 1:20 PM
	--TRUNCATE TABLE [DM_Shadow_Staging].[dbo].[_DM_SERVICE_ACADEMIC]
	--TRUNCATE TABLE [DM_Shadow_Production].[dbo].[_DM_SERVICE_ACADEMIC]
	SELECT * FROM [DM_Shadow_Staging].[dbo].[_DM_SERVICE_ACADEMIC]
	SELECT * FROM [DM_Shadow_Production].[dbo].[_DM_SERVICE_ACADEMIC]
	EXEC dbo.webservices_initiate @screen='SERVICE_ACADEMIC'	
	--RUN	 DMFeed: SSIS FSDB_Downloads_Parallel.dtsx module

	-- 3/14/2017 1:27 PM
	--TRUNCATE TABLE [DM_Shadow_Staging].[dbo].[_DM_SERVICE_COMMITTEE]
	--TRUNCATE TABLE [DM_Shadow_Production].[dbo].[_DM_SERVICE_COMMITTEE]
	SELECT * FROM [DM_Shadow_Staging].[dbo].[_DM_SERVICE_COMMITTEE]
	SELECT * FROM [DM_Shadow_Production].[dbo].[_DM_SERVICE_COMMITTEE]
	EXEC dbo.webservices_initiate @screen='SERVICE_COMMITTEE'	
	--RUN	 DMFeed: SSIS FSDB_Downloads_Parallel.dtsx module

	-- 3/14/2017 1:34 PM
	--TRUNCATE TABLE [DM_Shadow_Staging].[dbo].[_DM_SERVICE_PROFESSIONAL]
	--TRUNCATE TABLE [DM_Shadow_Production].[dbo].[_DM_SERVICE_PROFESSIONAL]
	SELECT * FROM [DM_Shadow_Staging].[dbo].[_DM_SERVICE_PROFESSIONAL]
	SELECT * FROM [DM_Shadow_Production].[dbo].[_DM_SERVICE_PROFESSIONAL]
	EXEC dbo.webservices_initiate @screen='SERVICE_PROFESSIONAL'	
	--RUN	 DMFeed: SSIS FSDB_Downloads_Parallel.dtsx module
	
	-- 3/14/2017 2:08 PM
	--TRUNCATE TABLE [DM_Shadow_Staging].[dbo].[_DM_LICCERT]
	--TRUNCATE TABLE [DM_Shadow_Production].[dbo].[_DM_LICCERT]
	SELECT * FROM [DM_Shadow_Staging].[dbo].[_DM_LICCERT]
	SELECT * FROM [DM_Shadow_Production].[dbo].[_DM_LICCERT]
	EXEC dbo.webservices_initiate @screen='LICCERT'	
	--RUN	 DMFeed: SSIS FSDB_Downloads_Parallel.dtsx module

	-- 3/14/2017 2:08 PM
	--TRUNCATE TABLE [DM_Shadow_Staging].[dbo].[_DM_FACDEV]
	--TRUNCATE TABLE [DM_Shadow_Production].[dbo].[_DM_FACDEV]
	SELECT * FROM [DM_Shadow_Staging].[dbo].[_DM_FACDEV]
	SELECT * FROM [DM_Shadow_Production].[dbo].[_DM_FACDEV]
	EXEC dbo.webservices_initiate @screen='FACDEV'	
	--RUN	 DMFeed: SSIS FSDB_Downloads_Parallel.dtsx module

	-- 3/14/2017 2:08 PM
	--TRUNCATE TABLE [DM_Shadow_Staging].[dbo].[_DM_MEMBER]
	--TRUNCATE TABLE [DM_Shadow_Production].[dbo].[_DM_MEMBER]
	SELECT * FROM [DM_Shadow_Staging].[dbo].[_DM_MEMBER]
	SELECT * FROM [DM_Shadow_Production].[dbo].[_DM_MEMBER]
	EXEC dbo.webservices_initiate @screen='MEMBER'	
	--RUN	 DMFeed: SSIS FSDB_Downloads_Parallel.dtsx module

	-- 3/14/2017 2:08 PM
	--TRUNCATE TABLE [DM_Shadow_Staging].[dbo].[_DM_EDUCATION]
	--TRUNCATE TABLE [DM_Shadow_Production].[dbo].[_DM_EDUCATION]
	SELECT * FROM [DM_Shadow_Staging].[dbo].[_DM_EDUCATION]
	SELECT * FROM [DM_Shadow_Production].[dbo].[_DM_EDUCATION]
	EXEC dbo.webservices_initiate @screen='EDUCATION'	
	--RUN	 DMFeed: SSIS FSDB_Downloads_Parallel.dtsx module

	-- 3/14/2017 2:10 PM
	--TRUNCATE TABLE [DM_Shadow_Staging].[dbo].[_DM_INNOVATIONS]
	--TRUNCATE TABLE [DM_Shadow_Production].[dbo].[_DM_INNOVATIONS]
	SELECT * FROM [DM_Shadow_Staging].[dbo].[_DM_INNOVATIONS]
	SELECT * FROM [DM_Shadow_Production].[dbo].[_DM_INNOVATIONS]
	EXEC dbo.webservices_initiate @screen='INNOVATIONS'	
	--RUN	 DMFeed: SSIS FSDB_Downloads_Parallel.dtsx module

	-- 3/14/2017 6:30 PM
	--TRUNCATE TABLE [DM_Shadow_Staging].[dbo].[_DM_USERS]
	--TRUNCATE TABLE [DM_Shadow_Production].[dbo].[_DM_USERS]
	SELECT * FROM [DM_Shadow_Staging].[dbo].[_DM_USERS]
	SELECT * FROM [DM_Shadow_Production].[dbo].[_DM_USERS]
	EXEC dbo.webservices_initiate @screen='USERS'	
	--RUN	 DMFeed: SSIS FSDB_Downloads_Parallel.dtsx module


	-- 3/15/2017 2:40 PM
	--TRUNCATE TABLE [DM_Shadow_Staging].[dbo].[_DM_AWARDHONOR]
	--TRUNCATE TABLE [DM_Shadow_Production].[dbo].[_DM_AWARDHONOR]
	SELECT * FROM [DM_Shadow_Staging].[dbo].[_DM_AWARDHONOR]
	SELECT * FROM [DM_Shadow_Production].[dbo].[_DM_AWARDHONOR]
	EXEC dbo.webservices_initiate @screen='AWARDHONOR'	
	--RUN	 DMFeed: SSIS FSDB_Downloads_Parallel.dtsx module

	-- 3/15/2017 4:40 PM
	SELECT * FROM [DM_Shadow_Staging].[dbo].[_DM_PCI] order by username
	SELECT * FROM [DM_Shadow_Production].[dbo].[_DM_PCI] 
	EXEC dbo.webservices_initiate @screen='PCI'	
	--RUN	 DMFeed: SSIS FSDB_Downloads_Parallel.dtsx module

	-- 3/15/2017 4:49 PM -- old schema, old DL process
	-- 3/24/2017 5.15 PM -- new schema, new DL process
	--TRUNCATE TABLE [DM_Shadow_Staging].[dbo].[_DM_PRESENT]
	--TRUNCATE TABLE [DM_Shadow_Staging].[dbo].[_DM_PRESENT_AUTH]
	--TRUNCATE TABLE [DM_Shadow_Production].[dbo].[_DM_PRESENT]
	--TRUNCATE TABLE [DM_Shadow_Production].[dbo].[_DM_PRESENT_AUTH]
	SELECT * FROM [DM_Shadow_Staging].[dbo].[_DM_PRESENT]
	SELECT * FROM [DM_Shadow_Production].[dbo].[_DM_PRESENT]
	SELECT * FROM [DM_Shadow_Staging].[dbo].[_DM_PRESENT_AUTH]
	SELECT * FROM [DM_Shadow_Production].[dbo].[_DM_PRESENT_AUTH]
	EXEC dbo.webservices_initiate @screen='PRESENT'	
	--RUN	 DMFeed: SSIS FSDB_Downloads_Parallel.dtsx module

	-- 3/15/2017 4:55 PM -- old schema, old DL process
	-- 3/24/2017 5 PM	 -- new schema, new DL process
	--TRUNCATE TABLE [DM_Shadow_Staging].[dbo].[_DM_CONGRANT]
	--TRUNCATE TABLE [DM_Shadow_Staging].[dbo].[_DM_CONGRANT_INVEST]
	--TRUNCATE TABLE [DM_Shadow_Production].[dbo].[_DM_CONGRANT]
	--TRUNCATE TABLE [DM_Shadow_Production].[dbo].[_DM_CONGRANT_INVEST]
	SELECT * FROM [DM_Shadow_Staging].[dbo].[_DM_CONGRANT]
	SELECT * FROM [DM_Shadow_Staging].[dbo].[_DM_CONGRANT_INVEST]
	SELECT * FROM [DM_Shadow_Production].[dbo].[_DM_CONGRANT]
	SELECT * FROM [DM_Shadow_Production].[dbo].[_DM_CONGRANT_INVEST]
	EXEC dbo.webservices_initiate @screen='CONGRANT'	
	--RUN	 DMFeed: SSIS FSDB_Downloads_Parallel.dtsx module


	-- 3/15/2017 6.00 PM -- old schema, old DL process
	-- 3/24/2017 5 PM	 -- new schema, new DL process
	--TRUNCATE TABLE [DM_Shadow_Staging].[dbo].[_DM_INTELLCONT]
	--TRUNCATE TABLE [DM_Shadow_Staging].[dbo].[_DM_INTELLCONT_AUTH]
	--TRUNCATE TABLE [DM_Shadow_Production].[dbo].[_DM_INTELLCONT]
	--TRUNCATE TABLE [DM_Shadow_Production].[dbo].[_DM_INTELLCONT_AUTH]
	SELECT * FROM [DM_Shadow_Staging].[dbo].[_DM_INTELLCONT] 
	SELECT * FROM [DM_Shadow_Staging].[dbo].[_DM_INTELLCONT_AUTH]
	SELECT * FROM [DM_Shadow_Production].[dbo].[_DM_INTELLCONT]
	SELECT * FROM [DM_Shadow_Production].[dbo].[_DM_INTELLCONT_AUTH]
	EXEC dbo.webservices_initiate @screen='INTELLCONT'	
	--RUN	 DMFeed: SSIS FSDB_Downloads_Parallel.dtsx module


	-- 3/27/2017   1:50 PM
	SELECT * FROM [DM_Shadow_Staging].[dbo].[_DM_RESPROG] 
	SELECT * FROM [DM_Shadow_Production].[dbo].[_DM_RESPROG]
	EXEC dbo.webservices_initiate @screen='RESPROG'	
	--RUN	 DMFeed: SSIS FSDB_Downloads_Parallel.dtsx module

	-- 9/18/2017
	EXEC DM_Shadow_Staging.dbo.produce_XML_SCHTEACH
	EXEC DM_Shadow_Staging.dbo.DailyUpdate_sp_DM_Step11_Report_DTSX_Errors

	-- 9/18/2017 and 9/19/2017
	EXEC dbo.webservices_initiate @screen='PROFILE'
	EXEC DM_Shadow_Staging.dbo.DailyUpdate_sp_DM_Step10_Run_DTSX

	UPDATE [DM_Shadow_Staging].[dbo].[webservices_requests]
	SET  [responseCode] = NULL ,[response] = NULL ,[process] = NULL ,[initiated] = NULL ,[completed] = NULL ,[processed] = NULL ,dependsOn = null
	WHERE ID = 2491
	EXEC DM_Shadow_Staging.dbo.DailyUpdate_sp_DM_Step10_Run_DTSX

	-- 9/20/2017
	EXEC dbo.webservices_initiate @screen='CONTACT'
	EXEC DM_Shadow_Staging.dbo.DailyUpdate_sp_DM_Step10_Run_DTSX
	
	UPDATE [DM_Shadow_Staging].[dbo].[webservices_requests]
	SET  [responseCode] = NULL ,[response] = NULL ,[process] = NULL ,[initiated] = NULL ,[completed] = NULL ,[processed] = NULL ,dependsOn = null
	WHERE ID = 2495
	EXEC DM_Shadow_Staging.dbo.DailyUpdate_sp_DM_Step10_Run_DTSX

	SELECT * FROM [DM_Shadow_Staging].[dbo].[_DM_CONTACT] 
	SELECT * FROM [DM_Shadow_Staging].[dbo].[_DM_CONTACT_SOCIAL_MEDIA] 
	SELECT * FROM [DM_Shadow_Staging].[dbo].[_DM_CONTACT_OTHER_PHONE] 
	SELECT * FROM [DM_Shadow_Production].[dbo].[_DM_CONTACT] 
	SELECT * FROM [DM_Shadow_Production].[dbo].[_DM_CONTACT_SOCIAL_MEDIA] 
	SELECT * FROM [DM_Shadow_Production].[dbo].[_DM_CONTACT_OTHER_PHONE] 


  /*
  SELECT * FROM [DM_Shadow_Staging].[dbo].[_DM_INTELLCONT] WHERE username='nhadi' 
	userid	id				USERNAME	title
	1791140	138778734592	nhadi		test 4
	1791140	144073977856	nhadi		article 6
	1791140	144157110272	nhadi		Market Oriented Services
	
  SELECT * FROM [DM_Shadow_Staging].[dbo].[_DM_INTELLCONT] WHERE id='144157110272'
	userid	id				USERNAME	title
	1791140	144157110272	nhadi		Market Oriented Services
	1940561	144157110272	brownjr		Market Oriented Services
	1940574	144157110272	halmeida	Market Oriented Services

  SELECT * FROM [DM_Shadow_Staging].[dbo].[_DM_INTELLCONT_AUTH] WHERE id='144157110272' -- username='nhadi'
	id				itemid			userid	USERNAME
	138778734592	138778734595	1791140	nhadi
	144073977856	144073977858	1791140	nhadi
	144157110272	144157110273	1791140	nhadi

  SELECT * FROM [DM_Shadow_Staging].[dbo].[_DM_INTELLCONT] WHERE id='138778734592'
  SELECT * FROM [DM_Shadow_Staging].[dbo].[_DM_INTELLCONT_AUTH] WHERE id='138778734592' 

	

  */

  /*

		NS 3/20/2017
		=======================================================================
		(B) Create Publications from all civitas academica past and present in FSDB

		>>>>>> STAGE 1: Insert all FSDB bus_person_indicator = 1 into _DM_USERS with Scott's DM ID (1791141)

		INSERT INTO dbo._DM_USERS (
			username, userid, FacstaffID, EDWPERSID, UIN, First_Name, Middle_Name, Last_Name
					 ,Email_Address, Enabled_Indicator, Load_Scope
					 ,Update_Datetime
		)
		SELECT network_id, '1791141', Facstaff_ID, EDW_PERS_ID, UIN, First_Name, Middle_Name, Last_Name
					,network_id + '@illinois.edu', 0, 'Y'
					,getdate()
		FROM faculty_Staff_Holder.dbo.facstaff_basic
		WHERE  (BUS_Person_Indicator = 1) 
				AND (EDW_PERS_ID IS NOT NULL)
				AND network_id NOT IN (SELECT username FROM _DM_USERS)

		>>>>>> STAGE 2: Generate _DM_INTELLCONT (run Faculty_Staff_Holder.dbo.__DM_Excel_INTELLCONT)

		EXEC  Faculty_Staff_Holder.dbo.__DM_Excel_INTELLCONT
		SELECT * FROM dbo._UPLOADED_DM_INTELLCONT
		
		EXEC  Faculty_Staff_Holder.dbo.__DM_Excel_CONGRANT
		SELECT * FROM dbo._UPLOADED_DM_CONGRANT

		EXEC  Faculty_Staff_Holder.dbo.__DM_Excel_PRESENT
		SELECT * FROM dbo._UPLOADED_DM_PRESENT


		>>>>>> STAGE 3: Remove newly added records at dbo._DM_USERS

		DECLARE @toremovedate as datetime
		SELECT @toremovedate = MAX(Update_Datetime)
		FROM dbo._DM_USERS

		PRINT @toremovedate

		DELETE FROM dbo._DM_USERS
		WHERE Update_Datetime = @toremovedate
				AND Enabled_Indicator=0 AND Load_Scope='Y'


	*/

	/*
		3/7/2017
		=======================================================
		C) To test new user(s) creation

		1. Edit Test_Create_New_Users_At_DM SP
				This SP populates USERS table with new users to add to DM, indicate the records with Load_Scope = 'Y'
				(all other records must have Load_Scope = 'N')
		2. Run DM_Shadow_Staging.dbo.produce_XML_USERS SP
				This SP convert those records into XML, and put the POST records into web_services_requests table
				leave web_services_requests.completed to NULL
				Once done check web_services_requests table whether related new records are actually created
		3. Run SSIS package FSDB_Post_Users
				This module connects to DM webservices and submit each records (marked by ) from web_services_requests table
				whose web_services_requests.completed is NULL
		


	UPDATE USERS SET Load_Scope='N'

	INSERT INTO DM_Shadow_Staging.dbo.USERS (
		username, Facstaff_ID, EDW_PERS_ID, UIN, First_Name, Middle_Name, Last_Name, Email_Address, Enabled_Indicator, Load_Scope
					 ,Update_Datetime
	)
	SELECT network_id, Facstaff_ID, EDW_PERS_ID, UIN, First_Name, Middle_Name, Last_Name, network_id + '@illinois.edu', 1, 'Y'
					, getdate()
	FROM faculty_Staff_Holder.dbo.facstaff_basic
	WHERE network_id='wenhan'

	--WHERE network_id='wenhan'		-- 3/27/2017
	--WHERE network_id='mviswana'
	--WHERE network_id='mkoo'
	--WHERE network_id='peecher'	-- 3/21/2017
	--where facstaff_id in (264, 101564, 15923, 11937, 17047, 59, 16336, 101396)		-- 3/14/2017
	--where facstaff_id in (13853, 13703, 78, 129, 15905)	-- 3/7/2017

	--SELECT * FROM USERS

	-- NS 10/1/2017
	
	MUST SEE  Faculty_Staff_Holder.dbo._Adhoc_sp_DM_Create_BUS_COURSES_EDW_and_BUS_ICES_Part1
		and Faculty_Staff_Holder.dbo._Adhoc_sp_DM_Create_BUS_COURSES_EDW_and_BUS_ICES_Part2

	-- NS 10/2/2017
	It is odd that all of sudden we got this error on all execution of shadow_*
	   Description: Executing the query "dbo.webservices_process" failed with the following error: "Error converting data type varchar to bigint.". 
	   Possible failure reasons: Problems with the query, "ResultSet" property not set correctly, parameters not set correctly, or connection not established correctly.

	UPDATE [DM_Shadow_Staging].[dbo].[webservices_requests]
		SET  [responseCode] = NULL
			  ,[response] = NULL
			  ,[process] = NULL
			  ,[initiated] = NULL
			  ,[completed] = NULL
			  ,[processed] = NULL
			  ,dependsOn = null
	--WHERE ID = 26327
	--WHERE ID = 26326
	WHERE ID in (26325,26324,26323)

	EXEC dbo.webservices_initiate @username='rashad'  -- PCI, bio, consulting, honor, pub, edu, facdev, member
														-- service ACO, service pro, svc committee
	EXEC dbo.webservices_initiate @username='busfac1'
	EXEC dbo.webservices_initiate @username='brownjr' -- PCI, bio, consulting, honor, pub, edu, facdev, member
														-- service ACO, service pro, svc committee, presentation
	EXEC dbo.webservices_initiate @username='nhadi'	-- especially: Work in progress, deg committee, grants, innovations
														-- certifications

	EXEC dbo.webservices_run_DTSX

	SELECT * FROM [DM_Shadow_Staging].[dbo].[webservices_requests] ORDER BY created DESC


	-- NS 10/3/2017
	EXEC dbo.webservices_initiate @screen='PCI'	


	-- NS 10/4/2017
	EXEC dbo.DailyUpdate_sp_DM_Step04_New_Employees_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees
	EXEC dbo.DailyUpdate_sp_DM_Step05_New_Employees_BEL_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees
	EXEC dbo.DailyUpdate_sp_DM_Step06_Update_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees
	EXEC dbo.DailyUpdate_sp_DM_Step09_Reset_UPLOAD_DM_BANNER_copy_to_DM_BANNER

	EXEC dbo.produce_XML_PCI @submit = 1
	EXEC dbo.webservices_run_DTSX
	EXEC dbo.webservices_initiate @screen='PCI'	
	EXEC dbo.webservices_run_DTSX

	--> Department DDL are not good yet cannot run POST updates, some records have gender "Female" and unupdatable since the department cannot be posted
	Ofc of Undergraduate Affairs
	College of Business
	Communication
	ELearning
	iMBA
	Advancement

	-- NS 10/11/2017
	EXEC dbo.webservices_initiate @username='brownjr' 
	EXEC dbo.webservices_initiate @username='rashad' 
	EXEC dbo.webservices_run_DTSX

	EXEC dbo.webservices_initiate @screen='INTELLCONT'
	EXEC dbo.webservices_run_DTSX

	-- NS 10/12/2017
	EXEC dbo.webservices_initiate @screen='CONTACT'
	EXEC dbo.webservices_initiate @screen='PROFILE'
	EXEC dbo.webservices_initiate @screen='CONGRANT'
	EXEC dbo.webservices_initiate @screen='INTELLCONT'
	EXEC dbo.webservices_initiate @screen='PRESENT'
	EXEC dbo.webservices_initiate @screen='DEG_COMMITTEE'
	EXEC dbo.webservices_initiate @username='brownjr'	-- username=brownjr 	userid=1940561	FacstaffID=239

	EXEC dbo.webservices_run_DTSX

	Common Errors:
	Description: Executing the query "dbo.webservices_process" failed with the following error: "Invalid column name 'Download_Datetime'.". Possible failure reasons: Problems with the query, "ResultSet" property not set correctly, parameters not set correc
	--> one or more of the 4 tables miss Download_Datetime column
	Description: Executing the query "dbo.webservices_process" failed with the following error: "Incorrect syntax near the keyword 'DESC'.
	--> pass [DESC] instead of DESC to shadow_screen_data2()

	-- NS 10/16/2017

	SELECT *   FROM [Faculty_Staff_Holder].[dbo].[Facstaff_Basic]
    WHERE facstaff_id>=102369 and edw_pers_id is not null
    ORDER BY [Facstaff_ID] DESC

	MUST have the same # of records with

	SELECT *
	FROM [DM_Shadow_Staging].[dbo].[FSDB_Facstaff_Basic]
	WHERE facstaff_id>=102369
	ORDER BY [Facstaff_ID] DESC

	-- ----------------------------------------------
	EXEC dbo.webservices_initiate @username='brownjr' 
	EXEC dbo.webservices_initiate @username='rashad' 
	EXEC dbo.webservices_initiate @username='nhadi' 
	EXEC dbo.webservices_run_DTSX
	-- ----------------------------------------------
	SELECT * FROM webservices_requests order by id desc

	SELECT *
	  FROM [DM_Shadow_Staging].[dbo].[_DM_USERS]
	  order by [Update_Datetime] desc

	SELECT *
	  FROM [DM_Shadow_Staging].[dbo].[_DM_PCI]
	  order by Download_Datetime desc
	-- ----------------------------------------------
	SELECT *
	FROM [DM_Shadow_Staging].[dbo]._DM_DEG_COMMITTEE
		order by Download_Datetime desc

	SELECT *
	FROM [DM_Shadow_Staging].[dbo]._DM_DEG_COMMITTEE_MEMBER
		order by Download_Datetime desc
	-- ----------------------------------------------
	SELECT *
	FROM [DM_Shadow_Staging].[dbo]._DM_CONTACT
		order by Download_Datetime desc

	SELECT *
	FROM [DM_Shadow_Staging].[dbo]._DM_CONTACT_OTHER_PHONE
		order by Download_Datetime desc

	SELECT *
	FROM [DM_Shadow_Staging].[dbo]._DM_CONTACT_SOCIAL_MEDIA
		order by Download_Datetime desc
	-- ----------------------------------------------
	SELECT *
	FROM [DM_Shadow_Staging].[dbo]._DM_PROFILE
		order by Download_Datetime desc

	SELECT *
	FROM [DM_Shadow_Staging].[dbo]._DM_PROFILE_LANGUAGES
		order by Download_Datetime desc
	-- ----------------------------------------------
	SELECT *
	FROM [DM_Shadow_Staging].[dbo]._DM_CONGRANT
		order by Download_Datetime desc

	SELECT *
	FROM [DM_Shadow_Staging].[dbo]._DM_CONGRANT_INVEST
		order by Download_Datetime desc
	-- ----------------------------------------------
	SELECT *
	FROM [DM_Shadow_Staging].[dbo].[_DM_PRESENT]
		order by Download_Datetime desc

	SELECT *
	FROM [DM_Shadow_Staging].[dbo].[_DM_PRESENT_AUTH]
		order by Download_Datetime desc
	-- ---------------------------------------------
	SELECT *
	FROM [DM_Shadow_Staging].[dbo].[_DM_INTELLCONT]
		order by Download_Datetime desc

	SELECT *
	FROM [DM_Shadow_Staging].[dbo].[_DM_INTELLCONT_AUTH]
		order by Download_Datetime desc



	-- NS 10/25/2017
	EXEC dbo.webservices_initiate @screen='PCI'
	EXEC dbo.webservices_run_DTSX

	-- NS 10/27/2017
	EXEC dbo.webservices_initiate @screen='USERS'
	EXEC dbo.webservices_run_DTSX

	-- NS 11/1/2017
	EXEC dbo._Test_Shadow_ADMIN
	EXEC dbo.webservices_initiate @screen='ADMIN'
	EXEC dbo.webservices_run_DTSX
	*/
GO
