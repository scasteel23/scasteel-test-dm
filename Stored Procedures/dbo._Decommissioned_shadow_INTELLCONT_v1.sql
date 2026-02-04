SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- V1
-- NS 3/16/2017: Added to parse <JOURNAL> ... not successful/done yet
-- NS 2/28/2017:  Revised based on the latest DM config as of 2/22/2017
-- NS 9/11/22016: Readying for DM screen availability as publications a.k.a. INTELLCONT screen is being developed by Scott Casteel
--				  Get XML data from the downloader (SSIS package) insert into _DM_INTELLCONT table
--				 

CREATE PROCEDURE [dbo].[_Decommissioned_shadow_INTELLCONT_v1] (@xml XML,@userid BIGINT=NULL,@resync BIT=NULL) 
AS 

BEGIN

	-- GET all INTELLCONT data from
	-- https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/INTELLCONT
	-- XML Sample:
/*
		
<Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2017-02-28">
<Record userId="1791141" username="scasteel" termId="6117" dmd:surveyId="17698890">
<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services"/>

<INTELLCONT id="138778697728" dmd:lastModified="2017-02-23T12:01:18" dmd:startDate="2016-01-01" dmd:endDate="2016-12-31">
<CONTYPE>Article in a Journal</CONTYPE>
<ARTICLE_TYPE>Academic Journal</ARTICLE_TYPE>
<TITLE>test 5</TITLE>
<STATUS>Submitted</STATUS>
<JOURNAL_REF>142384445440</JOURNAL_REF>
<PUBLISHER/>
<PUBCTYST/>
<VOLUME/>
<ISSUE/>
<PAGENUM/>
<REVISED/>
<INVITED>true</INVITED>
<UNDER_REVIEW/>
<INTELLCONT_AUTH id="138778697729">
<FACULTY_NAME>1791141</FACULTY_NAME>
<FNAME>Scott</FNAME>
<MNAME/>
<LNAME>Casteel</LNAME>
<INSTITUTION/>
<WEB_PROFILE>Yes</WEB_PROFILE>
</INTELLCONT_AUTH>
<INTELLCONT_AUTH id="138778697731">
<FACULTY_NAME/>
<FNAME/>
<MNAME/>
<LNAME>test</LNAME>
<INSTITUTION/>
<WEB_PROFILE>Yes</WEB_PROFILE>
</INTELLCONT_AUTH>
<EDITORS/>
<DTM_PREP/>
<DTY_PREP/>
<PREP_START/>
<PREP_END/>
<DTM_EXPSUB/>
<DTD_EXPSUB/>
<DTY_EXPSUB/>
<EXPSUB_START/>
<EXPSUB_END/>
<DTM_SUB/>
<DTD_SUB/>
<DTY_SUB>2016</DTY_SUB>
<SUB_START>2016-01-01</SUB_START>
<SUB_END>2016-12-31</SUB_END>
<DTM_ACC/>
<DTY_ACC/>
<ACC_START/>
<ACC_END/>
<DTM_PUB/>
<DTD_PUB/>
<DTY_PUB/>
<PUB_START/>
<PUB_END/>
<DESC/>
<SCOPE_LOCALE/>
<PUBLICAVAIL/>
<ABSTRACT/>
<WEB_ADDRESS/>
<SSRN/>
<DOI/>
<ISBNISSN/>
<USER_REFERENCE_CREATOR>Yes</USER_REFERENCE_CREATOR>
<JOURNAL id="142384445440" lastModified="2017-02-21T18:10:04" dmd:primaryKey="Academy of Management Journal">
<JOURNAL_NAME>Academy of Management Journal</JOURNAL_NAME>
<ABBREVIATION>amj</ABBREVIATION>
<REFEREED>Yes</REFEREED>
<REVIEW_TYPE>Blind</REVIEW_TYPE>
<UTDALLAS>true</UTDALLAS>
</JOURNAL>
</INTELLCONT>


<INTELLCONT id="138778734592" dmd:lastModified="2017-02-23T11:50:04" dmd:startDate="2016-04-01" dmd:endDate="2016-04-30">
<CONTYPE>Article in a Journal</CONTYPE>
<ARTICLE_TYPE>Research Monograph</ARTICLE_TYPE>
<TITLE>test 4</TITLE>
<STATUS>Published</STATUS>
<JOURNAL_REF>-1</JOURNAL_REF>
<JOURNAL id="138778734596">
<JOURNAL_NAME>Journal of Ficticious Publications</JOURNAL_NAME>
<REFEREED>Yes</REFEREED>
</JOURNAL>
<PUBLISHER/>
<PUBCTYST>Atlantis</PUBCTYST>
<VOLUME>23</VOLUME>
<ISSUE>Spring</ISSUE>
<PAGENUM>334-367</PAGENUM>
<REVISED/>
<INVITED/>
<UNDER_REVIEW/>
<INTELLCONT_AUTH id="138778734593">
<FACULTY_NAME>1791141</FACULTY_NAME>
<FNAME>Scott</FNAME>
<MNAME/>
<LNAME>Casteel</LNAME>
<INSTITUTION/>
<WEB_PROFILE>Yes</WEB_PROFILE>
</INTELLCONT_AUTH>
<INTELLCONT_AUTH id="138778734595">
<FACULTY_NAME>1791140</FACULTY_NAME>
<FNAME>Nursalim</FNAME>
<MNAME/>
<LNAME>Hadi</LNAME>
<INSTITUTION/>
<WEB_PROFILE>Yes</WEB_PROFILE>
</INTELLCONT_AUTH>
<EDITORS/>
<DTM_PREP/>
<DTY_PREP/>
<PREP_START/>
<PREP_END/>
<DTM_EXPSUB/>
<DTD_EXPSUB/>
<DTY_EXPSUB/>
<EXPSUB_START/>
<EXPSUB_END/>
<DTM_SUB/>
<DTD_SUB/>
<DTY_SUB/>
<SUB_START/>
<SUB_END/>
<DTM_ACC/>
<DTY_ACC/>
<ACC_START/>
<ACC_END/>
<DTM_PUB>April (2nd Quarter/Spring)</DTM_PUB>
<DTD_PUB/>
<DTY_PUB>2016</DTY_PUB>
<PUB_START>2016-04-01</PUB_START>
<PUB_END>2016-04-30</PUB_END>
<DESC/>
<SCOPE_LOCALE/>
<PUBLICAVAIL/>
<ABSTRACT/>
<WEB_ADDRESS/>
<SSRN/>
<DOI/>
<ISBNISSN/>
<USER_REFERENCE_CREATOR>Yes</USER_REFERENCE_CREATOR>
</INTELLCONT>


<INTELLCONT id="138778525696" dmd:lastModified="2017-02-23T11:49:57" dmd:startDate="2016-02-01" dmd:endDate="2016-02-28">
<CONTYPE>Working Paper</CONTYPE>
<ARTICLE_TYPE>N/A</ARTICLE_TYPE>
<TITLE>test</TITLE>
<STATUS>Working Paper</STATUS>
<JOURNAL_REF>-1</JOURNAL_REF>
<JOURNAL id="138778525698">
<JOURNAL_NAME/>
<REFEREED>No</REFEREED>
</JOURNAL>
<PUBLISHER/>
<PUBCTYST/>
<VOLUME/>
<ISSUE/>
<PAGENUM/>
<REVISED/>
<INVITED/>
<UNDER_REVIEW/>
<INTELLCONT_AUTH id="138778525697">
<FACULTY_NAME>1791141</FACULTY_NAME>
<FNAME>Scott</FNAME>
<MNAME/>
<LNAME>Casteel</LNAME>
<INSTITUTION/>
<WEB_PROFILE>Yes</WEB_PROFILE>
</INTELLCONT_AUTH>
<EDITORS/>
<DTM_PREP/>
<DTY_PREP/>
<PREP_START/>
<PREP_END/>
<DTM_EXPSUB/>
<DTD_EXPSUB/>
<DTY_EXPSUB/>
<EXPSUB_START/>
<EXPSUB_END/>
<DTM_SUB/>
<DTD_SUB/>
<DTY_SUB/>
<SUB_START/>
<SUB_END/>
<DTM_ACC/>
<DTY_ACC/>
<ACC_START/>
<ACC_END/>
<DTM_PUB>February</DTM_PUB>
<DTD_PUB/>
<DTY_PUB>2016</DTY_PUB>
<PUB_START>2016-02-01</PUB_START>
<PUB_END>2016-02-28</PUB_END>
<DESC/>
<SCOPE_LOCALE/>
<PUBLICAVAIL/>
<ABSTRACT/>
<WEB_ADDRESS/>
<SSRN/>
<DOI/>
<ISBNISSN/>
<USER_REFERENCE_CREATOR>Yes</USER_REFERENCE_CREATOR>
</INTELLCONT>


<INTELLCONT id="138778580992" dmd:lastModified="2017-02-21T18:10:04" dmd:startDate="2016-02-01" dmd:endDate="2016-02-28">
<TITLE>test 2</TITLE>
<STATUS>Accepted</STATUS>
<PUBLISHER/>
<PUBCTYST/>
<VOLUME/>
<ISSUE/>
<PAGENUM/>
<INVITED/>
<INTELLCONT_AUTH id="138778580993">
<FACULTY_NAME>1791141</FACULTY_NAME>
<FNAME>Scott</FNAME>
<MNAME/>
<LNAME>Casteel</LNAME>
</INTELLCONT_AUTH>
<EDITORS/>
<DTM_PREP/>
<DTY_PREP/>
<PREP_START/>
<PREP_END/>
<DTM_EXPSUB/>
<DTD_EXPSUB/>
<DTY_EXPSUB/>
<EXPSUB_START/>
<EXPSUB_END/>
<DTM_SUB/>
<DTD_SUB/>
<DTY_SUB/>
<SUB_START/>
<SUB_END/>
<DTM_ACC>February</DTM_ACC>
<DTY_ACC>2016</DTY_ACC>
<ACC_START>2016-02-01</ACC_START>
<ACC_END>2016-02-28</ACC_END>
<DTM_PUB/>
<DTD_PUB/>
<DTY_PUB/>
<PUB_START/>
<PUB_END/>
<SCOPE_LOCALE/>
<PUBLICAVAIL/>
<ABSTRACT/>
<WEB_ADDRESS/>
<ISBNISSN/>
<USER_REFERENCE_CREATOR>Yes</USER_REFERENCE_CREATOR>
</INTELLCONT>
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

		ISNULL(Item.value('(CLASSIFICATION/text())[1]','varchar(100)'),'')CLASSIFICATION,
		ISNULL(Item.value('(CONTYPE/text())[1]','varchar(100)'),'')CONTYPE,
		ISNULL(Item.value('(ARTICLE_TYPE/text())[1]','varchar(100)'),'')ARTICLE_TYPE,
		ISNULL(Item.value('(TITLE/text())[1]','varchar(400)'),'')TITLE,
		ISNULL(Item.value('(TITLE_SECONDARY/text())[1]','varchar(400)'),'')TITLE_SECONDARY,
		ISNULL(Item.value('(STATUS/text())[1]','varchar(30)'),'')[STATUS],

		ISNULL(Item.value('(JOURNAL_REF/text())[1]','varchar(30)'),'')JOURNAL_REF,
		/* NS 3/3/2017 need to find out how to parse a sub-group
			<JOURNAL @id=567>
				<JOURNAL_NAME>Abracadabra Journal</JOURNAL_NAME>
				<REFEREED>Yes</REFEREED>
				<REVIEW_TYPE>Blind</REVIEW_TYPE>
				<UTDALLAS>true</UTDALLAS>
			</JOURNAL>

		*/
		Item.value('(JOURNAL[1]/@id[1])','bigint') JOURNAL_ID,
		ISNULL(Item.value('JOURNAL[1]/JOURNAL_NAME[1]','varchar(200)'),'')JOURNAL_NAME,
		ISNULL(Item.value('JOURNAL[1]/REFEREED[1]','varchar(30)'),'')JOURNAL_REFEREED,
		ISNULL(Item.value('JOURNAL[1]/REVIEW_TYPE[1]','varchar(30)'),'')JOURNAL_REVIEW_TYPE,
	
		
		ISNULL(Item.value('(PUBLISHER/text())[1]','varchar(200)'),'')PUBLISHER,
		ISNULL(Item.value('(PUBCTYST/text())[1]','varchar(200)'),'')PUBCTYST,
		ISNULL(Item.value('(VOLUME/text())[1]','varchar(200)'),'')VOLUME,
		ISNULL(Item.value('(ISSUE/text())[1]','varchar(50)'),'')ISSUE,
		ISNULL(Item.value('(PAGENUM/text())[1]','varchar(200)'),'')PAGENUM,
		ISNULL(Item.value('(REVISED/text())[1]','varchar(3)'),'')REVISED,
		ISNULL(Item.value('(INVITED/text())[1]','varchar(3)'),'')INVITED,
		ISNULL(Item.value('(UNDER_REVIEW/text())[1]','varchar(3)'),'')UNDER_REVIEW,
		ISNULL(Item.value('(EDITORS/text())[1]','varchar(400)'),'')EDITORS,

		ISNULL(Item.value('(DESC/text())[1]','varchar(50)'),'')[DESC],
		ISNULL(Item.value('(SCOPE_LOCALE/text())[1]','varchar(50)'),'')SCOPE_LOCALE,
		ISNULL(Item.value('(REVPUBLICAVAILISED/text())[1]','varchar(3)'),'')PUBLICAVAIL,
		ISNULL(Item.value('(PROCEEDING_TYPE/text())[1]','varchar(30)'),'')PROCEEDING_TYPE,
		ISNULL(Item.value('(ABSTRACT/text())[1]','varchar(5000)'),'')ABSTRACT,

		ISNULL(Item.value('(WEB_ADDRESS/text())[1]','varchar(1000)'),'')WEB_ADDRESS,
		ISNULL(Item.value('(SSRN_ID/text())[1]','varchar(200)'),'')SSRN_ID,
		ISNULL(Item.value('(DOI/text())[1]','varchar(200)'),'')DOI,
		ISNULL(Item.value('(ISBNISSN/text())[1]','varchar(200)'),'')ISBNISSN,

		ISNULL(Item.value('(DTM_PREP/text())[1]','varchar(60)'),'')DTM_PREP,
		ISNULL(Item.value('(DTY_PREP/text())[1]','varchar(20)'),'')DTY_PREP,

		ISNULL(Item.value('(DTM_EXPSUB/text())[1]','varchar(60)'),'')DTM_EXPSUB,
		ISNULL(Item.value('(DTD_EXPSUB/text())[1]','varchar(20)'),'')DTD_EXPSUB,
		ISNULL(Item.value('(DTY_EXPSUB/text())[1]','varchar(20)'),'')DTY_EXPSUB,

		ISNULL(Item.value('(DTM_SUB/text())[1]','varchar(60)'),'')DTM_SUB,
		ISNULL(Item.value('(DTD_SUB/text())[1]','varchar(20)'),'')DTD_SUB,
		ISNULL(Item.value('(DTY_SUB/text())[1]','varchar(20)'),'')DTY_SUB,

		ISNULL(Item.value('(DTM_ACC/text())[1]','varchar(60)'),'')DTM_ACC,
		ISNULL(Item.value('(DTY_ACC/text())[1]','varchar(20)'),'')DTY_ACC,

		ISNULL(Item.value('(DTM_PUB/text())[1]','varchar(60)'),'')DTM_PUB,
		ISNULL(Item.value('(DTD_PUB/text())[1]','varchar(20)'),'')DTD_PUB,
		ISNULL(Item.value('(DTY_PUB/text())[1]','varchar(20)'),'')DTY_PUB,
	
		ISNULL(Item.value('(USER_REFERENCE_CREATOR/text())[1]','varchar(3)'),'')USER_REFERENCE_CREATOR		
		--ISNULL(Item.value('(PERENNIAL/text())[1]','varchar(3)'),'')PERENNIAL
		
	INTO #_DM_INTELLCONT
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./INTELLCONT')Items(Item);
	
	-- DEBUG
	--SELECT * FROm #_DM_INTELLCONT

	
	
	/*
		>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
		Parse XML nested <INTELLCONT_AUTH> under <INTELLCONT>


		...
	    <INTELLCONT id="138778734592" dmd:lastModified="2017-02-23T11:50:04" dmd:startDate="2016-04-01" dmd:endDate="2016-04-30">
	    ...
	    ...
		<INTELLCONT_AUTH id="138778697729">
		<FACULTY_NAME>1791141</FACULTY_NAME>
		<FNAME>Scott</FNAME>
		<MNAME/>
		<LNAME>Casteel</LNAME>
		<INSTITUTION/>
		<WEB_PROFILE>Yes</WEB_PROFILE>
		</INTELLCONT_AUTH>

		<INTELLCONT_AUTH id="138778697731">
		<FACULTY_NAME/>
		<FNAME/>
		<MNAME/>
		<LNAME>test</LNAME>
		<INSTITUTION/>
		<WEB_PROFILE>Yes</WEB_PROFILE>
		</INTELLCONT_AUTH>  
	    ...
	    </INTELLCONT>
	    ...

	*/

	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')
	SELECT INTELLCONT.value('@id','bigint')id,
		INTELLCONT.value('@userid','bigint')userid,
		INTELLCONT.value('@dmd:lastModified','date')lastModified,
		INTELLCONT.value('@username','varchar(60)')USERNAME,
		Item.value('@id','bigint')itemid,
		ISNULL(Item.value('LNAME[1]','varchar(120)'),'')LNAME,
		ISNULL(Item.value('FNAME[1]','varchar(120)'),'')FNAME,
		ISNULL(Item.value('MNAME[1]','varchar(120)'),'')MNAME,
		ISNULL(Item.value('FACULTY_NAME[1]','varchar(60)'),'')FACULTY_NAME,
		ISNULL(Item.value('INSTITUTION[1]','varchar(200)'),'')INSTITUTION,
		ISNULL(Item.value('WEB_PROFILE[1]','varchar(3)'),'')WEB_PROFILE		
	INTO #_DM_INTELLCONT_AUTH
	FROM @xml.nodes('/Data/Record/INTELLCONT')INTELLCONTs(INTELLCONT)
		CROSS APPLY INTELLCONTs.INTELLCONT.nodes('./INTELLCONT_AUTH')Items(Item);



	-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	-- Save into Tables
	DECLARE @fields varchar(2000), @fields2 varchar(2000)

	-- Verify Incoming Data Integrity
	IF @userid IS NULL AND (SELECT COUNT(*) FROM #_DM_INTELLCONT) < 2 RAISERROR('No Data',18,1) -- just to make sure we have some records, change the threshold to 10 or more on production
	-- Delete & Insert the staging data
	ELSE BEGIN
		DECLARE @locked INTEGER;
		EXEC @locked = sp_getapplock 'shadowmaker-INTELLCONT','Exclusive','Session',20000; -- 20 second wait
		IF @locked < 0 PRINT 'Import Locked';
		ELSE BEGIN
			-- UserID or id will be added later depending on idtype (LINKED -> id, otherwise-> username, userID ) 
			SET @fields = 'userName,lastModified' +
					 ',CLASSIFICATION,CONTYPE,ARTICLE_TYPE,TITLE,TITLE_SECONDARY' +
					 ',STATUS,JOURNAL_REF,JOURNAL_ID,JOURNAL_NAME,JOURNAL_REVIEW_TYPE,JOURNAL_REFEREED'+
					 ',PUBLISHER,PUBCTYST,VOLUME,ISSUE,PAGENUM'+
					 ',REVISED,INVITED,UNDER_REVIEW,EDITORS'+
					 ',DTM_PREP,DTY_PREP,DTM_EXPSUB,DTD_EXPSUB,DTY_EXPSUB'+
					 ',DTM_SUB,DTD_SUB,DTY_SUB,DTM_ACC,DTY_ACC'+
					 ',DTM_PUB,DTD_PUB,DTY_PUB'+
					 ',DESC,SCOPE_LOCALE,PUBLICAVAIL,PROCEEDING_TYPE,ABSTRACT'+
					 ',WEB_ADDRESS,SSRN_ID,DOI,ISBNISSN,USER_REFERENCE_CREATOR'

			EXEC dbo.shadow_screen_data @table='_DM_INTELLCONT'
				,@idtype=NULL,@cols=@fields
				,@userid=@userid,@resync=@resync,@debug=0


			SET @fields2 = 'userName,lastModified' +
							',FACULTY_NAME,FNAME,MNAME' +
							',LNAME,INSTITUTION,WEB_PROFILE'
			EXEC dbo.shadow_screen_data '_DM_INTELLCONT_AUTH','_DM_INTELLCONT',@fields2,@userid,@resync;
			--EXEC dbo.shadow_screen_data 'LINKS','PCI','NAME,URL,sequence',@userid,@resync;
			
			
			EXEC sp_releaseapplock 'shadowmaker-INTELLCONT','Session'; 
		END



	END
	
	

	DROP TABLE #_DM_INTELLCONT;
	--DROP TABLE #RESEARCH_KEYWORD;
	--DROP TABLE #LINKS;
END



GO
