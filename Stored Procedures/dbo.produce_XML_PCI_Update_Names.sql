SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 3/31/2019:
-- Reset PFNAME, FLNAME, PMNAME fom DM_Shadow_Staging.dbo._DM_PCI_For_Name_Update Where PCI_Reset_PName='Yes'
-- This SP relies on DM_Shadow_Staging.dbo._DM_PCI_For_Name_Update table
--	that has been prepared by dbo.DailyUpdate_sp_Hourly_Update_Names_From_Preferred_Name procedure
-- Do this every hour
--		EXEC dbo.produce_XML_PCI_Update_Names @submit = 0
--		EXEC dbo.produce_XML_PCI_Update_Names @submit = 1
--		EXEC dbo.webservices_run_DTSX
CREATE PROC [dbo].[produce_XML_PCI_Update_Names] ( @submit BIT=0 )
AS


BEGIN

	
	IF (SELECT COUNT(*) FROM DM_Shadow_Staging.dbo._DM_PCI_For_Name_Update WHERE PCI_Reset_PName='Yes') > 0

		BEGIN
			-- UPDATE PCI screen of current users on Banner names, ethnicity, citizenship, gender, and doctoral status
			DECLARE @updated_names varchar(2000)
			SELECT  @updated_names = COALESCE(@updated_names + ',','') + username
			FROM DM_Shadow_Staging.dbo._DM_PCI_For_Name_Update 	
			WHERE PCI_Reset_PName='Yes'

			PRINT 'UPDATE PCI P-NAMES : ' + ISNULL(@updated_names,'')

			SELECT  username
					,FNAME
					,MNAME
					,LNAME
					--,PFNAME
					--,PMNAME
					--,PLNAME
			INTO #pci_basic_data
				-- produced by DM_Shadow_Staging.dbo.DailyUpdate_sp_DM_Step06_Update_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees
			FROM DM_Shadow_Staging.dbo._DM_PCI_For_Name_Update pci	
			WHERE PCI_Reset_PName='Yes'

			UPDATE #pci_basic_data
			SET FNAME = replace(replace(replace(replace(replace(replace(
							replace(replace(replace(FNAME, char(9), ' '), char(10), ' '), char(13), ' '), 
							'     ', ' '), '    ', ' '), '   ', ' '), '  ', ' '), '- ', '-'), ' -', '-')

				,LNAME = replace(replace(replace(replace(replace(replace(
								replace(replace(replace(LNAME, char(9), ' '), char(10), ' '), char(13), ' '), 
								'     ', ' '), '    ', ' '), '   ', ' '), '  ', ' '), '- ', '-'), ' -', '-')

				,MNAME = replace(replace(replace(replace(replace(replace(
								replace(replace(replace(MNAME, char(9), ' '), char(10), ' '), char(13), ' '), 
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
								  --FNAME
								  --,MNAME
								  --,LNAME
								  --'' as PFNAME
								  --,'' as PMNAME
								  --,'' as PLNAME					 
								  FNAME as PFNAME
								  ,MNAME as PMNAME
								  ,LNAME as PLNAME					 
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

				EXEC dbo.webservices_initiate @screen='PCI'
			END
			ELSE SELECT * FROM #updates

			DROP TABLE #updates

			--EXEC dbo.webservices_run_DTSX
		END
	ELSE
		PRINT 'NO NAME UPDATE '
END


GO
