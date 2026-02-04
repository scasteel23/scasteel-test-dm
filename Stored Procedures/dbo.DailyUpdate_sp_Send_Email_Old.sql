SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO



-- NS 1/21/2015: Update using Ashwini's sqlmail
--		Original is on [xTmp_DailyUpdate_sp_Send_Email]

CREATE	PROCEDURE [dbo].[DailyUpdate_sp_Send_Email_Old]
(
	@From varchar(100), 
	@To varchar(500), 
	@ReplyTo varchar(100), 
	@EmailSubject varchar(200) = ' ', 
	@EmailBody varchar(MAX) = ' '
)
AS 

	  -- EXEC DailyUpdate_sp_Send_Email 'nhadi@illinois.edu', 'scasteel@illinois.edu, nhadi@illinois.edu', 'nhadi@illinois.edu', 'Test', 'Test Body'
	   Declare @intMessage int
	   Declare @intResult int
	   Declare @source varchar(255)
	   Declare @description varchar(500)
	   Declare @output varchar(1000)
	
	
	   EXEC @intResult = sp_OACreate 'CDO.Message', @intMessage OUT
	  
	  IF @intResult <>0 
	     BEGIN
	       SELECT @intResult
	       INSERT INTO dbo.DailyUpdate_Monitor_Email_failures VALUES (getdate(), @@spid, @From, @To, @EmailSubject, LEFT(@EmailBody,3500),  @intMessage, @intResult, @source, @description, @output, 'Failed at sp_OACreate')
	       EXEC @intResult = sp_OAGetErrorInfo NULL, @source OUT, @description OUT
	       IF @intResult = 0
	         BEGIN
	           SELECT @output = '  Source: ' + @source
	           --PRINT  @output
	           SELECT @output = '  Description: ' + @description
	           --PRINT  @output
                   INSERT INTO dbo.DailyUpdate_Monitor_Email_failures VALUES (getdate(), @@spid, @From, @To, @EmailSubject, LEFT(@EmailBody,3500), @intMessage, @intResult, @source, @description, @output, 'sp_OAGetErrorInfo for sp_OACreate')
                   RETURN
	         END
	       ELSE
	         BEGIN
	           --PRINT '  sp_OAGetErrorInfo failed.'
	           RETURN
	         END
	     END
	

	-- Configure a remote SMTP server.
	 EXEC @intResult = sp_OASetProperty @intMessage, 'Configuration.fields("http://schemas.microsoft.com/cdo/configuration/sendusing").Value','2'
	   IF @intResult <>0 
	     BEGIN
	       SELECT @intResult
	       INSERT INTO dbo.DailyUpdate_Monitor_Email_failures VALUES (getdate(), @@spid, @From, @To, @EmailSubject, LEFT(@EmailBody,3500), @intMessage, @intResult, @source, @description, @output, 'Failed at sp_OASetProperty sendusing')
	       EXEC @intResult = sp_OAGetErrorInfo NULL, @source OUT, @description OUT
	       IF @intResult = 0
	         BEGIN
	           SELECT @output = '  Source: ' + @source
	           --PRINT  @output
	           SELECT @output = '  Description: ' + @description
	           --PRINT  @output
                   INSERT INTO dbo.DailyUpdate_Monitor_Email_failures VALUES (getdate(), @@spid, @From, @To, @EmailSubject, LEFT(@EmailBody,3500), @intMessage, @intResult, @source, @description, @output, 'sp_OAGetErrorInfo for sp_OASetProperty sendusing')
                   GOTO send_cdosysmail_cleanup
	         END
	       ELSE
	         BEGIN
	           --PRINT '  sp_OAGetErrorInfo failed.'
	           GOTO send_cdosysmail_cleanup
	         END
	     END
	     
	--Configure the Server Name or IP address. 
	EXEC @intResult = sp_OASetProperty @intMessage, 'Configuration.fields("http://schemas.microsoft.com/cdo/configuration/smtpserver").Value', 'express-smtp.cites.uiuc.edu' 
	   IF @intResult <>0 
	     BEGIN
	       SELECT @intResult
	       INSERT INTO dbo.DailyUpdate_Monitor_Email_failures VALUES (getdate(), @@spid, @From, @To, @EmailSubject, LEFT(@EmailBody,3500), @intMessage, @intResult, @source, @description, @output, 'Failed at sp_OASetProperty smtpserver')
	       EXEC @intResult = sp_OAGetErrorInfo NULL, @source OUT, @description OUT
	       IF @intResult = 0
	         BEGIN
	           SELECT @output = '  Source: ' + @source
	           --PRINT  @output
	           SELECT @output = '  Description: ' + @description
	           --PRINT  @output
  	  	   INSERT INTO dbo.DailyUpdate_Monitor_Email_failures VALUES (getdate(), @@spid, @From, @To, @EmailSubject, LEFT(@EmailBody,3500), @intMessage, @intResult, @source, @description, @output, 'sp_OAGetErrorInfo for sp_OASetProperty smtpserver')
                   GOTO send_cdosysmail_cleanup
	         END
	       ELSE
	         BEGIN
	           --PRINT '  sp_OAGetErrorInfo failed.'
	           GOTO send_cdosysmail_cleanup
	         END
	     END
	     
	     
	     
	     --This is to configure sending to a remote SMTP Server. 
	EXEC @intResult = sp_OASetProperty @intMessage, 'Configuration.fields("http://schemas.microsoft.com/cdo/configuration/smtpserverport").Value', '25' 
	   IF @intResult <>0 
	     BEGIN
	       SELECT @intResult
	       INSERT INTO dbo.DailyUpdate_Monitor_Email_failures VALUES (getdate(), @@spid, @From, @To, @EmailSubject, LEFT(@EmailBody,3500), @intMessage, @intResult, @source, @description, @output, 'Failed at sp_OASetProperty Remotesmtpserver')
	       EXEC @intResult = sp_OAGetErrorInfo NULL, @source OUT, @description OUT
	       IF @intResult = 0
	         BEGIN
	           SELECT @output = '  Source: ' + @source
	           --PRINT  @output
	           SELECT @output = '  Description: ' + @description
	           --PRINT  @output
  	  	   INSERT INTO dbo.DailyUpdate_Monitor_Email_failures VALUES (getdate(), @@spid, @From, @To, @EmailSubject, LEFT(@EmailBody,3500), @intMessage, @intResult, @source, @description, @output, 'sp_OAGetErrorInfo for sp_OASetProperty Remotesmtpserver')
                   GOTO send_cdosysmail_cleanup
	         END
	       ELSE
	         BEGIN
	           --PRINT '  sp_OAGetErrorInfo failed.'
	           GOTO send_cdosysmail_cleanup
	         END
	     END
	     
	     
	----Set the Timeout in seconds
	EXEC @intResult = sp_OASetProperty @intMessage, 'Configuration.fields("http://schemas.microsoft.com/cdo/configuration/smtpconnectiontimeout").value', '30' 
	   IF @intResult <>0 
	     BEGIN
	       SELECT @intResult
	       INSERT INTO dbo.DailyUpdate_Monitor_Email_failures VALUES (getdate(), @@spid, @From, @To, @EmailSubject, LEFT(@EmailBody,3500), @intMessage, @intResult, @source, @description, @output, 'Failed at sp_OASetProperty Timeout')
	       EXEC @intResult = sp_OAGetErrorInfo NULL, @source OUT, @description OUT
	       IF @intResult = 0
	         BEGIN
	           SELECT @output = '  Source: ' + @source
	           --PRINT  @output
	           SELECT @output = '  Description: ' + @description
	           --PRINT  @output
  	  	   INSERT INTO dbo.DailyUpdate_Monitor_Email_failures VALUES (getdate(), @@spid, @From, @To, @EmailSubject, LEFT(@EmailBody,3500), @intMessage, @intResult, @source, @description, @output, 'sp_OAGetErrorInfo for sp_OASetProperty Timeout')
                   GOTO send_cdosysmail_cleanup
	         END
	       ELSE
	         BEGIN
	           --PRINT '  sp_OAGetErrorInfo failed.'
	           GOTO send_cdosysmail_cleanup
	         END
	     END
	      
	     
	
	--Save the configurations to the message object.
	   EXEC @intResult = sp_OAMethod @intMessage, 'Configuration.Fields.Update', null
	   IF @intResult <>0 
	     BEGIN
	       SELECT @intResult
	       INSERT INTO dbo.DailyUpdate_Monitor_Email_failures VALUES (getdate(), @@spid, @From, @To, @EmailSubject, LEFT(@EmailBody,3500), @intMessage, @intResult, @source, @description, @output, 'Failed at sp_OASetProperty Update')
	       EXEC @intResult = sp_OAGetErrorInfo NULL, @source OUT, @description OUT
	       IF @intResult = 0
	         BEGIN
	           SELECT @output = '  Source: ' + @source
	           --PRINT  @output
	           SELECT @output = '  Description: ' + @description
	           --PRINT  @output
  	  	   INSERT INTO dbo.DailyUpdate_Monitor_Email_failures VALUES (getdate(), @@spid, @From, @To, @EmailSubject, LEFT(@EmailBody,3500), @intMessage, @intResult, @source, @description, @output, 'sp_OAGetErrorInfo for sp_OASetProperty Update')                 
		   GOTO send_cdosysmail_cleanup
	         END
	       ELSE
	         BEGIN
	           --PRINT '  sp_OAGetErrorInfo failed.'
	           GOTO send_cdosysmail_cleanup
	         END
	     END
	
	--Set the e-mail parameters.
	   EXEC @intResult = sp_OASetProperty @intMessage, 'To', @To
	   IF @intResult <>0 
	     BEGIN
	       SELECT @intResult
	       INSERT INTO dbo.DailyUpdate_Monitor_Email_failures VALUES (getdate(), @@spid, @From, @To, @EmailSubject, LEFT(@EmailBody,3500), @intMessage, @intResult, @source, @description, @output, 'Failed at sp_OASetProperty To')
	       EXEC @intResult = sp_OAGetErrorInfo NULL, @source OUT, @description OUT
	       IF @intResult = 0
	         BEGIN
	           SELECT @output = '  Source: ' + @source
	           --PRINT  @output
	           SELECT @output = '  Description: ' + @description
	           --PRINT  @output
  	  	   INSERT INTO dbo.DailyUpdate_Monitor_Email_failures VALUES (getdate(), @@spid, @From, @To, @EmailSubject, LEFT(@EmailBody,3500), @intMessage, @intResult, @source, @description, @output, 'sp_OAGetErrorInfo for sp_OASetProperty To')                 
                   GOTO send_cdosysmail_cleanup
	         END
	       ELSE
	         BEGIN
	           --PRINT '  sp_OAGetErrorInfo failed.'
	           GOTO send_cdosysmail_cleanup
	         END
	     END

	   EXEC @intResult = sp_OASetProperty @intMessage, 'From', @From
	   IF @intResult <>0 
	     BEGIN
	       SELECT @intResult
	       INSERT INTO dbo.DailyUpdate_Monitor_Email_failures VALUES (getdate(), @@spid, @From, @To, @EmailSubject, LEFT(@EmailBody,3500), @intMessage, @intResult, @source, @description, @output, 'Failed at sp_OASetProperty From')
	       EXEC @intResult = sp_OAGetErrorInfo NULL, @source OUT, @description OUT
	       IF @intResult = 0
	         BEGIN
	           SELECT @output = '  Source: ' + @source
	           --PRINT  @output
	           SELECT @output = '  Description: ' + @description
	           --PRINT  @output
  	  	   INSERT INTO dbo.DailyUpdate_Monitor_Email_failures VALUES (getdate(), @@spid, @From, @To, @EmailSubject, LEFT(@EmailBody,3500), @intMessage, @intResult, @source, @description, @output, 'sp_OAGetErrorInfo for sp_OASetProperty From')                 
                   GOTO send_cdosysmail_cleanup
	         END
	       ELSE
	         BEGIN
	           --PRINT '  sp_OAGetErrorInfo failed.'
	           GOTO send_cdosysmail_cleanup
	         END
	     END

	   EXEC @intResult = sp_OASetProperty @intMessage, 'Subject', @EmailSubject
	   IF @intResult <>0 
	     BEGIN
	       SELECT @intResult
	       INSERT INTO dbo.DailyUpdate_Monitor_Email_failures VALUES (getdate(), @@spid, @From, @To, @EmailSubject, LEFT(@EmailBody,3500), @intMessage, @intResult, @source, @description, @output, 'Failed at sp_OASetProperty Subject')
	       EXEC @intResult = sp_OAGetErrorInfo NULL, @source OUT, @description OUT
	       IF @intResult = 0
	         BEGIN
	           SELECT @output = '  Source: ' + @source
	           --PRINT  @output
	           SELECT @output = '  Description: ' + @description
	           --PRINT  @output
  	  	   INSERT INTO dbo.DailyUpdate_Monitor_Email_failures VALUES (getdate(), @@spid, @From, @To, @EmailSubject, LEFT(@EmailBody,3500), @intMessage, @intResult, @source, @description, @output, 'sp_OAGetErrorInfo for sp_OASetProperty Subject')
                   GOTO send_cdosysmail_cleanup
	         END
	       ELSE
	         BEGIN
	           --PRINT '  sp_OAGetErrorInfo failed.'
	           GOTO send_cdosysmail_cleanup
	         END
	     END
	
	-- Since we need an HTML e-mail, using 'HTMLBody' instead of 'TextBody'.
	   EXEC @intResult = sp_OASetProperty @intMessage, 'HTMLBody', @EmailBody
	   IF @intResult <>0 
	     BEGIN
	       SELECT @intResult
	       INSERT INTO dbo.DailyUpdate_Monitor_Email_failures VALUES (getdate(), @@spid, @From, @To, @EmailSubject, LEFT(@EmailBody,3500), @intMessage, @intResult, @source, @description, @output, 'Failed at sp_OASetProperty TextBody')
	       EXEC @intResult = sp_OAGetErrorInfo NULL, @source OUT, @description OUT
	       IF @intResult = 0
	         BEGIN
	           SELECT @output = '  Source: ' + @source
	           --PRINT  @output
	           SELECT @output = '  Description: ' + @description
	           --PRINT  @output
  	  	   INSERT INTO dbo.DailyUpdate_Monitor_Email_failures VALUES (getdate(), @@spid, @From, @To, @EmailSubject, LEFT(@EmailBody,3500), @intMessage, @intResult, @source, @description, @output, 'sp_OAGetErrorInfo for sp_OASetProperty TextBody')
                   GOTO send_cdosysmail_cleanup
	         END
	       ELSE
	         BEGIN
	           --PRINT '  sp_OAGetErrorInfo failed.'
	           GOTO send_cdosysmail_cleanup
	         END
	     END

	   EXEC @intResult = sp_OAMethod @intMessage, 'Send', NULL
	   IF @intResult <>0 
	     BEGIN
	       SELECT @intResult
	       INSERT INTO dbo.DailyUpdate_Monitor_Email_failures VALUES (getdate(), @@spid, @From, @To, @EmailSubject, LEFT(@EmailBody,3500), @intMessage, @intResult, @source, @description, @output, 'Failed at sp_OAMethod Send')
	       EXEC @intResult = sp_OAGetErrorInfo NULL, @source OUT, @description OUT
	       IF @intResult = 0
	         BEGIN
	           SELECT @output = '  Source: ' + @source
	           --PRINT  @output
	           SELECT @output = '  Description: ' + @description
	           --PRINT  @output
  	  	   INSERT INTO dbo.DailyUpdate_Monitor_Email_failures VALUES (getdate(), @@spid, @From, @To, @EmailSubject, LEFT(@EmailBody,3500), @intMessage, @intResult, @source, @description, @output, 'sp_OAGetErrorInfo for sp_OAMethod Send')
                   GOTO send_cdosysmail_cleanup
	         END
	       ELSE
	         BEGIN
	           --PRINT '  sp_OAGetErrorInfo failed.'
	           GOTO send_cdosysmail_cleanup
	         END
	     END
	

	-- Do some error handling after each step if you have to.
	-- Clean up the objects created.
        send_cdosysmail_cleanup:
	If (@intMessage IS NOT NULL) -- if @intMessage is NOT NULL then destroy it
	BEGIN
		EXEC @intResult=sp_OADestroy @intMessage
	
		-- handle the failure of the destroy if needed
		IF @intResult <>0 
	     	BEGIN
			select @intResult
        	        INSERT INTO dbo.DailyUpdate_Monitor_Email_failures VALUES (getdate(), @@spid, @From, @To, @EmailSubject, LEFT(@EmailBody,3500), @intMessage, @intResult, @source, @description, @output, 'Failed at sp_OADestroy')
	       		EXEC @intResult = sp_OAGetErrorInfo NULL, @source OUT, @description OUT
	
			-- if sp_OAGetErrorInfo was successful, --PRINT errors
			IF @intResult = 0
			BEGIN
				SELECT @output = '  Source: ' + @source
			        --PRINT  @output
			        SELECT @output = '  Description: ' + @description
			        --PRINT  @output
				INSERT INTO dbo.DailyUpdate_Monitor_Email_failures VALUES (getdate(), @@spid, @From, @To, @EmailSubject, LEFT(@EmailBody,3500), @intMessage, @intResult, @source, @description, @output, 'sp_OAGetErrorInfo for sp_OADestroy')
			END
			
			-- else sp_OAGetErrorInfo failed
			ELSE
			BEGIN
				--PRINT '  sp_OAGetErrorInfo failed.'
			        RETURN
			END
		END
	END
	ELSE 
	BEGIN
		--PRINT ' sp_OADestroy skipped because @intMessage is NULL.'
		INSERT INTO dbo.DailyUpdate_Monitor_Email_failures VALUES (getdate(), @@spid, @From, @To, @EmailSubject, LEFT(@EmailBody,3500), @intMessage, @intResult, @source, @description, @output, '@intMessage is NULL, sp_OADestroy skipped')

	    RETURN
	END
	        
GO
