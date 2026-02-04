SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 12/2/2021
--	Added CONTACT
-- NS 12/3/2019
--	Needed for all AD, DSLIST and web apps related data source/reference

CREATE PROC [dbo].[DailyUpdate_sp_DM_Step19_Shadow_DM_ADMIN_CONTACT]

AS

	BEGIN TRY

		DECLARE @jobdate datetime, @step_name varchar(200)
		SET @jobdate = getdate()

		DECLARE @email_body varchar(4000), @from varchar(500),@to_admin varchar(500) ,@reply_to varchar(500)
			,@email_subject varchar(500), @Header varchar(500)

		SET @from = 'appsmonitor@business.illinois.edu'
		SET @to_admin = 'appsmonitor@business.illinois.edu, nhadi@illinois.edu'
		SET @reply_to = 'appsmonitor@business.illinois.edu'
		SET @email_subject = '[DM] Step-by-Step Activity step 19 as of ' + cast(getdate() as varchar) 

		SET @header = '<HTML><B>[DM] Step By step Process Activity as of ' + cast(getdate() as varchar) + '</B><BR><R>'
					+ 'DailyUpdate_sp_DM_Step19_Shadow_DM_ADMIN' + '</B><BR><BR>'

		INSERT INTO Database_Maintenance.dbo.Download_Process_Monitor_Logs
					(Table_Name, Copy_Datetime, [Status]) 
		VALUES('FSDB_EDW_Current_Employees 19', @jobdate, 0)

		DECLARE @Result varchar(500)

		-- DOWNLOAD ADMIN screen
		SET @step_name = 'dbo.webservices_initiate  @screen=''ADMIN'''
		EXEC dbo.webservices_initiate @screen='ADMIN'
		SET @step_name = 'dbo.webservices2_run @Result = @Result OUTPUT'

		EXEC dbo.webservices2_run @Result = @Result OUTPUT


		-- DOWNLOAD CONTACT screen
		SET @step_name = 'dbo.webservices_initiate  @screen=''CONTACT'''
		EXEC dbo.webservices_initiate @screen='CONTACT'
		SET @step_name = 'dbo.webservices2_run @Result = @Result OUTPUT'

		EXEC dbo.webservices2_run @Result = @Result OUTPUT


		-- DOWNLOAD PCI 
		--SET @step_name = 'dbo.webservices_initiate  @screen=''PCI'''

		--EXEC dbo.webservices_initiate @screen='PCI'

		--SET @step_name = 'dbo.webservices2_run @Result = @Result OUTPUT'

		--EXEC dbo.webservices2_run @Result = @Result OUTPUT



		UPDATE	Database_Maintenance.dbo.Download_Process_Monitor_Logs
		SET		Status = 2
		WHERE	Table_Name = 'FSDB_EDW_Current_Employees 19'
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
	

				
GO
