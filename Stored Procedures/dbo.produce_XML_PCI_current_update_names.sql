SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 3/22/2019 
--		DM_Shadow_Staging.dbo.FSDB_facstaff_Basic has no professional_last_name and mname
--		rerun with names in faculty_staff_holder.dbo.facstaff_Basic
-- NS 3/20/2019 run with names in DM_Shadow_Staging.dbo.FSDB_facstaff_Basic
CREATE PROC [dbo].[produce_XML_PCI_current_update_names] ( @submit BIT=0 )
AS

/*
	TEST
	EXEC dbo.[produce_XML_PCI_current_update_names] @submit=0

	RUN MANUALLY
	EXEC dbo.[produce_XML_PCI_current_update_names] @submit=1
	EXEC dbo.webservices_run_DTSX

*/

BEGIN

	SELECT  username
			,CASE WHEN fb.PERS_PREFERRED_FNAME IS not null AND RTRIM(fb.PERS_PREFERRED_FNAME) <> '' THEN fb.PERS_PREFERRED_FNAME
				  ELSE First_Name END FNAME			
			,CASE WHEN fb.Middle_Name IS not null AND RTRIM(fb.Middle_Name) <> '' THEN fb.Middle_Name
				  ELSE MNAME END MNAME	
			,CASE WHEN fb.Professional_Last_Name IS not null AND RTRIM(fb.Professional_Last_Name) <> '' THEN fb.Professional_Last_Name
				  ELSE Last_Name END LNAME		
			,'' AS PFNAME
			,'' AS PMNAME
			,'' AS PLNAME

	INTO #pci_basic_data
		-- produced by DM_Shadow_Staging.dbo.DailyUpdate_sp_DM_Step06_Update_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees
	FROM Faculty_Staff_holder.dbo.facstaff_Basic fb
			INNER JOIN dbo._DM_PCI usr
			ON fb.Network_ID = usr.username						

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
					
					  ,PFNAME
					  ,PMNAME
					  ,PLNAME
					 
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

END
GO
