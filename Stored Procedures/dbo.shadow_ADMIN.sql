SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 4/15/2019
--			Added RANK,TENURE,STAFF_TYPE,FTE,FTE_EXTERN,UPDATED,KEEP_ACTIVE
-- NS 1/2/2019
--			DM_ADMIN_PROG, DM_ADMIN_EMPGROUP, DM_ADMIN_EMPTYPE, DM_ADMIN_NPRESP, DM_ADMIN_TITLE are all done
-- NS 12/17/2018
--			Changed _DM_ADMIN_AREA to _DM_ADMIN_PROG table
--			changed _DM_ADMIN_AREA.AREA to _DM_ADMIN_PROG.PROG
--			newly updated names: UPDATED, EXCLUDE_AACSB, ENDOWED_POS, and SHOW_DIRECTORY
-- NS 10/27/2017 

CREATE PROCEDURE [dbo].[shadow_ADMIN] (@webservices_requests_id INT, @xml XML, @userid BIGINT=NULL,@resync BIT=NULL) AS 

BEGIN

/*
	Manual run to shadow individual ADMIN screen -- 10 seconds
	EXEC dbo.webservices_initiate @screen='ADMIN'
	DECLARE @Result varchar(500)
	EXEC dbo.webservices2_run @Result = @Result OUTPUT
	PRINT @Result

	Run Test
	EXEC dbo._Test_Shadow_ADMIN
*/

			
	-- https://www.digitalmeasures.com/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/ADMIN
	-- XML Sample:
	/*

	<Data dmd:date="2019-01-02">
		<Record userId="1791140" username="nhadi" termId="6117" dmd:surveyId="17698891">
			<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="Academy for Entrepreneurial Leadership" text="Academy for Entrepreneurial Leadership" />
			<dmd:IndexEntry indexKey="DEPARTMENT" entryKey="IT Partners" text="IT Partners" />
			<dmd:IndexEntry indexKey="PROG" entryKey="BA: Information Systems" text="BA: Information Systems" />
			<dmd:IndexEntry indexKey="PROG" entryKey="BA: Marketing" text="BA: Marketing" />
			<dmd:IndexEntry indexKey="PROG" entryKey="iMBA Program" text="iMBA Program" />
			<ADMIN id="169909727232" dmd:originalSource="IMPORT" dmd:created="2018-09-20T14:10:30" dmd:lastModifiedSource="MANUAL" dmd:lastModified="2019-01-02T15:45:48" dmd:startDate="2017-09-01" dmd:endDate="2018-08-31" dmd:primaryKey="2017-2018">
					<AC_YEAR>2017-2018</AC_YEAR>
					<YEAR_START>2017-09-01</YEAR_START>
					<YEAR_END>2018-08-31</YEAR_END>
					<ADMIN_DEP id="169909727233" dmd:primaryKey="IT Partners">
						<DEP>IT Partners</DEP>
						<SHOW_DIRECTORY>Yes</SHOW_DIRECTORY>
					</ADMIN_DEP>
					<ADMIN_DEP id="169909727242" dmd:primaryKey="Academy for Entrepreneurial Leadership">
						<DEP>Academy for Entrepreneurial Leadership</DEP>
						<SHOW_DIRECTORY>Yes</SHOW_DIRECTORY>
					</ADMIN_DEP>
					<ADMIN_PROG id="169909727234">
						<PROG>BA: Information Systems</PROG>
					</ADMIN_PROG>
					<ADMIN_PROG id="169909727237">
						<PROG>BA: Marketing</PROG>
					</ADMIN_PROG>
					<ADMIN_PROG id="169909727240">
						<PROG>iMBA Program</PROG>
					</ADMIN_PROG>
					<RANK>Adjunct Professor</RANK>
					<STAFF_TYPE>Academic Professional</STAFF_TYPE>
					<TENURE>Non-Tenure Track</TENURE>
					<FTE>100</FTE>
					<FTE_EXTERN>25</FTE_EXTERN>
					<ADMIN_TITLE id="169909727235">
					<TITLE>Assistant Director for Systems Development</TITLE>
						<ENDOWED_POS>No</ENDOWED_POS>
						<ROLE>Other</ROLE>
						<ROLE_OTHER>Assistant Director</ROLE_OTHER>
						<TITLE_CURRENT>Yes</TITLE_CURRENT>
					</ADMIN_TITLE>
					<ADMIN_TITLE id="169909727238">
						<TITLE>Big Data Consultant</TITLE>
						<ENDOWED_POS>No</ENDOWED_POS>
						<ROLE>Other</ROLE>
						<ROLE_OTHER>Consultant</ROLE_OTHER>
						<TITLE_CURRENT>Yes</TITLE_CURRENT>
					</ADMIN_TITLE>
					
					<EMPTYPE>Faculty</EMPTYPE>
					<EMPTYPE>Staff</EMPTYPE>
					
					<EMPGROUP>Accountancy Faculty</EMPGROUP>
					<EMPGROUP>Business Administration Faculty</EMPGROUP>
					<EMPGROUP>Business Administration Staff</EMPGROUP>

					<NPRESP>Administration</NPRESP>
					<NPRESP>Doctoral Level Teaching/Mentoring</NPRESP>
					<NPRESP>Executive Education</NPRESP>
					<NPRESP>Other Service and Outreach Responsibilities</NPRESP>
					<KEEP_ACTIVE>Yes</KEEP_ACTIVE>

					<DEDMISS>90</DEDMISS>
					<QUALIFICATION />
					<QUALIFICATION_BASIS />
					<AACSBSUFF />
					<JOINT_APPOINTMENT />
					<EXCLUDE_AACSB />
					<UPDATED>No</UPDATED>
					
			 </ADMIN>
		 </Record>
	</Data>
	

		*/

	DECLARE @prefix varchar(1000)
	SELECT @prefix = SP_ERROR FROM dbo.webservices_requests WHERE [ID]=@webservices_requests_id		
	SET @prefix = @prefix + '- shadow_ADMIN '
	UPDATE dbo.webservices_requests SET SP_Error=@prefix WHERE [ID]=@webservices_requests_id;	

	-- >>>>>>>>>> PROCESSING ADMIN

	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')	
	SELECT ADMIN.value('@id','bigint')id,
		--ADMIN.value('@id','bigint')id,
		ADMIN.value('@dmd:lastModified','date')lastModified,
		ADMIN.value('(AC_YEAR/text())[1]','varchar(12)') AC_YEAR,
		ADMIN.value('(RANK/text())[1]','varchar(100)') [RANK],
		ADMIN.value('(TENURE/text())[1]','varchar(100)') TENURE,
		ADMIN.value('(STAFF_TYPE/text())[1]','varchar(100)') STAFF_TYPE,
		ADMIN.value('(FTE/text())[1]','decimal(9,0)') FTE,
		ADMIN.value('(FTE_EXTERN/text())[1]','decimal(9,0)') FTE_EXTERN,
		ADMIN.value('(DEDMISS/text())[1]','int') DEDMISS,
		ADMIN.value('(QUALIFICATION/text())[1]','varchar(100)') QUALIFICATION,
		ADMIN.value('(QUALIFICATION_BASIS/text())[1]','varchar(1000)') QUALIFICATION_BASIS,
		ADMIN.value('(AACSBSUFF/text())[1]','varchar(100)') AACSBSUFF,  -- AACSB SUfficiency
		ADMIN.value('(JOINT_APPOINTMENT/text())[1]','varchar(3)') JOINT_APPOINTMENT,
		ADMIN.value('(EXCLUDE_AACSB/text())[1]','varchar(3)') EXCLUDE_AACSB,
		ADMIN.value('(UPDATED/text())[1]','varchar(3)') UPDATED,
		ADMIN.value('(KEEP_ACTIVE/text())[1]','varchar(3)') KEEP_ACTIVE,
		REC.value('@userId','bigint')userid,	
		REC.value('@username','varchar(60)')USERNAME,

		getdate() as Create_Datetime,
		getdate() as Download_Datetime				
	INTO #_DM_ADMIN1
	FROM @xml.nodes('/Data/Record')Recs(REC)
		CROSS APPLY Recs.Rec.nodes('./ADMIN')ADMINs(ADMIN)


	--SELECT * FROM #_DM_ADMIN0

	SELECT DMA.*
	INTO #_DM_ADMIN
	FROM #_DM_ADMIN1 DMA INNER JOIN
			(SELECT USERNAME, MAX(AC_YEAR) AS AC_YEAR
			 FROM #_DM_ADMIN1 
			 GROUP BY USERNAME) DMMAX
		ON DMA.AC_YEAR = DMMAX.AC_YEAR
			AND DMA.USERNAME = DMMAX.USERNAME;

	--SELECT * FROM #_DM_ADMIN

	-- >>>>>>>>> PROCESSING ADMIN_DEP 
	--	the id for each ADMIN_DEP records is from the individual DSA (ADMIN_DEP)

	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')	
	SELECT Item.value('@id','bigint')id,
		--ADMIN.value('@id','bigint')id,
		ADMIN.value('@dmd:lastModified','date')lastModified,
		ADMIN.value('(AC_YEAR/text())[1]','varchar(12)') AC_YEAR,
		REC.value('@userId','bigint')userid,	
		REC.value('@username','varchar(60)')USERNAME,
		--Item.value('@id','bigint')itemid,
		ISNULL(Item.value('DEP[1]','varchar(200)'),'')DEP,	
		Item.value('(SHOW_DIRECTORY/text())[1]','varchar(3)') SHOW_DIRECTORY,
		ROW_NUMBER()OVER(PARTITION BY ADMIN ORDER BY Item) SEQ,
		getdate() as Create_Datetime,
		getdate() as Download_Datetime				
	INTO #_DM_ADMIN2
	FROM @xml.nodes('/Data/Record')Recs(REC)
		CROSS APPLY Recs.Rec.nodes('./ADMIN')ADMINs(ADMIN)
		CROSS APPLY ADMINs.ADMIN.nodes('./ADMIN_DEP')Items(Item);

	--SELECT * FROM #_DM_ADMIN2

	SELECT DMA.*
	INTO #_DM_ADMIN_DEP
	FROM #_DM_ADMIN2 DMA INNER JOIN
			(SELECT USERNAME, MAX(AC_YEAR) AS AC_YEAR
			 FROM #_DM_ADMIN2 
			 GROUP BY USERNAME) DMMAX
		ON DMA.AC_YEAR = DMMAX.AC_YEAR
			AND DMA.USERNAME = DMMAX.USERNAME;

	-- >>>>>>>> PROCESSING ADMIN_NPRESP (Percent of Time Dedicated to the School's Mission)
	-- Since individual NPRESP does not have ID (unlike individual DSA for DEP in ADMIN_DEP)
	--		then the id for each ADMIN_NPRESP records MUST be a combination from the id from the main (ADMIN) with the SEQ since the NPRESP checkboxes are not implemented as a DSA (unlike the DEP)
	--		Therefore SEQ is needed to compose an ID

		WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')	
	SELECT ADMIN.value('@id','bigint')id,
		--ADMIN.value('@id','bigint')id,
		ADMIN.value('@dmd:lastModified','date')lastModified,
		ADMIN.value('(AC_YEAR/text())[1]','varchar(12)') AC_YEAR,
		REC.value('@userId','bigint')userid,	
		REC.value('@username','varchar(60)')USERNAME,
		--Item.value('@id','bigint')itemid,
		item.value('.','varchar(200)') NPRESP,
		ROW_NUMBER()OVER(PARTITION BY ADMIN ORDER BY Item) SEQ,
		getdate() as Create_Datetime,
		getdate() as Download_Datetime				
	INTO #_DM_ADMIN3
	FROM @xml.nodes('/Data/Record')Recs(REC)
		CROSS APPLY Recs.Rec.nodes('./ADMIN')ADMINs(ADMIN)
		CROSS APPLY ADMINs.ADMIN.nodes('./NPRESP')Items(Item);

	--SELECT * FROM #_DM_ADMIN3

	SELECT DMA.*
	INTO #_DM_ADMIN_NPRESP
	FROM #_DM_ADMIN3 DMA INNER JOIN
			(SELECT USERNAME, MAX(AC_YEAR) AS AC_YEAR
			 FROM #_DM_ADMIN3 
			 GROUP BY USERNAME) DMMAX
		ON DMA.AC_YEAR = DMMAX.AC_YEAR
			AND DMA.USERNAME = DMMAX.USERNAME;

	UPDATE #_DM_ADMIN_NPRESP
	SET id = CAST (CONCAT(CAST(id as varchar),CAST(SEQ as varchar)) as bigint);

	-- >>>>>>>>> PROCESSING ADMIN_PROG 
	--	the id for each ADMIN_PROG records is from the individual DSA (ADMIN_PROG)

	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')	
	SELECT Item.value('@id','bigint')id,
		--ADMIN.value('@id','bigint')id,
		ADMIN.value('@dmd:lastModified','date')lastModified,
		ADMIN.value('(AC_YEAR/text())[1]','varchar(12)') AC_YEAR,
		REC.value('@userId','bigint')userid,	
		REC.value('@username','varchar(60)')USERNAME,
		--Item.value('@id','bigint')itemid,
		ISNULL(Item.value('PROG[1]','varchar(200)'),'')PROG,
		ROW_NUMBER()OVER(PARTITION BY ADMIN ORDER BY Item) SEQ,
		getdate() as Create_Datetime,
		getdate() as Download_Datetime				
	INTO #_DM_ADMIN4
	FROM @xml.nodes('/Data/Record')Recs(REC)
		CROSS APPLY Recs.Rec.nodes('./ADMIN')ADMINs(ADMIN)
		CROSS APPLY ADMINs.ADMIN.nodes('./ADMIN_PROG')Items(Item);

	--SELECT * FROM #_DM_ADMIN4

	SELECT DMA.*
	INTO #_DM_ADMIN_PROG
	FROM #_DM_ADMIN4 DMA INNER JOIN
			(SELECT USERNAME, MAX(AC_YEAR) AS AC_YEAR
			 FROM #_DM_ADMIN4
			 GROUP BY USERNAME) DMMAX
		ON DMA.AC_YEAR = DMMAX.AC_YEAR
			AND DMA.USERNAME = DMMAX.USERNAME;


	-- >>>>>>>>> PROCESSING ADMIN_TITLE
	--	the id for each ADMIN_TITLE records is from the individual DSA (ADMIN_TITLE)

	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')	
	SELECT Item.value('@id','bigint')id,
		--ADMIN.value('@id','bigint')id,
		ADMIN.value('@dmd:lastModified','date')lastModified,
		ADMIN.value('(AC_YEAR/text())[1]','varchar(12)') AC_YEAR,
		REC.value('@userId','bigint')userid,	
		REC.value('@username','varchar(60)')USERNAME,
		--Item.value('@id','bigint')itemid,
		ISNULL(Item.value('TITLE[1]','varchar(200)'),'')TITLE,
		ISNULL(Item.value('ENDOWED_POS[1]','varchar(3)'),'')ENDOWED_POS,
		ISNULL(Item.value('ROLE[1]','varchar(100)'),'')[ROLE],
		ISNULL(Item.value('ROLE_OTHER[1]','varchar(500)'),'')ROLE_OTHER,
		ISNULL(Item.value('TITLE_CURRENT[1]','varchar(3)'),'')TITLE_CURRENT,
		ROW_NUMBER()OVER(PARTITION BY ADMIN ORDER BY Item) SEQ,
		getdate() as Create_Datetime,
		getdate() as Download_Datetime				
	INTO #_DM_ADMIN5
	FROM @xml.nodes('/Data/Record')Recs(REC)
		CROSS APPLY Recs.Rec.nodes('./ADMIN')ADMINs(ADMIN)
		CROSS APPLY ADMINs.ADMIN.nodes('./ADMIN_TITLE')Items(Item);

	--SELECT * FROM #_DM_ADMIN5

	SELECT DMA.*
	INTO #_DM_ADMIN_TITLE
	FROM #_DM_ADMIN5 DMA INNER JOIN
			(SELECT USERNAME, MAX(AC_YEAR) AS AC_YEAR
			 FROM #_DM_ADMIN5
			 GROUP BY USERNAME) DMMAX
		ON DMA.AC_YEAR = DMMAX.AC_YEAR
			AND DMA.USERNAME = DMMAX.USERNAME;

	-- >>>>>>>> PROCESSING ADMIN_EMPGROUP (all possible empgroup for the purpose allowing varios admin roles to access)
	-- Since individual EMPGROUP does not have ID (unlike individual DSA for DEP in ADMIN_DEP)
	--		then the id for each ADMIN_EMPGROUP records MUST be a combination from the id from the main (ADMIN) with the SEQ since the EMPGROUP checkboxes are not implemented as a DSA (unlike the DEP)
	--		Therefore SEQ is needed to compose an ID

	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')	
	SELECT ADMIN.value('@id','bigint')id,
		--ADMIN.value('@id','bigint')id,
		ADMIN.value('@dmd:lastModified','date')lastModified,
		ADMIN.value('(AC_YEAR/text())[1]','varchar(12)') AC_YEAR,
		REC.value('@userId','bigint')userid,	
		REC.value('@username','varchar(60)')USERNAME,
		--Item.value('@id','bigint')itemid,
		item.value('.','varchar(200)') EMPGROUP,
		ROW_NUMBER()OVER(PARTITION BY ADMIN ORDER BY Item) SEQ,
		getdate() as Create_Datetime,
		getdate() as Download_Datetime				
	INTO #_DM_ADMIN6
	FROM @xml.nodes('/Data/Record')Recs(REC)
		CROSS APPLY Recs.Rec.nodes('./ADMIN')ADMINs(ADMIN)
		CROSS APPLY ADMINs.ADMIN.nodes('./EMPGROUP')Items(Item);

	--SELECT * FROM #_DM_ADMIN6

	SELECT DMA.*
	INTO #_DM_ADMIN_EMPGROUP
	FROM #_DM_ADMIN6 DMA INNER JOIN
			(SELECT USERNAME, MAX(AC_YEAR) AS AC_YEAR
			 FROM #_DM_ADMIN6
			 GROUP BY USERNAME) DMMAX
		ON DMA.AC_YEAR = DMMAX.AC_YEAR
			AND DMA.USERNAME = DMMAX.USERNAME;

	UPDATE #_DM_ADMIN_EMPGROUP
	SET id = CAST (CONCAT(CAST(id as varchar),CAST(SEQ as varchar)) as bigint);


		-- >>>>>>>> PROCESSING ADMIN_EMPGROUP (all possible empgroup for the purpose allowing varios admin roles to access)
	-- Since individual EMPGROUP does not have ID (unlike individual DSA for DEP in ADMIN_DEP)
	--		then the id for each ADMIN_EMPGROUP records MUST be a combination from the id from the main (ADMIN) with the SEQ since the EMPGROUP checkboxes are not implemented as a DSA (unlike the DEP)
	--		Therefore SEQ is needed to compose an ID

	WITH XMLNAMESPACES('http://www.digitalmeasures.com/schema/data-metadata' AS dmd, DEFAULT 'http://www.digitalmeasures.com/schema/data')	
	SELECT ADMIN.value('@id','bigint')id,
		--ADMIN.value('@id','bigint')id,
		ADMIN.value('@dmd:lastModified','date')lastModified,
		ADMIN.value('(AC_YEAR/text())[1]','varchar(12)') AC_YEAR,
		REC.value('@userId','bigint')userid,	
		REC.value('@username','varchar(60)')USERNAME,
		--Item.value('@id','bigint')itemid,
		item.value('.','varchar(200)') EMPTYPE,
		ROW_NUMBER()OVER(PARTITION BY ADMIN ORDER BY Item) SEQ,
		getdate() as Create_Datetime,
		getdate() as Download_Datetime				
	INTO #_DM_ADMIN7
	FROM @xml.nodes('/Data/Record')Recs(REC)
		CROSS APPLY Recs.Rec.nodes('./ADMIN')ADMINs(ADMIN)
		CROSS APPLY ADMINs.ADMIN.nodes('./EMPTYPE')Items(Item);

	--SELECT * FROM #_DM_ADMIN7

	SELECT DMA.*
	INTO #_DM_ADMIN_EMPTYPE
	FROM #_DM_ADMIN7 DMA INNER JOIN
			(SELECT USERNAME, MAX(AC_YEAR) AS AC_YEAR
			 FROM #_DM_ADMIN7
			 GROUP BY USERNAME) DMMAX
		ON DMA.AC_YEAR = DMMAX.AC_YEAR
			AND DMA.USERNAME = DMMAX.USERNAME;

	UPDATE #_DM_ADMIN_EMPTYPE
	SET id = CAST (CONCAT(CAST(id as varchar),CAST(SEQ as varchar)) as bigint);





	--SELECT * FROM #_DM_ADMIN_NPRESP

	--SELECT * FROM #_DM_ADMIN
	--print '#_DM_ADMIN done'

	DECLARE @tolerance INT
	DECLARE @fields varchar(3000)

	-- Verify Incoming Data Integrity
	IF @userid IS NULL AND (SELECT COUNT(*) FROM #_DM_ADMIN) < 1  -- just to make sure we have some records, change the threshold to 10 or more on production
		BEGIN
			UPDATE dbo.webservices_requests SET SP_Error=@prefix + ': ADMIN has no data' WHERE [ID]=@webservices_requests_id			
			RAISERROR('ADMIN screen has no Data',18,1)
		END
	-- Delete & Insert the staging data
	ELSE 
	    BEGIN

		DECLARE @locked INTEGER;

		EXEC @locked = sp_getapplock 'shadowmaker-ADMIN','Exclusive','Session',20000; -- 20 second wait

		IF @locked < 0 
			BEGIN
					PRINT 'shadowmaker-ADMIN Import Locked'
					UPDATE dbo.webservices_requests SET SP_Error=@prefix + ': shadowmaker-ADMIN Import Locked' WHERE [ID]=@webservices_requests_id			
			END
		ELSE	
		    BEGIN 				
					-- DM_ADMIN
					SET @fields = 'userid,username,lastModified,Create_Datetime,Download_DateTime' +
										',AC_YEAR,RANK,TENURE,STAFF_TYPE,FTE,FTE_EXTERN,DEDMISS,QUALIFICATION,QUALIFICATION_BASIS,AACSBSUFF,JOINT_APPOINTMENT,EXCLUDE_AACSB,UPDATED,KEEP_ACTIVE'
					EXEC dbo.shadow_screen_data1 @webservices_requests_id=@webservices_requests_id,@table='_DM_ADMIN'
						,@idtype=NULL,@cols=@fields
						,@userid=@userid,@resync=@resync,@debug=0

					-- DM_ADMIN_DEP
					SET @fields = 'userid,username,lastModified,Create_Datetime,Download_DateTime' +
										',DEP,SHOW_DIRECTORY,AC_YEAR,SEQ'
					EXEC dbo.shadow_screen_data1 @webservices_requests_id=@webservices_requests_id,@table='_DM_ADMIN_DEP'
						,@idtype=NULL,@cols=@fields
						,@userid=@userid,@resync=@resync,@debug=0

					-- DM_ADMIN_NPRESP
					SET @fields = 'userid,username,lastModified,Create_Datetime,Download_DateTime' +
										',NPRESP,AC_YEAR,SEQ'
					EXEC dbo.shadow_screen_data1 @webservices_requests_id=@webservices_requests_id,@table='_DM_ADMIN_NPRESP'
						,@idtype=NULL,@cols=@fields
						,@userid=@userid,@resync=@resync,@debug=0

					-- DM_ADMIN_PROG
					SET @fields = 'userid,username,lastModified,Create_Datetime,Download_DateTime' +
										',PROG,AC_YEAR,SEQ'
					EXEC dbo.shadow_screen_data1 @webservices_requests_id=@webservices_requests_id,@table='_DM_ADMIN_PROG'
						,@idtype=NULL,@cols=@fields
						,@userid=@userid,@resync=@resync,@debug=0

					-- DM_ADMIN_EMPGROUP
					SET @fields = 'userid,username,lastModified,Create_Datetime,Download_DateTime' +
										',EMPGROUP,AC_YEAR,SEQ'
					EXEC dbo.shadow_screen_data1 @webservices_requests_id=@webservices_requests_id,@table='_DM_ADMIN_EMPGROUP'
						,@idtype=NULL,@cols=@fields
						,@userid=@userid,@resync=@resync,@debug=0
					
					-- DM_ADMIN_EMPTYPE
					SET @fields = 'userid,username,lastModified,Create_Datetime,Download_DateTime' +
										',EMPTYPE,AC_YEAR,SEQ'
					EXEC dbo.shadow_screen_data1 @webservices_requests_id=@webservices_requests_id,@table='_DM_ADMIN_EMPTYPE'
						,@idtype=NULL,@cols=@fields
						,@userid=@userid,@resync=@resync,@debug=0
					
					-- DM_ADMIN_TITLE
					SET @fields = 'userid,username,lastModified,Create_Datetime,Download_DateTime' +
										',TITLE,ENDOWED_POS,ROLE,ROLE_OTHER,TITLE_CURRENT,AC_YEAR,SEQ'
					EXEC dbo.shadow_screen_data1 @webservices_requests_id=@webservices_requests_id,@table='_DM_ADMIN_TITLE'
						,@idtype=NULL,@cols=@fields
						,@userid=@userid,@resync=@resync,@debug=0
							
			END
		EXEC sp_releaseapplock 'shadowmaker-ADMIN','Session'; 
	END

	UPDATE dbo.webservices_requests SET SP_Error=@prefix + ': shadow_ADMIN Done' WHERE [ID]=@webservices_requests_id		


	

	DROP TABLE #_DM_ADMIN1; -- for _DM_ADMIN
	DROP TABLE #_DM_ADMIN2; -- for _DM_ADMIN_DEP
	DROP TABLE #_DM_ADMIN3; -- for _DM_ADMIN_NPRESP
	DROP TABLE #_DM_ADMIN4;	-- for _DM_ADMIN_PROG
	DROP TABLE #_DM_ADMIN5;	-- for _DM_ADMIN_TITLE
	DROP TABLE #_DM_ADMIN;

END



GO
