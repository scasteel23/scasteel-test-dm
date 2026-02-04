SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 11/18/2018
--		PART_1 records >= '2013'
--		PART_2 records < '2013'
--		Must Run faculty_Staff_Holder.dbo.__DM_Excel_SCHTEACH first
--		Pull from _UPLOADED_DM_SCHTEACH table and create XML to upload to DM
--
-- NS 9/28/2017
-- MUST SEE  Faculty_Staff_Holder.dbo._Adhoc_sp_DM_Create_BUS_COURSES_EDW_and_BUS_ICES_Part1
--	and Faculty_Staff_Holder.dbo._Adhoc_sp_DM_Create_BUS_COURSES_EDW_and_BUS_ICES_Part2

CREATE PROC [dbo].[produce_XML_SCHTEACH_FROM_FSDB_PART_2] ( @submit BIT=0 )
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

	/*
		ICES scores are not uploaded
		BUS_ICES table holds Courses with ICES scores from 120008, COURSE_DETAILS holds all courses from 120178
		Not all courses has ICES scores
		CRS_SUBJ_CD and CRS_NBR from BUS_ICES table may match with those from COURSE_DETAILS, but SECT_NBR may not

		Run this to see the message Body to upload to SCHTEACH
		EXEC dbo.produce_XML_SCHTEACH_FROM_FSDB_PART_1 @submit = 0

		Run this to update SCHTEACH
		EXEC dbo.produce_XML_SCHTEACH_FROM_FSDB_PART_1 @submit = 1
		EXEC dbo.webservices_run_DTSX

		EXEC dbo.produce_XML_SCHTEACH_FROM_FSDB_PART_2 @submit = 1
		EXEC dbo.webservices_run_DTSX

		 */

	-- >>>>>>>>>>>>>>>>>>>>>   Generate XML and insert into the queue webservices_requests table
		
	SELECT  username
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
		  ,CRN
		  		 
	INTO #_DM_Courses
	FROM dbo._UPLOADED_DM_SCHTEACH courses
	WHERE TYY_TERM < '2013'
			--Inner JOIN dbo._DM_USERS u
			--ON courses.username=u.username


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
					  --,ICES_Responses 
					  --,ICES_COURSE 
					  --,ICES_INSTRUCTOR 
					  				
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
	--SELECT * FROM #_DM_Courses
	SELECT * FROM #updates
END

DROP TABLE #updates



END

GO
