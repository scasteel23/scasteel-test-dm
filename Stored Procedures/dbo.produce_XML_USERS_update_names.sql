SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 3/31/2019 UPDATE USERS'names 

/*
 Manual run to upload select USERS (depending on queries to select those users) FROM FSDB
	 EXEC dbo.[produce_XML_USERS_update_names_from_PCI_names] @submit = 0

	 EXEC dbo.[produce_XML_USERS_update_names_from_PCI_names] @submit = 1
	 EXEC dbo.webservices_run_DTSX
*/

CREATE PROC [dbo].[produce_XML_USERS_update_names] ( @submit BIT=0 )
AS

BEGIN
	
	SELECT  username
			,FNAME
			,MNAME
			,LNAME
	INTO #users_basic_data
		-- produced by DM_Shadow_Staging.dbo.DailyUpdate_sp_DM_Step06_Update_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees
	FROM DM_Shadow_Staging.dbo._DM_PCI_For_Name_Update pci	
	WHERE USER_Update_Name='Yes'

	DECLARE @updated_names varchar(2000)
	SELECT  @updated_names = COALESCE(@updated_names + ',','') + username + ' : ' + FNAME + ' ' + MNAME + ' ' + lname
	FROM #users_basic_data

	PRINT 'UPDATE PCI P-NAMES : ' + ISNULL(@updated_names,'')

	UPDATE #users_basic_data
	SET FNAME = replace(replace(replace(replace(replace(replace(
					replace(replace(replace(FNAME, char(9), ' '), char(10), ' '), char(13), ' '), 
					'     ', ' '), '    ', ' '), '   ', ' '), '  ', ' '), '- ', '-'), ' -', '-')

		,LNAME = replace(replace(replace(replace(replace(replace(
						replace(replace(replace(LNAME, char(9), ' '), char(10), ' '), char(13), ' '), 
						'     ', ' '), '    ', ' '), '   ', ' '), '  ', ' '), '- ', '-'), ' -', '-')

		,MNAME = replace(replace(replace(replace(replace(replace(
						replace(replace(replace(MNAME, char(9), ' '), char(10), ' '), char(13), ' '), 
						'     ', ' '), '    ', ' '), '   ', ' '), '  ', ' '), '- ', '-'), ' -', '-')


	 -->>>>>>>>>>>>>>>>>> UPDATE  USERS
	--SELECT USERNAME u,1 o,'PUT' m,'/login/service/v4/User/USERNAME:'+username url,
	--		'<User FirstName="' + FNAME + '" MiddleName="' +  MNAME + '" LastName="' +  LNAME + '"></User>' post,
	--		ROW_NUMBER()OVER(ORDER BY USERNAME)r
	--INTO #updates
	--FROM #users_basic_data

	SELECT USERNAME u,1 o,'PUT' m,'/login/service/v4/User/USERNAME:'+username url,
		CAST((SELECT USERNAME "@username",
			LName as LastName,
			mName as MiddleName,
			fname as  FirstName
		FOR XML PATH('User'),TYPE)AS VARCHAR(max)) post,
		ROW_NUMBER()OVER(ORDER BY USERNAME)r
	INTO #updates
	FROM #users_basic_data



	IF @submit=1 BEGIN
	
		CREATE TABLE #requests(id INT NOT NULL,method VARCHAR(10),url VARCHAR(255),r INT)
	
		INSERT INTO webservices_requests(method,url,post,process)
		OUTPUT inserted.id,inserted.method,inserted.url,inserted.process INTO #requests
		SELECT m,url,CAST(post AS VARCHAR(MAX)),r FROM #updates WHERE post IS NOT NULL

		UPDATE webservices_requests SET process=NULL,dependsOn=(
			SELECT TOP 1 id FROM #requests r2 JOIN #updates u2 ON u2.r=r2.r
			WHERE u2.o<u1.o AND u2.u=u1.u ORDER BY u2.o DESC)
		FROM webservices_requests
		JOIN #requests r1 ON r1.id=webservices_requests.id
		JOIN #updates u1 ON u1.r=r1.r

		DROP TABLE #requests
		
		-- DOWNLOAD USERS INTO _DM_USERS
		EXEC dbo.webservices_initiate @screen='USERS'

	END
		ELSE SELECT * FROM #updates

	DROP TABLE #updates


	--EXEC dbo.webservices_initiate @screen='USERS'	



END


GO
