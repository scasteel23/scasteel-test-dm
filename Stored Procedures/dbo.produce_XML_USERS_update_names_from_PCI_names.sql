SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 3/31/2019 UPDATE USERS'names from PCI names
/*
-- Scott's on 3/29/2019  10:50 PM
After using WS to test making changes for Jan's name, 

I realized that the refresh should update USERS name fields (First_Name, Middle_Name, Last_Name). 
Updating NAME fields on PCI would work for feed to SF, but not for the rest of DM.  
The names used in DM  in Author DDLs, in the "You are currently managing data for Jan Slater" message, 
in lists to select users for reports are all based on USERS, not PCI. 

Updating names in USERS seems to automatically update the NAME fields on PCI, but not the other way around. 

*/

/*
 Manual run to upload select USERS (depending on queries to select those users) FROM FSDB
	 EXEC dbo.[produce_XML_USERS_update_names_from_PCI_names] @submit = 0

	 EXEC dbo.[produce_XML_USERS_update_names_from_PCI_names] @submit = 1
	 EXEC dbo.webservices_run_DTSX
*/

CREATE PROC [dbo].[produce_XML_USERS_update_names_from_PCI_names] ( @submit BIT=0 )
AS

BEGIN

	WITH names_from_pci AS (
	
		select du.username, du.FacstaffID, du.userid
		   , dv.lname, dv.fname, dv.mname	   
		from DM_Shadow_Staging.dbo._DM_USERS du
				left outer join DM_Shadow_Staging.dbo._DM_PCI dv
				on dv.username = du.username
		where du.username is not null
			   and (dv.fname <> du.First_Name 
					  or dv.mname <> du.Middle_Name
					  or dv.lname <> du.Last_Name)
			   and du.enabled_indicator = 1
			   and du.service_account_indicator = 0
	)


	-->>>>>>>>>>>>>>>>>> UPDATE  USERS

	--SELECT USERNAME u,1 o,'PUT' m,'/login/service/v4/User/USERNAME:'+username url,
	--		'<User FirstName="' + FNAME + '" MiddleName="' +  MNAME + '" LastName="' +  LNAME + '"></User>' post,
	--		ROW_NUMBER()OVER(ORDER BY USERNAME)r
	--INTO #updates
	--FROM names_from_pci

	SELECT USERNAME u,1 o,'PUT' m,'/login/service/v4/User/USERNAME:'+username url,
		CAST((SELECT USERNAME "@username",
			LName as LastName,
			mName as MiddleName,
			fname as  FirstName
		FOR XML PATH('User'),TYPE)AS VARCHAR(max)) post,
		ROW_NUMBER()OVER(ORDER BY USERNAME)r
	INTO #updates
	FROM names_from_pci


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
	
		--SELECT TOP 100 * FROM dbo.webservices_requests ORDER BY id DESC
		DROP TABLE #requests
		
		-- DOWNLOAD USERS INTO _DM_USERS
		EXEC dbo.webservices_initiate @screen='USERS'

	END
		ELSE SELECT * FROM #updates

	DROP TABLE #updates


	--EXEC dbo.webservices_initiate @screen='USERS'	



END


GO
