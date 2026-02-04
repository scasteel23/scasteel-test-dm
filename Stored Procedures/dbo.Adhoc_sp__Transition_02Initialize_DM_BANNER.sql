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
CREATE PROC [dbo].[Adhoc_sp__Transition_02Initialize_DM_BANNER]
AS

	truncate table dbo._DM_BANNER

	INSERT INTO dbo._DM_BANNER
	(  [userid]	-- this is DM ID
      --,[id]		-- this is DM ID
      ,[USERNAME]
      ,[FACSTAFFID]
      ,[EDWPERSID]
      ,[UIN]
      ,[EDW_Database]
      ,[PERS_PREFERRED_FNAME]
      ,[PERS_FNAME]
      ,[PERS_MNAME]
      ,[PERS_LNAME]
      ,[BIRTH_DT]
      ,[SEX_CD]
      ,[RACE_ETH_DESC]
      ,[PERS_CITZN_TYPE_DESC]
      ,[EMPEE_CAMPUS_CD]
      ,[EMPEE_CAMPUS_NAME]
      ,[EMPEE_COLL_CD]
      ,[EMPEE_COLL_NAME]
      ,[EMPEE_DEPT_CD]
      ,[EMPEE_DEPT_NAME]
      ,[JOB_DETL_TITLE]
      ,[JOB_DETL_FTE]
      ,[JOB_CNTRCT_TYPE_DESC]
      ,[JOB_DETL_COLL_CD]
      ,[JOB_DETL_COLL_NAME]
      ,[JOB_DETL_DEPT_CD]
      ,[JOB_DETL_DEPT_NAME]
      ,[COA_CD]
      ,[ORG_CD]
      ,[EMPEE_ORG_TITLE]
      ,[EMPEE_CLS_CD]
      ,[EMPEE_CLS_LONG_DESC]
      ,[EMPEE_GROUP_CD]
      ,[EMPEE_GROUP_DESC]
      ,[EMPEE_RET_IND]
      ,[EMPEE_LEAVE_CATGRY_CD]
      ,[EMPEE_LEAVE_CATGRY_DESC]
      ,[BNFT_CATGRY_CD]
      ,[BNFT_CATGRY_DESC]
      ,[HR_CAMPUS_CD]
      ,[HR_CAMPUS_NAME]
      ,[EMPEE_STATUS_CD]
      ,[EMPEE_STATUS_DESC]
      ,[CAMPUS_JOB_DETL_FTE]
      ,[COLLEGE_JOB_DETL_FTE]
      ,[FAC_RANK_CD]
      ,[FAC_RANK_DESC]
      ,[FAC_RANK_ACT_DT]
      ,[FAC_RANK_DECN_DT]
      ,[FAC_RANK_ACAD_TITLE]
      ,[FAC_RANK_EMRTS_STATUS_IND]
      ,[FIRST_HIRE_DT]
      ,[CUR_HIRE_DT]
      ,[FIRST_WORK_DT]
      ,[LAST_WORK_DT]
      ,[EMPEE_TERMN_DT]
      ,[Network_ID]
      ,[lastModified]
      ,[Create_Datetime])

--SELECT Network_ID as USERNAME
--      ,[FACSTAFF_ID] as FACSTAFFID
--      ,[EDW_PERS_ID] as EDWPERSID
--      ,[UIN]
--      --,[EDW_Database]
--      ,[PERS_PREFERRED_FNAME]
--      ,First_Name
--      ,Middle_Name
--      ,last_Name
--      ,Birth_date
--      ,Gender
--	  ,[Network_ID]
--      ,getdate()
--      ,getdate()
--  FROM Faculty_Staff_Holder.dbo.Facstaff_BASIC  
--  WHERE Active_Indicator=1 
--		AND Bus_Person_Indicator =1
--		AND EMPEE_CLS_CD NOT IN ('GA','SA', 'HG')

SELECT 
      users.[userID]
	  ,banner.[USERNAME]
      ,banner.[FACSTAFFID]
      ,banner.[EDWPERSID]
      ,banner.[UIN]
      ,[EDW_Database]
      ,[PERS_PREFERRED_FNAME]
      ,[PERS_FNAME]
      ,[PERS_MNAME]
      ,[PERS_LNAME]
      ,[BIRTH_DT]
      ,[SEX_CD]
      ,[RACE_ETH_DESC]
      ,[PERS_CITZN_TYPE_DESC]
      ,[EMPEE_CAMPUS_CD]
      ,[EMPEE_CAMPUS_NAME]
      ,[EMPEE_COLL_CD]
      ,[EMPEE_COLL_NAME]
      ,[EMPEE_DEPT_CD]
      ,[EMPEE_DEPT_NAME]
      ,[JOB_DETL_TITLE]
      ,[JOB_DETL_FTE]
      ,[JOB_CNTRCT_TYPE_DESC]
      ,[JOB_DETL_COLL_CD]
      ,[JOB_DETL_COLL_NAME]
      ,[JOB_DETL_DEPT_CD]
      ,[JOB_DETL_DEPT_NAME]
      ,[COA_CD]
      ,[ORG_CD]
      ,[EMPEE_ORG_TITLE]
      ,[EMPEE_CLS_CD]
      ,[EMPEE_CLS_LONG_DESC]
      ,[EMPEE_GROUP_CD]
      ,[EMPEE_GROUP_DESC]
      ,[EMPEE_RET_IND]
      ,[EMPEE_LEAVE_CATGRY_CD]
      ,[EMPEE_LEAVE_CATGRY_DESC]
      ,[BNFT_CATGRY_CD]
      ,[BNFT_CATGRY_DESC]
      ,[HR_CAMPUS_CD]
      ,[HR_CAMPUS_NAME]
      ,[EMPEE_STATUS_CD]
      ,[EMPEE_STATUS_DESC]
      ,[CAMPUS_JOB_DETL_FTE]
      ,[COLLEGE_JOB_DETL_FTE]
      ,[FAC_RANK_CD]
      ,[FAC_RANK_DESC]
      ,[FAC_RANK_ACT_DT]
      ,[FAC_RANK_DECN_DT]
      ,[FAC_RANK_ACAD_TITLE]
      ,[FAC_RANK_EMRTS_STATUS_IND]
      ,[FIRST_HIRE_DT]
      ,[CUR_HIRE_DT]
      ,[FIRST_WORK_DT]
      ,[LAST_WORK_DT]
      ,[EMPEE_TERMN_DT]
      ,[Network_ID]
      ,Last_Update_Datetime
      ,[Create_Datetime]
  FROM dbo._UPLOAD_DM_BANNER banner
		INNER JOIN dbo._DM_USERS users
		ON banner.USERNAME = users.username



			
GO
