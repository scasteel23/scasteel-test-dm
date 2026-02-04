SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 7/6/2018: replaced ' with ", undone
-- NS 9/22/2017: Need to pass webservices_requests.id to each shadow_* SP in order to save the error into webservices_requests.SP_Error
--		i.e. EXEC dbo.shadow_PCI @id,@response,@resync=0
--
-- NS 6/15/2016: Worked!
-- NS 5/28/2016
CREATE PROCEDURE [dbo].[webservices_process](@id INT, @response TEXT, @responseCode VARCHAR(20)) 
AS 

BEGIN

	
	DECLARE @prefix varchar(1000)
	SELECT @prefix = ISNULL(SP_ERROR,'') FROM dbo.webservices_requests WHERE [ID]=@id		
	SET @prefix = @prefix + ' - webservices_process started '
	UPDATE dbo.webservices_requests SET SP_Error=@prefix WHERE [ID]=@id

	-- NS 7/6/2018: replaced ' with ", undone
	-- SET @response = CAST(REPLACE(CAST(@response AS NVARCHAR(MAX)),'''','"') as TEXT)

	UPDATE dbo.webservices_requests SET response=@response,completed=GETDATE(),responseCode=@responseCode WHERE [id]=@id

	-- DEBUG starts
	-- >>>>>>>>>>>>>>
	--DECLARE @res varchar(2000), @method varchar(10), @urls varchar(2000)
	--SELECT @method=method, @urls = url FROM dbo.webservices_requests WHERE [id]=@id
	--SET @res = SUBSTRING(@response,1,1990)
	--EXEC dbo.webservices_save_log @webservices_requests_[id]=@id
	--			,@Post_Or_Get = @method
	--			,@What_Loaded=@urls
	--			,@LOAD_STATUS_CD = @responseCode
	--			,@LOAD_STATUS_DESC=  @res
	-- >>>>>>>>>>>>>>
	-- DEBUG ends

	DECLARE @method varchar(20)
	SELECT @method=isnull(method,'none') FROM dbo.webservices_requests WHERE [id]=@id
	UPDATE dbo.webservices_requests SET SP_Error=@prefix + ' - method ' + @method WHERE [ID]=@id;	

	

	-- Keep the GET log small and make the older parts of the log more sparse
	IF (SELECT method FROM dbo.webservices_requests WHERE [id]=@id) = 'GET' BEGIN
		DELETE x FROM (SELECT ROW_NUMBER()OVER(PARTITION BY url ORDER BY completed DESC)R,* FROM webservices_requests WHERE method='GET' AND response IS NOT NULL)x
		WHERE (SELECT COUNT(*) FROM webservices_requests WHERE url=x.url AND response IS NOT NULL)>30 AND x.R > 10 AND x.R % 3 = 1
	END
	DELETE x FROM (SELECT ROW_NUMBER()OVER(ORDER BY created DESC)R,* FROM dbo.webservices_requests)x WHERE x.R > 20000 AND x.created < DATEADD(DAY,-2,GETDATE()) OR x.R > 20000


	-- Process it
	IF (SELECT method FROM dbo.webservices_requests WHERE [id]=@id) = 'GET' BEGIN

		DECLARE @url VARCHAR(255) = (SELECT url FROM dbo.webservices_requests WHERE [id]=@id)
		DECLARE @initiated VARCHAR(255) = (SELECT initiated FROM dbo.webservices_requests WHERE [id]=@id)
		DECLARE @urlDetail VARCHAR(50) = SUBSTRING(@url,CHARINDEX('/SchemaData/INDIVIDUAL-ACTIVITIES-Business/',@url)+43,999) 

		UPDATE dbo.webservices_requests SET SP_Error=@prefix + ' - call ' + @urlDetail WHERE [ID]=@id	
			
		IF @urlDetail LIKE 'COLLEGE:Business/%' SET @urlDetail = SUBSTRING(@urlDetail,19,999);
		IF @urlDetail LIKE 'USERNAME:%' EXEC dbo.shadow_1USER @id,@response,@initiated									-- get a particular user data
		
		ELSE IF @urlDetail='PCI' EXEC dbo.shadow_PCI @id,@response,@resync=0				-- works						-- get all PCI (personal) screen data
		ELSE IF @urlDetail='CONTACT' EXEC dbo.shadow_CONTACT @id,@response,@resync=1										-- get all CONTACT screen data		
		ELSE IF @urlDetail='PROFILE' EXEC dbo.shadow_PROFILE @id,@response,@resync=1		-- works						-- get all BIO and *_INTERESTS

		ELSE IF @urlDetail='PASTHIST' EXEC dbo.shadow_PASTHIST @id,@response,@resync=1		-- check						-- get all PASTHIST (experience & consulting) screen data
		ELSE IF @urlDetail='AWARDHONOR' EXEC dbo.shadow_AWARDHONOR @id,@response,@resync=1	-- works						-- get all AWARDHONOR screen data
		ELSE IF @urlDetail='EDUCATION' EXEC dbo.shadow_EDUCATION @id,@response,@resync=1	-- works						-- get all EDUCATION screen data
		ELSE IF @urlDetail='FACDEV' EXEC dbo.shadow_FACDEV @id,@response,@resync=1			-- works						-- get all FACDEV (development) screen data
		ELSE IF @urlDetail='LICCERT' EXEC dbo.shadow_LICCERT @id,@response,@resync=1		-- works						-- get all LICCERT (license & certificate) screen data
		ELSE IF @urlDetail='MEMBER' EXEC dbo.shadow_MEMBER @id,@response,@resync=1			-- works						-- get all MEMBER

		ELSE IF @urlDetail='DSL' EXEC dbo.shadow_DSL @id,@response,@resync=1	
		ELSE IF @urlDetail='DEG_COMMITTEE' EXEC dbo.shadow_DEG_COMMITTEE @id,@response,@resync=1							-- get all DEGREE_COMMITTEE 
		ELSE IF @urlDetail='SCHTEACH' EXEC dbo.shadow_SCHTEACH @id,@response,@resync=1										-- get all COURSE 

		ELSE IF @urlDetail='CURRICULUM' EXEC dbo.shadow_CURRICULUM @id,@response,@resync=1	-- works					-- get all CURRICULUM (publication presentation) screen data
		ELSE IF @urlDetail='CONGRANT' EXEC dbo.shadow_CONGRANT @id,@response,@resync=1			-- works					-- get all CONGRANT screen data
		ELSE IF @urlDetail='INTELLCONT' EXEC dbo.shadow_INTELLCONT @id,@response,@resync=1		-- works					-- get all SERVICE_PROFESSIONAL (Publications) screen data
		ELSE IF @urlDetail='PRESENT' EXEC dbo.shadow_PRESENT @id,@response,@resync=1			-- now test					-- get all PRESENT (publication presentation) screen data
		ELSE IF @urlDetail='RESPROG' EXEC dbo.shadow_RESPROG @id,@response,@resync=1										-- get all (Work in Progress) screen data

		ELSE IF @urlDetail='SERVICE_ACADEMIC' EXEC dbo.shadow_SERVICE_ACADEMIC @id,@response,@resync=1			-- works	-- get all SERVICE_ACADEMIC (ACO: academic & community services) screen data			
		ELSE IF @urlDetail='SERVICE_COMMITTEE' EXEC dbo.shadow_SERVICE_COMMITTEE @id,@response,@resync=1		-- works	-- get all SERVICE_COMMITTEE (committee) screen data
		ELSE IF @urlDetail='SERVICE_PROFESSIONAL' EXEC dbo.shadow_SERVICE_PROFESSIONAL @id,@response,@resync=1	-- works	-- get all SERVICE_PROFESSIONAL (ACO: professional services) screen data
		ELSE IF @urlDetail='SERVICE_PUBLIC' EXEC dbo.shadow_SERVICE_PUBLIC @id,@response,@resync=1			    -- new 7/3/2018 	-- get all SERVICE_PUBLIC (ACO: community, public, and other services) screen data

		ELSE IF @urlDetail='NCTEACH' EXEC dbo.shadow_NCTEACH @id,@response,@resync=1	-- works	-- get all NCTEACH Non-Course Teaching
		ELSE IF @urlDetail='MEDCONT' EXEC dbo.shadow_MEDCONT @id,@response,@resync=1	-- works	-- get all Media Contribution
		
	
		ELSE IF @urlDetail='ADMIN' EXEC dbo.shadow_ADMIN @id,@response,@resync=1				-- 10/27/2017

		-- Not available yet as of 9/19/2017
		--ELSE IF @urlDetail='TITLE' EXEC dbo.shadow_TITLE @id,@response,@resync=1											-- get all TITLE screen data

		ELSE IF @url='/login/service/v4/User/INDIVIDUAL-ACTIVITIES-Business' EXEC dbo.shadow_USERS @id,@response,@resync=1	-- get all users
		ELSE 
			BEGIN
				DECLARE @msg varchar(300)
				SET @msg = ' - Shadow_' + @urlDetail + ' Stored Procedure is not found in DM_Shadow_Staging database'  
				UPDATE dbo.webservices_requests SET SP_Error=@prefix + @msg WHERE [ID]=@id;					
				RAISERROR(@msg,18,1);
			END
		
	END

	SET @prefix = @prefix + ' - webservices_process done '
	UPDATE dbo.webservices_requests SET SP_Error=@prefix WHERE [ID]=@id;	

	UPDATE dbo.webservices_requests SET processed=GETDATE() WHERE [id]=@id;
	-- Converting the response to XML and back strips useless whitespace from this log, then we trim it to the first MB so the logs don't get too big
	UPDATE dbo.webservices_requests SET response=LEFT(CAST(CAST(response AS XML)AS VARCHAR(MAX)),1024*1024) WHERE [id]=@id;
	/*
	DECLARE @url varchar(1000)
	SET @url = 'https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/EDUCATION'
	DECLARE @urlDetail VARCHAR(50) = SUBSTRING(@url,CHARINDEX('/SchemaData/INDIVIDUAL-ACTIVITIES-Business/',@url)+43,999)
	PRINT @urldetail
	*/
END




GO
