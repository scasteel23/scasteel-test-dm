SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 4/4/2019 change from using TDS to using SQL OLE automation to DM webservices 
-- NS 3/29/2019
--		WHEN both PFNAME and PLNAME in PCI screen are not empty, update FNAME, MNAME and LNAME in USER screen with PFNAME, PMNAME and PLNAME from PCI
--				empty PFNAME, PMNAME, and PLNAME in PCI
--		OTHERIWISE (at least one of PFNAME or PLNAME is empty) and anyone of PFNAME, PMNAME, or PLNAME in PCI has values, empty PFNAME, PMNAME, and PLNAME in PCI
--
--  Reasoning why there are PFNAME, PMNAME, PLNAME and script to run every 30 minutes to update FNAME,MNAME,LNAME at PCI and USERS screens.
--	  PCI screen has name fields as well as USER screen.
--	  If names in USERS screen got updated, names in PCI screen are also got updated automatically. But not the other way.
--	  End users cannot update names in USERS screen, hence we allow update names on PCI screen.
--	  When end users update names on PCI screen, the names are not propagated to the USERS screen.
--	  Names in USERS are used as names when end-users sign in into DM, names in PCI are used in CV, and other reports.
--	  In order to maintain consistency, we do not allow updates names (FNAME, LNAME, MNAME) in PCI directly but through temporary name fields (PFNAME, PLNAME, PMNAME)
--	  we have a script to check and updates (FNAME, MNAME, LNAME) in both PCI and USESR screen.
--	

CREATE PROC [dbo].[DailyUpdate_sp_Hourly_Update_Names_From_Preferred_Name_orig]  ( @submit BIT=0 )

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
	  ,PCI_Empty_Pname
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
  WHERE ACTIVE = 'Yes'


  -- log the changes

  INSERT INTO DM_Shadow_Staging.dbo._DM_PCI_For_Name_Update_Log
  ( userid,USERNAME,FACSTAFFID,EDWPERSID,FNAME,MNAME,LNAME,PFNAME,PMNAME,PLNAME,BUS_FACULTY,ACTIVE
      ,PCI_Empty_Pname,USER_Update_Name,lastModified,Create_datetime,Download_Datetime  )
  SELECT userid,USERNAME,FACSTAFFID,EDWPERSID,FNAME,MNAME,LNAME,PFNAME,PMNAME,PLNAME,BUS_FACULTY,ACTIVE
      ,'Yes'
	  ,CASE WHEN PFNAME IS NOT NULL AND RTRIM(PFNAME) <> '' 
				AND PLNAME IS NOT NULL AND RTRIM(PLNAME) <> ''  THEN 'Yes'
			ELSE 'No' END as USER_Update_Name
	  ,lastModified,Create_datetime,Download_Datetime
  FROM DM_Shadow_Staging.dbo._DM_PCI_For_Name_Update
  WHERE ((PFNAME IS NOT NULL AND RTRIM(PFNAME) <> '')
		OR (PLNAME IS NOT NULL AND RTRIM(PLNAME) <> '')
		OR (PMNAME IS NOT NULL AND RTRIM(PMNAME) <> ''))
  
  -- move PFNAME, PMNAME, PLNAME to FNAME, MNAME, LNAME if  PLNAME and PFNAME both are not empty

  UPDATE DM_Shadow_Staging.dbo._DM_PCI_For_Name_Update
  SET FNAME = PFNAME, MNAME = PMNAME, LNAME = PLNAME,  USER_Update_Name='Yes', PCI_Empty_Pname='Yes',
		PFNAME = '', PMNAME = '', PLNAME = ''
  WHERE PFNAME IS NOT NULL AND RTRIM(PFNAME) <> '' 
		AND PLNAME IS NOT NULL AND RTRIM(PLNAME) <> '' 

  -- empty PFNAME, PLNAME, PMNAME if either PFNAME OR PLNAME is not empty
  UPDATE DM_Shadow_Staging.dbo._DM_PCI_For_Name_Update
  SET PFNAME = '', PMNAME = '', PLNAME = '',  PCI_Empty_Pname='Yes'
  WHERE ((PFNAME IS NOT NULL AND RTRIM(PFNAME) <> '')
		OR (PLNAME IS NOT NULL AND RTRIM(PLNAME) <> '')
		OR (PMNAME IS NOT NULL AND RTRIM(PMNAME) <> ''))


  UPDATE DM_Shadow_Staging.dbo._DM_PCI_For_Name_Update
  SET PLNAME = '', PMNAME='', PFNAME=''


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
