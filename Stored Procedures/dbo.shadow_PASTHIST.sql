SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 7/2/2018 Removed LEADERSHIP
--			Added DTM_START, DTM_END, CLASSIFICATION, COMPENSATED, NUMHOURS_YEARLY all empty values
-- NS 9/9/22016: New, worked
--				 Get XML data from the downloader (SSIS package) insert into _DM_PASTHIST table

/*
	Manual run to shadow individual PASTHIST screen
	EXEC dbo.webservices_initiate @screen='PASTHIST'
	EXEC dbo.webservices_run_DTSX
*/

CREATE PROCEDURE [dbo].[shadow_PASTHIST] (@webservices_requests_id INT,@xml XML,@userid BIGINT=NULL,@resync BIT=NULL) 
AS 
BEGIN
	-- GET all PASTHIST data from
	-- https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/PASTHIST
	-- Parse the incoming XML
	/*
	XML Sample
	<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-09-09">
	<Record userId="1940574" username="halmeida" termId="6117" dmd:surveyId="17825316">
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Finance" text="Finance"/>
		<PASTHIST id="130779676672" dmd:lastModified="2016-07-13T22:28:31" dmd:startDate="2011-01-01" dmd:endDate="2014-12-31">
			<EXPTYPE>College/University</EXPTYPE>
			<ORG_REPORTABLE/>
			<ORG>University of Illinois</ORG>
			<DEP/>
			<TITLE>Stanley C. and Joan J. Golder Distinguished Chair in Finance</TITLE>
			<DESC/>
			<OWN_COMPANY/>
			<DTY_START>2011</DTY_START>
			<START_START>2011-01-01</START_START>
			<START_END>2011-12-31</START_END>
			<DTY_END>2014</DTY_END>
			<END_START>2014-01-01</END_START>
			<END_END>2014-12-31</END_END>
			<CITY>Urbana-Champaign</CITY>
			<STATE/>
			<COUNTRY/>
			<WEB_PROFILE>Yes</WEB_PROFILE>
			<WEB_PROFILE_ORDER/>
		</PASTHIST>
		<PASTHIST id="130779680768" dmd:lastModified="2016-07-13T22:29:24" dmd:startDate="2009-01-01" dmd:endDate="2014-12-31">
			<EXPTYPE>College/University</EXPTYPE>
			<ORG_REPORTABLE/>
			<ORG>University of Illinois</ORG>
			<DEP/>
			<TITLE>Professor of Finance</TITLE>
			<DESC/>
			<OWN_COMPANY/>
			<DTY_START>2009</DTY_START>
			<START_START>2009-01-01</START_START>
			<START_END>2009-12-31</START_END>
			<DTY_END>2014</DTY_END>
			<END_START>2014-01-01</END_START>
			<END_END>2014-12-31</END_END>
			<CITY>Urbana-Champaign</CITY>
			<STATE/>
			<COUNTRY/>
			<WEB_PROFILE>Yes</WEB_PROFILE>
			<WEB_PROFILE_ORDER/>
		</PASTHIST>
		<PASTHIST id="130779682816" dmd:lastModified="2016-07-13T22:29:45" dmd:startDate="2008-01-01" dmd:endDate="2014-12-31">
			<EXPTYPE>College/University</EXPTYPE>
			<ORG_REPORTABLE/>
			<ORG>University of Illinois</ORG>
			<DEP/>
			<TITLE>Director of the Finance PhD program</TITLE>
			<DESC/>
			<OWN_COMPANY/>
			<DTY_START>2008</DTY_START>
			<START_START>2008-01-01</START_START>
			<START_END>2008-12-31</START_END>
			<DTY_END>2014</DTY_END>
			<END_START>2014-01-01</END_START>
			<END_END>2014-12-31</END_END>
			<CITY>Urbana-Champaign</CITY>
			<STATE/>
			<COUNTRY/>
			<WEB_PROFILE>Yes</WEB_PROFILE>
			<WEB_PROFILE_ORDER/>
		</PASTHIST>
		<PASTHIST id="130779686912" dmd:lastModified="2016-07-13T22:30:05" dmd:startDate="2007-01-01" dmd:endDate="2009-12-31">
			<EXPTYPE>College/University</EXPTYPE>
			<ORG_REPORTABLE/>
			<ORG>University of Illinois</ORG>
			<DEP/>
			<TITLE>Associate Professor of Finance</TITLE>
			<DESC/>
			<OWN_COMPANY/>
			<DTY_START>2007</DTY_START>
			<START_START>2007-01-01</START_START>
			<START_END>2007-12-31</START_END>
			<DTY_END>2009</DTY_END>
			<END_START>2009-01-01</END_START>
			<END_END>2009-12-31</END_END>
			<CITY>Urbana-Champaign</CITY>
			<STATE/>
			<COUNTRY/>
			<WEB_PROFILE>Yes</WEB_PROFILE>
			<WEB_PROFILE_ORDER/>
		</PASTHIST>
		<PASTHIST id="130779752448" dmd:lastModified="2016-07-13T22:43:14" dmd:startDate="2007-01-01" dmd:endDate="2008-12-31">
			<EXPTYPE>College/University</EXPTYPE>
			<ORG_REPORTABLE/>
			<ORG>New York University</ORG>
			<DEP>Stern School of Business</DEP>
			<TITLE>Associate Professor of Finance</TITLE>
			<DESC/>
			<OWN_COMPANY/>
			<DTY_START>2007</DTY_START>
			<START_START>2007-01-01</START_START>
			<START_END>2007-12-31</START_END>
			<DTY_END>2008</DTY_END>
			<END_START>2008-01-01</END_START>
			<END_END>2008-12-31</END_END>
			<CITY/>
			<STATE/>
			<COUNTRY/>
			<WEB_PROFILE>Yes</WEB_PROFILE>
			<WEB_PROFILE_ORDER/>
		</PASTHIST>
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
		ISNULL(Item.value('(EXPTYPE/text())[1]','varchar(50)'),'')EXPTYPE,
		ISNULL(Item.value('(ORG_REPORTABLE/text())[1]','varchar(200)'),'')ORG_REPORTABLE,
		ISNULL(Item.value('(ORG/text())[1]','varchar(200)'),'')ORG,
		ISNULL(Item.value('(DEP/text())[1]','varchar(200)'),'')DEP,

		ISNULL(Item.value('(TITLE/text())[1]','varchar(200)'),'')TITLE,
		ISNULL(Item.value('(DESC/text())[1]','varchar(400)'),'')[DESC],
		ISNULL(Item.value('(OWN_COMPANY/text())[1]','varchar(3)'),'')OWN_COMPANY,

		ISNULL(Item.value('(DTM_START/text())[1]','varchar(12)'),'')DTM_START,
		ISNULL(Item.value('(DTY_START/text())[1]','varchar(4)'),'')DTY_START,
		ISNULL(Item.value('(DTM_END/text())[1]','varchar(12)'),'')DTM_END,
		ISNULL(Item.value('(DTY_END/text())[1]','varchar(4)'),'')DTY_END,
		ISNULL(Item.value('(CLASSIFICATION/text())[1]','varchar(100)'),'')CLASSIFICATION,
		ISNULL(Item.value('(COMPENSATED/text())[1]','varchar(3)'),'')COMPENSATED,
		ISNULL(Item.value('(NUMHOURS_YEARLY/text())[1]','varchar(20)'),'')NUMHOURS_YEARLY,

		ISNULL(Item.value('(CITY/text())[1]','varchar(100)'),'')CITY,
		ISNULL(Item.value('(STATE/text())[1]','varchar(100)'),'')[STATE],
		ISNULL(Item.value('(COUNTRY/text())[1]','varchar(100)'),'')COUNTRY,
		ISNULL(Item.value('(WEB_PROFILE/text())[1]','varchar(3)'),'')WEB_PROFILE,
		Item.value('(WEB_PROFILE_ORDER/text())[1]','bigint')WEB_PROFILE_ORDER
	INTO #_DM_PASTHIST
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./PASTHIST')Items(Item);

	
	ALTER TABLE #_DM_PASTHIST ADD Download_Datetime  Datetime NULL
	UPDATE #_DM_PASTHIST SET Download_Datetime=getdate();
	
	DECLARE @fields varchar(2000)

	-- Verify Incoming Data Interity
	IF @userid IS NULL AND (SELECT COUNT(*) FROM #_DM_PASTHIST)<2 
		BEGIN
			UPDATE dbo.webservices_requests SET SP_Error='PASTHIST has no data' WHERE [ID]=@webservices_requests_id			
			RAISERROR('PASTHIST has no Data',18,1)
		END
	-- Delete & Insert the staging data
	ELSE 
		BEGIN
			DECLARE @locked INTEGER;
			EXEC @locked = sp_getapplock 'shadowmaker-pasthist','Exclusive','Session',20000; -- 20 second wait
			IF @locked < 0 
				BEGIN
					PRINT 'shadowmaker-PASTHIST Import Locked'
					UPDATE dbo.webservices_requests SET SP_Error='shadowmaker-PASTHIST Import Locked' WHERE [ID]=@webservices_requests_id			
				END
			ELSE 
				BEGIN
					SET @fields = 'username,lastModified,Download_Datetime,EXPTYPE,ORG_REPORTABLE,ORG,DEP,TITLE,DESC'+
							',OWN_COMPANY,DTM_START,DTY_START,DTM_END,DTY_END,CLASSIFICATION,COMPENSATED,NUMHOURS_YEARLY,CITY,STATE,COUNTRY,WEB_PROFILE,WEB_PROFILE_ORDER'
					EXEC dbo.shadow_screen_data1 @webservices_requests_id=@webservices_requests_id, @table='_DM_PASTHIST'
						,@idtype=NULL,@cols=@fields
						,@userid=@userid,@resync=@resync,@debug=0
					EXEC sp_releaseapplock 'shadowmaker-pasthist','Session';
				END
		END
	DROP TABLE #_DM_PASTHIST;

	
END



GO
