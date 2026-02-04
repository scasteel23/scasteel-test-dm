SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 5/23/2019

CREATE PROC [dbo].[DailyUpdate_sp_Hourly_Check_Keep_Active_No]  ( @submit BIT=0 )

AS
	-- How to manually run
	-- Test
	-- EXEC dbo.[DailyUpdate_sp_Hourly_Check_Keep_Active_No] @submit=0
	-- Production
	-- EXEC dbo.[DailyUpdate_sp_Hourly_Check_Keep_Active_No] @submit=1

	DECLARE @Result varchar(500)

	-- Refresh PCI, ADMIN and USER screen shadow data
	EXEC dbo.webservices_initiate @screen='USERS'
	EXEC dbo.webservices_initiate @screen='ADMIN'
	EXEC dbo.webservices2_run @Result = @Result OUTPUT

	SELECT m1.username, ISNULL(m1.KEEP_ACTIVE,'') as KEEP_ACTIVE, m1.AC_YEAR
	INTO #Latest_Keep_Inactive
	FROM DM_Shadow_Staging.dbo._DM_ADMIN m1
			LEFT JOIN DM_Shadow_Staging.dbo._DM_ADMIN m2
			ON m1.USERNAME = m2.USERNAME  AND m1.AC_YEAR < m2.AC_YEAR
				AND m1.USERNAME is not NULL		
	WHERE m2.AC_YEAR is NULL AND m1.KEEP_ACTIVE='NO' AND m1.USERNAME is not null
			AND m1.USERNAME  IN (SELECT USERNAME FROM dbo._DM_USERS WHERE Enabled_Indicator=1)


	SELECT method m,url u,xml post, NETID,o,ROW_NUMBER()OVER(ORDER BY NETID,o,url)r
	INTO #deactivates
	FROM (

		---- Deactivate users
		SELECT b.username as NETID,1 o,'PUT'method,'/login/service/v4/User/USERNAME:'+b.username url,
			'<User enabled="false"></User>' xml
		FROM #Latest_Keep_Inactive b
		WHERE b.username not IN ('mpainter','nhadi','scasteel','jonker')

	)x
	ORDER BY NETID,o

	DECLARE @cc as INT
	SELECT @cc = count(*)
	FROM #deactivates

	IF @submit=1 BEGIN
		--	DO NOT deactivate any users when there are 30 or more deactivated.
		--	This is to guard unexpected datavase corruption or errors
		--	Batch deactivation for stident workers will be done separately

		IF @cc < 50  BEGIN	

			CREATE TABLE #requests(id INT NOT NULL,method VARCHAR(10),url VARCHAR(255),r INT)
	
			INSERT INTO webservices_requests(method,url,post,process)
			OUTPUT inserted.id,inserted.method,inserted.url,inserted.process INTO #requests
			SELECT m,u,CAST(post AS VARCHAR(MAX)),r 
			FROM #deactivates 
			WHERE post IS NOT NULL

			UPDATE webservices_requests SET process=NULL,dependsOn=(
				SELECT TOP 1 id FROM #requests r2 JOIN #deactivates u2 ON u2.r=r2.r
				WHERE u2.o<u1.o AND u2.NETID=u1.NETID ORDER BY u2.o DESC)
			FROM webservices_requests
			JOIN #requests r1 ON r1.id=webservices_requests.id
			JOIN #deactivates u1 ON u1.r=r1.r

			DROP TABLE #requests

			EXEC dbo.webservices_initiate @screen='USERS'

			EXEC dbo.webservices2_RUN @Result = @Result OUTPUT

		END
	
	END
	ELSE SELECT * FROM #deactivates

	DROP TABLE #deactivates





	




GO
