SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 7/2/2018: added DTM_START and DTM_END, removed TYPE
-- NS 9/22/2017: added @webservices_requests_id parameter, also to all Shadow_* stored procedures
-- NS 9/6/22016: Adjusted fields to DM Business instance: Worked!
--				 Get XML data from the downloader (SSIS package) insert into _DM_AWARDHONOR table
/*
	Manual run to shadow individual AWARDHONOR screen
	EXEC dbo.webservices_initiate @screen='AWARDHONOR'
	EXEC dbo.webservices_run_DTSX
*/

CREATE PROCEDURE [dbo].[shadow_AWARDHONOR] (@webservices_requests_id INT, @xml XML,@userid BIGINT=NULL,@resync BIT=NULL) 
AS 

BEGIN



	
	-- https://beta.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/AWARDHONOR
	/*
		XML Sample:
		<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-09-09">
	<Record userId="1940570" username="rashad" termId="6117" dmd:surveyId="17825311">
		<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy"/>
		<AWARDHONOR id="144075419648" dmd:lastModified="2018-07-05T10:24:25" dmd:startDate="1984-08-01" dmd:endDate="2020-01-31">
			<NAME>N/A</NAME>
			<ORG>Beta Alpha Psi, Alpha Chapter (The professional fraternity of accounting)</ORG>
			<ORG_REPORTABLE>Beta Alpha Psi, Alpha Chapter (The professional fraternity of accounting)</ORG_REPORTABLE>
			<SCOPE>Academic Service</SCOPE>
			<SCOPE_LOCALE>National</SCOPE_LOCALE>
			<DTM_START>August</DTM_START>
			<DTY_START>1984</DTY_START>
			<START_START>1984-08-01</START_START>
			<START_END>1984-08-31</START_END>
			<DTM_END>January</DTM_END>
			<DTY_END>2020</DTY_END>
			<END_START>2020-01-01</END_START>
			<END_END>2020-01-31</END_END>
			<WEB_PROFILE>No</WEB_PROFILE>
			<WEB_PROFILE_ORDER>1</WEB_PROFILE_ORDER>
			<PERENNIAL>No</PERENNIAL>
		</AWARDHONOR>
		<AWARDHONOR id="132925216768" dmd:lastModified="2016-09-08T16:16:49" dmd:startDate="2004-01-01" dmd:endDate="2004-12-31">
			<NAME>University Medal for Contribution to Scholarship</NAME>
			<ORG_REPORTABLE>Athens University of Economics and Business</ORG_REPORTABLE>
			<ORG>Athens University of Economics and Business</ORG>

			<SCOPE>Research</SCOPE>
			<SCOPE_LOCALE/>
			<PERENNIAL>No</PERENNIAL>
			<DTM_START>September</DTM_START>
			<DTY_START>1994</DTY_START>
			<START_START></START_START>
			<START_END></START_END>
			<DTY_END>2004</DTY_END>
			<END_START>2004-01-01</END_START>
			<END_END>2004-12-31</END_END>
			<WEB_PROFILE>Yes</WEB_PROFILE>
			<WEB_PROFILE_ORDER>1</WEB_PROFILE_ORDER>
		</AWARDHONOR>
		<AWARDHONOR id="132925212672" dmd:lastModified="2016-09-08T16:16:49" dmd:startDate="2003-01-01" dmd:endDate="2003-12-31">
			<NAME>N/A</NAME>
			<ORG_REPORTABLE>Beta Gamma Sigma (The professional fraternity of business administration)</ORG_REPORTABLE>
			<ORG>Beta Gamma Sigma (The professional fraternity of business administration)</ORG>

			<SCOPE>Other</SCOPE>
			<SCOPE_LOCALE/>
			<PERENNIAL>No</PERENNIAL>
			<DTY_START/>
			<START_START></START_START>
			<START_END></START_END>
			<DTY_END>2003</DTY_END>
			<END_START>2003-01-01</END_START>
			<END_END>2003-12-31</END_END>
			<WEB_PROFILE>No</WEB_PROFILE>
			<WEB_PROFILE_ORDER>1</WEB_PROFILE_ORDER>
		</AWARDHONOR>
		<AWARDHONOR id="132925218816" dmd:lastModified="2016-09-08T16:16:49" dmd:startDate="2003-01-01" dmd:endDate="2003-12-31">
			<NAME>Who's Who in America, Who's Who in Finance and Industry and Who's Who in the South and Southwest</NAME>
			<ORG_REPORTABLE>Biographical Listing</ORG_REPORTABLE>
			<ORG>Biographical Listing</ORG>

			<SCOPE>Other</SCOPE>
			<SCOPE_LOCALE/>
			<PERENNIAL>No</PERENNIAL>
			<DTY_START/>
			<START_START></START_START>
			<START_END></START_END>
			<DTY_END>2003</DTY_END>
			<END_START>2003-01-01</END_START>
			<END_END>2003-12-31</END_END>
			<WEB_PROFILE>No</WEB_PROFILE>
			<WEB_PROFILE_ORDER>1</WEB_PROFILE_ORDER>
		</AWARDHONOR>
		<AWARDHONOR id="132925206528" dmd:lastModified="2016-09-08T16:16:49" dmd:startDate="1997-01-01" dmd:endDate="1997-12-31">
			<NAME>Graduate Teacher of the Year</NAME>
			<ORG_REPORTABLE>University of Florida</ORG_REPORTABLE>
			<ORG>University of Florida</ORG>

			<SCOPE>Academic Service</SCOPE>
			<SCOPE_LOCALE/>
			<PERENNIAL>No</PERENNIAL>
			<DTY_START/>
			<START_START></START_START>
			<START_END></START_END>
			<DTY_END>1997</DTY_END>
			<END_START>1997-01-01</END_START>
			<END_END>1997-12-31</END_END>
			<WEB_PROFILE>No</WEB_PROFILE>
			<WEB_PROFILE_ORDER>1</WEB_PROFILE_ORDER>
		</AWARDHONOR>
		<AWARDHONOR id="132925208576" dmd:lastModified="2016-09-08T16:16:49" dmd:startDate="1961-01-01" dmd:endDate="1961-12-31">
			<NAME>Graduation Honors</NAME>
			<ORG_REPORTABLE>Cairo University</ORG_REPORTABLE>
			<ORG>Cairo University</ORG>
	
			<SCOPE>Other</SCOPE>
			<SCOPE_LOCALE/>
			<PERENNIAL>No</PERENNIAL>
			<DTY_START/>
			<START_START></START_START>
			<START_END></START_END>
			<DTY_END>1961</DTY_END>
			<END_START>1961-01-01</END_START>
			<END_END>1961-12-31</END_END>
			<WEB_PROFILE>No</WEB_PROFILE>
			<WEB_PROFILE_ORDER>1</WEB_PROFILE_ORDER>
		</AWARDHONOR>
		<AWARDHONOR id="132925204480" dmd:lastModified="2016-09-08T16:16:49" dmd:startDate="1958-01-01" dmd:endDate="1960-12-31">
			<NAME>Faculty of Commerce Scholarship</NAME>
			<ORG_REPORTABLE>Cairo University</ORG_REPORTABLE>
			<ORG>Cairo University</ORG>

			<SCOPE>Other</SCOPE>
			<SCOPE_LOCALE/>
			<PERENNIAL>No</PERENNIAL>
			<DTY_START>1958</DTY_START>
			<START_START>1958-01-01</START_START>
			<START_END>1958-12-31</START_END>
			<DTY_END>1960</DTY_END>
			<END_START>1960-01-01</END_START>
			<END_END>1960-12-31</END_END>
			<WEB_PROFILE>No</WEB_PROFILE>
			<WEB_PROFILE_ORDER>1</WEB_PROFILE_ORDER>
		</AWARDHONOR>
	</Record>

	*/
	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')
	SELECT Record.value('@userId','bigint') userid,
		Record.value('@username','varchar(60)')username,		
		Record.value('@dmd:surveyId','bigint')surveyId,
		Record.value('@termId','bigint')termId,
		Item.value('@id','bigint') id,
		Item.value('@dmd:lastModified','date') lastModified,
		ISNULL(Item.value('(NAME/text())[1]','varchar(200)'),'')NAME,
		ISNULL(Item.value('(ORG/text())[1]','varchar(200)'),'')ORG,
		ISNULL(Item.value('(ORG_REPORTABLE/text())[1]','varchar(200)'),'')ORG_REPORTABLE,
		
		ISNULL(Item.value('(SCOPE/text())[1]','varchar(50)'),'')SCOPE,
		ISNULL(Item.value('(SCOPE_LOCALE/text())[1]','varchar(50)'),'')SCOPE_LOCALE,
		ISNULL(Item.value('(PERENNIAL/text())[1]','varchar(3)'),'')PERENNIAL,
		ISNULL(Item.value('(WEB_PROFILE/text())[1]','varchar(3)'),'')WEB_PROFILE,
		Item.value('(WEB_PROFILE_ORDER/text())[1]','bigint')WEB_PROFILE_ORDER,
		ISNULL(Item.value('(DTM_START/text())[1]','varchar(12)'),'')DTM_START,
		ISNULL(Item.value('(DTM_END/text())[1]','varchar(12)'),'')DTM_END,
		ISNULL(Item.value('(DTY_START/text())[1]','varchar(4)'),'')DTY_START,
		ISNULL(Item.value('(DTY_END/text())[1]','varchar(4)'),'')DTY_END

		--CAST(
		--	ISNULL(CASE WHEN Item.value('(DTY_START/text())[1]','char(3)') IS NULL THEN NULL ELSE Item.value('(DTY_START/text())[1]','char(2)') END,'')
		--	+' '+ISNULL(Item.value('(DTY_START/text())[1]','char(3)'),'')
		--	+' '+Item.value('(DTY_START/text())[1]','char(4)')
		--AS DATE) DTY_START,
		--CAST(
		--	ISNULL(CASE WHEN Item.value('(DTY_END/text())[1]','char(3)') IS NULL THEN NULL ELSE Item.value('(DTY_END/text())[1]','char(2)') END,'')
		--	+' '+ISNULL(Item.value('(DTY_END/text())[1]','char(3)'),'')
		--	+' '+Item.value('(DTY_END/text())[1]','char(4)')
		--AS DATE) DTY_END
	INTO #_DM_AWARDHONOR
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./AWARDHONOR')Items(Item)
	
	ALTER TABLE #_DM_AWARDHONOR ADD Download_Datetime  Datetime NULL
	UPDATE #_DM_AWARDHONOR SET Download_Datetime=getdate()
	
	--select * FROM #_DM_AWARDHONOR

	DECLARE @fields varchar(2000)

	-- Verify Incoming Data Interity
	IF @userid IS NULL AND (SELECT COUNT(*) FROM #_DM_AWARDHONOR)<10
		BEGIN
			UPDATE dbo.webservices_requests SET SP_Error='AWARDHONOR has no data' WHERE [ID]=@webservices_requests_id			
			RAISERROR('AWARDHONOR has no Data',18,1)
		END
	-- Delete & Insert the staging data
	ELSE 
	    BEGIN
			DECLARE @locked INTEGER;
			EXEC @locked = sp_getapplock 'shadowmaker-AWARDHONOR','Exclusive','Session',20000; -- 20 second wait
			IF @locked < 0 
				BEGIN
					PRINT 'shadowmaker-AWARDHONOR Import Locked'
					UPDATE dbo.webservices_requests SET SP_Error='shadowmaker-AWARDHONOR Import Locked' WHERE [ID]=@webservices_requests_id			
				END
			ELSE 
				BEGIN
					SET @fields = 'userName,lastModified,Download_Datetime,NAME,ORG,ORG_REPORTABLE,SCOPE,SCOPE_LOCALE,' +
								  'PERENNIAL,WEB_PROFILE,WEB_PROFILE_ORDER,DTY_START,DTY_END,DTM_START,DTM_END'
					EXEC dbo.shadow_screen_data1 @webservices_requests_id=@webservices_requests_id, @table='_DM_AWARDHONOR'
						,@idtype=NULL,@cols=@fields
						,@userid=@userid,@resync=@resync,@debug=0
					EXEC sp_releaseapplock 'shadowmaker-AWARDHONOR','Session';
				END
		END
	DROP TABLE #_DM_AWARDHONOR;
END



GO
