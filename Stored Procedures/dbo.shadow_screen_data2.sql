SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 11/26/2018 Update 
-- NS 11/16/2018 Updated FACSTAFFID and EDWPERSID based on _DM_USERS on 
--		_DM_CONTACT, _DM_DEG_COMMITTEE, _DM_PROFILE
-- NS 10/16/2017 done testing with https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:[username]
-- NS 10/12/2017 done testing with https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/[screen-name]
-- NS 10/5/2017 
-- Used in screens that has sub-screen (authors of Publications, languages of profile, publications of Media Contribution, etc.) or DSA
--		shadow_DEG_COMMITTEE, done
--		shadow_CONGRANT,	done
--		shadow_INTELLCONT,	done
--		shadow_CONTACT,		done
--		shadow_PRESENT,		done
--		shadow_PROFILE		done
--		shadow_1USER by calling all of the aboves for individual profile
-- MUST : field names that is similar with system names must be used with bracket [] in @fields 

CREATE PROC [dbo].[shadow_screen_data2]
(
		@webservices_requests_id INT
		,@table VARCHAR(MAX)
		,@cols VARCHAR(MAX)
		,@userid BIGINT = NULL
)
AS
	-- NS 8/2/2018
	-- >>>>>>>>> NOTES
	-- Transaction error can result from the list of the passing @cols does not match the table schema
	-- MUST : field names that is similar with system names must be used with bracket [] in @fields 

	-- IF @userid is NULL THEN we will truncate @table and insert all #_@table into the @table
	-- IF @userid is NOT NULL THEN
	--			get an @id from the #@table (all records will ahve the same id) then delete @table based on id=@id and insert all #_@table into the @table
BEGIN
	DECLARE @prefix varchar(1000)

	SELECT @prefix = ISNULL(SP_ERROR,'')
	FROM dbo.webservices_requests
	WHERE [ID]=@webservices_requests_id		

	SET @prefix = @prefix + '- shadow_screen_data2 '

	UPDATE dbo.webservices_requests SET SP_Error=@prefix WHERE [ID]=@webservices_requests_id;	

	DECLARE @dsqlstr VARCHAR(MAX), @ssqlstr VARCHAR(MAX)

	-- >>>>>>> Update related data in DM_Shadow_Staging
	SET @ssqlstr = 'INSERT INTO DM_Shadow_Staging.dbo.' + @table + '(' + @cols + ') ' +
				   'SELECT distinct ' + @cols +				   		
				   ' FROM #' + @table
-- DEBUG
--SET @prefix = @ssqlstr
--UPDATE dbo.webservices_requests SET SP_Error=@prefix WHERE [ID]=@webservices_requests_id;
--print @ssqlstr

	IF @userid is NULL
		BEGIN
			SET @dsqlstr = 'TRUNCATE TABLE DM_Shadow_Staging.dbo.' + @table
		END
	ELSE
		BEGIN
			SET @dsqlstr = 'DELETE FROM DM_Shadow_Staging.dbo.' + @table 
				+ ' WHERE [id] IN  (SELECT distinct [ID] FROM #' + @table + ')'
		END

	--exec (@dsqlstr);
	--exec (@ssqlstr);

	BEGIN TRANSACTION transaction1
		BEGIN TRY
			exec (@dsqlstr)
			exec (@ssqlstr)

			COMMIT TRANSACTION transaction1

		END TRY

		BEGIN CATCH
		  ROLLBACK TRANSACTION transaction1
		END CATCH 



	-- >>>>>>>>>> Update related data in DM_Shadow_Production

	SET @ssqlstr = 'INSERT INTO DM_Shadow_Production.dbo.' + @table + '(' + @cols + ') ' +
				   'SELECT distinct ' + @cols +				   		
				   ' FROM #' + @table

	IF @userid is NULL
		BEGIN
			SET @dsqlstr = 'TRUNCATE TABLE DM_Shadow_Production.dbo.' + @table
		END
	ELSE
		BEGIN
			SET @dsqlstr = 'DELETE FROM DM_Shadow_Production.dbo.' + @table 
				+ ' WHERE [id] IN  (SELECT distinct ID FROM #' + @table + ')'
		END

	--exec (@dsqlstr);
	--exec (@ssqlstr);


	BEGIN TRANSACTION transaction2
		BEGIN TRY
			exec (@dsqlstr)
			exec (@ssqlstr)

			COMMIT TRANSACTION transaction2

		END TRY

		BEGIN CATCH
		  ROLLBACK TRANSACTION transaction2
		END CATCH 

	
	-- >>>>>>>>>> SET FACSTAFFID and EDWPERSID
	-- >>>> NS 11/16/2018

		IF @table = '_DM_CONTACT' OR @table = '_DM_PROFILE' OR @table = '_DM_DEG_COMMITTEE' 
		BEGIN

			SET @dsqlstr = 'UPDATE DM_Shadow_Production.dbo.'+@table+' SET FACSTAFFID = U.FACSTAFFID, EDWPERSID=U.EDWPERSID ' +
				' FROM DM_Shadow_Production.dbo._DM_USERS U, DM_Shadow_Production.dbo.'+@table+' F ' +			
				' WHERE U.userid = F.userid AND ( F.FACSTAFFID is NULL OR F.EDWPERSID IS NULL )'

			SET @ssqlstr = 'UPDATE DM_Shadow_Staging.dbo.'+@table+' SET FACSTAFFID = U.FACSTAFFID, EDWPERSID=U.EDWPERSID ' +
				' FROM DM_Shadow_Staging.dbo._DM_USERS U, DM_Shadow_Staging.dbo.'+@table+' F ' +
				' WHERE U.userid = F.userid AND ( F.FACSTAFFID is NULL OR F.EDWPERSID IS NULL )'

			BEGIN TRANSACTION transaction1
				BEGIN TRY
					exec (@dsqlstr)
					exec (@ssqlstr)

					COMMIT TRANSACTION transaction1

				END TRY

				BEGIN CATCH
				  ROLLBACK TRANSACTION transaction1
				END CATCH 
		END

		IF @table = '_DM_CONTACT_OTHER_PHONE' OR @table = '_DM_CONTACT_SOCIAL_MEDIA'
		BEGIN

			SET @dsqlstr = 'UPDATE DM_Shadow_Production.dbo.'+@table+' SET FACSTAFFID = U.FACSTAFFID,EDWPERSID=U.EDWPERSID ' +
				' FROM DM_Shadow_Production.dbo._DM_USERS U, DM_Shadow_Production.dbo.'+@table+' F ' +			
				' WHERE U.USERNAME = F.USERNAME AND ( F.FACSTAFFID is NULL OR F.EDWPERSID IS NULL )'

			SET @ssqlstr = 'UPDATE DM_Shadow_Staging.dbo.'+@table+' SET FACSTAFFID = U.FACSTAFFID,EDWPERSID=U.EDWPERSID' +
				' FROM DM_Shadow_Staging.dbo._DM_USERS U, DM_Shadow_Staging.dbo.'+@table+' F ' +
				' WHERE U.USERNAME = F.USERNAME AND ( F.FACSTAFFID is NULL OR F.EDWPERSID IS NULL)'

			BEGIN TRANSACTION transaction1
				BEGIN TRY
					exec (@dsqlstr)
					exec (@ssqlstr)

					COMMIT TRANSACTION transaction1

				END TRY

				BEGIN CATCH
				  ROLLBACK TRANSACTION transaction1
				END CATCH 
		END


		IF @table = '_DM_INTELLCONT' 
		BEGIN
			UPDATE DM_Shadow_Production.dbo._DM_INTELLCONT
			SET Research_Publication_Type_Name = (select top 1 * from dbo.WP_fn_Parse_CSV (CONTYPE,','))
			UPDATE DM_Shadow_Staging.dbo._DM_INTELLCONT
			SET Research_Publication_Type_Name = (select top 1 * from dbo.WP_fn_Parse_CSV (CONTYPE,','))
		END

/*

-- MODEL
TRUNCATE TABLE dbo._DM_INTELLCONT

INSERT INTO dbo._DM_INTELLCONT
	(
			[id], lastModified, Create_Datetime, Download_Datetime
			,CLASSIFICATION,CONTYPE,ARTICLE_TYPE,TITLE,TITLE_SECONDARY
			,[STATUS],JOURNAL_REF,JOURNAL_ID,JOURNAL_REFEREED,JOURNAL_NAME,JOURNAL_REVIEW_TYPE
			,PUBLISHER,PUBCTYST,VOLUME,ISSUE,PAGENUM
			,REVISED,INVITED,UNDER_REVIEW,EDITORS
			,DTM_PREP,DTY_PREP,DTM_EXPSUB,DTD_EXPSUB,DTY_EXPSUB
			,DTM_SUB,DTD_SUB,DTY_SUB,DTM_ACC,DTY_ACC
			,DTM_PUB,DTD_PUB,DTY_PUB
			,[DESC],SCOPE_LOCALE,PUBLICAVAIL,PROCEEDING_TYPE,ABSTRACT
			,WEB_ADDRESS,SSRN_ID,DOI,ISBNISSN
			--,USER_REFERENCE_CREATOR
	)
SELECT distinct [id], lastModified, getdate(), getdate()
			,CLASSIFICATION,CONTYPE,ARTICLE_TYPE,TITLE,TITLE_SECONDARY
			,[STATUS],JOURNAL_REF,JOURNAL_ID,JOURNAL_REFEREED,JOURNAL_NAME,JOURNAL_REVIEW_TYPE
			,PUBLISHER,PUBCTYST,VOLUME,ISSUE,PAGENUM
			,REVISED,INVITED,UNDER_REVIEW,EDITORS
			,DTM_PREP,DTY_PREP,DTM_EXPSUB,DTD_EXPSUB,DTY_EXPSUB
			,DTM_SUB,DTD_SUB,DTY_SUB,DTM_ACC,DTY_ACC
			,DTM_PUB,DTD_PUB,DTY_PUB
			,[DESC],SCOPE_LOCALE,PUBLICAVAIL,PROCEEDING_TYPE,ABSTRACT
			,WEB_ADDRESS,SSRN_ID,DOI,ISBNISSN 
			--,USER_REFERENCE_CREATOR				
FROM #_DM_INTELLCONT



TRUNCATE TABLE DM_Shadow_Production.dbo._DM_INTELLCONT_AUTH
INSERT INTO DM_Shadow_Production.dbo._DM_INTELLCONT_AUTH
	(
		[id], itemid, lastModified, Create_Datetime
		,FACULTY_NAME,FNAME,MNAME
		,LNAME,INSTITUTION,WEB_PROFILE,sequence
	)
SELECT [id], itemid, lastModified, getdate()
		,FACULTY_NAME,FNAME,MNAME
		,LNAME,INSTITUTION,WEB_PROFILE,sequence
FROM dbo._DM_INTELLCONT_AUTH

	TRUNCATE TABLE dbo._DM_PROFILE
					
	-- Insert major fields in _DM_PROFILE table
	INSERT INTO dbo._DM_PROFILE
		(
			userid, [id], username, lastModified, Create_Datetime, Download_DateTime
			,BIO,PROF_INTERESTS,OTHER_INTERESTS,TEACHING_INTERESTS,RESEARCH_INTERESTS,SPECIALIZATION
		)
	SELECT distinct userid, [id], username, lastModified, getdate(), getdate()
			,BIO,PROF_INTERESTS,OTHER_INTERESTS,TEACHING_INTERESTS,RESEARCH_INTERESTS,SPECIALIZATION		
	FROM #_DM_PROFILE

	-- Update FACSTAFFID and EDWPERSID fields in _DM_PROFILE table
	UPDATE dbo._DM_PROFILE 
	SET FACSTAFFID = U.FACSTAFFID, EDWPERSID=U.EDWPERSID 
	FROM dbo._DM_USERS U, dbo._DM_PROFILE F
	WHERE U.userid = F.userid AND ( F.FACSTAFFID is NULL OR F.EDWPERSID IS NULL )			

	-- Insert records into _DM_PROFILE_LANGUAGES tables
	TRUNCATE TABLE dbo._DM_PROFILE_LANGUAGES
	INSERT INTO dbo._DM_PROFILE_LANGUAGES
		(
				[id], itemid, USERNAME, lastModified, Create_Datetime
				,FLUENCY,[LANGUAGE],LANGUAGE_OTHER					
		)
	SELECT distinct [id], itemid, USERNAME, lastModified, getdate()
				,FLUENCY,[LANGUAGE],LANGUAGE_OTHER								
	FROM #_DM_PROFILE_LANGUAGES


	DELETE FROM TABLE DM_Shadow_Staging.dbo._DM_INTELLCONT_AUTH
	WHERE 



*/

END
GO
