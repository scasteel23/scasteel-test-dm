SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 7/2/2018 Removed LEADERSHIP
--			Added DTM_START, DTM_END,
-- NS 9/9/22016: New, worked
--				 Get XML data from the downloader (SSIS package) insert into _DM_MEMBER table

/*
	Manual run to shadow individual MEMBER screen
	EXEC dbo.webservices_initiate @screen='MEMBER'
	EXEC dbo.webservices_run_DTSX
*/

CREATE PROCEDURE [dbo].[shadow_MEMBER] (@webservices_requests_id INT,@xml XML,@userid BIGINT=NULL,@resync BIT=NULL) 
AS 
BEGIN
	-- GET all MEMBER data from
	-- https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/MEMBER
	-- Parse the incoming XML
	/*
	XML Sample
	<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-09-09">
	<Record userId="1940574" username="halmeida" termId="6117" dmd:surveyId="17825316">
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Finance" text="Finance"/>
		<MEMBER id="130779779072" dmd:lastModified="2016-07-13T22:45:21" dmd:startDate="2010-01-01" dmd:endDate="2014-12-31">
			<NAME>National Bureau of Economic Research</NAME>
			<ORGABBR/>
			<SCOPE/>
			<DESC/>
			<DTM_START>January</DTM_START>
			<DTY_START>2010</DTY_START>
			<START_START>2010-01-01</START_START>
			<START_END>2010-12-31</START_END>
			<DTM_END>December</DTM_END>
			<DTY_END>2014</DTY_END>
			<END_START>2014-01-01</END_START>
			<END_END>2014-12-31</END_END>
			<WEB_PROFILE>Yes</WEB_PROFILE>
		</MEMBER>
		<MEMBER id="130779783168" dmd:lastModified="2016-07-13T22:45:45" dmd:startDate="2005-01-01" dmd:endDate="2010-12-31">
			<NAME>National Bureau of Economic Research</NAME>
			<ORGABBR/>
			<SCOPE/>
			<DESC/>
			<DTM_START></DTM_START>
			<DTY_START>2005</DTY_START>
			<START_START>2005-01-01</START_START>
			<START_END>2005-12-31</START_END>
			<DTM_END>February</DTM_END>
			<DTY_END>2010</DTY_END>
			<END_START>2010-01-01</END_START>
			<END_END>2010-12-31</END_END>
			<WEB_PROFILE>Yes</WEB_PROFILE>
		</MEMBER>
	</Record>
	<Record userId="1791141" username="scasteel" termId="6117" dmd:surveyId="17698890">
		<MEMBER id="126744752128" dmd:lastModified="2016-06-29T12:06:30">
			<NAME>Org 1</NAME>
			<ORGABBR/>
			<LEADERSHIP>King</LEADERSHIP>
			<SCOPE/>
			<DESC/>
			<WEB_PROFILE>Yes</WEB_PROFILE>
		</MEMBER>
	</Record>
	<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy"/>
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Administration" text="Business Administration"/>
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services"/>
		<MEMBER id="130926909440" dmd:lastModified="2016-07-19T09:08:14" dmd:startDate="1990-01-01">
			<NAME>International Eletrical and Electronics Egineers</NAME>
			<ORGABBR>IEEE</ORGABBR>			
			<SCOPE>International</SCOPE>
			<DESC/>
			<DTY_START>1990</DTY_START>
			<START_START>1990-01-01</START_START>
			<START_END>1990-12-31</START_END>
			<DTY_END/>
			<END_START></END_START>
			<END_END></END_END>
			<WEB_PROFILE>Yes</WEB_PROFILE>
		</MEMBER>
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
		ISNULL(Item.value('(NAME/text())[1]','varchar(400)'),'')NAME,
		ISNULL(Item.value('(ORGABBR/text())[1]','varchar(200)'),'')ORGABBR,
		--ISNULL(Item.value('(LEADERSHIP/text())[1]','varchar(200)'),'')LEADERSHIP,
		ISNULL(Item.value('(SCOPE/text())[1]','varchar(60)'),'')SCOPE,
		ISNULL(Item.value('(DESC/text())[1]','varchar(2000)'),'')[DESC],
		ISNULL(Item.value('(DTM_START/text())[1]','varchar(12)'),'')DTM_START,
		ISNULL(Item.value('(DTY_START/text())[1]','varchar(4)'),'')DTY_START,
		ISNULL(Item.value('(DTM_END/text())[1]','varchar(12)'),'')DTM_END,
		ISNULL(Item.value('(DTY_END/text())[1]','varchar(4)'),'')DTY_END,
		ISNULL(Item.value('(WEB_PROFILE/text())[1]','varchar(3)'),'')WEB_PROFILE
		--Item.value('(WEB_PROFILE_ORDER/text())[1]','bigint')WEB_PROFILE_ORDER
	INTO #_DM_MEMBER
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./MEMBER')Items(Item);

	ALTER TABLE #_DM_MEMBER ADD Download_Datetime  Datetime NULL
	UPDATE #_DM_MEMBER SET Download_Datetime=getdate();

	
	DECLARE @fields varchar(2000)

	-- Verify Incoming Data Interity
	IF @userid IS NULL AND (SELECT COUNT(*) FROM #_DM_MEMBER)<2 
		BEGIN
			UPDATE dbo.webservices_requests SET SP_Error='MEMBER has no data' WHERE [ID]=@webservices_requests_id			
			RAISERROR('MEMBER has no Data',18,1)
		END
	-- Delete & Insert the staging data
	ELSE 
		BEGIN
			DECLARE @locked INTEGER;
			EXEC @locked = sp_getapplock 'shadowmaker-member','Exclusive','Session',20000; -- 20 second wait
			IF @locked < 0 
				BEGIN
					PRINT 'shadowmaker-MEMBER Import Locked'
					UPDATE dbo.webservices_requests SET SP_Error='shadowmaker-MEMBER Import Locked' WHERE [ID]=@webservices_requests_id			
				END
			ELSE 
				BEGIN
					SET @fields = 'username,lastModified,Download_Datetime,NAME,ORGABBR,SCOPE,DESC,DTM_START,DTY_START,DTM_END,DTY_END,WEB_PROFILE'
					EXEC dbo.shadow_screen_data1 @webservices_requests_id=@webservices_requests_id,@table='_DM_MEMBER'
						,@idtype=NULL,@cols=@fields
						,@userid=@userid,@resync=@resync,@debug=0				
				END
			EXEC sp_releaseapplock 'shadowmaker-member','Session';
		END
	DROP TABLE #_DM_MEMBER;

	
END



GO
