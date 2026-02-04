SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 12/5/2018:
--	Taken from produce_XML_PCI_current
--	This SP was specially used to update fields on current PCI screen at DM that are not consistent with FSDB
--		EXEC dbo.produce_XML_PCI_current_special @submit = 0
--		EXEC dbo.produce_XML_PCI_current_special @submit = 1
--		EXEC dbo.webservices_run_DTSX
CREATE PROC [dbo].[produce_XML_PCI_current_special] ( @submit BIT=0 )
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

	-- UPDATE PCI screen of current users on Banner names, ethnicity, citizenship, gender, and doctoral status
	SELECT  username
			--,PREFIX
			,FNAME
			,MNAME
			,LNAME
			,GENDER 
			,ETHNICITY
			,CITIZEN
			,dbo.Get_Profile_URL(username) as Profile_URL		-- used when we have _UPLOADED_DM_PCI as the table source
			--,PROFILE_URL			-- used when we have _UPLOAD_DM_PCI as the table source
			,STAFF_CLASS
			,CASE WHEN [RANK] LIKE '%Unknown%' THEN '' ELSE [RANK] END as [RANK]
			,DOC_STATUS
			,DOC_DEPT
			,DOC_TERM	
			,SHOW_COLLEGE
			 --,'Yes' as SHOW_PHOTO
			 --,'Yes' as SHOW_CV
			 --,'Yes' as SHOW_DEPT
			 --,'Yes' as SHOW_COLLEGE
			 --,'Yes' as SHOW_PROFILE

			,FACSTAFFID
			,EDWPERSID
			,PFNAME
			,PMNAME
			,PLNAME
			,ACTIVE
			,DTM_DOB
			,DTD_DOB
			,DTY_DOB
						
			,EMAIL			
			--,BUS_PERSON
			,BUS_FACULTY
		INTO #pci_basic_data
		-- produced by DM_Shadow_Staging.dbo.DailyUpdate_sp_DM_Step06_Update_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees
		FROM dbo._UPLOADED_DM_PCI pci	
		-- produced by Faculty_Staff_Holder.dbo.__DM_Excel_PCI 			
		--FROM dbo._UPLOADED_DM_PCI pci			
		WHERE USERNAME IN (SELECT USERNAME FROM _DM_PCI WHERE USERNAME <> '')		
		-- ADD custom filter if needed for some naual upload works
		--AND [RANK] like '%unknown%'		
		--AND ACTIVE='Yes'
		--AND [SHOW_COLLEGE]='No'
		AND STAFF_CLASS like '%graduate assistant%'
		

	UPDATE #pci_basic_data
	SET FNAME = replace(replace(replace(replace(replace(replace(
					replace(replace(replace(FNAME, char(9), ' '), char(10), ' '), char(13), ' '), 
					'     ', ' '), '    ', ' '), '   ', ' '), '  ', ' '), '- ', '-'), ' -', '-')

		,LNAME = replace(replace(replace(replace(replace(replace(
						replace(replace(replace(LNAME, char(9), ' '), char(10), ' '), char(13), ' '), 
						'     ', ' '), '    ', ' '), '   ', ' '), '  ', ' '), '- ', '-'), ' -', '-')


SELECT method m,url u,xml post, username, o,ROW_NUMBER()OVER(ORDER BY username,o,url)r
INTO #updates
FROM (
	-- Fill in their Personal Information
	 --SELECT username,3 o,'POST' method,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:'+username+'/PCI' url,
	 SELECT username,3 o,'POST' method,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business' url,
		CAST((
			--SELECT NETID "@username",(SELECT
			--	FirstName FNAME,
			--	LastName LNAME
			--	FOR XML PATH('PCI'),TYPE
			--)FOR XML PATH('Record'),ROOT('Data')

			SELECT username "@username", (SELECT
					  FNAME
					  ,MNAME
					  ,LNAME
					  ,GENDER
					  ,ETHNICITY
					  ,CITIZEN
					  ,PROFILE_URL
					  ,STAFF_CLASS
					  ,[RANK]
					  ,DOC_STATUS
					  ,DOC_DEPT
					  ,DOC_TERM

					  --,SHOW_PHOTO
					  --,SHOW_CV
					  --,SHOW_DEPT
					  ,SHOW_COLLEGE
					  --,SHOW_PROFILE

					  --,FACSTAFFID
					  --,EDWPERSID

					  ,PFNAME
					  ,PMNAME
					  ,PLNAME
					  ,ACTIVE
					  ,DTM_DOB
					  ,DTD_DOB
					  ,DTY_DOB
					  ,EMAIL			
					  --,BUS_PERSON
					  ,BUS_FACULTY
					 
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

-- EXEC dbo.produce_XML_PCI_current_special @submit = 0
-- EXEC dbo.produce_XML_PCI_current_special @submit = 1
-- EXEC dbo.webservices_run_DTSX
END
GO
