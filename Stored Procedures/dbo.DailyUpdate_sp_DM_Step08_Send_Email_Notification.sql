SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 6/17/2019
--		FSDB_DM_Upload_Activity_Logs
--		FSDB_DM_Upload_Activity_Main
--		FSDB_DM_Upload_Activity_Email_Notification
--	Next: Send email to adresseess based on "Activity" on FSDB_DM_Upload_Activity_Email_Notification table
CREATE PROC [dbo].[DailyUpdate_sp_DM_Step08_Send_Email_Notification]
AS

	BEGIN TRY

		DECLARE @jobdate datetime
		SET @jobdate = getdate()

		DECLARE @email_body varchar(6000), @from varchar(500),@to_admin varchar(500) ,@reply_to varchar(500)
			,@email_subject varchar(500), @Header varchar(1000)

		SET @from = 'appsmonitor@business.illinois.edu'
		SET @to_admin = 'appsmonitor@business.illinois.edu, nhadi@illinois.edu'
		SET @reply_to = 'appsmonitor@business.illinois.edu'
		SET @email_subject = '[DM] Step-by-Step Activity step 8 (last step) as of ' + cast(getdate() as varchar) 

		SET @header = '<HTML><B>[DM] Step By step Process Activity as of ' + cast(getdate() as varchar) + '</B><BR><R>'
					+ 'DailyUpdate_sp_DM_Step08_Send_Email_Notification' + '</B><BR><BR>'

		INSERT INTO Database_Maintenance.dbo.Download_Process_Monitor_Logs
					(Table_Name, Copy_Datetime, [Status]) 
		VALUES('FSDB_EDW_Current_Employees 8', @jobdate, 0)



		DECLARE @admin_email_exists int
		DECLARE @listStr VARCHAR(MAX)
		DECLARE @Footer varchar(MAX)
		DECLARE @Email_Subject_Activity varchar(300), @Email_Body_Activity varchar(MAX)
		DECLARE @Insert varchar(MAX), @to_activity varchar(500)
		DECLARE @CRLF varchar(2)
	
	
		SET @from = 'appsmonitor@business.illinois.edu'
		SET @to_admin = 'appsmonitor@business.illinois.edu, nhadi@illinois.edu, scasteel@illinois.edu, ctidrick@illinois.edu'
		SET @reply_to = 'appsmonitor@business.illinois.edu'
		
		SET @header = '<HTML><B>[DM] Daily process Activity as of ' + cast(getdate() as varchar) + '</B><BR><BR>'
		SET @header = @header + '>>>  Procedure: DM_Shadow_Staging.dbo.DailyUpdate_sp_DM_Step08_Send_Email_Notification <BR>' 
		SET @header = @header + '>>>  Tables: FSDB_DM_Upload_Logs, FSDB_DM_Upload_Activity_Main, and FSDB_DM_Upload_Activity_Email_Notification  <BR><BR>' 
		SET @footer = '<BR></HTML>'

				
		SET @admin_email_exists = 0	
		SET @email_subject = '[DM] Daily process activity as of ' + cast(getdate() as varchar) 
		SET @email_body = @Header 

		DECLARE @activity varchar(100), @activity_description varchar(500)
		DECLARE activity_cursor  CURSOR READ_ONLY FOR
			SELECT activity, activity_description
			FROM dbo.FSDB_DM_Upload_Activity_Main
			ORDER BY activity_report_order ASC

		OPEN activity_cursor
		FETCH activity_cursor INTO @activity, @activity_description

		-- Iterate all to-be-reported activities
		WHILE @@FETCH_STATUS=0 
			BEGIN

				SET @listStr = NULL
				SELECT @listStr = COALESCE(@listStr+'<BR/>' ,'') 
						+ 'EDWPERSID ' + CAST (EDWPERSID as varchar) + ' : ' 
						+ USERNAME + '@illinois.edu' + ' : ' 
						+ 'UIN ' + UIN + ' : ' 
						+ 'DM USERID ' +  CAST (USERID as varchar) + ' : ' 
						+ BANNER_LNAME + ', ' 
						+ BANNER_FNAME + ' : ' 
						+ ISNULL(EMPEE_DEPT_NAME,'No Department') + ' : ' 
						+ ISNULL(DM_Department_Name,'No DM Department') + ' : ' 
									+ ISNULL(empee_group_desc,'No Emp Group') + ' : ' 
						+ ISNULL(EMPEE_CLS_LONG_DESC,'No Class Group')					
				FROM [DM_Shadow_Staging].[dbo].[FSDB_DM_Upload_Logs]
				WHERE [Current_Indicator]=1 and Activity=@activity

				IF @listStr IS NOT NULL
					BEGIN		
						SET @admin_email_exists = 1			
						SET @email_body = @email_body +  @activity_description + ': <BR> <BR>' + @listStr + '<BR><BR>' 

						SET @to_activity = NULL					
						SELECT @to_activity = COALESCE(@to_activity+',' ,'') +Email_Address
						FROM [DM_Shadow_Staging].[dbo].FSDB_DM_Upload_Activity_Email_Notification
						WHERE Activity=@activity

						IF @to_activity IS NOT NULL
							BEGIN
								SET @Email_Body_Activity =  @Header + @activity_description + ': <BR> <BR>' + @listStr + '<BR><BR>' + @Footer
								SET @Email_Subject_Activity = '[DM] Daily process - ' +  @activity_description + ' as of ' + cast(getdate() as varchar)
								EXEC dbo.DailyUpdate_sp_Send_Email @from,@to_activity,@reply_to,@Email_Subject_Activity, @Email_Body_Activity
							END
					END
							
				FETCH activity_cursor INTO @activity, @activity_description

			END

		CLOSE activity_cursor
		DEALLOCATE activity_cursor


		-- >>>>>>>>>>>>>>>>>>> SEND EMAIL 
		Print '>> Prepare Email Notification';

		IF @admin_email_exists = 1 
			BEGIN
				SET @email_body = @email_body + @Footer
				EXEC dbo.DailyUpdate_sp_Send_Email @from,@to_admin,@reply_to,@email_subject, @email_body
			END


		UPDATE	Database_Maintenance.dbo.Download_Process_Monitor_Logs
		SET		Status = 2
		WHERE	Table_Name = 'FSDB_EDW_Current_Employees 8'
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
GO
