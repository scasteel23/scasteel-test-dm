SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- NS 10/20/2016
CREATE PROC [dbo].[produce_XML_afrom_UPLOADED_PROFILE] ( @submit BIT=0 )
AS

BEGIN
		--  @submit=1 compose the PUT request and a a record to the webservices_requests table to be processed by the SSIS package
		--	@submit=10 compose the PUT request and display the request  
		WITH pci_bio AS (
			SELECT  FB.Network_ID as USERNAME	
					,RESEARCH_INTERESTS
					,ISNULL(FBO.Biographical_Sketch,'') as BIO_SKETCH
					,TEACHING_INTERESTS
		
			FROM Faculty_Staff_Holder.dbo.Facstaff_Basic FB
			LEFT OUTER JOIN Faculty_Staff_Holder.dbo.Facstaff_Bio_Sketch FBO
			ON FB.Facstaff_ID = FBO.Facstaff_ID
			WHERE BUS_Person_Indicator=1
						AND first_name is not NULL
						AND last_name is not NULL
						AND FB.EDW_PERS_ID is not NULL
						AND FB.Facstaff_ID In (SELECT FacstaffID FROM DM_Shadow_Staging.dbo._DM_USERS WHERE FacstaffID <> 0)
						)

		--select * from current_employees

		SELECT method m,url u,xml post, username, o,ROW_NUMBER()OVER(ORDER BY username,o,url)r
		INTO #updates
		FROM (
			-- Fill in their Personal Information
			 SELECT username,3 o,'POST' method,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:'+username+'/PROFILE' url,
				CAST(
					(SELECT username "@username", (SELECT
							 replace(replace(replace(replace(replace(replace(
									replace(replace(replace(BIO_SKETCH, char(9), ' '), char(10), ' '), char(13), ' '), 
									'     ', ' '), '    ', ' '), '   ', ' '), '  ', ' '), '- ', '-'), ' -', '-') as BIO_SKETCH,
							 replace(replace(replace(replace(replace(replace(
									replace(replace(replace(RESEARCH_INTERESTS, char(9), ' '), char(10), ' '), char(13), ' '), 
									'     ', ' '), '    ', ' '), '   ', ' '), '  ', ' '), '- ', '-'), ' -', '-') as RESEARCH_INTERESTS,
							 replace(replace(replace(replace(replace(replace(
									replace(replace(replace(TEACHING_INTERESTS, char(9), ' '), char(10), ' '), char(13), ' '), 
									'     ', ' '), '    ', ' '), '   ', ' '), '  ', ' '), '- ', '-'), ' -', '-') as TEACHING_INTERESTS			
															
						 FOR XML PATH('PROFILE'),TYPE
					)FOR XML PATH('Record'),ROOT('Data')

				)AS VARCHAR(MAX)) xml
			FROM pci_bio
		)x
		ORDER BY username,o

	
		IF @submit=1 
			BEGIN
	
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
			SELECT * FROM #updates

		DROP TABLE #updates

-- EXEC dbo.produce_XML_afrom_UPLOADED_PROFILE @submit = 0
-- EXEC dbo.produce_XML_afrom_UPLOADED_PROFILE @submit = 1
END


GO
