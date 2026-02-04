SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 6/8-10/2019: v2, modify fields to track changes
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
-- NS 11/18/2016
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

CREATE PROCEDURE [dbo].[DailyUpdate_sp_DM_Step06_Update_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees]
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

	BEGIN TRY

			DECLARE @debug_username varchar(60)
			SET @debug_username = 'aric'

			DECLARE @jobdate datetime
			SET @jobdate = getdate()

			DECLARE @email_body varchar(4000), @from varchar(500),@to_admin varchar(500) ,@reply_to varchar(500)
				,@email_subject varchar(500), @Header varchar(500)

			SET @from = 'appsmonitor@business.illinois.edu'
			SET @to_admin = 'appsmonitor@business.illinois.edu, nhadi@illinois.edu'
			SET @reply_to = 'appsmonitor@business.illinois.edu'
			SET @email_subject = '[DM] Step-by-Step Activity step 6 as of ' + cast(getdate() as varchar) 

			SET @header = '<HTML><B>[DM] Step By step Process Activity as of ' + cast(getdate() as varchar) + '</B><BR><R>'
					+ 'DailyUpdate_sp_DM_Step06_Update_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees' + '</B><BR><BR>'

			INSERT INTO Database_Maintenance.dbo.Download_Process_Monitor_Logs
					(Table_Name, Copy_Datetime, [Status]) 
			VALUES('FSDB_EDW_Current_Employees 6', @jobdate, 0)

			-- RESET Update_Status in _UPLOAD_DM_BANNER as we want to populate this field with updates categories
			UPDATE DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER SET Update_Status=''


			  DECLARE @Facstaff_ID INTEGER
			  DECLARE @UIN varchar(9)
			  DECLARE @EDWPERSID varchar(9)
			  DECLARE @Network_ID varchar(8)

			  DECLARE @PERS_FNAME varchar(120)
			  DECLARE @PERS_MNAME varchar(120)
			  DECLARE @PERS_LNAME varchar(120)
			  DECLARE @BIRTH_DT datetime
			  DECLARE @SEX_CD varchar(10)
			  DECLARE @RACE_ETH_DESC varchar(60)
			  DECLARE @PERS_CITZN_TYPE_DESC varchar(60)

			  DECLARE @DOC_STATUS varchar(60)
			  DECLARE @DOC_DEPT varchar(60)
			  DECLARE @DOC_TERM varchar(60)

			  DECLARE @CAMPUS_JOB_DETL_FTE decimal(9,0)
			  DECLARE @COLLEGE_JOB_DETL_FTE decimal(9,0)
			  DECLARE @FAC_RANK_DESC  varchar(35)

			  DECLARE @EMPEE_CLS_LONG_DESC varchar(60)
			  DECLARE @STAFF_TYPE varchar(60)
			  DECLARE @USERNAME varchar(60)
	  
			  DECLARE @new_Facstaff_ID INTEGER
			  DECLARE @new_UIN varchar(9)
			  DECLARE @new_EDWPERSID varchar(9)
			  DECLARE @new_Network_ID varchar(8)

			  DECLARE @new_PERS_FNAME varchar(120)
			  DECLARE @new_PERS_MNAME varchar(120)
			  DECLARE @new_PERS_LNAME varchar(120)
			  DECLARE @new_BIRTH_DT datetime
			  DECLARE @new_SEX_CD varchar(10)
			  DECLARE @new_RACE_ETH_DESC varchar(60)
			  DECLARE @new_PERS_CITZN_TYPE_DESC varchar(60)

			  DECLARE @new_DOC_STATUS varchar(60)
			  DECLARE @new_DOC_DEPT varchar(60)
			  DECLARE @new_DOC_TERM varchar(60)

			  DECLARE @new_CAMPUS_JOB_DETL_FTE decimal(9,0)
			  DECLARE @new_COLLEGE_JOB_DETL_FTE decimal(9,0)
			  DECLARE @new_FAC_RANK_DESC  varchar(35)

			  DECLARE @new_EMPEE_CLS_LONG_DESC varchar(60)
			  DECLARE @new_STAFF_TYPE varchar(60)
			  DECLARE @new_USERNAME varchar(60)

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
				SELECT EDWPERSID
					  ,ISNULL(UIN,'') as UIN
					  --,EDW_Database
					  ,ISNULL(PERS_FNAME,'') as PERS_FNAME
					  ,ISNULL(PERS_MNAME,'') as PERS_MNAME
					  ,ISNULL(PERS_LNAME,'') as PERS_LNAME
					  ,BIRTH_DT as BIRTH_DT
					  ,ISNULL(SEX_CD,'') as SEX_CD
					  ,ISNULL(RACE_ETH_DESC,'') as RACE_ETH_DESC
					  ,ISNULL(PERS_CITZN_TYPE_DESC,'') as PERS_CITZN_TYPE_DESC
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

					  ,ISNULL(CAMPUS_JOB_DETL_FTE,0) AS CAMPUS_JOB_DETL_FTE
					  ,ISNULL(COLLEGE_JOB_DETL_FTE,0) as  COLLEGE_JOB_DETL_FTE	
					  ,ISNULL(FAC_RANK_DESC,'') as FAC_RANK_DESC
					  ,ISNULL(USERNAME,'') as USERNAME

				FROM DM_Shadow_Staging.dbo._DM_BANNER 
				WHERE  EDWPERSID is not null AND EDWPERSID <> '' 
				ORDER BY USERNAME


			OPEN curr_banner
			FETCH curr_banner INTO 
					   @EDWPERSID
					  ,@UIN

					  ,@PERS_FNAME
					  ,@PERS_MNAME
					  ,@PERS_LNAME
					  ,@BIRTH_DT
					  ,@SEX_CD
					  ,@RACE_ETH_DESC
					  ,@PERS_CITZN_TYPE_DESC
					  ,@STAFF_TYPE	

					  ,@DOC_STATUS
					  ,@DOC_DEPT

					  ,@CAMPUS_JOB_DETL_FTE
					  ,@COLLEGE_JOB_DETL_FTE
					  ,@FAC_RANK_DESC
			  	
					  ,@USERNAME

			WHILE @@FETCH_STATUS = 0
	
			BEGIN

				-- GET Current (new) data from _UPLOAD_DM_BANNER table

				SELECT @new_EDWPERSID = ISNULL(EDWPERSID,'')
					  ,@new_UIN = ISNULL(UIN,'') 
			  
					  ,@new_PERS_FNAME = ISNULL(PERS_FNAME,'')
					  ,@new_PERS_MNAME = ISNULL(PERS_MNAME,'')
					  ,@new_PERS_LNAME = ISNULL(PERS_LNAME,'')
					  ,@new_BIRTH_DT = BIRTH_DT
					  ,@new_SEX_CD = CASE WHEN SEX_CD IS NULL THEN '' WHEN SEX_CD='M' THEN 'Male' ELSE 'Female' END
					  ,@new_RACE_ETH_DESC = ISNULL(RACE_ETH_DESC,'')
					  ,@new_PERS_CITZN_TYPE_DESC = ISNULL(PERS_CITZN_TYPE_DESC,'')
			 
					  ,@new_DOC_STATUS = CASE WHEN EDW_Database='PRRDOC' THEN 'Current PhD Student' ELSE '' END 
					  ,@new_DOC_DEPT = CASE WHEN EDW_Database='PRRDOC' THEN 
						CASE WHEN EMPEE_DEPT_NAME IS NULL THEN ''
						ELSE EMPEE_DEPT_NAME END 
						ELSE '' END 

					  ,@new_CAMPUS_JOB_DETL_FTE = ISNULL(CAMPUS_JOB_DETL_FTE,0) 
					  ,@new_COLLEGE_JOB_DETL_FTE = ISNULL(COLLEGE_JOB_DETL_FTE,0) 
					  ,@new_FAC_RANK_DESC = ISNULL(FAC_RANK_DESC,'')
			
					  ,@new_Network_ID = ISNULL(banner.Network_ID,'')

			 
					  ,@new_USERNAME = Network_id

				FROM DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER banner			
				WHERE EDWPERSID = @EDWPERSID 		 
		IF @USERNAME=@debug_username 
		BEGIN
				print 'new :' + @new_Network_ID + ':' + @new_EDWPERSID + 
					':' + @new_UIN + ':' + @new_PERS_FNAME + ':' + @new_PERS_MNAME + ':' + @new_PERS_LNAME 
				print ':' + @new_SEX_CD + ':' + @new_RACE_ETH_DESC + ':' + @new_PERS_CITZN_TYPE_DESC + ':' +  CAST(@new_CAMPUS_JOB_DETL_FTE as varchar) +  
					':' + CAST(@new_COLLEGE_JOB_DETL_FTE as varchar) +  ':' + @new_FAC_RANK_DESC 
				print 'current :' + @USERNAME + ':' + @EDWPERSID + 
					':' + @UIN + ':' + @PERS_FNAME + ':' + @PERS_MNAME + ':' + @PERS_LNAME 
				print ':' + @SEX_CD + ':' + @RACE_ETH_DESC + ':' + @PERS_CITZN_TYPE_DESC + ':' + CAST(@CAMPUS_JOB_DETL_FTE as varchar)+  
					':' + CAST(@COLLEGE_JOB_DETL_FTE as varchar) +  ':' + @FAC_RANK_DESC 
				print '---'
		END
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
	
					IF (@new_Network_ID <> @username)
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
	
		

				END --  IF @new_UIN is NOT NULL AND @new_UIN <> ''

				-- RESET all @new_* variables for not holding previous records data
				SET @new_UIN = NULL
				SET @new_Network_ID = NULL
				SET @new_EDWPERSID = NULL 
		
				SET @DOC_STATUS = NULL
				SET @DOC_DEPT = NULL

				SET @new_PERS_FNAME = NULL
				SET @new_PERS_LNAME = NULL
				SET @new_PERS_MNAME =NULL
				SET @new_COLLEGE_JOB_DETL_FTE = NULL 
				SET @new_CAMPUS_JOB_DETL_FTE = NULL 
				SET @new_SEX_CD = NULL
				SET @new_BIRTH_DT = NULL
				SET @new_RACE_ETH_DESC = NULL
				SET @new_PERS_CITZN_TYPE_DESC = NULL

				SET @new_FAC_RANK_DESC = NULL
				SET @new_STAFF_TYPE		= NULL
				SET @new_USERNAME = NULL

				SET @update_BANNER_indicator = ''
				SET @update_dept_indicator = ''
				SET @update_USERNAME_indicator = ''
				SET @update_reentry = ''
		
				--PRINT @EDWPERSID + ': ' +  @last_name + ', ' + @first_name
				FETCH curr_banner INTO  
					   @EDWPERSID
					  ,@UIN

					  ,@PERS_FNAME
					  ,@PERS_MNAME
					  ,@PERS_LNAME
					  ,@BIRTH_DT
					  ,@SEX_CD
					  ,@RACE_ETH_DESC
					  ,@PERS_CITZN_TYPE_DESC
					  ,@STAFF_TYPE	

					  ,@DOC_STATUS
					  ,@DOC_DEPT

					  ,@CAMPUS_JOB_DETL_FTE
					  ,@COLLEGE_JOB_DETL_FTE
					  ,@FAC_RANK_DESC
	
					  ,@USERNAME

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
			  ,Update_Status
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
			  ,Update_Status
			  ,EDW_Database
			  ,getdate()	
			FROM  DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER
			WHERE ( Update_Status LIKE '%U%' OR Record_Status = 'NEW' )
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


		-- >>>>>>>>>>>> Log _DM_BANNER
		insert into DM_Shadow_Staging.dbo._DM_BANNER_Logs ([USERNAME]
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
			  ,[Create_Datetime]
			  ,[Download_Datetime]
			  ,[Log_Datetime])
		  SELECT [USERNAME]
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
			  ,[Create_Datetime]
			  ,[Download_Datetime]
			  ,GETDATE()
		  FROM [DM_Shadow_Staging].[dbo].[_DM_BANNER]

		  -- >>>>>>> Refresh _DM_BANNER
		  truncate table [DM_Shadow_Staging].[dbo]._DM_BANNER
		  insert into [DM_Shadow_Staging].[dbo]._DM_BANNER ([USERNAME]
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
			  ,[Create_Datetime]
			  ,[Download_Datetime])
		  SELECT [USERNAME]
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
			  ,GETDATE()
			  ,[Create_Datetime]
			  ,GETDATE()
		  FROM [DM_Shadow_Staging].[dbo].[_UPLOAD_DM_BANNER]

		-- NS Update Status=2 for job running table='FSDB_EDW_Current_Employees' in the past 15 minutes,
		--		assuming that step 1 through step 6 runs in max 15 minutes (used to run between 5 and 6 minutes, as of November 2017)

		UPDATE	Database_Maintenance.dbo.Download_Process_Monitor_Logs
		SET		Status = 2
		WHERE	Table_Name = 'FSDB_EDW_Current_Employees 6'
			AND	Copy_Datetime = @jobdate

		SET @email_subject =  @email_subject + ' - Success'
		SET @email_body = @header + 'Success<BR><BR>'
		EXEC dbo.DailyUpdate_sp_Send_Email @from,@to_admin,@reply_to,@email_subject, @email_body

	END TRY

	BEGIN CATCH
			SET @email_subject =  @email_subject + ' - Error'
			SET @email_body = @header + ERROR_Message() + '<BR><BR>'
			EXEC dbo.DailyUpdate_sp_Send_Email @from,@to_admin,@reply_to,@email_subject, @email_body
	END CATCH


-- SELECT * FROM DM_Shadow_Staging.dbo._UPLOAD_DM_USERS
GO
