SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 3/23/2017 	Worked!	

/*
	Manual run to shadow individual RESPROG screen
	EXEC dbo.webservices_initiate @screen='RESPROG'
	EXEC dbo.webservices_run_DTSX
*/
CREATE PROCEDURE [dbo].[shadow_RESPROG] (@webservices_requests_id INT, @xml XML,@userid BIGINT=NULL,@resync BIT=NULL) 
AS 

BEGIN

	-- GET all RESPROG (Work in Progress) data from
	-- https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/RESPROG
	-- XML Sample:
/*
		
<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2017-03-24">
<Record userId="1791141" username="scasteel" termId="6117" dmd:surveyId="17698890">
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services"/>
<RESPROG id="142452533248" dmd:lastModified="2017-02-22T09:23:24" dmd:startDate="2014-01-01" dmd:endDate="2019-12-31">
<DESC>None of your business</DESC>
<DTY_START>2014</DTY_START>
<START_START>2014-01-01</START_START>
<START_END>2014-12-31</START_END>
<DTY_END>2019</DTY_END>
<END_START>2019-01-01</END_START>
<END_END>2019-12-31</END_END>
<WEB_PROFILE>Yes</WEB_PROFILE>
<WEB_PROFILE_ORDER/>
</RESPROG>
</Record>
<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services"/>
<RESPROG id="144206290944" dmd:lastModified="2017-03-24T11:48:28" dmd:startDate="2009-01-01" dmd:endDate="2011-12-31">
<DESC>
Thermal Insulation elasticity in pricing is affected by food price
</DESC>
<DTY_START>2009</DTY_START>
<START_START>2009-01-01</START_START>
<START_END>2009-12-31</START_END>
<DTY_END>2011</DTY_END>
<END_START>2011-01-01</END_START>
<END_END>2011-12-31</END_END>
<WEB_PROFILE>Yes</WEB_PROFILE>
<WEB_PROFILE_ORDER>3</WEB_PROFILE_ORDER>
</RESPROG>
<RESPROG id="144206245888" dmd:lastModified="2017-03-24T11:47:03" dmd:startDate="2001-01-01" dmd:endDate="2003-12-31">
<DESC>
Student Data Analysis for enhancing Recruiting and Admissions
</DESC>
<DTY_START>2001</DTY_START>
<START_START>2001-01-01</START_START>
<START_END>2001-12-31</START_END>
<DTY_END>2003</DTY_END>
<END_START>2003-01-01</END_START>
<END_END>2003-12-31</END_END>
<WEB_PROFILE>Yes</WEB_PROFILE>
<WEB_PROFILE_ORDER>2</WEB_PROFILE_ORDER>
</RESPROG>
</Record>
</Data>
		
	>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	Parse XML nested <INTELLCONT>
	*/


	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')
	SELECT Record.value('@userId','bigint') userid,
		Record.value('@username','varchar(60)')username,		
		Record.value('@dmd:surveyId','bigint')surveyId,
		Record.value('@termId','bigint')termId,
		Item.value('@id','bigint') id,
		Item.value('@dmd:lastModified','date') lastModified,
		--ISNULL(Item.value('@access','varchar(50)'),'')access,

		ISNULL(Item.value('(DESC/text())[1]','varchar(3000)'),'') [DESC],
		ISNULL(Item.value('(DTY_START/text())[1]','varchar(4)'),'') DTY_START,
		ISNULL(Item.value('(DTY_END/text())[1]','varchar(4)'),'') DTY_END
		--ISNULL(Item.value('(WEB_PROFILE/text())[1]','varchar(3)'),'') WEB_PROFILE,
		--ISNULL(Item.value('(WEB_PROFILE_ORDER/text())[1]','varchar(4)'),'') WEB_PROFILE_ORDER
		
	INTO #_DM_RESPROG
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./RESPROG')Items(Item);
		
	ALTER TABLE #_DM_RESPROG ADD Download_Datetime  Datetime NULL
	UPDATE #_DM_RESPROG SET Download_Datetime=getdate();


	-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-- Save into Tables
	DECLARE @fields varchar(2000), @fields2 varchar(2000)

	-- Verify Incoming Data Integrity
	IF @userid IS NULL AND (SELECT COUNT(*) FROM #_DM_RESPROG) < 3  -- just to make sure we have some records, change the threshold to 10 or more on production
		BEGIN
			UPDATE dbo.webservices_requests SET SP_Error='RESPROG has no data' WHERE [ID]=@webservices_requests_id			
			RAISERROR('RESPROG has no Data',18,1)
		END
	-- Delete & Insert the staging data
	ELSE BEGIN
		DECLARE @locked INTEGER;
		EXEC @locked = sp_getapplock 'shadowmaker-RESPROG','Exclusive','Session',20000; -- 20 second wait
		IF @locked < 0 
			BEGIN
					PRINT 'shadowmaker-RESPROG Import Locked'
					UPDATE dbo.webservices_requests SET SP_Error='shadowmaker-RESPROG Import Locked' WHERE [ID]=@webservices_requests_id			
			END
		ELSE BEGIN
			SET @fields = 'userName,lastModified,Download_Datetime' +
					 ',DESC,DTY_START,DTY_END'

			EXEC dbo.shadow_screen_data1 @webservices_requests_id=@webservices_requests_id, @table='_DM_RESPROG'
				,@idtype=NULL,@cols=@fields
				,@userid=@userid,@resync=@resync,@debug=0

			EXEC sp_releaseapplock 'shadowmaker-RESPROG','Session'; 
		END



	END
	
	DROP TABLE #_DM_RESPROG;

END



GO
