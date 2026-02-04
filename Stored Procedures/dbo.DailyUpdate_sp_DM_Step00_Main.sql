SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 4/17/2019 latest revision 
-- NS 4/26/2017
-- NS 11/15/2016 
/*

	Before we start the OFFICIAL launch, i.e. we need to prepare DM's FSDB related tables from FSDB,
	once we do this we can start daily process and all Facstaff_ID will start from the last one created at FSDB,
	FSDB can cease to exist.

	1. Run this SP Adhoc_sp__Transition_FSDB_to_DM
	2. Start the daily job, from this time on FSDB'Facstaff_Basic and 
		DM's FSDB_Facstaff_basuc may have different Facstaff_ID on their new records


	Daily process at 7 AM

	1.  dbo.DailyUpdate_sp_DM_Step01_Get_Current_College_Of_Business_Employees_From_EDW	(approx 5 minutes)
	    dbo.DailyUpdate_sp_DM_Step02_Get_Current_College_Of_Business_Doctoral_Students_From_EDW (approx 20 seconds)
		
			Download BANNER all COB emps (Faculty, AP, Civil, hourly/including students), BEL and PhD students to _UPLOAD_EDW_Current_Employees
			Each download will set old data to have new_download_indicator = 0, DM_Upload_Done_Indicator = 1
				and new data to have new_download_indicator = 1, DM_Upload_Done_Indicator = 0			
			Create_Datetime is also set for each download
	
	2. dbo.EXEC dbo.DailyUpdate_sp_DM_Step03_Update_Add_and_Terminate_Employees_at_FSDB_Facstaff_Basic

			INSERT new employees into FSDB_Facstaff_Basic in order to get FACSTAFF_ID and set Active_Indicator=1
			DEACTIVATE employees that already left COB,
				When those terminated employees are found, then do the following when the count is <= @EMP_Deletion_Threshold
				1) add to FSDB_Facstaff_Basic_Deactivated table, and set Update_Status = 'END-NEW'
				2) update to FSDB_Facstaff_Basic, set Active_Indicator=0 and find their respective Leaving_Date
				3) insert into dbo._UPLOAD_DM_BANNER with Record_Status='END-EMPS'
				4) send email to the admins list of terminated persons
			Otherwise send email to the admins about the hold up of termination
			
	3. EXEC dbo.DailyUpdate_sp_DM_Step04_New_Employees_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees
	   EXEC dbo.DailyUpdate_sp_DM_Step05_New_Employees_BEL_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees

	 		Select group A B H C E G S T U P under COB college, BEL (not under COB), exclude class HG SA GA and copy data to _UPLOAD_DM_BANNER. 
			This basically copy all records except student workers (Grads assistant, grad hourly, student hourly)
				1. Get Primary Jobs, except student workers
					Mark _UPLOAD_EDW_Current_Employees.Update_Employee_Indicator = 'DM-PRIMARY'
					Insert into _UPLOAD_DM_BANNER table
					Mark _UPLOAD_EDW_Current_Employees.DM_Upload_Done_Indicator=1
				2. Get Secondary Jobs, except student workers
					Mark _UPLOAD_EDW_Current_Employees.Update_Employee_Indicator = 'DM-SECOND'
					Insert into _UPLOAD_DM_BANNER table
					Mark _UPLOAD_EDW_Current_Employees.DM_Upload_Done_Indicator=1
				3. Get Doctoral students
					Mark _UPLOAD_EDW_Current_Employees.Update_Employee_Indicator = 'DOCTORAL'
					Insert into _UPLOAD_DM_BANNER table
					Mark _UPLOAD_EDW_Current_Employees.DM_Upload_Done_Indicator=1
				4. Get Primary Jobs in BEL, except student workers
					Mark _UPLOAD_EDW_Current_Employees.Update_Employee_Indicator = 'DM-BEL'
					Insert into _UPLOAD_DM_BANNER table
					Mark _UPLOAD_EDW_Current_Employees.DM_Upload_Done_Indicator=1
				5. Find out new and current emps, and mark them
					_UPLOAD_DM_BANNER.Record_Status = 'NEW-EMPS'  or 
					_UPLOAD_DM_BANNER.Record_Status = 'CURR-EMPS' 

	4. dbo.DailyUpdate_sp_DM_Step06_Update_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees

			SET Update_Status at _UPLOAD_DM_BANNER table
			Set Update_Status to reflect updates on PCI, BANNER, and USERS screens (P, B, and U)
			Special code for Network ID updates is N since the change in Network ID updates the USERNAME as one of the 2 main identifiers in DM
				(DM person identifier is USERID and USERNAME)
			The Update_Status values could be a combination of P, B, U, and N

	5. dbo.DailyUpdate_sp_DM_Step07_Produce_XML_Readying_Upload
			Execute to consume from/upload to DM Aebservices


	RELATED TABLES
		EDW_T_EMPEE_PERS
		EDW_V_EMPEE_PERS_HIST_1
		EDW_V_EMPEE_HIST_1
		EDW_T_JOB
		EDW_T_JOB_HIST
		EDW_T_JOB_DETL
		EDW_V_JOB_DETL_HIST_1
		EDW_T_POSN
		EDW_T_POSN_HIST

*/




CREATE PROCEDURE [dbo].[DailyUpdate_sp_DM_Step00_Main]
AS

	EXEC dbo.DailyUpdate_sp_DM_Step01_Get_Current_College_Of_Business_Employees_From_EDW			-- bout 4 minutes
	EXEC dbo.DailyUpdate_sp_DM_Step02_Get_Current_College_Of_Business_Doctoral_Students_From_EDW

	EXEC dbo.DailyUpdate_sp_DM_Step03_Update_Add_and_Terminate_Employees_at_FSDB_Facstaff_Basic

	EXEC dbo.DailyUpdate_sp_DM_Step04_New_Employees_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees
	EXEC dbo.DailyUpdate_sp_DM_Step05_New_Employees_BEL_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees

	EXEC dbo.DailyUpdate_sp_DM_Step06_Update_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees
	
	EXEC dbo.DailyUpdate_sp_DM_Step07_Produce_XML_Readying_Upload

	EXEC dbo.DailyUpdate_sp_DM_Step08_Send_Email_Notification

	EXEC dbo.DailyUpdate_sp_DM_Step19_Shadow_DM_ADMIN
	/*		
			EXEC dbo.produce_XML_USERS_deactivate @submit = 1
			EXEC dbo.produce_XML_USERS_add_update @submit = 1
			EXEC dbo.webservices2_run @Result = @Result OUTPUT
	

			EXEC dbo.webservices_initiate @screen='USERS'
			EXEC dbo.webservices_initiate @screen='ADMIN'
			EXEC dbo.webservices_initiate @screen='PCI'

			WAITFOR DELAY '00:00:03'
			EXEC dbo.webservices2_run  @Result = @Result OUTPUT

			EXEC dbo.produce_XML_PCI_New @submit = 1
			EXEC dbo.produce_XML_ADMIN_PCI_USER_Update @submit = 1

	*/
	--EXEC dbo.DailyUpdate_sp_DM_Step09_Reset_UPLOAD_DM_BANNER_copy_to_DM_BANNER
	
GO
