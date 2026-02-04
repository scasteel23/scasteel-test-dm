SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- 10/15/2018
--		Added <ROLE> under <INTELLCONT_AUTH> with value of EDITOR or AUTHOR
--			==> problematic with a professor who is both author and editor
--		Removed <EDITOR>
-- NS 8/2/2018: tested
--			Added STUDENT_LEVEL
--			removed DTM_PREP,DTY_PREP,DTY_EXPSUB,DTD_SUB,DTD_PUB,ARTICLE_TYPE, (DTM_EXPSUB,DTD_EXPSUB ?)
--			found extra dropped  TITLE_SECONDARY, UNDER_REVIEW, PROCEEDING_TYPE, JOURNAL_REVIEW_TYPE
--			but I still see DTM_EXPSUB,DTD_EXPSUB in XML download
-- NS 10/10/2017 use shadow_screen_data2()
-- NS 10/5/2017
--		Fixed the problem for which this SP works for /login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/INTELLCONT
--		but not for /login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:{username}
-- V2
-- NS 3/23/2017 
--		restructured _DM_INTELLCONT and _DM_INTELLCONT_AUTH tables
--			_DM_INTELLCONT has 1 record for each publication, _DM_INTELLCONT_AUTH ha 1 record for each (author,publication) 
--		rewrote the download codes: @DM_Shadow_Staging database truncate _DM_INTELLCONT and replace with DM XML's records
--		When successful: @DM_Shadow_Production database truncate _DM_INTELLCONT and replace with _DM_INTELLCONT from DM_Shadow_Staging
--		Do the same with _DM_INTELLCONT_AUTH tables
-- NS 3/16/2017: Added to parse <JOURNAL> ... not successful/done yet
-- NS 2/28/2017:  Revised based on the latest DM config as of 2/22/2017
-- NS 9/11/22016: Readying for DM screen availability as publications a.k.a. INTELLCONT screen is being developed by Scott Casteel
--				  Get XML data from the downloader (SSIS package) insert into _DM_INTELLCONT table
--				 

/*
	Manual run to shadow individual INTELLCONT screen
	EXEC dbo.webservices_initiate @screen='INTELLCONT'
	EXEC dbo.webservices_run_DTSX
*/

CREATE PROCEDURE [dbo].[shadow_INTELLCONT] (@webservices_requests_id INT, @xml XML,@userid BIGINT=NULL,@resync BIT=NULL) 
AS 

BEGIN

	-- GET all INTELLCONT data from
	-- https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/INTELLCONT
	-- XML Sample:
/*
	
<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2017-02-28">
<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Career Services" text="Business Career Services" />
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services" />
<INTELLCONT id="138778734592" dmd:originalSource="MANUAL" dmd:lastModified="2018-08-02T16:36:39" dmd:startDate="2016-03-01" dmd:endDate="2016-03-31">
<CONTYPE>Article, Other</CONTYPE>
<TITLE>This is a really long title full of words whose only purpose is to fill space</TITLE>
<STATUS>Published</STATUS>
<JOURNAL_REF>-1</JOURNAL_REF>
<JOURNAL id="138778734596"></JOURNAL>
<PUBLISHER />
<PUBCTYST>Atlantis</PUBCTYST>
<VOLUME>23</VOLUME>
<ISSUE>Spring</ISSUE>
<PAGENUM>334-367</PAGENUM>
<REVISED />
<INVITED />
<CLASSIFICATION />
<INTELLCONT_AUTH id="138778734593"></INTELLCONT_AUTH>
<INTELLCONT_AUTH id="138778734595"></INTELLCONT_AUTH>
<EDITORS />
<DTM_EXPSUB />
<DTY_EXPSUB />
<EXPSUB_START />
<EXPSUB_END />
<DTM_SUB />
<DTY_SUB />
<SUB_START />
<SUB_END />
<DTM_ACC />
<DTY_ACC />
<ACC_START />
<ACC_END />
<DTM_PUB>March</DTM_PUB>
<DTD_PUB />
<DTY_PUB>2016</DTY_PUB>
<PUB_START>2016-03-01</PUB_START>
<PUB_END>2016-03-31</PUB_END>
<DESC />
<SCOPE_LOCALE />
<PUBLICAVAIL />
<ABSTRACT />
<WEB_ADDRESS />
<SSRN />
<DOI />
<ISBNISSN />
<USER_REFERENCE_CREATOR>No</USER_REFERENCE_CREATOR>
 </INTELLCONT>
<INTELLCONT id="144216559616" dmd:originalSource="IMPORT" dmd:lastModified="2018-07-12T11:17:38" dmd:startDate="2015-01-01" dmd:endDate="2015-12-31">
<CONTYPE>Article, Academic Journal</CONTYPE>
<TITLE>article 6</TITLE>
<STATUS>Under Contract</STATUS>
<JOURNAL_REF>-1</JOURNAL_REF>
<PUBCTYST />
<INVITED>No</INVITED>
<INTELLCONT_AUTH id="144216559617">
<FACULTY_NAME>1791140</FACULTY_NAME>
<FNAME>Nursalim</FNAME>
<MNAME />
<LNAME>Hadi</LNAME>
<ROLE>Editor</ROLE>
<WEB_PROFILE>Yes</WEB_PROFILE>
 </INTELLCONT_AUTH>
<DTY_ACC>2015</DTY_ACC>
<ACC_START>2015-01-01</ACC_START>
<ACC_END>2015-12-31</ACC_END>
<PUBLICAVAIL>Yes</PUBLICAVAIL>
<USER_REFERENCE_CREATOR>Yes</USER_REFERENCE_CREATOR>
 </INTELLCONT>
</Record>
</Data>
		
	>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	Parse XML nested <INTELLCONT>
	*/


	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')
	SELECT Record.value('@userId','bigint') userid,
		Record.value('@username','varchar(60)')username,		
		Record.value('@dmd:surveyId','bigint')surveyId,
		Record.value('@termId','bigint')termId,
		Item.value('@id','bigint') id,
		Item.value('@dmd:lastModified','date') lastModified,
		--ISNULL(Item.value('@access','varchar(50)'),'')access,

		ISNULL(Item.value('(CONTYPE/text())[1]','varchar(100)'),'')CONTYPE,
		--ISNULL(Item.value('(ARTICLE_TYPE/text())[1]','varchar(100)'),'')ARTICLE_TYPE,
		ISNULL(Item.value('(TITLE/text())[1]','varchar(400)'),'')TITLE,
		--ISNULL(Item.value('(TITLE_SECONDARY/text())[1]','varchar(400)'),'')TITLE_SECONDARY,
		ISNULL(Item.value('(STATUS/text())[1]','varchar(30)'),'')[STATUS],

		ISNULL(Item.value('(JOURNAL_REF/text())[1]','varchar(30)'),'')JOURNAL_REF,
		/* 
			<JOURNAL @id=567>
				<JOURNAL_NAME>Abracadabra Journal</JOURNAL_NAME>
				<REFEREED>Yes</REFEREED>
				<REVIEW_TYPE>Blind</REVIEW_TYPE>
				<UTDALLAS>true</UTDALLAS>
			</JOURNAL>

		*/
		Item.value('(JOURNAL[1]/@id[1])','bigint') JOURNAL_ID,
		ISNULL(Item.value('JOURNAL[1]/JOURNAL_NAME[1]','varchar(200)'),'')JOURNAL_NAME,
		ISNULL(Item.value('JOURNAL[1]/REFEREED[1]','varchar(30)'),'')JOURNAL_REFEREED,
		--ISNULL(Item.value('JOURNAL[1]/REVIEW_TYPE[1]','varchar(30)'),'')JOURNAL_REVIEW_TYPE,
		--ISNULL(Journal1.value('(JOURNAL_NAME/text())[1]','varchar(200)'),'')JOURNAL_NAME,
		--ISNULL(Journal1.value('(REFEREED/text())[1]','varchar(200)'),'')JOURNAL_REFEREED,
		
		ISNULL(Item.value('(PUBLISHER/text())[1]','varchar(200)'),'')PUBLISHER,
		ISNULL(Item.value('(PUBCTYST/text())[1]','varchar(200)'),'')PUBCTYST,
		ISNULL(Item.value('(VOLUME/text())[1]','varchar(200)'),'')VOLUME,
		ISNULL(Item.value('(ISSUE/text())[1]','varchar(50)'),'')ISSUE,
		ISNULL(Item.value('(PAGENUM/text())[1]','varchar(200)'),'')PAGENUM,
		ISNULL(Item.value('(REVISED/text())[1]','varchar(3)'),'')REVISED,
		ISNULL(Item.value('(INVITED/text())[1]','varchar(3)'),'')INVITED,
		ISNULL(Item.value('(CLASSIFICATION/text())[1]','varchar(100)'),'')CLASSIFICATION,

		--ISNULL(Item.value('(UNDER_REVIEW/text())[1]','varchar(3)'),'')UNDER_REVIEW,
		--ISNULL(Item.value('(EDITORS/text())[1]','varchar(400)'),'')EDITORS,

		ISNULL(Item.value('(DTM_EXPSUB/text())[1]','varchar(60)'),'')DTM_EXPSUB,
		ISNULL(Item.value('(DTY_EXPSUB/text())[1]','varchar(20)'),'')DTY_EXPSUB,

		ISNULL(Item.value('(DTM_SUB/text())[1]','varchar(60)'),'')DTM_SUB,
		ISNULL(Item.value('(DTY_SUB/text())[1]','varchar(20)'),'')DTY_SUB,

		
		ISNULL(Item.value('(DTM_ACC/text())[1]','varchar(60)'),'')DTM_ACC,
		ISNULL(Item.value('(DTY_ACC/text())[1]','varchar(20)'),'')DTY_ACC,

		ISNULL(Item.value('(DTM_PUB/text())[1]','varchar(60)'),'')DTM_PUB,
		ISNULL(Item.value('(DTY_PUB/text())[1]','varchar(20)'),'')DTY_PUB,


		ISNULL(Item.value('(DESC/text())[1]','varchar(400)'),'')[DESC],
		ISNULL(Item.value('(SCOPE_LOCALE/text())[1]','varchar(50)'),'')SCOPE_LOCALE,
		ISNULL(Item.value('(PUBLICAVAIL/text())[1]','varchar(3)'),'')PUBLICAVAIL,
		--ISNULL(Item.value('(PROCEEDING_TYPE/text())[1]','varchar(30)'),'')PROCEEDING_TYPE,
		ISNULL(Item.value('(ABSTRACT/text())[1]','varchar(5000)'),'')ABSTRACT,

		ISNULL(Item.value('(WEB_ADDRESS/text())[1]','varchar(1000)'),'')WEB_ADDRESS,
		ISNULL(Item.value('(SSRN/text())[1]','varchar(200)'),'')SSRN,
		ISNULL(Item.value('(DOI/text())[1]','varchar(200)'),'')DOI,
		ISNULL(Item.value('(ISBNISSN/text())[1]','varchar(200)'),'')ISBNISSN,

		
		ISNULL(Item.value('(USER_REFERENCE_CREATOR/text())[1]','varchar(3)'),'')USER_REFERENCE_CREATOR,
		getdate() as Create_Datetime,
		getdate() as Download_Datetime			
		--ISNULL(Item.value('(PERENNIAL/text())[1]','varchar(3)'),'')PERENNIAL
		
	INTO #_DM_INTELLCONT
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./INTELLCONT')Items(Item);
	--CROSS APPLY Items.Item.nodes('./JOURNAL') Journal1s(Journal1);

	--ALTER TABLE #_DM_INTELLCONT ADD Download_Datetime  Datetime NULL
	--UPDATE #_DM_INTELLCONT SET Download_Datetime=getdate();
	
	-- DEBUG
	SELECT * FROm #_DM_INTELLCONT;

	
	
	/*
		>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		Parse XML nested <INTELLCONT_AUTH> under <INTELLCONT>


		...
	    <INTELLCONT id="138778734592" dmd:lastModified="2017-02-23T11:50:04" dmd:startDate="2016-04-01" dmd:endDate="2016-04-30">
	    ...
	    ...
		<INTELLCONT_AUTH id="138778697729">
		<FACULTY_NAME>1791141</FACULTY_NAME>
		<FNAME>Scott</FNAME>
		<MNAME/>
		<LNAME>Casteel</LNAME>
		<INSTITUTION/>
		<WEB_PROFILE>Yes</WEB_PROFILE>
		</INTELLCONT_AUTH>

		<INTELLCONT_AUTH id="138778697731">
		<FACULTY_NAME/>
		<FNAME/>
		<MNAME/>
		<LNAME>test</LNAME>
		<INSTITUTION/>
		<WEB_PROFILE>Yes</WEB_PROFILE>
		</INTELLCONT_AUTH>  
	    ...
	    </INTELLCONT>
	    ...

	*/

	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')
	SELECT INTELLCONT.value('@id','bigint')id,		-- ok
		INTELLCONT.value('@userid','bigint')userid,
		INTELLCONT.value('@dmd:lastModified','date')lastModified,
		INTELLCONT.value('@username','varchar(60)')USERNAME,
		Item.value('@id','bigint')itemid,	-- ok
		ISNULL(Item.value('LNAME[1]','varchar(120)'),'')LNAME,
		ISNULL(Item.value('FNAME[1]','varchar(120)'),'')FNAME,
		ISNULL(Item.value('MNAME[1]','varchar(120)'),'')MNAME,
		ISNULL(Item.value('FACULTY_NAME[1]','varchar(60)'),'')FACULTY_NAME,
		ISNULL(Item.value('INSTITUTION[1]','varchar(200)'),'')INSTITUTION,
		ISNULL(Item.value('ROLE[1]','varchar(30)'),'')[ROLE],	
		ISNULL(Item.value('STUDENT_LEVEL[1]','varchar(30)'),'')STUDENT_LEVEL,		
		ISNULL(Item.value('WEB_PROFILE[1]','varchar(3)'),'')WEB_PROFILE,
		ROW_NUMBER()OVER(PARTITION BY INTELLCONT ORDER BY Item)sequence,
		getdate() as Create_Datetime,
		getdate() as Download_Datetime		
	INTO #_DM_INTELLCONT_AUTH
	FROM @xml.nodes('/Data/Record/INTELLCONT')INTELLCONTs(INTELLCONT)
		CROSS APPLY INTELLCONTs.INTELLCONT.nodes('./INTELLCONT_AUTH')Items(Item);
--print '[shadow_INTELLCONT]1'
	--ALTER TABLE #_DM_INTELLCONT_AUTH ADD Download_Datetime  Datetime NULL
	--UPDATE #_DM_INTELLCONT_AUTH SET Download_Datetime=getdate();
--print '[shadow_INTELLCONT]2'

	--SELECT * from #_DM_INTELLCONT

	DECLARE @tolerance INT
	DECLARE @fields varchar(3000), @fields2 varchar(3000)

	-- Copy to the production if number of the new records is greater than 80% of number of the current records
	-- SET @tolerance = 0.8 
	SET @tolerance = 0.8
	
	-- Verify Incoming Data Integrity
	IF @userid IS NULL AND (SELECT COUNT(*) FROM #_DM_INTELLCONT) < 2 
		BEGIN
			UPDATE dbo.webservices_requests SET SP_Error='INTELLCONT has no data' WHERE [ID]=@webservices_requests_id			
			RAISERROR('INTELLCONT has no Data',18,1)
		END
	-- Delete & Insert the staging data
	ELSE BEGIN
		DECLARE @locked INTEGER;
		EXEC @locked = sp_getapplock 'shadowmaker-INTELLCONT','Exclusive','Session',20000; -- 20 second wait
		IF @locked < 0 
				BEGIN
					PRINT 'shadowmaker-INTELLCONT Import Locked'
					UPDATE dbo.webservices_requests SET SP_Error='shadowmaker-INTELLCONT Import Locked' WHERE [ID]=@webservices_requests_id			
				END
		ELSE BEGIN
			
			IF @userid is not null
				BEGIN
					-- Update records of @userid at Main tables _DM_INTELLCONT in DM_Shadow_Staging and DM_Shadow_Production databases
					-- Transaction error can result from the list of the @fields does not match table schema
					-- MUST use field names that is similar with system names with bracket [] in @fields
					SET @fields = 'id,lastModified,Create_Datetime,Download_Datetime,CLASSIFICATION,CONTYPE,TITLE' +
									 ',[STATUS],JOURNAL_REF,JOURNAL_ID,JOURNAL_REFEREED,JOURNAL_NAME' +
									 ',PUBLISHER,PUBCTYST,VOLUME,ISSUE,PAGENUM' +
									 --',REVISED,INVITED,EDITORS' +
									 ',REVISED,INVITED' +
									 ',DTM_SUB,DTY_SUB,DTM_ACC,DTY_ACC,DTM_PUB,DTY_PUB,DTM_EXPSUB,DTY_EXPSUB' +
									 ',[DESC],SCOPE_LOCALE,PUBLICAVAIL,ABSTRACT' +
									 ',WEB_ADDRESS,SSRN,DOI,ISBNISSN'
					EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
					    ,@table='_DM_INTELLCONT'
						,@cols=@fields
						,@userid=@userid
--print '[shadow_INTELLCONT]3'

					-- Update records of @userid at relational tables _DM_INTELLCONT_AUTH in DM_Shadow_Staging and DM_Shadow_Production databases		  
					-- MUST USE [ ] for system name to pass thru shadow_screen_data2  
					SET @fields = 'id,itemid,lastModified,Create_Datetime,Download_Datetime' +
									',FACULTY_NAME,FNAME,MNAME' +
									',LNAME,INSTITUTION,STUDENT_LEVEL,[ROLE],WEB_PROFILE,sequence'
					EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
					    ,@table='_DM_INTELLCONT_AUTH'
						,@cols=@fields
						,@userid=@userid

--print '[shadow_INTELLCONT]4'
				END
			ELSE
				BEGIN
					DECLARE @current_record_main_count INT, @new_record_main_count INT, @current_record_phone_count INT
					DECLARE @current_record_auth_count INT, @new_record_auth_count INT 

					SELECT @current_record_main_count = count(*)
					FROM DM_Shadow_Production.dbo._DM_INTELLCONT

					SELECT @new_record_main_count = count(*)
					FROM #_DM_INTELLCONT

					SELECT @current_record_auth_count = count(*)
					FROM DM_Shadow_Production.dbo._DM_INTELLCONT_AUTH

					SELECT @new_record_auth_count = count(*)
					FROM #_DM_INTELLCONT_AUTH

					--SET @current_record_main_count = 40
					--SET @new_record_main_count = 35

					SET @current_record_main_count = @tolerance * @current_record_main_count
					SET @current_record_auth_count = @tolerance * @current_record_auth_count
			
						IF @new_record_main_count >= @current_record_main_count
								AND  @new_record_auth_count >= @current_record_auth_count

						BEGIN
						
							-- Truncate and Insert into Main tables _DM_INTELLCONT in DM_Shadow_Staging and DM_Shadow_Production databases											
							SET @fields = 'id,lastModified,Create_Datetime,Download_Datetime,CLASSIFICATION,CONTYPE,TITLE' +
									 ',[STATUS],JOURNAL_REF,JOURNAL_ID,JOURNAL_REFEREED,JOURNAL_NAME' +
									 ',PUBLISHER,PUBCTYST,VOLUME,ISSUE,PAGENUM' +
									 --',REVISED,INVITED,EDITORS' +
									 ',REVISED,INVITED' +
									 ',DTM_SUB,DTY_SUB,DTM_ACC,DTY_ACC,DTM_PUB,DTY_PUB,DTM_EXPSUB,DTY_EXPSUB' +
									 ',[DESC],SCOPE_LOCALE,PUBLICAVAIL,ABSTRACT' +
									 ',WEB_ADDRESS,SSRN,DOI,ISBNISSN'
							EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
							    ,@table='_DM_INTELLCONT'
								,@cols=@fields
								,@userid=NULL

							-- Truncate and Insert into Relational tables _DM_INTELLCONT_AUTH in DM_Shadow_Staging and DM_Shadow_Production databases							
							SET @fields = 'id,itemid,lastModified,Create_Datetime,Download_Datetime' +
											',FACULTY_NAME,FNAME,MNAME' +
											',LNAME,INSTITUTION,STUDENT_LEVEL,[ROLE],WEB_PROFILE,sequence'
							EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
							    ,@table='_DM_INTELLCONT_AUTH'
								,@cols=@fields
								,@userid=NULL

							-- Extract all Journal_Name from dbo._DM_INTELLCONT and
							--	Insert new Journal_Name and Journal_Name_Short at dbo.FSDB_Journal_Web_IDs table accordingly
							INSERT INTO dbo.FSDB_Journal_Web_IDs
								  (Journal_Name
								  ,Journal_Name_Short  
								  ,Create_Datetime
								  ,Active_Indicator)
							SELECT DISTINCT JOURNAL_NAME, '', getdate(),1
							FROM dbo._DM_INTELLCONT
							WHERE Journal_Name <> '' 
								AND Journal_Name is not null
								AND Journal_Name NOT IN (SELECT JOURNAL_NAME FROM FSDB_Journal_Web_IDs)

							UPDATE dbo.FSDB_Journal_Web_IDs
							SET Journal_Name_Short = dbo.WP_fn_first_letters_in_string(Journal_Name)
							WHERE Journal_Name_Short IS NULL OR Journal_Name_Short=''

	
						END
					ELSE
						BEGIN
							UPDATE dbo.webservices_requests SET SP_Error='INTELLCONT Data is too few' WHERE [ID]=@webservices_requests_id		
							RAISERROR('shadow_INTELLCONT - Data is too few',18,1)
						END
					
				END	

				EXEC sp_releaseapplock 'shadowmaker-INTELLCONT','Session'; 
		END



	END
	
	

	DROP TABLE #_DM_INTELLCONT;
	DROP TABLE #_DM_INTELLCONT_AUTH

END



GO
