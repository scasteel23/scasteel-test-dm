SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 4/29/2019
--		Made this SP to connect to the betawebservices, while dbo.[webservices2_RUN] SP connects to the webservices
-- NS 4/4/2019
--		This replaces the use of DTS with the use of SQL OLE automation to connect to to DM Webservices 
CREATE PROCEDURE [dbo].[webservices2_RUNDMTEST]
	(
			@Result varchar(500) OUTPUT
	)
AS

	SET TEXTSIZE 2147483647

	DECLARE @records as XML

	DECLARE @base_url varchar(200), @complete_url varchar(600)
	DECLARE @ob int, @hr  int, @desc varchar(1000), @source varchar(500)
	DECLARE @response varchar(MAX), @responseCode varchar(10), @responseText varchar(8000)
	declare @problem varchar(2000)
	declare @username varchar(60), @pw varchar(60)

		
	/*
	 DECLARE @Result varchar(500)
	 EXEC dbo.[webservices2_RUN]  @Result=@Result OUT
	 PRINT @Result
	*/
	
	-- Must set this TEXTSIZE otherwise the SP cannot run in Job Agent
	-- This TEXTSIZE is not required when the SP is run manually
	
	SET NOCOUNT ON
	CREATE TABLE #Temp_XML
	(
		records Text NULL
	)

	DECLARE @id BIGINT, @method varchar(50), @url varchar(200), @post varchar(MAX)
	SET @base_url = 'https://betawebservices.digitalmeasures.com'
	
	SET @username = 'illinois/web_service'
	SET @pw = 'trgW42vXs7d'

	DECLARE @countreq INT
	SET @countreq = 0
	SET @id = NULL
	EXEC dbo.[webservices2_reserve_pending] @id=@ID OUTPUT, @method=@method OUTPUT, @url=@url OUTPUT, @post=@post OUTPUT

	WHILE @id is not NULL
		BEGIN
			DELETE FROM #Temp_XML
			
			SET @countreq = @countreq + 1	
			SET @complete_url = @base_url + @url

			--print convert(varchar,getdate(),108)
			print @id
			print @method
			--print @complete_url
			--print @post
			
			
			--EXEC @hr=sp_OACreate 'MSXML2.XMLHTTP',@ob OUT
			EXEC @hr=sp_OACreate 'MSXML2.ServerXMLHTTP',@ob OUT	
			IF @hr <> 0 EXEC sp_OAGetErrorInfo @ob

			-- time out
			--EXEC @hr=sp_OASetProperty @ob, 'setTimeouts','60000','60000','60000','60000' -- 60 seconds
			----EXEC @hr = sp_OASetProperty @ob,'ConnectorProperty', 600000, 'Timeout'
			--if @hr <>0 EXEC sp_OAGetErrorInfo @ob

		
			EXEC @hr=sp_OAMethod @ob, 'Open',NULL,@method,@complete_url,'false',@UserName, @pw
			IF @hr <> 0 EXEC sp_OAGetErrorInfo @ob

			SET @Result = 'OK'
			SET @responseCode = '200'

			IF @method = 'GET'
				BEGIN
					--  GET
					EXEC @hr=sp_OAMethod @ob,'Send'
					IF @hr <> 0 EXEC sp_OAGetErrorInfo @ob	

					-- Using a table to store data so we could use sp_OAGetProperty instead of sp_OAMethod, which would be more efficient
					INSERT INTO #Temp_XML(records)
					EXEC @hr=sp_OAGetProperty @ob, 'responseXML.XML' --'ResponseText'
					IF @hr <> 0 EXEC sp_OAGetErrorInfo @ob, @source OUT, @desc OUT

					--SELECT @hr=COUNT(*)  FROM #Temp_XML WHERE records like '%<Error>%'
					IF @hr > 0
						BEGIN			
							SET @Result = @desc
							UPDATE dbo.webservices_requests
							SET error_description=@desc, responseCode=1000, completed=GETDATE(), processed=GETDATE()
							WHERE id=@id
							RETURN
						END

					IF NOT EXISTS (select * from #Temp_XML) 
						BEGIN
							PRINT 'No Data'
							SET @Result = 'No Data'
							UPDATE dbo.webservices_requests
							SET error_description='No Data', responseCode=1000,completed=GETDATE(), processed=GETDATE()
							WHERE id=@id						
						END
						--
					ELSE
						BEGIN
							--select * from #Temp_XML
							SELECT @response=records FROM #Temp_XML
							EXEC dbo.[webservices2_process] @id=@id, @response=@response,@responseCode=@responseCode
						END
					
				END
			ELSE
				BEGIN

					-- >>>> PUT, POST, OR DELETE

					EXEC @hr=sp_OAMethod @ob,'Send',null,@post
					IF @hr <> 0 
						BEGIN
							EXEC sp_OAGetErrorInfo @ob, @source OUT, @desc OUT
							SET @Result = @desc
							UPDATE dbo.webservices_requests
							SET error_description=@desc, responseCode=1000, completed=GETDATE(), processed=GETDATE()
							WHERE id=@id
						END
					ELSE
						BEGIN
							EXEC @hr=sp_OAMethod @ob, 'responseText', @ResponseText OUTPUT
							IF @hr <> 0 
								BEGIN
									EXEC sp_OAGetErrorInfo @ob, @source OUT, @desc OUT
									SET @Result = @desc
									UPDATE dbo.webservices_requests
									SET error_description=@desc, responseCode=2000, completed=GETDATE(), processed=GETDATE()
									WHERE id=@id
								END
							ELSE
								BEGIN
									UPDATE dbo.webservices_requests SET processed=GETDATE(), completed=GETDATE(), responseCode=@responseCode 
									WHERE [id]=@id

									-- Converting the response to XML and back strips useless whitespace from this log, then we trim it to the first MB so the logs don't get too big
									UPDATE dbo.webservices_requests SET response=@ResponseText --LEFT(CAST(CAST(response AS XML)AS VARCHAR(MAX)),1024*1024) 
									WHERE [id]=@id

									
								END
						END
				END

				EXEC @hr=sp_OADestroy @ob
				IF @hr <> 0 EXEC sp_OAGetErrorInfo @ob

				PRINT @Result
				print '-----------------'

				-- GET the next request
				SET @id = NULL
				EXEC dbo.[webservices2_reserve_pending] @id=@ID OUTPUT, @method=@method OUTPUT, @url=@url OUTPUT, @post=@post OUTPUT

			END

	PRINT 'Processed requests : ' + CAST(@countreq as varchar)
GO
