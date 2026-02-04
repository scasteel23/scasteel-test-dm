SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- NS 8/11/2017: reviewed, added EMAIL and MNAME at POST to PCI, dropped the use of USER table, 
--		fixed PUT syntax, created user deactivation on a seperate SP dbo.produce_XML_USERS_deactivate
--		Worked!
-- NS 5/30/2017: Use preferred first/professional last names in (l,f) USERS screen names
-- NS 3/8/2017: Reviewed
-- NS 9/16/2016: Resumed
-- NS 6/16/2016: Start playing with this SP
CREATE PROC [dbo].[Adhoc_sp_produce_XML_USERS_v1] ( @submit BIT=0 )
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

WITH current_employees AS (
	SELECT  Network_ID NETID,UIN, CAST(Facstaff_ID as varchar) FACSTAFF_ID
			,CAST(EDW_PERS_ID as varchar) EDW_PERS_ID, ISNULL(DM_Department_Name,'') dept,
			CASE WHEN [PERS_PREFERRED_FNAME] IS NULL OR [PERS_PREFERRED_FNAME] = ''  THEN First_name
				ELSE [PERS_PREFERRED_FNAME] END as f
			, ISNULL(middle_Name,'') m
			,CASE WHEN [Professional_Last_Name] IS NULL OR [Professional_Last_Name] = ''  THEN [Last_Name]
				ELSE [Professional_Last_Name] END as l
			,0 as lastNameChangedInTheLastWeek
		FROM DM_Shadow_Staging.dbo.FSDB_Facstaff_Basic
		WHERE Active_Indicator = 1 
				AND Bus_Person_Indicator = 1 
				AND Network_ID is not NULL 
				AND Facstaff_ID is not NULL 
				AND EDW_PERS_ID is not NULL 
		--ORDER BY Network_id
			
					
),
new AS (
	SELECT NETID,UIN,CAST(Facstaff_ID as varchar) FACSTAFF_ID
		,CAST(EDW_PERS_ID as varchar) EDW_PERS_ID
		,LTRIM(f)FirstName,LTRIM(m)MiddleName
		,LTRIM(l)LastName, dept
	FROM current_employees
	-- DEBUG, must be commented out when on production:
	--WHERE NETID IN ('ckwood','sougiani')
	-- PRODUCTION:
	WHERE NETID  NOT in (Select username FROM DM_Shadow_Production.dbo._DM_USERS)
)

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


SELECT method m,url u,xml post, NETID,o,ROW_NUMBER()OVER(ORDER BY NETID,o,url)r
INTO #updates
FROM (
	-- Set/Correct UINs
	SELECT b.NETID,1 o,'PUT'method,'/login/service/v4/User/USERNAME:'+a.username url,
		'<User UIN="' + b.UIN + '" FacstaffID="' + b.Facstaff_ID + '" EDWPERSID="' + b.EDW_PERS_ID + '"></User>' xml
	FROM _DM_USERS a
		JOIN current_employees b ON b.NETID=a.username
	WHERE (a.UIN IS NULL and ISNULL(b.UIN,'')<>'')
			OR (a.UIN is not NULL and ISNULL(b.UIN,'')<>'' AND a.UIN <> B.UIN)
	
	UNION

	---- Update NetIDs & names: grant preferred first/professional last names to use in (l,f) USERS names
	SELECT b.NETID,1,'PUT','/login/service/v4/User/USERNAME:'+p.username,
		-- <User username="{b.NETID}"><LastName>{b.l}</LastName></User>
		--CAST((SELECT b.NETID "@username", 
		CAST((SELECT b.NETID "@username", b.UIN "@UIN", b.Facstaff_ID "@FacstaffID", b.EDW_PERS_ID "@EDWPERSID",
			b.l  LastName,
			b.m  MiddleName,
			b.f  FirstName,	
			b.NETID+'@illinois.edu'  Email
			--CASE WHEN ISNULL(b.L,'')<>'' AND b.l<>p.last_name THEN b.l ELSE NULL END LastName,
			--CASE WHEN a.username<>b.NETID THEN b.NETID+'@illinois.edu' ELSE NULL END Email
		FOR XML PATH('User'),TYPE)AS VARCHAR(max))
	--NS 8/11/2017: dropped the use of USERS table
	--FROM USERS a
	--	JOIN current_employees b ON b.UIN=a.UIN
	--	LEFT JOIN dbo._DM_USERS p ON p.userid=a.userid
	FROM current_employees b INNER JOIN dbo._DM_USERS p ON b.UIN=p.UIN
	WHERE ISNULL(b.NETID,'')<>'' 
			AND (p.username<>b.NETID OR b.l<>p.Last_Name OR b.f <> p.First_Name OR ISNULL(p.Middle_Name,'') <> isnull(b.m,''))

	UNION

	-- Create new users
	SELECT NETID,2,'POST','/login/service/v4/User/', 
		(SELECT NETID "@username", UIN "@UIN", Facstaff_ID "@FacstaffID", EDW_PERS_ID "@EDWPERSID",
			FirstName,MiddleName,LastName,
			NETID+'@illinois.edu' Email,
			''ShibbolethAuthentication
		FOR XML PATH('User'))
	FROM new

	UNION

	-- Assign new users to their department
	SELECT NETID,3,'POST','/login/service/v4/UserSchema/USERNAME:'+NETID,
		CAST((SELECT 
			CAST(YEAR(GETDATE())AS VARCHAR)+'-'+CAST(YEAR(GETDATE())+1 AS VARCHAR)AC_YEAR,
			(
				SELECT dept DEP
				-- NS 3/7/2017: <COLLEGE> is no longer working
				--SELECT 'Business' COLLEGE,'ED:  '+dept DEP
				---- DEBUG
				--SELECT 'ED: (external) Human & Community Development' DEP
				FOR XML PATH('ADMIN_DEP'),TYPE
			)
		FOR XML PATH('ADMIN'),ROOT('INDIVIDUAL-ACTIVITIES-Business'),TYPE)AS VARCHAR(999))
		/* '<INDIVIDUAL-ACTIVITIES-University><ADMIN>'+
			'<AC_YEAR>'+CAST(YEAR(GETDATE())AS VARCHAR)+'-'+CAST(YEAR(GETDATE())+1 AS VARCHAR)+'</AC_YEAR><ADMIN_DEP>'+
				'<COLLEGE>Education</COLLEGE>'+
				'<DEP>ED:  '+d+'</DEP>'+
			'</ADMIN_DEP>'+
		'</ADMIN></INDIVIDUAL-ACTIVITIES-University>' */
	FROM new

	UNION

	-- Give them the "Faculty" security role
	SELECT NETID,3,'POST','/login/service/v4/UserRole/USERNAME:'+NETID,
		'<INDIVIDUAL-ACTIVITIES-Business-Faculty />'
	FROM new
	
	UNION

	-- Fill in their Personal Information
	--UNION SELECT NETID,3,'POST','/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:'+NETID+'/PCI',
	SELECT NETID,3,'POST','/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business',
		CAST((
			SELECT NETID "@username",(SELECT
				FirstName FNAME,
				MiddleName MNAME,
				LastName LNAME,
				NETID+'@illinois.edu' EMAIL
				FOR XML PATH('PCI'),TYPE
			)FOR XML PATH('Record'),ROOT('Data')
		)AS VARCHAR(MAX))
	FROM new
)x
ORDER BY NETID,o

IF @submit=1 BEGIN
	
	CREATE TABLE #requests(id INT NOT NULL,method VARCHAR(10),url VARCHAR(255),r INT)
	
	INSERT INTO webservices_requests(method,url,post,process)
	OUTPUT inserted.id,inserted.method,inserted.url,inserted.process INTO #requests
	SELECT m,u,CAST(post AS VARCHAR(MAX)),r FROM #updates WHERE post IS NOT NULL

	UPDATE webservices_requests SET process=NULL,dependsOn=(
		SELECT TOP 1 id FROM #requests r2 JOIN #updates u2 ON u2.r=r2.r
		WHERE u2.o<u1.o AND u2.NETID=u1.NETID ORDER BY u2.o DESC)
	FROM webservices_requests
	JOIN #requests r1 ON r1.id=webservices_requests.id
	JOIN #updates u1 ON u1.r=r1.r
	
	DROP TABLE #requests
END
ELSE SELECT * FROM #updates

DROP TABLE #updates

-- EXEC dbo.produce_XML_USERS @submit = 0
-- EXEC dbo.produce_XML_USERS @submit = 1
END


GO
