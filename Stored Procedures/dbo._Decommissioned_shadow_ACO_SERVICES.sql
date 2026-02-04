SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 9/11/22016: Readying for DM screen availability

CREATE PROCEDURE [dbo].[_Decommissioned_shadow_ACO_SERVICES] (@xml XML,@userid BIGINT=NULL,@resync BIT=NULL) 
AS 

BEGIN

	-- GET all ACO_SERVICES data from
	-- https://beta.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/SERVICE_UNIVERSITY
	-- XML Sample:
	/*
		<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-06-21">
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
		ISNULL(Item.value('(TYPE/text())[1]','varchar(50)'),'')[TYPE],
		ISNULL(Item.value('(ORG/text())[1]','varchar(200)'),'')ORG,
		ISNULL(Item.value('(ORG_REPORTABLE/text())[1]','varchar(200)'),'')ORG_REPORTABLE,
		ISNULL(Item.value('(ROLE/text())[1]','varchar(200)'),'')[ROLE],
		ISNULL(Item.value('(ROLEOTHER/text())[1]','varchar(200)'),'')[ROLEOTHER],

		ISNULL(Item.value('(CITY/text())[1]','varchar(100)'),'')CITY,
		ISNULL(Item.value('(STATE/text())[1]','varchar(100)'),'')[STATE],
		ISNULL(Item.value('(COUNTRY/text())[1]','varchar(100)'),'')COUNTRY,

		ISNULL(Item.value('(AUDIENCE/text())[1]','varchar(200)'),'')AUDIENCE,
		ISNULL(Item.value('(DESC/text())[1]','varchar(400)'),'')[DESC],	
		
		ISNULL(Item.value('(PSV_YEAR_START/text())[1]','varchar(4)'),'')PSV_YEAR_START,
		ISNULL(Item.value('(PSV_YEAR_END/text())[1]','varchar(4)'),'')PSV_YEAR_END,
		ISNULL(Item.value('(WEB_PROFILE/text())[1]','VARCHAR(3)'),'')WEB_PROFILE,
		ISNULL(Item.value('(WEB_PROFILE_ORDER/text())[1]','INT'),'')WEB_PROFILE_ORDER,
		ISNULL(Item.value('(PERENNIAL/text())[1]','varchar(3)'),'')PERENNIAL

		
	INTO #_DM_ACO_SERVICES
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./ACO_SERVICES')Items(Item);
	
	-- DEBUG
	--SELECT * FROm #_DM_ACO_SERVICES


	DECLARE @fields varchar(2000)

	-- Verify Incoming Data Integrity
	IF @userid IS NULL AND (SELECT COUNT(*) FROM #_DM_ACO_SERVICES) < 3 RAISERROR('No Data',18,1) -- just to make sure we have some records, change the threshold to 10 or more on production
	-- Delete & Insert the staging data
	ELSE BEGIN
		DECLARE @locked INTEGER;
		EXEC @locked = sp_getapplock 'shadowmaker-ACO_SERVICES','Exclusive','Session',20000; -- 20 second wait
		IF @locked < 0 PRINT 'Import Locked';
		ELSE BEGIN
			-- UserID or id will be added later depending on idtype (LINKED -> id, otherwise-> username, userID ) 
			SET @fields = 'userName,surveyID,termID,lastModified' +
					',TYPE,ORG,ORG_REPORTABLE,ROLE,ROLEOTHER,CITY' +
					',STATE,COUNTRY,AUDIENCE,DESC,PSV_YEAR_START,PSV_YEAR_END' +
					',WEB_PROFILE,WEB_PROFILE_ORDER,PERENNIAL'

			--EXEC dbo.shadow_screen_data_Import @table='_DM_ACO_SERVICES'
			--	,@idtype=NULL,@cols=@fields,@username=@username
			--	,@userid=@userid,@resync=@resync,@debug=1

			EXEC dbo.shadow_screen_data @table='_DM_ACO_SERVICES'
				,@idtype=NULL,@cols=@fields
				,@userid=@userid,@resync=@resync,@debug=0

		
			EXEC sp_releaseapplock 'shadowmaker-ACO_SERVICES','Session'; 
		END


	END
	
	DROP TABLE #_DM_ACO_SERVICES;

END



GO
