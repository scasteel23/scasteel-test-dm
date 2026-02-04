SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- NS 7/30/2018: removed SCOPE_LOCALE; added DTM_START, DTM_END
-- NS 9/9/22016: New, worked
--				 Get XML data from the downloader (SSIS package) insert into _DM_FACDEV table

/*
	Manual run to shadow individual FACDEV screen
	EXEC dbo.webservices_initiate @screen='FACDEV'
	EXEC dbo.webservices_run_DTSX
*/

CREATE PROCEDURE [dbo].[shadow_FACDEV] (@webservices_requests_id INT,@xml XML,@userid BIGINT=NULL,@resync BIT=NULL) 
AS 
BEGIN
	-- GET all FACDEV data from
	-- https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/FACDEV
	-- Parse the incoming XML
	/*
	XML Sample
	<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-09-09">
	<Record userId="1791141" username="scasteel" termId="6117" dmd:surveyId="17698890">
		<FACDEV id="132759838720" dmd:lastModified="2016-08-30T16:59:28" dmd:startDate="2013-01-01" dmd:endDate="2014-12-31">
			<TYPE>Professional Conference/Meeting/Seminar/Workshop</TYPE>
			<TYPEOTHER/>
			<TITLE>Microsoft Windows 10</TITLE>
			<ORG>Microsoft</ORG>
			<CITY>Chicago</CITY>
			<STATE>Illinois</STATE>
			<COUNTRY>United States of America</COUNTRY>
			<CHOURS>12</CHOURS>
			<DESC>import test 1</DESC>
			
			<CPE>Yes</CPE>
			<DTY_START>2013</DTY_START>
			<START_START>2013-01-01</START_START>
			<START_END>2013-12-31</START_END>
			<DTY_END>2014</DTY_END>
			<END_START>2014-01-01</END_START>
			<END_END>2014-12-31</END_END>
			<WEB_PROFILE>Yes</WEB_PROFILE>
		</FACDEV>
	</Record>
	<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy"/>
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Administration" text="Business Administration"/>
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services"/>
		<FACDEV id="130927077376" dmd:lastModified="2016-08-30T16:57:31" dmd:startDate="2017-01-01" dmd:endDate="2018-12-31">
			<TYPE>Professional Conference/Meeting/Seminar/Workshop</TYPE>
			<TYPEOTHER/>
			<TITLE>Microsoft Windows 10</TITLE>
			<ORG>Microsoft</ORG>
			<CITY>Chicago</CITY>
			<STATE>Illinois</STATE>
			<COUNTRY>United States of America</COUNTRY>
			<CHOURS>16</CHOURS>
			<DESC>import test 1</DESC>
			<CPE>Yes</CPE>
			<DTY_START>2017</DTY_START>
			<START_START>2017-01-01</START_START>
			<START_END>2017-12-31</START_END>
			<DTY_END>2018</DTY_END>
			<END_START>2018-01-01</END_START>
			<END_END>2018-12-31</END_END>
			<WEB_PROFILE>Yes</WEB_PROFILE>
		</FACDEV>
		<FACDEV id="132759840768" dmd:lastModified="2016-08-30T16:59:28" dmd:startDate="2015-01-01" dmd:endDate="2016-12-31">
			<TYPE>Professional Conference/Meeting/Seminar/Workshop</TYPE>
			<TYPEOTHER/>
			<TITLE>Microsoft Windows 10</TITLE>
			<ORG>Microsoft</ORG>
			<CITY>Chicago</CITY>
			<STATE>Illinois</STATE>
			<COUNTRY>United States of America</COUNTRY>
			<CHOURS>12</CHOURS>
			<DESC>import test 1</DESC>
			
			<CPE>Yes</CPE>
			<DTY_START>2015</DTY_START>
			<START_START>2015-01-01</START_START>
			<START_END>2015-12-31</START_END>
			<DTY_END>2016</DTY_END>
			<END_START>2016-01-01</END_START>
			<END_END>2016-12-31</END_END>
			<WEB_PROFILE>Yes</WEB_PROFILE>
		</FACDEV>
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
		ISNULL(Item.value('(TYPE/text())[1]','varchar(100)'),'')[TYPE],
		ISNULL(Item.value('(TYPEOTHER/text())[1]','varchar(100)'),'')TYPEOTHER,
		ISNULL(Item.value('(TITLE/text())[1]','varchar(400)'),'')TITLE,
		ISNULL(Item.value('(ORG/text())[1]','varchar(200)'),'')ORG,
		ISNULL(Item.value('(CITY/text())[1]','varchar(100)'),'')CITY,
		ISNULL(Item.value('(STATE/text())[1]','varchar(100)'),'')[STATE],
		ISNULL(Item.value('(COUNTRY/text())[1]','varchar(100)'),'')COUNTRY,
		ISNULL(Item.value('(CHOURS/text())[1]','varchar(10)'),'')CHOURS,
		ISNULL(Item.value('(DESC/text())[1]','varchar(2000)'),'')[DESC],
		
		ISNULL(Item.value('(CPE/text())[1]','varchar(3)'),'')CPE,
		ISNULL(Item.value('(DTM_START/text())[1]','varchar(12)'),'')DTM_START,
		ISNULL(Item.value('(DTY_START/text())[1]','varchar(4)'),'')DTY_START,
		ISNULL(Item.value('(DTM_END/text())[1]','varchar(12)'),'')DTM_END,
		ISNULL(Item.value('(DTY_END/text())[1]','varchar(4)'),'')DTY_END,
		ISNULL(Item.value('(WEB_PROFILE/text())[1]','varchar(3)'),'')WEB_PROFILE
		--Item.value('(WEB_PROFILE_ORDER/text())[1]','bigint')WEB_PROFILE_ORDER
	INTO #_DM_FACDEV
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./FACDEV')Items(Item);
	
	ALTER TABLE #_DM_FACDEV ADD Download_Datetime  Datetime NULL
	UPDATE #_DM_FACDEV SET Download_Datetime=getdate();

	DECLARE @fields varchar(2000)

	-- Verify Incoming Data Interity
	IF @userid IS NULL AND (SELECT COUNT(*) FROM #_DM_FACDEV)<2 
		BEGIN	
			UPDATE dbo.webservices_requests SET SP_Error='FACDEV has no data' WHERE [ID]=@webservices_requests_id	
			RAISERROR('FACDEV has no Data',18,1)
		END
	-- Delete & Insert the staging data
	ELSE 
		BEGIN
			DECLARE @locked INTEGER;
			EXEC @locked = sp_getapplock 'shadowmaker-facdev','Exclusive','Session',20000; -- 20 second wait
			IF @locked < 0 
				BEGIN
					PRINT 'shadowmaker-FACDEV Import Locked'
					UPDATE dbo.webservices_requests SET SP_Error='shadowmaker-FACDEV Import Locked' WHERE [ID]=@webservices_requests_id	
				END
			ELSE 
				BEGIN
					SET @fields = 'username,lastModified,Download_Datetime,TYPE,TYPEOTHER,TITLE,ORG,CITY,STATE,COUNTRY'+
									',CHOURS,DESC,CPE,DTM_START,DTY_START,DTM_END,DTY_END,WEB_PROFILE'
					EXEC dbo.shadow_screen_data1 @webservices_requests_id=@webservices_requests_id,@table='_DM_FACDEV'
						,@idtype=NULL,@cols=@fields
						,@userid=@userid,@resync=@resync,@debug=0
					EXEC sp_releaseapplock 'shadowmaker-facdev','Session';
				END
		END
	DROP TABLE #_DM_FACDEV;

	
END



GO
