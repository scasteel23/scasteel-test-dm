SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 8/2/2018: dropped ORCID, due to new contract done Watermark who bought Digital Measures some time in May 2018
-- NS 5/10/2017: Added fields (ORCID, RANK) and removed fields (*interest, and bio)
-- NS 9/6/22016: Adjusted fields to DM Business instance: worked!
-- NS 6/22/2016:
--		Worked!
--		BOTH tables i.e DM_Shadow_Staging.dbo.PCI and DM_Shadow_Production.dbo.PCI have to have records that were downloaded previously from DM
--		This SP will match DM records with PCI tables in FSDB_Staging1 (based on id field), then create records at #changePCI for PCI records that has updates in DM
--		Therefore thsee tables could not be empty, this SP would not insert new records into these tables
--		This SP will take input XML from DM and update both tables based on DM values

-- NS 6/20/2016 (modified from Michael Painter's codes)
--				  Get XML data from the downloader (SSIS package) insert into _DM_PCI table

/*
	Manual run to shadow individual PCI screen
	EXEC dbo.webservices_initiate @screen='PCI'
	DECLARE @Result varchar(500)
	EXEC dbo.webservices2_run @Result = @Result OUTPUT
*/

CREATE PROCEDURE [dbo].[shadow_PCI] (@webservices_requests_id INT,@xml XML,@userid BIGINT=NULL,@resync BIT=NULL) 
AS 

BEGIN

	-- GET all PCI data from
	-- https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/PCI
	-- XML Sample:
	/*
		<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-06-21">
		<Record userId="1791141" username="scasteel" termId="6117" dmd:surveyId="17698890">
			<PCI id="125211813888" dmd:lastModified="2016-05-10T13:58:33">
			<PREFIX/>
			<FNAME>Scott</FNAME><PFNAME/><MNAME/><LNAME>Casteel</LNAME>
			<BANNER_FNAME>Scott</BANNER_FNAME><BANNER_MNAME/><BANNER_LNAME>Casteel</BANNER_LNAME>
			<SUFFIX/><ALT_NAME/><ENDPOS/><EMAIL>scasteel@illinois.edu</EMAIL><EMERGENCY_CONTACT/><WEBSITE/><TWITTER/><LINKEDIN/><DTM_DOB/><DTD_DOB/><DTY_DOB/><DOB_START/><DOB_END/><GENDER/><ETHNICITY/><CITIZEN/><BIO/><TEACHING_INTERESTS/><RESEARCH_INTERESTS/><QUOTE/><UPLOAD_CV>scasteel/pci/Vader Resume-1.docx</UPLOAD_CV><DISPLAY_ONLINE/><SHOW_PHOTO/><RESEARCH_KEYWORD id="125211813889"><KEYWORD/></RESEARCH_KEYWORD><LINK id="125211813890"><NAME/><URL/></LINK>
			</PCI>
		</Record>
		<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
			<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Accountancy" text="Accountancy"/>
			<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business Administration" text="Business Administration"/>
			<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services"/>
			<PCI id="125213026304" dmd:lastModified="2016-09-16T18:08:16">
			<FNAME>Nursalim</FNAME>
			<MNAME/>
			<LNAME>Hadi</LNAME>
			<PFNAME>Nursalim</PFNAME>
			<PMNAME/>
			<PLNAME/>
			<BANNER_FNAME>Nursalim</BANNER_FNAME>
			<BANNER_MNAME/>
			<BANNER_LNAME>Hadi</BANNER_LNAME>
		
			<EMAIL>nhadi@illinois.edu</EMAIL>
			<DTM_DOB>January</DTM_DOB>
			<DTD_DOB>1</DTD_DOB>
			<DTY_DOB>1965</DTY_DOB>
			<DOB_START>1965-01-01</DOB_START>
			<DOB_END>1965-01-01</DOB_END>
			<GENDER/>
			<ETHNICITY/>
			<CITIZEN/>
			<SSRN_ID/>
			<GOOGLE_SCHOLAR_ID/>
			<SCOPUS_ID/>

			<UPLOAD_CV/>
			<SHOW_CV>Yes</SHOW_CV>
			<UPLOAD_PHOTO/>
			<SHOW_PHOTO>Yes</SHOW_PHOTO>
			<SHOW_COLLEGE>Yes</SHOW_COLLEGE>
			<SHOW_DEPT>Yes</SHOW_DEPT>
			<SHOW_PROFILE>Yes</SHOW_PROFILE>
			<PROFILE_ID/>
			<STAFF_CLASS/>
			<RANK/>
			<DOC_STATUS/>
			<DOC_DEPT/>
			<DOC_TERM/>
			
			<BUS_FACULTY>No</BUS_FACULTY>
			<ACTIVE>Yes</ACTIVE>

			</PCI>
		</Record>
		*/

	DECLARE @prefix varchar(1000)

	SELECT @prefix = SP_ERROR
	FROM dbo.webservices_requests
	WHERE [ID]=@webservices_requests_id		

	SET @prefix = @prefix + '- shadow_PCI '
	UPDATE dbo.webservices_requests SET SP_Error=@prefix WHERE [ID]=@webservices_requests_id;	


	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')
	SELECT Record.value('@userId','bigint') userid,
		Record.value('@username','varchar(60)')username,		
		Record.value('@dmd:surveyId','bigint')surveyId,
		Record.value('@termId','bigint')termId,
		Item.value('@id','bigint') id,
		Item.value('@dmd:lastModified','date') lastModified,
		--ISNULL(Item.value('@access','varchar(50)'),'')access,
		ISNULL(Item.value('(FNAME/text())[1]','varchar(120)'),'')FNAME,
		ISNULL(Item.value('(PFNAME/text())[1]','varchar(120)'),'')PFNAME,
		ISNULL(Item.value('(BANNER_FNAME/text())[1]','varchar(120)'),'')BANNER_FNAME,
		ISNULL(Item.value('(MNAME/text())[1]','varchar(120)'),'')MNAME,
		ISNULL(Item.value('(PMNAME/text())[1]','varchar(120)'),'')PMNAME,
		ISNULL(Item.value('(BANNER_MNAME/text())[1]','varchar(120)'),'')BANNER_MNAME,
		ISNULL(Item.value('(LNAME/text())[1]','varchar(120)'),'')LNAME,
		ISNULL(Item.value('(PLNAME/text())[1]','varchar(120)'),'')PLNAME,
		ISNULL(Item.value('(BANNER_LNAME/text())[1]','varchar(120)'),'')BANNER_LNAME,
		
		ISNULL(Item.value('(EMAIL/text())[1]','varchar(200)'),'')EMAIL,
		ISNULL(Item.value('(DTM_DOB/text())[1]','varchar(20)'),'')DTM_DOB,
		ISNULL(Item.value('(DTD_DOB/text())[1]','varchar(4)'),'')DTD_DOB,
		ISNULL(Item.value('(DTY_DOB/text())[1]','varchar(4)'),'')DTY_DOB,
		ISNULL(Item.value('(DOB_START/text())[1]','varchar(12)'),'')DOB_START,
		ISNULL(Item.value('(DOB_END/text())[1]','varchar(12)'),'')DOB_END,
		
		ISNULL(Item.value('(GENDER/text())[1]','varchar(6)'),'')GENDER,
		ISNULL(Item.value('(ETHNICITY/text())[1]','varchar(50)'),'')ETHNICITY,
		ISNULL(Item.value('(CITIZEN/text())[1]','varchar(50)'),'')CITIZEN,
		
		ISNULL(Item.value('(SSRN_ID/text())[1]','varchar(10)'),'')SSRN_ID,				
		ISNULL(Item.value('(SCOPUS_ID/text())[1]','varchar(20)'),'')SCOPUS_ID,
		ISNULL(Item.value('(GOOGLE_SCHOLAR_ID/text())[1]','varchar(100)'),'')GOOGLE_SCHOLAR_ID,
		--ISNULL(Item.value('(ORCID/text())[1]','varchar(100)'),'')ORCID,

		ISNULL(Item.value('(UPLOAD_CV/text())[1]','VARCHAR(255)'),'')UPLOAD_CV,
		ISNULL(Item.value('(SHOW_CV/text())[1]','VARCHAR(3)'),'')SHOW_CV,
		ISNULL(Item.value('(UPLOAD_PHOTO/text())[1]','varchar(255)'),'')UPLOAD_PHOTO,
		ISNULL(Item.value('(SHOW_PHOTO/text())[1]','varchar(3)'),'')SHOW_PHOTO,

		ISNULL(Item.value('(SHOW_COLLEGE/text())[1]','varchar(3)'),'')SHOW_COLLEGE,
		ISNULL(Item.value('(SHOW_DEPT/text())[1]','varchar(3)'),'')SHOW_DEPT,
		ISNULL(Item.value('(SHOW_PROFILE/text())[1]','varchar(3)'),'')SHOW_PROFILE,
		ISNULL(Item.value('(PROFILE_ID/text())[1]','varchar(50)'),'')PROFILE_ID,

		ISNULL(Item.value('(STAFF_CLASS/text())[1]','varchar(60)'),'')STAFF_CLASS,
		ISNULL(Item.value('(RANK/text())[1]','varchar(100)'),'')[RANK],
		ISNULL(Item.value('(DOC_STATUS/text())[1]','varchar(60)'),'')DOC_STATUS,
		ISNULL(Item.value('(DOC_DEPT/text())[1]','varchar(60)'),'')DOC_DEPT,
		ISNULL(Item.value('(DOC_TERM/text())[1]','varchar(60)'),'')DOC_TERM,
		
		--ISNULL(Item.value('(BUS_PERSON/text())[1]','varchar(3)'),'')BUS_PERSON,
		ISNULL(Item.value('(BUS_FACULTY/text())[1]','varchar(3)'),'')BUS_FACULTY,

		ISNULL(Item.value('(ACTIVE/text())[1]','VARCHAR(3)'),'')ACTIVE
		
	INTO #_DM_PCI
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./PCI')Items(Item);
	
	ALTER TABLE #_DM_PCI ADD Download_Datetime  Datetime NULL
	UPDATE #_DM_PCI SET Download_Datetime=getdate();

	-- DEBUG
	--SELECT * FROm #_DM_PCI

	-- Populate both _DM_PCI tables under DM_Shadow_Staging and DM_Shadow_Production databases
	--INSERT INTO DM_Shadow_Staging.dbo._DM_PCI
	--	(userid
	--	  ,id
	--	  ,surveyID
	--	  ,termID
	--	  ,USERNAME
	--	  --,FACSTAFFID
	--	  --,EDWPERSID
	--	  ,FNAME
	--	  ,MNAME
	--	  ,LNAME
	--	  ,PFNAME
	--	  ,PMNAME
	--	  ,PLNAME
	--	  ,EMAIL
	--	  ,DTM_DOB
	--	  ,DTD_DOB
	--	  ,DTY_DOB
	--	  ,DOB_START
	--	  ,DOB_END
	--	  ,GENDER
	--	  ,ETHNICITY
	--	  ,CITIZEN
	--	  ,SSRN_ID
	--	  ,SCOPUS_ID
	--	  ,GOOGLE_SCHOLAR_ID
	
	--	  ,UPLOAD_CV
	--	  ,SHOW_CV
	--	  ,UPLOAD_PHOTO
	--	  ,SHOW_PHOTO
	--	  ,SHOW_COLLEGE
	--	  ,SHOW_DEPT
	--	  ,SHOW_PROFILE
	--	  ,PROFILE_ID
	--	  ,STAFF_CLASS
	--	  ,DOC_STATUS
	--	  ,DOC_DEPT
	--	  ,DOC_TERM
	--	  --,BUS_PERSON
	--	  ,BUS_FACULTY
	--	  ,ACTIVE

	--	  ,Create_datetime
	--	  ,lastModified)
	--	SELECT userid
	--	  ,id
	--	  ,surveyID
	--	  ,termID
	--	  ,USERNAME
	--	  --,FACSTAFFID
	--	  --,EDWPERSID
	--	  ,FNAME
	--	  ,MNAME
	--	  ,LNAME
	--	  ,PFNAME
	--	  ,PMNAME
	--	  ,PLNAME
	--	  ,EMAIL
	--	  ,DTM_DOB
	--	  ,DTD_DOB
	--	  ,DTY_DOB
	--	  ,DOB_START
	--	  ,DOB_END
	--	  ,GENDER
	--	  ,ETHNICITY
	--	  ,CITIZEN
	--	  ,SSRN_ID
	--	  ,SCOPUS_ID
	--	  ,GOOGLE_SCHOLAR_ID
	
	--	  ,UPLOAD_CV
	--	  ,SHOW_CV
	--	  ,UPLOAD_PHOTO
	--	  ,SHOW_PHOTO
	--	  ,SHOW_COLLEGE
	--	  ,SHOW_DEPT
	--	  ,SHOW_PROFILE
	--	  ,PROFILE_ID
	--	  ,STAFF_CLASS
	--	  ,DOC_STATUS
	--	  ,DOC_DEPT
	--	  ,DOC_TERM
	--	  --,BUS_PERSON
	--	  ,BUS_FACULTY
	--	  ,ACTIVE

	--	  ,getdate()
	--	  ,lastModified
	--FROM #_DM_PCI

	--INSERT INTO DM_Shadow_Production.dbo._DM_PCI
	--	(userid
	--	  ,id
	--	  ,surveyID
	--	  ,termID
	--	  ,USERNAME
	--	  --,FACSTAFFID
	--	  --,EDWPERSID
	--	  ,FNAME
	--	  ,MNAME
	--	  ,LNAME
	--	  ,PFNAME
	--	  ,PMNAME
	--	  ,PLNAME
	--	  ,EMAIL
	--	  --,DTM_DOB
	--	  --,DTD_DOB
	--	  --,DTY_DOB
	--	  ,DOB_START
	--	  ,DOB_END
	--	  ,GENDER
	--	  ,ETHNICITY
	--	  --,CITIZEN
	--	  ,SSRN_ID
	--	  ,SCOPUS_ID
	--	  ,GOOGLE_SCHOLAR_ID
	--	  ,BIO_SKETCH
	--	  ,PROF_INTERESTS
	--	  ,TEACHING_INTERESTS
	--	  ,RESEARCH_INTERESTS
	--	  ,UPLOAD_CV
	--	  ,SHOW_CV
	--	  ,UPLOAD_PHOTO
	--	  ,SHOW_PHOTO
	--	  ,SHOW_COLLEGE
	--	  ,SHOW_DEPT
	--	  ,SHOW_PROFILE
	--	  ,PROFILE_ID
	--	  ,STAFF_CLASS
	--	  ,DOC_STATUS
	--	  ,DOC_DEPT
	--	  ,DOC_TERM
	--	  --,BUS_PERSON
	--	  ,BUS_FACULTY
	--	  ,ACTIVE

	--	  ,Create_datetime
	--	  ,lastModified)
	--	SELECT userid
	--	  ,id
	--	  ,surveyID
	--	  ,termID
	--	  ,USERNAME
	--	  --,FACSTAFFID
	--	  --,EDWPERSID
	--	  ,FNAME
	--	  ,MNAME
	--	  ,LNAME
	--	  ,PFNAME
	--	  ,PMNAME
	--	  ,PLNAME
	--	  ,EMAIL
	--	  --,DTM_DOB
	--	  --,DTD_DOB
	--	  --,DTY_DOB
	--	  ,DOB_START
	--	  ,DOB_END
	--	  ,GENDER
	--	  ,ETHNICITY
	--	  --,CITIZEN
	--	  ,SSRN_ID
	--	  ,SCOPUS_ID
	--	  ,GOOGLE_SCHOLAR_ID
	--	  ,BIO_SKETCH
	--	  ,PROF_INTERESTS
	--	  ,TEACHING_INTERESTS
	--	  ,RESEARCH_INTERESTS
	--	  ,UPLOAD_CV
	--	  ,SHOW_CV
	--	  ,UPLOAD_PHOTO
	--	  ,SHOW_PHOTO
	--	  ,SHOW_COLLEGE
	--	  ,SHOW_DEPT
	--	  ,SHOW_PROFILE
	--	  ,PROFILE_ID
	--	  ,STAFF_CLASS
	--	  ,DOC_STATUS
	--	  ,DOC_DEPT
	--	  ,DOC_TERM
	--	  --,BUS_PERSON
	--	  ,BUS_FACULTY
	--	  ,ACTIVE

	--	  ,getdate()
	--	  ,lastModified
	--  FROM #_DM_PCI

	
	-- >>>>>>>>>>>>>>>>>>>>>
	--   This is how to parse/process sub-screens; Sample XML

	--    <Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-06-21">
	--    <Record userId="1791141" username="scasteel" termId="6117" dmd:surveyId="17698890">
	--    <PCI id="125211813888" dmd:lastModified="2016-05-10T13:58:33">
	--    ...
	--    ...
	--    <RESEARCH_KEYWORD id="64225812483">
	--      <KEYWORD access="READ_ONLY">Personal & Social Issues: Conceptual Change</KEYWORD>
	--    </RESEARCH_KEYWORD>
	--    <RESEARCH_KEYWORD id="64225812484">
	--      <KEYWORD access="READ_ONLY">Curriculum Issues: Curriculum</KEYWORD>
	--    </RESEARCH_KEYWORD>
	--    <RESEARCH_KEYWORD id="64225812485">
	--      <KEYWORD access="READ_ONLY">Curriculum Areas: Science Ed</KEYWORD>
	--    </RESEARCH_KEYWORD>
	--    ...
	--    ...
	--    </PCI>
	--    </Record>
	--    </Data>

	-- >>>>>>>>>>>>>>>>>>>>>
	--
	---- RESEARCH_KEYWORD
	--WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')
	--SELECT PCI.value('@id','bigint')id,
	--	Item.value('@id','bigint')itemid,
	--	ISNULL(Item.value('KEYWORD[1]','varchar(100)'),'')KEYWORD
	--INTO #RESEARCH_KEYWORD
	--FROM @xml.nodes('/Data/Record/PCI')PCIs(PCI)
	--	CROSS APPLY PCIs.PCI.nodes('./RESEARCH_KEYWORD')Items(Item);
	
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

	DECLARE @fields varchar(2000)

	-- Verify Incoming Data Integrity
	IF @userid IS NULL AND (SELECT COUNT(*) FROM #_DM_PCI) < 3 
		BEGIN
			UPDATE dbo.webservices_requests SET SP_Error='PCI has no data' WHERE [ID]=@webservices_requests_id			
			RAISERROR('PCI has no Data',18,1)
		END
	-- Delete & Insert the staging data
	ELSE BEGIN
		DECLARE @locked INTEGER;
		EXEC @locked = sp_getapplock 'shadowmaker-PCI','Exclusive','Session',20000; -- 20 second wait
		IF @locked < 0  
			BEGIN
					PRINT 'shadowmaker-PCI Import Locked'
					UPDATE dbo.webservices_requests SET SP_Error='shadowmaker-PCI Import Locked' WHERE [ID]=@webservices_requests_id			
			END
		ELSE 
			BEGIN
			-- UserID or id will be added later depending on idtype (LINKED -> id, otherwise-> username, userID ) 
			SET @fields = 'userName,surveyID,termID,lastModified,Download_Datetime' +
					',FNAME,MNAME,LNAME,BANNER_FNAME,BANNER_MNAME,BANNER_LNAME,PFNAME,PMNAME,PLNAME' +
					',DTM_DOB,DTD_DOB,DTY_DOB,DOB_START,DOB_END,GENDER,ETHNICITY,CITIZEN,SSRN_ID,SCOPUS_ID,GOOGLE_SCHOLAR_ID' +					
					',UPLOAD_CV,SHOW_CV,UPLOAD_PHOTO,SHOW_PHOTO,SHOW_COLLEGE,SHOW_DEPT,SHOW_PROFILE,PROFILE_ID' +
					',STAFF_CLASS,RANK,DOC_STATUS,DOC_DEPT,DOC_TERM' +
					',BUS_FACULTY,ACTIVE'
			--EXEC dbo.shadow_screen_data_Import @table='_DM_PCI'
			--	,@idtype=NULL,@cols=@fields,@username=@username
			--	,@userid=@userid,@resync=@resync,@debug=1

			EXEC dbo.shadow_screen_data1 @webservices_requests_id=@webservices_requests_id, @table='_DM_PCI'
				,@idtype=NULL,@cols=@fields
				,@userid=@userid,@resync=@resync,@debug=0

			--EXEC dbo.shadow_screen_data 'RESEARCH_KEYWORD','PCI','KEYWORD',@userid,@resync;
			--EXEC dbo.shadow_screen_data 'LINKS','PCI','NAME,URL,sequence',@userid,@resync;
			
			EXEC sp_releaseapplock 'shadowmaker-PCI','Session'; 
		END

	--DEBUG to initialize both PCI tables
	--INSERT INTO dbo.PCI (id,surveyId,lastModified,access,PREFIX,FNAME,PFNAME,MNAME,LNAME,SUFFIX,ALT_NAME,EMAIL,WEBSITE,DT_DOB,GENDER,ETHNICITY,CITIZEN,RESEARCH_INTERESTS,BIO,EMERGENCY_CONTACT,SHOW_PHOTO,TWITTER,LINKEDIN,DISPLAY_ONLINE,TEACHING_INTERESTS,QUOTE,UPLOAD_CV)
	--SELECT id,surveyId,lastModified,access,PREFIX,FNAME,PFNAME,MNAME,LNAME,SUFFIX,ALT_NAME,EMAIL,WEBSITE,DT_DOB,GENDER,ETHNICITY,CITIZEN,RESEARCH_INTERESTS,BIO,EMERGENCY_CONTACT,SHOW_PHOTO,TWITTER,LINKEDIN,DISPLAY_ONLINE,TEACHING_INTERESTS,QUOTE,UPLOAD_CV
	--FROm #_DM_PCI

	--INSERT INTO DM_Shadow_Production.dbo.PCI (id,surveyId,lastModified,access,PREFIX,FNAME,PFNAME,MNAME,LNAME,SUFFIX,ALT_NAME,EMAIL,WEBSITE,DT_DOB,GENDER,ETHNICITY,CITIZEN,RESEARCH_INTERESTS,BIO,EMERGENCY_CONTACT,SHOW_PHOTO,TWITTER,LINKEDIN,DISPLAY_ONLINE,TEACHING_INTERESTS,QUOTE,UPLOAD_CV)
	--SELECT id,surveyId,lastModified,access,PREFIX,FNAME,PFNAME,MNAME,LNAME,SUFFIX,ALT_NAME,EMAIL,WEBSITE,DT_DOB,GENDER,ETHNICITY,CITIZEN,RESEARCH_INTERESTS,BIO,EMERGENCY_CONTACT,SHOW_PHOTO,TWITTER,LINKEDIN,DISPLAY_ONLINE,TEACHING_INTERESTS,QUOTE,UPLOAD_CV
	--FROm #_DM_PCI

	END
	/*
	DEBUG
		EXEC dbo.shadow_PCI @xml ='<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2016-06-21"><Record userId="1791141" username="scasteel" termId="6117" dmd:surveyId="17698890"><PCI id="125211813888" dmd:lastModified="2016-05-10T13:58:33"><PREFIX/><FNAME>Scott</FNAME><PFNAME/><MNAME/><LNAME>Casteel</LNAME><SUFFIX/><ALT_NAME/><ENDPOS/><EMAIL>scasteel@illinois.edu</EMAIL><EMERGENCY_CONTACT/><WEBSITE/><TWITTER/><LINKEDIN/><DTM_DOB/><DTD_DOB/><DTY_DOB/><DOB_START/><DOB_END/><GENDER/><ETHNICITY/><CITIZEN/><BIO/><TEACHING_INTERESTS/><RESEARCH_INTERESTS/><QUOTE/><UPLOAD_CV>scasteel/pci/Vader Resume-1.docx</UPLOAD_CV><DISPLAY_ONLINE/><SHOW_PHOTO/><RESEARCH_KEYWORD id="125211813889"><KEYWORD/></RESEARCH_KEYWORD><LINK id="125211813890"><NAME/><URL/></LINK></PCI></Record><Record userId="1910556" username="busfac1" termId="6117" dmd:surveyId="17699128"><PCI id="125286320128" dmd:lastModified="2016-02-16T14:46:46"><FNAME>Test</FNAME><MNAME/><LNAME>Faculty1</LNAME><EMAIL>scasteel23@yahoo.com</EMAIL></PCI></Record><Record userId="1927020" username="busfac2" termId="6117" dmd:surveyId="17812262"><PCI id="127944998912" dmd:lastModified="2016-04-25T13:38:09"><FNAME>Test</FNAME><MNAME/><LNAME>Faculty2</LNAME><EMAIL>scasteel23@yahoo.com</EMAIL></PCI></Record><Record userId="1927022" username="busfac3" termId="6117" dmd:surveyId="17812264"><PCI id="127945322496" dmd:lastModified="2016-04-25T13:47:45"><FNAME>Test</FNAME><MNAME/><LNAME>Faculty3</LNAME><EMAIL>scasteel23@yahoo.com</EMAIL></PCI></Record><Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891"><PCI id="125213026304" dmd:lastModified="2016-02-15T14:26:20"><FNAME>Nursalim</FNAME><MNAME/><LNAME>Hadi</LNAME><EMAIL>nhadi@illinois.edu</EMAIL></PCI></Record></Data>'
			,@userid = NULL
			,@resync=1
		
		SELECT * FROM #_DM_PCI
	*/
	
	DROP TABLE #_DM_PCI;
	--DROP TABLE #RESEARCH_KEYWORD;
	--DROP TABLE #LINKS;
END



GO
