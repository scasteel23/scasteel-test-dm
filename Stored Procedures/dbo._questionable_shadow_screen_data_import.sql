SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- NS 5/28/2016 (modified from Michael Paine's codes)
-- NS 6/22/2016:
--		BOTH tables i.e DM_Shadow_Staging.dbo.PCI and DM_Shadow_Production.dbo.PCI have to have records that were downloaded previously from DM
--		This SP will take input XML from DM and update both tables based on DM values

-- process_screen_data - this procedure assumes takes the data from #{@table}, MERGEs it into staging, and then pushes the changes into [ED_PRODUCTION].
--   Any data locking needs to be done be the calling procedure
--   The new data needs to be in #{@table} (for example, if @table='EDUCATION', the data should be in #EDUCATION)
-- @table - the name of the destination table
-- @idtype -
--   If NULL then "id" must be the id column of the dataset
--   If "LINKED" then "id" must be the id column of the dataset and the dataset must contain a USER_REFERENCE_CREATOR field to describe "linked" Activity Insight records
--   Otherwise, the name of the table to which this dataset's "id" column refers.  "itemid" must be the id column of this dataset; this sub-record is assumed to be associated with a user if FACULTY_NAME appears in @cols
-- @userid - userid | FACULTY_NAME | null
-- @cols - a comma-separated list of all of the columns to merge (except for the id and itemid columns, and userid which is assumed unless @idtype specifies a parent table)
CREATE PROCEDURE [dbo].[_questionable_shadow_screen_data_import] (@table VARCHAR(MAX)
		,@idtype AS VARCHAR(50)
		,@cols VARCHAR(MAX)
		,@username varchar(50)
		,@userid BigInt
		,@resync BIT
		,@debug TINYINT=0) AS BEGIN
	-- Validate input
	-- Because we don't escape the field and table names, we need to make sure we prevent any kind of SQL injection by ensuring simple field names
	IF  @table LIKE '%[^A-Za-z0-9_]%' RAISERROR('The table specified in @table is not allowed',18,1)
	IF  @idtype LIKE '%[^A-Za-z0-9_]%' RAISERROR('The table specified in @idtype is not allowed',18,1)
	ELSE IF @cols LIKE '%[^A-Za-z0-9_,@]%' RAISERROR('@cols parameter should be a list of column names separated by commas with no spaces.  Column names may only contains letters, numbers, underscore, and the at symbol',18,1)
	ELSE BEGIN
		IF @debug<>0 PRINT 'Formatting Columns'
		-- Specify the identifier field
		DECLARE @id AS VARCHAR(MAX) = 'id'
		IF ISNULL(@idtype,'LINKED')<>'LINKED' BEGIN
			SET @id='itemid'
			SET @cols = 'id,'+@cols
		END ELSE BEGIN
			SET @cols = 'userid,username,'+@cols
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
			IF @username IS NOT NULL BEGIN
				SET @deleteOnlyThisUser = CASE 
					WHEN ISNULL(@idtype,'LINKED')='LINKED' THEN ' AND userid='+CAST(@userid AS VARCHAR(MAX))
					-- parent record is mine or this dsa is mine (if the dsa is associated with a user)
					ELSE ' AND ((SELECT username FROM dbo.'+@idtype+' WHERE id=a.id)='''+ @username+ ''' ' +
						CASE WHEN EXISTS(SELECT 1 FROM #colsList WHERE name='FACULTY_NAME')
							THEN ' OR a.FACULTY_NAME='+CAST(@userid AS VARCHAR(MAX)) ELSE '' END+')'
				END
			END
			
			DECLARE @insertOnlyExistingUsers AS VARCHAR(MAX) = ''
			IF ISNULL(@idtype,'LINKED')='LINKED' SET @insertOnlyExistingUsers = ' AND username IN (SELECT username FROM dbo.USERS)'
			ELSE SET @insertOnlyExistingUsers = ' AND id IN (SELECT id FROM dbo.'+@idtype+')'
			
		DROP TABLE #colsList;
		
		-- Prepare variables to pass into EXEC call
		DECLARE @sql_resync VARCHAR(MAX)=(SELECT ISNULL(@resync,0))
		DECLARE @sql_userid VARCHAR(MAX)=(SELECT CASE WHEN @userid IS NULL THEN 'NULL' ELSE CAST(@userid AS VARCHAR(30))END)
		DECLARE @sql_debug VARCHAR(MAX)=CASE WHEN @debug<>0 THEN 'PRINT ' ELSE '-- ' END
		
		-- Assumes that the table name does not need to be escaped
		DECLARE @sql AS VARCHAR(MAX) = '
		-- Pass Variables
		DECLARE @counts INT -- DEBUG
		DECLARE @resync BIT='+@sql_resync+'
		'+@sql_debug+'''Creating Temp Table''
		-- Create table to hold changes
		SELECT TOP 0 CAST(''A'' AS CHAR(1))action,'+@colsComma+' INTO #changes'+@table+' FROM dbo.'+@table+';
		
		'+@sql_debug+'''Resync Merge''
		
		INSERT INTO dbo.'+@table+' ('+@colsComma+')
		SELECT '+@colsComma+'
		FROM #'+@table+ '
		WHERE id NOT IN
			(SELECT id FROM dbo.'+@table+') 

		'+@sql_debug+' ''Merged'' SELECT * FROM #'+@table+' SELECT * FROM #changes'+@table+';';
		
		
		EXEC(@sql)
	END

	/*
		DEBUG
			DECLARE @userid as varchar(50), @resync as BIT
			-- Problem: This is relying of #PCI that has already be gone by end of shdow_PCI execution
			SET @userid = NULL
			SET @resync =1
			EXEC dbo.shadow_screen_data 'PCI',NULL,'surveyId,lastModified,access,PREFIX,FNAME,PFNAME,MNAME,LNAME,SUFFIX,ALT_NAME,EMAIL,WEBSITE,DT_DOB,GENDER,ETHNICITY,RESEARCH_INTERESTS,BIO,EMERGENCY_CONTACT,SHOW_PHOTO,TWITTER,LINKEDIN,TEACHING_INTERESTS,QUOTE,UPLOAD_CV',@userid,@resync;
			EXEC dbo.shadow_screen_data 'RESEARCH_KEYWORD','PCI','KEYWORD',@userid,@resync;
			EXEC dbo.shadow_screen_data 'LINKS','PCI','NAME,URL,sequence',@userid,@resync;
		
	*/
END



GO
