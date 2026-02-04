SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- V2
-- NS 9/19/2017: Done, worked!
-- NS 7/27/2017: Get the final screen/SchemaEntity definition, not testet yet
-- NS 4/25/22016:
CREATE PROCEDURE [dbo].[_Decommissioned_shadow_PROFILE_v2] (@webservices_requests_id INT, @xml XML,@userid BIGINT=NULL,@resync BIT=NULL) 
AS 

BEGIN

	-- GET  	<BIO/>, <SPECIALIZATION/>, <OTHER_INTERESTS/>, <TEACHING_INTERESTS/>, <RESEARCH_INTERESTS/>, <LANGUAGES/>
			
	-- https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/PROFILE
	-- XML Sample:
	/*

	<Data dmd:date="2017-07-27">
	<Record userId="1940570" username="rashad" termId="6117" dmd:surveyId="17825311">
	<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy" />
	<PROFILE id="146245117952" dmd:originalSource="IMPORT" dmd:lastModified="2017-07-27T16:22:05">
		<BIO><p><font face="Tahoma"><b>A. Rashad Abdel-khalik</b> is a professor of accountancy and the Director of the V. K Zimmerman Center for International Education and Research in Accounting at the University of Illinois at Urbana-Champaign. He earned his undergraduate degree in commerce from Cairo University, an M.B.A. (Accounting) and an M.A. (Economics) from Indiana University-Bloomington, and a Ph.D. (Accountancy) from the University of Illinois at Urbana-Champaign. He taught at Illinois, Columbia University, Duke University, and the University of Florida before returning to the University of Illinois.</font></p><p><font face="Tahoma">Professor Abdel-khalik has published articles in <em>The Accounting Review</em>, <em>Journal of Accounting Research</em>, <em>Contemporary Research in Accounting</em>, <em>Decision Sciences</em>, <em>Organization Studies</em> and the <em>European Accounting Review</em> and has authored and co-authored research studies published by the American Accounting Association and the Financial Accounting Standards Board. He is currently the Editor of the <em>International Journal of Accounting</em> and has served as the founding editor of <em>Journal of Accounting Literature</em> and editor of <em>The Accounting Review</em>, the quarterly research journal of the American Accounting Association. His research interests are in the areas of financial accounting and reporting.</font></p></BIO>
		<SPECIALIZATION />
		<PROF_INTERESTS />
		<RESEARCH_INTERESTS>Accounting Reporting Risk, Empirical Research in Accounting, Research Methodology, Accounting Theory, and Current Issues in Financial Reporting.</RESEARCH_INTERESTS>
		<TEACHING_INTERESTS>Currently: Accounting for Risk and Hedge Accounting; Empirical Research in Accounting Previously: Taught courses on the following subjects: Principles of Accounting, Principles of Economics, Intermediate Microeconomics; Intermiediate Macroeconomics, Introductory Statistics (a two-course sequence), Money and Banking, Intermediate Accounting, Accounting Theory, Management Control Systems, Financial Research in Accounting, Managerial Research in Accounting, Issues and Cases in Accounting, Controllership, and Advanced Accounting Analysis; and Analysis of Financial Statements</TEACHING_INTERESTS>
		<OTHER_INTERESTS />
		<LANGUAGES id="146245117953">
			<FLUENCY>Native or Bilingual</FLUENCY>
			<LANGUAGE>Arabic</LANGUAGE>
			<LANGUAGE_OTHER />
		</LANGUAGES>
		<LANGUAGES id="146245117955">
			<FLUENCY>Full Professional</FLUENCY>
			<LANGUAGE>English</LANGUAGE>
			<LANGUAGE_OTHER />
			</LANGUAGES>
		<LANGUAGES id="146245117956">
			<FLUENCY>Limited Working</FLUENCY>
			<LANGUAGE>French</LANGUAGE>
			<LANGUAGE_OTHER />
		</LANGUAGES>
	</PROFILE>
	</Record>
	</Data>	
		*/

	DECLARE @prefix varchar(1000)
	SELECT @prefix = SP_ERROR FROM dbo.webservices_requests WHERE [ID]=@webservices_requests_id		
	SET @prefix = @prefix + '- shadow_PROFILE '
	UPDATE dbo.webservices_requests SET SP_Error=@prefix WHERE [ID]=@webservices_requests_id;	

	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')
	SELECT Record.value('@userId','bigint') userid,
		Record.value('@username','varchar(60)')username,		
		Record.value('@dmd:surveyId','bigint')surveyId,
		Record.value('@termId','bigint')termId,
		Item.value('@id','bigint') id,
		Item.value('@dmd:lastModified','date') lastModified,
		ISNULL(Item.value('@access','varchar(50)'),'')access,
	
		ISNULL(Item.value('(BIO/text())[1]','varchar(MAX)'),'')BIO,
		ISNULL(Item.value('(PROF_INTERESTS/text())[1]','varchar(MAX)'),'')PROF_INTERESTS,
		ISNULL(Item.value('(OTHER_INTERESTS/text())[1]','varchar(MAX)'),'')OTHER_INTERESTS,
		ISNULL(Item.value('(TEACHING_INTERESTS/text())[1]','varchar(MAX)'),'')TEACHING_INTERESTS,
		ISNULL(Item.value('(RESEARCH_INTERESTS/text())[1]','varchar(MAX)'),'')RESEARCH_INTERESTS,
		ISNULL(Item.value('(SPECIALIZATION/text())[1]','varchar(1000)'),'')SPECIALIZATION
			
	INTO #_DM_PROFILE
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./PROFILE')Items(Item);
	
	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')	
	SELECT PROFILE.value('@id','bigint')id,
		REC.value('@userId','bigint')userid,
		PROFILE.value('@dmd:lastModified','date')lastModified,
		REC.value('@username','varchar(60)')USERNAME,
		Item.value('@id','bigint')itemid,
		ISNULL(Item.value('FLUENCY[1]','varchar(100)'),'')FLUENCY,
		ISNULL(Item.value('LANGUAGE[1]','varchar(100)'),'')[LANGUAGE],
		ISNULL(Item.value('LANGUAGE_OTHER[1]','varchar(100)'),'')LANGUAGE_OTHER,		
		ROW_NUMBER()OVER(PARTITION BY PROFILE ORDER BY Item)sequence	
	INTO #_DM_PROFILE_LANGUAGES
	FROM @xml.nodes('/Data/Record')Recs(REC)
		CROSS APPLY Recs.Rec.nodes('./PROFILE')PROFILEs(PROFILE)
		CROSS APPLY PROFILEs.PROFILE.nodes('./LANGUAGES')Items(Item);

	-- cannot get the userId and USERNAME
	--WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')	
	--SELECT PROFILE.value('@id','bigint')id,
	--	PROFILE.value('@userid','bigint')userid,
	--	PROFILE.value('@dmd:lastModified','date')lastModified,
	--	PROFILE.value('@username','varchar(60)')USERNAME,
	--	Item.value('@id','bigint')itemid,
	--	ISNULL(Item.value('FLUENCY[1]','varchar(100)'),'')FLUENCY,
	--	ISNULL(Item.value('LANGUAGE[1]','varchar(100)'),'')[LANGUAGE],
	--	ISNULL(Item.value('LANGUAGE_OTHER[1]','varchar(100)'),'')LANGUAGE_OTHER,		
	--	ROW_NUMBER()OVER(PARTITION BY PROFILE ORDER BY Item)sequence	
	--INTO #_DM_PROFILE_LANGUAGES
	--FROM @xml.nodes('/Data/Record/PROFILE')PROFILEs(PROFILE)
	--	CROSS APPLY PROFILEs.PROFILE.nodes('./LANGUAGES')Items(Item);

	DECLARE @tolerance INT

	-- Copy to the production if number of the new records is greater than 80% of number of the current records
	-- SET @tolerance = 0.8 
	SET @tolerance = 0.8

	-- Verify Incoming Data Integrity
	IF @userid IS NULL AND (SELECT COUNT(*) FROM #_DM_PROFILE) < 10  -- just to make sure we have some records, change the threshold to 10 or more on production
		BEGIN
			UPDATE dbo.webservices_requests SET SP_Error=@prefix + ': PROFILE has no data' WHERE [ID]=@webservices_requests_id			
			RAISERROR('PROFILE has no Data',18,1)
		END
	-- Delete & Insert the staging data
	ELSE BEGIN
		DECLARE @locked INTEGER;
		EXEC @locked = sp_getapplock 'shadowmaker-PROFILE','Exclusive','Session',20000; -- 20 second wait
		IF @locked < 0 
			BEGIN
					PRINT 'shadowmaker-PROFILE Import Locked'
					UPDATE dbo.webservices_requests SET SP_Error=@prefix + ': shadowmaker-PROFILE Import Locked' WHERE [ID]=@webservices_requests_id			
			END
		ELSE BEGIN
			
			DECLARE @current_record_main_count INT, @new_record_main_count INT, @current_record_phone_count INT
			DECLARE @current_record_languages_count INT, @new_record_languages_count INT 

			SELECT @current_record_main_count = count(*)
			FROM DM_Shadow_Production.dbo._DM_PROFILE

			SELECT @new_record_main_count = count(*)
			FROM #_DM_PROFILE

			SELECT @current_record_languages_count = count(*)
			FROM DM_Shadow_Production.dbo._DM_PROFILE_LANGUAGES

			SELECT @new_record_languages_count = count(*)
			FROM #_DM_PROFILE_LANGUAGES

			--SET @current_record_main_count = 40
			--SET @new_record_main_count = 35

			BEGIN TRY
				SET @current_record_main_count = @tolerance * @current_record_main_count
				SET @current_record_languages_count = @tolerance * @current_record_languages_count
			
				IF @new_record_main_count >= @current_record_main_count
						AND  @new_record_languages_count >= @current_record_languages_count

					BEGIN
						-- Copy to the production if number of the new records is greater than 80% of number of the current records
						-- Now we can copy FROM (#_DM_PROFILE,  and #_DM_PROFILE_LANGUAGES) 
						--		TO (_DM_PROFILE, and _DM_PROFILE_LANGUAGES)

						-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
						-- @DM_Shadow_Staging database
						-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

				

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



						-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
						-- @DM_Shadow_Production database
						-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
						TRUNCATE TABLE DM_Shadow_Production.dbo._DM_PROFILE

						INSERT INTO DM_Shadow_Production.dbo._DM_PROFILE
							(
								userid, [id], username, lastModified, Create_Datetime, Download_DateTime
								,BIO,PROF_INTERESTS,OTHER_INTERESTS,TEACHING_INTERESTS,RESEARCH_INTERESTS,SPECIALIZATION
							)
						SELECT  userid, [id], username, lastModified, Create_Datetime, Download_DateTime
								,BIO,PROF_INTERESTS,OTHER_INTERESTS,TEACHING_INTERESTS,RESEARCH_INTERESTS,SPECIALIZATION
						FROM dbo._DM_PROFILE
												
						UPDATE DM_Shadow_Production.dbo._DM_PROFILE
						SET FACSTAFFID = U.FACSTAFFID, EDWPERSID=U.EDWPERSID 
						FROM DM_Shadow_Production.dbo._DM_USERS U, DM_Shadow_Production.dbo._DM_PROFILE F
						WHERE U.userid = F.userid AND ( F.FACSTAFFID is NULL OR F.EDWPERSID IS NULL )

						TRUNCATE TABLE DM_Shadow_Production.dbo._DM_PROFILE_LANGUAGES
						INSERT INTO DM_Shadow_Production.dbo._DM_PROFILE_LANGUAGES
							(
								 [id], itemid, USERNAME, lastModified, Create_Datetime
								,FLUENCY,[LANGUAGE],LANGUAGE_OTHER				
							)
						SELECT  distinct [id], USERNAME, itemid, lastModified, getdate()
								 ,FLUENCY,[LANGUAGE],LANGUAGE_OTHER			
						FROM dbo._DM_PROFILE_LANGUAGES

					END
				ELSE
					BEGIN
						UPDATE dbo.webservices_requests SET SP_Error=@prefix + ': shadow_PROFILE Data is too few' WHERE [ID]=@webservices_requests_id		
						RAISERROR('Data is too few',18,1)
					END
			END TRY

			BEGIN CATCH
			    DECLARE @emsg varchar(MAX)
				SET @emsg = LEFT(ERROR_MESSAGE(), 500)
				UPDATE dbo.webservices_requests SET SP_Error=@prefix + ': ' + @emsg WHERE [ID]=@webservices_requests_id	
			END CATCH

			EXEC sp_releaseapplock 'shadowmaker-PROFILE','Session'; 
		END

	END

	UPDATE dbo.webservices_requests SET SP_Error=@prefix + ': shadow_PROFILE Done' WHERE [ID]=@webservices_requests_id		


	-- DEBUG
	--SELECT * FROm #_DM_PROFILE

	
	--DECLARE @fields varchar(2000)

	---- Verify Incoming Data Integrity
	--IF @userid IS NULL AND (SELECT COUNT(*) FROM #_DM_PROFILE) < 3 RAISERROR('No Data',18,1) -- just to make sure we have some records, change the threshold to 10 or more on production
	---- Delete & Insert the staging data
	--ELSE BEGIN
	--	DECLARE @locked INTEGER;
	--	EXEC @locked = sp_getapplock 'shadowmaker-BIO','Exclusive','Session',20000; -- 20 second wait
	--	IF @locked < 0 PRINT 'Import Locked';
	--	ELSE BEGIN
	--		-- UserID or id will be added later depending on idtype (LINKED -> id, otherwise-> username, userID ) 
	--		SET @fields = 'userName,surveyID,termID,lastModified' +					
	--				',BIO_SKETCH,PROF_INTERESTS,TEACHING_INTERESTS,RESEARCH_INTERESTS' 
	--		--EXEC dbo.shadow_screen_data_Import @table='_DM_PROFILE'
	--		--	,@idtype=NULL,@cols=@fields,@username=@username
	--		--	,@userid=@userid,@resync=@resync,@debug=1

	--		EXEC dbo.shadow_screen_data @table='_DM_PROFILE'
	--			,@idtype=NULL,@cols=@fields
	--			,@userid=@userid,@resync=@resync,@debug=0

	--		EXEC sp_releaseapplock 'shadowmaker-BIO','Session'; 
	--	END
	--END

	
	DROP TABLE #_DM_PROFILE;
	DROP TABLE #_DM_PROFILE_LANGUAGES;

END



GO
