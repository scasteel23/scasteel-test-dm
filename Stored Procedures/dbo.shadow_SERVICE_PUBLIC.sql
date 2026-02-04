SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 7/30/2018: Added CLASSIFICATION, FSDB_CURRENT
-- NS 7/3/2018: new
/*
	Manual run to shadow individual SERVICE_PUBLIC screen
	EXEC dbo.webservices_initiate @screen='SERVICE_PUBLIC'
	EXEC dbo.webservices_run_DTSX
*/
CREATE PROCEDURE [dbo].[shadow_SERVICE_PUBLIC] (@webservices_requests_id INT,@xml XML,@userid BIGINT=NULL,@resync BIT=NULL) 
AS 

BEGIN

	-- EXEC dbo._Test_Shadow_SERVICE_PUBLIC
	-- GET all SERVICE_PUBLIC data from
	-- https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:nhadi/SERVICE_PUBLIC
	-- XML Sample:
	/*
		This XML file does not appear to have any style information associated with it. The document tree is shown below.
<Data dmd:date="2018-07-03">
	<Record userId="1910556" username="busfac1" termId="6117" dmd:surveyId="17699128">
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy" />
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Administration" text="Business Administration" />
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Finance" text="Finance" />
		<SERVICE_PUBLIC id="163082776576" dmd:originalSource="MANAGE_DATA" dmd:lastModified="2018-07-03T14:05:14" dmd:startDate="2009-01-01" dmd:endDate="2013-03-31">
			<TYPE>Other Community or Public Service</TYPE>
			<ROLE>Finance Advisory Committee</ROLE>
			<ORG>University Laboratory High School, Urbana, IL</ORG>
			<ORG_REPORTABLE>University Laboratory High School, Urbana, IL</ORG_REPORTABLE>
			<CITY>Urbana</CITY>
			<STATE>Illinois</STATE>
			<COUNTRY>United States of America</COUNTRY>
			<SCOPE>Local</SCOPE>
			<COMPENSATED>Compensated</COMPENSATED>
			<NUMHOURS_YEARLY>200</NUMHOURS_YEARLY>
			<DESC>Mentoring</DESC>
			<DTM_START>January</DTM_START>
			<DTY_START>2009</DTY_START>
			<START_START>2009-01-01</START_START>
			<START_END>2009-01-31</START_END>
			<DTM_END>March</DTM_END>
			<DTY_END>2013</DTY_END>
			<END_START>2013-03-01</END_START>
			<END_END>2013-03-31</END_END>
			<WEB_PROFILE>No</WEB_PROFILE>
			<WEB_PROFILE_ORDER>1</WEB_PROFILE_ORDER>
			<PERENNIAL>Yes</PERENNIAL>
		</SERVICE_PUBLIC>
	</Record>
	<Record userId="1997303" username="ambauer" termId="6117" dmd:surveyId="17886929">
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy" />
		<SERVICE_PUBLIC id="163082692608" dmd:originalSource="IMPORT" dmd:lastModified="2018-05-08T09:11:12" dmd:startDate="2007-01-01" dmd:endDate="2011-12-31">
			<TYPE>Other Community or Public Service</TYPE>
			<ROLE>Director</ROLE>
			<ORG>Waterloo County Rugby Football Club</ORG>
			<ORG_REPORTABLE>Waterloo County Rugby Football Club</ORG_REPORTABLE>
			<DTY_START>2007</DTY_START>
			<START_START>2007-01-01</START_START>
			<START_END>2007-12-31</START_END>
			<DTY_END>2011</DTY_END>
			<END_START>2011-01-01</END_START>
			<END_END>2011-12-31</END_END>
			<WEB_PROFILE>No</WEB_PROFILE>
			<WEB_PROFILE_ORDER>1</WEB_PROFILE_ORDER>
			<PERENNIAL>No</PERENNIAL>
		</SERVICE_PUBLIC>
		<SERVICE_PUBLIC id="163082698752" dmd:originalSource="IMPORT" dmd:lastModified="2018-05-08T09:11:12" dmd:startDate="2005-01-01" dmd:endDate="2011-12-31">
			<TYPE>Other Community or Public Service</TYPE>
			<ROLE>Treasurer</ROLE>
			<ORG>Waterloo County Rugby Football Club</ORG>
			<ORG_REPORTABLE>Waterloo County Rugby Football Club</ORG_REPORTABLE>
			<DTY_START>2005</DTY_START>
			<START_START>2005-01-01</START_START>
			<START_END>2005-12-31</START_END>
			<DTY_END>2011</DTY_END>
			<END_START>2011-01-01</END_START>
			<END_END>2011-12-31</END_END>
			<WEB_PROFILE>No</WEB_PROFILE>
			<WEB_PROFILE_ORDER>1</WEB_PROFILE_ORDER>
			<PERENNIAL>No</PERENNIAL>
		</SERVICE_PUBLIC>
		<SERVICE_PUBLIC id="163082686464" dmd:originalSource="IMPORT" dmd:lastModified="2018-05-08T09:11:12" dmd:startDate="2008-01-01" dmd:endDate="2008-12-31">
			<TYPE>Other Community or Public Service</TYPE>
			<ROLE>Student Member</ROLE>
			<ORG>University of Waterloo Athletics Team-Up Youth Program</ORG>
			<ORG_REPORTABLE>University of Waterloo Athletics Team-Up Youth Program</ORG_REPORTABLE>
			<CITY>Waterloo</CITY>
			<STATE>Ontario</STATE>
			<COUNTRY>Canada</COUNTRY>
			<DTY_END>2008</DTY_END>
			<END_START>2008-01-01</END_START>
			<END_END>2008-12-31</END_END>
			<WEB_PROFILE>No</WEB_PROFILE>
			<WEB_PROFILE_ORDER>1</WEB_PROFILE_ORDER>
			<PERENNIAL>No</PERENNIAL>
		</SERVICE_PUBLIC>
	 </Record>
 </DATA>
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
		ISNULL(Item.value('(SCOPE/text())[1]','varchar(100)'),'')SCOPE,
		ISNULL(Item.value('(DESC/text())[1]','varchar(1000)'),'')[DESC],
		ISNULL(Item.value('(CLASSIFICATION/text())[1]','varchar(1000)'),'')CLASSIFICATION,	
		ISNULL(Item.value('(COMPENSATED/text())[1]','varchar(30)'),'')COMPENSATED,
		ISNULL(Item.value('(NUMHOURS_YEARLY/text())[1]','varchar(20)'),'')NUMHOURS_YEARLY,
	
		ISNULL(Item.value('(DTM_START/text())[1]','varchar(12)'),'')DTM_START,
		ISNULL(Item.value('(DTY_START/text())[1]','varchar(4)'),'')DTY_START,
		ISNULL(Item.value('(DTM_END/text())[1]','varchar(12)'),'')DTM_END,
		ISNULL(Item.value('(DTY_END/text())[1]','varchar(4)'),'')DTY_END,		
		ISNULL(Item.value('(WEB_PROFILE/text())[1]','VARCHAR(3)'),'')WEB_PROFILE,
		ISNULL(Item.value('(WEB_PROFILE_ORDER/text())[1]','INT'),'')WEB_PROFILE_ORDER,
		ISNULL(Item.value('(FSDB_CURRENT/text())[1]','INT'),'')FSDB_CURRENT,
		ISNULL(Item.value('(PERENNIAL/text())[1]','varchar(3)'),'')PERENNIAL
		
		
	INTO #_DM_SERVICE_PUBLIC
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./SERVICE_PUBLIC')Items(Item);
	
	ALTER TABLE #_DM_SERVICE_PUBLIC ADD Download_Datetime  Datetime NULL
	UPDATE #_DM_SERVICE_PUBLIC SET Download_Datetime=getdate();

	-- DEBUG
	--SELECT * FROm #_DM_SERVICE_PUBLIC


	DECLARE @fields varchar(2000)
	DECLARE @prefix varchar(1000)
	SELECT @prefix = ISNULL(SP_ERROR,'') FROM dbo.webservices_requests WHERE [ID]=@webservices_requests_id		
	SET @prefix = @prefix + ' - SERVICE_PUBLIC starts '
	UPDATE dbo.webservices_requests SET SP_Error=@prefix WHERE [ID]=@webservices_requests_id	

	-- Verify Incoming Data Integrity
	IF @userid IS NULL AND (SELECT COUNT(*) FROM #_DM_SERVICE_PUBLIC) < 1  -- just to make sure we have some records, change the threshold to 10 or more on production
		BEGIN
			UPDATE dbo.webservices_requests SET SP_Error='SERVICE_PUBLIC has no data' WHERE [ID]=@webservices_requests_id			
			RAISERROR('SERVICE_PUBLIC has no Data',18,1)
		END
	-- Delete & Insert the staging data
	ELSE BEGIN
		DECLARE @locked INTEGER;
		EXEC @locked = sp_getapplock 'shadowmaker-SERVICE_PUBLIC','Exclusive','Session',20000; -- 20 second wait
		IF @locked < 0 
			BEGIN
					PRINT 'shadowmaker-SERVICE_PUBLIC Import Locked'
					UPDATE dbo.webservices_requests SET SP_Error='shadowmaker-SERVICE_PUBLIC Import Locked' WHERE [ID]=@webservices_requests_id			
			END
		ELSE BEGIN
			-- UserID or id will be added later depending on idtype (LINKED -> id, otherwise-> username, userID ) 
			SET @fields = 'userName,lastModified,Download_Datetime' +
					',TYPE,ROLE,ORG,ORG_REPORTABLE,CITY,CLASSIFICATION' +
					',STATE,COUNTRY,SCOPE,COMPENSATED,NUMHOURS_YEARLY,DESC,DTM_START,DTY_START,DTM_END,DTY_END' +
					',PERENNIAL,WEB_PROFILE,FSDB_CURRENT,WEB_PROFILE_ORDER'

			--EXEC dbo.shadow_screen_data_Import @table='_DM_SERVICE_PUBLIC'
			--	,@idtype=NULL,@cols=@fields,@username=@username
			--	,@userid=@userid,@resync=@resync,@debug=1

			EXEC dbo.shadow_screen_data1 @webservices_requests_id=@webservices_requests_id,@table='_DM_SERVICE_PUBLIC'
				,@idtype=NULL,@cols=@fields
				,@userid=@userid,@resync=@resync,@debug=0

			SET @prefix = @prefix + ' - SERVICE_PUBLIC done '
			UPDATE dbo.webservices_requests SET SP_Error=@prefix WHERE [ID]=@webservices_requests_id
	
			EXEC sp_releaseapplock 'shadowmaker-SERVICE_PUBLIC','Session'; 
		END


	END
	
	DROP TABLE #_DM_SERVICE_PUBLIC;

END



GO
