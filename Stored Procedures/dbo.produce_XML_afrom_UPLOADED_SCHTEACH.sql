SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 12/12/2017:
--		Divided this process to two phases: 
--			1. produce_XML_afrom_UPLOADED_SCHTEACH : Upload the courses in daily basis 
--			2. produce_XML_afrom_UPLOADED_SCHTEACH_INITIAL
--		
-- NS 5/11/2017: Incorporated the ICES scores
-- NS 4/4/2017: new, worked!
/*

<Data><Record username="abarb6">
<SCHTEACH>
<TYT_TERM>Spring</TYT_TERM>
<TYY_TERM>2019</TYY_TERM>
<TITLE>Ethical Dilemmas of Business</TITLE>
<COURSEPRE>BADM</COURSEPRE>
<COURSENUM>340</COURSENUM>
<SECTION>A</SECTION>
<ENROLL>0</ENROLL>
<CHOURS>3.000</CHOURS>
<LEVEL>Undergraduate</LEVEL>
<DELIVERY_MODE>Lecture/Discussion
</DELIVERY_MODE>
</SCHTEACH>
</Record>
</Data>
*/
CREATE PROC [dbo].[produce_XML_afrom_UPLOADED_SCHTEACH] ( @submit BIT=0 )
AS

--IF EXISTS (
--	SELECT 1
--	FROM dbo.webservices_requests
--	WHERE url LIKE '%/User/%'
--	HAVING -- last shadowed < last refreshed
--	MAX(CASE WHEN method='GET' AND processed IS NOT NULL THEN initiated ELSE NULL END) < MAX(CASE WHEN method<>'GET' THEN created ELSE NULL END)
--) RAISERROR('This data has not been shadowed since the last refresh.',18,1);
--ELSE 

BEGIN

	-- 1) Get all courses taught by faculty/academics into _DM_UPLOAD_COURSES
	-- 2) Generate XML and insert into the queue webservices_requests table

	-- >>>>>>>> 1) Get all courses taught by faculty/academics into _DM_UPLOAD_COURSES

	DECLARE @FSID AS INT 
	DECLARE @EDWPERSID AS INT 
	DECLARE @USERNAME varchar(60)
	DECLARE @TERMCD AS VARCHAR(6) 
	DECLARE @CRSID AS VARCHAR(12) 
	DECLARE @CRN AS VARCHAR(5) 
	DECLARE @CRSSUBJCD AS VARCHAR(4) 
	DECLARE @CRSNBR AS VARCHAR(5) 
	DECLARE @CRSTITLE VARCHAR(200) 

	--select @TERMCD = term_cd
	--from Decision_Support.dbo.EDW_T_STUDENT_term
	--order by term_cd ASC  

	DECLARE @Course_Details TABLE
	(
	  [FACSTAFFID] varchar(10)
		  ,[EDWPERSID] varchar(10)
		  ,[USERNAME] varchar(60)
		  ,[TERM_CD] varchar(10)    
		  ,[TITLE] varchar(100)
		  ,CRS_SUBJ_CD varchar(10)
		  ,CRS_NBR varchar(10)
		  ,[SECTION] varchar(10)
		  ,[ENROLL] varchar(10)
		  ,[ENROLL_SECT_BASE] INT
		  ,[CHOURS] varchar(10)
		  ,[CHOURS_SECT_BASE] decimal(10,3)
		  ,[LEVEL] varchar(20)
		  ,DELIVERY_MODE varchar(100)
		  ,CRS_ID VARCHAR(20)
		  ,CRN VARCHAR(20)
	)

	SET @TERMCD = dbo.Get_Current_Term(getdate())

	DECLARE Courses_cursor CURSOR READ_ONLY FOR
	SELECT DISTINCT FacstaffID, EDWPersID, USERNAME
	FROM dbo._DM_USERS
	WHERE FacstaffID is not NULL AND EDWPersID is not NULL AND FacstaffID <> 0 AND EDWPersID <> 0 
	
	--FROM Facstaff_Basic 
	--WHERE Faculty_Staff_Indicator = '1' AND Active_Indicator = '1' 
	/*
	  Related EDW tables
		EDW_T_FAC_INSTRN_ASSIGN
		PUBLIC_EDW_T_SECT_SESS
		PUBLIC_EDW_T_SESS
		PUBLIC_EDW_T_SECT_BASE
		PUBLIC_EDW_T_TERM_CD
		PUBLIC_EDW_T_SESS_MEETING
		PUBLIC_EDW_T_CRS
		PUBLIC_EDW_T_CRS_LISTING
		PUBLIC_EDW_T_CRS_DESC_TXT
		EDW_V_FAC_PERS
		*/


	OPEN Courses_cursor
	FETCH Courses_cursor INTO @FSID, @EDWPERSID, @USERNAME

	WHILE @@FETCH_STATUS = 0
		BEGIN -- Start of Courses_cursor
			 IF @EDWPERSID IS NOT NULL -- Start of @EDWPERSID NOT NULL
			BEGIN
			
				INSERT INTO @Course_Details
					(  FACSTAFFID	
					  ,USERNAME			
					  ,TERM_CD				 
					  ,TITLE
					  ,CRS_SUBJ_CD
					  ,CRS_NBR
					  ,SECTION
					  ,ENROLL
					  ,ENROLL_SECT_BASE
					  ,CHOURS
					  ,CHOURS_SECT_BASE
					  ,[LEVEL]
					  ,DELIVERY_MODE
					  ,CRS_ID
					  ,CRN
					)
				SELECT DISTINCT @FSID as FacstaffID 
					, @USERNAME
					, TC.TERM_CD
					, TC.CRS_TITLE
					, TSB.CRS_SUBJ_CD
					, TSB.CRS_NBR
					, TSB.SECT_NBR
					, 0				
					, TSB.SECT_CENSUS_ENRL_NBR
					--, CAST(ISNULL(TC.CRS_MAX_CREDIT_HOUR_NBR,'') AS VARCHAR) AS CHOURS
					, CAST(TC.CRS_MAX_CREDIT_HOUR_NBR as DECIMAL(10,3)) as CHOURS
					, TSB.SECT_RESTRICT_VAR_CREDIT_HOUR
					, TC.CRS_NBR_LEVEL
					, TSB.SCHED_TYPE_DESC
					, TC.CRS_ID
					, TSS.CRN
				FROM  DECISION_SUPPORT.dbo.EDW_T_FAC_INSTRN_ASSIGN TFIA 
				INNER JOIN DECISION_SUPPORT.dbo.PUBLIC_EDW_T_SESS TS 
					INNER JOIN DECISION_SUPPORT.dbo.PUBLIC_EDW_T_SECT_SESS TSS 
						INNER JOIN DECISION_SUPPORT.dbo.PUBLIC_EDW_T_SECT_BASE TSB 
							ON TSS.CRN = TSB.CRN AND 
							TSS.CRS_ID = TSB.CRS_ID AND 
							TSS.TERM_CD = TSB.TERM_CD AND 
							TSB.SECT_STATUS_CD = 'A' --AND 
							--TSB.SCHED_TYPE_CD <> 'IND' 
						ON TS.CRS_ID = TSS.CRS_ID AND 
						TS.TERM_CD = TSS.TERM_CD AND 
						TS.SESS_ID = TSS.SESS_ID 
						INNER JOIN DECISION_SUPPORT.dbo.PUBLIC_EDW_T_TERM_CD PETTC 
						ON TS.TERM_CD = PETTC.TERM_CD AND 
						PETTC.TERM_CD_CAMPUS_CD = '100' -- UIUC
					INNER JOIN DECISION_SUPPORT.dbo.PUBLIC_EDW_T_SESS_MEETING TSM 
						ON TS.CRS_ID = TSM.CRS_ID AND 
						TS.SESS_ID = TSM.SESS_ID AND 
						TS.TERM_CD = TSM.TERM_CD AND 
						TSM.TIME_CONFLICT_OVRIDE_IND <> 'O' --AND 
						--LTRIM(RTRIM(TSM.SECT_BGN_TIME)) <> ''  
					INNER JOIN DECISION_SUPPORT.dbo.PUBLIC_EDW_T_CRS TC  
						INNER JOIN DECISION_SUPPORT.dbo.PUBLIC_EDW_T_CRS_LISTING TCL 			
							ON TC.CRS_ID = TCL.CRS_ID  AND 
							TC.CRS_SUBJ_CD = TCL.CRS_SUBJ_CD AND 
							TC.CRS_NBR = TCL.CRS_NBR AND 
							TCL.TERM_CD_END = '999999' -- To Weed out Renumbered Courses 
						INNER JOIN DECISION_SUPPORT.dbo.PUBLIC_EDW_T_CRS_DESC_TXT TCDT   
								ON TC.CRS_ID = TCDT.CRS_ID AND 
								TC.CRS_SUBJ_CD = TCDT.CRS_SUBJ_CD AND 
								TC.CRS_NBR = TCDT.CRS_NBR AND 
								TC.TERM_CD = TCDT.TERM_CD
						ON TS.CRS_ID = TC.CRS_ID AND 
						TS.TERM_CD = TC.TERM_CD 
					ON TFIA.CRS_ID = TS.CRS_ID AND 
						TFIA.TERM_CD = TS.TERM_CD AND 
						TFIA.SESS_ID = TS.SESS_ID 
				INNER JOIN DECISION_SUPPORT.dbo.EDW_V_FAC_PERS VFP 
					ON TFIA.EDW_PERS_ID = VFP.EDW_PERS_ID AND 
					VFP.PERS_CONFIDENTIALITY_IND <> 'Y'	
				--INNER JOIN dbo.Facstaff_Basic FSB 
					--ON TFIA.EDW_PERS_ID = FSB.EDW_PERS_ID AND 
					--FSB.Facstaff_ID = @Facstaff_ID 
			
				WHERE TFIA.EDW_Pers_ID = @EDWPERSID  
					--AND TSB.SCHED_TYPE_CD  <> 'IND' 
					AND TS.TERM_CD = @TERMCD 
					AND (LEN(TSM.SECT_BGN_TIME) <> 0) 
					AND (LEN(TSM.SECT_ROOM_NBR) <> 0)
					AND TSS.CRN is not NULL
								

			END -- End of  @EDWPERSID NOT NULL

			 FETCH Courses_cursor INTO @FSID, @EDWPERSID, @USERNAME
	
		END -- End Courses_cursor 

	CLOSE Courses_cursor
	DEALLOCATE Courses_cursor

	--UPDATE @Course_Details
	--SET Username = dbo.Get_Get_Username(FACSTAFFID)
	--	,EDWPERSID = dbo.Get_Get_EDWPERSID(FACSTAFFID)

	TRUNCATE TABLE [DM_Shadow_Staging].[dbo]._UPLOADED_DM_SCHTEACH

	-- Remove Courses already being uploaded earlier

	-- Insert into the final table for upload dbo._UPLOADED_DM_SCHTEACH
	INSERT INTO [DM_Shadow_Staging].[dbo]._UPLOADED_DM_SCHTEACH
		(TERM_CD
		  ,[FACSTAFFID]
		  ,[EDWPERSID]
		  ,[USERNAME]
		  ,[TYT_TERM]
		  ,[TYY_TERM]
		  ,[TERM_START]
		  ,[TERM_END]
		  ,[TITLE]
		  ,[COURSEPRE]
		  ,[COURSENUM]
		  ,[SECTION]
		  ,[ENROLL]	
		  ,[CHOURS]
		  ,[LEVEL]
		  ,DELIVERY_MODE
		  ,CRS_ID
		  ,CRN
		  ,Create_Datetime
		  )
	SELECT TERM_CD
		  ,FACSTAFFID
		  ,EDWPERSID		
		  ,USERNAME
		  ,dbo.Get_Term_Name(TERM_CD)
		  ,dbo.Get_Term_Year(TERM_CD)
		  ,dbo.Get_Term_Start(TERM_CD)
		  ,dbo.Get_Term_End(TERM_CD)
		  ,TITLE
		  ,CRS_SUBJ_CD
		  ,CRS_NBR
		  ,SECTION
		  ,dbo.Get_Course_Enrollment(TERM_CD,CRN,CRS_ID,EDWPERSID,CRS_SUBJ_CD,CRS_NBR,SECTION) as ENROLL      
		  ,CASE WHEN CHOURS_SECT_BASE IS NOT NULL AND CHOURS_SECT_BASE > 0.0 THEN CAST(CHOURS_SECT_BASE as varchar)
				WHEN (CHOURS_SECT_BASE IS NULL OR CHOURS_SECT_BASE = 0.0) AND CHOURS IS NOT NULL THEN CHOURS
				ELSE '' END as CHOURS 
		  ,CASE WHEN [LEVEL] IN ('100','200','300') THEN 'Undergraduate'
				WHEN [LEVEL] IN ('400','500','600','700') THEN 'Graduate'
				ELSE '' END AS [LEVEL] 
		  ,DELIVERY_MODE
		  ,CRS_ID
		  ,CRN
		  ,getdate()
	FROM @Course_Details

	-- Replace all "-" to "/", except "On-line"
	UPDATE [DM_Shadow_Staging].[dbo]._UPLOADED_DM_SCHTEACH
	SET DELIVERY_MODE = REPLACE(DELIVERY_MODE,'-','/')

	UPDATE [DM_Shadow_Staging].[dbo]._UPLOADED_DM_SCHTEACH
	SET DELIVERY_MODE = REPLACE(DELIVERY_MODE,'On/Line','On-Line')


	-- NS 5/11/2017: Incorporated the ICES scores
	/*
	UPDATE [DM_Shadow_Staging].[dbo].[_UPLOADED_DM_SCHTEACH]
	SET    ICES_Respondents = AI.[Respondents]
			,[ICES1] = AI.[ICES1]
			,ICES2 = AI.[ICES2]
	FROM  [DM_Shadow_Staging].[dbo].[_UPLOADED_DM_SCHTEACH] CD, 
				[Faculty_Staff_Holder].[dbo].[ACCY_ICES_2000_2005] AI
	WHERE CD.FacstaffId = AI.Facstaff_ID 
						AND CD.SECTION = AI.SECT_NBR
						AND CD.TERM_CD = AI.TERM
						AND CD.COURSENUM = AI.CRS_NBR
						AND CD.COURSEPRE = AI.CRS_SUBJ_CD

	UPDATE [DM_Shadow_Staging].[dbo].[_UPLOADED_DM_SCHTEACH]
	SET   [ICES1] = ''
	WHERE ICES1 IS NULL

	UPDATE [DM_Shadow_Staging].[dbo].[_UPLOADED_DM_SCHTEACH]
	SET    ICES_Respondents = ''
	WHERE  ICES_Respondents IS NULl

	UPDATE [DM_Shadow_Staging].[dbo].[_UPLOADED_DM_SCHTEACH]
	SET  ICES2 = ''
	WHERE ICES2 IS NULl
	*/


	-- >>>>>>>>>>>>>>>>>>>>>  2) Generate XML and insert into the queue webservices_requests table
		
	SELECT  u.username
		  ,[TYT_TERM]
		  ,[TYY_TERM]
		  ,[TERM_START]
		  ,[TERM_END]
		  ,[TITLE]
		  ,[COURSEPRE]
		  ,[COURSENUM]
		  ,[SECTION]
		  ,[ENROLL]	
		  ,[CHOURS]
		  ,[LEVEL]
		  ,DELIVERY_MODE 
	INTO #_DM_Courses
	FROM dbo._UPLOADED_DM_SCHTEACH courses
			Inner JOIN dbo._DM_USERS u
			ON courses.username=u.username


	--UPDATE #_DM_Courses
	--SET FNAME = replace(replace(replace(replace(replace(replace(
	--				replace(replace(replace(FNAME, char(9), ' '), char(10), ' '), char(13), ' '), 
	--				'     ', ' '), '    ', ' '), '   ', ' '), '  ', ' '), '- ', '-'), ' -', '-')

		
	SELECT method m,url u,xml post, username, o,ROW_NUMBER()OVER(ORDER BY username,o,url)r
	INTO #updates
	FROM (
	    SELECT username,3 o,'POST' method,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business' url,
		CAST((SELECT username "@username"
					  ,(SELECT
					   TYT_TERM
					  ,TYY_TERM
					  --,TERM_START	-- this must have been READ_ONLY type
					  --,TERM_END	-- this must have been READ_ONLY type
					  ,TITLE
					  ,COURSEPRE
					  ,COURSENUM
					  ,SECTION
					  ,ENROLL	
					  ,CHOURS
					  ,[LEVEL]
					  ,DELIVERY_MODE 
					  				
				  FOR XML PATH('SCHTEACH'),TYPE
			)FOR XML PATH('Record'),ROOT('Data')

		)AS VARCHAR(MAX)) xml
	FROM #_DM_Courses
	)x
	ORDER BY username,o



IF @submit=1 BEGIN
	
	CREATE TABLE #requests(id INT NOT NULL,method VARCHAR(10),url VARCHAR(255),r INT)
	
	INSERT INTO webservices_requests(method,url,post,process)
	OUTPUT inserted.id,inserted.method,inserted.url,inserted.process INTO #requests
	SELECT m,u,CAST(post AS VARCHAR(MAX)),r FROM #updates WHERE post IS NOT NULL

	UPDATE webservices_requests SET process=NULL,dependsOn=(
		SELECT TOP 1 id FROM #requests r2 JOIN #updates u2 ON u2.r=r2.r
		WHERE u2.o<u1.o AND u2.username=u1.username ORDER BY u2.o DESC)
	FROM webservices_requests
	JOIN #requests r1 ON r1.id=webservices_requests.id
	JOIN #updates u1 ON u1.r=r1.r
	
	DROP TABLE #requests
END
ELSE
BEGIN
	--SELECT  username,DELIVERY_MODE FROM #_DM_Courses
	SELECT * FROM #updates
END

DROP TABLE #updates

-- EXEC dbo.produce_XML_afrom_UPLOADED_SCHTEACH @submit = 0
-- EXEC dbo.produce_XML_afrom_UPLOADED_SCHTEACH @submit = 1
END


GO
