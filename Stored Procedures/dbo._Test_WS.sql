SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 9/7/2016 it worked for GET method
-- Provide a WS URL of an entity (MEMBER, AWARDHONOR, EDUCATION, ...) and get a varchar(8000) stream output
--	Test for POST has not been verified/tested

-- NS 6/3/2016: original

CREATE PROC [dbo].[_Test_WS]
AS

	DECLARE @user varchar(50)
	DECLARE @pwd varchar(50)
	DECLARE @url varchar(500)
	DECLARE @baseurl varchar(500)
	DECLARE @response varchar(8000)
	DECLARE @hr INT
	DECLARE @src varchar(300)
	DECLARE @desc varchar(300)
	DECLARE @obj INT
	DECLARE @t table (ID int, strxml xml)
	DECLARE @responsexml xml
	DECLARE @postBody varchar(8000)

	SET @user = 'illinois/web_service'
	SET @Pwd = 'trgW42vXs7d'



	SET @postBody = '<User username="nhadi1">
      <FirstName>Brian</FirstName>
      <MiddleName>T</MiddleName>
      <LastName>Hadi</LastName>
      <Email>nhadi1@illinois.edu</Email>      
      <ShibbolethAuthentication/>
    </User>'

	--SET @postBody = '&lt;USER Username="bwhitloc"&gt;
 --     &lt;FirstName&gt;Brian&lt;/FirstName&gt;
 --     &lt;MiddleName&gt;T&lt;/MiddleName&gt;
 --     &lt;LastName&gt;Whitlock&lt;/LastName&gt;
 --     &lt;Email&gt;bwhitloc@illinois.edu&lt;/Email&gt;
 --     &lt;UIN&gt;654716534&lt;/UIN&gt;
 --     &lt;ShibbolethAuthentication/&gt;
 --   &lt;/USER&gt;'

	SET @url = 'https://beta.digitalmeasures.com/login/service/v4/User/INDIVIDUAL-ACTIVITIES-Business/'
	--SET @url = 'https://beta.digitalmeasures.com/login/service/v4/User/'

	--EXEC dbo._Invoke_WS_v1 @URI  = @url,      
	--	@methodName = 'POST',
	--	@requestBody  = @postBody,
	--	--@SoapAction = '',
	--	@UserName = @user,
	--	@Password = @pwd,
	--	@responseText = @response OUTPUT

	--SELECT @response [response]



	

	-- >>>>>>>>>>>>>>  V1 - GET
	-- NS 9/9/2016:  It worked

	SET @baseurl = 'https://beta.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business'
	SET @url = @baseurl + '/EDUCATION'
	
	EXEC dbo._Test_Invoke_WS_v1 @URI  = @url,      
		@methodName = 'GET',
		@requestBody  = '',
		--@SoapAction = '',
		@UserName = @user,
		@Password = @pwd,
		@responseText = @response OUTPUT

	SELECT @response [response]


	


	-- >>>>>>>>>>>>>>>> V2 - GET
	

	--SET @baseurl = 'https://beta.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business'
	--SET @url = @baseurl + '/EDUCATION'
	----SET @url = 'https://www3.business.illinois.edu/fsdb_services/WP_XML_College_Directory.aspx'
	--print @url

	--EXEC sp_OACreate 'MSXML2.ServerXMLHttp', @obj OUT

	-- No user and pwd
	--EXEC sp_OAMethod @obj, 'Open', NULL, 'GET', @url, false, @UserName, @Password

	/*
	-- With user and pwd
	EXEC @hr = sp_OAMethod @obj, 'open', null, 'GET', @url, 'false', @user, @Pwd
	IF @hr = 0 
		BEGIN
			EXEC @hr = sp_OAMethod @obj, 'send'

			IF    @hr <> 0 
			BEGIN
				  EXEC sp_OAGetErrorInfo @obj, @src OUT, @desc OUT
				  SELECT      hResult = convert(varbinary(4), @hr), 
						source = @src, 
						description = @desc, 
						FailPoint = 'Send failed', 
						MedthodName = 'GET' 
				  goto destroy 
				  return
			END


			-- Get response text
			EXEC sp_OAGetProperty @obj, 'responseText', @response OUT
			IF @hr <> 0 
				BEGIN
					  EXEC sp_OAGetErrorInfo @obj, @src OUT, @desc OUT
					  SELECT      hResult = convert(varbinary(4), @hr), 
							source = @src, 
							description = @desc, 
							FailPoint = 'ResponseText failed', 
							MedthodName = 'GET' 
					  goto destroy 
					  return
				END

			--DECLARE @statusText varchar(1000), @status varchar(1000) 
			-- Get status text 
			--exec sp_OAGetProperty @obj, 'StatusText', @statusText out
			--exec sp_OAGetProperty @obj, 'Status', @status out
			--select @status, @statusText, 'GET' 
			--
			--SELECT @response [response]
			
		END
		*/
	destroy:
	EXEC sp_OADestroy @obj

	
	



GO
