SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


 --NS 9/27/2017
  CREATE PROC [dbo].[DailyUpdate_sp_DM_Step11_Report_DTSX_Errors]
 AS
	 DECLARE @Network_ID varchar(60), @Err_Desc varchar(1000), @webservices_logs_id INT
	 DECLARE @current_datetime as datetime, @current_date varchar(12)

	 DECLARE @emailtable table(emailid INT, emailbody varchar(MAX))
	 DECLARE @body varchar(MAX), @emailid INT, @subject varchar(200), @emailcount INT

	 -- DEBUG
	 DECLARE @sent_to varchar(600)
	 SET @sent_to = 'nhadi@illinois.edu'

	 SET NOCOUNT OFF

	 SET @body=''
	 SET @emailid=1

	 SET @current_datetime=getdate()
	 SET @current_date = convert(varchar, @current_datetime,101)
	 --print @current_date

	 DECLARE errs CURSOR READ_ONLY FOR
		  SELECT [webservices_logs_id], REPLACE([What_Loaded],'/login/service/v4/UserSchema/USERNAME:','') as Network_ID
			,[LOAD_STATUS_DESC]
		  FROM [DM_Shadow_Staging].[dbo].[webservices_logs]
		  where load_status_cd = '400' --and [webservices_logs_id]>2824
			AND [POST_DATE] >= @current_date
			AND What_loaded LIKE '%/login/service/v4/UserSchema/USERNAME:%'
		  
		  UNION

		  SELECT  [webservices_logs_id],  [What_Loaded] as Network_ID
			,[LOAD_STATUS_DESC]
		  FROM [DM_Shadow_Staging].[dbo].[webservices_logs]
		  where load_status_cd = '400' --and [webservices_logs_id]>2824
			AND [POST_DATE] >= @current_date
			AND What_loaded NOT LIKE '%/login/service/v4/UserSchema/USERNAME:%'
			--AND What_loaded LIKE '%/login/service/v4/UserSchema/USERNAME:%'

		  UNION

		  SELECT  [webservices_logs_id],  [What_Loaded] as Network_ID
			,[LOAD_STATUS_DESC]
		  FROM [DM_Shadow_Staging].[dbo].[webservices_logs]
		  where load_status_cd = '500' --and [webservices_logs_id]>2824
			AND [POST_DATE] >= @current_date

		  order by  [webservices_logs_id] asc


	OPEN errs
	FETCH errs INTO @webservices_logs_id, @Network_ID, @Err_desc
	WHILE (@@FETCH_STATUS = 0)
		BEGIN

			SET @body = @body + '<BR/><b>' + @Network_ID + '</b><BR/>' + @Err_desc + '<BR/>'
			IF LEN(@body) > 6000
				BEGIN
					INSERT INTO @emailtable (emailid, emailbody) VALUES (@emailid, @body)
					SET @emailid = @emailid + 1
					SET @body = ''
				END
			--PRINT @Network_ID
			--PRINT @Err_desc
			FETCH errs INTO @webservices_logs_id, @Network_ID, @Err_desc
		END

	CLOSE Errs
	DEALLOCATE errs

	SELECT @emailcount=count(*) FROM @emailtable

	IF @emailcount > 0 AND @emailcount <= 25
		BEGIN

			DECLARE emails CURSOR READ_ONLY FOR
				SELECT emailid, emailbody FROM @emailtable ORDER by emailid desc

			OPEN emails
			FETCH emails INTO @emailid, @body
			WHILE @@FETCH_STATUS = 0 
				BEGIN

					--PRINT @body
					SET @subject = 'DTSX and REST return errors #' + cast(@emailid as varchar)
					EXEC dbo.DailyUpdate_sp_Send_Email 'appsmonitor@business.illinois.edu', 'nhadi@illinois.edu'
						,'appsmonitor@business.illinois.edu', @subject , @body
					FETCH emails INTO @emailid, @body
				END

			CLOSE emails
			DEALLOCATE emails
		END
	ELSE
	IF  @emailcount > 25
		BEGIN
			SET @subject = 'DTSX and REST return too many error emails (' + cast(@emailcount as varchar) + ')'
			SET @body = '<BR><BR>DTSX and REST return too many error emails - ' + cast(@emailcount as varchar) + '<BR/><BR/>'
				+ 'RUN DM_Shadow_Staging.dbo.DailyUpdate_sp_DM_Step12_Manual_Error_Inspection'
			EXEC dbo.DailyUpdate_sp_Send_Email 'appsmonitor@business.illinois.edu', @sent_to
				,'appsmonitor@business.illinois.edu', @subject , @body			
		END
	ELSE
		BEGIN
			SET @subject = 'DTSX and REST return no errors'
			SET @body = '<BR><BR>DTSX and REST return no errors ' 
			EXEC dbo.DailyUpdate_sp_Send_Email 'appsmonitor@business.illinois.edu', 'nhadi@illinois.edu', @sent_to
				,'appsmonitor@business.illinois.edu', @subject , @body			

		END

	-- EXEC dbo.DailyUpdate_sp_DM_Step11_Report_DTSX_Errors
GO
