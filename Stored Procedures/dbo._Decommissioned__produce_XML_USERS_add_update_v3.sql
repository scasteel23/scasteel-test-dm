SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 6/10/2019 v3
		/*
		CREATE TYPE FSDB_DM_Upload_EDWPERSID_activity AS TABLE   
		( EDWPERSID VARCHAR(10), Activity varchar(60) );  
		*/
-- NS 5/22/2019 v2
-- Add, Reacticate (Re-entry users) and Update USERS based on the following procedures
-- 0) Get records where KEEP_ACTIVE='NO' in the latest AC_YEAR. DO NOT reactivate (re-entry) those username even though BANNER includes them as GiesBusiness emps
-- 1) Add New employees
--			KM employees in Banner that are not shown in _DM_USERS
--			POST to USERS to create a new ENABLED=1  record
--			POST to ADMIN to create a new 3018-2019 record
--			PUT 'FACULTY' role
--
-- 2) Re-activate Re-entry Employees
--			KM employees in Banner that are not shown in _DM_USERS who has Enabled_Indicator = 1
--			PUT to USERS to enable
--			PUT a new 2018-2019 ADMIN regardless
--			PUT 'FACULTY' role
--		
-- 3) Update Network ID
--			KM employes that has Network ID changed
--			PUT to USERS to change USERNAME
--			Put 'FACULTY' role

-- PCI update is done in a seperate SP

-- NS 3/8/2017: Reviewed
-- NS 9/16/2016: Resumed
-- NS 6/16/2016: v1 
--			Start playing with this SP

CREATE PROC [dbo].[_Decommissioned_produce_XML_USERS_add_update_v3] ( @submit BIT=0 )
AS

/*

	 Test the results
	 EXEC dbo.[produce_XML_USERS_add_update] @submit = 0

	 Manual run to upload USERS FROM FSDB
	 DECLARE @Result varchar(2000)
	 EXEC dbo._1PHASE2_sp_DM_Upload_Update_or_Add_Users_From_Facstaff_Basic
	 EXEC dbo.[produce_XML_USERS_add_update] @submit = 1
	 EXEC dbo.webservices2_run @Result = @Result OUTPUT 

*/


BEGIN

	-- Get records where KEEP_ACTIVE='NO' in the latest AC_YEAR
	-- DO NOT reactivate (re-entry) those username even though BANNER includes them as GiesBusiness emps
	SELECT m1.username, ISNULL(m1.KEEP_ACTIVE,'') as KEEP_ACTIVE, m1.AC_YEAR, m1.EDWPERSID
	INTO #Latest_Keep_Inactive
	FROM DM_Shadow_Staging.dbo._DM_ADMIN m1
			LEFT JOIN DM_Shadow_Staging.dbo._DM_ADMIN m2
			ON m1.USERNAME = m2.USERNAME  AND m1.AC_YEAR < m2.AC_YEAR
				AND m1.USERNAME is not NULL		
	WHERE m2.AC_YEAR is NULL AND m1.KEEP_ACTIVE='NO' AND m1.USERNAME is not null;

	--  SELECT * FROM #Latest_Keep_Inactive
	-- _UPLOAD_DM_USERS table was populated in Dbo.DailyUpdate_sp_DM_Step06_Update_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees
	-- _UPLOAD_DM_USERS table contains
	--			(1) all current users in DM that has updated information from EDW (Update_Status <> '')
	--			(2) all new users registered in EDW	(Record_Status='NEW')
	--	

	WITH new_and_updated_current_employees AS (
		SELECT  UDMU.USERNAME
				,UDMU.UIN
				,CAST(UDMU.FACSTAFFID as varchar) as FACSTAFFID
				,CAST(UDMU.EDWPERSID as varchar) as EDWPERSID 
				--,DMU.DEP
				--,ISNULL(REPLACE(D.Department_Name,'IT Partners','Business IT Services'),'') as DEP 
				,UDMU.DEP as DEP
				,UDMU.FIRST_NAME,DMU.MIDDLE_NAME,DMU.LAST_NAME
				,UDMU.Record_Status
				,CASE WHEN UDMU.Enabled_Indicator=1 THEN 'true' ELSE 'false' END as [Enabled]	
				,FB.EMPEE_GROUP_CD
				,FB.EMPEE_CLS_CD	
				,ISNULL(FB.FAC_RANK_CD,'') as FAC_RANK_CD	
				,Record_Source
				,DMU.username as Original_USERNAME
				,DMB.Update_Status
				,UDMU.userid
		FROM DM_Shadow_Staging.dbo._UPLOAD_DM_USERS UDMU
				INNER JOIN DM_Shadow_Staging.dbo.FSDB_Facstaff_Basic FB
					LEFT OUTER JOIN DM_Shadow_Staging.dbo.FSDB_Departments D 
						ON FB.Department_ID = D.Department_ID
				ON UDMU.FacstaffID = FB.Facstaff_ID
				LEFT OUTER JOIN DM_Shadow_Staging.dbo._DM_USERS DMU
				ON UDMU.EDWPERSID = DMU.EDWPERSID
				LEFT OUTER JOIN DM_Shadow_Staging.dbo._UPLOAD_DM_BANNER DMB
				ON UDMU.EDWPERSID = DMB.EDWPERSID
		WHERE DMU.username NOT IN (SELECT username FROM #Latest_Keep_Inactive) -- check keep_active=no at all years regardless
				AND DMU.EDWPERSID NOT IN (SELECT EDWPERSID FROM #Latest_Keep_Inactive) 

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
			AND  EDWPERSID NOT IN (SELECT EDWPERSID FROM #Latest_Keep_Inactive) 
			AND Update_Status not like '%N%'

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
			AND Update_Status not like '%N%'
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
	),
	-- DDD
	NETID_Changed AS (
		-- reentry employees are those who had been employees, quit, but returned to the college. 
		-- must not load those whose KEEP_ACTIVE = 'No'.
		-- Welcome back!
		SELECT  updates.USERNAME, updates.userid, updates.Original_USERNAME
		FROM new_and_updated_current_employees updates
				INNER JOIN dbo._DM_ADMIN_DEP dep
				ON updates.EDWPERSID = dep.EDWPERSID
					AND dep.AC_YEAR = '2018-2019'
		WHERE  updates.username not in  (SELECT username FROM #Latest_Keep_Inactive)
				AND Update_Status like '%N%'
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

	


		-- >>>>>> (1a) POST a NEW USER 
		SELECT USERNAME,2 o,'POST' method,'/login/service/v4/User/' as url, 
				(SELECT USERNAME "@username", UIN "@UIN", [Enabled] "@enabled" , FacstaffID "@FacstaffID", EDWPERSID "@EDWPERSID",
					First_Name FirstName,Middle_Name MiddleName,Last_Name LastName,
					USERNAME+'@illinois.edu' Email,
					'' ShibbolethAuthentication
				FOR XML PATH('User')) xml
		FROM new_employees_new_user

		UNION

		-- >>>>>> (1b) POST a new ADMIN for 2018-2019  for those who are adedd at step (1a)
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

		-- >>>>>> (1c) ASSIGN the "Faculty" security role
		SELECT USERNAME,3,'POST','/login/service/v4/UserRole/USERNAME:'+USERNAME,
			'<INDIVIDUAL-ACTIVITIES-Business-Faculty />'
		FROM new_employees_new_user

		UNION

		-- >>>>>> (2a) RE-ENTRY : ENABLE user

		---- activate users
		SELECT b.username,1 o,'PUT'method,'/login/service/v4/User/USERNAME:'+b.username url,
				'<User enabled="true"></User>' xml
		FROM reentry_employees_enable_users b 		

		UNION

		-- >>>>>> (2b) Re-activate Re-entry Employees
		--			 RE-ENTRY : PUT ADMIN (update)
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

		-- >>>>>>> (2c) ASSIGN the "Faculty" security role
		SELECT USERNAME,3,'POST','/login/service/v4/UserRole/USERNAME:'+USERNAME,
			'<INDIVIDUAL-ACTIVITIES-Business-Faculty />'
		FROM reentry_employees_enable_users

		UNION

		-- >>>>>>> (3a) Change USERNAME
		SELECT USERNAME,3,'POST','/login/service/v4/UserRole/USERNAME:'+Original_USERNAME,
			'<User username="' + USERNAME + '">
			 <Email_Address>' +  USERNAME + '@illinois.edu</Email>
			 </User>'
		FROM NETID_Changed

		UNION

		-- >>>>>> (3b) ASSIGN the newly changed USERNAME the "Faculty" security role
		SELECT USERNAME,4,'POST','/login/service/v4/UserRole/USERNAME:'+USERNAME,
			'<INDIVIDUAL-ACTIVITIES-Business-Faculty />'
		FROM NETID_Changed

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

	/*
	PUT /login/service/v4/User/USERNAME:oldnetid
		<User username="newnetid">
		<Email_Address>newnetid@illinois.edu</Email>
		</User>

	*/
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

		-- LOG

		/*
		CREATE TYPE FSDB_DM_Upload_EDWPERSID_activity AS TABLE   
		( EDWPERSID VARCHAR(10), Activity varchar(60) );  
		*/

	END
	ELSE SELECT * FROM #updates

	DROP TABLE #updates



END


GO
