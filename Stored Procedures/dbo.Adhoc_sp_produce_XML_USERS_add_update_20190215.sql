SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 2/15/2019: Special Run to add new users only
-- NS 11/8-12/2018: Ran to update new users to DM based on Faculty_Staff_Holder.dbo.Facstaff_Basic data
-- STC 11/19/18 - IT dept name updated in FSDB, no longer need string replacement for DM
-- NS 9/27/2017: Added enabled
-- NS 8/17/2017: changed source of NEW EMPLOYEES from _DM_USERS table to _UPLOAD_USERS table
--		source of Current Employees from FSDB_FACSTAFF_BASIC table to _DM_USERS table
-- NS 8/11/2017: reviewed, added EMAIL and MNAME at POST to PCI, dropped the use of USER table, 
--		fixed PUT syntax, created user deactivation on a seperate SP dbo.produce_XML_USERS_deactivate
--		Worked!
-- NS 5/30/2017: Use preferred first/professional last names in (l,f) USERS screen names
-- NS 3/8/2017: Reviewed
-- NS 9/16/2016: Resumed
-- NS 6/16/2016: Start playing with this SP
CREATE PROC [dbo].[Adhoc_sp_produce_XML_USERS_add_update_20190215] ( @submit BIT=0 )
AS

/*
	NS 8/11/2017
	Create new test users at DM by editing DEBUG lines below

*/
/*
	On DM_Shadow_Production, _DM_USERS table is all Users in DM site. 
	On DM_Shadow_Staging, _DM_USERS table is all Users in DM site + new users 
			new users are users that exist on dbo.FSDB_Facstaff_Basic but not in DM_Shadow_Production.dbo._DM_USERS
	There is a daily upload of new users to DM_Shadow_Staging.dbo._DM_USERS table

	 Test the results
	 EXEC dbo.[produce_XML_USERS_add_update] @submit = 0

	 Manual run to upload USERS FROM FSDB
	 EXEC dbo._1PHASE2_sp_DM_Upload_Update_or_Add_Users_From_Facstaff_Basic
	 EXEC dbo.[produce_XML_USERS_add_update_20190215] @submit = 0
	 EXEC dbo.webservices_run_DTSX

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

--  NS 8/17/2017 decommissioned
--WITH new_and_updated_current_employees AS (
--	SELECT  Network_ID NETID,UIN, CAST(Facstaff_ID as varchar) FACSTAFF_ID
--			,CAST(EDW_PERS_ID as varchar) EDW_PERS_ID, ISNULL(DM_Department_Name,'') dept,
--			CASE WHEN [PERS_PREFERRED_FNAME] IS NULL OR [PERS_PREFERRED_FNAME] = ''  THEN First_name
--				ELSE [PERS_PREFERRED_FNAME] END as f
--			, ISNULL(middle_Name,'') m
--			,CASE WHEN [Professional_Last_Name] IS NULL OR [Professional_Last_Name] = ''  THEN [Last_Name]
--				ELSE [Professional_Last_Name] END as l
--			,0 as lastNameChangedInTheLastWeek
--		FROM DM_Shadow_Staging.dbo.FSDB_Facstaff_Basic
--		WHERE Active_Indicator = 1 
--				AND Bus_Person_Indicator = 1 
--				AND Network_ID is not NULL 
--				AND Facstaff_ID is not NULL 
--				AND EDW_PERS_ID is not NULL 
--		--ORDER BY Network_id
			
					
--),
--new AS (
--	SELECT NETID,UIN,CAST(Facstaff_ID as varchar) FACSTAFF_ID
--		,CAST(EDW_PERS_ID as varchar) EDW_PERS_ID
--		,LTRIM(f)FirstName,LTRIM(m)MiddleName
--		,LTRIM(l)LastName, dept
--	FROM new_and_updated_current_employees
--	-- DEBUG, must be commented out when on production:
--	--WHERE NETID IN ('ckwood','sougiani')
--	-- PRODUCTION:
--	WHERE NETID  NOT in (Select username FROM DM_Shadow_Production.dbo._DM_USERS)
--)

/*
	>>>> See list of new users to uplaod to DM:
				
	>>>> PRODUCTION
	SELECT  Network_ID NETID,UIN, Faculty_Staff_Holder.dbo.FSD_fn_Get_Department_Name(Department_ID) dept,
			First_name f, ISNULL(middle_Name,'') m,last_name l,
			0 as lastNameChangedInTheLastWeek
	FROM dbo.FSDB_Facstaff_Basic
	WHERE Active_Indicator = 1 
				AND Bus_Person_Indicator = 1 
				AND Network_ID is not null
				AND Network_ID  NOT in (Select username FROM DM_Shadow_Production.dbo._DM_USERS)

*/


WITH new_and_updated_current_employees AS (
	-- The following codes get the detailed data from Faculty_Staff_Holder.dbo.Facstaff_Basic
	--		but for all persons pulled to DM_Shadow_Staging.dbo._UPLOAD_DM_USERS

	-- >>>>>>> TRANSITION - FSDB RELATED UPLOAD

	SELECT FB.network_ID as USERNAME
		,FB.UIN
		,CAST(FB.Facstaff_ID as varchar) as FACSTAFFID
		,CAST(FB.EDW_PERS_ID as varchar) EDWPERSID
		,FB.First_Name, FB.Middle_Name, FB.Last_Name
--		,ISNULL(REPLACE(D.Department_Name,'IT Partners','Business IT Services'),'') as DEP      
		,ISNULL(D.Department_Name,'') as DEP      
		,'NEW' as Record_Status
		,'true' as [Enabled]
	FROM Faculty_Staff_Holder.dbo.Facstaff_Basic FB
			LEFT OUTER JOIN Faculty_Staff_Holder.dbo.Departments D 
			ON FB.Department_ID = D.Department_ID 
	WHERE FB.Active_Indicator=1 and FB.BUS_Person_Indicator=1
		AND Network_ID in (select username from dbo._UPLOAD_DM_USERS) -- can use dbo._UPLOAD_DM_USERS to confirm network ID of legit current emps that can be uploaded to DM


	-- >>>>> PRODUCTION !!

	-- The following codes should be on production, 
	-- Populate _UPLOAD_DM_USERS in Dbo.DailyUpdate_sp_DM_Step06_Update_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees
	--		_UPLOAD_DM_USERS has all current users in DM that has updated information form EDW as well
	--		all new users registered in EDW	
	--	
	--SELECT  DMU.USERNAME
	--        ,DMU.UIN
	--	    ,CAST(DMU.FACSTAFFID as varchar) as FACSTAFFID
	--        ,CAST(DMU.EDWPERSID as varchar) as EDWPERSID 
	--		--,DMU.DEP
	--		,ISNULL(REPLACE(DMU.DEP,'IT Partners','Business IT Services'),'') as DEP 
	--		,DMU.FIRST_NAME,DMU.MIDDLE_NAME,DMU.LAST_NAME
	--		,DMU.Record_Status
	--		,CASE WHEN DMU.Enabled_Indicator=1 THEN 'true' ELSE 'false' END as [Enabled]		
	--FROM DM_Shadow_Staging.dbo._UPLOAD_DM_USERS DMU
	

	-- >>>>>> DEBUG SPECIAL
	-- This part of the codes is just to qualify certain persons to upload
	--FROM DM_Shadow_Staging.dbo._UPLOAD_DM_USERS	DMU INNER JOIN DM_Shadow_Staging.dbo._DM_USERS D
	--		ON DMU.FacstaffID = D.FacstaffID
	--WHERE D.DEP is NULL OR D.DEP = '' 	
),
new_employees AS (
	-- new employees extracted from EDW 
	SELECT  USERNAME,UIN, FACSTAFFID, EDWPERSID 
			,DEP 
			,FIRST_NAME,MIDDLE_NAME,LAST_NAME
			,Record_Status
			,[Enabled]
	FROM new_and_updated_current_employees
	WHERE username NOT IN (SELECT USERNAME FROM _DM_USERS WHERE USERNAME is not NULL)
	--  SPECIAL UPLOAD NEW USERS CERTAIN USERS
	--  WHERE USERNAME IN ('holland6','kdedward','mhl')
	--  WHERE USERNAME IN ('holland6','m-leroy')
)

--select * from new_employees
--select * from new_and_updated_current_employees

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


/*
-- upload NEW employees
SELECT USERNAME,2,'POST','/login/service/v4/User/', 
		(SELECT USERNAME "@username", UIN "@UIN", [Enabled] "@enabled" , FacstaffID "@FacstaffID", EDWPERSID "@EDWPERSID",
			First_Name FirstName,Middle_Name MiddleName,Last_Name LastName,
			USERNAME+'@illinois.edu' Email,
			''ShibbolethAuthentication
		FOR XML PATH('User'))
FROM new

-- upload UPDATES based on UIN changes
SELECT b.USERNAME,1 o,'PUT'method,'/login/service/v4/User/USERNAME:'+a.username url,
		'<User UIN="' + CAST(b.UIN as varchar) + '" FacstaffID="' +  CAST(b.FACSTAFFID as varchar)  + '" EDWPERSID="' +  CAST(b.EDWPERSID as varchar)  + '"></User>' xml
FROM _DM_USERS a
		JOIN new_and_updated_current_employees b ON b.USERNAME=a.username
WHERE (a.UIN IS NULL)
			OR (a.UIN is not NULL AND a.UIN <> B.UIN)


-- upload UPDATES based on name changes (same UIN)
SELECT b.USERNAME,1,'PUT','/login/service/v4/User/USERNAME:'+p.username,
		-- <User username="{b.NETID}"><LastName>{b.l}</LastName></User>
		--CAST((SELECT b.NETID "@username", 
		CAST((SELECT b.USERNAME "@username", b.UIN "@UIN", b.FacstaffID "@FacstaffID", b.EDWPERSID "@EDWPERSID",
		    --p.userid "@USERID",
			b.Last_Name as LastName,
			b.Middle_Name as MiddleName,
			b.first_name as  FirstName,	
			b.USERNAME+'@illinois.edu'  Email
			--CASE WHEN ISNULL(b.L,'')<>'' AND b.l<>p.last_name THEN b.l ELSE NULL END LastName,
			--CASE WHEN a.username<>b.NETID THEN b.NETID+'@illinois.edu' ELSE NULL END Email
		FOR XML PATH('User'),TYPE)AS VARCHAR(max))
	--NS 8/11/2017: dropped the use of USERS table
	--FROM USERS a
	--	JOIN new_and_updated_current_employees b ON b.UIN=a.UIN
	--	LEFT JOIN dbo._DM_USERS p ON p.userid=a.userid
FROM new_and_updated_current_employees b INNER JOIN dbo._DM_USERS p ON b.UIN=p.UIN
WHERE ISNULL(b.USERNAME,'')<>'' 
			AND (p.username<>b.USERNAME OR b.last_Name<>p.Last_Name OR b.First_Name <> p.First_Name OR ISNULL(p.Middle_Name,'') <> isnull(b.Middle_Name,''))

*/

SELECT method m,url u,xml post, USERNAME,o,ROW_NUMBER()OVER(ORDER BY USERNAME,o,url)r
INTO #updates
FROM (
	-- Set/Correct UINs
	SELECT b.USERNAME,1 o,'PUT'method,'/login/service/v4/User/USERNAME:'+a.username url,
		'<User UIN="' + CAST(b.UIN as varchar) + '" FacstaffID="' +  CAST(b.FACSTAFFID as varchar)  + '" EDWPERSID="' +  CAST(b.EDWPERSID as varchar)  + '"></User>' xml
	FROM _DM_USERS a
		JOIN new_and_updated_current_employees b ON b.USERNAME=a.username
	WHERE (a.UIN IS NULL)
			OR (a.UIN is not NULL AND a.UIN <> B.UIN)
	
	UNION

	---- Update NetIDs & names: grant preferred first/professional last names to use in (l,f) USERS names
	SELECT b.USERNAME,1,'PUT','/login/service/v4/User/USERNAME:'+p.username,
		-- <User username="{b.NETID}"><LastName>{b.l}</LastName></User>
		--CAST((SELECT b.NETID "@username", 
		CAST((SELECT b.USERNAME "@username", b.UIN "@UIN", b.FacstaffID "@FacstaffID", b.EDWPERSID "@EDWPERSID",  
		    --p.userid "@USERID",
			b.Last_Name as LastName,
			b.Middle_Name as MiddleName,
			b.first_name as  FirstName,	
			b.USERNAME+'@illinois.edu'  Email
			--CASE WHEN ISNULL(b.L,'')<>'' AND b.l<>p.last_name THEN b.l ELSE NULL END LastName,
			--CASE WHEN a.username<>b.NETID THEN b.NETID+'@illinois.edu' ELSE NULL END Email
		FOR XML PATH('User'),TYPE)AS VARCHAR(max))
	--NS 8/11/2017: dropped the use of USERS table
	--FROM USERS a
	--	JOIN new_and_updated_current_employees b ON b.UIN=a.UIN
	--	LEFT JOIN dbo._DM_USERS p ON p.userid=a.userid
	FROM new_and_updated_current_employees b INNER JOIN dbo._DM_USERS p ON b.UIN=p.UIN
	WHERE ISNULL(b.USERNAME,'')<>'' 
			AND (p.username<>b.USERNAME OR b.last_Name<>p.Last_Name OR b.First_Name <> p.First_Name OR ISNULL(p.Middle_Name,'') <> isnull(b.Middle_Name,''))

	UNION

	-- Create new users
	SELECT USERNAME,2,'POST','/login/service/v4/User/', 
		(SELECT USERNAME "@username", UIN "@UIN", [Enabled] "@enabled" , FacstaffID "@FacstaffID", EDWPERSID "@EDWPERSID",
			First_Name FirstName,Middle_Name MiddleName,Last_Name LastName,
			USERNAME+'@illinois.edu' Email,
			''ShibbolethAuthentication
		FOR XML PATH('User'))
	FROM new_employees

	UNION

	-- Assign new users to their department

	SELECT USERNAME,3,'POST','/login/service/v4/UserSchema/USERNAME:'+ USERNAME + '/INDIVIDUAL-ACTIVITIES-Business' as url,
		CAST((SELECT 
			--CAST(YEAR(GETDATE())AS VARCHAR)+'-'+CAST(YEAR(GETDATE())+1 AS VARCHAR)AC_YEAR,
			'2017-2018' AC_YEAR	,
			(
				SELECT DEP
				-- NS 3/7/2017: <COLLEGE> is no longer working
				--SELECT 'Business' COLLEGE,'ED:  '+dept DEP
				---- DEBUG
				--SELECT 'ED: (external) Human & Community Development' DEP
				FOR XML PATH('ADMIN_DEP'),TYPE
			)
		FOR XML PATH('ADMIN'),ROOT('INDIVIDUAL-ACTIVITIES-Business'),TYPE)AS VARCHAR(MAX))
		/* '<INDIVIDUAL-ACTIVITIES-University><ADMIN>'+
			'<AC_YEAR>'+CAST(YEAR(GETDATE())AS VARCHAR)+'-'+CAST(YEAR(GETDATE())+1 AS VARCHAR)+'</AC_YEAR><ADMIN_DEP>'+
				'<COLLEGE>Education</COLLEGE>'+
				'<DEP>ED:  '+d+'</DEP>'+
			'</ADMIN_DEP>'+
		'</ADMIN></INDIVIDUAL-ACTIVITIES-University>' */
	FROM new_employees

	UNION

	-- Give them the "Faculty" security role
	SELECT USERNAME,3,'POST','/login/service/v4/UserRole/USERNAME:'+USERNAME,
		'<INDIVIDUAL-ACTIVITIES-Business-Faculty />'
	FROM new_employees
	
	UNION

	-- Fill in their Personal Information
	--UNION SELECT NETID,3,'POST','/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:'+NETID+'/PCI',
	SELECT USERNAME,3,'POST','/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:'+USERNAME+'/PCI',
		CAST((
			SELECT USERNAME "@username",(SELECT
				First_Name FNAME,
				Middle_Name MNAME,
				Last_Name LNAME,
				USERNAME+'@illinois.edu' EMAIL
				FOR XML PATH('PCI'),TYPE
			)FOR XML PATH('Record'),ROOT('Data')
		)AS VARCHAR(MAX))
	FROM new_employees
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


--EXEC dbo.webservices_initiate @screen='USERS'	



END


GO
