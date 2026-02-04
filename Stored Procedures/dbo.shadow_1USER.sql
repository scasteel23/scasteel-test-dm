SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- 10/16/2017: restesting works, due to the use of new shadow_screen_data1 and shadow_screen_data2 SP 
-- NS 9/22/2017: added @webservices_requests_id to pass for each "EXEC dbo.shadow_* ..."
-- NS 10/19/2016 revisited, worked!
-- NS 5/28/2016 (modified from Michael Paine's codes)

-- Given all of the Digital Measures data for a user, import it into staging1 and staging2.
-- Should be fed the output of a web service call like this one:
-- https://digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:nhadi
-- EXEC dbo.parse_all '<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata"><Record userid="1380179">
-- <APPOINTMENTS id="1" dmd:lastModified="2014-05-30T04:04:53"><BANNERTITLE>TEST</BANNERTITLE></APPOINTMENTS></Record></Data>'


CREATE PROCEDURE [dbo].[shadow_1USER] (@webservices_requests_id INT, @xml XML,@refresh_initiated DATETIME) AS


	DECLARE @prefix varchar(1000)
	SELECT @prefix = SP_ERROR FROM dbo.webservices_requests WHERE id=@webservices_requests_id		
	SET @prefix = @prefix +  ' - shadow_1USER '
	UPDATE dbo.webservices_requests SET SP_Error=@prefix WHERE id=@webservices_requests_id;	

	-- Verify the integrity of the data
	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')
	SELECT Record.value('@userId','BIGINT') userid, Record.value('@username','VARCHAR(50)')username
	INTO #users
	FROM @xml.nodes('/Data/Record')Records(Record)

	IF (SELECT COUNT(*) FROM #users)=0 
		BEGIN
			UPDATE dbo.webservices_requests SET SP_Error=@prefix + ': There is no such individual user data in Activity Insight''s XML' WHERE [ID]=@webservices_requests_id					
			RAISERROR('No Data',18,1)
		END
	ELSE IF (SELECT COUNT(*) FROM #users)>1 
		BEGIN
			UPDATE dbo.webservices_requests SET SP_Error=@prefix + ':Found more than one users' WHERE [ID]=@webservices_requests_id					
			RAISERROR('There are more than one users',18,1)
		END
	ELSE BEGIN
		-- Find the userid
		DECLARE @userid BIGINT
		SET @userid = (SELECT userid FROM dbo._DM_USERS WHERE userid IN (SELECT userid FROM #users))
		IF @userid IS NULL 
			BEGIN
				UPDATE dbo.webservices_requests SET SP_Error=@prefix + ':User not found in dbo._DM_USERS' WHERE [ID]=@webservices_requests_id		
				RAISERROR('User not found in dbo._DM_USERS',18,1)
			END
		ELSE 
			IF (SELECT COUNT(*) FROM #users WHERE userid=@userid)=0 
				BEGIN
					UPDATE dbo.webservices_requests SET SP_Error=@prefix + ':UserId not found in @xml' WHERE [ID]=@webservices_requests_id					
					RAISERROR('Userid not found in @xml',18,1)
				END
			ELSE 
				BEGIN
	--print '[shadow_1USER]1'
	--print @userid
	--print @webservices_requests_id
					EXEC dbo.shadow_PCI @webservices_requests_id,@xml, @userid				-- NS 3/15/2017
					EXEC dbo.shadow_CONTACT @webservices_requests_id,@xml, @userid			-- NS 9/20/2017
					EXEC dbo.shadow_PROFILE @webservices_requests_id,@xml, @userid			-- NS 9/19/2017

					EXEC dbo.shadow_PASTHIST @webservices_requests_id,@xml, @userid			-- NS 10/19/2016
					EXEC dbo.shadow_AWARDHONOR @webservices_requests_id,@xml, @userid		-- NS 10/19/2016
					EXEC dbo.shadow_EDUCATION @webservices_requests_id,@xml, @userid			-- NS 3/14/2017
					EXEC dbo.shadow_FACDEV @webservices_requests_id,@xml, @userid			-- NS 3/14/2017
					EXEC dbo.shadow_LICCERT @webservices_requests_id,@xml, @userid			-- NS 3/14/2017
					EXEC dbo.shadow_MEMBER @webservices_requests_id,@xml, @userid			-- NS 3/14/2017
		
					 --EXEC dbo.shadow_DSL @webservices_requests_id,@xml, @userid				
					EXEC dbo.shadow_DEG_COMMITTEE @webservices_requests_id,@xml, @userid	-- NS 4/26/2017	
					EXEC dbo.shadow_SCHTEACH @webservices_requests_id,@xml, @userid			-- NS 4/26/2017

					EXEC dbo.shadow_INNOVATIONS @webservices_requests_id,@xml, @userid		-- NS 3/14/2017
					EXEC dbo.shadow_CONGRANT @webservices_requests_id,@xml, @userid			-- NS 3/15/2017
					EXEC dbo.shadow_INTELLCONT @webservices_requests_id,@xml, @userid		-- NS 3/15/2017
					EXEC dbo.shadow_PRESENT @webservices_requests_id,@xml, @userid			-- NS 3/15/2017		
					EXEC dbo.shadow_RESPROG @webservices_requests_id,@xml, @userid			-- NS 4/26/2017
		
					EXEC dbo.shadow_SERVICE_ACADEMIC @webservices_requests_id,@xml, @userid		-- NS 3/14/2017
					EXEC dbo.shadow_SERVICE_COMMITTEE @webservices_requests_id,@xml, @userid	-- NS 3/14/2017
					EXEC dbo.shadow_SERVICE_PROFESSIONAL @webservices_requests_id,@xml, @userid	-- NS 3/14/2017		
					
					EXEC dbo.shadow_ADMIN @webservices_requests_id,@xml, @userid				-- NS 11/3/2017			
			
					-- --EXEC dbo.shadow_TITLE @xml, @userid		
	--print '[shadow_1USER]2'
				UPDATE DM_Shadow_Staging.dbo._DM_USERS SET Update_Datetime=@refresh_initiated WHERE userid=@userid;
				--NS 6/4/2020 not needed
				--UPDATE DM_Shadow_Production.dbo._DM_USERS SET Update_Datetime=@refresh_initiated WHERE userid=@userid;
			END
	END



GO
