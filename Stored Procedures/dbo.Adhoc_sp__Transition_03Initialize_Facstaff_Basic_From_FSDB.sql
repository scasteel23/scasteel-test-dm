SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 2/15/2019 Last Run
-- NS 11/27/2018	Run in sequence
--			Adhoc_sp_Add_DM_With_New_Users_From_Facstaff_Basic
--			DailyUpdate_sp_DM_Step04_New_Employees_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees
--			Adhoc_sp_Initialize_DM_BANNER
--			Adhoc_sp_Initialize_Facstaff_Basic_From_FSDB
--			Adhoc_sp_Initialize_FSDB_Course_Details
--			Adhoc_sp_Initialize_Journal_Short_Names
-- NS 11/27/2018
--		Added to adjust Facstaff_ID at FSDB_WEB_IDs from Facstaff_WEB_IDS
-- NS 4/20/2017: 
--		Initialize DM_Shadow_Staging.dbo.FSDB_Facstaff_Basic in order from 
--			Faculty_Staff_Holder.dbo.FSDB_Facstaff_Basic
--		This DM_Shadow_Staging.dbo.FSDB_Facstaff_Basic table will be use in the future to hold all COB academics & students
--			because we do not upload all records to DM
--		We need to do this once before we officially use DM to drive all profiles, and switch downloading
--			from (EDW to FSDB) to (EDW to DM)

CREATE PROCEDURE [dbo].[Adhoc_sp__Transition_03Initialize_Facstaff_Basic_From_FSDB]
AS

DECLARE @cdate datetime
SET @cdate = getdate()

-- Go to SSMS' Table design and drop IDENTITY from Facstaff_ID column
truncate table DM_Shadow_Staging.dbo.FSDB_Facstaff_Basic

INSERT INTO DM_Shadow_Staging.dbo.FSDB_Facstaff_Basic
	(
	Facstaff_ID,
	UIN, Network_ID,
	Email_address,
	EDW_PERS_ID, 
	JOB_DETL_DEPT_CD, 
	JOB_DETL_DEPT_NAME, 
	JOB_DETL_FTE,
	EMPEE_GROUP_CD, 
	EMPEE_GROUP_DESC, 
	EMPEE_CLS_CD,
	EMPEE_CLS_LONG_DESC,
	POSN_EMPEE_CLS_CD, 
	POSN_EMPEE_CLS_LONG_DESC,
	FAC_RANK_CD,
	FAC_RANK_DESC,
	FAC_RANK_DECN_DT,
	FAC_RANK_EMRTS_STATUS_IND,
	FAC_RANK_ACT_DT,
	JOB_DETL_TITLE,
	JOB_CNTRCT_TYPE_DESC,
	EMPEE_DEPT_CD,
	EMPEE_DEPT_NAME,
	POSN_NBR,
	First_Name,
	Last_Name, 
	Middle_Name, 
	PERS_PREFERRED_FNAME,
	Department_ID, 
	DM_Department_Name,
	Appointment_Percent, 
	Campus_Wide_Appointment_Percent, 
	Bus_Person_Manual_Entry_Indicator,
	BUS_Person_Indicator,
	Faculty_Staff_Indicator, 
	Staff_Classification_ID,
	Rank_ID,
	Active_Indicator, Current_Status_Indicator, College_List_Indicator, Department_List_Indicator,
	Gender,
	Birth_Date,
	Ethnicity_ID,
	Citizenship_ID,
	Hired_Date,
	Create_Datetime,
	Last_Update_Datetime,
	Last_EDW_Update_Datetime
	)

SELECT 
	Facstaff_ID,	UIN, Network_ID,
	Email_address,
	EDW_PERS_ID, 
	JOB_DETL_DEPT_CD, 
	JOB_DETL_DEPT_NAME, 
	JOB_DETL_FTE,
	EMPEE_GROUP_CD, 
	EMPEE_GROUP_DESC, 
	EMPEE_CLS_CD,
	EMPEE_CLS_LONG_DESC,
	POSN_EMPEE_CLS_CD, 
	POSN_EMPEE_CLS_LONG_DESC,
	FAC_RANK_CD,
	FAC_RANK_DESC,
	FAC_RANK_DECN_DT,
	FAC_RANK_EMRTS_STATUS_IND,
	FAC_RANK_ACT_DT,
	JOB_DETL_TITLE,
	JOB_CNTRCT_TYPE_DESC,
	EMPEE_DEPT_CD,
	EMPEE_DEPT_NAME,
	POSN_NBR,
	First_Name,
	Last_Name, 
	Middle_Name, 
	PERS_PREFERRED_FNAME,
	Department_ID, 
	dbo.Get_DM_Department_Name(Department_ID) as DM_Department_Name,
	Appointment_Percent, 
	Campus_Wide_Appointment_Percent, 
	Bus_Person_Manual_Entry_Indicator,
	BUS_Person_Indicator,
	Faculty_Staff_Indicator, 
	Staff_Classification_ID,
	Rank_ID,
	Active_Indicator, Current_Status_Indicator, College_List_Indicator, Department_List_Indicator,
	Gender,
	Birth_Date,
	Ethnicity_ID,
	Citizenship_ID,
	Hired_Date,
	Create_Datetime,
	Last_Update_Datetime,
	Last_EDW_Update_Datetime
FROM Faculty_Staff_Holder.dbo.Facstaff_Basic

-- NS 11/27/2018 : added
-- delete from dbo.FSDB_Web_IDs
UPDATE dbo.FSDB_Web_IDs
SET FACSTAFFID=FSDB.Facstaff_ID, Create_Datetime=GETDATE()
FROM dbo.FSDB_Web_IDs dm, Faculty_Staff_Holder.dbo.Facstaff_basic fsdb
WHERE dm.username=fsdb.Network_ID

INSERT INTO dbo.FSDB_Web_IDs (
	  [USERNAME]
      ,[Attribute]
      ,[Sequence]
      ,[FACSTAFFID]
      ,[Value]
      ,[Preferred_Attribute_Indicator]
      ,[Create_Datetime])
SELECT fsdb.Network_ID
	  ,[Attribute]
      ,[Sequence]
      ,webid.[FACSTAFF_ID]
      ,[Value]
      ,Pereferred_Attribute_Indicator
	  ,GETDATE()
FROM Faculty_Staff_Holder.dbo.Facstaff_Web_IDs webid
		INNER JOIN Faculty_Staff_Holder.dbo.Facstaff_basic fsdb
		ON webid.Facstaff_ID = fsdb.Facstaff_ID
WHERE webid.FACSTAFF_ID not in (SELECT [FACSTAFFID] from dbo.FSDB_Web_IDs )
	and fsdb.Network_ID is not null


-- Go to SSMS' Table design and change Facstaff_ID column to IDENTITY
GO
