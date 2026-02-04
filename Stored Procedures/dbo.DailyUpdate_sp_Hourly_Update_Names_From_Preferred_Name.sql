SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- STC 9/5/19 - Update to implement new behavior as described in notes below
-- NS 4/4/2019 change from using TDS to using SQL OLE automation to DM webservices 
-- NS 3/29/2019
--		WHEN (PFNAME, PMNAME, PLNAME) <> (FNAME, MNAME, LNAME) and both PFNAME and PLNAME in PCI screen are not empty:
--				valid name change has been entered, so update FNAME, MNAME and LNAME in USER screen with PFNAME, PMNAME and PLNAME from PCI
--		WHEN at least one of PFNAME or PLNAME is empty:
--				name is invalid, so reset values of PFNAME, PMNAME, and PLNAME in PCI to FNAME, MNAME, LNAME
--		OTHERWISE do nothing
--				(user made no changes; (PFNAME, PMNAME, PLNAME) = (FNAME, MNAME, LNAME))
--
--  Reasoning why there are PFNAME, PMNAME, PLNAME and script to run every 30 minutes to update FNAME,MNAME,LNAME at PCI and USERS screens.
--	  PCI screen has name fields as well as USER screen.
--	  If names in USERS screen got updated, names in PCI screen are also got updated automatically. But not the other way.
--	  End users cannot update names in USERS screen, hence we allow update names on PCI screen.
--	  When end users update names on PCI screen, the names are not propagated to the USERS screen.
--	  Names in USERS are used as names when end-users sign in into DM, names in PCI are used in CV, and other reports.
--	  In order to maintain consistency, we do not allow updates names (FNAME, LNAME, MNAME) in PCI directly but through temporary name fields (PFNAME, PLNAME, PMNAME)
--	  we have a script to check and updates (FNAME, MNAME, LNAME) in both PCI and USERS screen.
--	

CREATE PROC [dbo].[DailyUpdate_sp_Hourly_Update_Names_From_Preferred_Name]  ( @submit BIT=0 )

AS
	-- How to manually run
	-- EXEC dbo.[DailyUpdate_sp_Hourly_Update_Names_From_Preferred_Name] @submit=1
	DECLARE @Result varchar(500)

	-- Refresh PCI, ADMIN and USER screen shadow data
	EXEC dbo.webservices_initiate @screen='USERS'
	EXEC dbo.webservices_initiate @screen='PCI'
	EXEC dbo.webservices2_run @Result = @Result OUTPUT

	TRUNCATE TABLE DM_Shadow_Staging.dbo._DM_PCI_For_Name_Update
	--select * from DM_Shadow_Staging.dbo._DM_PCI_For_Name_Update where USERNAME='nhadi'
	--select * from DM_Shadow_Staging.dbo._DM_PCI where USERNAME='nhadi'
	INSERT INTO DM_Shadow_Staging.dbo._DM_PCI_For_Name_Update
	(
	   userid
      ,id
      ,surveyID
      ,termID
      ,USERNAME
      ,FACSTAFFID
      ,EDWPERSID
      ,FNAME
      ,MNAME
      ,LNAME
      ,PFNAME
      ,PMNAME
      ,PLNAME
      ,BUS_FACULTY
      ,ACTIVE
	  ,USER_Update_Name
	  ,PCI_Reset_PName
      ,lastModified
      ,Create_datetime
      ,Download_Datetime
	)
	SELECT  userid
      ,id
      ,surveyID
      ,termID
      ,USERNAME
      ,FACSTAFFID
      ,EDWPERSID
      ,FNAME
      ,MNAME
      ,LNAME
      ,PFNAME
      ,PMNAME
      ,PLNAME
      ,BUS_FACULTY
      ,ACTIVE
	  ,'No'
	  ,'No'
      ,lastModified
      ,Create_datetime
      ,Download_Datetime
  FROM DM_Shadow_Staging.dbo._DM_PCI
--  WHERE ACTIVE = 'Yes'


  -- log the changes

  INSERT INTO DM_Shadow_Staging.dbo._DM_PCI_For_Name_Update_Log
  ( userid,USERNAME,FACSTAFFID,EDWPERSID,FNAME,MNAME,LNAME,PFNAME,PMNAME,PLNAME,BUS_FACULTY,ACTIVE
      ,PCI_Reset_PName,USER_Update_Name,lastModified,Create_datetime,Download_Datetime,Log_Datetime  )
  SELECT userid,USERNAME,FACSTAFFID,EDWPERSID,FNAME,MNAME,LNAME,PFNAME,PMNAME,PLNAME,BUS_FACULTY,ACTIVE
--      ,'Yes'
	  ,CASE WHEN PFNAME IS NULL OR RTRIM(PFNAME) = '' 
				OR PLNAME IS NULL OR RTRIM(PLNAME) = ''  THEN 'Yes'
			ELSE 'No' END as PCI_Reset_PName
	  ,CASE WHEN PFNAME IS NOT NULL AND RTRIM(PFNAME) <> '' 
				AND PLNAME IS NOT NULL AND RTRIM(PLNAME) <> ''  THEN 'Yes'
			ELSE 'No' END as USER_Update_Name
	  ,lastModified,Create_datetime,Download_Datetime,CURRENT_TIMESTAMP
  FROM DM_Shadow_Staging.dbo._DM_PCI_For_Name_Update
  WHERE (PFNAME <> FNAME OR PLNAME <> LNAME OR PMNAME <> MNAME)
  
  -- if PNAME <> NAME and PLNAME and PFNAME both are not empty,
  -- update USERS name (set NAME = PNAME), no need to reset PNAME

  UPDATE DM_Shadow_Staging.dbo._DM_PCI_For_Name_Update
  SET FNAME = PFNAME, MNAME = PMNAME, LNAME = PLNAME,  USER_Update_Name='Yes'
  WHERE (PFNAME <> FNAME OR PLNAME <> LNAME OR PMNAME <> MNAME)
		AND PFNAME IS NOT NULL AND RTRIM(PFNAME) <> '' 
		AND PLNAME IS NOT NULL AND RTRIM(PLNAME) <> '' 

  -- if either PFNAME OR PLNAME is empty,
  -- reset PNAME (set PNAME = NAME), no neeed to update USERS name

  UPDATE DM_Shadow_Staging.dbo._DM_PCI_For_Name_Update
  SET PFNAME = FNAME, PMNAME = MNAME, PLNAME = LNAME,  PCI_Reset_PName='Yes'
  WHERE PFNAME IS NULL OR RTRIM(PFNAME) = '' 
			OR PLNAME IS NULL OR RTRIM(PLNAME) = ''  


  -- should not need to do this
--  UPDATE DM_Shadow_Staging.dbo._DM_PCI_For_Name_Update
--  SET PFNAME = FNAME, PMNAME = MNAME, PLNAME = LNAME
----  SET PLNAME = '', PMNAME='', PFNAME=''


  SELECT * FROM DM_Shadow_Staging.dbo._DM_PCI_For_Name_Update --WHERE update_name = 'Yes'


  -- DEBUG
  --EXEC dbo.produce_XML_USERS_Update_Names @submit=1
  --EXEC dbo.produce_XML_PCI_Update_Names @submit = 1
  

  -- Production
 
  EXEC dbo.produce_XML_USERS_Update_Names @submit = @submit   
  IF @submit = 1
 	  EXEC dbo.webservices2_RUN @Result = @Result OUTPUT

  EXEC dbo.produce_XML_PCI_Update_Names @submit = @submit   
  IF @submit = 1
	  EXEC dbo.webservices2_RUN @Result = @Result OUTPUT
GO
