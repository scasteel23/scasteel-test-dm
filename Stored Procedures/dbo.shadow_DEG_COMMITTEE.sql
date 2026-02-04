SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- V4
-- NS 9/17/2018: worked!
-- NS 9/14/2018: final version of the screen
-- V3
-- NS 10/12/2017: use shadow_screen_data2()
-- V2
-- NS 4/24/2017, created, worked

CREATE PROCEDURE [dbo].[shadow_DEG_COMMITTEE] (@webservices_requests_id INT,@xml XML,@userid BIGINT=NULL,@resync BIT=NULL) 
AS 

BEGIN

	/*
	 TEST
	    TRUNCATE TABle _DM_DEG_COMMITTEE
	    TRUNCATE TABLE _DM_DEG_COMMITTEE_TYPE
	    TRUNCATE TABLE _DM_DEG_COMMITTEE_ROLE
	    EXEC dbo._Test_Shadow_DEG_COMMITTEE
	 */

	 /*
		Manual run to shadow individual CONGRANT screen
		EXEC dbo.webservices_initiate @screen='DEG_COMMITTEE'
		EXEC dbo.webservices_run_DTSX
	 */	

	-- GET all GRANT data from
	-- https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/DEG_COMMITTEE
	-- XML Sample:
/*
	  <Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2017-04-24">
	  <Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
			<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy" />
			<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Career Services" text="Business Career Services" />
			<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services" />
		<DEG_COMMITTEE id="133567455232" dmd:originalSource="MANUAL" dmd:created="2016-09-16T18:40:29" dmd:lastModifiedSource="MANUAL" dmd:lastModified="2018-09-14T16:06:22" dmd:startDate="2011-01-01" dmd:endDate="2018-02-28">
			<FNAME>Kenny</FNAME>
			<LNAME>Sullivan</LNAME>
			<UIN>888888</UIN>
			<INSTITUTION>Gies Business</INSTITUTION>
			<INSTITUTION_OTHER />
			<DEP>Accountancy</DEP>
			<DEP_OTHER />
			<TYPE>Master's Thesis</TYPE>
			<TYPE>PhD Final (Dissertation)</TYPE>
			<TYPE>PhD Prelim (Proposal)</TYPE>
			<TYPE_OTHER />
			<ROLE>Chair</ROLE>
			<ROLE>Co-Chair</ROLE>
			<ROLE>Co-Director of Research</ROLE>
			<ROLE>Director of Research</ROLE>
			<ROLE>Other</ROLE>
			<ROLE_OTHER>Committee Auditor</ROLE_OTHER>
			<DTM_START>January</DTM_START>
			<DTY_START>2011</DTY_START>
			<START_START>2011-01-01</START_START>

			<START_END>2011-01-31</START_END>
			<DTM_END>February</DTM_END>
			<DTY_END>2018</DTY_END>
			<END_START>2018-02-01</END_START>
			<END_END>2018-02-28</END_END>

			<DTM_PRELIM_START>February</DTM_PRELIM_START>
			<DTY_PRELIM_START>2016</DTY_PRELIM_START>
			<PRELIM_START_START>2016-02-01</PRELIM_START_START>
			<PRELIM_START_END>2016-02-28</PRELIM_START_END>
			<DTM_PRELIM_END>March</DTM_PRELIM_END>
			<DTY_PRELIM_END>2017</DTY_PRELIM_END>
			<PRELIM_END_START>2017-03-01</PRELIM_END_START>
			<PRELIM_END_END>2017-03-31</PRELIM_END_END>
			<DTM_FINAL_START>February</DTM_FINAL_START>
			<DTY_FINAL_START>2018</DTY_FINAL_START>
			<FINAL_START_START>2018-02-01</FINAL_START_START>
			<FINAL_START_END>2018-02-28</FINAL_START_END>
			<DTM_FINAL_END>May</DTM_FINAL_END>
			<DTY_FINAL_END>2020</DTY_FINAL_END>
			<FINAL_END_START>2020-05-01</FINAL_END_START>
			<FINAL_END_END>2020-05-31</FINAL_END_END>
			<DESC>I am in a Degree Committee, yeah</DESC>
			<TITLE>What A Different a Day Makes</TITLE>
			<PLACEMENT>KPMG</PLACEMENT>
			<WEB_PROFILE>Yes</WEB_PROFILE>
		</DEG_COMMITTEE>
		<DEG_COMMITTEE id="133567440896" dmd:originalSource="MANUAL" dmd:created="2016-09-16T18:39:38" dmd:lastModifiedSource="MANUAL" dmd:lastModified="2018-08-03T15:05:17" dmd:startDate="2011-02-01" dmd:endDate="2016-02-28">
			<FNAME>John</FNAME>
			<LNAME>Padila</LNAME>
			<UIN>777777</UIN>
			<INSTITUTION>Other Institution</INSTITUTION>
			<INSTITUTION_OTHER>University of Virginia</INSTITUTION_OTHER>
			<DEP>Other</DEP>
			<DEP_OTHER>Electrical Engineering</DEP_OTHER>
			<TYPE>Master's Thesis</TYPE>
			<TYPE>PhD Final (Dissertation)</TYPE>
			<TYPE>PhD Prelim (Proposal)</TYPE>
			<TYPE_OTHER>Not sure</TYPE_OTHER>
			<ROLE>Chair</ROLE>
			<ROLE>Co-Chair</ROLE>
			<ROLE>Director of Research</ROLE>
			<ROLE>Other</ROLE>
			<ROLE_OTHER>Psycho Therapist</ROLE_OTHER>
			<DTM_START>February</DTM_START>
			<DTY_START>2011</DTY_START>
			<START_START>2011-02-01</START_START>
			<START_END>2011-02-28</START_END>
			<DTM_END>February</DTM_END>
			<DTY_END>2016</DTY_END>
			<END_START>2016-02-01</END_START>
			<END_END>2016-02-28</END_END>
			<DTM_PRELIM_START>January</DTM_PRELIM_START>
			<DTY_PRELIM_START>2014</DTY_PRELIM_START>
			<PRELIM_START_START>2014-01-01</PRELIM_START_START>
			<PRELIM_START_END>2014-01-31</PRELIM_START_END>
			<DTM_PRELIM_END>February</DTM_PRELIM_END>
			<DTY_PRELIM_END>2016</DTY_PRELIM_END>
			<PRELIM_END_START>2016-02-01</PRELIM_END_START>
			<PRELIM_END_END>2016-02-28</PRELIM_END_END>
			<DTM_FINAL_START>January</DTM_FINAL_START>
			<DTY_FINAL_START>2015</DTY_FINAL_START>
			<FINAL_START_START>2015-01-01</FINAL_START_START>
			<FINAL_START_END>2015-01-31</FINAL_START_END>
			<DTM_FINAL_END>March</DTM_FINAL_END>
			<DTY_FINAL_END>2016</DTY_FINAL_END>
			<FINAL_END_START>2016-03-01</FINAL_END_START>
			<FINAL_END_END>2016-03-31</FINAL_END_END>
			<DESC>The student and advisor are exploring possible ways to do self psychotherapy</DESC>
			<TITLE>Research on Self Psychotherapy</TITLE>
			<PLACEMENT>Not sure what it is</PLACEMENT>
			<WEB_PROFILE>Yes</WEB_PROFILE>
		</DEG_COMMITTEE>
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

		ISNULL(Item.value('(FNAME/text())[1]','varchar(130)'),'')FNAME,
		ISNULL(Item.value('(LNAME/text())[1]','varchar(120)'),'')LNAME,
		ISNULL(Item.value('(UIN/text())[1]','varchar(10)'),'')UIN,
		ISNULL(Item.value('(INSTITUTION/text())[1]','varchar(200)'),'')INSTITUTION,
		ISNULL(Item.value('(INSTITUTION_OTHER/text())[1]','varchar(200)'),'')INSTITUTION_OTHER,
		ISNULL(Item.value('(DEP/text())[1]','varchar(200)'),'')DEP,
		ISNULL(Item.value('(DEP_OTHER/text())[1]','varchar(200)'),'')DEP_OTHER,

		ISNULL(Item.value('(TYPE_OTHER/text())[1]','varchar(200)'),'')TYPE_OTHER,
		ISNULL(Item.value('(ROLE_OTHER/text())[1]','varchar(200)'),'')ROLE_OTHER,

		ISNULL(Item.value('(DTM_START/text())[1]','varchar(20)'),'')DTM_START,
		ISNULL(Item.value('(DTY_START/text())[1]','varchar(4)'),'')DTY_START,
		ISNULL(Item.value('(START_START/text())[1]','varchar(20)'),'')START_START,
		ISNULL(Item.value('(START_END/text())[1]','varchar(20)'),'')START_END,
		ISNULL(Item.value('(DTM_END/text())[1]','varchar(20)'),'')DTM_END,
		ISNULL(Item.value('(DTY_END/text())[1]','varchar(4)'),'')DTY_END,
		ISNULL(Item.value('(END_START/text())[1]','varchar(20)'),'')END_START,
		ISNULL(Item.value('(END_END/text())[1]','varchar(20)'),'')END_END,

		ISNULL(Item.value('(DTM_PRELIM_START/text())[1]','varchar(20)'),'')DTM_PRELIM_START,
		ISNULL(Item.value('(DTY_PRELIM_START/text())[1]','varchar(4)'),'')DTY_PRELIM_START,
		ISNULL(Item.value('(PRELIM_START_START/text())[1]','varchar(20)'),'')PRELIM_START_START,
		ISNULL(Item.value('(PRELIM_START_END/text())[1]','varchar(20)'),'')PRELIM_START_END,
		ISNULL(Item.value('(DTM_PRELIM_END/text())[1]','varchar(20)'),'')DTM_PRELIM_END,
		ISNULL(Item.value('(DTY_PRELIM_END/text())[1]','varchar(4)'),'')DTY_PRELIM_END,
		ISNULL(Item.value('(PRELIM_END_START/text())[1]','varchar(20)'),'')PRELIM_END_START,
		ISNULL(Item.value('(PRELIM_END_END/text())[1]','varchar(20)'),'')PRELIM_END_END,

		ISNULL(Item.value('(DTM_FINAL_START/text())[1]','varchar(20)'),'')DTM_FINAL_START,
		ISNULL(Item.value('(DTY_FINAL_START/text())[1]','varchar(4)'),'')DTY_FINAL_START,
		ISNULL(Item.value('(FINAL_START_START/text())[1]','varchar(20)'),'')FINAL_START_START,
		ISNULL(Item.value('(FINAL_START_END/text())[1]','varchar(20)'),'')FINAL_START_END,
		ISNULL(Item.value('(DTM_FINAL_END/text())[1]','varchar(20)'),'')DTM_FINAL_END,
		ISNULL(Item.value('(DTY_FINAL_END/text())[1]','varchar(4)'),'')DTY_FINAL_END,
		ISNULL(Item.value('(FINAL_END_START/text())[1]','varchar(20)'),'')FINAL_END_START,
		ISNULL(Item.value('(FINAL_END_END/text())[1]','varchar(20)'),'')FINAL_END_END,

		ISNULL(Item.value('(TITLE/text())[1]','varchar(200)'),'')TITLE,
		ISNULL(Item.value('(DESC/text())[1]','varchar(1000)'),'')[DESC],
		ISNULL(Item.value('(PLACEMENT/text())[1]','varchar(200)'),'')PLACEMENT,
		ISNULL(Item.value('(WEB_PROFILE/text())[1]','varchar(3)'),'')WEB_PROFILE,

		getdate() as Create_Datetime,
		getdate() as Download_Datetime		

	INTO #_DM_DEG_COMMITTEE
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./DEG_COMMITTEE')Items(Item);
	
	-- DEBUG
	--SELECT * FROm #_DM_DEG_COMMITTEE;

	

	-- >>>>>>>>>>>>>>>>>>>>>
	--
	-- Processing Degree Committee Types in the form of Check boxes on the Screen, and multiple <TYPE> tags on XML
	--
	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')	
	SELECT DEG_COMMITTEE.value('@id','bigint')id,		
		DEG_COMMITTEE.value('@dmd:lastModified','date')lastModified,
		Record.value('@username','varchar(60)')USERNAME,
		ISNULL(DEG_COMMITTEE.value('(FNAME/text())[1]','varchar(120)'),'')FNAME,
		ISNULL(DEG_COMMITTEE.value('(LNAME/text())[1]','varchar(120)'),'')LNAME,
		ISNULL(DEG_COMMITTEE.value('(UIN/text())[1]','varchar(10)'),'')UIN,
		ISNULL(Item.value('.','varchar(200)'),'')[TYPE],	
		ROW_NUMBER()OVER(PARTITION BY DEG_COMMITTEE ORDER BY Item) SEQ,
		getdate() as Create_Datetime,
		getdate() as Download_Datetime		
	INTO #_DM_DEG_COMMITTEE_TYPE
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./DEG_COMMITTEE')DEG_COMMITTEEs(DEG_COMMITTEE)
	CROSS APPLY DEG_COMMITTEEs.DEG_COMMITTEE.nodes('./TYPE')Items(Item);
	
	-- Make up the id as id + seq
	--UPDATE #_DM_DEG_COMMITTEE_TYPE
	--SET id = CAST (CONCAT(CAST(id as varchar),CAST(SEQ as varchar)) as bigint);

	-- DEBUG
	--SELECT * FROm #_DM_DEG_COMMITTEE_TYPE;



	-- >>>>>>>>>>>>>>>>>>>>>
	--
	-- Processing Degree Committee Roles in the form of Check boxes on the Screen, and multiple <ROLE> tags on XML
	--
	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')	
	SELECT DEG_COMMITTEE.value('@id','bigint')id,		
		DEG_COMMITTEE.value('@dmd:lastModified','date')lastModified,
		Record.value('@username','varchar(60)')USERNAME,
		ISNULL(DEG_COMMITTEE.value('(FNAME/text())[1]','varchar(120)'),'')FNAME,
		ISNULL(DEG_COMMITTEE.value('(LNAME/text())[1]','varchar(120)'),'')LNAME,
		ISNULL(DEG_COMMITTEE.value('(UIN/text())[1]','varchar(10)'),'')UIN,
		ISNULL(Item.value('.','varchar(200)'),'')[ROLE],	
		ROW_NUMBER()OVER(PARTITION BY DEG_COMMITTEE ORDER BY Item) SEQ,
		getdate() as Create_Datetime,
		getdate() as Download_Datetime		
	INTO #_DM_DEG_COMMITTEE_ROLE
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./DEG_COMMITTEE')DEG_COMMITTEEs(DEG_COMMITTEE)
	CROSS APPLY DEG_COMMITTEEs.DEG_COMMITTEE.nodes('./ROLE')Items(Item);
	
	---- DEBUG
	--SELECT * FROm #_DM_DEG_COMMITTEE_ROLE

	-- Make up the id as id + seq
	--UPDATE #_DM_DEG_COMMITTEE_ROLE
	--SET id = CAST (CONCAT(CAST(id as varchar),CAST(SEQ as varchar)) as bigint);

	-- DEBUG
	SELECT * FROm #_DM_DEG_COMMITTEE_ROLE




	DECLARE @tolerance INT
	DECLARE @fields varchar(3000), @fields2 varchar(3000)

	-- Copy to the production if number of the new records is greater than 80% of number of the current records
	-- SET @tolerance = 0.8 
	SET @tolerance = 0.8
	

	-- Verify Incoming Data Integrity
	IF @userid IS NULL AND (SELECT COUNT(*) FROM #_DM_DEG_COMMITTEE) < 1 
		BEGIN
			UPDATE dbo.webservices_requests SET SP_Error='DEG_COMMITTEE has no data' WHERE [ID]=@webservices_requests_id	
			RAISERROR('DEG_COMMITTEE has no Data',18,1) -- just to make sure we have some records, change the threshold to 10 or more on production
		END
	-- Delete & Insert the staging data
	ELSE BEGIN
		DECLARE @locked INTEGER;
		EXEC @locked = sp_getapplock 'shadowmaker-DEG_COMMITTEE','Exclusive','Session',20000; -- 20 second wait
		IF @locked < 0 
				BEGIN
					PRINT 'shadowmaker-DEG_COMMITTEE Import Locked'
					UPDATE dbo.webservices_requests SET SP_Error='shadowmaker-DEG_COMMITTEE Import Locked' WHERE [ID]=@webservices_requests_id						
				END
		ELSE 
			BEGIN

				IF @userid is not null
					BEGIN
						-- Update records of @userid at Main tables _DM_DEG_COMMITTEE in DM_Shadow_Staging and DM_Shadow_Production databases
						SET @fields = 'id,userid,lastModified,Create_Datetime,Download_Datetime' +
								      ',USERNAME,FNAME,LNAME,UIN,INSTITUTION,INSTITUTION_OTHER,DEP,DEP_OTHER,TYPE_OTHER' +
									  ',DTM_START,DTY_START,START_START,START_END,DTM_END,DTY_END,END_START,END_END' +
									  ',DTM_PRELIM_START ,DTY_PRELIM_START,PRELIM_START_START,PRELIM_START_END,DTM_PRELIM_END,DTY_PRELIM_END,PRELIM_END_START,PRELIM_END_END' +
									  ',DTM_FINAL_START ,DTY_FINAL_START,FINAL_START_START,FINAL_START_END,DTM_FINAL_END,DTY_FINAL_END,FINAL_END_START,FINAL_END_END' +
									  ',[DESC],TITLE,PLACEMENT,WEB_PROFILE' 
						EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
							,@table='_DM_DEG_COMMITTEE'
							,@cols=@fields
							,@userid=@userid

						-- Update records of @userid at relational tables _DM_DEG_COMMITTEE_TYPE in DM_Shadow_Staging and DM_Shadow_Production databases	
						-- MUST USE [ ] for system name to pass thru shadow_screen_data2
						SET @fields = 'id,lastModified,Create_Datetime,Download_Datetime' +
										',USERNAME,FNAME,LNAME,UIN,[TYPE],SEQ'
						EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
							,@table='_DM_DEG_COMMITTEE_TYPE'
							,@cols=@fields
							,@userid=@userid

						-- Update records of @userid at relational tables _DM_DEG_COMMITTEE_ROLE in DM_Shadow_Staging and DM_Shadow_Production databases	
						-- MUST USE [ ] for system name to pass thru shadow_screen_data2	    
						SET @fields = 'id,lastModified,Create_Datetime,Download_Datetime' +
										',USERNAME,FNAME,LNAME,UIN,[ROLE],SEQ'
						EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
							,@table='_DM_DEG_COMMITTEE_ROLE'
							,@cols=@fields
							,@userid=@userid

					END
				ELSE
					BEGIN
						DECLARE @current_record_main_count INT, @new_record_main_count INT
						DECLARE @current_record_member_count INT, @new_record_member_count INT

						SELECT @current_record_main_count = count(*)
						FROM DM_Shadow_Production.dbo._DM_DEG_COMMITTEE

						SELECT @new_record_main_count = count(*)
						FROM #_DM_DEG_COMMITTEE

						SET @current_record_main_count = 0.8 * @current_record_main_count

						SELECT @current_record_member_count = count(*)
						FROM DM_Shadow_Production.dbo._DM_DEG_COMMITTEE_TYPE

						SELECT @new_record_member_count = count(*)
						FROM #_DM_DEG_COMMITTEE_TYPE

						SET @current_record_member_count = 0.8 * @current_record_member_count

						IF @new_record_main_count >= @current_record_main_count
								AND  @new_record_member_count >= @current_record_member_count
							BEGIN
								-- Truncate and Insert into Main tables _DM_DEG_COMMITTEE in DM_Shadow_Staging and DM_Shadow_Production databases																		
								SET @fields = 'id,userid,lastModified,Create_Datetime,Download_Datetime' +
								      ',USERNAME,FNAME,LNAME,UIN,INSTITUTION,INSTITUTION_OTHER,DEP,DEP_OTHER,TYPE_OTHER' +
									  ',DTM_START,DTY_START,START_START,START_END,DTM_END,DTY_END,END_START,END_END' +
									  ',DTM_PRELIM_START ,DTY_PRELIM_START,PRELIM_START_START,PRELIM_START_END,DTM_PRELIM_END,DTY_PRELIM_END,PRELIM_END_START,PRELIM_END_END' +
									  ',DTM_FINAL_START ,DTY_FINAL_START,FINAL_START_START,FINAL_START_END,DTM_FINAL_END,DTY_FINAL_END,FINAL_END_START,FINAL_END_END' +
									  ',[DESC],TITLE,PLACEMENT,WEB_PROFILE' 
								EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
									,@table='_DM_DEG_COMMITTEE'
									,@cols=@fields
									,@userid=NULL

								-- Truncate and Insert into Relational tables _DM_DEG_COMMITTEE_TYPE in DM_Shadow_Staging and DM_Shadow_Production databases							
								SET @fields = 'id,lastModified,Create_Datetime,Download_Datetime' +
										',USERNAME,FNAME,LNAME,UIN,[TYPE],SEQ'
								EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
									,@table='_DM_DEG_COMMITTEE_TYPE'
									,@cols=@fields
									,@userid=NULL

								-- Truncate and Insert into Relational tables _DM_DEG_COMMITTEE_ROLE in DM_Shadow_Staging and DM_Shadow_Production databases							
								SET @fields = 'id,lastModified,Create_Datetime,Download_Datetime' +
										',USERNAME,FNAME,LNAME,UIN,[ROLE],SEQ'
								EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
									,@table='_DM_DEG_COMMITTEE_ROLE'
									,@cols=@fields
									,@userid=NULL
			
							END
						ELSE
							RAISERROR('DEG_COMMITTEE Data is too few',18,1)
				END

			END
			
		EXEC sp_releaseapplock 'shadowmaker-DEG_COMMITTEE','Session'; 

	END
	
	
	DROP TABLE #_DM_DEG_COMMITTEE;
	DROP TABLE #_DM_DEG_COMMITTEE_TYPE;
	--DROP TABLE #LINKS;

END



GO
