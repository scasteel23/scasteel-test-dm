SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

-- 10/4/2017: Retired this module, this has been donw on 
--		[DailyUpdate_sp_DM_Step04_New_Employees_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees]
-- 4/26/2017: working on it today
--   Put records on _UPLOAD_DM_USERS, _UPLOAD_DM_PCI tables ready for upload to DM, along with _UPLOAD_DM_BANNER table
--
-- NS 11/30/2016: Created

CREATE  Procedure [dbo].[Decommissioned_DailyUpdate_sp_DM_Step08_Add_Records_to_UPLOAD_DM_Other_Tables_From_FSDB_EDW_Current_Employees]
as

	DECLARE @term_cd varchar(6)
	DECLARE @prior_term_cd varchar(6)
	DECLARE @i integer

	DECLARE @Term_name_term varchar(20)
	DECLARE @Term_name_year varchar(4)
	DECLARE @Term_name varchar(20)

	SET @term_cd = dbo.DailyUpdate_fn_Get_Current_Term(getdate())

	SET @Term_name_term = dbo.Get_Term_Name(@term_cd)
	SET @Term_name_year= dbo.Get_Term_Year(@term_cd)
	IF @Term_name_term = ''
		SET @Term_name = ''
	ELSE
		SET @Term_name = @Term_name_term + ' ' + @Term_name_year

	TRUNCATE TABLE DM_Shadow_Staging.dbo._UPLOAD_DM_PCI
	TRUNCATE TABLE DM_Shadow_Staging.dbo._UPLOAD_DM_USERS

-- >>>> ADD new users (or updated data to USERS) to DM_Shadow_Staging.dbo._UPLOAD_DM_USERS

	INSERT INTO DM_Shadow_Staging.dbo._UPLOAD_DM_USERS
		  (USERID
		  ,username
		  ,FacstaffID
		  ,EDWPERSID
		  ,UIN
		  ,First_Name
		  ,Middle_Name
		  ,Last_Name
		  ,Email_Address
		  ,Enabled_Indicator
		  --,Load_Scope
		  ,Update_Datetime)
	SELECT ID
		  ,username
		  ,FacstaffID
		  ,EDWPERSID
		  ,UIN
		  ,PERS_FNAME
		  ,PERS_MNAME
		  ,PERS_LNAME
		  ,Network_ID + '@illinois.edu' as Email_Address
		  ,1 as Enabled_Indicator
		  --,'N' as Load_Scope
		  ,getdate() as Update_Datetime
	FROM DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
	WHERE Record_Status='NEW-EMPS'
			OR Update_Status LIKE '%U%'	-- there are updates on USERS screen
	
	-- >>>> ADD new users (or updated data to PCI screen) to DM_Shadow_Staging.dbo._UPLOAD_DM_PCI

	INSERT INTO DM_Shadow_Staging.dbo._UPLOAD_DM_PCI
	(	[ID]
		  ,FACSTAFFID
		  ,USERNAME
		  ,FNAME
		  ,MNAME
		  ,LNAME
		  ,PFNAME
		  ,EMAIL
		  ,DTM_DOB
		  ,DTD_DOB
		  ,DTY_DOB
		  ,DOB_START
		  ,DOB_END
		  ,GENDER
		  ,ETHNICITY
		  ,CITIZEN

		  ,STAFF_CLASS
		  ,DOC_STATUS
		  ,DOC_DEPT
		  ,DOC_TERM
		  ,BUS_PERSON
		  ,BUS_FACULTY

	)
	SELECT ID
	      ,FACSTAFFID
		  ,USERNAME
		  ,PERS_FNAME
		  ,PERS_MNAME
		  ,PERS_LNAME
		  ,PERS_PREFERRED_FNAME
		  ,Network_ID + '@illinois.edu' as EMAIL
	 	
		  ,CASE WHEN BIRTH_DT is NULL THEN ''
			ELSE DATENAME(month,BIRTH_DT) END  as DTM_DOB
		  ,ISNULL(CONVERT(VARCHAR(4),DATEPART(DAY, BIRTH_DT)),'')  as DTD_DOB
		  ,ISNULL(CONVERT(VARCHAR(4),DATEPART(YEAR, BIRTH_DT)),'') as DTY_DOB
		  ,CONVERT(varchar(12), BIRTH_DT,111) as DOB_START
		  ,CONVERT(varchar(12), BIRTH_DT,111) as DOB_END

		  ,CASE SEX_CD when 'M' THEN 'Male' WHEN 'F' THEN 'Female' ELSE '' END as GENDER
		  ,RACE_ETH_DESC as ETHNICITY
		  ,PERS_CITZN_TYPE_DESC as  CITIZEN	 
	
		  ,dbo.Get_Staff_Classification(EMPEE_GROUP_CD) as  STAFF_CLASS
		  ,CASE WHEN EDW_Database='PRRDOC' THEN 'Current PhD Student'
				ELSE ''
				END AS DOC_STATUS
		  ,CASE WHEN EDW_Database='PRRDOC' THEN EMPEE_DEPT_NAME
				ELSE ''
				END AS DOC_DEPT
		  ,CASE WHEN EDW_Database='PRRDOC' THEN @Term_name
				ELSE ''
				END AS DOC_TERM						  
		  ,'Yes' as BUS_PERSON
		  ,CASE WHEN FAC_RANK_CD IS NOT NULL AND FAC_RANK_CD <> '' THEN 'Yes'
				ELSE 'No'
				END AS BUS_FACULTY

	FROM DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
	WHERE Record_Status='NEW'
			OR Update_Status LIKE '%P%'		-- there are updates on PCI screen
GO
