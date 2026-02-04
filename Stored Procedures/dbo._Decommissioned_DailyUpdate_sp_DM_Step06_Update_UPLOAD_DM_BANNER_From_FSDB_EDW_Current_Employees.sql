SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 4/29/2019: Added missing new DOCTORAL records to _UPLOAD_DM_USERS
--
-- PROCESS:
--		1. SET Update_Status at _UPLOAD_DM_BANNER table
--			Set Update_Status to reflect updates on PCI, BANNER, and USERS screens (P, B, and U)
--			Network ID updates will update the USERNAME, this is specially coded with N
--			The values could be combination of P, B, U, and N
--
--		2. Update _UPLOAD_DM_USERS and _UPLOAD_DM_PCI
--			create records in _UPLOAD_DM_PCI when there are new emps; changes in emp termination, names, UIN
--			create records in _UPLOAD_DM_USERS when there are new emps; changes in emp termination, names, UIN
--
--		3. Update _UPLOAD_DM_PCI for AWARDED PHD and NOT AWARDED PHD  
--			create records in _UPLOAD_DM_PCI when there are new emps; changes in emp termination, names, UIN
--			create records in _UPLOAD_DM_USERS when there are new emps; changes in emp termination, names, UIN
--
-- NS 3/25/2019
--		Found out that create and update _DM_UPLOAD_USERS table is done at
--			DailyUpdate_sp_DM_Step06_Update_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees
--
-- NS 3/30/2017: revisited. Created FSDB_EDW_Current_Employees table at DM_Shadow_Staging database functioning
--		as EDW_Current_Employees table in Facukty_Staff_Holder database
--		Renamed _UPLOADED_DM_USERS, _UPLOADED_DM_PCI, _UPLOADED_DM_BANNER, and Web_IDs to
--		_UPLOAD_DM_USERS, _UPLOAD_DM_PCI, _UPLOAD_DM_BANNER, and _UPLOAD_WEB_IDS tables
--
-- NS 11/30/2016: revisited
--		SET  Update_Status at _UPLOAD_DM_BANNER table
--			Set Update_Status to reflect updates on PCI, BANNER, and USERS screens (P, B, and U)
--			Network ID updates will update the USERNAME, this is specially coded with N
--			The values could be combination of P, B, U, and N
--
--		Copy necessary data to _UPLOAD_DM_PCI and _UPLOAD_DM_USERS
--			CREATE RECODRS in _UPLOAD_DM_PCI when there are new emps; changes in emp termination, names, or UIN
--			CREATE RECODRS in _UPLOAD_DM_USERS when there are new emps; changes in emp termination, names, or UIN
-- NS 11/18/2016 v1
--		Newly created for DM
--
-- NS 12/9/2008: Update Rank_ID if the result of
--		dbo.DailyUpdate_fn_Convert_FAC_RANK_CD_TO_RANK_ID(@FAC_RANK_CD) is not null
--		(resulting either full prof, assoc prof, or asst prof)
--		Add column Old_Rank_ID in dbo.FSDB_EDW_Current_Employees
--		Archive past dbo.FSDB_EDW_Current_Employees table into dbo.FSDB_EDW_Current_Employees_Archive_12082008.
--		Create an empty dbo.FSDB_EDW_Current_Employees table
-- NS 3/3/3009: Re-entry case: Some faculty might have got deactivated, the faculty needs to be reactivated 
--		when the faculty is in dbo.FSDB_EDW_Current_Employees
--		Send email for re-entry case
-- NS 12/14/2010 : set College_Directory_Indicator for staff re-entry
-- STC 8/1/16 - send email when a NetID changes

CREATE PROCEDURE [dbo].[_Decommissioned_DailyUpdate_sp_DM_Step06_Update_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees]
AS

--		Codes on dbo.FSDB_EDW_Current_Employees table
--			SEX_CD   F or M
--			College_JOB_DETL_FTE   0-100
--			Campus_JOB_DETL_FTE    0-100
--			FAC_RANK_EMRTS_STATUS_IND  Y or N
--			EMPEE_RET_IND  Y or N
--
--		Codes on _UPLOAD_DM_BANNER
--			SEX_CD   Female or Male
--			College_JOB_DETL_FTE   0-100
--			Campus_JOB_DETL_FTE    0-100
--			FAC_RANK_EMRTS_STATUS_IND  Yes or No
--			EMPEE_RET_IND Yes or No


-- >>>>>>>>>>>>>>>>>>>		1. SET Update_Status at _UPLOAD_DM_BANNER table
--			Set Update_Status to reflect updates on PCI, BANNER, and USERS screens (P, B, and U)
--			Network ID updates will update the USERNAME, this is specially coded with N
--			The values could be combination of P, B, U, and N

	  DECLARE @Facstaff_ID INTEGER
	  DECLARE @UIN varchar(9)
	  DECLARE @EDWPERSID varchar(9)
	  DECLARE @Network_ID varchar(8)
	  DECLARE @PERS_PREFERRED_FNAME varchar(120)
      DECLARE @PERS_FNAME varchar(120)
      DECLARE @PERS_MNAME varchar(120)
      DECLARE @PERS_LNAME varchar(120)
      DECLARE @BIRTH_DT datetime
      DECLARE @SEX_CD varchar(10)
      DECLARE @RACE_ETH_DESC varchar(60)
      DECLARE @PERS_CITZN_TYPE_DESC varchar(60)
      DECLARE @EMPEE_CAMPUS_CD varchar(10)
      DECLARE @EMPEE_CAMPUS_NAME varchar(60)
      DECLARE @EMPEE_COLL_CD varchar(10)
      DECLARE @EMPEE_COLL_NAME varchar(60)
      DECLARE @EMPEE_DEPT_CD varchar(10)
      DECLARE @EMPEE_DEPT_NAME varchar(60)
      DECLARE @JOB_DETL_TITLE varchar(60)
      DECLARE @JOB_DETL_FTE decimal (9,3)
	  DECLARE @JOB_CNTRCT_TYPE_DESC  varchar(30)
	  DECLARE @JOB_DETL_COLL_CD  varchar(10)
	  DECLARE @JOB_DETL_COLL_NAME varchar(60)
	  DECLARE @JOB_DETL_DEPT_CD  varchar(10)
	  DECLARE @JOB_DETL_DEPT_NAME varchar(60)
      DECLARE @COA_CD varchar(10)
      DECLARE @ORG_CD varchar(10)
      DECLARE @EMPEE_ORG_TITLE varchar(100)
      DECLARE @EMPEE_CLS_CD varchar(2)
      DECLARE @EMPEE_CLS_LONG_DESC varchar(30)
      DECLARE @EMPEE_GROUP_CD varchar(4)
      DECLARE @EMPEE_GROUP_DESC varchar(30)
      DECLARE @EMPEE_RET_IND varchar(10)
      DECLARE @EMPEE_LEAVE_CATGRY_CD varchar(10)
      DECLARE @EMPEE_LEAVE_CATGRY_DESC varchar(60)
      DECLARE @BNFT_CATGRY_CD varchar(10)
      DECLARE @BNFT_CATGRY_DESC varchar(60)
      DECLARE @HR_CAMPUS_CD varchar(10)
      DECLARE @HR_CAMPUS_NAME varchar(60)
      DECLARE @EMPEE_STATUS_CD varchar(1)
      DECLARE @EMPEE_STATUS_DESC varchar(30)
      DECLARE @CAMPUS_JOB_DETL_FTE decimal(9,3)
      DECLARE @COLLEGE_JOB_DETL_FTE decimal(9,3)
      DECLARE @FAC_RANK_CD varchar(2)
      DECLARE @FAC_RANK_DESC  varchar(35)
      DECLARE @FAC_RANK_ACT_DT datetime
      DECLARE @FAC_RANK_DECN_DT datetime
      DECLARE @FAC_RANK_ACAD_TITLE  varchar(100)
      DECLARE @FAC_RANK_EMRTS_STATUS_IND  varchar(10)
      DECLARE @FIRST_HIRE_DT datetime	
      DECLARE @CUR_HIRE_DT datetime
      DECLARE @FIRST_WORK_DT datetime
      DECLARE @LAST_WORK_DT datetime
      DECLARE @EMPEE_TERMN_DT datetime

	-- EDW_Current_Employees table variables
	  DECLARE @new_Facstaff_ID INTEGER
	  DECLARE @new_UIN varchar(9)
	  DECLARE @new_EDWPERSID varchar(9)
	  DECLARE @new_Network_ID varchar(8)
	  DECLARE @new_PERS_PREFERRED_FNAME varchar(120)
      DECLARE @new_PERS_FNAME varchar(120)
      DECLARE @new_PERS_MNAME varchar(120)
      DECLARE @new_PERS_LNAME varchar(120)
      DECLARE @new_BIRTH_DT datetime
      DECLARE @new_SEX_CD varchar(10)
      DECLARE @new_RACE_ETH_DESC varchar(60)
      DECLARE @new_PERS_CITZN_TYPE_DESC varchar(60)
      DECLARE @new_EMPEE_CAMPUS_CD varchar(10)
      DECLARE @new_EMPEE_CAMPUS_NAME varchar(60)
      DECLARE @new_EMPEE_COLL_CD varchar(10)
      DECLARE @new_EMPEE_COLL_NAME varchar(60)
      DECLARE @new_EMPEE_DEPT_CD varchar(10)
      DECLARE @new_EMPEE_DEPT_NAME varchar(60)
      DECLARE @new_JOB_DETL_TITLE varchar(60)
      DECLARE @new_JOB_DETL_FTE decimal (9,3)
	  DECLARE @new_JOB_CNTRCT_TYPE_DESC  varchar(30)
	  DECLARE @new_JOB_DETL_COLL_CD  varchar(10)
	  DECLARE @new_JOB_DETL_COLL_NAME varchar(60)
	  DECLARE @new_JOB_DETL_DEPT_CD  varchar(10)
	  DECLARE @new_JOB_DETL_DEPT_NAME varchar(60)
      DECLARE @new_COA_CD varchar(10)
      DECLARE @new_ORG_CD varchar(10)
      DECLARE @new_EMPEE_ORG_TITLE varchar(100)
      DECLARE @new_EMPEE_CLS_CD varchar(2)
      DECLARE @new_EMPEE_CLS_LONG_DESC varchar(30)
      DECLARE @new_EMPEE_GROUP_CD varchar(4)
      DECLARE @new_EMPEE_GROUP_DESC varchar(30)
      DECLARE @new_EMPEE_RET_IND varchar(10)
      DECLARE @new_EMPEE_LEAVE_CATGRY_CD varchar(10)
      DECLARE @new_EMPEE_LEAVE_CATGRY_DESC varchar(60)
      DECLARE @new_BNFT_CATGRY_CD varchar(10)
      DECLARE @new_BNFT_CATGRY_DESC varchar(60)
      DECLARE @new_HR_CAMPUS_CD varchar(10)
      DECLARE @new_HR_CAMPUS_NAME varchar(60)
      DECLARE @new_EMPEE_STATUS_CD varchar(1)
      DECLARE @new_EMPEE_STATUS_DESC varchar(30)
      DECLARE @new_CAMPUS_JOB_DETL_FTE decimal(9,3)
      DECLARE @new_COLLEGE_JOB_DETL_FTE decimal(9,3)
      DECLARE @new_FAC_RANK_CD varchar(2)
      DECLARE @new_FAC_RANK_DESC  varchar(35)
      DECLARE @new_FAC_RANK_ACT_DT datetime
      DECLARE @new_FAC_RANK_DECN_DT datetime
      DECLARE @new_FAC_RANK_ACAD_TITLE  varchar(100)
      DECLARE @new_FAC_RANK_EMRTS_STATUS_IND  varchar(10)
      DECLARE @new_FIRST_HIRE_DT datetime	
      DECLARE @new_CUR_HIRE_DT datetime
      DECLARE @new_FIRST_WORK_DT datetime
      DECLARE @new_LAST_WORK_DT datetime
      DECLARE @new_EMPEE_TERMN_DT datetime
	  DECLARE @New_Rank_ID integer

	  DECLARE @update_USERS_indicator varchar(1)
	  DECLARE @update_PCI_indicator varchar(1)
	  DECLARE @update_BANNER_indicator varchar(1)
	  DECLARE @update_USERNAME_indicator varchar(1)	-- USERNAME has changed
	  DECLARE @Update_Status varchar(10)			-- identify which screen(s) to update

	  DECLARE @update_dept_indicator varchar(1)	  
	  DECLARE @update_reentry varchar(1)
	  DECLARE @print_str varchar(100)
      DECLARE @print_str2 varchar(100)
	  DECLARE @msg_body varchar(7000)		-- Alert about changing primary job 
										-- 1) from non 952 (College of Business) department to  952 (College of Business) department				IF @update_dept_indicator = 'B'
										-- 2) from a department to a department other than 952 (College of Business) department
	  DECLARE @msg_body2 varchar(7000)	-- Alert for faculty re-entry
	  DECLARE @msg_body4 varchar(7000)	-- Alert for NetID update
	  	  
	  SET @update_USERS_indicator=''
	  SET @update_PCI_indicator=''
	  SET @update_BANNER_indicator = ''
	  SET @update_USERNAME_indicator = ''

	  SET @update_dept_indicator = ''
	  SET @update_reentry = ''

	  DECLARE curr_banner CURSOR READ_ONLY FOR
		SELECT --USERNAME
			  --,ID
			  --,FACSTAFFID
			   EDWPERSID
			  ,ISNULL(UIN,'') as UIN
			  --,EDW_Database
			  ,ISNULL(PERS_PREFERRED_FNAME,'') as PERS_PREFERRED_FNAME
			  ,ISNULL(PERS_FNAME,'') as PERS_FNAME
			  ,ISNULL(PERS_MNAME,'') as PERS_MNAME
			  ,ISNULL(PERS_LNAME,'') as PERS_LNAME
			  ,BIRTH_DT
			  ,ISNULL(SEX_CD,'') as SEX_CD
			  ,ISNULL(RACE_ETH_DESC,'') as RACE_ETH_DESC
			  ,ISNULL(PERS_CITZN_TYPE_DESC,'') as PERS_CITZN_TYPE_DESC

			  ,ISNULL(EMPEE_CAMPUS_CD,'') as EMPEE_CAMPUS_CD
			  ,ISNULL(EMPEE_CAMPUS_NAME,'') as EMPEE_CAMPUS_NAME
			  ,ISNULL(EMPEE_COLL_CD,'') as EMPEE_COLL_CD
			  ,ISNULL(EMPEE_COLL_NAME,'') as EMPEE_COLL_NAME
			  ,ISNULL(EMPEE_DEPT_CD,'') as EMPEE_DEPT_CD
			  ,ISNULL(EMPEE_DEPT_NAME,'') as EMPEE_DEPT_NAME
			  ,ISNULL(JOB_DETL_TITLE,'') as JOB_DETL_TITLE
			  ,ISNULL(JOB_DETL_FTE,0) as JOB_DETL_FTE
			  ,ISNULL(JOB_CNTRCT_TYPE_DESC,'') as JOB_CNTRCT_TYPE_DESC
			  ,ISNULL(JOB_DETL_COLL_CD,'') as JOB_DETL_COLL_CD

			  ,ISNULL(JOB_DETL_COLL_NAME,'') as JOB_DETL_COLL_NAME
			  ,ISNULL(COA_CD,'') as COA_CD
			  ,ISNULL(ORG_CD,'') as ORG_CD
			  ,ISNULL(EMPEE_ORG_TITLE,'') as EMPEE_ORG_TITLE
			  ,ISNULL(EMPEE_CLS_CD,'') as EMPEE_CLS_CD
			  ,ISNULL(EMPEE_CLS_LONG_DESC,'') as EMPEE_CLS_LONG_DESC
			  ,ISNULL(EMPEE_GROUP_CD,'') as EMPEE_GROUP_CD
			  ,ISNULL(EMPEE_GROUP_DESC,'') as EMPEE_GROUP_DESC
			  ,ISNULL(EMPEE_RET_IND,'') as EMPEE_RET_IND
			  ,ISNULL(EMPEE_LEAVE_CATGRY_CD,'') as EMPEE_LEAVE_CATGRY_CD

			  ,ISNULL(EMPEE_LEAVE_CATGRY_DESC,'') as EMPEE_LEAVE_CATGRY_DESC
			  ,ISNULL(BNFT_CATGRY_CD,'') as BNFT_CATGRY_CD
			  ,ISNULL(BNFT_CATGRY_DESC,'') as BNFT_CATGRY_DESC
			  ,ISNULL(HR_CAMPUS_CD,'') as HR_CAMPUS_CD
			  ,ISNULL(HR_CAMPUS_NAME,'') as HR_CAMPUS_NAME
			  ,ISNULL(EMPEE_STATUS_CD,'') as EMPEE_STATUS_CD
			  ,ISNULL(EMPEE_STATUS_DESC,'') asEMPEE_STATUS_DESC

			  ,ISNULL(CAMPUS_JOB_DETL_FTE,0) AS CAMPUS_JOB_DETL_FTE
			  ,ISNULL(COLLEGE_JOB_DETL_FTE,0) as  COLLEGE_JOB_DETL_FTE
			  ,ISNULL(FAC_RANK_CD,'') as FAC_RANK_CD

			  ,ISNULL(FAC_RANK_DESC,'') as FAC_RANK_DESC
			  ,FAC_RANK_ACT_DT
			  ,FAC_RANK_DECN_DT
			  ,ISNULL(FAC_RANK_ACAD_TITLE,'') as FAC_RANK_ACAD_TITLE
			  ,ISNULL(FAC_RANK_EMRTS_STATUS_IND,'') asFAC_RANK_EMRTS_STATUS_IND
			  ,FIRST_HIRE_DT
			  ,CUR_HIRE_DT
			  ,FIRST_WORK_DT
			  ,LAST_WORK_DT
			  ,EMPEE_TERMN_DT
			  ,ISNULL(USERNAME,'') as USERNAME
			  --,Record_Status
			  --,Create_Datetime
			  --,Last_Update_Datetime
		FROM DM_Shadow_Staging.dbo._DM_BANNER
		WHERE  EDWPERSID is not null AND EDWPERSID <> ''
		ORDER BY EDWPERSID


	OPEN curr_banner
	FETCH curr_banner INTO -- @USERNAME
			  --,ID
			  --,FACSTAFFID
			   @EDWPERSID
			  ,@UIN
			  --,EDW_Database
			  ,@PERS_PREFERRED_FNAME
			  ,@PERS_FNAME
			  ,@PERS_MNAME
			  ,@PERS_LNAME
			  ,@BIRTH_DT
			  ,@SEX_CD
			  ,@RACE_ETH_DESC
			  ,@PERS_CITZN_TYPE_DESC

			  ,@EMPEE_CAMPUS_CD
			  ,@EMPEE_CAMPUS_NAME
			  ,@EMPEE_COLL_CD
			  ,@EMPEE_COLL_NAME
			  ,@EMPEE_DEPT_CD
			  ,@EMPEE_DEPT_NAME
			  ,@JOB_DETL_TITLE
			  ,@JOB_DETL_FTE
			  ,@JOB_CNTRCT_TYPE_DESC
			  ,@JOB_DETL_COLL_CD

			  ,@JOB_DETL_COLL_NAME
			  ,@COA_CD
			  ,@ORG_CD
			  ,@EMPEE_ORG_TITLE
			  ,@EMPEE_CLS_CD
			  ,@EMPEE_CLS_LONG_DESC
			  ,@EMPEE_GROUP_CD
			  ,@EMPEE_GROUP_DESC
			  ,@EMPEE_RET_IND
			  ,@EMPEE_LEAVE_CATGRY_CD

			  ,@EMPEE_LEAVE_CATGRY_DESC
			  ,@BNFT_CATGRY_CD
			  ,@BNFT_CATGRY_DESC
			  ,@HR_CAMPUS_CD
			  ,@HR_CAMPUS_NAME
			  ,@EMPEE_STATUS_CD
			  ,@EMPEE_STATUS_DESC
			  ,@CAMPUS_JOB_DETL_FTE
			  ,@COLLEGE_JOB_DETL_FTE			  
			  ,@FAC_RANK_CD

			  ,@FAC_RANK_DESC
			  ,@FAC_RANK_ACT_DT
			  ,@FAC_RANK_DECN_DT
			  ,@FAC_RANK_ACAD_TITLE
			  ,@FAC_RANK_EMRTS_STATUS_IND
			  ,@FIRST_HIRE_DT
			  ,@CUR_HIRE_DT
			  ,@FIRST_WORK_DT
			  ,@LAST_WORK_DT
			  ,@EMPEE_TERMN_DT

			  ,@Network_ID
			  --,@Record_Status
			  --,@Create_Datetime
			  --,@Last_Update_Datetime

	WHILE @@FETCH_STATUS = 0
	
	BEGIN

		-- GET Current (new) data from _UPLOAD_DM_USERS table
		SELECT --@new_USERNAME = Network_id
			   @new_EDWPERSID = ISNULL(EDWPERSID,'')
			  ,@new_UIN = ISNULL(UIN,'') 
			  --,@new_EDW_Database
			  ,@new_PERS_PREFERRED_FNAME = ISNULL(PERS_PREFERRED_FNAME,'')
			  ,@new_PERS_FNAME = ISNULL(PERS_FNAME,'')
			  ,@new_PERS_MNAME = ISNULL(PERS_MNAME,'')
			  ,@new_PERS_LNAME = ISNULL(PERS_LNAME,'')
			  ,@new_BIRTH_DT = BIRTH_DT
			  ,@new_SEX_CD = CASE WHEN SEX_CD IS NULL THEN '' WHEN SEX_CD='M' THEN 'Male' ELSE 'Female' END
			  ,@new_RACE_ETH_DESC = ISNULL(RACE_ETH_DESC,'')
			  ,@new_PERS_CITZN_TYPE_DESC = ISNULL(PERS_CITZN_TYPE_DESC,'')
			  ,@new_EMPEE_CAMPUS_CD = ISNULL(EMPEE_CAMPUS_CD,'')
			  ,@new_EMPEE_CAMPUS_NAME = ISNULL(EMPEE_CAMPUS_NAME,'')
			  ,@new_EMPEE_COLL_CD = ISNULL(EMPEE_COLL_CD,'')
			  ,@new_EMPEE_COLL_NAME = ISNULL(EMPEE_COLL_NAME,'')
			  ,@new_EMPEE_DEPT_CD = ISNULL(EMPEE_DEPT_CD,'')
			  ,@new_EMPEE_DEPT_NAME = ISNULL(EMPEE_DEPT_NAME,'')
			  ,@new_JOB_DETL_TITLE = ISNULL(JOB_DETL_TITLE,'')
			  ,@new_JOB_DETL_FTE = ISNULL(JOB_DETL_FTE,0)
			  ,@new_JOB_CNTRCT_TYPE_DESC = ISNULL(JOB_CNTRCT_TYPE_DESC,'')
			  ,@new_JOB_DETL_COLL_CD = ISNULL(JOB_DETL_COLL_CD,'')
			  ,@new_JOB_DETL_COLL_NAME = ISNULL(JOB_DETL_COLL_NAME,'')
			  ,@new_COA_CD = ISNULL(COA_CD,'')
			  ,@new_ORG_CD = ISNULL(ORG_CD,'')
			  ,@new_EMPEE_ORG_TITLE = ISNULL(EMPEE_ORG_TITLE,'')
			  ,@new_EMPEE_CLS_CD = ISNULL(EMPEE_CLS_CD,'')
			  ,@new_EMPEE_CLS_LONG_DESC = ISNULL(EMPEE_CLS_LONG_DESC,'')
			  ,@new_EMPEE_GROUP_CD = ISNULL(EMPEE_GROUP_CD,'')
			  ,@new_EMPEE_GROUP_DESC = ISNULL(EMPEE_GROUP_DESC,'')
			  ,@new_EMPEE_RET_IND = ISNULL(EMPEE_RET_IND,'')
			  ,@new_EMPEE_LEAVE_CATGRY_CD = ISNULL(EMPEE_LEAVE_CATGRY_CD,'')
			  ,@new_EMPEE_LEAVE_CATGRY_DESC = ISNULL(EMPEE_LEAVE_CATGRY_DESC,'')
			  ,@new_BNFT_CATGRY_CD = ISNULL(BNFT_CATGRY_CD,'')
			  ,@new_BNFT_CATGRY_DESC = ISNULL(BNFT_CATGRY_DESC,'')
			  ,@new_HR_CAMPUS_CD = ISNULL(HR_CAMPUS_CD,'')
			  ,@new_HR_CAMPUS_NAME = ISNULL(HR_CAMPUS_NAME,'')
			  ,@new_EMPEE_STATUS_CD = ISNULL(EMPEE_STATUS_CD,'')
			  ,@new_EMPEE_STATUS_DESC = ISNULL(EMPEE_STATUS_DESC,'')
			  ,@new_CAMPUS_JOB_DETL_FTE = ISNULL(CAMPUS_JOB_DETL_FTE,0) 
			  ,@new_COLLEGE_JOB_DETL_FTE = ISNULL(COLLEGE_JOB_DETL_FTE,0) 
			  ,@new_FAC_RANK_CD = ISNULL(FAC_RANK_CD,'')
			  ,@new_FAC_RANK_DESC = ISNULL(FAC_RANK_DESC,'')
			  ,@new_FAC_RANK_ACT_DT = FAC_RANK_ACT_DT
			  ,@new_FAC_RANK_DECN_DT = FAC_RANK_DECN_DT
			  ,@new_FAC_RANK_ACAD_TITLE = ISNULL(FAC_RANK_ACAD_TITLE,'')
			  ,@new_FAC_RANK_EMRTS_STATUS_IND =  CASE WHEN FAC_RANK_EMRTS_STATUS_IND IS NULL THEN '' WHEN FAC_RANK_EMRTS_STATUS_IND='Y' THEN 'Yes' ELSE 'No' END
			  ,@new_FIRST_HIRE_DT = FIRST_HIRE_DT
			  ,@new_CUR_HIRE_DT = CUR_HIRE_DT
			  ,@new_FIRST_WORK_DT = FIRST_WORK_DT
			  ,@new_LAST_WORK_DT = LAST_WORK_DT
			  ,@new_EMPEE_TERMN_DT = EMPEE_TERMN_DT
			  ,@new_Network_ID = ISNULL(Network_ID,'')
			  --,@Record_Status
			  --,@Create_Datetime
			  --,@Last_Update_Datetime
		FROM DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
		WHERE EDWPERSID = @EDWPERSID 		 

		IF @new_UIN <> ''
		BEGIN
			
			SET @update_BANNER_indicator = ''

			IF (@new_UIN <> @UIN)
			BEGIN			   
			    --UPDATE  DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			    --SET UIN = @new_UIN
			    --WHERE EDWPERSID = @EDWPERSID	 
			    SET @update_BANNER_indicator = 'U'  
				SET @update_USERS_indicator = 'U'  
			END
	
			IF (@new_Network_ID <> @Network_ID)
			BEGIN
			   
			    --UPDATE  DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			    --SET Network_ID = @new_Network_ID, USERNAME = @new_Network_ID
			    --WHERE EDWPERSID = @EDWPERSID	     
			    SET @update_BANNER_indicator = 'U'    
			    SET @update_USERNAME_indicator = 'U'
				SET @update_USERS_indicator = 'U'
			END
	
			IF @new_SEX_CD <> @SEX_CD
			BEGIN			  
			    --UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			    --SET PERS_PREFERRED_FNAME = @new_PERS_PREFERRED_FNAME
			    --WHERE EDWPERSID = @EDWPERSID	     
			    SET @update_BANNER_indicator = 'U'    
				--SET @update_USERS_indicator = 'U'
				SET @update_PCI_indicator = 'U'
			END
	

			IF @new_PERS_PREFERRED_FNAME <> @PERS_PREFERRED_FNAME
			BEGIN			  
			    --UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			    --SET PERS_PREFERRED_FNAME = @new_PERS_PREFERRED_FNAME
			    --WHERE EDWPERSID = @EDWPERSID	     
			    SET @update_BANNER_indicator = 'U'    
				--SET @update_USERS_indicator = 'U'
				SET @update_PCI_indicator = 'U'
			END

			IF @new_PERS_FNAME <> @PERS_FNAME
			BEGIN			  
			    --UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			    --SET PERS_FNAME = @new_PERS_FNAME
			    --WHERE EDWPERSID = @EDWPERSID	     
			    SET @update_BANNER_indicator = 'U'  
				SET @update_USERS_indicator = 'U'
				SET @update_PCI_indicator = 'U'  
			END
	
			IF  @new_PERS_LNAME <> @PERS_LNAME
			BEGIN
	
			    --UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			    --SET PERS_LNAME = @new_PERS_LNAME
			    --WHERE EDWPERSID = @EDWPERSID	     
			    SET @update_BANNER_indicator = 'U'    
				SET @update_USERS_indicator = 'U'
				SET @update_PCI_indicator = 'U' 
--print @new_pers_fname + ' ' + @new_pers_lname + '(' + @last_name + ')'
			END
	
			IF  @new_PERS_MNAME <> @PERS_MNAME
			BEGIN
			  
			    --UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			    --SET PERS_MNAME = @new_PERS_MNAME
			    --WHERE EDWPERSID = @EDWPERSID	    
			    SET @update_BANNER_indicator = 'U'  
				SET @update_USERS_indicator = 'U'
				SET @update_PCI_indicator = 'U'    
			END


	
			IF (@BIRTH_DT is NULL and @new_BIRTH_DT is not null) OR (@new_BIRTH_DT is not null and @new_BIRTH_DT <> @BIRTH_DT)
			BEGIN			
			    --UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			    --SET BIRTH_DT = @new_BIRTH_DT
			    --WHERE EDWPERSID = @EDWPERSID	  
			    SET @update_BANNER_indicator = 'U' 
				SET @update_PCI_indicator = 'U'      
			END
	
			IF @new_SEX_CD <> @SEX_CD
			BEGIN		   
			    UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			    SET SEX_CD = @new_SEX_CD
			    WHERE EDWPERSID = @EDWPERSID	     
			    SET @update_BANNER_indicator = 'U' 
				SET @update_PCI_indicator = 'U'      
			END

			IF @new_RACE_ETH_DESC <> @RACE_ETH_DESC
			BEGIN
			  
			    UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			    SET RACE_ETH_DESC = @new_RACE_ETH_DESC
			    WHERE EDWPERSID = @EDWPERSID	     
			    SET @update_BANNER_indicator = 'U' 
				SET @update_PCI_indicator = 'U'      
			END
	
			IF  @new_PERS_CITZN_TYPE_DESC <> @PERS_CITZN_TYPE_DESC
			BEGIN

			    UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			    SET PERS_CITZN_TYPE_DESC = @new_PERS_CITZN_TYPE_DESC
			    WHERE EDWPERSID = @EDWPERSID	
			    SET @update_BANNER_indicator = 'U'  
				SET @update_PCI_indicator = 'U'          
			END


			-- No need to check COLL_CD and CAMPUS_CD when DEPT_CD is checked
			SET @update_dept_indicator = ''

		
			IF (@new_EMPEE_DEPT_CD <> @EMPEE_DEPT_CD)
				OR (@EMPEE_DEPT_NAME <> @new_EMPEE_DEPT_NAME)
			BEGIN
				
			    IF  @new_EMPEE_DEPT_CD = '952' AND @EMPEE_DEPT_CD <> @new_EMPEE_DEPT_CD
					BEGIN
					   -- New EDW dept is College of Business from non College of Business
					   -- Must send an email notifying that there is a EDW update to College of Business and hence 
			   		   -- FSDB Department_ID has been set to NULL
					   /*
					   SET @update_dept_indicator = 'U'
					   */
					   SET @update_dept_indicator = 'A'
					END

			    IF  @new_EMPEE_DEPT_CD <> '952' AND @EMPEE_DEPT_CD <> @new_EMPEE_DEPT_CD 
					-- AND @New_Department_ID is not NULL
					BEGIN
						-- New EDW dept is not College of Business, we can change the Department_ID
						SET @update_dept_indicator = 'B'
					END

				--UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
				--SET EMPEE_DEPT_CD = @new_EMPEE_DEPT_CD,
				--	EMPEE_DEPT_NAME = @new_EMPEE_DEPT_NAME,
				--	EMPEE_COLL_CD = @new_EMPEE_COLL_CD,
				--	EMPEE_COLL_NAME = @new_EMPEE_COLL_NAME,
				--	EMPEE_CAMPUS_CD = @new_EMPEE_CAMPUS_CD,
				--	EMPEE_CAMPUS_NAME = @new_EMPEE_CAMPUS_NAME,
				--	EMPEE_ORG_TITLE = @new_EMPEE_ORG_TITLE
				--	--Department_ID = @New_Department_ID
				--WHERE EDWPERSID = @EDWPERSID					

			    SET @update_BANNER_indicator = 'U'    
	
			END

			IF (@JOB_DETL_TITLE is NULL and @new_JOB_DETL_TITLE is not null) 
					OR (@new_JOB_DETL_TITLE is not null and @new_JOB_DETL_TITLE <> '' and @new_JOB_DETL_TITLE <> @JOB_DETL_TITLE)
			BEGIN
			   
			    UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			    SET JOB_DETL_TITLE = @new_JOB_DETL_TITLE
			    WHERE EDWPERSID = @EDWPERSID	     
			    SET @update_BANNER_indicator = 'U'    
			END

			IF (@JOB_DETL_FTE is NULL and @new_JOB_DETL_FTE is not null) 
					OR (@new_JOB_DETL_FTE is not null  and @new_JOB_DETL_FTE <> @JOB_DETL_FTE)
			BEGIN
			   
			    UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			    SET JOB_DETL_FTE = @new_JOB_DETL_FTE
			    WHERE EDWPERSID = @EDWPERSID	     
			    SET @update_BANNER_indicator = 'U'    
			END

			-- DDD1
			IF (@JOB_CNTRCT_TYPE_DESC is NULL and @new_JOB_CNTRCT_TYPE_DESC is not null) 
					OR (@new_JOB_CNTRCT_TYPE_DESC is not null and @new_JOB_CNTRCT_TYPE_DESC <> '' and @new_JOB_CNTRCT_TYPE_DESC <> @JOB_CNTRCT_TYPE_DESC)
			BEGIN
			   
			    UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			    SET JOB_CNTRCT_TYPE_DESC = @new_JOB_CNTRCT_TYPE_DESC
			    WHERE EDWPERSID = @EDWPERSID	     
			    SET @update_BANNER_indicator = 'U'    
			END


			IF (@JOB_DETL_DEPT_NAME <> @new_JOB_DETL_DEPT_NAME) 
				OR (@new_JOB_DETL_DEPT_CD <> @JOB_DETL_DEPT_CD)
			BEGIN
				
			    IF  @new_JOB_DETL_DEPT_CD = '952' AND @JOB_DETL_DEPT_CD <> @new_JOB_DETL_DEPT_CD
					BEGIN
					   -- New EDW dept is College of Business from non College of Business
					   -- Must send an email notifying that there is a EDW update to College of Business and hence 
			   		   -- FSDB Department_ID has been set to NULL
					   /*
					   SET @update_dept_indicator = 'U'
					   */
					   SET @update_dept_indicator = 'A'
					END

			    IF  @new_JOB_DETL_DEPT_CD <> '952' AND @JOB_DETL_DEPT_CD <> @new_JOB_DETL_DEPT_CD 
					-- AND @New_Department_ID is not NULL
					BEGIN
						-- New EDW dept is not College of Business, we can change the Department_ID
						SET @update_dept_indicator = 'B'
					END

				-- NS 11/30/2016: NEED TO REVISIT
				--UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
				--SET JOB_DETL_DEPT_CD = @new_JOB_DETL_DEPT_CD,
				--	JOB_DETL_DEPT_NAME = @new_JOB_DETL_DEPT_NAME,
				--	JOB_DETL_COLL_CD = @new_JOB_DETL_COLL_CD,
				--	JOB_DETL_COLL_NAME = @new_JOB_DETL_COLL_NAME
				--	--Department_ID = @New_Department_ID
				--WHERE EDWPERSID = @EDWPERSID					

			    SET @update_BANNER_indicator = 'U'    
	
			END
	
		
			IF @new_COA_CD <> @COA_CD
			BEGIN
			   
			    --UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			    --SET COA_CD = @new_COA_CD
			    --WHERE EDWPERSID = @EDWPERSID	     
			    SET @update_BANNER_indicator = 'U'    
			END

			IF @new_ORG_CD <> @ORG_CD
			BEGIN
			   
			    --UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			    --SET ORG_CD = @new_ORG_CD
			    --WHERE EDWPERSID = @EDWPERSID	     
			    SET @update_BANNER_indicator = 'U'    
			END

			IF @new_EMPEE_GROUP_CD <> @EMPEE_GROUP_CD
			BEGIN
			   
			  --  UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			  --  SET EMPEE_GROUP_CD = @new_EMPEE_GROUP_CD,
					--EMPEE_GROUP_DESC = @new_EMPEE_GROUP_DESC
			  --  WHERE EDWPERSID = @EDWPERSID	     
			    SET @update_BANNER_indicator = 'U'    
			END
				
			IF @new_EMPEE_CLS_CD <> @EMPEE_CLS_CD
			BEGIN
			  
			  --  UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			  --  SET EMPEE_CLS_CD = @new_EMPEE_CLS_CD,
					--EMPEE_CLS_LONG_DESC = @new_EMPEE_CLS_LONG_DESC
			  --  WHERE EDWPERSID = @EDWPERSID	     
			    SET @update_BANNER_indicator = 'U'    
			END

			IF @new_EMPEE_LEAVE_CATGRY_CD <> @EMPEE_LEAVE_CATGRY_CD
			BEGIN
			   
			  --  UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			  --  SET EMPEE_LEAVE_CATGRY_CD = @new_EMPEE_LEAVE_CATGRY_CD,
					--EMPEE_LEAVE_CATGRY_DESC = @new_EMPEE_LEAVE_CATGRY_DESC
			  --  WHERE EDWPERSID = @EDWPERSID	     
			    SET @update_BANNER_indicator = 'U'    
			END

			IF  @new_BNFT_CATGRY_CD <> @BNFT_CATGRY_CD
			BEGIN
			   
			  --  UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			  --  SET BNFT_CATGRY_CD = @new_BNFT_CATGRY_CD,
					--BNFT_CATGRY_DESC = @new_BNFT_CATGRY_DESC
			  --  WHERE EDWPERSID = @EDWPERSID	     
			    SET @update_BANNER_indicator = 'U'    
			END

			IF  @new_HR_CAMPUS_CD <> @HR_CAMPUS_CD
			BEGIN		   
			  --  UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			  --  SET HR_CAMPUS_CD = @new_HR_CAMPUS_CD,
					--HR_CAMPUS_NAME = @new_HR_CAMPUS_NAME
			  --  WHERE EDWPERSID = @EDWPERSID	     
			    SET @update_BANNER_indicator = 'U'    
			END

			IF  @new_EMPEE_STATUS_CD <> @EMPEE_STATUS_CD
			BEGIN		   
			  --  UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			  --  SET EMPEE_STATUS_CD = @new_EMPEE_STATUS_CD,
					--EMPEE_STATUS_DESC = @new_EMPEE_STATUS_DESC
			  --  WHERE EDWPERSID = @EDWPERSID	     
			    SET @update_BANNER_indicator = 'U'    
			END

			IF @new_COLLEGE_JOB_DETL_FTE <> @COLLEGE_JOB_DETL_FTE
			BEGIN			 	
			    --UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			    --SET COLLEGE_JOB_DETL_FTE = @new_COLLEGE_JOB_DETL_FTE
			    --WHERE EDWPERSID = @EDWPERSID	     
			    SET @update_BANNER_indicator = 'U'    
			END

			IF @new_CAMPUS_JOB_DETL_FTE <> @CAMPUS_JOB_DETL_FTE
			BEGIN				
			    --UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			    --SET CAMPUS_JOB_DETL_FTE = @new_CAMPUS_JOB_DETL_FTE
			    --WHERE EDWPERSID = @EDWPERSID	     
			    SET @update_BANNER_indicator = 'U'    
			END

			IF @FAC_RANK_EMRTS_STATUS_IND <> @new_FAC_RANK_EMRTS_STATUS_IND
			BEGIN			  	
				--IF @new_FAC_RANK_EMRTS_STATUS_IND = 'Y'
				--	UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
				--	SET FAC_RANK_EMRTS_STATUS_IND = 'Yes'
				--	WHERE EDWPERSID = @EDWPERSID
				--ELSE
				--	UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
				--	SET FAC_RANK_EMRTS_STATUS_IND = 'No'
				--	WHERE EDWPERSID = @EDWPERSID	 
				
				-- >>>>>>>>>>>>>>> Q:WHERE IS RANK_ID in DM?

				SET @New_Rank_ID = 8
				SET @update_BANNER_indicator = 'U'    

				--IF @New_Rank_ID is not NULL
				--	BEGIN
				--		UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_PCI
				--		SET RANK_ID = @New_Rank_ID
				--		WHERE EDWPERSID = @EDWPERSID	     
				--	END
				--END
			END

			IF @EMPEE_RET_IND <> @new_EMPEE_RET_IND
			BEGIN			  	
				--IF @new_EMPEE_RET_IND = 'Y'
				--	UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
				--	SET EMPEE_RET_IND = 'Yes'
				--	WHERE EDWPERSID = @EDWPERSID
				--ELSE
				--	UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
				--	SET EMPEE_RET_IND = 'No'
				--	WHERE EDWPERSID = @EDWPERSID	 
				
				SET @update_BANNER_indicator = 'U'   
			END

	
			IF  @new_FAC_RANK_CD <> @FAC_RANK_CD
			BEGIN
			 
			 --   UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
				--SET FAC_RANK_CD = @new_FAC_RANK_CD,
				--	FAC_RANK_DESC = @new_FAC_RANK_DESC,
				--	FAC_RANK_DECN_DT = @new_FAC_RANK_DECN_DT,
				--	FAC_RANK_ACT_DT = @new_FAC_RANK_ACT_DT,
				--	FAC_RANK_ACAD_TITLE = @new_FAC_RANK_ACAD_TITLE
			 --   WHERE EDWPERSID = @EDWPERSID	     
			    SET @update_BANNER_indicator = 'U'    		

				-- Refresh Rank_ID from EDW if the EDW has prof/assoc/asst prof rank data
				-- NS 12/1/2016 Need to set Rank_ID at _UPLOAD_DM_PCI (PCI screen)

				SET @New_Rank_ID = dbo.DailyUpdate_fn_Convert_FAC_RANK_CD_TO_RANK_ID(@new_FAC_RANK_CD)
			
				--IF @New_Rank_ID is not NULL
				--	BEGIN
				--		UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_PCI
				--		SET RANK_ID = @New_Rank_ID
				--		WHERE EDWPERSID = @EDWPERSID	     
				--	END
				--END

			
			END
	
			-- STC 4/10/09 - Removed JOB_DETL_TITLE from POSN_NBR update and created separate check to update JOB_DETL_TITLE
			--IF (@POSN_NBR is NULL and @new_POSN_NBR is not null) OR ( @new_POSN_NBR is not null and @new_POSN_NBR <> '' 
			--	and @new_POSN_NBR <> @POSN_NBR )
			--BEGIN
			--    UPDATE dbo.FSDB_EDW_Current_Employees
			--    SET FSDB_Old_POSN_NBR = @POSN_NBR
			--    WHERE EDWPERSID = @EDWPERSID AND New_Download_Indicator = 1
	
			--    UPDATE Facstaff_Basic
			--    SET POSN_NBR = @new_POSN_NBR
			--    WHERE EDW_PERS_ID = @EDWPERSID	     
			--    SET @update_BANNER_indicator = 'U'    
			--END
		
	
			IF @new_FIRST_HIRE_DT <> @FIRST_HIRE_DT
			BEGIN			   
			    --UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			    --SET FIRST_HIRE_DT = @new_FIRST_HIRE_DT
			    --WHERE EDWPERSID = @EDWPERSID	     
			    SET @update_BANNER_indicator = 'U'    
			END

			IF  @new_CUR_HIRE_DT <> @CUR_HIRE_DT
			BEGIN			   
			    --UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			    --SET CUR_HIRE_DT = @new_CUR_HIRE_DT
			    --WHERE EDWPERSID = @EDWPERSID	     
			    SET @update_BANNER_indicator = 'U'    
			END

			IF  @new_FIRST_WORK_DT <> @FIRST_WORK_DT
			BEGIN			   
			    --UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			    --SET FIRST_WORK_DT = @new_FIRST_WORK_DT
			    --WHERE EDWPERSID = @EDWPERSID	     
			    SET @update_BANNER_indicator = 'U'    
			END

			SET @Update_Status = ''
			
			IF @update_BANNER_indicator = 'U'
				SET @Update_Status = @Update_Status + 'B'

			IF @update_PCI_indicator = 'U'
				SET @Update_Status = @Update_Status + 'P'

			IF @update_USERNAME_indicator = 'U'
				SET @Update_Status = @Update_Status + 'N'

			IF @update_USERS_indicator = 'U'
				SET @Update_Status = @Update_Status + 'U'
				
			UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			SET Update_Status = @Update_Status
			WHERE EDWPERSID = @EDWPERSID	
	
			--IF @update_reentry = 'U'
			--      BEGIN
			--			SET @msg_body2 = @msg_body2 + '<BR><BR>Faculty Re-entry:<br>'				
			--      END
			--IF @update_dept_indicator <> ''
			--      BEGIN
			--			IF @update_dept_indicator = 'A'
			--				SET @msg_body = @msg_body + '<BR><BR>Employee changes Primary Job EDW department from non 952 (non-College of Business) department to  952 (College of Business) department:<br>'
			--			IF @update_dept_indicator = 'B'
			--				SET @msg_body = @msg_body + '<BR><BR>Employee changes Primary Job department to a department other than 952 (College of Business) department:<br>'
			--	  END

			---- STC 8/1/16 - send email when a NetID changes
			--IF @update_USERNAME_indicator <> ''
			--      BEGIN
			--	    SET @msg_body4 = ''
			--      END


		END --  IF @new_UIN is NOT NULL AND @new_UIN <> ''

		-- RESET all @new_* variables for not holding previous records data
		SET @new_UIN = NULL
		SET @new_Network_ID = NULL
		SET @new_EDWPERSID = NULL 
		SET @new_JOB_DETL_DEPT_CD = NULL 
		SET @new_JOB_DETL_DEPT_NAME = NULL
		SET @new_JOB_DETL_FTE = NULL
		SET @new_EMPEE_GROUP_CD= NULL
		SET @new_EMPEE_GROUP_DESC = NULL 
		SET @new_EMPEE_CLS_CD = NULL
		SET @new_EMPEE_CLS_LONG_DESC = NULL		
		SET @new_FAC_RANK_CD = NULL
		SET @new_FAC_RANK_DESC = NULL
		SET @new_FAC_RANK_DECN_DT = NULL
		SET @new_FAC_RANK_EMRTS_STATUS_IND = NULL
		SET @new_FAC_RANK_ACT_DT = NULL
		SET @new_JOB_DETL_TITLE = NULL
		SET @new_JOB_CNTRCT_TYPE_DESC = NULL
		SET @new_EMPEE_DEPT_CD =NULL
		SET @new_EMPEE_DEPT_NAME = NULL
		SET @new_PERS_FNAME = NULL
		SET @new_PERS_LNAME = NULL
		SET @new_PERS_MNAME =NULL
		SET @new_COLLEGE_JOB_DETL_FTE = NULL 
		SET @new_CAMPUS_JOB_DETL_FTE = NULL 
		SET @new_SEX_CD = NULL
		SET @new_BIRTH_DT = NULL
		SET @new_RACE_ETH_DESC = NULL
		SET @new_FIRST_HIRE_DT = NULL

		SET @update_BANNER_indicator = ''
		SET @update_dept_indicator = ''
		SET @update_USERNAME_indicator = ''
		SET @update_reentry = ''
		
		--PRINT @EDWPERSID + ': ' +  @last_name + ', ' + @first_name
		FETCH curr_banner INTO -- @USERNAME
			  --,ID
			  --,FACSTAFFID
			  @EDWPERSID
			  ,@UIN
			  --,EDW_Database
			  ,@PERS_PREFERRED_FNAME
			  ,@PERS_FNAME
			  ,@PERS_MNAME
			  ,@PERS_LNAME
			  ,@BIRTH_DT
			  ,@SEX_CD
			  ,@RACE_ETH_DESC
			  ,@PERS_CITZN_TYPE_DESC
			  ,@EMPEE_CAMPUS_CD
			  ,@EMPEE_CAMPUS_NAME
			  ,@EMPEE_COLL_CD
			  ,@EMPEE_COLL_NAME
			  ,@EMPEE_DEPT_CD
			  ,@EMPEE_DEPT_NAME
			  ,@JOB_DETL_TITLE
			  ,@JOB_DETL_FTE
			  ,@JOB_CNTRCT_TYPE_DESC
			  ,@JOB_DETL_COLL_CD
			  ,@JOB_DETL_COLL_NAME
			  ,@COA_CD
			  ,@ORG_CD
			  ,@EMPEE_ORG_TITLE
			  ,@EMPEE_CLS_CD
			  ,@EMPEE_CLS_LONG_DESC
			  ,@EMPEE_GROUP_CD
			  ,@EMPEE_GROUP_DESC
			  ,@EMPEE_RET_IND
			  ,@EMPEE_LEAVE_CATGRY_CD
			  ,@EMPEE_LEAVE_CATGRY_DESC
			  ,@BNFT_CATGRY_CD
			  ,@BNFT_CATGRY_DESC
			  ,@HR_CAMPUS_CD
			  ,@HR_CAMPUS_NAME
			  ,@EMPEE_STATUS_CD
			  ,@EMPEE_STATUS_DESC
			  ,@CAMPUS_JOB_DETL_FTE
			  ,@COLLEGE_JOB_DETL_FTE
			  ,@FAC_RANK_CD
			  ,@FAC_RANK_DESC
			  ,@FAC_RANK_ACT_DT
			  ,@FAC_RANK_DECN_DT
			  ,@FAC_RANK_ACAD_TITLE
			  ,@FAC_RANK_EMRTS_STATUS_IND
			  ,@FIRST_HIRE_DT
			  ,@CUR_HIRE_DT
			  ,@FIRST_WORK_DT
			  ,@LAST_WORK_DT
			  ,@EMPEE_TERMN_DT
			  ,@Network_ID
			  --,@Record_Status
			  --,@Create_Datetime
			  --,@Last_Update_Datetime

	END

	DEALLOCATE curr_banner


	


-- >>>>>>>>>>>>>>>>>>>> 	2. Create _UPLOAD_DM_Web_Ids, _DM_UPLOAD_USERS, _DM_UPLOAD_PCI
--			create records in _UPLOAD_DM_PCI when there are new emps; changes in emp termination, names, UIN
--			create records in _UPLOAD_DM_USERS when there are new emps; changes in emp termination, names, UIN, Network_ID


	EXEC dbo.DailyUpdate_sp_DM_Step06sub_Populate_FSDB_Web_ids_Table

	TRUNCATE TABLE DM_Shadow_Staging.dbo._UPLOAD_DM_USERS

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
      ,Update_Datetime)
	SELECT   distinct username
      --,userid
      ,FacstaffID
      ,EDWPERSID
      ,UIN
      ,PERS_FNAME
      ,PERS_MNAME
      ,PERS_LNAME
      ,dbo.DailyUpdate_fn_Get_DM_Department_Name_By_Banner_Dept_CD(EMPEE_DEPT_CD) as DEP
      ,username + '@illinois.edu'
      ,1
      ,Record_Status
	  ,EDW_Database
	  ,getdate()	
	FROM  DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
	WHERE ( Update_Status = '%U%' OR Record_Status = 'NEW' )
		AND ( (EMPEE_GROUP_CD in ('A','B','C','E','P','T','U') OR EMPEE_CLS_CD IN ('HA'))
				OR EDW_Database = 'PRRDOC')
	order by username asc


	TRUNCATE TABLE DM_Shadow_Staging.dbo._UPLOAD_DM_PCI

	INSERT INTO DM_Shadow_Staging.dbo._UPLOAD_DM_PCI(
	  --userid
	  --   ,ID
      --   ,surveyID
      --   ,termID
      FACSTAFFID
      ,EDWPERSID
      ,USERNAME

      ,FNAME
      ,MNAME
      ,LNAME
      ,PFNAME
      ,PMNAME
      ,PLNAME
      ,EMAIL

      ,DTM_DOB
      ,DTD_DOB
      ,DTY_DOB
      ,DOB_START
      ,DOB_END

      ,GENDER
      ,ETHNICITY
      ,CITIZEN
      ,Profile_URL
	  ,[RANK]
      ,STAFF_CLASS
      ,DOC_STATUS
      ,DOC_DEPT
      ,DOC_TERM
      ,BUS_PERSON
      ,BUS_FACULTY
      ,Record_Status
      ,Update_Datetime)
	SELECT   
      DISTINCT FACSTAFFID
      ,EDWPERSID
      ,USERNAME

      ,PERS_FNAME
      ,PERS_MNAME
      ,PERS_LNAME
      ,PERS_PREFERRED_FNAME
      ,PERS_MNAME
      ,PERS_LNAME
      ,USERNAME + '@illinois.edu'

	  ,CASE WHEN BIRTH_DT is NULL THEN ''
	   ELSE DATENAME(month,BIRTH_DT) END  as DTM_DOB
	  ,ISNULL(CONVERT(VARCHAR(4),DATEPART(DAY, BIRTH_DT)),'')  as DTD_DOB
	  ,ISNULL(CONVERT(VARCHAR(4),DATEPART(YEAR, BIRTH_DT)),'') as DTY_DOB
	  ,CONVERT(varchar(12), BIRTH_DT,111) as DOB_START
	  ,CONVERT(varchar(12), BIRTH_DT,111) as DOB_END

	  ,SEX_CD
	  --,CASE SEX_CD when 'M' THEN 'Male' WHEN 'F' THEN 'Female' ELSE '' END as GENDER ====> Sex_CD has already had "Female"/"Male" value insteaf of F/M values
	  ,RACE_ETH_DESC as ETHNICITY
	  ,PERS_CITZN_TYPE_DESC as  CITIZEN	 -- No need to submit this since we will have it at the BANNER screen
	  ,dbo.Get_Profile_URL(username) as Profile_URL	
	  ,CASE WHEN FAC_RANK_DESC IS NULL THEN ''
			ELSE FAC_RANK_DESC END AS [RANK]
	  ,CASE WHEN EMPEE_GROUP_CD = 'H' THEN 'Academic Hourly & Grad Hourly'
		    WHEN EMPEE_GROUP_CD = 'B' THEN 'Academic Professional'
		    WHEN EMPEE_GROUP_CD = 'C' THEN 'Civil Service - Department'
			WHEN EMPEE_GROUP_CD = 'E' THEN 'Civil Service - Extra Help'
			WHEN EMPEE_GROUP_CD = 'G' THEN 'Academic ProfessionalGraduate Assistant/Pre Doc Fellows'
			WHEN EMPEE_GROUP_CD = 'P' THEN 'Post Doc Fellows, Res Assoc, Interns'
			WHEN EMPEE_GROUP_CD = 'T' THEN 'Retiree/Annuitant'
			WHEN EMPEE_GROUP_CD = 'U' THEN 'Unpaid'
			WHEN EMPEE_GROUP_CD = 'S' THEN 'Undergraduate Hourly'	-- this group is not supposed to be uploaded
			ELSE 'N/A' END AS STAFF_CLASS

	  ,CASE WHEN EDW_Database='PRRDOC' THEN 'Current PhD Student'
			ELSE '' END AS DOC_STATUS
	  ,CASE WHEN EDW_Database='PRRDOC' THEN 
				CASE WHEN EMPEE_DEPT_NAME IS NULL THEN ''
				ELSE EMPEE_DEPT_NAME END 
			ELSE '' END AS DOC_DEPT
      ,'' as DOC_TERM
      ,'Yes' as BUS_PERSON
      ,CASE WHEN EMPEE_GROUP_CD='A' THEN 'Yes' ELSE 'No' END as BUS_FACULTY
      ,Record_Status
	  ,getdate()
FROM  DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
WHERE Update_Status = '%P%'
			OR Record_Status = 'NEW'
order by username;


-- >>>>>>>>>>>>>>>>>>>>  3. Update _UPLOAD_DM_PCI for AWARDED PHD and NOT AWARDED PHD
--			create records in _UPLOAD_DM_PCI when there are new emps; changes in emp termination, names, UIN
--			create records in _UPLOAD_DM_USERS when there are new emps; changes in emp termination, names, UIN


WITH awardrecords AS
(
	--SELECT rta.edw_pers_id, 
	--		rta.pers_lname, rta.pers_fname, rta.pers_mname, 
	--		deg.grad_term_cd, deg.grad_term_desc, deg.grad_acad_yr_desc, 
	--		deg.deg_dept_name, deg.deg_acad_pgm_name, deg.deg_cd, deg.deg_name,
	--		year(deg.grad_dt) grad_year
	--FROM Decision_Support.dbo.edw_v_pers_hist_rta_dir rta 
	--	INNER JOIN Decision_Support.dbo.edw_t_student_ah_deg_hist deg
	--	ON rta.edw_pers_id = deg.edw_pers_id  and 
	--		rta.pers_cur_info_ind = 'y'
	SELECT DISTINCT deg.EDW_PERS_ID
			,deg.grad_term_cd, deg.grad_term_desc, deg.grad_acad_yr_desc
			,deg.deg_dept_name, deg.deg_acad_pgm_name
			,year(deg.grad_dt) grad_year
			
	FROM Decision_Support.dbo.edw_t_student_ah_deg_hist deg
	WHERE 	deg.deg_level_cd = '1G'
		AND deg.deg_cd = 'PHD'
		AND deg.admin_coll_cd = 'ks' 
		AND deg.coll_cd='km'
		AND deg.deg_status_cd = 'aw' 	
		AND NOT EXISTS (
			SELECT *
			FROM  dbo._UPLOAD_DM_PCI upci 
			WHERE  upci.EDWPERSID = deg.EDW_PERS_ID 
			)
		--and not ( deg.deg_ACAD_PGM_name like '%econ%' )
)

-- LIST OF newly Awarded PHD
INSERT INTO DM_Shadow_Staging.dbo._UPLOAD_DM_PCI(
      FACSTAFFID,EDWPERSID,USERNAME
      ,FNAME,MNAME,LNAME
      ,DOC_STATUS,DOC_DEPT,DOC_TERM
	  ,Record_Status
	  ,Update_Datetime
)
SELECT DISTINCT pci.FACSTAFFID,pci.EDWPERSID,pci.USERNAME
	,pci.FNAME,pci.MNAME,pci.LNAME
	,'Awarded PhD', deg.DEG_DEPT_NAME,DBO.Get_Term_Fullname(deg.GRAD_TERM_CD)
	,'CUR'
	, getdate()
FROM awardrecords deg
	INNER JOIN dbo._DM_PCI pci 
	ON  pci.EDWPERSID = deg.EDW_PERS_ID 
		AND ISNULL(pci.DOC_DEPT,'') <> ''
		AND ISNULL(pci.DOC_TERM,'') = ''

-- LIST OF newly NOT Awarded PHD

INSERT INTO DM_Shadow_Staging.dbo._UPLOAD_DM_PCI(
      FACSTAFFID,EDWPERSID,USERNAME
      ,FNAME,MNAME,LNAME
      ,DOC_STATUS,DOC_TERM
	  ,Record_Status
	  ,Update_Datetime
)
SELECT  DISTINCT pci1.FACSTAFFID,pci1.EDWPERSID,pci1.USERNAME
	,pci1.FNAME,pci1.MNAME,pci1.LNAME
	,'Not Awarded PhD', ''
	,'CUR'
	,getdate()
FROM _DM_PCI pci1 
WHERE pci1.DOC_STATUS='Current PhD Student'
		AND NOT EXISTS (
			SELECT *
			FROM _UPLOAD_DM_PCI pci2
			WHERE pci1.EDWPERSID = pci2.EDWPERSID
					AND pci2.DOC_STATUS in ('Current PhD Student','Awarded PhD') 
		)

-- NS Update Status=2 for job running table='FSDB_EDW_Current_Employees' in the past 15 minutes,
--		assuming that step 1 through step 6 runs in max 15 minutes (used to run between 5 and 6 minutes, as of November 2017)
DECLARE @jobdate as datetime
SET @jobdate = dateadd(minute,-15,getdate())
UPDATE  Database_Maintenance.dbo.Download_Process_Monitor_Logs
SET		Status = 2
WHERE	Table_Name = 'FSDB_EDW_Current_Employees'
	AND	Copy_Datetime >= @jobdate


-- SELECT * FROM DM_Shadow_Staging.dbo._UPLOAD_DM_USERS
GO
