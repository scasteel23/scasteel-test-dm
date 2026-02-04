SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- NS 7/3/2018: New
--				 Get XML data from the downloader (SSIS package) insert into _DM_NCTEACH table

/*
	Manual run to shadow individual NCTEACH screen
	EXEC dbo.webservices_initiate @screen='NCTEACH'
	EXEC dbo.webservices_run_DTSX
*/

CREATE PROCEDURE [dbo].[shadow_NCTEACH] (@webservices_requests_id INT,@xml XML,@userid BIGINT=NULL,@resync BIT=NULL) 
AS 
BEGIN
	-- GET all NCTEACH data from
	-- https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/NCTEACH
	-- Parse the incoming XML
	/*
	XML Sample
	<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-09-09">
	<Record userId="1910556" username="busfac1" termId="6117" dmd:surveyId="17699128">
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy" />
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Administration" text="Business Administration" />
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Finance" text="Finance" />
		<NCTEACH id="166221842432" dmd:originalSource="MANAGE_DATA" dmd:lastModified="2018-07-03T12:38:49" dmd:startDate="2015-01-01" dmd:endDate="2018-12-31">
			<TYPE>Coursera Non-Credit Course</TYPE>
			<TYPEOTHER />
			<AUDIENCE />
			<ORG />
			<NUMPART />
			<DESC>Data Excavation</DESC>
			<DTM_START>January</DTM_START>
			<DTY_START>2015</DTY_START>
			<START_START>2015-01-01</START_START>
			<START_END>2015-01-31</START_END>
			<DTM_END />
			<DTY_END>2018</DTY_END>
			<END_START>2018-01-01</END_START>
			<END_END>2018-12-31</END_END>
			<WEB_PROFILE>No</WEB_PROFILE>
		</NCTEACH>
		<NCTEACH id="163591274496" dmd:originalSource="MANAGE_DATA" dmd:lastModified="2018-07-03T12:38:02" dmd:startDate="2016-01-01" dmd:endDate="2018-02-28">
			<TYPE>Continuing Education</TYPE>
			<TYPEOTHER />
			<AUDIENCE>Internal to University of Illinois at Urbana-Champaign</AUDIENCE>
			<ORG>Department of Business Administration</ORG>
			<NUMPART>20</NUMPART>
			<DESC>FAST teaching</DESC>
			<DTM_START>January</DTM_START>
			<DTY_START>2016</DTY_START>
			<START_START>2016-01-01</START_START>
			<START_END>2016-01-31</START_END>
			<DTM_END>February</DTM_END>
			<DTY_END>2018</DTY_END>
			<END_START>2018-02-01</END_START>
			<END_END>2018-02-28</END_END>
			<WEB_PROFILE>Yes</WEB_PROFILE>
		</NCTEACH>
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
		ISNULL(Item.value('(TYPE/text())[1]','varchar(200)'),'')[TYPE],
		ISNULL(Item.value('(TYPEOTHER/text())[1]','varchar(400)'),'')TYPEOTHER,
		ISNULL(Item.value('(AUDIENCE/text())[1]','varchar(200)'),'')AUDIENCE,
		ISNULL(Item.value('(ORG/text())[1]','varchar(200)'),'')ORG,
		ISNULL(Item.value('(NUMPART/text())[1]','varchar(10)'),'')NUMPART,
		ISNULL(Item.value('(DESC/text())[1]','varchar(1000)'),'')[DESC],

		ISNULL(Item.value('(DTM_START/text())[1]','varchar(50)'),'')DTM_START,
		ISNULL(Item.value('(DTM_END/text())[1]','varchar(50)'),'')DTM_END,

		ISNULL(Item.value('(DTY_START/text())[1]','varchar(4)'),'')DTY_START,
		ISNULL(Item.value('(DTY_END/text())[1]','varchar(4)'),'')DTY_END,
		
		ISNULL(Item.value('(WEB_PROFILE/text())[1]','varchar(3)'),'')WEB_PROFILE

	INTO #_DM_NCTEACH
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./NCTEACH')Items(Item);
	
	ALTER TABLE #_DM_NCTEACH ADD Download_Datetime  Datetime NULL
	UPDATE #_DM_NCTEACH SET Download_Datetime=getdate();

	DECLARE @fields varchar(2000)

	-- Verify Incoming Data Interity
	IF @userid IS NULL AND (SELECT COUNT(*) FROM #_DM_NCTEACH)<1 
		BEGIN
			UPDATE dbo.webservices_requests SET SP_Error='NCTEACH has no data' WHERE [ID]=@webservices_requests_id			
			RAISERROR('NCTEACH has no Data',18,1)
		END
	-- Delete & Insert the staging data
	ELSE 
		BEGIN
			DECLARE @locked INTEGER;
			EXEC @locked = sp_getapplock 'shadowmaker-NCTEACH','Exclusive','Session',20000; -- 20 second wait
			IF @locked < 0 
				BEGIN
					PRINT 'shadowmaker-NCTEACH Import Locked'
					UPDATE dbo.webservices_requests SET SP_Error='shadowmaker-NCTEACH Import Locked' WHERE [ID]=@webservices_requests_id			
				END
			ELSE 
				BEGIN
					-- shadow_screen_data1 does not allow [] signs, shadow_screen_data2 requires [] for system var names
					SET @fields = 'username,lastModified,Download_Datetime,TYPE,TYPEOTHER,AUDIENCE,ORG,NUMPART,DESC,DTM_START,DTM_END,DTY_START,DTY_END,WEB_PROFILE'
					EXEC dbo.shadow_screen_data1 @webservices_requests_id=@webservices_requests_id,@table='_DM_NCTEACH'
						,@idtype=NULL,@cols=@fields
						,@userid=@userid,@resync=@resync,@debug=0
					EXEC sp_releaseapplock 'shadowmaker-NCTEACH','Session';
				END
		END
	DROP TABLE #_DM_NCTEACH;

	
END



GO
