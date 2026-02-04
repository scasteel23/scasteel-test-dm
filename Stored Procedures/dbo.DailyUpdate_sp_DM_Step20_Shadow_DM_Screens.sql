SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 1/18/2019 Updated
-- NS 3/19/2018
--	Shadow/download all DM screens into _DM_* table in DM_Shadow_Staging database

CREATE PROC [dbo].[DailyUpdate_sp_DM_Step20_Shadow_DM_Screens]

AS

	BEGIN TRY

		DECLARE @jobdate datetime, @step_name varchar(200)
		SET @jobdate = getdate()

		DECLARE @email_body varchar(4000), @from varchar(500),@to_admin varchar(500) ,@reply_to varchar(500)
			,@email_subject varchar(500), @Header varchar(500)

		SET @from = 'appsmonitor@business.illinois.edu'
		SET @to_admin = 'appsmonitor@business.illinois.edu, nhadi@illinois.edu'
		SET @reply_to = 'appsmonitor@business.illinois.edu'
		SET @email_subject = '[DM] Step-by-Step Activity step 20 as of ' + cast(getdate() as varchar) 

		SET @header = '<HTML><B>[DM] Step By step Process Activity as of ' + cast(getdate() as varchar) + '</B><BR><R>'
					+ 'DailyUpdate_sp_DM_Step20_Shadow_DM_Screens' + '</B><BR><BR>'

		INSERT INTO Database_Maintenance.dbo.Download_Process_Monitor_Logs
					(Table_Name, Copy_Datetime, [Status]) 
		VALUES('FSDB_EDW_Current_Employees 20', @jobdate, 0)

		-- 01
		SET @step_name = 'dbo.webservices_initiate  @screen=''USERS'''

		EXEC dbo.webservices_initiate @screen='USERS'	
		EXEC dbo.webservices_run_DTSX

		-- 02
		SET @step_name = 'dbo.webservices_initiate  @screen=''PCI'''

		EXEC dbo.webservices_initiate @screen='PCI'	
		EXEC dbo.webservices_run_DTSX

		-- 03
		SET @step_name = 'dbo.webservices_initiate  @screen=''ADMIN'''

		EXEC dbo.webservices_initiate @screen='ADMIN'	-- 
		EXEC dbo.webservices_run_DTSX

		-- 04
		SET @step_name = 'dbo.webservices_initiate  @screen=''AWARDHONOR'''

		EXEC dbo.webservices_initiate @screen='AWARDHONOR'	--
		EXEC dbo.webservices_run_DTSX

		--EXEC dbo.webservices_initiate @screen='BANNER'		-- NOT YET as of 1/18/2019
		--EXEC dbo.webservices_run_DTSX

		-- 05
		SET @step_name = 'dbo.webservices_initiate  @screen=''CONGRANT'''

		EXEC dbo.webservices_initiate @screen='CONGRANT'		--						 
		EXEC dbo.webservices_run_DTSX

		-- 06
		SET @step_name = 'dbo.webservices_initiate  @screen=''CONTACT'''

		EXEC dbo.webservices_initiate @screen='CONTACT'	--
		EXEC dbo.webservices_run_DTSX

		-- 07
		SET @step_name = 'dbo.webservices_initiate  @screen=''CURRICULUM'''

		EXEC dbo.webservices_initiate @screen='CURRICULUM'	 -- 
		EXEC dbo.webservices_run_DTSX

		-- 08
		SET @step_name = 'dbo.webservices_initiate  @screen=''DEG_COMMITTEE'''

		EXEC dbo.webservices_initiate @screen='DEG_COMMITTEE'
		EXEC dbo.webservices_run_DTSX

		-- 09
		SET @step_name = 'dbo.webservices_initiate  @screen=''DSL'''

		EXEC dbo.webservices_initiate @screen='DSL'   
		EXEC dbo.webservices_run_DTSX

		-- 10
		SET @step_name = 'dbo.webservices_initiate  @screen=''EDUCATION'''

		EXEC dbo.webservices_initiate @screen='EDUCATION'				 
		EXEC dbo.webservices_run_DTSX

		-- 11
		SET @step_name = 'dbo.webservices_initiate  @screen=''FACDEV'''

		EXEC dbo.webservices_initiate @screen='FACDEV'	
		EXEC dbo.webservices_run_DTSX
	 
		-- 12
		SET @step_name = 'dbo.webservices_initiate  @screen=''INTELLCONT'''

		EXEC dbo.webservices_initiate @screen='INTELLCONT'	
		EXEC dbo.webservices_run_DTSX

		-- 13
		SET @step_name = 'dbo.webservices_initiate  @screen=''LICCERT'''

		EXEC dbo.webservices_initiate @screen='LICCERT'
		EXEC dbo.webservices_run_DTSX
	 
		-- 14
		SET @step_name = 'dbo.webservices_initiate  @screen=''MEDCONT'''

		EXEC dbo.webservices_initiate @screen='MEDCONT'					
		EXEC dbo.webservices_run_DTSX

		-- 15
		SET @step_name = 'dbo.webservices_initiate  @screen=''MEMBER'''

		EXEC dbo.webservices_initiate @screen='MEMBER'					
		EXEC dbo.webservices_run_DTSX
	 
		-- 16
		SET @step_name = 'dbo.webservices_initiate  @screen=''NCTEACH'''

		EXEC dbo.webservices_initiate @screen='NCTEACH'					
		EXEC dbo.webservices_run_DTSX
 
		-- 17
		SET @step_name = 'dbo.webservices_initiate  @screen=''PASTHIST'''

		EXEC dbo.webservices_initiate @screen='PASTHIST'
		EXEC dbo.webservices_run_DTSX

		-- 18
		SET @step_name = 'dbo.webservices_initiate  @screen=''PRESENT'''

		EXEC dbo.webservices_initiate @screen='PRESENT'
		EXEC dbo.webservices_run_DTSX

		-- 19
		SET @step_name = 'dbo.webservices_initiate  @screen=''PROFILE'''

		EXEC dbo.webservices_initiate @screen='PROFILE'	
		EXEC dbo.webservices_run_DTSX
	  
		-- 20
		SET @step_name = 'dbo.webservices_initiate  @screen=''RESPROG'''

		EXEC dbo.webservices_initiate @screen='RESPROG'
		EXEC dbo.webservices_run_DTSX

		--EXEC dbo.webservices_initiate @screen='SCHTEACH'		-- NS 1/22/2019 No need to download
		--EXEC dbo.webservices_run_DTSX
	 	
		-- 21
		SET @step_name = 'dbo.webservices_initiate  @screen=''SERVICE_ACADEMIC'''

		EXEC dbo.webservices_initiate @screen='SERVICE_ACADEMIC'		
		EXEC dbo.webservices_run_DTSX
	 
		-- 22
		SET @step_name = 'dbo.webservices_initiate  @screen=''SERVICE_COMMITTEE'''

		EXEC dbo.webservices_initiate @screen='SERVICE_COMMITTEE'		
		EXEC dbo.webservices_run_DTSX
	 	
		-- 23
		SET @step_name = 'dbo.webservices_initiate  @screen=''SERVICE_PROFESSIONAL'''

		EXEC dbo.webservices_initiate @screen='SERVICE_PROFESSIONAL'	
		EXEC dbo.webservices_run_DTSX

		-- 24
		SET @step_name = 'dbo.webservices_initiate  @screen=''SERVICE_PUBLIC'''

		EXEC dbo.webservices_initiate @screen='SERVICE_PUBLIC'	
		EXEC dbo.webservices_run_DTSX
	 
		UPDATE	Database_Maintenance.dbo.Download_Process_Monitor_Logs
		SET		Status = 2
		WHERE	Table_Name = 'FSDB_EDW_Current_Employees 20'
			AND	Copy_Datetime = @jobdate

		SET @email_subject =  @email_subject + ' - Success'
		SET @email_body = @header + 'Success<BR><BR>'
		EXEC dbo.DailyUpdate_sp_Send_Email @from,@to_admin,@reply_to,@email_subject, @email_body

	END TRY

	BEgIN CATCH

			SET @email_subject =  @email_subject + ' - Error'
			SET @email_body = @header +  '<BR><BR>' + @step_name + '<BR><BR>'
					+ ERROR_Message() + '<BR><BR>'
			EXEC dbo.DailyUpdate_sp_Send_Email @from,@to_admin,@reply_to,@email_subject, @email_body

	END CATCH
	 -- To shadow/download records of specific user in related tables
	 -- EXEC dbo.webservices_initiate @username='rashad'  -- PCI, bio, consulting, honor, pub, edu, facdev, member
														-- service ACO, service pro, svc committee
	 -- EXEC dbo.webservices_run_DTSX


				
GO
