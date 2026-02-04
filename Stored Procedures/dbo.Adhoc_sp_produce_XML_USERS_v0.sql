SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- NS 6/16/2016: Start playing with this SP
CREATE PROC [dbo].[Adhoc_sp_produce_XML_USERS_v0] ( @submit BIT=0 )
AS

-- NS 6/16/2016
/*
	We upload records from Facstaff_Basic based on Load_Scope value in Users table.
	On Production, Users table is all Users in DM site. Therefore new users are those in Facstaff_Basic that are NOT in Users table
	On Debugging, I preloaded Users table from COB academics from  Facstaff_Basic in which Load_Scope was set to Y for new, and A for existig Users

*/

-- NS 6/17/2016
-- a) MUST HAVE LIST OF VALUE OF DEPARTMENT

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
	SELECT  Network_ID NETID,UIN, Faculty_Staff_Holder.dbo.FSD_fn_Get_Department_Name(Department_ID) d,
			First_name f, ISNULL(middle_Name,'') m,last_name l,
			0 as lastNameChangedInTheLastWeek
		FROM Faculty_Staff_Holder.dbo.Facstaff_Basic
		WHERE Active_Indicator = 1 AND Bus_Person_Indicator = 1 AND Network_ID is not null
			-- DEBUG:
			AND ( Network_ID in (Select username FROM dbo.Users)
					OR
				  Network_ID IN ('rashad','bwhitloc','nfrank','h-engle','chandlej','jshaplan','kjack','peecher','martinwu' )  )
),
new AS (
	SELECT NETID,UIN,LTRIM(f)FirstName,LTRIM(m)MiddleName,LTRIM(l)LastName,d
	FROM current_employees
	-- DEBUG:
	-- WHERE UIN IN (SELECT UIN FROM USERS WHERE Load_Scope='Y')
	-- PRODUCTION:
	 WHERE UIN NOT IN (SELECT UIN FROM USERS WHERE UIN IS NOT NULL)
		AND NETID NOT IN (SELECT username FROM USERS WHERE username IS NOT NULL)
		AND ISNULL(UIN,'')<>''
)

--select * from current_employees

SELECT method m,url u,xml post, NETID,o,ROW_NUMBER()OVER(ORDER BY NETID,o,url)r
INTO #updates
FROM (
	-- Set/Correct UINs
	SELECT b.NETID,1 o,'PUT'method,'/login/service/v4/User/USERNAME:'+a.username url,
		'<User UIN="'+b.UIN+'"></User>' xml
	FROM USERS a
		JOIN current_employees b ON b.NETID=a.username
	WHERE a.UIN IS NULL and ISNULL(b.UIN,'')<>''
	
	---- Update NetIDs & Last Names (pulling Last Name from PCI)
	UNION SELECT b.NETID,1,'PUT','/login/service/v4/User/USERNAME:'+a.username,
		-- <User username="{b.NETID}"><LastName>{b.l}</LastName></User>
		CAST((SELECT b.NETID "@username",
			CASE WHEN ISNULL(p.LNAME,'')<>'' AND p.LNAME<>a.last_name THEN p.LNAME ELSE NULL END LastName,
			CASE WHEN a.username<>b.NETID THEN b.NETID+'@illinois.edu' ELSE NULL END Email
		FOR XML PATH('User'),TYPE)AS VARCHAR(max))
	FROM USERS a
	JOIN current_employees b ON b.UIN=a.UIN
	LEFT JOIN dbo.PCI p ON p.userid=a.userid
	WHERE ISNULL(b.NETID,'')<>'' AND (a.username<>b.NETID OR ISNULL(p.LNAME,'')<>'' AND p.LNAME<>a.last_name)
	
	-- Create new users
	UNION SELECT NETID,2,'POST','/login/service/v4/User/', 
		(SELECT NETID "@username", UIN "@UIN",
			FirstName,MiddleName,LastName,
			NETID+'@illinois.edu' Email,
			''ShibbolethAuthentication
		FOR XML PATH('User'))
	FROM new

	-- Assign new users to their department
	UNION SELECT NETID,3,'POST','/login/service/v4/UserSchema/USERNAME:'+NETID,
		CAST((SELECT 
			CAST(YEAR(GETDATE())AS VARCHAR)+'-'+CAST(YEAR(GETDATE())+1 AS VARCHAR)AC_YEAR,
			(
				--SELECT 'Business' COLLEGE,'ED:  '+d DEP
				-- DEBUG
				SELECT 'ED: (external) Human & Community Development' DEP
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

	-- Give them the "Faculty" security role
	UNION SELECT NETID,3,'POST','/login/service/v4/UserRole/USERNAME:'+NETID,
		'<INDIVIDUAL-ACTIVITIES-Business-Faculty />'
	FROM new
	-- Fill in their Personal Information
	UNION SELECT NETID,3,'POST','/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:'+NETID+'/PCI',
		CAST((
			SELECT NETID "@username",(SELECT
				FirstName FNAME,
				LastName LNAME
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
