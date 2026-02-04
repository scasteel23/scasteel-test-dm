SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- NS 8/3/2018: renamed from INNOVATIONS to CURRICULUM, tested
-- NS 10/27/2016: It worked!
-- NS 10/24/2016: Based on shadow_AWARDHONOR()
--				  Get XML data from the downloader (SSIS package) insert into _DM_CURRICULUM table
/*
	Manual run to shadow individual CURRICULUM screen
	EXEC dbo.webservices_initiate @screen='CURRICULUM'
	EXEC dbo.webservices_run_DTSX
*/
CREATE PROCEDURE [dbo].[shadow_CURRICULUM] (@webservices_requests_id INT, @xml XML,@userid BIGINT=NULL,@resync BIT=NULL) 
AS 

BEGIN

	-- https://beta.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/CURRICULUM
	/*
		XML Sample:

<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-10-24">
<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Career Services" text="Business Career Services" />
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services" />
<CURRICULUM id="167708702720" dmd:originalSource="MANUAL" dmd:lastModified="2018-08-03T14:48:02" dmd:startDate="2017-05-01">
<TYPE>Revise Existing Course</TYPE>
<TYPE_OTHER />
<ORG>At Illinois, Outside Gies Business</ORG>
<ORG_OTHER>Social Works</ORG_OTHER>
<TITLE>How to approach the homeless without emotionless</TITLE>
<EVENT>Park gathering</EVENT>
<PRES_TITLE>Social works around us</PRES_TITLE>
<DESC>This is one of the park programs</DESC>
<DTM_START>May</DTM_START>
<DTY_START>2017</DTY_START>
<START_START>2017-05-01</START_START>
<START_END>2017-05-31</START_END>
<DTM_END />
<DTY_END />
<END_START />
<END_END />
<WEB_PROFILE>Yes</WEB_PROFILE>
 </CURRICULUM>
<CURRICULUM id="167708678144" dmd:originalSource="MANUAL" dmd:lastModified="2018-08-03T14:48:53" dmd:startDate="1999-01-01" dmd:endDate="2003-03-31">
<TYPE>New Course</TYPE>
<TYPE_OTHER />
<ORG>Gies Business</ORG>
<ORG_OTHER />
<TITLE>UISES</TITLE>
<EVENT>Classroom seminar</EVENT>
<PRES_TITLE>30 year UISES</PRES_TITLE>
<DESC>History of UISES</DESC>
<DTM_START>January</DTM_START>
<DTY_START>1999</DTY_START>
<START_START>1999-01-01</START_START>
<START_END>1999-01-31</START_END>
<DTM_END>March</DTM_END>
<DTY_END>2003</DTY_END>
<END_START>2003-03-01</END_START>
<END_END>2003-03-31</END_END>
<WEB_PROFILE>Yes</WEB_PROFILE>
 </CURRICULUM>
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
		ISNULL(Item.value('(TYPE_OTHER/text())[1]','varchar(200)'),'')[TYPE_OTHER],
		ISNULL(Item.value('(TITLE/text())[1]','varchar(200)'),'')TITLE,
		ISNULL(Item.value('(EVENT/text())[1]','varchar(400)'),'')[EVENT],
		ISNULL(Item.value('(PRES_TITLE/text())[1]','varchar(400)'),'')PRES_TITLE,
		ISNULL(Item.value('(ORG/text())[1]','varchar(200)'),'')ORG,
		ISNULL(Item.value('(ORG_OTHER/text())[1]','varchar(200)'),'')ORG_OTHER,
		ISNULL(Item.value('(ROLE/text())[1]','varchar(200)'),'')[ROLE],
		ISNULL(Item.value('(DESC/text())[1]','varchar(2000)'),'')[DESC],
		ISNULL(Item.value('(DTM_START/text())[1]','varchar(12)'),'')DTM_START,
		ISNULL(Item.value('(DTY_START/text())[1]','varchar(4)'),'')DTY_START,
		ISNULL(Item.value('(DTM_END/text())[1]','varchar(12)'),'')DTM_END,
		ISNULL(Item.value('(DTY_END/text())[1]','varchar(4)'),'')DTY_END,
		ISNULL(Item.value('(WEB_PROFILE/text())[1]','varchar(3)'),'')WEB_PROFILE
	
		
	INTO #_DM_CURRICULUM
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./CURRICULUM')Items(Item);
	
	ALTER TABLE #_DM_CURRICULUM ADD Download_Datetime  Datetime NULL
	UPDATE #_DM_CURRICULUM SET Download_Datetime=getdate();

	DECLARE @fields varchar(2000)

	SELECT * FROM #_DM_CURRICULUM

	-- Verify Incoming Data Interity
	IF @userid IS NULL AND (SELECT COUNT(*) FROM #_DM_CURRICULUM)<1 
		BEGIN
			UPDATE dbo.webservices_requests SET SP_Error='CURRICULUM has no data' WHERE [ID]=@webservices_requests_id			
			RAISERROR('CURRICULUM has no Data',18,1)
		END
	-- Delete & Insert the staging data
	ELSE 
	    BEGIN
			DECLARE @locked INTEGER;
			EXEC @locked = sp_getapplock 'shadowmaker-CURRICULUM','Exclusive','Session',20000; -- 20 second wait
			IF @locked < 0 
				BEGIN
					PRINT 'shadowmaker-CURRICULUM Import Locked'
					UPDATE dbo.webservices_requests SET SP_Error='shadowmaker-CURRICULUM Import Locked' WHERE [ID]=@webservices_requests_id			
				END
			ELSE 
				BEGIN
					SET @fields = 'userName,lastModified,Download_Datetime,TYPE,TYPE_OTHER,TITLE,EVENT,PRES_TITLE,ROLE,' +
								  'ORG,ORG_OTHER,DESC,WEB_PROFILE,DTM_START,DTY_START,DTM_END,DTY_END'
					EXEC dbo.shadow_screen_data1 @webservices_requests_id=@webservices_requests_id,@table='_DM_CURRICULUM'
						,@idtype=NULL,@cols=@fields
						,@userid=@userid,@resync=@resync,@debug=0
					EXEC sp_releaseapplock 'shadowmaker-CURRICULUM','Session';
				END
		END
	DROP TABLE #_DM_CURRICULUM;
END



GO
