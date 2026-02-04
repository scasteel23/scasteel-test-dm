SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




-- NS 10/12/2016: Must re-test due to newly updated shadow_screen_data SP
--		for setting author_username, this is not universal, done only for presentation, grant, and publication authors tables!!
--
-- NS 10/5/2016 Revisited
--		get FACSTAFFID, EDWPERSID by linking dbo.USERS and the related table based on ID field
-- NS 9/8/2016 Revisited
--		All tables must have standards userid, id, FACSTAFFID, EDWPERSID, lastModified, and Create_Datetime fields
--		Set Create_Datetime as getdate() for new records
--		Set FACSTAFFID and EDWPERSID looking up _DM_USERS table
-- NS 5/28/2016 (modified from Michael Paine's codes)
-- NS 6/22/2016:
--		BOTH tables i.e DM_Shadow_Staging.dbo._DM_PCI and DM_Shadow_Production.dbo._DM_PCI have to have records that were downloaded previously from DM
--		This SP will take input XML from DM and update both tables based on DM values

/*
			Sample call from dbo.shadow_PRESENT SP:

			SET @fields = 'userName,lastModified' +
					',TITLE,CLASSIFICATION,NAME,STATUS,REFEREED,CITY,STATE,COUNTRY' +                          
					',MEETING_TYPE,SCOPE_LOCALE,ORG,PUBPROCEED,DESC'+                                   
					',DOI,SSRN_ID,DTM_DATE,DTY_DATE'

			EXEC dbo.shadow_screen_data @table='_DM_PRESENT'
				,@idtype=NULL,@cols=@fields
				,@userid=@userid,@resync=@resync,@debug=0

			SET @fields2 = 'userName,lastModified' +
							',FACULTY_NAME,FNAME,MNAME' +
							',LNAME,ROLE'
			
			EXEC dbo.shadow_screen_data '_DM_PRESENT_AUTH'
				,'_DM_PRESENT',@fields2
				,@userid,@resync;

*/
-- Process_screen_data - this procedure assumes takes the data from #{@table}, 
--		MERGEs it into DM_Shadow_Staging database, and then pushes the changes into DM_Shadow_Production database production.
--
-- Any data locking needs to be done be the calling procedure
-- The new data needs to be in #{@table} (for example, if @table='_DM_EDUCATION', the data should be in #_DM_EDUCATION)
--		@table - the name of the destination table
--		@idtype -
--			If NULL then "id" must be the id column of the dataset
--			If "LINKED" then "id" must be the id column of the dataset and the dataset must contain a USER_REFERENCE_CREATOR field to describe "linked" Activity Insight records
--			Otherwise, the name of the table to which this dataset's "id" column refers.  "itemid" must be the id column of this dataset; this sub-record is assumed to be associated with a user if FACULTY_NAME appears in @cols
--		@userid - userid | FACULTY_NAME | null
--		@cols - a comma-separated list of all of the columns to merge (except for the id and itemid columns, and userid which is assumed unless @idtype specifies a parent table)

CREATE PROCEDURE [dbo].[shadow_screen_data1_new] (@webservices_requests_id INT, @table VARCHAR(MAX)
		,@idtype AS VARCHAR(50)
		,@cols VARCHAR(MAX)
		,@userid BIGINT
		,@resync BIT
		,@debug TINYINT=0) AS BEGIN

	-- NS 10/2/2017: Need to pass webservices_requests_id to this SP
	DECLARE @prefix varchar(1000)

	SELECT @prefix = ISNULL(SP_ERROR,'')
	FROM dbo.webservices_requests
	WHERE [ID]=@webservices_requests_id		

	SET @prefix = @prefix + '- shadow_screen_data '
	UPDATE dbo.webservices_requests SET SP_Error=@prefix WHERE [ID]=@webservices_requests_id;	

	-- Validate input
	-- Because we don't escape the field and table names, we need to make sure we prevent any kind of SQL injection by ensuring simple field names
	IF  @table LIKE '%[^A-Za-z0-9_]%' 
		RAISERROR('The table specified in @table is not allowed',18,1)
	IF  @idtype LIKE '%[^A-Za-z0-9_]%' 
		RAISERROR('The table specified in @idtype is not allowed',18,1)
	ELSE 
		IF @cols LIKE '%[^A-Za-z0-9_,@]%' 
			RAISERROR('@cols parameter should be a list of column names separated by commas with no spaces.  Column names may only contains letters, numbers, underscore, and the at symbol',18,1)
		ELSE 
		    BEGIN
				IF @debug<>0 PRINT 'Formatting Columns'
				-- Specify the identifier field
				DECLARE @id AS VARCHAR(MAX) = 'id'
				IF ISNULL(@idtype,'LINKED')<>'LINKED'		-- @idtype is NULL (the @table is the main table), or 
															-- @idtype is a table name which is the main table itself
				   BEGIN
					  SET @id='itemid'
					  SET @cols = 'id,'+@cols
				   END 
				ELSE										-- @idtype value is "LINKED"
				   BEGIN
					  SET @cols = 'userid,'+@cols
				   END
				-- Split @cols into rows as #colsList
				DECLARE @colsSplit AS XML = CAST('<n>'+REPLACE(@cols,',','</n><n>')+'</n>' AS XML)
				SELECT CAST(@id AS VARCHAR(MAX))name,CAST(1 AS BIT) isKey INTO #colsList
				UNION SELECT Col.value('(./text())[1]','varchar(MAX)'),0 FROM @colsSplit.nodes('/n')Cols(Col)
				-- Put it back into @cols to make sure the table and the list have the same order
				SET @cols = STUFF(CAST((SELECT ','+name FROM #colsList WHERE isKey=0 FOR XML PATH(''),TYPE)AS VARCHAR(MAX)),1,1,'')
		
				-- Build pieces of SQL to put into the EXEC call
				-- Lists of Columns
				DECLARE @colsComma AS VARCHAR(MAX) = STUFF(CAST((SELECT ',['+name+']' FROM #colsList FOR XML PATH(''),TYPE)AS VARCHAR(MAX)),1,1,'')
				DECLARE @colsMergeInsertValues AS VARCHAR(MAX) = @colsComma
				IF @idtype='LINKED' SET @colsMergeInsertValues = STUFF(CAST((SELECT ','+CASE WHEN name='userid' THEN 'CASE WHEN USER_REFERENCE_CREATOR=''Yes'' THEN userid ELSE NULL END' ELSE name END FROM #colsList FOR XML PATH(''),TYPE)AS VARCHAR(MAX)),1,1,'')
				DECLARE @colsMergeOutput AS VARCHAR(MAX) = CAST((SELECT ',ISNULL(inserted.['+name+'],deleted.['+name+'])' FROM #colsList FOR XML PATH(''),TYPE)AS VARCHAR(MAX))
				DECLARE @colsChangeTest AS VARCHAR(MAX) = REPLACE(STUFF(CAST((SELECT 'OR CASE WHEN a.['+name+'] IS NULL THEN 1 ELSE 0 END++CASE WHEN b.['+name+'] IS NULL THEN 1 ELSE 0 END OR a.['+name+']++b.['+name+']' FROM #colsList WHERE iskey=0 FOR XML PATH(''),TYPE)AS VARCHAR(MAX)),1,3,''),'++','<>')
				DECLARE @colsSet AS VARCHAR(MAX) = STUFF(CAST((SELECT ',['+name+']=b.['+name+']' FROM #colsList WHERE iskey=0 FOR XML PATH(''),TYPE)AS VARCHAR(MAX)),1,1,'')
				DECLARE @colsMergeSet AS VARCHAR(MAX) = @colsSet;
				IF @idType='LINKED' SET @colsMergeSet = STUFF(CAST((SELECT ',['+name+']='+CASE WHEN name='userid' THEN 'CASE WHEN USER_REFERENCE_CREATOR=''Yes'' THEN b.userid ELSE a.userid END' ELSE 'b.['+name+']' END FROM #colsList WHERE iskey=0 FOR XML PATH(''),TYPE)AS VARCHAR(MAX)),1,1,'')
				-- Criteria
				DECLARE @deleteOnlyThisUser AS VARCHAR(MAX) = ''
				IF @userid IS NOT NULL BEGIN
					SET @deleteOnlyThisUser = CASE 
						WHEN ISNULL(@idtype,'LINKED')='LINKED' THEN ' AND userid='+CAST(@userid AS VARCHAR(MAX))
						-- parent record is mine or this dsa is mine (if the dsa is associated with a user)
						ELSE ' AND ((SELECT userid FROM dbo.'+@idtype+' WHERE id=a.id)='+CAST(@userid AS VARCHAR(MAX))+
							CASE WHEN EXISTS(SELECT 1 FROM #colsList WHERE name='FACULTY_NAME')
								THEN ' OR a.FACULTY_NAME='+CAST(@userid AS VARCHAR(MAX)) ELSE '' END+')'
					END
				END
			
				DECLARE @insertOnlyExistingUsers AS VARCHAR(MAX) = ''
				IF ISNULL(@idtype,'LINKED')='LINKED' SET @insertOnlyExistingUsers = ' AND userid IN (SELECT userid FROM dbo._DM_USERS)'
				ELSE SET @insertOnlyExistingUsers = ' AND id IN (SELECT id FROM dbo.'+@idtype+')'
			
				DROP TABLE #colsList;
		
				-- Prepare variables to pass into EXEC call
				DECLARE @sql_resync VARCHAR(MAX)=(SELECT ISNULL(@resync,0))
				DECLARE @sql_userid VARCHAR(MAX)=(SELECT CASE WHEN @userid IS NULL THEN 'NULL' ELSE CAST(@userid AS VARCHAR(30))END)
				DECLARE @sql_debug VARCHAR(MAX)=CASE WHEN @debug<>0 THEN 'PRINT ' ELSE '-- ' END
		
				DECLARE @sql AS VARCHAR(MAX) 
			
				SET @sql = '
				-- Pass Variables
				DECLARE @counts INT -- DEBUG
				DECLARE @resync BIT='+@sql_resync+'
				'+@sql_debug+'''Creating Temp Table''
				-- Create table to hold changes
				SELECT TOP 0 CAST(''A'' AS CHAR(1))action,'+@colsComma+' INTO #changes'+@table+' FROM dbo.'+@table+';
		
				TryAgain:
				-- The changes are assessed on Staging.  So Production & Staging tables need to start out identical.
				-- If @resync, then we pull the Production table to Staging to make sure they are identical before importing.
				'+@sql_debug+'''Resync Merge''
				IF @resync=1
					MERGE INTO dbo.'+@table+' a USING DM_Shadow_Production.dbo.'+@table+' b ON (a.'+@id+'=b.'+@id+')
					WHEN MATCHED AND (
						'+@colsChangeTest + 
					') THEN UPDATE SET
						'+@colsSet+'
					WHEN NOT MATCHED BY TARGET'+@insertOnlyExistingUsers+' THEN
						INSERT ('+@colsComma+')
						VALUES ('+@colsComma+')
					WHEN NOT MATCHED BY SOURCE THEN DELETE;
		
				-- Merge into Staging; whatever changes are made by this merge will be replicated on production
				'+@sql_debug+'''Merge to Staging''
				MERGE INTO dbo.'+@table+' a USING #'+@table+' b ON (a.'+@id+'=b.'+@id+')
				WHEN MATCHED AND (
						'+@colsChangeTest+'
					) THEN UPDATE SET
						'+@colsMergeSet+' 
				WHEN NOT MATCHED BY TARGET'+@insertOnlyExistingUsers+' THEN
						INSERT ('+@colsComma+')
						VALUES ('+@colsMergeInsertValues+')
				WHEN NOT MATCHED BY SOURCE'+@deleteOnlyThisUser+' THEN DELETE
				OUTPUT LEFT($action,1) action'+@colsMergeOutput+'
				INTO #changes'+@table+';

				'+@sql_debug+' ''Merged'' SELECT * FROM #'+@table+' SELECT * FROM #changes'+@table+';
		
				-- Push to Production
				BEGIN TRY
					'+@sql_debug+'''Production INSERT''
					INSERT INTO DM_Shadow_Production.dbo.'+@table+'
							('+@colsComma+')
					SELECT '+@colsComma+'
					FROM #changes'+@table+' WHERE action=''I'';
	
					'+@sql_debug+'''Production UPDATE''
					UPDATE DM_Shadow_Production.dbo.'+@table+' SET 
						'+@colsSet+'
					FROM DM_Shadow_Production.dbo.'+@table+' a
					JOIN #changes'+@table+' b ON a.'+@id+'=b.'+@id+'
					WHERE b.action=''U'';
			
					'+@sql_debug+'''Production DELETE''
					DELETE FROM DM_Shadow_Production.dbo.'+@table+' WHERE '+@id+' IN (SELECT '+@id+' FROM #changes'+@table+' WHERE action=''D'');
					'+@sql_debug+'''Production DELETED''
				END TRY 
				BEGIN CATCH
					DECLARE @error_message AS VARCHAR(MAX) = (SELECT ERROR_MESSAGE());
					SELECT @error_message,ERROR_SEVERITY(),ERROR_NUMBER();
					IF @resync=1 RAISERROR(''Fail '+@table+': %s'',18,0,@error_message)
					ELSE BEGIN
						'+@sql_debug+'''Production Retry''
						SET @resync=1;
						DELETE FROM #changes'+@table+';
						GOTO TryAgain;
					END
				END CATCH
				DROP TABLE #changes'+@table+'
				';


				if @debug=1 
					BEGIN
						DECLARE @sql1 varchar(4000), @sql2 varchar(4000)
						SET @sql1 = SUBSTRING(@sql,1,2000)
						SET @sql2 = SUBSTRING(@sql,2001,4000)
						PRINT @sql1
						PRINT @sql2
					END
		
				EXEC(@sql)

				-- >>>>>>>>>>>>>>>>>>>>>>>
				-- NS 9/8/2016
				-- All tables must have standards userid, id, FACSTAFFID, EDWPERSID, lastModified, and Create_Datetime fields
				-- SET Create_Datetime to those who is empty, meaning newly created records
				SET @sql = 'UPDATE DM_Shadow_Staging.dbo.'+@table+' SET Create_Datetime = GETDATE() ' +
					' WHERE Create_Datetime is NULL '
				EXEC(@sql)

				SET @sql = 'UPDATE DM_Shadow_Production.dbo.'+@table+' SET Create_Datetime = GETDATE() ' +
					' WHERE Create_Datetime is NULL '
				EXEC(@sql)

				-- SET FACSTAFFID and EDWPERSID
			
				-- >>>> based on USERID on main tables, i.e. _DM_PRESENT, _DM_AWARDHONOR, _DM_GRANT, DM_PUBLICATION
				-- >>>> NS 9/8/2016
				SET @sql = 'UPDATE DM_Shadow_Production.dbo.'+@table+' SET FACSTAFFID = U.FACSTAFFID, EDWPERSID=U.EDWPERSID ' +
					' FROM DM_Shadow_Production.dbo._DM_USERS U, DM_Shadow_Production.dbo.'+@table+' F ' +			
					' WHERE U.userid = F.userid AND ( F.FACSTAFFID is NULL OR F.EDWPERSID IS NULL )'
				EXEC(@sql)

				SET @sql = 'UPDATE DM_Shadow_Staging.dbo.'+@table+' SET FACSTAFFID = U.FACSTAFFID, EDWPERSID=U.EDWPERSID ' +
					' FROM DM_Shadow_Staging.dbo._DM_USERS U, DM_Shadow_Staging.dbo.'+@table+' F ' +
					' WHERE U.userid = F.userid AND ( F.FACSTAFFID is NULL OR F.EDWPERSID IS NULL )'
				EXEC(@sql)

				-- >>>> based on ID on between main and sub tables: Three tables as follow'
			
				-- >>>> NS 10/5/2016
				IF @idtype is NOT NULL and @idtype <>'LINKED'
					BEGIN				
						
						-- NS 10/12/2016: Must re-test due to newly updated shadow_screen_data SP
						--		for setting author_username, this might not be universal must be done only for presentation, grant, and publication authors tables!!

						--		@idtype				@table
						--		_DM_PRESENT			_DM_PRESENT_AUTH
						--		_DM_CONGRANT		_DM_CONGRANT_INVEST
						--		_DM_INTELLCONT		_DM_INTELLCONT_AUTH	
						--		_DM_DEG_COMMITTEE	_DM_DEG_COMMITTEE_MEMBER	

						print @table
						print @idtype

						IF @table = '_DM_PRESENT_AUTH' OR @table = '_DM_CONGRANT_INVEST' OR @table = '_DM_INTELLCONT_AUTH'
									OR @table = '_DM_DEG_COMMITTEE_MEMBER'
							BEGIN
								--print '1'
								-- SET AUTHORS's FACSTAFFID, EDWPERSID, and USERNAME
								SET @sql = 'UPDATE DM_Shadow_Staging.dbo.'+@idtype+' SET USERID = U.USERID, FACSTAFFID = U.FACSTAFFID, EDWPERSID=U.EDWPERSID, USERNAME=U.USERNAME ' +
									' FROM DM_Shadow_Staging.dbo.' + @idtype + ' U, DM_Shadow_Staging.dbo.'+@table+' F ' +
									' WHERE U.id = F.id AND ( F.FACSTAFFID is NULL OR F.EDWPERSID IS NULL )'
								EXEC(@sql)
								--print '2'
								SET @sql = 'UPDATE DM_Shadow_Production.dbo.'+@idtype+' SET USERID = U.USERID, FACSTAFFID = U.FACSTAFFID, EDWPERSID=U.EDWPERSID, USERNAME=U.USERNAME ' +
									' FROM DM_Shadow_Production.dbo.' + @idtype + ' U, DM_Shadow_Production.dbo.'+@table+' F ' +
									' WHERE U.id = F.id AND ( F.FACSTAFFID is NULL OR F.EDWPERSID IS NULL )'
								EXEC(@sql)
								--print '3'
								-- SET OWNER's FACSTAFFID, EDWPERSID, and USERNAME
								SET @sql = 'UPDATE DM_Shadow_Staging.dbo.'+@table+' SET FACSTAFFID = U.FACSTAFFID, EDWPERSID=U.EDWPERSID, USERID = U.USERID, USERNAME=U.USERNAME ' +
									' FROM DM_Shadow_Staging.dbo._DM_USERS U, DM_Shadow_Staging.dbo.'+@table+' F ' +
									' WHERE U.userid = F.FACULTY_NAME AND F.FACULTY_NAME is NOT NULL AND F.FACULTY_NAME <> '''' AND F.USERNAME IS NULL'
								EXEC(@sql)
								--print '4'
								SET @sql = 'UPDATE DM_Shadow_Production.dbo.'+@table+' SET FACSTAFFID = U.FACSTAFFID, EDWPERSID=U.EDWPERSID, USERID = U.USERID,  USERNAME=U.USERNAME ' +
									' FROM DM_Shadow_Production.dbo._DM_USERS U, DM_Shadow_Production.dbo.'+@table+' F ' +			 
									' WHERE U.userid = F.FACULTY_NAME AND F.FACULTY_NAME is NOT NULL AND F.FACULTY_NAME <> '''' AND F.USERNAME IS NULL'
								EXEC(@sql)
								--print '5'
							END

					

					
						
						
					END
			END

	/*
		DEBUG
			DECLARE @userid as varchar(50), @resync as BIT
			-- Problem: This is relying of #PCI that has already be gone by end of shadow_PCI execution
			SET @userid = NULL
			SET @resync =1
			EXEC dbo.shadow_screen_data 'PCI',NULL,'surveyId,lastModified,access,PREFIX,FNAME,PFNAME,MNAME,LNAME,SUFFIX,ALT_NAME,EMAIL,WEBSITE,DT_DOB,GENDER,ETHNICITY,RESEARCH_INTERESTS,BIO,EMERGENCY_CONTACT,SHOW_PHOTO,TWITTER,LINKEDIN,TEACHING_INTERESTS,QUOTE,UPLOAD_CV',@userid,@resync;
			EXEC dbo.shadow_screen_data 'RESEARCH_KEYWORD','PCI','KEYWORD',@userid,@resync;
			EXEC dbo.shadow_screen_data 'LINKS','PCI','NAME,URL,sequence',@userid,@resync;
		
	*/
END



GO
