SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 1/2/2019 Tested, but NPR_* columns has no data yet in Faculty_Staff_Holder.dbo.Facstaff_AACSB table
-- NS 12/21/2018
--		ADMIN_NPRESP, ADMIN_EMPGROUP and ADMIN_EMPTYPE are implemented with Checkboxes, not DSA
--		Copied from ADMIN_EMPGROUP for ADMIN_NPRESP
--		This SP relies on the most recent _DM_USERS data, 
--			if the creation date time _DM_USERS and _DM_ADMIN are nboth the same then no update and addition needed to the ADMIN screen
--		Update to ADMIN (PUT): This DM update relies on the most recent _DM_ADMIN and Facstaff_Basic
--					Any record in _DM_ADMIN will get updates if the user exist in _DM_BANNER
--		Add to ADMIN (POST): This DM add relies on the most recent _DM_USERS
--				   Any record on _DM_USERS that not in _DM_ADMINS will be added ADMIN

CREATE PROC [dbo].[produce_XML_ADMIN_Update_ADMIN_NPRESP] ( @submit BIT=0 )
AS


/*
	On DM_Shadow_Production, _DM_USERS table is all Users in DM site. 
	On DM_Shadow_Staging, _DM_USERS table is all Users in DM site + new users 
			new users are users that exist on dbo.FSDB_Facstaff_Basic but not in DM_Shadow_Production.dbo._DM_USERS
	There is a daily upload of new users to DM_Shadow_Staging.dbo._DM_USERS table

	 Get Facstaff_Basic into _UPLOAD_DM_USERS table
	 _1PHASE2_sp_DM_Upload_Update_or_Add_Users_From_Facstaff_Basic

	 Test
	 EXEC dbo.[produce_XML_ADMIN_Update_ADMIN_NPRESP] @submit = 0

	 Manual run to upload USERS FROM FSDB  -- 6 minutes for 600 records
	 EXEC dbo.[produce_XML_ADMIN_Update_ADMIN_NPRESP] @submit = 
	 EXEC dbo.webservices_run_DTSX
*/

/*
<INDIVIDUAL-ACTIVITIES-Business>
	<ADMIN>
		<AC_YEAR>2018-2019</AC_YEAR>
		<NPRESP>Administration</NPRESP>
		<NPRESP>Executive Education</NPRESP>
		<NPRESP>Doctoral Level Teaching/Mentoring</NPRESP>		
	</ADMIN>
	<ADMIN>
	<AC_YEAR>2018-2019</AC_YEAR>
		<ADMIN_DEP><DEP>iMBA</DEP></ADMIN_DEP>
		<NPRESP>Executive Education</NPRESP>
		<NPRESP>Doctoral Level Teaching/Mentoring</NPRESP>		
	</ADMIN>
</INDIVIDUAL-ACTIVITIES-Business>

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

-- PUT to update existing ADMIN_NPRESP
-- POST to create new ADMIN_NPRESP -- based on _DM_USERS as users to compare with _DM_ADMIN

CREATE TABLE [dbo].#Updates(
	m varchar(10) NOT NULL,
	u varchar(100) NULL,
	post [varchar](MAX) NULL,
	o  int,
	username varchar(60),
	r int
) ;



-- >>>>>>>>>>>>>>>>>> 1. "PUT" to update existing ADMIN_NPRESP
--			Update to ADMIN (PUT): This DM update relies on the most recent _DM_ADMIN and Facstaff_Basic
--			Any record in _DM_ADMIN will get updates if the user exist in _DM_BANNER

WITH existdept_current_employees AS (
	-- Existing user records at DMM on  _DM_USERS table
	SELECT  DISTINCT DMU.USERNAME,DMU.UIN, CAST(DMU.FACSTAFFID as varchar) as FACSTAFFID, CAST(DMU.EDWPERSID as varchar) as EDWPERSID 
		
		FROM DM_Shadow_Staging.dbo._DM_USERS DMU
				INNER JOIN dbo.FSDB_Facstaff_Basic FB
				ON DMU.FacstaffID = FB.Facstaff_ID				
		WHERE  username in (SELECT [USERNAME]FROM [DM_Shadow_Staging].[dbo].[_DM_ADMIN] WHERE AC_YEAR='2018-2019')
				--	DEBUG: commented out this phrase for all FSDB records
				AND Active_Indicator=1
),

npresp1 as (
	SELECT DMU.USERNAME,CAST(DMU.FACSTAFFID as varchar) as FACSTAFFID, CAST(DMU.EDWPERSID as varchar) as EDWPERSID 
			,'Administration' as NPRESP
	FROM DM_Shadow_Staging.dbo._DM_USERS DMU INNER JOIN Faculty_Staff_Holder.dbo.Facstaff_AACSB	FA ON DMU.FacstaffID = FA.Facstaff_ID 	AND NPR_Administration=1

	UNION

	SELECT DMU.USERNAME,CAST(DMU.FACSTAFFID as varchar) as FACSTAFFID, CAST(DMU.EDWPERSID as varchar) as EDWPERSID 
			,'Doctoral Level Teaching/Mentoring' as NPRESP
	FROM DM_Shadow_Staging.dbo._DM_USERS DMU INNER JOIN Faculty_Staff_Holder.dbo.Facstaff_AACSB	FA ON DMU.FacstaffID = FA.Facstaff_ID 	AND NPR_Doctoral=1

	UNION

	SELECT DMU.USERNAME,CAST(DMU.FACSTAFFID as varchar) as FACSTAFFID, CAST(DMU.EDWPERSID as varchar) as EDWPERSID 
			,'Executive Education' as NPRESP
	FROM DM_Shadow_Staging.dbo._DM_USERS DMU INNER JOIN Faculty_Staff_Holder.dbo.Facstaff_AACSB	FA ON DMU.FacstaffID = FA.Facstaff_ID 	AND NPR_Executive=1

	UNION

	SELECT DMU.USERNAME,CAST(DMU.FACSTAFFID as varchar) as FACSTAFFID, CAST(DMU.EDWPERSID as varchar) as EDWPERSID 
			,'Master''s Level Teaching' as NPRESP
	FROM DM_Shadow_Staging.dbo._DM_USERS DMU INNER JOIN Faculty_Staff_Holder.dbo.Facstaff_AACSB	FA ON DMU.FacstaffID = FA.Facstaff_ID 	AND NPR_Masters=1

	UNION

	SELECT DMU.USERNAME,CAST(DMU.FACSTAFFID as varchar) as FACSTAFFID, CAST(DMU.EDWPERSID as varchar) as EDWPERSID 
			,'Research' as NPRESP
	FROM DM_Shadow_Staging.dbo._DM_USERS DMU INNER JOIN Faculty_Staff_Holder.dbo.Facstaff_AACSB	FA ON DMU.FacstaffID = FA.Facstaff_ID 	AND NPR_Research=1

	UNION

	SELECT DMU.USERNAME,CAST(DMU.FACSTAFFID as varchar) as FACSTAFFID, CAST(DMU.EDWPERSID as varchar) as EDWPERSID 
			,'Undergraduate Teaching' as NPRESP
	FROM DM_Shadow_Staging.dbo._DM_USERS DMU INNER JOIN Faculty_Staff_Holder.dbo.Facstaff_AACSB	FA ON DMU.FacstaffID = FA.Facstaff_ID 	AND NPR_Undergrad=1

	UNION

	SELECT DMU.USERNAME,CAST(DMU.FACSTAFFID as varchar) as FACSTAFFID, CAST(DMU.EDWPERSID as varchar) as EDWPERSID 
			,'Other Service and Outreach Responsibilities' as NPRESP
	FROM DM_Shadow_Staging.dbo._DM_USERS DMU INNER JOIN Faculty_Staff_Holder.dbo.Facstaff_AACSB	FA ON DMU.FacstaffID = FA.Facstaff_ID 	AND NPR_Other=1

				
)

--select * from npresp1

INSERT INTO #Updates (m,u,post,username,o,r)
SELECT method m,url u,xml post, USERNAME,o,ROW_NUMBER()OVER(ORDER BY USERNAME,o,url)r
FROM (
	SELECT USERNAME,3 as o,'PUT' method
	    ,'/login/service/v4/UserSchema/USERNAME:'+ USERNAME + '/INDIVIDUAL-ACTIVITIES-Business' as url

		,CAST(
		 (SELECT '2018-2019' AC_YEAR		
			,(
				--NPRESP was implemented as Checkboxes, not DSA, no need to hav XML PATH, instead add the alias NPRESP to be a <NPRESP> tag later
				SELECT  NPRESP 						
				FROM NPRESP1 d WHERE d.username = c.username
				FOR XML PATH(''),TYPE
			 ) 
		 FROM existdept_current_employees c2 WHERE c.username=c2.username
		 FOR XML PATH('ADMIN'),ROOT('INDIVIDUAL-ACTIVITIES-Business'),TYPE) as varchar(MAX)) 
		 as xml


		--,CAST(
		--	(SELECT '2018-2019' AC_YEAR,  NPRESP						
		--	 FROM existdept_current_employees c2 INNER JOIN NPRESP1 np
		--			ON c.username = c2.username AND np.username= c2.username			
		--	 FOR XML PATH('ADMIN'),ROOT('INDIVIDUAL-ACTIVITIES-Business'),TYPE) as varchar(MAX)) 
		-- as xml

	

	FROM existdept_current_employees c
	) x;

-- NO POST to non existent <ADMIN> wrt to the AC_YEAR
-- >>>>>>>>>>>>>>>>>  2. "POST" to create new ADMIN_NPRESP and ADMIN
--				Add to ADMIN (POST): This DM add relies on the most recent _DM_USERS
--				Any record on _DM_USERS that not in _DM_ADMINS will be added ADMIN

--WITH nodept_current_employees AS (
--	SELECT  DISTINCT DMU.USERNAME,DMU.UIN, CAST(DMU.FACSTAFFID as varchar) as FACSTAFFID, CAST(DMU.EDWPERSID as varchar) as EDWPERSID 
--		FROM DM_Shadow_Staging.dbo._DM_USERS DMU
--				INNER JOIN dbo.FSDB_Facstaff_Basic FB
--				ON DMU.FacstaffID = FB.Facstaff_ID
--		WHERE  username not in (SELECT [USERNAME]FROM [DM_Shadow_Staging].[dbo].[_DM_ADMIN] WHERE AC_YEAR='2018-2019')
--				--	DEBUG: commented out this phrase for all FSDB records
--				AND Active_Indicator=1
--),

--npresp2 as (
--	SELECT DMU.USERNAME,CAST(DMU.FACSTAFFID as varchar) as FACSTAFFID, CAST(DMU.EDWPERSID as varchar) as EDWPERSID 
--			,'Administration' as NPRESP
--	FROM DM_Shadow_Staging.dbo._DM_USERS DMU INNER JOIN Faculty_Staff_Holder.dbo.Facstaff_AACSB	FA ON DMU.FacstaffID = FA.Facstaff_ID 	AND NPR_Administration=1

--	UNION

--	SELECT DMU.USERNAME,CAST(DMU.FACSTAFFID as varchar) as FACSTAFFID, CAST(DMU.EDWPERSID as varchar) as EDWPERSID 
--			,'Doctoral Level Teaching/Mentoring' as NPRESP
--	FROM DM_Shadow_Staging.dbo._DM_USERS DMU INNER JOIN Faculty_Staff_Holder.dbo.Facstaff_AACSB	FA ON DMU.FacstaffID = FA.Facstaff_ID 	AND NPR_Doctoral=1

--	UNION

--	SELECT DMU.USERNAME,CAST(DMU.FACSTAFFID as varchar) as FACSTAFFID, CAST(DMU.EDWPERSID as varchar) as EDWPERSID 
--			,'Executive Education' as NPRESP
--	FROM DM_Shadow_Staging.dbo._DM_USERS DMU INNER JOIN Faculty_Staff_Holder.dbo.Facstaff_AACSB	FA ON DMU.FacstaffID = FA.Facstaff_ID 	AND NPR_Executive=1

--	UNION

--	SELECT DMU.USERNAME,CAST(DMU.FACSTAFFID as varchar) as FACSTAFFID, CAST(DMU.EDWPERSID as varchar) as EDWPERSID 
--			,'Master''s Level Teaching' as NPRESP
--	FROM DM_Shadow_Staging.dbo._DM_USERS DMU INNER JOIN Faculty_Staff_Holder.dbo.Facstaff_AACSB	FA ON DMU.FacstaffID = FA.Facstaff_ID 	AND NPR_Masters=1

--	UNION

--	SELECT DMU.USERNAME,CAST(DMU.FACSTAFFID as varchar) as FACSTAFFID, CAST(DMU.EDWPERSID as varchar) as EDWPERSID 
--			,'Research' as NPRESP
--	FROM DM_Shadow_Staging.dbo._DM_USERS DMU INNER JOIN Faculty_Staff_Holder.dbo.Facstaff_AACSB	FA ON DMU.FacstaffID = FA.Facstaff_ID 	AND NPR_Research=1

--	UNION

--	SELECT DMU.USERNAME,CAST(DMU.FACSTAFFID as varchar) as FACSTAFFID, CAST(DMU.EDWPERSID as varchar) as EDWPERSID 
--			,'Undergraduate Teaching' as NPRESP
--	FROM DM_Shadow_Staging.dbo._DM_USERS DMU INNER JOIN Faculty_Staff_Holder.dbo.Facstaff_AACSB	FA ON DMU.FacstaffID = FA.Facstaff_ID 	AND NPR_Undergrad=1

--	UNION

--	SELECT DMU.USERNAME,CAST(DMU.FACSTAFFID as varchar) as FACSTAFFID, CAST(DMU.EDWPERSID as varchar) as EDWPERSID 
--			,'Other Service and Outreach Responsibilities' as NPRESP
--	FROM DM_Shadow_Staging.dbo._DM_USERS DMU INNER JOIN Faculty_Staff_Holder.dbo.Facstaff_AACSB	FA ON DMU.FacstaffID = FA.Facstaff_ID 	AND NPR_Other=1
	
				
--)

----select * from npresp2

---- POST to create new ADMIN_NPRESP
--INSERT INTO #Updates (m,u,post,username,o,r)
--SELECT method m,url u,xml post, USERNAME,o,ROW_NUMBER()OVER(ORDER BY USERNAME,o,url)r
--FROM (
--SELECT USERNAME,3 as o,'POST' method
--	,'/login/service/v4/UserSchema/USERNAME:'+ USERNAME + '/INDIVIDUAL-ACTIVITIES-Business' as url
--	,CAST(
--	 (SELECT '2018-2019' AC_YEAR		
--	  ,(
--		--NPRESP was implemented as Checkboxes, not DSA, no need to hav XM PATH, instead add the alias NPRESP to be a <NPRESP> tag later
--		SELECT  NPRESP
--		FROM NPRESP2 d WHERE d.username = c.username
--		FOR XML PATH(''),TYPE
--		) 
--		FROM nodept_current_employees c2 WHERE c.username=c2.username
--		FOR XML PATH('ADMIN'),ROOT('INDIVIDUAL-ACTIVITIES-Business'),TYPE) as varchar(MAX)
--	  ) as xml
--FROM nodept_current_employees c
--) x
--ORDER BY USERNAME,o







/*
-- works!
SELECT method m,url u,xml post, USERNAME,o,ROW_NUMBER()OVER(ORDER BY USERNAME,o,url)r
INTO #updates
FROM (
	SELECT USERNAME,3 as o,'PUT' method
	    ,'login/service/v4/UserSchema/USERNAME:'+ USERNAME + '/INDIVIDUAL-ACTIVITIES-Business' as url
		,CAST((SELECT '2018-2019' AC_YEAR		
		,(
			SELECT Department_Name as DEP				
			FROM departments d WHERE d.username = c.username
			FOR XML PATH('ADMIN_DEP'),TYPE
		 ) 
		 FROM current_employees c2 WHERE c.username=c2.username
		 FOR XML PATH('ADMIN'),ROOT('INDIVIDUAL-ACTIVITIES-Business'),TYPE) as varchar(MAX)) as xml
	FROM current_employees c
	) x
ORDER BY USERNAME,o
*/

/*
-- works!
SELECT method m,url u,xml post, USERNAME,o,ROW_NUMBER()OVER(ORDER BY USERNAME,o,url)r
INTO #updates
FROM (
	SELECT USERNAME,3 as o,'PUT' method,'login/service/v4/UserSchema/USERNAME:'+ USERNAME + '/INDIVIDUAL-ACTIVITIES-Business' as url,
		CAST((SELECT '2018-2019' AC_YEAR,
			--SELECT CAST(YEAR(GETDATE())AS VARCHAR)+'-'+CAST(YEAR(GETDATE())+1 AS VARCHAR) AC_YEAR,
			(
				SELECT Department_Name as DEP
				FOR XML PATH('ADMIN_DEP'),TYPE
			) FROM departments d WHERE d.username = c.username
		FOR XML PATH('ADMIN'),ROOT('INDIVIDUAL-ACTIVITIES-Business'),TYPE)AS VARCHAR(999)) xml
		/* '<INDIVIDUAL-ACTIVITIES-University><ADMIN>'+
			'<AC_YEAR>'+CAST(YEAR(GETDATE())AS VARCHAR)+'-'+CAST(YEAR(GETDATE())+1 AS VARCHAR)+'</AC_YEAR><ADMIN_DEP>'+
				'<COLLEGE>Education</COLLEGE>'+
				'<DEP>ED:  '+d+'</DEP>'+
			'</ADMIN_DEP>'+
		'</ADMIN></INDIVIDUAL-ACTIVITIES-University>' */
	FROM current_employees c
	) x
ORDER BY USERNAME,o
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
	-- shadow the ADMIN screen to _DM_ADMIN table
	--EXEC dbo.webservices_initiate @screen='ADMIN'

END
ELSE SELECT * FROM #updates

DROP TABLE #updates


--EXEC dbo.webservices_initiate @screen='ADMIN'	



END


GO
