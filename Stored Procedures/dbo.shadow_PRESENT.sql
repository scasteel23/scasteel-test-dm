SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- V3
--	NS 10/12/2017: Use shadow_screen_data2()
-- V2
-- NS 3/23/2017 
--		restructured _DM_PRESENT and _DM_PRESENT_AUTH tables
--			_DM_PRESENT has 1 record for each publication, _DM_PRESENT_AUTH ha 1 record for each (author,publication) 
--		rewrote the download codes: @DM_Shadow_Staging database truncate _DM_PRESENT and replace with DM XML's records
--		When successful: @DM_Shadow_Production database truncate _DM_PRESENT and replace with _DM_PRESENT from DM_Shadow_Staging
--		Do the same with _DM_PRESENT_AUTH tables
-- NS 2/28/2017: Replaced CONTR_TYPE with CLASSIFICATION, Added PUBPROCEED
-- NS 10/12/2016: newly updated shadow_screen_data SP
-- NS 10/5/22016: New, worked ate TEST_Shadow but... need to initialize sequence based on id on _DM_PRESENT_AUTH
--				  Get XML data from the downloader (SSIS package) insert into _DM_PRESENT table

/*
	Manual run to shadow individual PRESENT screen
	EXEC dbo.webservices_initiate @screen='PRESET'
	EXEC dbo.webservices_run_DTSX
*/

CREATE PROCEDURE [dbo].[shadow_PRESENT] (@webservices_requests_id INT,@xml XML,@userid BIGINT=NULL,@resync BIT=NULL) 
AS 

BEGIN

	--TRUNCATE TABLE _DM_PRESENT_AUTH
	--TRUNCATE TABLE _DM_PRESENT
	-- EXEC dbo._Test_Shadow_PRESENT

	-- GET all PRESENTATION data from
	-- https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/PRESENT
	-- XML Sample:
/*
	 USERNAME, 
	,FACSTAFF_ID, EDW_PERS_ID  
	,TITLE, STATUS, REFEREED, CITY,  STATE, COUNTRY                           
	,MEETING_TYPE, SCOPE_LOCALE, ORG, CLASSIFICATION, DESC, PUBPROCEED                                  
	,DOI, SSRN_ID,  DTM_DATE, DTY_DATE

	<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-09-30">
		<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
			<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy"/>
			<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Administration" text="Business Administration"/>
			<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services"/>
			
			<PRESENT id="134053957632" dmd:lastModified="2016-09-30T03:54:48" dmd:startDate="2016-08-01" dmd:endDate="2016-08-31">
				<TITLE>Sovereignty and Democracy</TITLE>
				<STATUS>Accepted</STATUS>
				<REFEREED>Yes</REFEREED>
				<NAME>General Assembly</NAME>
				<CITY>New York</CITY>
				<STATE>Illinois</STATE>
				<COUNTRY>United States of America</COUNTRY>
				<MEETING_TYPE>Research Seminar</MEETING_TYPE>
				<SCOPE_LOCALE>International</SCOPE_LOCALE>
				<ORG>United Nations</ORG>
				<CLASSIFICATION>Discipline-Based</CLASSIFICATION>
				<DESC>
				The sovereignty state of a country cannot be looked down and hence cannot be taken into lightly by other countries
				</DESC>
				<PUBPROCEED>Yes</PUBPROCEED>

				<PRESENT_AUTH id="134053957633">
				<FACULTY_NAME>1791140</FACULTY_NAME>
				<FNAME>Nursalim</FNAME>
				<MNAME/>
				<LNAME>Hadi</LNAME>
				<ROLE>Author</ROLE>
				</PRESENT_AUTH>

				<PRESENT_AUTH id="134053957635">
				<FACULTY_NAME>1940561</FACULTY_NAME>
				<FNAME>Jeffrey</FNAME>
				<MNAME>R</MNAME>
				<LNAME>Brown</LNAME>
				<ROLE>Author & Presenter</ROLE>
				</PRESENT_AUTH>

				<PRESENT_AUTH id="134053957636">
				<FACULTY_NAME/>
				<FNAME>Malory</FNAME>
				<MNAME>M</MNAME>
				<LNAME>Jeanne</LNAME>
				<ROLE>Author</ROLE>
				</PRESENT_AUTH>

				<DOI>23450</DOI>
				<SSRN_ID>1456710</SSRN_ID>
				<INVACC>Accepted</INVACC>
				<DTM_DATE>August</DTM_DATE>
				<DTY_DATE>2016</DTY_DATE>
				<DATE_START>2016-08-01</DATE_START>
				<DATE_END>2016-08-31</DATE_END>
				<WEB_PROFILE>Yes</WEB_PROFILE>
				<WEB_PROFILE_ORDER>3</WEB_PROFILE_ORDER>
				<USER_REFERENCE_CREATOR>Yes</USER_REFERENCE_CREATOR>
			</PRESENT>

			<PRESENT id="134053961728" dmd:lastModified="2016-09-30T03:58:34" dmd:startDate="2015-02-01" dmd:endDate="2015-02-28">
			<TITLE>Bitcoin and Blockchain</TITLE>
			<STATUS>Presented</STATUS>
			<REFEREED>No</REFEREED>
			<NAME>Digital Money in the New Brave World</NAME>
			<CITY>San Fransisco</CITY>
			<STATE>California</STATE>
			<COUNTRY>United States of America</COUNTRY>
			<MEETING_TYPE>Other</MEETING_TYPE>
			<SCOPE_LOCALE>International</SCOPE_LOCALE>
			<ORG>University of Illinois</ORG>
			<CLASSIFICATION>Contributions to Practice</CLASSIFICATION>
			<DESC>Blockchain is the tech</DESC>
			<PUBPROCEED>Yes</PUBPROCEED>

			<PRESENT_AUTH id="134053961729">
			<FACULTY_NAME>1791140</FACULTY_NAME>
			<FNAME>Nursalim</FNAME>
			<MNAME/>
			<LNAME>Hadi</LNAME>
			<ROLE>Presenter</ROLE>
			</PRESENT_AUTH>
			<PRESENT_AUTH id="134053961731">
			<FACULTY_NAME>1940566</FACULTY_NAME>
			<FNAME>Marcelo</FNAME>
			<MNAME/>
			<LNAME>Bucheli</LNAME>
			<ROLE>Presenter</ROLE>
			</PRESENT_AUTH>
			<DOI>678</DOI>
			<SSRN_ID>12345</SSRN_ID>
			<INVACC>Invited</INVACC>
			<DTM_DATE>February</DTM_DATE>
			<DTY_DATE>2015</DTY_DATE>
			<DATE_START>2015-02-01</DATE_START>
			<DATE_END>2015-02-28</DATE_END>
			<WEB_PROFILE>Yes</WEB_PROFILE>
			<WEB_PROFILE_ORDER>2</WEB_PROFILE_ORDER>
			<USER_REFERENCE_CREATOR>Yes</USER_REFERENCE_CREATOR>
			</PRESENT>
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

		ISNULL(Item.value('(TITLE/text())[1]','varchar(200)'),'')TITLE,
		ISNULL(Item.value('(CLASSIFICATION/text())[1]','varchar(100)'),'')CLASSIFICATION,
		ISNULL(Item.value('(MEETING_TYPE/text())[1]','varchar(100)'),'')MEETING_TYPE,
		ISNULL(Item.value('(NAME/text())[1]','varchar(100)'),'')NAME,
		ISNULL(Item.value('(SCOPE_LOCALE/text())[1]','varchar(50)'),'')SCOPE_LOCALE,
		ISNULL(Item.value('(REFEREED/text())[1]','varchar(3)'),'')REFEREED,
		ISNULL(Item.value('(DTM_DATE/text())[1]','varchar(50)'),'')DTM_DATE,
		ISNULL(Item.value('(DTY_DATE/text())[1]','varchar(50)'),'')DTY_DATE,

		ISNULL(Item.value('(DESC/text())[1]','varchar(400)'),'')[DESC],
		ISNULL(Item.value('(PUBPROCEED/text())[1]','varchar(3)'),'')[PUBPROCEED],
		ISNULL(Item.value('(STATUS/text())[1]','varchar(30)'),'')[STATUS],
		ISNULL(Item.value('(ORG/text())[1]','varchar(100)'),'')ORG,
		
		ISNULL(Item.value('(CITY/text())[1]','varchar(50)'),'')CITY,
		ISNULL(Item.value('(STATE/text())[1]','varchar(100)'),'')[STATE],
		ISNULL(Item.value('(COUNTRY/text())[1]','varchar(100)'),'')COUNTRY,
		
		ISNULL(Item.value('(SSRN_ID/text())[1]','varchar(150)'),'')SSRN_ID,
		ISNULL(Item.value('(DOI/text())[1]','varchar(50)'),'')DOI,
		getdate() as Create_Datetime,
		getdate() as Download_Datetime				
		--ISNULL(Item.value('(PERENNIAL/text())[1]','varchar(3)'),'')PERENNIAL

	INTO #_DM_PRESENT
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./PRESENT')Items(Item);
	
	-- DEBUG
	--SELECT * FROm #_DM_PRESENT

	
	-- >>>>>>>>>>>>>>>>>>>>>
	--   This is how to parse/process sub-screens; Sample XML
	/*
	    <Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-06-21">
	    <Record userId="1791141" username="scasteel" termId="6117" dmd:surveyId="17698890">
	    <PCI id="125211813888" dmd:lastModified="2016-05-10T13:58:33">
	    ...
	    ...
		<PRESENT_AUTH id="134053957633">
				<FACULTY_NAME>1791140</FACULTY_NAME>
				<FNAME>Nursalim</FNAME>
				<MNAME/>
				<LNAME>Hadi</LNAME>
				<ROLE>Author</ROLE>
				</PRESENT_AUTH>

				<PRESENT_AUTH id="134053957635">
				<FACULTY_NAME>1940561</FACULTY_NAME>
				<FNAME>Jeffrey</FNAME>
				<MNAME>R</MNAME>
				<LNAME>Brown</LNAME>
				<ROLE>Author & Presenter</ROLE>
				</PRESENT_AUTH>

				<PRESENT_AUTH id="134053957636">
				<FACULTY_NAME/>
				<FNAME>Malory</FNAME>
				<MNAME>M</MNAME>
				<LNAME>Jeanne</LNAME>
				<ROLE>Author</ROLE>
				</PRESENT_AUTH>	--    ...
	    ...
	    </PRESENT>
	    </Record>
	    </Data>

	*/
	-- >>>>>>>>>>>>>>>>>>>>>
	--
	---- AUTHORS[web_profile]
	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')
	
	
	SELECT PRESENT.value('@id','bigint')id,
		PRESENT.value('@userid','bigint')userid,
		PRESENT.value('@dmd:lastModified','date')lastModified,
		PRESENT.value('@username','varchar(60)')USERNAME,
		Item.value('@id','bigint')itemid,
		ISNULL(Item.value('LNAME[1]','varchar(200)'),'')LNAME,
		ISNULL(Item.value('FNAME[1]','varchar(200)'),'')FNAME,
		ISNULL(Item.value('MNAME[1]','varchar(200)'),'')MNAME,
		ISNULL(Item.value('FACULTY_NAME[1]','varchar(60)'),'')FACULTY_NAME,
		ISNULL(Item.value('ROLE[1]','varchar(100)'),'')[ROLE],
		ROW_NUMBER()OVER(PARTITION BY PRESENT ORDER BY Item)sequence,
		getdate() as Create_Datetime,
		getdate() as Download_Datetime	
	INTO #_DM_PRESENT_AUTH
	FROM @xml.nodes('/Data/Record/PRESENT')PRESENTs(PRESENT)
		CROSS APPLY PRESENTs.PRESENT.nodes('./PRESENT_AUTH')Items(Item);
	
	---- LINKS
	--WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')
	--SELECT PCI.value('@id','bigint')id,
	--	Item.value('@id','bigint')itemid,
	--	ISNULL(Item.value('NAME[1]','varchar(150)'),'')NAME,
	--	ISNULL(Item.value('URL[1]','varchar(255)'),'')URL,
	--	ROW_NUMBER()OVER(PARTITION BY PCI.value('@id','bigint') ORDER BY Item)sequence
	--INTO #LINKS
	--FROM @xml.nodes('/Data/Record/PCI')PCIs(PCI)
	--	CROSS APPLY PCIs.PCI.nodes('./LINK')Items(Item);

	DECLARE @tolerance INT
	DECLARE @fields varchar(3000), @fields2 varchar(3000)

	-- Copy to the production if number of the new records is greater than 80% of number of the current records
	-- SET @tolerance = 0.8 
	SET @tolerance = 0.8

	-- Verify Incoming Data Integrity
	IF @userid IS NULL AND (SELECT COUNT(*) FROM #_DM_PRESENT) < 10 -- just to make sure we have some records, change the threshold to 10 or more on production
		BEGIN
			UPDATE dbo.webservices_requests SET SP_Error='PRESENT has no data' WHERE [ID]=@webservices_requests_id			
			RAISERROR('PRESENT has no Data',18,1)
		END
	-- Delete & Insert the staging data
	ELSE 
		BEGIN
		DECLARE @locked INTEGER;
		EXEC @locked = sp_getapplock 'shadowmaker-PRESENT','Exclusive','Session',20000; -- 20 second wait
		IF @locked < 0 
			BEGIN
					PRINT 'shadowmaker-PRESENT Import Locked'
					UPDATE dbo.webservices_requests SET SP_Error='shadowmaker-PRESENT Import Locked' WHERE [ID]=@webservices_requests_id			
			END
		ELSE BEGIN

			IF @userid is not null
				BEGIN
					-- Truncate and Insert into tables _DM_PRESENT in DM_Shadow_Staging and DM_Shadow_Production databases
					SET @fields = 'id,lastModified,Create_Datetime,Download_Datetime' +
									',TITLE,CLASSIFICATION,NAME,STATUS,REFEREED,CITY,STATE,COUNTRY' +                      
									',MEETING_TYPE,SCOPE_LOCALE,ORG,PUBPROCEED,[DESC]' +
									',DOI,SSRN_ID,DTM_DATE,DTY_DATE'
					EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
					    ,@table='_DM_PRESENT'
						,@cols=@fields
						,@userid=@userid				

					-- Truncate and Insert into relational tables _DM_PRESENT_AUTH in DM_Shadow_Staging and DM_Shadow_Production databases
					SET @fields = 	'id,itemid,lastModified,Create_Datetime,Download_Datetime' +
							',FACULTY_NAME,FNAME,MNAME,LNAME,ROLE,sequence'
					EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
						,@table='_DM_PRESENT_AUTH'
						,@cols=@fields
						,@userid=@userid

				END
			ELSE
				BEGIN

					DECLARE @current_record_main_count INT, @new_record_main_count INT, @current_record_phone_count INT
					DECLARE @current_record_auth_count INT, @new_record_auth_count INT 

					SELECT @current_record_main_count = count(*)
					FROM DM_Shadow_Production.dbo._DM_PRESENT

					SELECT @new_record_main_count = count(*)
					FROM #_DM_PRESENT

					SELECT @current_record_auth_count = count(*)
					FROM DM_Shadow_Production.dbo._DM_PRESENT_AUTH

					SELECT @new_record_auth_count = count(*)
					FROM #_DM_PRESENT_AUTH

					SET @current_record_main_count = @tolerance * @current_record_main_count
					SET @current_record_auth_count = @tolerance * @current_record_auth_count
			
					IF @new_record_main_count >= @current_record_main_count
								AND  @new_record_auth_count >= @current_record_auth_count

						BEGIN
							-- Update records of @userid at relational tables _DM_PRESENT in DM_Shadow_Staging and DM_Shadow_Production databases		    												
							SET @fields = 'id,lastModified,Create_Datetime,Download_Datetime' +
									',TITLE,CLASSIFICATION,NAME,STATUS,REFEREED,CITY,STATE,COUNTRY' +                      
									',MEETING_TYPE,SCOPE_LOCALE,ORG,PUBPROCEED,[DESC]' +
									',DOI,SSRN_ID,DTM_DATE,DTY_DATE'
							EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
								,@table='_DM_PRESENT'
								,@cols=@fields
								,@userid=NULL				

							-- Update records of @userid at relational tables _DM_PRESENT_AUTH in DM_Shadow_Staging and DM_Shadow_Production databases		    					
							SET @fields = 	'id,itemid,lastModified,Create_Datetime,Download_Datetime' +
									',FACULTY_NAME,FNAME,MNAME,LNAME,ROLE,sequence'
							EXEC dbo.shadow_screen_data2 @webservices_requests_id=@webservices_requests_id
								,@table='_DM_PRESENT_AUTH'
								,@cols=@fields
								,@userid=NULL
							
						END
					ELSE
						BEGIN
							UPDATE dbo.webservices_requests SET SP_Error='PRESENT Data is too few' WHERE [ID]=@webservices_requests_id		
							RAISERROR('shadow_PRESENT - Data is too few',18,1)
						END
				END
	
			EXEC sp_releaseapplock 'shadowmaker-PRESENT','Session'; 


		END



	END
	
	
	DROP TABLE #_DM_PRESENT;
	DROP TABLE #_DM_PRESENT_AUTH;
	--DROP TABLE #RESEARCH_KEYWORD;
	--DROP TABLE #LINKS;

END



GO
