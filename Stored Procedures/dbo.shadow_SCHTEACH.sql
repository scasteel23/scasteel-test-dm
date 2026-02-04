SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 10/15/2018: Added new fields
--		
-- NS 9/25/2017: technically there is no need to shadow the Courses, except that if we have Syllabi file instated @DM
-- NS 4/3/2017: Worked, but the actual Business Screen not available yet
--				 Get XML data from the downloader (SSIS package) insert into _DM_SCHTEACH table

/*
	Manual run to shadow individual SCHTEACH screen
	EXEC dbo.webservices_initiate @screen='SCHTEACH'
	EXEC dbo.webservices_run_DTSX
*/

CREATE PROCEDURE [dbo].[shadow_SCHTEACH] (@webservices_requests_id INT, @xml XML,@userid BIGINT=NULL,@resync BIT=NULL) 
AS 
BEGIN
	-- GET all SCHTEACH data from
	-- https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/SCHTEACH
	-- Parse the incoming XML
	/*
	XML Sample
	<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2017-03-28">
		<Record userId="1380251" username="fouad" termId="3236" dmd:surveyId="9938794">
			<dmd:IndexEntry indexKey="COLLEGE" entryKey="Education" text="Education"/>
			<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="ED: Curriculum and Instruction" text="ED: Curriculum and Instruction"/>
			<SCHTEACH id="111841122304" dmd:lastModified="2015-11-20T09:31:44" 
				dmd:startDate="2015-09-01" dmd:endDate="2015-12-31" dmd:primaryKey="Fall|2015|CI|599|FSA">
			<TYT_TERM>Fall</TYT_TERM>
			<TYY_TERM>2015</TYY_TERM>
			<TERM_START>2015-09-01</TERM_START>
			<TERM_END>2015-12-31</TERM_END>
			<TITLE>Thesis Research</TITLE>
			<COURSEPRE>CI</COURSEPRE>
			<COURSENUM>599</COURSENUM>
			<SECTION>FSA</SECTION>
			<ENROLL>3</ENROLL>
			<CHOURS>.00</CHOURS>
			<LEVEL>Graduate</LEVEL>
			<DELIVERY_MODE>Independent Study</DELIVERY_MODE>
			</SCHTEACH>

			<SCHTEACH id="156143685632" dmd:originalSource="IMPORT" dmd:created="2017-12-15T19:51:46" dmd:lastModifiedSource="MANAGE_DATA" dmd:lastModified="2018-10-15T16:35:50" dmd:startDate="2016-09-01" dmd:endDate="2016-12-31">
			<TYT_TERM>Fall</TYT_TERM>
			<TYY_TERM>2016</TYY_TERM>
			<COURSEPRE>ACCY</COURSEPRE>
			<COURSENUM>511</COURSENUM>
			<TITLE>External Risk Measurement/Rept</TITLE>
			<SECTION>E</SECTION>
			<DELIVERY_MODE>Lecture-Discussion</DELIVERY_MODE>
			<CRN>49276</CRN>
			<LEVEL>Graduate</LEVEL>
			<CENSUS_ENROLL />
			<ENROLL>33</ENROLL>
			<CHOURS>4.000</CHOURS>
			<DMI_HOURS />
			<DEGREE_PROGRAM>Bachelor's</DEGREE_PROGRAM>
			<DEGREE_PROGRAM>Doctoral</DEGREE_PROGRAM>
			<DEGREE_PROGRAM>MBA</DEGREE_PROGRAM>
			<COURSE_INFO_URL />
			<SYLLABUS />
			<COURSE_URL />
			<ICES_COURSE />
			<ICES_INSTRUCTOR />
			<ICES_RESPONSES />
			</SCHTEACH>
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
		
		ISNULL(Item.value('(TYT_TERM/text())[1]','varchar(20)'),'')TYT_TERM,
		ISNULL(Item.value('(TYY_TERM/text())[1]','varchar(20)'),'')TYY_TERM,
		--ISNULL(Item.value('(CRS_ID/text())[1]','varchar(20)'),'')CRS_ID,
		ISNULL(Item.value('(COURSEPRE/text())[1]','varchar(10)'),'')COURSEPRE,
		ISNULL(Item.value('(COURSENUM/text())[1]','varchar(10)'),'')COURSENUM,
		ISNULL(Item.value('(TITLE/text())[1]','varchar(200)'),'')TITLE,

		ISNULL(Item.value('(SECTION/text())[1]','varchar(50)'),'')SECTION,
		ISNULL(Item.value('(DELIVERY_MODE/text())[1]','varchar(200)'),'')DELIVERY_MODE,
		ISNULL(Item.value('(CRN/text())[1]','varchar(20)'),'')CRN,
		ISNULL(Item.value('(LEVEL/text())[1]','varchar(200)'),'')[LEVEL],

		-- Replaced with Multi Checkboxes
		--ISNULL(Item.value('(DEGREE_PROGRAM/text())[1]','varchar(200)'),'')DEGREE_PROGRAM,
		ISNULL(Item.value('(ENROLL/text())[1]','varchar(10)'),'')ENROLL,
		ISNULL(Item.value('(CENSUS_ENROLL/text())[1]','varchar(10)'),'')CENSUS_ENROLL,
		ISNULL(Item.value('(CHOURS/text())[1]','varchar(10)'),'')CHOURS,
		ISNULL(Item.value('(DMI_HOURS/text())[1]','varchar(10)'),'')DMI_HOURS,

		ISNULL(Item.value('(COURSE_INFO_URL/text())[1]','varchar(200)'),'')COURSE_INFO_URL,
		--ISNULL(Item.value('(SYLLABUS/text())[1]','varchar(200)'),'')SYLLABUS,
		ISNULL(Item.value('(ICES_COURSE/text())[1]','varchar(10)'),'')ICES_COURSE,
		ISNULL(Item.value('(ICES_INSTRUCTOR/text())[1]','varchar(10)'),'')ICES_INSTRUCTOR,
		ISNULL(Item.value('(ICES_RESPONSES/text())[1]','varchar(10)'),'')ICES_RESPONSES,

		-- Updateable in DM site
		ISNULL(Item.value('(COURSE_URL/text())[1]','varchar(100)'),'')COURSE_URL,
		ISNULL(Item.value('(SYLLABUS/text())[1]','varchar(1000)'),'')SYLLABUS
		-- DEGREE_PROGRAM multi boxes is also updateable

		--ISNULL(Item.value('(WEB_PROFILE/text())[1]','varchar(3)'),'')WEB_PROFILE
		--Item.value('(WEB_PROFILE_ORDER/text())[1]','bigint')WEB_PROFILE_ORDER
	INTO #_DM_SCHTEACH
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./SCHTEACH')Items(Item);
	
	ALTER TABLE #_DM_SCHTEACH ADD Download_Datetime  Datetime NULL
	UPDATE #_DM_SCHTEACH SET Download_Datetime=getdate();

	-- >>>>>>>>>>>>>>>>>>>>>
	--
	-- Processing SchTeach Roles in the form of Check boxes on the Screen, and multiple <DEGREE_PROGRAM> tags on XML
	--
	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')	
	SELECT SCHTEACH.value('@id','bigint')id,		
		SCHTEACH.value('@dmd:lastModified','date')lastModified,
		Record.value('@username','varchar(60)')USERNAME,
		ISNULL(SCHTEACH.value('(CRS_ID/text())[1]','varchar(20)'),'')CRS_ID,
		ISNULL(SCHTEACH.value('(CRN/text())[1]','varchar(20)'),'')CRN,
		ISNULL(SCHTEACH.value('(TITLE/text())[1]','varchar(100)'),'')TITLE,
		ISNULL(SCHTEACH.value('(COURSEPRE/text())[1]','varchar(10)'),'')COURSEPRE,
		ISNULL(SCHTEACH.value('(COURSENUM/text())[1]','varchar(10)'),'')COURSENUM,
		ISNULL(Item.value('.','varchar(200)'),'')DEGREE_PROGRAM,	
		ROW_NUMBER()OVER(PARTITION BY SCHTEACH ORDER BY Item) SEQ,
		getdate() as Create_Datetime,
		getdate() as Download_Datetime		
	INTO #_DM_SCHTEACH_DEGREE_PROGRAM
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./SCHTEACH')SCHTEACHs(SCHTEACH)
	CROSS APPLY SCHTEACHs.SCHTEACH.nodes('./DEGREE_PROGRAM')Items(Item);
	


	DECLARE @fields varchar(2000)

	-- Verify Incoming Data Interity
	IF @userid IS NULL AND (SELECT COUNT(*) FROM #_DM_SCHTEACH)<10 
		BEGIN
			UPDATE dbo.webservices_requests SET SP_Error='SCHTEACH has no data' WHERE [ID]=@webservices_requests_id			
			RAISERROR('SCHTEACH has no Data',18,1)
		END
	-- Delete & Insert the staging data
	ELSE 
		BEGIN
			DECLARE @locked INTEGER;
			EXEC @locked = sp_getapplock 'shadowmaker-SCHTEACH','Exclusive','Session',20000; -- 20 second wait
			IF @locked < 0 
				BEGIN
					PRINT 'shadowmaker-SCHTEACH Import Locked'
					UPDATE dbo.webservices_requests SET SP_Error='shadowmaker-SCHTEACH Import Locked' WHERE [ID]=@webservices_requests_id			
				END
			ELSE 
				BEGIN
					SET @fields = 'username,lastModified,Download_Datetime,TYT_TERM,TYY_TERM,COURSEPRE,COURSENUM,TITLE,SECTION' +
									',DELIVERY_MODE,CRN,LEVEL,CENSUS_ENROLL,SYLLABUS,ENROLL,CHOURS,DMI_HOURS,COURSE_INFO_URL' +
									',COURSE_URL,ICES_COURSE,ICES_INSTRUCTOR,ICES_RESPONSES'
					EXEC dbo.shadow_screen_data1 @webservices_requests_id=@webservices_requests_id,@table='_DM_SCHTEACH'
						,@idtype=NULL,@cols=@fields
						,@userid=@userid,@resync=@resync,@debug=0


					-- Update records of @userid at relational tables _DM_SCHTEACH_DEGREE_PROGRAM in DM_Shadow_Staging and DM_Shadow_Production databases	
					-- MUST USE [ ] for system name to pass thru shadow_screen_data2	    
					SET @fields = 'id,lastModified,Create_Datetime,Download_Datetime' +
									',USERNAME,CRS_ID,CRN,TITLE,COURSEPRE,COURSENUM,DEGREE_PROGRAM,SEQ'
					EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
						,@table='_DM_SCHTEACH_DEGREE_PROGRAM'
						,@cols=@fields
						,@userid=@userid

					EXEC sp_releaseapplock 'shadowmaker-SCHTEACH','Session';
				END
		END
	DROP TABLE #_DM_SCHTEACH;

	
END



GO
