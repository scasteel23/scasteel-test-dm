SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 3/20/2018
CREATE PROC [dbo].[_1PHASE3_sp_produce_XML_USERS_Update_or_Add] 
(
	 @submit BIT=0 
	,@rowstart INT
	,@rowend INT
)
AS


/*
		On DM_Shadow_Staging, 
			_DM_USERS table is all Users in DM site 
			_UPLOAD_DM_USERS is all users to upload with different status of Record_Status, and Enabled_Indicator
	
		Create queues for
		1) NEW USERS			Record_Status = 'NEW' (users that are not in current DM yet)
		2) DEACTIVATE USERS		Record_Status = 'OUT' (users that are in current DM but in Upload DM)
								OR
								Record_Status = 'CUR' (users that are in current DM) but Enabled_Indicator=0 (need to disable)
		3) ACTIVATE USERS		Record_Status = 'CUR' (users that are in current DM) and Enabled_Indicator=1 (need to enable)
*/


BEGIN

	-- >>>>>>> 1) NEW USERS

	WITH new AS (
		SELECT  DMU.USERNAME
			    ,DMU.UIN
			    ,CAST(DMU.FACSTAFFID as varchar) as FACSTAFFID
			    ,CAST(DMU.EDWPERSID as varchar) as EDWPERSID 
				,DMU.DEP			
				,DMU.FIRST_NAME
				,DMU.MIDDLE_NAME
				,DMU.LAST_NAME
				,DMU.Record_Status
				,DMU.Seq
				,CASE WHEN DMU.Enabled_Indicator=1 THEN 'true' ELSE 'false' END as [Enabled]			
			FROM DM_Shadow_Staging.dbo._UPLOAD_DM_USERS	DMU 
			WHERE Record_Status = 'NEW'

	)
	
	SELECT method m,url u,xml post, USERNAME,o,ROW_NUMBER()OVER(ORDER BY USERNAME,o,url)r
	INTO #new
	FROM (
		
		-- Create new users
		SELECT USERNAME,2 o,'POST' method,'/login/service/v4/User/' url, 
			(SELECT USERNAME "@username", UIN "@UIN", [Enabled] "@enabled" , FacstaffID "@FacstaffID", EDWPERSID "@EDWPERSID",
				First_Name FirstName,Middle_Name MiddleName,Last_Name LastName,
				USERNAME+'@illinois.edu' Email,
				'' ShibbolethAuthentication
			FOR XML PATH('User')) xml
		FROM new
		--WHERE seq >= @rowstart AND seq <= @rowend

		UNION

		-- Assign new users to their department
		SELECT USERNAME,3 o,'POST' method,'/login/service/v4/UserSchema/USERNAME:'+USERNAME url,
			CAST((SELECT 
				CAST(YEAR(GETDATE())AS VARCHAR)+'-'+CAST(YEAR(GETDATE())+1 AS VARCHAR)AC_YEAR,
				(
					SELECT DEP
					-- NS 3/7/2017: <COLLEGE> is no longer working
					--SELECT 'Business' COLLEGE,'ED:  '+dept DEP
					---- DEBUG
					--SELECT 'ED: (external) Human & Community Development' DEP
					FOR XML PATH('ADMIN_DEP'),TYPE
				)
			FOR XML PATH('ADMIN'),ROOT('INDIVIDUAL-ACTIVITIES-Business'),TYPE)AS VARCHAR(999)) xml
			/* '<INDIVIDUAL-ACTIVITIES-University><ADMIN>'+
				'<AC_YEAR>'+CAST(YEAR(GETDATE())AS VARCHAR)+'-'+CAST(YEAR(GETDATE())+1 AS VARCHAR)+'</AC_YEAR><ADMIN_DEP>'+
					'<COLLEGE>Education</COLLEGE>'+
					'<DEP>ED:  '+d+'</DEP>'+
				'</ADMIN_DEP>'+
			'</ADMIN></INDIVIDUAL-ACTIVITIES-University>' */
		FROM new
		--WHERE seq >= @rowstart AND seq <= @rowend

		UNION

		-- Give them the "Faculty" security role
		SELECT USERNAME,3 o,'POST' method,'/login/service/v4/UserRole/USERNAME:'+USERNAME url,
			'<INDIVIDUAL-ACTIVITIES-Business-Faculty />' xml
		FROM new
		--WHERE seq >= @rowstart AND seq <= @rowend

		UNION

		-- Fill in their Personal Information
		--UNION SELECT NETID,3,'POST','/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:'+NETID+'/PCI',
		SELECT USERNAME,3 o,'POST' method,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business' url,
			CAST((
				SELECT USERNAME "@username",(SELECT
					First_Name FNAME,
					Middle_Name MNAME,
					Last_Name LNAME,
					USERNAME+'@illinois.edu' EMAIL
					FOR XML PATH('PCI'),TYPE
				)FOR XML PATH('Record'),ROOT('Data')
			)AS VARCHAR(MAX)) xml
		FROM new
		--WHERE seq >= @rowstart AND seq <= @rowend
		)x
	ORDER BY USERNAME,o


	-- DEACTIVATE USERS
	SELECT method m,url u,xml post, username,o,ROW_NUMBER()OVER(ORDER BY username,o,url)r
	INTO #deactivates
	FROM (

		---- Deactivate users
		SELECT username,1 o,'PUT'method,'/login/service/v4/User/USERNAME:'+username url,
			'<User enabled="false"></User>' xml
		FROM DM_Shadow_Staging.dbo._UPLOAD_DM_USERS	DMU 
		WHERE Record_Status = 'OUT' 
				OR (Record_Status = 'CUR' AND Enabled_Indicator=0)
	
	)x
	ORDER BY username,o

	-- ACTIVATE USERS
	SELECT method m,url u,xml post, username,o,ROW_NUMBER()OVER(ORDER BY username,o,url)r
	INTO #activates
	FROM (

		---- Activate users
		SELECT username,1 o,'PUT'method,'/login/service/v4/User/USERNAME:'+username url,
			'<User enabled="true"></User>' xml
		FROM DM_Shadow_Staging.dbo._UPLOAD_DM_USERS	DMU 
		WHERE (Record_Status = 'CUR' AND Enabled_Indicator=1)
	
	)x
	ORDER BY username,o

	IF @submit=1 BEGIN
	
		CREATE TABLE #requests(id INT NOT NULL,method VARCHAR(10),url VARCHAR(255),r INT)

	
		-- ADD NEW USERS 

		INSERT INTO webservices_requests(method,url,post,process)
		OUTPUT inserted.id,inserted.method,inserted.url,inserted.process INTO #requests
		SELECT m,u,CAST(post AS VARCHAR(MAX)),r FROM #new WHERE post IS NOT NULL

		UPDATE webservices_requests SET process=NULL,dependsOn=(
			SELECT TOP 1 id FROM #requests r2 JOIN #new u2 ON u2.r=r2.r
			WHERE u2.o<u1.o AND u2.USERNAME=u1.USERNAME ORDER BY u2.o DESC)
		FROM webservices_requests
		JOIN #requests r1 ON r1.id=webservices_requests.id
		JOIN #new u1 ON u1.r=r1.r
	
		-- USERS Deactivations
		TRUNCATE TABLE #requests
	
		INSERT INTO webservices_requests(method,url,post,process)
		OUTPUT inserted.id,inserted.method,inserted.url,inserted.process INTO #requests
		SELECT m,u,CAST(post AS VARCHAR(MAX)),r FROM #deactivates WHERE post IS NOT NULL

		UPDATE webservices_requests SET process=NULL,dependsOn=(
			SELECT TOP 1 id FROM #requests r2 JOIN #deactivates u2 ON u2.r=r2.r
			WHERE u2.o<u1.o AND u2.USERNAME=u1.USERNAME ORDER BY u2.o DESC)
		FROM webservices_requests
		JOIN #requests r1 ON r1.id=webservices_requests.id
		JOIN #deactivates u1 ON u1.r=r1.r

		-- USERS Activations
		TRUNCATE TABLE #requests
	
		INSERT INTO webservices_requests(method,url,post,process)
		OUTPUT inserted.id,inserted.method,inserted.url,inserted.process INTO #requests
		SELECT m,u,CAST(post AS VARCHAR(MAX)),r FROM #activates WHERE post IS NOT NULL

		UPDATE webservices_requests SET process=NULL,dependsOn=(
			SELECT TOP 1 id FROM #requests r2 JOIN #activates u2 ON u2.r=r2.r
			WHERE u2.o<u1.o AND u2.USERNAME=u1.USERNAME ORDER BY u2.o DESC)
		FROM webservices_requests
		JOIN #requests r1 ON r1.id=webservices_requests.id
		JOIN #activates u1 ON u1.r=r1.r

		DROP TABLE #requests
		
		EXEC dbo.webservices_run_DTSX
		-- UPDATE _DM_USERS after uploading the above
		EXEC dbo.webservices_initiate @screen='USERS'

	END
	ELSE 
		-- @submit=0 just show the result w/o queuing for DTSX to pick up

		SELECT 'NEW' as category, * FROM #new
		UNION
		SELECT 'ACTIVATE CURRENT DM' as category, * FROM #activates
		UNION
		SELECT 'DEACTIVATE CURRENT DM' as category, * FROM #deactivates
		ORDER BY category ASC

	DROP TABLE #new
	DROP TABLE #activates
	DROP TABLE #deactivates
	
	--IF @submit = 1
	--	EXEC dbo.webservices_run_DTSX
	
	--truncate table  webservices_requests


/* 
	NS 4/2/2018 3 PM Run The following
	EXEC dbo.[_1PHASE2_sp_produce_XML_USERS_Update_or_Add] @submit = 1, @rowstart=1, @rowend=2000
	EXEC dbo.webservices_run_DTSX

	Here is based on current _DM_USERS (just shadowed from DM around 4.30 PM 4/2/2018)
                540 enabled non-service accounts (same)
                1438 disabled non-service accounts (23 already in DM but not in _UPLOAD_DM_USERS)
                16 service accounts
	1994 total users (this includes 16 service accounts and those 23 users)

	Need to find out how to mark FT, PT, DOC, INS @ DM (do not recall yet)

*/
END


GO
