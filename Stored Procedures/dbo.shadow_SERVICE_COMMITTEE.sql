SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 7/30/2018: Added DTM_START, DTM_END, FSDB_CURRENT
-- NS 10/5/2016: Test Worked!
--				 Get XML data from the downloader (SSIS package) insert into _DM_SERVICE_COMMITTEE table
/*
	Manual run to shadow individual SERVICE_COMMITTEE screen
	EXEC dbo.webservices_initiate @screen='SERVICE_COMMITTEE'
	EXEC dbo.webservices_run_DTSX
*/
CREATE PROCEDURE [dbo].[shadow_SERVICE_COMMITTEE] (@webservices_requests_id INT, @xml XML,@userid BIGINT=NULL,@resync BIT=NULL) 
AS 

BEGIN

	-- EXEC dbo._Test_Shadow_SERVICE_COMMITTEE
	-- GET all SERVICE_COMMITTEE data from
	-- https://beta.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/SERVICE_COMMITTEE
	-- XML Sample:
	/*
		<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-10-01">
			<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
					<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy"/>
					<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Administration" text="Business Administration"/>
					<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services"/>
				<SERVICE_COMMITTEE id="134110388224" dmd:lastModified="2016-10-01T21:49:40" dmd:startDate="2016-01-01" dmd:endDate="2016-12-31">
					<TYPE>College Committee (In College of Business, UIUC)</TYPE>
					<ORG>Interview</ORG>
					<ROLE>Member</ROLE>
					<SUPERVISION>Yes</SUPERVISION>
					<READING>No</READING>
					<INIT_EMPLOYMENT>not sure</INIT_EMPLOYMENT>
					<DESC>
					This is a team to set up criteria and procedure for the upcoming bla bla bla
					</DESC>
					<DEP>Undergraduate Affairs</DEP>
					<YR_START/>
					<START_START/>
					<START_END/>
					<YR_END>2016</YR_END>
					<END_START>2016-01-01</END_START>
					<END_END>2016-12-31</END_END>
					<WEB_PROFILE>Yes</WEB_PROFILE>
				</SERVICE_COMMITTEE>

				<SERVICE_COMMITTEE id="134110390272" dmd:lastModified="2016-10-01T21:50:32" dmd:startDate="2015-01-01" dmd:endDate="2016-12-31">
					<TYPE>
					Department Committee (In College of Business, UIUC)
					</TYPE>
					<ORG>Website</ORG>
					<ROLE>Chair</ROLE>
					<SUPERVISION>Yes</SUPERVISION>
					<READING>Yes</READING>
					<INIT_EMPLOYMENT>BADM</INIT_EMPLOYMENT>
					<DESC>This is business...</DESC>
					<DEP>Business Administration</DEP>
					<YR_START>2015</YR_START>
					<START_START>2015-01-01</START_START>
					<START_END>2015-12-31</START_END>
					<YR_END>2016</YR_END>
					<END_START>2016-01-01</END_START>
					<END_END>2016-12-31</END_END>
					<WEB_PROFILE>Yes</WEB_PROFILE>
				</SERVICE_COMMITTEE>
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
		--ISNULL(Item.value('@access','varchar(50)'),'')access,
		ISNULL(Item.value('(TYPE/text())[1]','varchar(100)'),'')[TYPE],
		ISNULL(Item.value('(ORG/text())[1]','varchar(200)'),'')ORG,
		ISNULL(Item.value('(ROLE/text())[1]','varchar(50)'),'')[ROLE],
		--ISNULL(Item.value('(SUPERVISION/text())[1]','varchar(3)'),'')SUPERVISION,
		--ISNULL(Item.value('(READING/text())[1]','varchar(3)'),'')READING,
		--ISNULL(Item.value('(INIT_EMPLOYMENT/text())[1]','varchar(200)'),'')INIT_EMPLOYMENT,
		
		ISNULL(Item.value('(DESC/text())[1]','varchar(400)'),'')[DESC],
		ISNULL(Item.value('(DEP/text())[1]','varchar(50)'),'')DEP,

		ISNULL(Item.value('(DTM_START/text())[1]','varchar(12)'),'')DTM_START,
		ISNULL(Item.value('(DTY_START/text())[1]','varchar(4)'),'')DTY_START,
		ISNULL(Item.value('(DTM_END/text())[1]','varchar(12)'),'')DTM_END,
		ISNULL(Item.value('(DTY_END/text())[1]','varchar(4)'),'')DTY_END,
		ISNULL(Item.value('(FSDB_CURRENT/text())[1]','VARCHAR(3)'),'')FSDB_CURRENT,
		ISNULL(Item.value('(WEB_PROFILE/text())[1]','VARCHAR(3)'),'')WEB_PROFILE
		
	INTO #_DM_SERVICE_COMMITTEE
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./SERVICE_COMMITTEE')Items(Item);
	
	ALTER TABLE #_DM_SERVICE_COMMITTEE ADD Download_Datetime  Datetime NULL
	UPDATE #_DM_SERVICE_COMMITTEE SET Download_Datetime=getdate();

	-- DEBUG
	--SELECT * FROm #_DM_SERVICE_UNIVERSITIES


	DECLARE @fields varchar(2000)

	-- Verify Incoming Data Integrity
	IF @userid IS NULL AND (SELECT COUNT(*) FROM #_DM_SERVICE_COMMITTEE) < 1  -- just to make sure we have some records, change the threshold to 10 or more on production
		BEGIN
			UPDATE dbo.webservices_requests SET SP_Error='SERVICE_COMMITTEE has no data' WHERE [ID]=@webservices_requests_id			
			RAISERROR('SERVICE_COMMITTEE has no Data',18,1)
		END
	-- Delete & Insert the staging data
	ELSE BEGIN
		DECLARE @locked INTEGER;
		EXEC @locked = sp_getapplock 'shadowmaker-SERVICE_COMMITTEE','Exclusive','Session',20000; -- 20 second wait
		IF @locked < 0 
			BEGIN
					PRINT 'shadowmaker-SERVICE_COMMITTEE Import Locked'
					UPDATE dbo.webservices_requests SET SP_Error='shadowmaker-SERVICE_COMMITTEE Import Locked' WHERE [ID]=@webservices_requests_id			
			END
		ELSE BEGIN
			-- UserID or id will be added later depending on idtype (LINKED -> id, otherwise-> username, userID ) 
			SET @fields = 'userName,lastModified,Download_Datetime' +
					',TYPE,ORG,ROLE,DESC,DEP,DTM_START,DTY_START,DTM_END,DTY_END,FSDB_CURRENT,WEB_PROFILE'

			--EXEC dbo.shadow_screen_data_Import @table='_DM_SERVICE_COMMITTEE'
			--	,@idtype=NULL,@cols=@fields,@username=@username
			--	,@userid=@userid,@resync=@resync,@debug=1

			EXEC dbo.shadow_screen_data1 @webservices_requests_id=@webservices_requests_id,@table='_DM_SERVICE_COMMITTEE'
				,@idtype=NULL,@cols=@fields
				,@userid=@userid,@resync=@resync,@debug=0

		
			EXEC sp_releaseapplock 'shadowmaker-SERVICE_COMMITTEE','Session'; 
		END

	--DEBUG to initialize both SERVICE_COMMITTEE tables
	--INSERT INTO dbo.SERVICE_UNIVERSITIES (id,surveyId,lastModified,access,PREFIX,FNAME,PFNAME,MNAME,LNAME,SUFFIX,ALT_NAME,EMAIL,WEBSITE,DT_DOB,GENDER,ETHNICITY,CITIZEN,RESEARCH_INTERESTS,BIO,EMERGENCY_CONTACT,SHOW_PHOTO,TWITTER,LINKEDIN,DISPLAY_ONLINE,TEACHING_INTERESTS,QUOTE,UPLOAD_CV)
	--SELECT id,surveyId,lastModified,access,PREFIX,FNAME,PFNAME,MNAME,LNAME,SUFFIX,ALT_NAME,EMAIL,WEBSITE,DT_DOB,GENDER,ETHNICITY,CITIZEN,RESEARCH_INTERESTS,BIO,EMERGENCY_CONTACT,SHOW_PHOTO,TWITTER,LINKEDIN,DISPLAY_ONLINE,TEACHING_INTERESTS,QUOTE,UPLOAD_CV
	--FROm #_DM_SERVICE_UNIVERSITIES

	--INSERT INTO DM_Shadow_Production.dbo.SERVICE_COMMITTEE (id,surveyId,lastModified,access,PREFIX,FNAME,PFNAME,MNAME,LNAME,SUFFIX,ALT_NAME,EMAIL,WEBSITE,DT_DOB,GENDER,ETHNICITY,CITIZEN,RESEARCH_INTERESTS,BIO,EMERGENCY_CONTACT,SHOW_PHOTO,TWITTER,LINKEDIN,DISPLAY_ONLINE,TEACHING_INTERESTS,QUOTE,UPLOAD_CV)
	--SELECT id,surveyId,lastModified,access,PREFIX,FNAME,PFNAME,MNAME,LNAME,SUFFIX,ALT_NAME,EMAIL,WEBSITE,DT_DOB,GENDER,ETHNICITY,CITIZEN,RESEARCH_INTERESTS,BIO,EMERGENCY_CONTACT,SHOW_PHOTO,TWITTER,LINKEDIN,DISPLAY_ONLINE,TEACHING_INTERESTS,QUOTE,UPLOAD_CV
	--FROm #_DM_SERVICE_UNIVERSITIES

	END
	
	DROP TABLE #_DM_SERVICE_COMMITTEE;

END



GO
