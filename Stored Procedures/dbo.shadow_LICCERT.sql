SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- NS 9/9/22016: New, worked
--				 Get XML data from the downloader (SSIS package) insert into _DM_LICCERT table

/*
	Manual run to shadow individual LICCERT screen
	EXEC dbo.webservices_initiate @screen='LICCERT'
	EXEC dbo.webservices_run_DTSX
*/

CREATE PROCEDURE [dbo].[shadow_LICCERT] (@webservices_requests_id INT,@xml XML,@userid BIGINT=NULL,@resync BIT=NULL) 
AS 
BEGIN
	-- GET all LICCERT data from
	-- https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/LICCERT
	-- Parse the incoming XML
	/*
	XML Sample
	<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-09-09">
	<Record userId="1791141" username="scasteel" termId="6117" dmd:surveyId="17698890">
		<LICCERT id="130281576448" dmd:lastModified="2016-06-27T13:52:29" dmd:startDate="2014-01-01" dmd:endDate="2016-05-31">
			<TITLE>Certified License</TITLE>
			<ORG/>
			<SCOPE/>
			<DESC/>
			<DTM_START/>
			<DTD_START/>
			<DTY_START>2014</DTY_START>
			<START_START>2014-01-01</START_START>
			<START_END>2014-12-31</START_END>
			<DTM_END>May</DTM_END>
			<DTD_END/>
			<DTY_END>2016</DTY_END>
			<END_START>2016-05-01</END_START>
			<END_END>2016-05-31</END_END>
		</LICCERT>
	</Record>
	<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy"/>
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Administration" text="Business Administration"/>
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services"/>
		<LICCERT id="130926800896" dmd:lastModified="2016-07-19T09:06:23" dmd:startDate="1995-01-01" dmd:endDate="1996-12-31">
			<TITLE>Microsoft Certificate</TITLE>
			<ORG>Microsoft</ORG>
			<SCOPE>International</SCOPE>
			<DESC/>
			<DTM_START/>
			<DTD_START/>
			<DTY_START>1995</DTY_START>
			<START_START>1995-01-01</START_START>
			<START_END>1995-12-31</START_END>
			<DTM_END/>
			<DTD_END/>
			<DTY_END>1996</DTY_END>
			<END_START>1996-01-01</END_START>
			<END_END>1996-12-31</END_END>
			<WEB_PROFILE>Yes</WEB_PROFILE>
		</LICCERT>
		<LICCERT id="130926809088" dmd:lastModified="2016-07-19T09:07:04" dmd:startDate="1984-01-01" dmd:endDate="1986-12-31">
			<TITLE>IBM JCL</TITLE>
			<ORG>IBM</ORG>
			<SCOPE>International</SCOPE>
			<DESC/>
			<DTM_START/>
			<DTD_START/>
			<DTY_START>1984</DTY_START>
			<START_START>1984-01-01</START_START>
			<START_END>1984-12-31</START_END>
			<DTM_END/>
			<DTD_END/>
			<DTY_END>1986</DTY_END>
			<END_START>1986-01-01</END_START>
			<END_END>1986-12-31</END_END>
			<WEB_PROFILE>Yes</WEB_PROFILE>
		</LICCERT>
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
		ISNULL(Item.value('(TITLE/text())[1]','varchar(200)'),'')TITLE,
		ISNULL(Item.value('(ORG/text())[1]','varchar(200)'),'')ORG,
		ISNULL(Item.value('(SCOPE/text())[1]','varchar(60)'),'')SCOPE,

		ISNULL(Item.value('(DESC/text())[1]','varchar(400)'),'')[DESC],

		ISNULL(Item.value('(DTM_START/text())[1]','varchar(50)'),'')DTM_START,
		ISNULL(Item.value('(DTM_END/text())[1]','varchar(50)'),'')DTM_END,

		ISNULL(Item.value('(DTY_START/text())[1]','varchar(4)'),'')DTY_START,
		ISNULL(Item.value('(DTY_END/text())[1]','varchar(4)'),'')DTY_END,
		
		ISNULL(Item.value('(WEB_PROFILE/text())[1]','varchar(3)'),'')WEB_PROFILE

	INTO #_DM_LICCERT
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./LICCERT')Items(Item);
	
	ALTER TABLE #_DM_LICCERT ADD Download_Datetime  Datetime NULL
	UPDATE #_DM_LICCERT SET Download_Datetime=getdate();

	DECLARE @fields varchar(2000)

	-- Verify Incoming Data Interity
	IF @userid IS NULL AND (SELECT COUNT(*) FROM #_DM_LICCERT)<2 
		BEGIN
			UPDATE dbo.webservices_requests SET SP_Error='LICCERT has no data' WHERE [ID]=@webservices_requests_id			
			RAISERROR('LICCERT has no Data',18,1)
		END
	-- Delete & Insert the staging data
	ELSE 
		BEGIN
			DECLARE @locked INTEGER;
			EXEC @locked = sp_getapplock 'shadowmaker-LICCERT','Exclusive','Session',20000; -- 20 second wait
			IF @locked < 0 
				BEGIN
					PRINT 'shadowmaker-LICCERT Import Locked'
					UPDATE dbo.webservices_requests SET SP_Error='shadowmaker-LICCERT Import Locked' WHERE [ID]=@webservices_requests_id			
				END
			ELSE 
				BEGIN
					SET @fields = 'username,lastModified,Download_Datetime,TITLE,ORG,SCOPE,DESC,DTM_START,DTM_END,DTY_START,DTY_END,WEB_PROFILE'
					EXEC dbo.shadow_screen_data1 @webservices_requests_id=@webservices_requests_id,@table='_DM_LICCERT'
						,@idtype=NULL,@cols=@fields
						,@userid=@userid,@resync=@resync,@debug=0
					EXEC sp_releaseapplock 'shadowmaker-LICCERT','Session';
				END
		END
	DROP TABLE #_DM_LICCERT;

	
END



GO
