SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 7/30/2018: Added CLASSIFICATION, FSDB_CURRENT
-- NS 7/30/2018: removed SCOPE_LOCALE; added DTM_START, DTM_END
-- NS 10/6/2016: Readying for DM screen availability
--		Underconstruction because waiting for the screen final variables
--		Get XML data from the downloader (SSIS package) insert into _DM_SERVICE_PROFESSIONAL table
/*
	Manual run to shadow individual SERVICE_PROFESSIONAL screen
	EXEC dbo.webservices_initiate @screen='SERVICE_PROFESSIONAL'
	EXEC dbo.webservices_run_DTSX
*/
CREATE PROCEDURE [dbo].[shadow_SERVICE_PROFESSIONAL] (@webservices_requests_id INT,@xml XML,@userid BIGINT=NULL,@resync BIT=NULL) 
AS 

BEGIN

	-- EXEC dbo._Test_Shadow_SERVICE_PROFESSIONAL
	-- GET all SERVICE_PROFESSIONAL data from
	-- https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:nhadi/SERVICE_PROFESSIONAL
	-- XML Sample:
	/*
		This XML file does not appear to have any style information associated with it. The document tree is shown below.
<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-10-06">
<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Career Services" text="Business Career Services" />
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services" />
<SERVICE_PROFESSIONAL id="134117332992" dmd:originalSource="MANUAL" dmd:lastModified="2018-07-30T17:50:31" dmd:startDate="2016-01-01" dmd:endDate="2016-12-31">
<TYPE>EDITORIAL BOARDS - Editor or Co-Editor</TYPE>
<ROLE>Editorial Board</ROLE>
<ORG>CACM</ORG>
<ORG_REPORTABLE>CACM</ORG_REPORTABLE>
<CITY>Sacramento</CITY>
<STATE>California</STATE>
<COUNTRY>United States of America</COUNTRY>
<SCOPE_LOCALE>International</SCOPE_LOCALE>
<CLASSIFICATION>Basic or Discovery Scholarship</CLASSIFICATION>
<DESC>Nano superscale GPS navigation</DESC>
<DTM_START />
<DTY_START />
<START_START />
<START_END />
<DTM_END />
<DTY_END>2016</DTY_END>
<END_START>2016-01-01</END_START>
<END_END>2016-12-31</END_END>
<WEB_PROFILE>Yes</WEB_PROFILE>
<WEB_PROFILE_ORDER>6</WEB_PROFILE_ORDER>
<PERENNIAL>Yes</PERENNIAL>
<FSDB_CURRENT />
 </SERVICE_PROFESSIONAL>
 <SERVICE_PROFESSIONAL id="134117300224" dmd:originalSource="MANUAL" dmd:lastModified="2018-07-30T17:50:39" dmd:startDate="2003-01-01" dmd:endDate="2006-12-31">
<TYPE>CONFERENCES - Conference Moderator</TYPE>
<ROLE>Head Moderator</ROLE>
<ORG>Red Cross Champaign</ORG>
<ORG_REPORTABLE>Red Cross Big Data</ORG_REPORTABLE>
<CITY>Urbana</CITY>
<STATE>Illinois</STATE>
<COUNTRY>United States of America</COUNTRY>
<SCOPE_LOCALE>Regional</SCOPE_LOCALE>
<CLASSIFICATION>Teaching and Learning Scholarship</CLASSIFICATION>
<DESC>member get member</DESC>
<DTM_START />
<DTY_START>2003</DTY_START>
<START_START>2003-01-01</START_START>
<START_END>2003-12-31</START_END>
<DTM_END />
<DTY_END>2006</DTY_END>
<END_START>2006-01-01</END_START>
<END_END>2006-12-31</END_END>
<WEB_PROFILE>No</WEB_PROFILE>
<WEB_PROFILE_ORDER>10</WEB_PROFILE_ORDER>
<PERENNIAL />
<FSDB_CURRENT />
 </SERVICE_PROFESSIONAL>
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
		ISNULL(Item.value('(TYPE/text())[1]','varchar(100)'),'')[TYPE],
		ISNULL(Item.value('(ROLE/text())[1]','varchar(200)'),'')[ROLE],
		ISNULL(Item.value('(ORG_REPORTABLE/text())[1]','varchar(200)'),'')ORG_REPORTABLE,
		ISNULL(Item.value('(ORG/text())[1]','varchar(200)'),'')ORG,
		
		ISNULL(Item.value('(CITY/text())[1]','varchar(100)'),'')CITY,
		ISNULL(Item.value('(STATE/text())[1]','varchar(100)'),'')[STATE],
		ISNULL(Item.value('(COUNTRY/text())[1]','varchar(100)'),'')COUNTRY,
		ISNULL(Item.value('(SCOPE_LOCALE/text())[1]','varchar(60)'),'')SCOPE_LOCALE,
		ISNULL(Item.value('(DESC/text())[1]','varchar(400)'),'')[DESC],	
		ISNULL(Item.value('(CLASSIFICATION/text())[1]','varchar(100)'),'')CLASSIFICATION,	
	
		ISNULL(Item.value('(DTM_START/text())[1]','varchar(12)'),'')DTM_START,
		ISNULL(Item.value('(DTY_START/text())[1]','varchar(4)'),'')DTY_START,
		ISNULL(Item.value('(DTM_END/text())[1]','varchar(12)'),'')DTM_END,
		ISNULL(Item.value('(DTY_END/text())[1]','varchar(4)'),'')DTY_END,
		ISNULL(Item.value('(PERENNIAL/text())[1]','varchar(3)'),'')PERENNIAL,
		ISNULL(Item.value('(WEB_PROFILE/text())[1]','VARCHAR(3)'),'')WEB_PROFILE,
		ISNULL(Item.value('(FSDB_CURRENT/text())[1]','VARCHAR(3)'),'')FSDB_CURRENT,
		ISNULL(Item.value('(WEB_PROFILE_ORDER/text())[1]','INT'),'')WEB_PROFILE_ORDER
		
		
	INTO #_DM_SERVICE_PROFESSIONAL
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./SERVICE_PROFESSIONAL')Items(Item);
	
	ALTER TABLE #_DM_SERVICE_PROFESSIONAL ADD Download_Datetime  Datetime NULL
	UPDATE #_DM_SERVICE_PROFESSIONAL SET Download_Datetime=getdate();

	-- DEBUG
	--SELECT * FROm #_DM_SERVICE_PROFESSIONAL


	DECLARE @fields varchar(2000)

	-- Verify Incoming Data Integrity
	IF @userid IS NULL AND (SELECT COUNT(*) FROM #_DM_SERVICE_PROFESSIONAL) < 1  -- just to make sure we have some records, change the threshold to 10 or more on production
		BEGIN
			UPDATE dbo.webservices_requests SET SP_Error='SERVICE_PROFESSIONAL has no data' WHERE [ID]=@webservices_requests_id			
			RAISERROR('SERVICE_PROFESSIONAL has no Data',18,1)
		END
	-- Delete & Insert the staging data
	ELSE BEGIN
		DECLARE @locked INTEGER;
		EXEC @locked = sp_getapplock 'shadowmaker-SERVICE_PROFESSIONAL','Exclusive','Session',20000; -- 20 second wait
		IF @locked < 0 
			BEGIN
					PRINT 'shadowmaker-SERVICE_PROFESSIONAL Import Locked'
					UPDATE dbo.webservices_requests SET SP_Error='shadowmaker-SERVICE_PROFESSIONAL Import Locked' WHERE [ID]=@webservices_requests_id			
			END
		ELSE BEGIN
			-- UserID or id will be added later depending on idtype (LINKED -> id, otherwise-> username, userID ) 
			SET @fields = 'userName,lastModified,Download_Datetime' +
					',TYPE,ORG,ORG_REPORTABLE,ROLE,CITY' +
					',STATE,COUNTRY,SCOPE_LOCALE,DESC,CLASSIFICATION,DTM_START,DTY_START,DTM_END,DTY_END' +
					',PERENNIAL,WEB_PROFILE,FSDB_CURRENT,WEB_PROFILE_ORDER'

			--EXEC dbo.shadow_screen_data_Import @table='_DM_SERVICE_PROFESSIONAL'
			--	,@idtype=NULL,@cols=@fields,@username=@username
			--	,@userid=@userid,@resync=@resync,@debug=1

			EXEC dbo.shadow_screen_data1 @webservices_requests_id=@webservices_requests_id,@table='_DM_SERVICE_PROFESSIONAL'
				,@idtype=NULL,@cols=@fields
				,@userid=@userid,@resync=@resync,@debug=0

		
			EXEC sp_releaseapplock 'shadowmaker-SERVICE_PROFESSIONAL','Session'; 
		END


	END
	
	DROP TABLE #_DM_SERVICE_PROFESSIONAL;

END



GO
