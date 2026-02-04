SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/


-- NS 11/27/2018	Run in sequence
--			Adhoc_sp_Add_DM_With_New_Users_From_Facstaff_Basic
--			DailyUpdate_sp_DM_Step04_New_Employees_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees
--			Adhoc_sp_Initialize_DM_BANNER
--			Adhoc_sp_Initialize_Facstaff_Basic_From_FSDB
--			Adhoc_sp_Initialize_FSDB_Course_Details
--			Adhoc_sp_Initialize_Journal_Short_Names
CREATE PROC [dbo].[Adhoc_sp__Transition_04Initialize_FSDB_Course_Details]
AS
	TRUNCATE TABLE [DM_Shadow_Staging].[dbo].[FSDB_Course_Details]

	INSERT INTO [DM_Shadow_Staging].[dbo].[FSDB_Course_Details](
		   [Course_ID]
		  ,[Facstaff_ID]
		  ,[CRS_ID]
		  ,[TERM_CD]
		  ,[CRN]
		  ,[CRS_SUBJ_CD]
		  ,[CRS_NBR]
		  ,[CRS_TITLE]
		  ,[SECT_NBR]
		  ,[SCHED_TYPE_CD]
		  ,[Enrollment]
		  ,[Course_Web_URL]
		  ,[Course_Syllabus_Name]
		  ,[Course_Syllabus_Extension]
		  ,[Active_Indicator]
		  ,[Create_Datetime])
	SELECT 
		 [Course_ID]
		  ,[Facstaff_ID]
		  ,[CRS_ID]
		  ,[TERM_CD]
		  ,[CRN]
		  ,[CRS_SUBJ_CD]
		  ,[CRS_NBR]
		  ,[CRS_TITLE]
		  ,[SECT_NBR]
		  ,[SCHED_TYPE_CD]
		  ,[Enrollment]
		  ,[Course_Web_URL]
		  ,[Course_Syllabus_Name]
		  ,[Course_Syllabus_Extension]
		  ,[Active_Indicator]
		  ,[Create_Datetime]
	FROM [Faculty_Staff_Holder].[dbo].[Course_Details]
GO
