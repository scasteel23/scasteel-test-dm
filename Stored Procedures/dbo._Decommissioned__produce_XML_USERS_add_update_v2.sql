SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 5/22/2019 v2
-- NS 4/15/2019:
--		Prevented to re-activate records whose KEEP_ACTIVE='No' 
-- NS 3/25/2019 TO DO
--		Checked: new users, new admin_dep, new faculty role
--		Need to check: re-entry (enable existing users), update department, renew faculty role
--		PCI will be done in seperate SP
--
-- NS 3/20/2019 specially changed, original version is in [produce_XML_USERS_add_update_original]
-- NS 3/12/2019 added reentry_employees
-- NS 11/8-12/2018: Ran to update new users to DM based on Faculty_Staff_Holder.dbo.Facstaff_Basic data
-- STC 11/19/18 - IT dept name updated in FSDB, no longer need string replacement for DM
-- NS 9/27/2017: Added enabled
-- NS 8/17/2017: changed source of NEW EMPLOYEES from _DM_USERS table to _UPLOAD_DM_USERS table
--		source of Current Employees from FSDB_FACSTAFF_BASIC table to _DM_USERS table
-- NS 8/11/2017: reviewed, added EMAIL and MNAME at POST to PCI, dropped the use of USER table, 
--		fixed PUT syntax, created user deactivation on a seperate SP dbo.produce_XML_USERS_deactivate
--		Worked!
-- NS 5/30/2017: Use preferred first/professional last names in (l,f) USERS screen names
-- NS 3/8/2017: Reviewed
-- NS 9/16/2016: Resumed
-- NS 6/16/2016: Start playing with this SP
CREATE PROC [dbo].[_Decommissioned_produce_XML_USERS_add_update_v2] ( @submit BIT=0 )
AS

/*

	 1) UPDATE records OR ADD new records to USER screen, including RE-ENTRY
	 2) ADD new records to ADMIN screen with AC_YEAR='2018-2019'
	 3) ADD new records to PCI screens

	 Test the results
	 EXEC dbo.[produce_XML_USERS_add_update_v2] @submit = 0

	 Manual run to upload USERS FROM FSDB
	 DECLARE @Result varchar(2000)
	 EXEC dbo._1PHASE2_sp_DM_Upload_Update_or_Add_Users_From_Facstaff_Basic
	 EXEC dbo.[produce_XML_USERS_add_update] @submit = 1
	 EXEC dbo.webservices2_run @Result = @Result OUTPUT 

*/


--IF EXISTS (
--	SELECT 1
--	FROM dbo.webservices_requests
--	WHERE url LIKE '%/User/%'
--	HAVING -- last shadowed < last refreshed
--	MAX(CASE WHEN method='GET' AND processed IS NOT NULL THEN initiated ELSE NULL END) < MAX(CASE WHEN method<>'GET' THEN created ELSE NULL END)
--) RAISERROR('This data has not been shadowed since the last refresh.',18,1);
--ELSE 

BEGIN

	-- FIND status of KEEP_ACTIVE of the latest AC_YEAR, and from them just geet where KEEP_ACTIVE='NO'
	--	DO NOT reactivate (re-entry) those username even though BANNER includes them as GiesBusiness emps
	SELECT m1.username, ISNULL(m1.KEEP_ACTIVE,'') as KEEP_ACTIVE, m1.AC_YEAR
	INTO #Latest_Keep_Inactive
	FROM DM_Shadow_Staging.dbo._DM_ADMIN m1
			LEFT JOIN DM_Shadow_Staging.dbo._DM_ADMIN m2
			ON m1.USERNAME = m2.USERNAME  AND m1.AC_YEAR < m2.AC_YEAR
				AND m1.USERNAME is not NULL		
	WHERE m2.AC_YEAR is NULL AND m1.KEEP_ACTIVE='NO' AND m1.USERNAME is not null;

	-- SELECT * FROM #Latest_Keep_Inactive

	WITH new_and_updated_current_employees AS (
		-- >>>>> PRODUCTION !!

		-- The following codes should be on production, 
		-- Populate _UPLOAD_DM_USERS in Dbo.DailyUpdate_sp_DM_Step06_Update_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees
		--		_UPLOAD_DM_USERS has all current users in DM that has updated information from EDW as well
		--		all new users registered in EDW	
		--	
		SELECT  DMU.USERNAME
				,DMU.UIN
				,CAST(DMU.FACSTAFFID as varchar) as FACSTAFFID
				,CAST(DMU.EDWPERSID as varchar) as EDWPERSID 
				--,DMU.DEP
				--,ISNULL(REPLACE(D.Department_Name,'IT Partners','Business IT Services'),'') as DEP 
				,DMU.DEP as DEP
				,DMU.FIRST_NAME,DMU.MIDDLE_NAME,DMU.LAST_NAME
				,DMU.Record_Status
				,CASE WHEN DMU.Enabled_Indicator=1 THEN 'true' ELSE 'false' END as [Enabled]	
				,FB.EMPEE_GROUP_CD
				,FB.EMPEE_CLS_CD	
				,ISNULL(FB.FAC_RANK_CD,'') as FAC_RANK_CD	
				,Record_Source
		FROM DM_Shadow_Staging.dbo._UPLOAD_DM_USERS DMU
				INNER JOIN DM_Shadow_Staging.dbo.FSDB_Facstaff_Basic FB
					LEFT OUTER JOIN DM_Shadow_Staging.dbo.FSDB_Departments D 
						ON FB.Department_ID = D.Department_ID
				ON DMU.FacstaffID = FB.Facstaff_ID
		WHERE DMU.username NOT IN (SELECT username FROM #Latest_Keep_Inactive) -- check keep_active=no at all years regardless

		--FROM DM_Shadow_Staging.dbo._DM_USERS DMU 
		--		INNER JOIN DM_Shadow_Staging.dbo.FSDB_Facstaff_Basic FB
		--				LEFT OUTER JOIN DM_Shadow_Staging.dbo.FSDB_Departments D 
		--				ON FB.Department_ID = D.Department_ID							
		--		ON DMU.FacstaffID = FB.Facstaff_ID
		--				--AND FB.Active_Indicator=1 AND FB.BUS_Person_Indicator=1
		--				--AND  (EMPEE_GROUP_CD in ('A','B','C','E','G','H','P','S','T','U')	)								
		--				--		OR EMPEE_CLS_CD IN ('GA','SA', 'HG')
			
		--WHERE Enabled_Indicator=1 and Service_Account_Indicator=0
		--		AND DMU.username IN (
		--			SELECT network_ID 
		--			from DM_Shadow_Staging.dbo.FSDB_Facstaff_Basic 
		--			where Active_Indicator=1 AND BUS_Person_Indicator=1
		--					AND (EMPEE_GROUP_CD in ('A','B','C','E','G','H','P','S','T','U')									
		--							OR EMPEE_CLS_CD IN ('GA','SA', 'HG') )				
		--)
	
	),
	new_employees_new_user AS (
		-- extract the new employees, compare to all records in _DM_ADMIN
		SELECT  USERNAME,UIN, FACSTAFFID, EDWPERSID 
				,DEP 
				,FIRST_NAME,MIDDLE_NAME,LAST_NAME
				--,Record_Status
				,[Enabled]
				,EMPEE_GROUP_CD
				,EMPEE_CLS_CD	
				,FAC_RANK_CD
		FROM new_and_updated_current_employees
		WHERE username NOT IN (SELECT USERNAME FROM _DM_USERS WHERE USERNAME is not NULL)
			AND Record_Status='NEW'
			AND  username NOT IN (SELECT username FROM #Latest_Keep_Inactive) 

	),
	new_employees_add_ADMIN AS (
		-- extract the new employees that has no DM's ADMIN records yet (compare to all records in _DM_ADMIN)
		SELECT  USERNAME,UIN, FACSTAFFID, EDWPERSID 
				,DEP 
				,FIRST_NAME,MIDDLE_NAME,LAST_NAME
				--,Record_Status
				,[Enabled]
				,EMPEE_GROUP_CD
				,EMPEE_CLS_CD	
				,FAC_RANK_CD
		FROM new_and_updated_current_employees
		WHERE username NOT IN (SELECT USERNAME FROM _DM_ADMIN WHERE USERNAME is not NULL)		
			AND Record_Status='NEW'
			AND username NOT IN (SELECT username FROM #Latest_Keep_Inactive) 
	),
	
	reentry_employees_put_admin AS (
		-- reentry employees are those who had been employees, quit, but returned to the college. 
		-- must not load those whose KEEP_ACTOVE = 'No'.
		-- Welcome back!
		SELECT  USERNAME,UIN, FACSTAFFID, EDWPERSID 
				,DEP 
				,FIRST_NAME,MIDDLE_NAME,LAST_NAME
				--,Record_Status
				,[Enabled]
				,EMPEE_GROUP_CD
				,EMPEE_CLS_CD	
				,FAC_RANK_CD
		FROM new_and_updated_current_employees
		WHERE username IN (SELECT USERNAME FROM dbo._DM_USERS WHERE USERNAME is not NULL AND Enabled_Indicator=0)
				AND username not in  (SELECT username FROM #Latest_Keep_Inactive)
				AND username in (SELECT username from dbo._DM_ADMIN)
	),
	
	reentry_employees_enable_users AS (
		-- reentry employees are those who had been employees, quit, but returned to the college. 
		-- must not load those whose KEEP_ACTOVE = 'No'.
		-- Welcome back!
		SELECT  USERNAME,UIN, FACSTAFFID, EDWPERSID 
				,DEP 
				,FIRST_NAME,MIDDLE_NAME,LAST_NAME
				--,Record_Status
				,[Enabled]
				,EMPEE_GROUP_CD
				,EMPEE_CLS_CD	
				,FAC_RANK_CD
		FROM new_and_updated_current_employees
		WHERE username IN (SELECT USERNAME FROM dbo._DM_USERS WHERE USERNAME is not NULL AND Enabled_Indicator=0)
				AND username not in  (SELECT username FROM #Latest_Keep_Inactive)
	),

	reentry_employees_old_DEP AS (
		-- reentry employees are those who had been employees, quit, but returned to the college. 
		-- must not load those whose KEEP_ACTIVE = 'No'.
		-- Welcome back!
		SELECT  reentry.USERNAME, dep.id
		FROM new_and_updated_current_employees reentry
				INNER JOIN dbo._DM_ADMIN_DEP dep
				ON reentry.username = dep.USERNAME
					AND dep.AC_YEAR = '2018-2019'
		WHERE reentry.username IN (SELECT USERNAME FROM dbo._DM_USERS WHERE USERNAME is not NULL AND Enabled_Indicator=0)
				AND reentry.username not in  (SELECT username FROM #Latest_Keep_Inactive)
	)


	--select * from reentry_employees
	--select * from new_employees_add_ADMIN
	--select * from new_employees_new_user
	--select * from new_and_updated_current_employees
	--select * from reentry_employees_old_DEP

	/*
		--NS 11/7/2018 Check existence of the newly added staff in the FSDB
	
		SELECT			
		FROM DM_Shadow_Staging.dbo._UPLOAD_DM_USERS DMU
		WHERE username  in 
			(select network_id from Faculty_Staff_Holder.dbo.Facstaff_basic where  active_indicator=1 and BUS_Person_Indicator=1 and Network_ID is not NULL)

		SELECT *
		FROM DM_Shadow_Staging.dbo._UPLOAD_DM_USERS DMU
		WHERE username  in (SELECT USERNAME FROM _DM_USERS WHERE USERNAME is not NULL)

		SELECT *
		FROM DM_Shadow_Staging.dbo._UPLOAD_DM_USERS DMU
		WHERE username  not in (SELECT USERNAME FROM _DM_USERS WHERE USERNAME is not NULL)
	*/



	SELECT method m,url u,xml post, USERNAME,o,ROW_NUMBER()OVER(ORDER BY USERNAME,o,url)r
	INTO #updates
	FROM (
		-- Set/Correct UINs
		-- /login/service/v4/User/USERNAME:{Username}

		--SELECT b.USERNAME,1 o,'PUT'method,'/login/service/v4/User/USERNAME:'+a.username url,
		--	'<User UIN="' + CAST(b.UIN as varchar) + '" FacstaffID="' +  CAST(b.FACSTAFFID as varchar)  + '" EDWPERSID="' +  CAST(b.EDWPERSID as varchar)  + '"></User>' xml
		--FROM _DM_USERS a
		--	JOIN new_and_updated_current_employees b ON b.USERNAME=a.username
		--WHERE (a.UIN IS NULL)
		--		OR (a.UIN is not NULL AND a.UIN <> B.UIN)
	
		--UNION	

		-- >>>>>> ADD ADMIN
	
		SELECT USERNAME,3 o,'POST'  method,'/login/service/v4/UserSchema/USERNAME:'+ USERNAME + '/INDIVIDUAL-ACTIVITIES-Business' as url,
			CAST((SELECT 
				--CAST(YEAR(GETDATE())AS VARCHAR)+'-'+CAST(YEAR(GETDATE())+1 AS VARCHAR)AC_YEAR,
				'2018-2019' AC_YEAR	,
				(
					SELECT DEP
					FOR XML PATH('ADMIN_DEP'),TYPE
				)
			FOR XML PATH('ADMIN'),ROOT('INDIVIDUAL-ACTIVITIES-Business'),TYPE)AS VARCHAR(MAX)) xml
			/* '<INDIVIDUAL-ACTIVITIES-University><ADMIN>'+
				'<AC_YEAR>'+CAST(YEAR(GETDATE())AS VARCHAR)+'-'+CAST(YEAR(GETDATE())+1 AS VARCHAR)+'</AC_YEAR><ADMIN_DEP>'+
					'<COLLEGE>Education</COLLEGE>'+
					'<DEP>ED:  '+d+'</DEP>'+
				'</ADMIN_DEP>'+
			'</ADMIN></INDIVIDUAL-ACTIVITIES-University>' */
		FROM new_employees_add_ADMIN



		UNION


		-- >>>>>> add NEW USER 
		SELECT USERNAME,2 o,'POST','/login/service/v4/User/', 
				(SELECT USERNAME "@username", UIN "@UIN", [Enabled] "@enabled" , FacstaffID "@FacstaffID", EDWPERSID "@EDWPERSID",
					First_Name FirstName,Middle_Name MiddleName,Last_Name LastName,
					USERNAME+'@illinois.edu' Email,
					''ShibbolethAuthentication
				FOR XML PATH('User'))
		FROM new_employees_new_user

		UNION

		-- >>>>>> RE-ENTRY : UPDATE ADMIN
		SELECT USERNAME,3 o,'PUT','/login/service/v4/UserSchema/USERNAME:'+ USERNAME + '/INDIVIDUAL-ACTIVITIES-Business' as url,
			CAST((SELECT 
				--CAST(YEAR(GETDATE())AS VARCHAR)+'-'+CAST(YEAR(GETDATE())+1 AS VARCHAR)AC_YEAR,
				'2018-2019' AC_YEAR	,
				(
					SELECT DEP
					FOR XML PATH('ADMIN_DEP'),TYPE
				)
			FOR XML PATH('ADMIN'),ROOT('INDIVIDUAL-ACTIVITIES-Business'),TYPE)AS VARCHAR(MAX))
		FROM reentry_employees_put_admin

		UNION

		-- NS 5/22/2019
		-- >>>> RE-ENTRY : Enabled users

		---- activate users
		SELECT b.username,1 o,'PUT'method,'/login/service/v4/User/USERNAME:'+b.username url,
				'<User enabled="true"></User>' xml
		FROM reentry_employees_enable_users b 			


		UNION

		-- ASSIGN the "Faculty" security role
		SELECT USERNAME,3,'POST','/login/service/v4/UserRole/USERNAME:'+USERNAME,
			'<INDIVIDUAL-ACTIVITIES-Business-Faculty />'
		FROM new_employees_new_user
	
		UNION

		-- ASSIGN the "Faculty" security role
		SELECT USERNAME,3,'POST','/login/service/v4/UserRole/USERNAME:'+USERNAME,
			'<INDIVIDUAL-ACTIVITIES-Business-Faculty />'
		FROM reentry_employees_enable_users

		--UNION

		---- Fill in their Personal Information
		----UNION SELECT NETID,3,'POST','/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:'+NETID+'/PCI',
		--SELECT USERNAME,3,'POST','/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:'+USERNAME+'/PCI',
		--	CAST((
		--		SELECT USERNAME "@username",(SELECT
		--			First_Name FNAME,
		--			Middle_Name MNAME,
		--			Last_Name LNAME,
		--			USERNAME+'@illinois.edu' EMAIL
		--			FOR XML PATH('PCI'),TYPE
		--		)FOR XML PATH('Record'),ROOT('Data')
		--	)AS VARCHAR(MAX))
		--FROM new_employees
		)x
	ORDER BY USERNAME,o


	IF @submit=1 BEGIN
	
		CREATE TABLE #requests(id INT NOT NULL,method VARCHAR(10),url VARCHAR(255),r INT)
	
		INSERT INTO webservices_requests(method,url,post,process)
		OUTPUT inserted.id,inserted.method,inserted.url,inserted.process INTO #requests
		SELECT m,u,CAST(post AS VARCHAR(MAX)),r FROM #updates WHERE post IS NOT NULL

		UPDATE webservices_requests SET process=NULL,dependsOn=(
			SELECT TOP 1 id FROM #requests r2 JOIN #updates u2 ON u2.r=r2.r
			WHERE u2.o<u1.o AND u2.USERNAME=u1.USERNAME ORDER BY u2.o DESC)
		FROM webservices_requests
		JOIN #requests r1 ON r1.id=webservices_requests.id
		JOIN #updates u1 ON u1.r=r1.r
	
		DROP TABLE #requests
		
		EXEC dbo.webservices_initiate @screen='USERS'

	END
	ELSE SELECT * FROM #updates

	DROP TABLE #updates



END


GO
