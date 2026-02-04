SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 9/7/2016
-- It worked
-- Provide a WS URL of an entity (MEMBER, AWARDHONOR, EDUCATION, ...) and get an XML stream

CREATE PROC [dbo].[_Test_Shadow]
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
	
	SET @user = 'illinois/web_service'
	SET @Pwd = 'trgW42vXs7d'



	-- >>>>>>>>>>>>>>  V1 - GET an xml string of EDUCATION entity
	-- NS 9/9/2016:  It worked for MEMBER, EDUCATION, FACDEV, and LICCEART
	--				 not working for PASTHIST, PCI, and AWARDHONOR... the data is too large, > 8000 characters
	--
	 --SET @baseurl = 'https://beta.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business'
	 --SET @url = @baseurl + '/EDUCATION'
	
	 --EXEC dbo._Test_Invoke_WS_v2 @URI  = @url,      
	 -- @methodName = 'GET',
	 -- @requestBody  = '',
	 -- @UserName = @user,
	 -- @Password = @pwd,
	 -- @responsexml = @responsexml OUTPUT
	 
	 --SELECT @responsexml [response]

	 -- EXEC dbo.[_Test_Shadow]	

	 -- >>>>>>>>>>>>>>  V2 - GET AND run Shadow_USERS
	 --NS 9/9/2016:  
	
	 SET @url = 'https://beta.digitalmeasures.com/login/service/v4/User/INDIVIDUAL-ACTIVITIES-Business'
	
	 EXEC dbo._Test_Invoke_WS_v2 @URI  = @url,      
		 @methodName = 'GET',
		 @requestBody  = '',
		 @UserName = @user,
		 @Password = @pwd,
		 @responsexml = @responsexml OUTPUT
	
	SELECT @responsexml [response]
	EXEC dbo.shadow_USERS @xml=@responsexml,@resync=1
	-- EXEC dbo.[_Test_Shadow]	

	-- >>>>>>>>>>>>>>  V3 - GET AND run Shadow_PCI
	-- NS 9/9/2016:  
	--
	-- SET @baseurl = 'https://beta.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business'
	-- SET @url = @baseurl + '/PCI'
	
	-- EXEC dbo._Test_Invoke_WS_v2 @URI  = @url,      
	--	 @methodName = 'GET',
	--	 @requestBody  = '',
	--	 @UserName = @user,
	--	 @Password = @pwd,
	--	 @responsexml = @responsexml OUTPUT
	
	----SELECT @responsexml [response]
	--EXEC dbo.shadow_PCI @xml=@responsexml, @userid=NULL,@resync=NULL
	---- EXEC dbo.[_Test_Shadow]	

	
	

	

GO
