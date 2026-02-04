SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 7/30/2018: added FSDB_CURRENT
-- NS 7/10/2018
-- NS 10/6/2016: Test worked!
--				 Get XML data from the downloader (SSIS package) insert into _DM_SERVICE_ACADEMIC table
--		Underconstruction because waiting for the beta.digitalmeasures.com to be ready
--		Need to change on the screen:
--			START DATE to START YEAR
--			END DATE to END YEAR

/*
	Manual run to shadow individual SERVICE_ACADEMIC screen
	EXEC dbo.webservices_initiate @screen='SERVICE_ACADEMIC'
	EXEC dbo.webservices_run_DTSX
*/

CREATE PROCEDURE [dbo].[shadow_SERVICE_ACADEMIC] (@webservices_requests_id INT,@xml XML,@userid BIGINT=NULL,@resync BIT=NULL) 
AS 

BEGIN

	-- EXEC dbo._Test_Shadow_SERVICE_ACADEMIC
	-- GET all SERVICE_ACADEMIC data from
	-- https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:nhadi/SERVICE_ACADEMIC
	-- XML Sample:
	/*
		This XML file does not appear to have any style information associated with it. The document tree is shown below.
<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-10-06">
<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Career Services" text="Business Career Services" />
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services" />
<SERVICE_ACADEMIC id="166435889152" dmd:originalSource="MANUAL" dmd:lastModified="2018-07-10T13:30:07" dmd:startDate="2016-01-01" dmd:endDate="2019-05-31">
<TYPE>Service at Other Academic Organization</TYPE>
<ROLE>Board of Trustee</ROLE>
<ORG>University of Small Enterprise</ORG>
<ORG_REPORTABLE>University of Small Enterprise</ORG_REPORTABLE>
<CITY>Chicago</CITY>
<STATE>Illinois</STATE>
<COUNTRY>United States of America</COUNTRY>
<SCOPE>University</SCOPE>
<DESC>This is a new university created for Small Enterpreneurships</DESC>
<DTM_START />
<DTY_START>2016</DTY_START>
<START_START>2016-01-01</START_START>
<START_END>2016-12-31</START_END>
<DTM_END>May</DTM_END>
<DTY_END>2019</DTY_END>
<END_START>2019-05-01</END_START>
<END_END>2019-05-31</END_END>
<WEB_PROFILE>No</WEB_PROFILE>
<WEB_PROFILE_ORDER>2</WEB_PROFILE_ORDER>
<PERENNIAL>No</PERENNIAL>
 </SERVICE_ACADEMIC>
<SERVICE_ACADEMIC id="134285971456" dmd:lastModified="2018-07-10T13:28:09" dmd:startDate="2015-01-01" dmd:endDate="2016-04-30">
<TYPE>Advisor/Sponsor/Mentor</TYPE>
<ROLE>SBC University Preparation Team</ROLE>
<ORG>SBC University</ORG>
<ORG_REPORTABLE>SBC University</ORG_REPORTABLE>
<CITY>Melbourne</CITY>
<STATE />
<COUNTRY>Australia</COUNTRY>
<SCOPE />
<DESC>this is a prestigious fictional university</DESC>
<DTM_START>January</DTM_START>
<DTY_START>2015</DTY_START>
<START_START>2015-01-01</START_START>
<START_END>2015-01-31</START_END>
<DTM_END>April</DTM_END>
<DTY_END>2016</DTY_END>
<END_START>2016-04-01</END_START>
<END_END>2016-04-30</END_END>
<WEB_PROFILE>No</WEB_PROFILE>
<WEB_PROFILE_ORDER>5</WEB_PROFILE_ORDER>
<PERENNIAL>Yes</PERENNIAL>
 </SERVICE_ACADEMIC>
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
		ISNULL(Item.value('(ROLE/text())[1]','varchar(1000)'),'')[ROLE],
		ISNULL(Item.value('(ORG_REPORTABLE/text())[1]','varchar(200)'),'')ORG_REPORTABLE,
		ISNULL(Item.value('(ORG/text())[1]','varchar(200)'),'')ORG,
		
		ISNULL(Item.value('(CITY/text())[1]','varchar(100)'),'')CITY,
		ISNULL(Item.value('(STATE/text())[1]','varchar(100)'),'')[STATE],
		ISNULL(Item.value('(COUNTRY/text())[1]','varchar(100)'),'')COUNTRY,
		ISNULL(Item.value('(SCOPE/text())[1]','varchar(60)'),'')SCOPE,
		ISNULL(Item.value('(DESC/text())[1]','varchar(1000)'),'')[DESC],	
	
		ISNULL(Item.value('(DTM_START/text())[1]','varchar(12)'),'')DTM_START,
		ISNULL(Item.value('(DTY_START/text())[1]','varchar(4)'),'')DTY_START,
		ISNULL(Item.value('(DTM_END/text())[1]','varchar(12)'),'')DTM_END,
		ISNULL(Item.value('(DTY_END/text())[1]','varchar(4)'),'')DTY_END,
		ISNULL(Item.value('(PERENNIAL/text())[1]','varchar(3)'),'')PERENNIAL,
		ISNULL(Item.value('(WEB_PROFILE/text())[1]','VARCHAR(3)'),'')WEB_PROFILE,
		ISNULL(Item.value('(FSDB_CURRENT/text())[1]','VARCHAR(3)'),'')FSDB_CURRENT,
		ISNULL(Item.value('(WEB_PROFILE_ORDER/text())[1]','INT'),'')WEB_PROFILE_ORDER
		
		
	INTO #_DM_SERVICE_ACADEMIC
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./SERVICE_ACADEMIC')Items(Item);
	
	ALTER TABLE #_DM_SERVICE_ACADEMIC ADD Download_Datetime  Datetime NULL
	UPDATE #_DM_SERVICE_ACADEMIC SET Download_Datetime=getdate();

	-- DEBUG
	--SELECT * FROm #_DM_SERVICE_ACADEMIC


	DECLARE @fields varchar(2000)

	-- Verify Incoming Data Integrity
	IF @userid IS NULL AND (SELECT COUNT(*) FROM #_DM_SERVICE_ACADEMIC) < 1 -- just to make sure we have some records, change the threshold to 10 or more on production
		BEGIN
			UPDATE dbo.webservices_requests SET SP_Error='SERVICE_ACADEMIC has no data' WHERE [ID]=@webservices_requests_id			
			RAISERROR('SERVICE_ACADEMIC has no Data',18,1)
		END
	-- Delete & Insert the staging data
	ELSE BEGIN
		DECLARE @locked INTEGER;
		EXEC @locked = sp_getapplock 'shadowmaker-SERVICE_ACADEMIC','Exclusive','Session',20000; -- 20 second wait
		IF @locked < 0 
			BEGIN
					PRINT 'shadowmaker-SERVICE_ACADEMIC Import Locked'
					UPDATE dbo.webservices_requests SET SP_Error='shadowmaker-SERVICE_ACADEMIC Import Locked' WHERE [ID]=@webservices_requests_id			
			END
		ELSE BEGIN
			-- UserID or id will be added later depending on idtype (LINKED -> id, otherwise-> username, userID ) 
			-- NO blank or empty spaces, no [ ] sign for system variable names
			SET @fields = 'userName,lastModified,Download_Datetime' +
					',TYPE,ORG,ORG_REPORTABLE,ROLE,CITY' +
					',STATE,COUNTRY,SCOPE,DESC,DTM_START,DTY_START,DTM_END,DTY_END' +
					',PERENNIAL,WEB_PROFILE,FSDB_CURRENT,WEB_PROFILE_ORDER'

			--EXEC dbo.shadow_screen_data_Import @table='_DM_SERVICE_ACADEMIC'
			--	,@idtype=NULL,@cols=@fields,@username=@username
			--	,@userid=@userid,@resync=@resync,@debug=1

			EXEC dbo.shadow_screen_data1 @webservices_requests_id=@webservices_requests_id, @table='_DM_SERVICE_ACADEMIC'
				,@idtype=NULL,@cols=@fields
				,@userid=@userid,@resync=@resync,@debug=0

		
			EXEC sp_releaseapplock 'shadowmaker-SERVICE_ACADEMIC','Session'; 
		END


	END
	
	DROP TABLE #_DM_SERVICE_ACADEMIC;

END



GO
