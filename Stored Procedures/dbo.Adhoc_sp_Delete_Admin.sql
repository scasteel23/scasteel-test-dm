SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 3/12/2019
CREATE PROC [dbo].[Adhoc_sp_Delete_Admin] ( @submit BIT=0 )
AS

BEGIN

	-- EXEC dbo.[Adhoc_sp_Delete_Admin] @submit=0
	SELECT  id
			INTO #delete_ids
			FROM dbo._DM_ADMIN 
			WHERE AC_YEAR='2018-2019'

	DECLARE @delete_body as varchar(MAX)

	SELECT @delete_body = COALESCE(@delete_body,'') + '<item id="' + CAST([id] as varchar) + '"/> ' 
	FROM #delete_ids

	SET @delete_body='<Data><ADMIN>'+@delete_body+'</ADMIN></Data>'

	PRINT @delete_body

	SELECT 'DELETE' as m
		,'/login/service/v4/SchemaData:delete/INDIVIDUAL-ACTIVITIES-Business' as u
		,@delete_body as post
		,1 as r
	INTO #updates




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

	-- EXEC dbo.[Adhoc_sp_Delete_Admin] @submit = 0		-- test to see the post and the body
	-- EXEC dbo.[Adhoc_sp_Delete_Admin] @submit = 1		-- request to post
	-- EXEC DM_Shadow_Staging.dbo.webservices_run_DTSX	-- execute all webservices requests
	END

GO
