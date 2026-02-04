SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



-- NS 6/5/2022

CREATE	PROCEDURE [dbo].[DailyUpdate_sp_Send_Email]
(
	@From varchar(100), 
	@To varchar(500), 
	@ReplyTo varchar(100), 
	@EmailSubject varchar(200) = ' ', 
	@EmailBody varchar(MAX) = ' '
)
AS 
   BEGIN

	BEGIN TRY
		DECLARE @dbmailProfile VARCHAR(60)
		IF  @@SERVERNAME LIKE '%dev%'
			SET @dbmailProfile='giesazsqldevProfile'
		ELSE
		IF  @@SERVERNAME LIKE '%prod%'
			SET @dbmailProfile='giesazsqlprodProfile'
		ELSE
		IF  @@SERVERNAME LIKE '%stage%'
			SET @dbmailProfile='giesazsqlstageProfile'

	   --SET @@To =   'nhadi@illinois.edu; appsmonitor@business.illinois.edu; amduboi2@illinois.edu'

	   EXEC msdb.dbo.sp_send_dbmail
			@profile_name = @dbmailProfile,
			@from_address = @From, -- 'AppsMonitor <appsmonitor@business.illinois.edu>',
			@reply_to = @ReplyTo, -- 'appsmonitor@business.illinois.edu',
			@body = @EmailBody,
			@body_format ='HTML',
			@recipients = @To,
			@subject = @EmailSubject 
	END TRY

	BEGIN CATCH
		PRINT '[dbo].[DailyUpdate_sp_Send_Email] Error'	     
	END CATCH
    

	

END
	         
GO
