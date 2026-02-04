SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- V2
-- NS 3/23/2017 
--		restructured _DM_CONGRANT and _DM_CONGRANT_INVEST tables
--			_DM_CONGRANT has 1 record for each grant, _DM_CONGRANT_INVEST ha 1 record for each (investigator,grant) 
--		rewrote the download codes: @DM_Shadow_Staging database truncate _DM_CONGRANT and replace with DM XML's records
--		When successful: @DM_Shadow_Production database truncate _DM_CONGRANT and replace with _DM_CONGRANT from DM_Shadow_Staging
--		Did the same with _DM_CONGRANT_INVEST tables
-- NS 2/28/2017: Replaced CONTYPE with CLASSIFICATION, Removed WEB_PROFILE_ORDER
--				 CLASSIFICATION is used for AACSB Classificaton it is Research_Publication_Contribution_Type
--	1  Basic or Discovery Scholarship
--	2  Applied or Integration/Application Scholarship
--	3  Teaching and Learning Scholarship
--	4  NULL
-- NS 10/31/2016: it worked! but... need to initialize sequence based on id on _DM_CONGRANT_INVEST
-- NS 10/24/2016: Screen is ready @DM, get the XML data
-- NS 10/12/2016: New, copied from PRESENT
--				  Get XML data from the downloader (SSIS package) insert into _DM_CONGRANT table

CREATE PROCEDURE [dbo].[_Decommissioned_shadow_CONGRANT_v2] (@webservices_requests_id INT, @xml XML,@userid BIGINT=NULL,@resync BIT=NULL) 
AS 

BEGIN

	-- TRUNCATE TABle _DM_CONGRANT_INVEST
	-- TRUNCATE TABLE _DM_CONGRANT
	-- EXEC dbo._Test_Shadow_GRANT

	-- GET all GRANT data from
	-- https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/CONGRANT
	-- XML Sample:
/*
	USERNAME, 
	,FACSTAFF_ID, EDW_PERS_ID  
	,SPONORG, TITLE, AMOUNT, CLASSIFICATION, [STATUS]
	,DTY_START, DTY_END
	
<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-10-24">
<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy"/>
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Administration" text="Business Administration"/>
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services"/>			

<CONGRANT id="135061223424" dmd:lastModified="2016-10-24T12:35:07" dmd:startDate="2015-01-01" dmd:endDate="2016-12-31">
<TITLE>Using Google Analytics to track web haters</TITLE>
<STATUS>Awarded</STATUS>
<SPONORG>Google</SPONORG>

<CONGRANT_INVEST id="135061223425">
<FACULTY_NAME>1791140</FACULTY_NAME>
<FNAME>Nursalim</FNAME>
<MNAME/>
<LNAME>Hadi</LNAME>
<ROLE>Principal</ROLE>
</CONGRANT_INVEST>

<CONGRANT_INVEST id="135061223427">
<FACULTY_NAME>1791141</FACULTY_NAME>
<FNAME>Scott</FNAME>
<MNAME/>
<LNAME>Casteel</LNAME>
<ROLE>Co-Principal</ROLE>
</CONGRANT_INVEST>

<CONGRANT_INVEST id="135061223428">
<FACULTY_NAME/>
<FNAME>Jayesh</FNAME>
<MNAME/>
<LNAME>Krishna</LNAME>
<ROLE>Supporting</ROLE>
</CONGRANT_INVEST>

<CONGRANT_INVEST id="135061223429">
<FACULTY_NAME/>
<FNAME>Rudi</FNAME>
<MNAME/>
<LNAME>Giulani</LNAME>
<ROLE>Co-Principal</ROLE>
</CONGRANT_INVEST>

<AMOUNT>12000</AMOUNT>
<CLASSIFICATION>Learning & Pedagogical</CLASSIFICATION>
<DTY_START>2015</DTY_START>
<START_START>2015-01-01</START_START>
<START_END>2015-12-31</START_END>
<DTY_END>2016</DTY_END>
<END_START>2016-01-01</END_START>
<END_END>2016-12-31</END_END>

<WEB_PROFILE>Yes</WEB_PROFILE>

<USER_REFERENCE_CREATOR>Yes</USER_REFERENCE_CREATOR>
</CONGRANT>

<CONGRANT id="135061225472" dmd:lastModified="2016-10-24T12:36:40" dmd:startDate="2014-01-01" dmd:endDate="2016-12-31">
<TITLE>Map Entrepreneurship Program Distribution</TITLE>
<STATUS>Awaiting Decision</STATUS>
<SPONORG>Kauffman Foundation</SPONORG>

<CONGRANT_INVEST id="135061225473">
<FACULTY_NAME>1791140</FACULTY_NAME>
<FNAME>Nursalim</FNAME>
<MNAME/>
<LNAME>Hadi</LNAME>
<ROLE/>
</CONGRANT_INVEST>
<CONGRANT_INVEST id="135061225475">
<FACULTY_NAME>1791141</FACULTY_NAME>
<FNAME>Scott</FNAME>
<MNAME/>
<LNAME>Casteel</LNAME>
<ROLE>Supporting</ROLE>
</CONGRANT_INVEST>
<AMOUNT>12000</AMOUNT>
<CLASSIFICATION>Contributions to Practice</CLASSIFICATION>
<DTY_START>2014</DTY_START>
<START_START>2014-01-01</START_START>
<START_END>2014-12-31</START_END>
<DTY_END>2016</DTY_END>
<END_START>2016-01-01</END_START>
<END_END>2016-12-31</END_END>
<WEB_PROFILE>Yes</WEB_PROFILE>

<USER_REFERENCE_CREATOR>Yes</USER_REFERENCE_CREATOR>
</CONGRANT>

<CONGRANT id="135061227520" dmd:lastModified="2016-10-24T12:37:18" dmd:startDate="2013-01-01" dmd:endDate="2015-12-31">
<TITLE>Using Google Analytics to track web haters</TITLE>
<STATUS>Awarded</STATUS>
<SPONORG>Google</SPONORG>

<CONGRANT_INVEST id="135061227521">
<FACULTY_NAME>1791140</FACULTY_NAME>
<FNAME>Nursalim</FNAME>
<MNAME/>
<LNAME>Hadi</LNAME>
<ROLE>Principal</ROLE>
</CONGRANT_INVEST>
<CONGRANT_INVEST id="135061227523">
<FACULTY_NAME>1791141</FACULTY_NAME>
<FNAME>Scott</FNAME>
<MNAME/>
<LNAME>Casteel</LNAME>
<ROLE>Co-Principal</ROLE>
</CONGRANT_INVEST>
<CONGRANT_INVEST id="135061227524">
<FACULTY_NAME/>
<FNAME>Jayesh</FNAME>
<MNAME/>
<LNAME>Krishna</LNAME>
<ROLE>Supporting</ROLE>
</CONGRANT_INVEST>
<CONGRANT_INVEST id="135061227525">
<FACULTY_NAME/>
<FNAME>Rudi</FNAME>
<MNAME/>
<LNAME>Giulani</LNAME>
<ROLE>Co-Principal</ROLE>
</CONGRANT_INVEST>
<AMOUNT>12000</AMOUNT>
<CLASSIFICATION>Learning & Pedagogical</CLASSIFICATION>
<DTY_START>2013</DTY_START>
<START_START>2013-01-01</START_START>
<START_END>2013-12-31</START_END>
<DTY_END>2015</DTY_END>
<END_START>2015-01-01</END_START>
<END_END>2015-12-31</END_END>
<WEB_PROFILE>Yes</WEB_PROFILE>

<USER_REFERENCE_CREATOR>Yes</USER_REFERENCE_CREATOR>
</CONGRANT>

<CONGRANT id="135061229568" dmd:lastModified="2016-10-24T12:37:41" dmd:startDate="2009-01-01" dmd:endDate="2011-12-31">
<TITLE>Using Google Analytics to track web haters</TITLE>
<STATUS>Awarded</STATUS>
<SPONORG>Google</SPONORG>

<CONGRANT_INVEST id="135061229569">
<FACULTY_NAME>1791140</FACULTY_NAME>
<FNAME>Nursalim</FNAME>
<MNAME/>
<LNAME>Hadi</LNAME>
<ROLE>Principal</ROLE>
</CONGRANT_INVEST>

<CONGRANT_INVEST id="135061229571">
<FACULTY_NAME>1791141</FACULTY_NAME>
<FNAME>Scott</FNAME>
<MNAME/>
<LNAME>Casteel</LNAME>
<ROLE>Co-Principal</ROLE>
</CONGRANT_INVEST>

<CONGRANT_INVEST id="135061229572">
<FACULTY_NAME/>
<FNAME>Jayesh</FNAME>
<MNAME/>
<LNAME>Krishna</LNAME>
<ROLE>Supporting</ROLE>
</CONGRANT_INVEST>

<CONGRANT_INVEST id="135061229573">
<FACULTY_NAME/>
<FNAME>Rudi</FNAME>
<MNAME/>
<LNAME>Giulani</LNAME>
<ROLE>Co-Principal</ROLE>
</CONGRANT_INVEST>

<AMOUNT>12000</AMOUNT>
<CLASSIFICATION>Learning & Pedagogical</CLASSIFICATION>
<DTY_START>2009</DTY_START>
<START_START>2009-01-01</START_START>
<START_END>2009-12-31</START_END>
<DTY_END>2011</DTY_END>
<END_START>2011-01-01</END_START>
<END_END>2011-12-31</END_END>
<WEB_PROFILE>Yes</WEB_PROFILE>

<USER_REFERENCE_CREATOR>Yes</USER_REFERENCE_CREATOR>
</CONGRANT>

		
</Record>
</Data>
	*/



	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')
	SELECT Record.value('@userId','bigint') userid,
		Record.value('@username','varchar(60)')username,		
		Record.value('@dmd:surveyId','bigint')surveyId,
		Record.value('@termId','bigint')termId,
		Item.value('@id','bigint') id,
		Item.value('@dmd:lastModified','date') lastModified,
		--ISNULL(Item.value('@access','varchar(50)'),'')access,

		ISNULL(Item.value('(TITLE/text())[1]','varchar(1000)'),'')TITLE,
		ISNULL(Item.value('(SPONORG/text())[1]','varchar(200)'),'')SPONORG,
		ISNULL(Item.value('(AMOUNT/text())[1]','varchar(20)'),'')AMOUNT,
		ISNULL(Item.value('(CLASSIFICATION/text())[1]','varchar(100)'),'')CLASSIFICATION,
		ISNULL(Item.value('(STATUS/text())[1]','varchar(20)'),'')[STATUS],
		ISNULL(Item.value('(ROLE/text())[1]','varchar(100)'),'')[ROLE],
		ISNULL(Item.value('(DTY_START/text())[1]','varchar(4)'),'')DTY_START,
		ISNULL(Item.value('(DTY_END/text())[1]','varchar(4)'),'')DTY_END,

		ISNULL(Item.value('(USER_REFERENCE_CREATOR/text())[1]','varchar(3)'),'')USER_REFERENCE_CREATOR

	INTO #_DM_CONGRANT
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./CONGRANT')Items(Item);


	
	-- DEBUG
	--SELECT * FROm #_DM_CONGRANT

	
	-- >>>>>>>>>>>>>>>>>>>>>
	--   This is how to parse/process sub-screens; Sample XML

	--    <Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-06-21">
	--    <Record userId="1791141" username="scasteel" termId="6117" dmd:surveyId="17698890">
	--    <PCI id="125211813888" dmd:lastModified="2016-05-10T13:58:33">
	--    ...
	--    ...
	--    <RESEARCH_KEYWORD id="64225812483">
	--      <KEYWORD access="READ_ONLY">Personal & Social Issues: Conceptual Change</KEYWORD>
	--    </RESEARCH_KEYWORD>
	--    <RESEARCH_KEYWORD id="64225812484">
	--      <KEYWORD access="READ_ONLY">Curriculum Issues: Curriculum</KEYWORD>
	--    </RESEARCH_KEYWORD>
	--    <RESEARCH_KEYWORD id="64225812485">
	--      <KEYWORD access="READ_ONLY">Curriculum Areas: Science Ed</KEYWORD>
	--    </RESEARCH_KEYWORD>
	--    ...
	--    ...
	--    </PCI>
	--    </Record>
	--    </Data>

	-- >>>>>>>>>>>>>>>>>>>>>
	--
	---- AUTHORS[web_profile]
	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')
	
	SELECT CONGRANT.value('@id','bigint')id,
		CONGRANT.value('@userid','bigint')userid,
		CONGRANT.value('@dmd:lastModified','date')lastModified,
		CONGRANT.value('@username','varchar(60)')USERNAME,
		Item.value('@id','bigint')itemid,
		ISNULL(Item.value('LNAME[1]','varchar(200)'),'')LNAME,
		ISNULL(Item.value('FNAME[1]','varchar(200)'),'')FNAME,
		ISNULL(Item.value('MNAME[1]','varchar(200)'),'')MNAME,
		ISNULL(Item.value('FACULTY_NAME[1]','varchar(60)'),'')FACULTY_NAME,
		ISNULL(Item.value('WEB_PROFILE[1]','varchar(3)'),'')WEB_PROFILE,
		ISNULL(Item.value('ROLE[1]','varchar(100)'),'')[ROLE],
		ROW_NUMBER()OVER(PARTITION BY CONGRANT ORDER BY Item)sequence	
	INTO #_DM_CONGRANT_INVEST
	FROM @xml.nodes('/Data/Record/CONGRANT')CONGRANTs(CONGRANT)
		CROSS APPLY CONGRANTs.CONGRANT.nodes('./CONGRANT_INVEST')Items(Item);
	
	-- DEBUG
	--SELECT * FROm #_DM_CONGRANT_INVEST

	---- LINKS
	--WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')
	--SELECT PCI.value('@id','bigint')id,
	--	Item.value('@id','bigint')itemid,
	--	ISNULL(Item.value('NAME[1]','varchar(150)'),'')NAME,
	--	ISNULL(Item.value('URL[1]','varchar(255)'),'')URL,
	--	ROW_NUMBER()OVER(PARTITION BY PCI.value('@id','bigint') ORDER BY Item)sequence
	--INTO #LINKS
	--FROM @xml.nodes('/Data/Record/PCI')PCIs(PCI)
	--	CROSS APPLY PCIs.PCI.nodes('./LINK')Items(Item);

	DECLARE @tolerance INT
	-- Copy to the production if number of the new records is greater than 80% of number of the current records
	-- SET @tolerance = 0.8 
	SET @tolerance = 0.8


	-- Verify Incoming Data Integrity
	IF @userid IS NULL AND (SELECT COUNT(*) FROM #_DM_CONGRANT) < 1 
		BEGIN	
			UPDATE dbo.webservices_requests SET SP_Error='CONGRANT has no data' WHERE [ID]=@webservices_requests_id
			RAISERROR('CONGRANT has no Data',18,1)
		END
	-- Delete & Insert the staging data
	ELSE BEGIN

		DECLARE @locked INTEGER;
		EXEC @locked = sp_getapplock 'shadowmaker-CONGRANT','Exclusive','Session',20000; -- 20 second wait
		IF @locked < 0 PRINT 'Import Locked';IF @locked < 0 
				BEGIN
					PRINT 'shadowmaker-CONGRANT Import Locked'
					UPDATE dbo.webservices_requests SET SP_Error='shadowmaker-CONGRANT Import Locked' WHERE [ID]=@webservices_requests_id			
				END
		ELSE BEGIN




		DECLARE @current_record_main_count INT, @new_record_main_count INT, @current_record_phone_count INT
			DECLARE @current_record_auth_count INT, @new_record_auth_count INT 

			SELECT @current_record_main_count = count(*)
			FROM DM_Shadow_Production.dbo._DM_CONGRANT

			SELECT @new_record_main_count = count(*)
			FROM #_DM_CONGRANT

			SELECT @current_record_auth_count = count(*)
			FROM DM_Shadow_Production.dbo._DM_CONGRANT_INVEST

			SELECT @new_record_auth_count = count(*)
			FROM #_DM_CONGRANT_INVEST

			--SET @current_record_main_count = 40
			--SET @new_record_main_count = 35

			SET @current_record_main_count = @tolerance * @current_record_main_count
			SET @current_record_auth_count = @tolerance * @current_record_auth_count
			
			IF @new_record_main_count >= @current_record_main_count
						AND  @new_record_auth_count >= @current_record_auth_count

				BEGIN
					-- we can copy FROM (#_DM_CONGRANT, and #_DM_CONGRANT_INVEST) TO (_DM_CONGRANT, and _DM_CONGRANT_INVEST)

					-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
					-- @DM_Shadow_Staging database
					-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
					TRUNCATE TABLE dbo._DM_CONGRANT

					INSERT INTO dbo._DM_CONGRANT
						(
							[id], lastModified
							,TITLE,SPONORG,AMOUNT,CLASSIFICATION,[STATUS],[ROLE]                          
							,DTY_START,DTY_END,Create_Datetime, Download_Datetime
							--,USER_REFERENCE_CREATOR
						)
					SELECT distinct [id], lastModified
							,TITLE,SPONORG,AMOUNT,CLASSIFICATION,[STATUS],[ROLE]                          
							,DTY_START,DTY_END, getdate(), getdate()
							 --,USER_REFERENCE_CREATOR				
					FROM #_DM_CONGRANT
									
				
					--UPDATE dbo._DM_CONGRANT 
					--	SET FACSTAFFID = U.FACSTAFFID, EDWPERSID=U.EDWPERSID 
					--FROM dbo._DM_USERS U, dbo._DM_CONGRANT F
					--WHERE U.userid = F.userid AND ( F.FACSTAFFID is NULL OR F.EDWPERSID IS NULL )			

					TRUNCATE TABLE dbo._DM_CONGRANT_INVEST
					INSERT INTO dbo._DM_CONGRANT_INVEST
						(
							 [id], itemid, lastModified, Create_Datetime
							 ,FACULTY_NAME,FNAME,MNAME
							 ,LNAME,[ROLE],WEB_PROFILE,sequence
						)
					SELECT distinct [id], itemid, lastModified, getdate()
							 ,FACULTY_NAME,FNAME,MNAME
							 ,LNAME,[ROLE],WEB_PROFILE,sequence
					FROM #_DM_CONGRANT_INVEST

					-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
					-- @DM_Shadow_Production database
					-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
					TRUNCATE TABLE DM_Shadow_Production.dbo._DM_CONGRANT

					INSERT INTO DM_Shadow_Production.dbo._DM_CONGRANT
						(
							[id], lastModified
							,TITLE,SPONORG,AMOUNT,CLASSIFICATION,[STATUS],[ROLE]                          
							,DTY_START,DTY_END,Create_Datetime,Download_Datetime
							 --,USER_REFERENCE_CREATOR
						)
					SELECT  [id], lastModified
							,TITLE,SPONORG,AMOUNT,CLASSIFICATION,[STATUS],[ROLE]                          
							,DTY_START,DTY_END,Create_Datetime,Download_Datetime
							 --,USER_REFERENCE_CREATOR				
					FROM dbo._DM_CONGRANT
												
					--UPDATE DM_Shadow_Production.dbo._DM_CONGRANT
					--SET FACSTAFFID = U.FACSTAFFID, EDWPERSID=U.EDWPERSID 
					--FROM DM_Shadow_Production.dbo._DM_USERS U, DM_Shadow_Production.dbo._DM_CONGRANT F
					--WHERE U.userid = F.userid AND ( F.FACSTAFFID is NULL OR F.EDWPERSID IS NULL )

					TRUNCATE TABLE DM_Shadow_Production.dbo._DM_CONGRANT_INVEST
					INSERT INTO DM_Shadow_Production.dbo._DM_CONGRANT_INVEST
						(
							 [id], itemid, lastModified, Create_Datetime
							 ,FACULTY_NAME,FNAME,MNAME
							 ,LNAME,[ROLE],WEB_PROFILE,sequence
						)
					SELECT  [id], itemid, lastModified, getdate()
							 ,FACULTY_NAME,FNAME,MNAME
							 ,LNAME,[ROLE],WEB_PROFILE,sequence
					FROM dbo._DM_CONGRANT_INVEST

				END
			ELSE
				BEGIN
					UPDATE dbo.webservices_requests SET SP_Error='CONGRANT Data is too few' WHERE [ID]=@webservices_requests_id		
					RAISERROR('shadow_CONGRANT - Data is too few',18,1)
				END

			EXEC sp_releaseapplock 'shadowmaker-CONGRANT','Session'; 
		END



	END
	
	
	DROP TABLE #_DM_CONGRANT;
	DROP TABLE #_DM_CONGRANT_INVEST;
	--DROP TABLE #LINKS;

END



GO
