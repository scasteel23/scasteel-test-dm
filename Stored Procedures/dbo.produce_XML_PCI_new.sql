SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 8/22/2017: Revised using the new _UPLOAD_DM_PCI table
-- NS 3/27/2017: last rerun successfully
-- NS 6/27/2016: Start playing with this SP
CREATE PROC [dbo].[produce_XML_PCI_new] ( @submit BIT=0 )
AS

--	Add PCI screen of new users

--IF EXISTS (
--	SELECT 1
--	FROM dbo.webservices_requests
--	WHERE url LIKE '%/User/%'
--	HAVING -- last shadowed < last refreshed
--	MAX(CASE WHEN method='GET' AND processed IS NOT NULL THEN initiated ELSE NULL END) < MAX(CASE WHEN method<>'GET' THEN created ELSE NULL END)
--) RAISERROR('This data has not been shadowed since the last refresh.',18,1);
--ELSE 

BEGIN

	--drop table #pci_basic_data
	print 'start produce_XML_PCI_new';
	SELECT  USERNAME
			--,PREFIX
			,FNAME
			,PFNAME
			,MNAME
			,PMNAME
			,LNAME
			,PLNAME
		
			,FNAME as BANNER_FNAME
			,MNAME as BANNER_MNAME
			,LNAME as BANNER_LNAME

			--,SUFFIX
			--,ALT_NAME
			,EMAIL
			--,WEBSITE
		    ,DTM_DOB
			,DTD_DOB
			,DTY_DOB
			,GENDER 
			,ETHNICITY
			,CITIZEN

		    ,'Yes' as SHOW_PHOTO
		    ,'Yes' as SHOW_CV
		    ,'Yes' as SHOW_DEPT
		    ,'Yes' as SHOW_COLLEGE
		    ,'Yes' as SHOW_PROFILE

			,PROFILE_URL			
			--,STAFF_CLASS
			--,CASE WHEN [RANK] LIKE '%Unknown%' THEN '' ELSE [RANK] END as [RANK]
			,DOC_STATUS
			,DOC_DEPT
			,DOC_TERM
			--,dbo.Get_PROFILE_URL(u.username) as PROFILE_URL		
			--,BUS_PERSON
			,BUS_FACULTY
			,'Yes' AS ACTIVE
		INTO #pci_basic_data
		FROM dbo._UPLOAD_DM_PCI pci			
		WHERE Record_Status = 'NEW'
			AND username NOT IN (SELECT USERNAME FROM _DM_PCI WHERE USERNAME is not NULL)
			--AND username IN (SELECT USERNAME FROM _DM_USERS WHERE USERNAME is not NULL AND Enabled_Indicator=1)
				
	-- remove extra spaces
	UPDATE #pci_basic_data
	SET FNAME = replace(replace(replace(replace(replace(replace(
					replace(replace(replace(FNAME, char(9), ' '), char(10), ' '), char(13), ' '), 
					'     ', ' '), '    ', ' '), '   ', ' '), '  ', ' '), '- ', '-'), ' -', '-')

		,PFNAME = replace(replace(replace(replace(replace(replace(
						replace(replace(replace(PFNAME, char(9), ' '), char(10), ' '), char(13), ' '), 
						'     ', ' '), '    ', ' '), '   ', ' '), '  ', ' '), '- ', '-'), ' -', '-')

		,LNAME = replace(replace(replace(replace(replace(replace(
						replace(replace(replace(LNAME, char(9), ' '), char(10), ' '), char(13), ' '), 
						'     ', ' '), '    ', ' '), '   ', ' '), '  ', ' '), '- ', '-'), ' -', '-')

		,PLNAME = replace(replace(replace(replace(replace(replace(
						replace(replace(replace(PLNAME, char(9), ' '), char(10), ' '), char(13), ' '), 
						'     ', ' '), '    ', ' '), '   ', ' '), '  ', ' '), '- ', '-'), ' -', '-')

		,EMAIL = replace(replace(replace(replace(replace(replace(
						replace(replace(replace(EMAIL, char(9), ' '), char(10), ' '), char(13), ' '), 
						'     ', ' '), '    ', ' '), '   ', ' '), '  ', ' '), '- ', '-'), ' -', '-')

	UPDATE #pci_basic_data
	SET BANNER_FNAME = FNAME,BANNER_MNAME = MNAME,BANNER_LNAME = LNAME


		--,TEACHING_INTERESTS = replace(replace(replace(replace(replace(replace(
		--				replace(replace(replace(TEACHING_INTERESTS, char(9), ' '), char(10), ' '), char(13), ' '), 
		--				'     ', ' '), '    ', ' '), '   ', ' '), '  ', ' '), '- ', '-'), ' -', '-')
		--,RESEARCH_INTERESTS = replace(replace(replace(replace(replace(replace(
		--				replace(replace(replace(RESEARCH_INTERESTS, char(9), ' '), char(10), ' '), char(13), ' '), 
		--				'     ', ' '), '    ', ' '), '   ', ' '), '  ', ' '), '- ', '-'), ' -', '-')



/* 
	select * from current_employees
	SELECT  u.username
			--,PREFIX
			,FNAME
			,PFNAME
			,MNAME
			,PMNAME
			,LNAME
			,PLNAME
			--,SUFFIX
			--,ALT_NAME
			,EMAIL
			--,WEBSITE
			,DOB_START
			,CASE WHEN GENDER='M' THEN 'Male' ELSE 'Female' END as GENDER 
			,ETHNICITY
			,CITIZEN
			,RESEARCH_INTERESTS
			--,BIO
			--,EMERGENCY_CONTACT
			,CASE WHEN SHOW_PHOTO=1 THEN 'Yes' ELSE 'No' END as SHOW_PHOTO
			,SSRN_ID
			,GOOGLE_SCHOLAR_ID
			,CASE WHEN SHOW_COLLEGE=1 THEN 'Yes' ELSE 'No' END as SHOW_COLLEGE 
			,CASE WHEN SHOW_DEPT=1 THEN 'Yes' ELSE 'No' END as SHOW_DEPT 
			,CASE WHEN SHOW_PROFILE=1 THEN 'Yes' ELSE 'No' END as SHOW_PROFILE 
			,CASE WHEN SHOW_CV=1 THEN 'Yes' ELSE 'No' END as SHOW_CV
			,TEACHING_INTERESTS
			,dbo.Get_PROFILE_URL(u.username) as PROFILE_URL
			,surveyId
			,UPLOAD_CV
		FROM dbo._UPLOADED_DM_PCI pci
				Inner JOIN dbo._DM_USERS u
				ON pci.Facstaffid=u.FacstaffID
				
	*/

SELECT method m,url u,xml post, username, o,ROW_NUMBER()OVER(ORDER BY username,o,url)r
INTO #updates
FROM (
	-- Fill in their Personal Information
	 SELECT username,3 o,'POST' method,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:'+username+'/PCI' url,
		CAST((
			--SELECT NETID "@username",(SELECT
			--	FirstName FNAME,
			--	LastName LNAME
			--	FOR XML PATH('PCI'),TYPE
			--)FOR XML PATH('Record'),ROOT('Data')

			SELECT username "@username", (SELECT
					  FNAME
					  ,PFNAME
					  ,MNAME
					  ,PMNAME
					  ,LNAME
					  ,PLNAME
					  ,BANNER_FNAME
					  ,BANNER_MNAME
					  ,BANNER_LNAME
					  ,EMAIL
					  ,DTM_DOB
					  ,DTD_DOB
					  ,DTY_DOB
					  ,GENDER
					  ,ETHNICITY
					  ,CITIZEN
					  ,SHOW_PHOTO
					  ,SHOW_CV
					  ,SHOW_DEPT
					  ,SHOW_COLLEGE
					  ,SHOW_PROFILE
					  ,PROFILE_URL
					  --,STAFF_CLASS
					  --,[RANK]
					  ,DOC_STATUS
					  ,DOC_DEPT
					  ,DOC_TERM
					  --,BUS_PERSON
					  ,BUS_FACULTY
					  ,ACTIVE
				
				  FOR XML PATH('PCI'),TYPE
			)FOR XML PATH('Record'),ROOT('Data')

		)AS VARCHAR(MAX)) xml
	FROM #pci_basic_data
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
ELSE SELECT * FROM #updates

DROP TABLE #updates

-- EXEC dbo.produce_XML_PCI_new @submit = 0
-- EXEC dbo.produce_XML_PCI_current @submit = 0

/*
	DECLARE @Result varchar(1000)
	EXEC dbo.produce_XML_PCI_new @submit = 1
	EXEC dbo.webservices2_run @Result = @Result OUTPUT 

	DECLARE @Result varchar(1000)
	EXEC dbo.produce_XML_PCI_current @submit = 1
	EXEC dbo.webservices2_run @Result = @Result OUTPUT 
*/

END
GO
