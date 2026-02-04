SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- V2
-- NS 4/24/2017, created, woked

CREATE PROCEDURE [dbo].[_Decommissioned_shadow_DEG_COMMITTEE_v2] (@webservices_requests_id INT,@xml XML,@userid BIGINT=NULL,@resync BIT=NULL) 
AS 

BEGIN

	/*
	 TRUNCATE TABle _DM_DEG_COMMITTEE
	 TRUNCATE TABLE _DM_DEG_COMMITTEE_MEMBER
	 EXEC dbo._Test_Shadow_DEG_COMMITTEE
	 */

	-- GET all GRANT data from
	-- https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/DEG_COMMITTEE
	-- XML Sample:
/*
	DEG_COMMITTEE
	   FNAME
      ,LNAME
      ,UIN
      ,INSTITUTION
      ,[TYPE]
      ,DTM_EXAM
      ,DTD_EXAM
      ,DTY_EXAM
      ,DTM_DECISION
      ,DTD_DECISION
      ,DTY_DECISION
      ,EXAM_START
      ,EXAM_END
      ,TITLE
      ,WEB_PROFILE

	 DEG_COMMITTEE_MEMBER
	   FACULTY_NAME
      ,LNAME
      ,FNAME
      ,MNAME
      ,ROLE
      ,sequence

	  <Data xmlns="http://www.digitalmeasures.com/schema/data" xmlns:dmd="http://www.digitalmeasures.com/schema/data-metadata" dmd:date="2017-04-24">
			<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
			<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Business IT Services" text="Business IT Services"/>

				<DEG_COMMITTEE id="133567455232" dmd:lastModified="2016-09-16T18:40:54" dmd:startDate="2015-02-01" dmd:endDate="2015-02-01">
				<ID/>
				<FNAME>Kenny</FNAME>
				<LNAME>Sullivan</LNAME>
				<UIN>888888</UIN>
				<INSTITUTION>Business</INSTITUTION>
				<TYPE>Final</TYPE>
				<DTM_EXAM>February</DTM_EXAM>
				<DTD_EXAM>1</DTD_EXAM>
				<DTY_EXAM>2015</DTY_EXAM>
				<EXAM_START>2015-02-01</EXAM_START>
				<EXAM_END>2015-02-01</EXAM_END>
				<TITLE>What A Different a Day Makes</TITLE>
				<DTM_DECISION>March</DTM_DECISION>
				<DTD_DECISION>1</DTD_DECISION>
				<DTY_DECISION>2015</DTY_DECISION>
				<DECISION_START>2015-03-01</DECISION_START>
				<DECISION_END>2015-03-01</DECISION_END>
				<STATUS>Pass Excellent</STATUS>
					<DEG_COMMITTEE_MEMBER id="133567455233">
					<FACULTY_NAME>1791140</FACULTY_NAME>
					<FNAME>John</FNAME>
					<MNAME/>
					<LNAME>Chandler</LNAME>
					<ROLE>Chairperson</ROLE>
					</DEG_COMMITTEE_MEMBER>

					<DEG_COMMITTEE_MEMBER id="133567455235">
					<FACULTY_NAME>1791140</FACULTY_NAME>
					<FNAME>Nursalim</FNAME>
					<MNAME/>
					<LNAME>Hadi</LNAME>
					<ROLE/>
					</DEG_COMMITTEE_MEMBER>
				<USER_REFERENCE_CREATOR>Yes</USER_REFERENCE_CREATOR>
				</DEG_COMMITTEE>

				<DEG_COMMITTEE id="133567440896" dmd:lastModified="2016-09-16T18:39:38" dmd:startDate="2015-01-01" dmd:endDate="2015-01-01">
				<ID/>
				<FNAME>John</FNAME>
				<LNAME>Padila</LNAME>
				<UIN>777777</UIN>
				<INSTITUTION>Business</INSTITUTION>
				<TYPE>Final</TYPE>
				<DTM_EXAM>January</DTM_EXAM>
				<DTD_EXAM>1</DTD_EXAM>
				<DTY_EXAM>2015</DTY_EXAM>
				<EXAM_START>2015-01-01</EXAM_START>
				<EXAM_END>2015-01-01</EXAM_END>
				<TITLE>Hello Kitty</TITLE>
				<DTM_DECISION>February</DTM_DECISION>
				<DTD_DECISION>1</DTD_DECISION>
				<DTY_DECISION>2015</DTY_DECISION>
				<DECISION_START>2015-02-01</DECISION_START>
				<DECISION_END>2015-02-01</DECISION_END>
				<STATUS>Pass Excellent</STATUS>
					<DEG_COMMITTEE_MEMBER id="133567440897">
					<FACULTY_NAME>1791140</FACULTY_NAME>
					<FNAME>Nursalim</FNAME>
					<MNAME/>
					<LNAME>Hadi</LNAME>
					<ROLE/>
					</DEG_COMMITTEE_MEMBER>
				<USER_REFERENCE_CREATOR>Yes</USER_REFERENCE_CREATOR>
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
		ISNULL(Item.value('(TYPE/text())[1]','varchar(50)'),'')[TYPE],

		ISNULL(Item.value('(DTM_EXAM/text())[1]','varchar(30)'),'')DTM_EXAM,
		ISNULL(Item.value('(DTD_EXAM/text())[1]','varchar(4)'),'')DTD_EXAM,
		ISNULL(Item.value('(DTY_EXAM/text())[1]','varchar(4)'),'')DTY_EXAM,

		ISNULL(Item.value('(DTM_DECISION/text())[1]','varchar(30)'),'')DTM_DECISION,
		ISNULL(Item.value('(DTD_DECISION/text())[1]','varchar(4)'),'')DTD_DECISION,
		ISNULL(Item.value('(DTY_DECISION/text())[1]','varchar(4)'),'')DTY_DECISION,

		ISNULL(Item.value('(EXAM_START/text())[1]','varchar(30)'),'')EXAM_START,
		ISNULL(Item.value('(EXAM_END/text())[1]','varchar(30)'),'')EXAM_END,

		ISNULL(Item.value('(STATUS/text())[1]','varchar(200)'),'')[STATUS],
		ISNULL(Item.value('(TITLE/text())[1]','varchar(200)'),'')TITLE,
		ISNULL(Item.value('(WEB_PROFILE/text())[1]','varchar(3)'),'')WEB_PROFILE

	INTO #_DM_DEG_COMMITTEE
	FROM @xml.nodes('/Data/Record')Records(Record)
	CROSS APPLY Records.Record.nodes('./DEG_COMMITTEE')Items(Item);
	
	-- DEBUG
	--SELECT * FROm #_DEG_COMMITTEE

	
	-- >>>>>>>>>>>>>>>>>>>>>
	--   This is how to parse/process sub-screens; Sample XML



	-- >>>>>>>>>>>>>>>>>>>>>
	--
	---- AUTHORS[web_profile]
	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')
	
	SELECT DEG_COMMITTEE.value('@id','bigint')id,
		DEG_COMMITTEE.value('@userid','bigint')userid,
		DEG_COMMITTEE.value('@dmd:lastModified','date')lastModified,
		DEG_COMMITTEE.value('@username','varchar(60)')USERNAME,
		Item.value('@id','bigint')itemid,
		ISNULL(Item.value('LNAME[1]','varchar(120)'),'')LNAME,
		ISNULL(Item.value('FNAME[1]','varchar(120)'),'')FNAME,
		ISNULL(Item.value('MNAME[1]','varchar(120)'),'')MNAME,
		ISNULL(Item.value('FACULTY_NAME[1]','varchar(60)'),'')FACULTY_NAME,
		ISNULL(Item.value('ROLE[1]','varchar(100)'),'')[ROLE],
		ROW_NUMBER()OVER(PARTITION BY DEG_COMMITTEE ORDER BY Item)sequence	
	INTO #_DM_DEG_COMMITTEE_MEMBER
	FROM @xml.nodes('/Data/Record/DEG_COMMITTEE')DEG_COMMITTEEs(DEG_COMMITTEE)
		CROSS APPLY DEG_COMMITTEEs.DEG_COMMITTEE.nodes('./DEG_COMMITTEE_MEMBER')Items(Item);
	
	-- DEBUG
	--SELECT * FROm #DEG_COMMITTEE_MEMBER

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
		ELSE BEGIN

			DECLARE @current_record_main_count INT, @new_record_main_count INT
			DECLARE @current_record_auth_count INT, @new_record_auth_count INT

			SELECT @current_record_main_count = count(*)
			FROM DM_Shadow_Production.dbo._DM_DEG_COMMITTEE

			SELECT @new_record_main_count = count(*)
			FROM #_DM_DEG_COMMITTEE

			SET @current_record_main_count = 0.8 * @current_record_main_count

			SELECT @current_record_auth_count = count(*)
			FROM DM_Shadow_Production.dbo._DM_DEG_COMMITTEE_MEMBER

			SELECT @new_record_auth_count = count(*)
			FROM #_DM_DEG_COMMITTEE_MEMBER

			SET @current_record_auth_count = 0.8 * @current_record_auth_count


			IF @new_record_main_count >= @current_record_main_count
					AND  @new_record_auth_count >= @current_record_auth_count
				BEGIN
					-- we can copy FROM (#_DM_DEG_COMMITTEE, and #_DM_DEG_COMMITTEE_MEMBER) TO (_DM_DEG_COMMITTEE, and _DM_DEG_COMMITTEE_MEMBER)

					-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
					-- @DM_Shadow_Staging database
					-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
					TRUNCATE TABLE dbo._DM_DEG_COMMITTEE

					INSERT INTO dbo._DM_DEG_COMMITTEE
						(
							[id], lastModified, Create_Datetime
							,FNAME, LNAME, UIN, INSTITUTION, [TYPE], TITLE                          
							,DTM_EXAM,DTD_EXAM, DTY_EXAM, DTM_DECISION, DTD_DECISION, DTY_DECISION
							,EXAM_START, EXAM_END, [STATUS], WEB_PROFILE
							--,USER_REFERENCE_CREATOR
						)
					SELECT distinct [id], lastModified, getdate()
							,FNAME, LNAME, UIN, INSTITUTION, [TYPE], TITLE                          
							,DTM_EXAM,DTD_EXAM, DTY_EXAM, DTM_DECISION, DTD_DECISION, DTY_DECISION
							,EXAM_START, EXAM_END, [STATUS], WEB_PROFILE
							 --,USER_REFERENCE_CREATOR				
					FROM #_DM_DEG_COMMITTEE
									
				
					--UPDATE dbo._DM_DEG_COMMITTEE 
					--	SET FACSTAFFID = U.FACSTAFFID, EDWPERSID=U.EDWPERSID 
					--FROM dbo._DM_USERS U, dbo._DM_DEG_COMMITTEE F
					--WHERE U.userid = F.userid AND ( F.FACSTAFFID is NULL OR F.EDWPERSID IS NULL )			

					TRUNCATE TABLE dbo._DM_DEG_COMMITTEE_MEMBER
					INSERT INTO dbo._DM_DEG_COMMITTEE_MEMBER
						(
							 [id], itemid, lastModified, Create_Datetime
							 ,FACULTY_NAME,FNAME,MNAME
							 ,LNAME,[ROLE],sequence
						)
					SELECT distinct [id], itemid, lastModified, getdate()
							 ,FACULTY_NAME,FNAME,MNAME
							 ,LNAME,[ROLE],sequence
					FROM #_DM_DEG_COMMITTEE_MEMBER

					-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
					-- @DM_Shadow_Production database
					-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
					TRUNCATE TABLE DM_Shadow_Production.dbo._DM_DEG_COMMITTEE

					INSERT INTO DM_Shadow_Production.dbo._DM_DEG_COMMITTEE
						(
							[id], lastModified, Create_Datetime
							,FNAME, LNAME, UIN, INSTITUTION, [TYPE], TITLE                          
							,DTM_EXAM,DTD_EXAM, DTY_EXAM, DTM_DECISION, DTD_DECISION, DTY_DECISION
							,EXAM_START, EXAM_END, [STATUS], WEB_PROFILE
							 --,USER_REFERENCE_CREATOR
						)
					SELECT  [id], lastModified, getdate()
							,FNAME, LNAME, UIN, INSTITUTION, [TYPE], TITLE                          
							,DTM_EXAM,DTD_EXAM, DTY_EXAM, DTM_DECISION, DTD_DECISION, DTY_DECISION
							,EXAM_START, EXAM_END, [STATUS], WEB_PROFILE
							 --,USER_REFERENCE_CREATOR				
					FROM dbo._DM_DEG_COMMITTEE
												
					--UPDATE DM_Shadow_Production.dbo._DM_DEG_COMMITTEE
					--SET FACSTAFFID = U.FACSTAFFID, EDWPERSID=U.EDWPERSID 
					--FROM DM_Shadow_Production.dbo._DM_USERS U, DM_Shadow_Production.dbo._DM_DEG_COMMITTEE F
					--WHERE U.userid = F.userid AND ( F.FACSTAFFID is NULL OR F.EDWPERSID IS NULL )

					TRUNCATE TABLE DM_Shadow_Production.dbo._DM_DEG_COMMITTEE_MEMBER
					INSERT INTO DM_Shadow_Production.dbo._DM_DEG_COMMITTEE_MEMBER
						(
							 [id], itemid, lastModified, Create_Datetime
							 ,FACULTY_NAME,FNAME,MNAME
							 ,LNAME,[ROLE],sequence
						)
					SELECT  [id], itemid, lastModified, getdate()
							 ,FACULTY_NAME,FNAME,MNAME
							 ,LNAME,[ROLE],sequence
					FROM dbo._DM_DEG_COMMITTEE_MEMBER

				END
			ELSE
				RAISERROR('Data is too few',18,1)

			EXEC sp_releaseapplock 'shadowmaker-DEG_COMMITTEE','Session'; 
		END



	END
	
	
	DROP TABLE #_DM_DEG_COMMITTEE;
	DROP TABLE #_DM_DEG_COMMITTEE_MEMBER;
	--DROP TABLE #LINKS;

END



GO
