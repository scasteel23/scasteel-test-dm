SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 4/29/2019: streamlined all SP calls correctly
-- NS 4/15/2019: prevented anyone with ADMIN:KEEP_ACTIVE=No to re-add to DM (should keep USER:enabled=true and PCI:SHOW_COLLEGE=No)
-- NS 4/4/2019:  replaced webservices_run_DTSX with webservices2_run
-- NS 3/12/2019: revisited
-- NS 11/3/2017: done testing, but need to revisit as screens etc may change, find out whether update_status is effective
--		TO DO: 
--		this has not been put in the DAILY batch
/*
	-- Run the REST XML from webservices_requests
	DECLARE @Result varchar(500)
	EXEC dbo.webservices2_run @Result = @Result OUTPUT

*/

CREATE PROCEDURE [dbo].[DailyUpdate_sp_DM_Step07_Produce_XML_Readying_Upload]
AS


	BEGIN TRY

		DECLARE @jobdate datetime
		SET @jobdate = getdate()

		DECLARE @email_body varchar(4000), @from varchar(500),@to_admin varchar(500) ,@reply_to varchar(500)
			,@email_subject varchar(500), @Header varchar(500)
			,@step_name varchar(200)

		SET @from = 'appsmonitor@business.illinois.edu'
		SET @to_admin = 'appsmonitor@business.illinois.edu, nhadi@illinois.edu'
		SET @reply_to = 'appsmonitor@business.illinois.edu'
		SET @email_subject = '[DM] Step-by-Step Activity step 7 as of ' + cast(getdate() as varchar) 

		SET @header = '<HTML><B>[DM] Step By step Process Activity as of ' + cast(getdate() as varchar) + '</B><BR><R>'
					+ 'DailyUpdate_sp_DM_Step07_Produce_XML_Readying_Upload' + '</B><BR><BR>'

		INSERT INTO Database_Maintenance.dbo.Download_Process_Monitor_Logs
					(Table_Name, Copy_Datetime, [Status]) 
		VALUES('FSDB_EDW_Current_Employees 7', @jobdate, 0)

		DECLARE @Result varchar(500)
		--NS 3/12/2019 Screen is not ready
		--EXEC dbo.produce_XML_BANNER
		--EXEC dbo.webservices2_run @Result = @Result OUTPUT

		-- NS 4/15/2019 
		--		At this point PCI and USERS have been uptodate
		--		we need to download ADMIN to get KEEP_ACTIVE information to be used in both
		--		produce_XML_USERS_deactivate and produce_XML_USERS_add_update procedures

		-- RESET logs
		UPDATE dbo.FSDB_DM_Upload_Logs
		SET Current_Indicator=0
	
		SET @step_name = 'dbo.webservices_initiate @screen=''ADMIN'''
		PRINT @step_name
		EXEC dbo.webservices_initiate @screen='ADMIN'

		SET @step_name = 'dbo.webservices2_run 1st run'
		PRINT @step_name
		EXEC dbo.webservices2_run @Result = @Result OUTPUT
	
		SET @step_name = 'dbo.produce_XML_USERS_deactivate @submit = 1'
		PRINT @step_name
		EXEC dbo.produce_XML_USERS_deactivate @submit = 1

		SET @step_name = 'dbo.produce_XML_USERS_add_update @submit = 1'
		PRINT @step_name
		EXEC dbo.produce_XML_USERS_add_update @submit = 1
		--DECLARE @Result varchar(500)

		SET @step_name = 'dbo.webservices2_run 2nd run'
		PRINT @step_name
		EXEC dbo.webservices2_run @Result = @Result OUTPUT
	
		SET @step_name = 'dbo.webservices_initiate @screen=''USERS'''
		PRINT @step_name
		EXEC dbo.webservices_initiate @screen='USERS'

		SET @step_name = 'dbo.webservices_initiate @screen=''ADMIN'''
		PRINT @step_name
		EXEC dbo.webservices_initiate @screen='ADMIN'

		SET @step_name = 'dbo.webservices_initiate @screen=''PCI'''
		PRINT @step_name
		EXEC dbo.webservices_initiate @screen='PCI'

		WAITFOR DELAY '00:00:03'
		SET @step_name = 'dbo.webservices2_run 3rd run'
		PRINT @step_name
		EXEC dbo.webservices2_run  @Result = @Result OUTPUT

		SET @step_name = 'dbo.produce_XML_PCI_New @submit = 1'
		PRINT @step_name
		EXEC dbo.produce_XML_PCI_New @submit = 1

		SET @step_name = 'dbo.produce_XML_ADMIN_PCI_USER_Update @submit = 1'
		PRINT @step_name
		EXEC dbo.produce_XML_ADMIN_PCI_USER_Update @submit = 1

		WAITFOR DELAY '00:00:03'
		--DECLARE @Result varchar(500)
		SET @step_name = 'dbo.webservices2_run 4th run'
		PRINT @step_name
		EXEC dbo.webservices2_run  @Result = @Result OUTPUT
	
		SET @step_name = 'dbo.webservices_initiate @screen=''PCI, USERS, ADMIN'''
		PRINT @step_name

		EXEC dbo.webservices_initiate @screen='PCI'
		EXEC dbo.webservices_initiate @screen='USERS'
		EXEC dbo.webservices_initiate @screen='ADMIN'

		SET @step_name = 'dbo.webservices2_run 5th run'
		PRINT @step_name
		EXEC dbo.webservices2_run  @Result = @Result OUTPUT

		UPDATE	Database_Maintenance.dbo.Download_Process_Monitor_Logs
		SET		Status = 2
		WHERE	Table_Name = 'FSDB_EDW_Current_Employees 7'
			AND	Copy_Datetime = @jobdate

		SET @email_subject =  @email_subject + ' - Success'
		SET @email_body = @header + 'Success<BR><BR>'
		EXEC dbo.DailyUpdate_sp_Send_Email @from,@to_admin,@reply_to,@email_subject, @email_body

	END TRY

	BEGIN CATCH
			SET @email_subject =  @email_subject + ' - Error'
			SET @email_body = @header + '<BR><BR>' + @step_name + '<BR><BR>'
					+ ERROR_Message() + '<BR><BR>'
			EXEC dbo.DailyUpdate_sp_Send_Email @from,@to_admin,@reply_to,@email_subject, @email_body
	END CATCH

	-- NS 3/12/2019 ICES Data is not ready yet
	--EXEC dbo.produce_XML_SCHTEACH
	--EXEC dbo.webservices2_run  @Result = @Result OUTPUT

	/*
	-- RUN the codes to connect to DM webservuces
	DECLARE @Result varchar(500)
	EXEC dbo.webservices2_run @Result = @Result OUTPUT
	*/

GO
