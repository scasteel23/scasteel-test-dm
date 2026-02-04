SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 12/12/2017 
--		Divided this process to two phases: 
--			1. produce_XML_afrom_UPLOADED_SCHTEACH : Upload the courses in daily basis 
--			2. produce_XML_afrom_UPLOADED_SCHTEACH_INITIAL : once during the DM setup
--		
CREATE PROC [dbo].[produce_XML_afrom_UPLOADED_SCHTEACH_INITIAL] ( @submit BIT=0 )
AS

--IF EXISTS (
--	SELECT 1
--	FROM dbo.dbo.webservices_requests
--	WHERE url LIKE '%/User/%'
--	HAVING -- last shadowed < last refreshed
--	MAX(CASE WHEN method='GET' AND processed IS NOT NULL THEN initiated ELSE NULL END) < MAX(CASE WHEN method<>'GET' THEN created ELSE NULL END)
--) RAISERROR('This data has not been shadowed since the last refresh.',18,1);
--ELSE 

BEGIN

	-- 1) Get all courses from Faculty_Staff_Holder.dbo.BUS_COURSES_FOR_DM into dbo._DM_UPLOAD_COURSES
	-- 2) Generate XML and insert into the queue dbo.webservices_requests table

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



	TRUNCATE TABLE [DM_Shadow_Staging].[dbo].[_UPLOADED_DM_SCHTEACH]

	-- Remove Courses already being uploaded earlier

	-- Insert into the final table for upload dbo._UPLOADED_DM_SCHTEACH
	INSERT INTO dbo._UPLOADED_DM_SCHTEACH
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
		  ,ICES_RESPONDENTS
		  ,ICES1
		  ,ICES2
		  ,Create_Datetime
		  )
	SELECT  TERM_CD
			  ,Facstaff_ID
			  ,EDW_PERS_ID
			  ,Network_ID
			  ,dbo.Get_Term_Name(TERM_CD)
			  ,dbo.Get_Term_Year(TERM_CD)
			  ,dbo.Get_Term_Start(TERM_CD)
			  ,dbo.Get_Term_End(TERM_CD)

			  ,CRS_TITLE
			  ,CRS_SUBJ_CD
			  ,CRS_NBR
			  ,SECT_NBR

			  ,SECT_CENSUS_ENRL_NBR
			  ,CHOUR 
		      ,[LEVEL] 
			  --,SECT_RESTRICT_VAR_CREDIT_HOUR
			  ,SCHED_TYPE_DESC

			  ,CRS_ID
			  ,CRN
			  ,Respondents
			  ,ICES1
			  ,ICES2

			  ,Create_Datetime
	FROM Faculty_Staff_Holder.dbo.BUS_COURSES_FOR_DM BC
	WHERE Network_ID IN (SELECT USERNAME FROM dbo._DM_USERS )
		
	UPDATE [DM_Shadow_Staging].[dbo]._UPLOADED_DM_SCHTEACH
	SET DELIVERY_MODE = REPLACE(DELIVERY_MODE,'Laboratory/Discussion','Laboratory-Discussion')

	UPDATE [DM_Shadow_Staging].[dbo]._UPLOADED_DM_SCHTEACH
	SET DELIVERY_MODE = REPLACE(DELIVERY_MODE,'Lecture/Discussion','Lecture-Discussion')	

	UPDATE [DM_Shadow_Staging].[dbo]._UPLOADED_DM_SCHTEACH
	SET DELIVERY_MODE = REPLACE(DELIVERY_MODE,'On/Line','Online')

	UPDATE [DM_Shadow_Staging].[dbo]._UPLOADED_DM_SCHTEACH
	SET DELIVERY_MODE = REPLACE(DELIVERY_MODE,'On-Line','Online')

	UPDATE [DM_Shadow_Staging].[dbo]._UPLOADED_DM_SCHTEACH
	SET DELIVERY_MODE = ''
	WHERE DELIVERY_MODE NOT IN ('Conference',
			'Discussion/Recitation',
			'Independent Study',
			'Laboratory',
			'Laboratory-Discussion',
			'Lecture',
			'Lecture-Discussion',
			'Online',
			'Packaged Section',
			'Practice',
			'Quiz',
			'Study Abroad' )


	-- DDD >>>
	-- >>>>>>>>>>>>>>>>>>>>>  2) Generate XML and insert into the queue dbo.webservices_requests table
		
	SELECT  USERNAME
		  ,TYT_TERM
		  ,TYY_TERM
		  ,TERM_START
		  ,TERM_END
		  ,TITLE
		  ,COURSEPRE
		  ,COURSENUM
		  ,SECTION
		  ,ENROLL	
		  ,CHOURS
		  ,[LEVEL]
		  ,DELIVERY_MODE
		  ,CRN 
		  ,ICES_RESPONDENTS AS ICES_RESPONSES
		  ,ICES1 AS ICES_COURSE
		  ,ICES2 AS ICES_INSTRUCTOR
	INTO #_DM_Courses
	FROM dbo._UPLOADED_DM_SCHTEACH


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
					  ,CRN
					  ,ICES_COURSE
					  ,ICES_INSTRUCTOR
					  ,ICES_RESPONSES
					  				
				  FOR XML PATH('SCHTEACH'),TYPE
			)FOR XML PATH('Record'),ROOT('Data')

		)AS VARCHAR(MAX)) xml
	FROM #_DM_Courses
	)x
	ORDER BY username,o



IF @submit=1 BEGIN
	
	CREATE TABLE #requests(id INT NOT NULL,method VARCHAR(10),url VARCHAR(255),r INT)
	
	INSERT INTO dbo.webservices_requests(method,url,post,process)
	OUTPUT inserted.id,inserted.method,inserted.url,inserted.process INTO #requests
	SELECT m,u,CAST(post AS VARCHAR(MAX)),r FROM #updates WHERE post IS NOT NULL

	UPDATE dbo.webservices_requests SET process=NULL,dependsOn=(
		SELECT TOP 1 id FROM #requests r2 JOIN #updates u2 ON u2.r=r2.r
		WHERE u2.o<u1.o AND u2.username=u1.username ORDER BY u2.o DESC)
	FROM dbo.webservices_requests
	JOIN #requests r1 ON r1.id=dbo.webservices_requests.id
	JOIN #updates u1 ON u1.r=r1.r
	
	DROP TABLE #requests
END
ELSE
BEGIN
	--SELECT  username,DELIVERY_MODE FROM #_DM_Courses
	SELECT * FROM #updates
END

DROP TABLE #updates

-- EXEC dbo.produce_XML_afrom_UPLOADED_SCHTEACH_INITIAL @submit = 0
-- EXEC dbo.produce_XML_afrom_UPLOADED_SCHTEACH_INITIAL @submit = 1
END


GO
