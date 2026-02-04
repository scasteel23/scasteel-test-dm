SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO




/*
	Manual run to shadow individual DSL screen
	EXEC dbo.webservices_initiate @screen='DSL'
	EXEC dbo.webservices_run_DTSX
*/
CREATE PROCEDURE [dbo].[shadow_DSL] (@webservices_requests_id INT, @xml XML,@userid BIGINT=NULL,@resync BIT=NULL) 
AS 

BEGIN

	-- https://beta.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/CURRICULUM
	/*
		XML Sample:
		<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
			<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy" />
			<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Career Services" text="Business Career Services" />
			<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services" />
			<DSL id="169824608256" dmd:originalSource="MANUAL" dmd:created="2018-09-20T10:44:56" dmd:lastModifiedSource="MANUAL" dmd:lastModified="2018-09-20T10:44:57" dmd:startDate="2017-10-01" dmd:endDate="2018-12-31">
				<TYPE>Academic Advisor or Mentor</TYPE>
				<TYPE_OTHER>No other</TYPE_OTHER>
				<TITLE>Consulting with Digital Courses Thesis</TITLE>
				<PROGRAM>Dissertation</PROGRAM>
				<LEVELS>Doctoral</LEVELS>
				<LEVELS>Master's</LEVELS>
				<LEVELS>Undergraduate</LEVELS>
				<SPONSOR>Gies Business</SPONSOR>
				<ORG>History</ORG>
				<INSTITUTION>Caterpillar</INSTITUTION>
				<SPONSOR_OTHER>no other sponsor</SPONSOR_OTHER>
				<DESC>Supervise Graduate Research Accompany International Trip IBM All Users for a Schema and Index Entry Retrieve users with access to University data in the College of Business</DESC>
				<DTM_START>October</DTM_START>
				<DTY_START>2017</DTY_START>
				<START_START>2017-10-01</START_START>
				<START_END>2017-10-31</START_END>
				<DTM_END>December</DTM_END>
				<DTY_END>2018</DTY_END>
				<END_START>2018-12-01</END_START>
				<END_END>2018-12-31</END_END>
				<WEB_PROFILE>Yes</WEB_PROFILE>
			</DSL>
		</Record>
		<Record userId="1910556" username="busfac1" termId="6117" dmd:surveyId="17699128">
			<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy" />
			<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Administration" text="Business Administration" />
			<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Finance" text="Finance" />
			<DSL id="164584628224" dmd:originalSource="MANAGE_DATA" dmd:created="2018-05-30T14:45:00" dmd:lastModifiedSource="MANAGE_DATA" dmd:lastModified="2018-08-06T19:31:28" dmd:startDate="2017-01-01" dmd:endDate="2017-12-31">
				<TYPE>Accompany International Trip</TYPE>
				<TYPE_OTHER />
				<TITLE>China Immersion Trip</TITLE>
				<PROGRAM />
				<LEVELS>Undergraduate</LEVELS>
				<SPONSOR>Gies Business</SPONSOR>
				<ORG>T&M Program</ORG>
				<INSTITUTION />
				<SPONSOR_OTHER />
				<DESC />
				<DTM_START />
				<DTY_START />
				<START_START />
				<START_END />
				<DTM_END />
				<DTY_END>2017</DTY_END>
				<END_START>2017-01-01</END_START>
				<END_END>2017-12-31</END_END>
				<WEB_PROFILE>No</WEB_PROFILE>
			</DSL>
				<DSL id="167761569792" dmd:originalSource="MANAGE_DATA" dmd:created="2018-08-06T16:58:09" dmd:lastModifiedSource="MANAGE_DATA" dmd:lastModified="2018-08-06T20:35:22" dmd:startDate="2015-01-01" dmd:endDate="2016-12-31">
				<TYPE>Mentor for Student Consulting and Capstone Teams</TYPE>
				<TYPE_OTHER />
				<TITLE>IBC Faculty Mentor</TITLE>
				<PROGRAM />
				<LEVELS>Undergraduate</LEVELS>
				<SPONSOR>Gies Business</SPONSOR>
				<ORG>IBC</ORG>
				<INSTITUTION />
				<SPONSOR_OTHER>Caterpillar</SPONSOR_OTHER>
				<DESC>Mentor for IBC student consulting team project to develop marketing strategy for new Caterpillar product</DESC>
				<DTM_START />
				<DTY_START>2015</DTY_START>
				<START_START>2015-01-01</START_START>
				<START_END>2015-12-31</START_END>
				<DTM_END />
				<DTY_END>2016</DTY_END>
				<END_START>2016-01-01</END_START>
				<END_END>2016-12-31</END_END>
				<WEB_PROFILE>No</WEB_PROFILE>
			 </DSL>
			 <DSL id="167781922816" dmd:originalSource="MANAGE_DATA" dmd:created="2018-08-07T10:50:28" dmd:lastModifiedSource="MANAGE_DATA" dmd:lastModified="2018-08-07T10:50:29" dmd:startDate="2015-01-01" dmd:endDate="2015-12-31">
				<TYPE>Accompany International Trip</TYPE>
				<TYPE_OTHER />
				<TITLE>China Immersion Trip</TITLE>
				<PROGRAM />
				<LEVELS>Undergraduate</LEVELS>
				<SPONSOR>Gies Business</SPONSOR>
				<ORG>T&M Program</ORG>
				<INSTITUTION />
				<SPONSOR_OTHER />
				<DESC />
				<DTM_START />
				<DTY_START />
				<START_START />
				<START_END />
				<DTM_END />
				<DTY_END>2015</DTY_END>
				<END_START>2015-01-01</END_START>
				<END_END>2015-12-31</END_END>
				<WEB_PROFILE>No</WEB_PROFILE>
		    </DSL>
			<DSL id="167763175424" dmd:originalSource="MANAGE_DATA" dmd:created="2018-08-06T21:38:33" dmd:lastModifiedSource="MANAGE_DATA" dmd:lastModified="2018-08-06T21:38:33" dmd:startDate="2014-01-01" dmd:endDate="2015-12-31">
				<TYPE>Supervise Graduate Research (Excluding Dissertations)</TYPE>
				<TYPE_OTHER />
				<TITLE>Special Research Project for John Smith</TITLE>
				<PROGRAM />
				<LEVELS>Master's</LEVELS>
				<SPONSOR>Other</SPONSOR>
				<ORG />
				<INSTITUTION>University of Wisconsin</INSTITUTION>
				<SPONSOR_OTHER />
				<DESC />
				<DTM_START />
				<DTY_START>2014</DTY_START>
				<START_START>2014-01-01</START_START>
				<START_END>2014-12-31</START_END>
				<DTM_END />
				<DTY_END>2015</DTY_END>
				<END_START>2015-01-01</END_START>
				<END_END>2015-12-31</END_END>
				<WEB_PROFILE>No</WEB_PROFILE>
			 </DSL>
		</Record>

	*/
	
	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')
	SELECT Record.value('@userId','bigint') userid,
		Record.value('@username','varchar(60)')username,		
		Record.value('@dmd:surveyId','bigint')surveyId,
		Record.value('@termId','bigint')termId,
		Item.value('@id','bigint') id,
		Item.value('@dmd:lastModified','date') lastModified,
		--ISNULL(Item.value('@access','varchar(50)'),'')access,

		ISNULL(Item.value('(FACSTAFFID/text())[1]','int'),'')FACSTAFFID,
		ISNULL(Item.value('(EDWPERSID/text())[1]','varchar(12)'),'')EDWPERSID,

		ISNULL(Item.value('(TYPE/text())[1]','varchar(200)'),'')[TYPE],
		ISNULL(Item.value('(TYPE_OTHER/text())[1]','varchar(200)'),'')TYPE_OTHER,
		ISNULL(Item.value('(TITLE/text())[1]','varchar(200)'),'')TITLE,
		ISNULL(Item.value('(PROGRAM/text())[1]','varchar(200)'),'')PROGRAM,

		ISNULL(Item.value('(SPONSOR/text())[1]','varchar(200)'),'')SPONSOR,
		ISNULL(Item.value('(ORG/text())[1]','varchar(200)'),'')ORG,

		ISNULL(Item.value('(INSTITUTION/text())[1]','varchar(200)'),'')INSTITUTION,
		ISNULL(Item.value('(SPONSOR_OTHER/text())[1]','varchar(200)'),'')SPONSOR_OTHER,
		ISNULL(Item.value('(DESC/text())[1]','varchar(1000)'),'')[DESC],

		ISNULL(Item.value('(DTM_START/text())[1]','varchar(20)'),'')DTM_START,
		ISNULL(Item.value('(DTY_START/text())[1]','varchar(4)'),'')DTY_START,
		ISNULL(Item.value('(START_START/text())[1]','varchar(20)'),'')START_START,
		ISNULL(Item.value('(START_END/text())[1]','varchar(20)'),'')START_END,
		ISNULL(Item.value('(DTM_END/text())[1]','varchar(20)'),'')DTM_END,
		ISNULL(Item.value('(DTY_END/text())[1]','varchar(4)'),'')DTY_END,
		ISNULL(Item.value('(END_START/text())[1]','varchar(20)'),'')END_START,
		ISNULL(Item.value('(END_END/text())[1]','varchar(20)'),'')END_END,
		
		ISNULL(Item.value('(WEB_PROFILE/text())[1]','varchar(3)'),'')WEB_PROFILE,

		getdate() as Create_Datetime,
		getdate() as Download_Datetime		

	INTO #_DM_DSL
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./DSL')Items(Item);
	
	-- DEBUG
	--SELECT * FROm #_DM_DSL;

	

	-- >>>>>>>>>>>>>>>>>>>>>
	--
	-- Processing DSL Levels in the form of Check boxes on the Screen, and multiple <LEVELS> tags on XML
	--
	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')	
	SELECT DSL.value('@id','bigint')id,		
		DSL.value('@dmd:lastModified','date')lastModified,
		Record.value('@username','varchar(60)')USERNAME,	
		ISNULL(Item.value('.','varchar(200)'),'')LEVELS,	
		ROW_NUMBER()OVER(PARTITION BY DSL ORDER BY Item) SEQ,
		getdate() as Create_Datetime,
		getdate() as Download_Datetime		
	INTO #_DM_DSL_LEVELS
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./DSL')DSLs(DSL)
	CROSS APPLY DSLs.DSL.nodes('./LEVELS')Items(Item);
	
	-- Make up the id as id + seq
	--UPDATE #_DM_DSL_LEVELS
	--SET id = CAST (CONCAT(CAST(id as varchar),CAST(SEQ as varchar)) as bigint);

	-- DEBUG
	--SELECT * FROm #_DM_DSL_LEVELS;




	DECLARE @tolerance INT
	DECLARE @fields varchar(3000), @fields2 varchar(3000)

	-- Copy to the production if number of the new records is greater than 80% of number of the current records
	-- SET @tolerance = 0.8 
	SET @tolerance = 0.8
	

	-- Verify Incoming Data Integrity
	IF @userid IS NULL AND (SELECT COUNT(*) FROM #_DM_DSL) < 1 
		BEGIN
			UPDATE dbo.webservices_requests SET SP_Error='DSL has no data' WHERE [ID]=@webservices_requests_id	
			RAISERROR('DSL has no Data',18,1) -- just to make sure we have some records, change the threshold to 10 or more on production
		END
	-- Delete & Insert the staging data
	ELSE BEGIN
		DECLARE @locked INTEGER;
		EXEC @locked = sp_getapplock 'shadowmaker-DSL','Exclusive','Session',20000; -- 20 second wait
		IF @locked < 0 
				BEGIN
					PRINT 'shadowmaker-DSL Import Locked'
					UPDATE dbo.webservices_requests SET SP_Error='shadowmaker-DSL Import Locked' WHERE [ID]=@webservices_requests_id						
				END
		ELSE 
			BEGIN

				IF @userid is not null
					BEGIN
						-- Update records of @userid at Main tables _DM_DSL in DM_Shadow_Staging and DM_Shadow_Production databases
						SET @fields = 'id,userid,lastModified,Create_Datetime,Download_Datetime' +
								      ',USERNAME,FACSTAFFID,EDWPERSID,[TYPE],TYPE_OTHER,TITLE,PROGRAM,SPONSOR,ORG,INSTITUTION' +
									  ',SPONSOR_OTHER,[DESC],WEB_PROFILE' +
									  ',DTM_START,DTY_START,START_START,START_END,DTM_END,DTY_END,END_START,END_END' 
						EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
							,@table='_DM_DSL'
							,@cols=@fields
							,@userid=@userid

						-- Update records of @userid at relational tables _DM_DSL_LEVELS in DM_Shadow_Staging and DM_Shadow_Production databases		    
						SET @fields = 'id,SEQ,lastModified,Create_Datetime,Download_Datetime' +
										',USERNAME,[LEVELS]'
						EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
							,@table='_DM_DSL_LEVELS'
							,@cols=@fields
							,@userid=@userid

					END
				ELSE
					BEGIN
						DECLARE @current_record_main_count INT, @new_record_main_count INT
						DECLARE @current_record_member_count INT, @new_record_member_count INT

						SELECT @current_record_main_count = count(*)
						FROM DM_Shadow_Production.dbo._DM_DSL

						SELECT @new_record_main_count = count(*)
						FROM #_DM_DSL

						SET @current_record_main_count = 0.8 * @current_record_main_count

						SELECT @current_record_member_count = count(*)
						FROM DM_Shadow_Production.dbo._DM_DSL_LEVELS

						SELECT @new_record_member_count = count(*)
						FROM #_DM_DSL_LEVELS

						SET @current_record_member_count = 0.8 * @current_record_member_count

						IF @new_record_main_count >= @current_record_main_count
								AND  @new_record_member_count >= @current_record_member_count
							BEGIN
								-- Truncate and Insert into Main tables _DM_DSL in DM_Shadow_Staging and DM_Shadow_Production databases																		
								SET @fields = 'id,userid,lastModified,Create_Datetime,Download_Datetime' +
								      ',USERNAME,FACSTAFFID,EDWPERSID,[TYPE],TYPE_OTHER,TITLE,PROGRAM,SPONSOR,ORG,INSTITUTION' +
									  ',SPONSOR_OTHER,[DESC],WEB_PROFILE' +
									  ',DTM_START,DTY_START,START_START,START_END,DTM_END,DTY_END,END_START,END_END' 
									  
								EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
									,@table='_DM_DSL'
									,@cols=@fields
									,@userid=NULL

								-- Truncate and Insert into Relational tables _DM_DSL_LEVELS in DM_Shadow_Staging and DM_Shadow_Production databases							
								SET @fields = 'id,SEQ,lastModified,Create_Datetime,Download_Datetime' +
										',USERNAME,[LEVELS]'
								EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
									,@table='_DM_DSL_LEVELS'
									,@cols=@fields
									,@userid=NULL

							
			
							END
						ELSE
							RAISERROR('DSL Data is too few',18,1)
				END

			END
			
		EXEC sp_releaseapplock 'shadowmaker-DSL','Session'; 

	END
	
	
	DROP TABLE #_DM_DSL;
	DROP TABLE #_DM_DSL_LEVELS;


END



GO
