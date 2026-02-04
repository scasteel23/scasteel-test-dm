SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 4/5/2019
--	under construction: Update ADMIN or add new ADMIN records
--	==> Update ADMIN on the following variables RANK, TENURE, EMPTYPE, EMPGROUP, FTE, FTE_EXTERN
--	==> Add new ADMIN records on the following variables AC_YEAR, ADMIN_DEP, RANK, TENURE, EMPTYPE, EMPGROUP, FTE, FTE_EXTERN
--
--	Must download the most recent USER and ADMIN screen data before calling produce_XML_ADMIN_Update_ADMIN_New_Emps
--		DECLARE @Result varchar(1000)
--		EXEC dbo.webservices_initiate @screen='USERS'
--		EXEC dbo.webservices_initiate @screen='ADMIN'
--		EXEC dbo.webservices2_run  @Result = @Result OUTPUT

CREATE PROC [dbo].[produce_XML_ADMIN_Update_ADMIN_New_Emps] ( @submit BIT=0 )
AS


/*

	 Manual run to upload USERS FROM FSDB  -- 6 minutes for 600 records
	 EXEC dbo.[produce_XML_ADMIN_Update_ADMIN_New_Emps] @submit = 0		-- request to upload to DM
	 EXEC dbo.webservices_initiate @screen='ADMIN'						-- request to shadow
	 DECLARE @Result varchar(500)										
	 EXEC dbo.webservices2_run 	Result=Result OUTPUT					-- execute the requests
*/

CREATE TABLE [dbo].#Updates(
	m varchar(10) NOT NULL,
	u varchar(100) NULL,
	post [varchar](MAX) NULL,
	o  int,
	username varchar(60),
	r int
) ;

CREATE TABLE #requests(id INT NOT NULL,method VARCHAR(10),url VARCHAR(255),r INT);

-- Add 2018-2019 ADMIN records : 
--		Compare _DM_USERS and _DM_ADMIN table, whether there are 2018-2019 ADMIN records
-- Update 2019-2019 ADMIN Records : 
--		Compare _DM_ADMIN with FSDB_EDW_Current_Employees : one of (TENURE, EMPTYPE, EMPGROUP, FTE, FTE_EXTERN) changes

-- >>>>>>>>>>>>>>>>>> DEPARTMENT


WITH nodept_current_employees AS (
	SELECT  DISTINCT DMU.USERNAME,DMU.UIN, CAST(DMU.FACSTAFFID as varchar) as FACSTAFFID, CAST(DMU.EDWPERSID as varchar) as EDWPERSID 
		,D.Department_Name as Department_Name 

		FROM DM_Shadow_Staging.dbo._DM_USERS DMU
				INNER JOIN DM_Shadow_Staging.dbo.FSDB_Facstaff_Basic FB
				ON DMU.FacstaffID = FB.Facstaff_ID AND DMU.Enabled_Indicator=1
				INNER JOIN DM_Shadow_Staging.dbo.FSDB_Departments D 
				ON FB.Department_ID = D.Department_ID
		WHERE  username not in (SELECT [USERNAME]FROM [DM_Shadow_Staging].[dbo].[_DM_ADMIN] WHERE AC_YEAR='2018-2019')
)

INSERT INTO #Updates (m,u,post,username,o,r)
SELECT method m,url u,xml post, USERNAME,o,ROW_NUMBER()OVER(ORDER BY USERNAME,o,url)r
FROM (
SELECT USERNAME,3 as o,'POST' method
	,'/login/service/v4/UserSchema/USERNAME:'+ USERNAME + '/INDIVIDUAL-ACTIVITIES-Business' as url
	,CAST((SELECT '2018-2019' AC_YEAR		
	,(
		SELECT Department_Name as DEP				
		FROM nodept_current_employees d WHERE d.username = c.username
		FOR XML PATH('ADMIN_DEP'),TYPE
		) 
		FROM nodept_current_employees c2 WHERE c.username=c2.username
		FOR XML PATH('ADMIN'),ROOT('INDIVIDUAL-ACTIVITIES-Business'),TYPE) as varchar(MAX)) as xml
FROM nodept_current_employees c
) x
ORDER BY USERNAME,o;

IF @submit=1 BEGIN
	
	DELETE FROM #requests

	INSERT INTO webservices_requests(method,url,post,process)
	OUTPUT inserted.id,inserted.method,inserted.url,inserted.process INTO #requests
	SELECT m,u,CAST(post AS VARCHAR(MAX)),r FROM #updates WHERE post IS NOT NULL

	UPDATE webservices_requests SET process=NULL,dependsOn=(
		SELECT TOP 1 id FROM #requests r2 JOIN #updates u2 ON u2.r=r2.r
		WHERE u2.o<u1.o AND u2.USERNAME=u1.USERNAME ORDER BY u2.o DESC)
	FROM webservices_requests
	JOIN #requests r1 ON r1.id=webservices_requests.id
	JOIN #updates u1 ON u1.r=r1.r

	--EXEC dbo.webservices_initiate @screen='ADMIN'

END
ELSE SELECT * FROM #updates

DElETE FROM #Updates;


-- >>>>>>>>>>>>>>>>>> EMPGROUP

DELETE FROM #updates;

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

empgroup1 as (
		SELECT DMU.USERNAME,CAST(DMU.FACSTAFFID as varchar) as FACSTAFFID, CAST(DMU.EDWPERSID as varchar) as EDWPERSID 
			,dbo.DMUPLOAD_fn_Get_ADMIN_EMPGROUP(D.Department_Name, FSB.Faculty_Staff_Indicator, FSB.Doctoral_Flag) as EMPGROUP
	
		FROM dbo.FSDB_Facstaff_Basic FSB
				INNER JOIN DM_Shadow_Staging.dbo._DM_USERS DMU 
				ON DMU.FacstaffID = FSB.Facstaff_ID
				INNER JOIN Faculty_Staff_Holder.dbo.Departments D 
				ON FSB.Department_ID = D.Department_ID 		
				
)

INSERT INTO #Updates (m,u,post,username,o,r)
SELECT method m,url u,xml post, USERNAME,o,ROW_NUMBER()OVER(ORDER BY USERNAME,o,url)r
FROM (
	SELECT USERNAME,3 as o,'PUT' method
	    ,'/login/service/v4/UserSchema/USERNAME:'+ USERNAME + '/INDIVIDUAL-ACTIVITIES-Business' as url
		,CAST(
		 (SELECT '2018-2019' AC_YEAR		
		,(
			--EMPGROUP was implemented as Checkboxes, not DSA, no need to hav XML PATH, instead add the alias EMPTYPE to be a <EMPGROUP> tag later
			SELECT  EMPGROUP 						
			FROM empgroup1 d WHERE d.username = c.username
			FOR XML PATH(''),TYPE
		 ) 
		 FROM existdept_current_employees c2 WHERE c.username=c2.username
		 FOR XML PATH('ADMIN'),ROOT('INDIVIDUAL-ACTIVITIES-Business'),TYPE) as varchar(MAX)) 
		 as xml
	FROM existdept_current_employees c
	) x;

IF @submit=1 BEGIN
		
	INSERT INTO webservices_requests(method,url,post,process)
	OUTPUT inserted.id,inserted.method,inserted.url,inserted.process INTO #requests
	SELECT m,u,CAST(post AS VARCHAR(MAX)),r FROM #updates WHERE post IS NOT NULL

	UPDATE webservices_requests SET process=NULL,dependsOn=(
		SELECT TOP 1 id FROM #requests r2 JOIN #updates u2 ON u2.r=r2.r
		WHERE u2.o<u1.o AND u2.USERNAME=u1.USERNAME ORDER BY u2.o DESC)
	FROM webservices_requests
	JOIN #requests r1 ON r1.id=webservices_requests.id
	JOIN #updates u1 ON u1.r=r1.r

END
ELSE SELECT * FROM #updates

-- PUT to update existing ADMIN_EMPTYPE
-- POST to create new ADMIN_EMPTYPE -- based on _DM_USERS as users to compare with _DM_ADMINS

DELETE FROM #Updates;

-- >>>>>>>>>>>>>>>>>>> EMPTYPE

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

emptype1 as (
		SELECT DMU.USERNAME,CAST(DMU.FACSTAFFID as varchar) as FACSTAFFID, CAST(DMU.EDWPERSID as varchar) as EDWPERSID 
			,CASE WHEN Faculty_Staff_Indicator=1 THEN 'Faculty' 
				WHEN Doctoral_Flag =1 THEN 'PhD Student'
				ELSE 'Staff'
			END as EMPTYPE	
		FROM dbo.FSDB_Facstaff_Basic FSB
				INNER JOIN DM_Shadow_Staging.dbo._DM_USERS DMU 
				ON DMU.FacstaffID = FSB.Facstaff_ID	
				
)


--select * from emptype1

INSERT INTO #Updates (m,u,post,username,o,r)
SELECT method m,url u,xml post, USERNAME,o,ROW_NUMBER()OVER(ORDER BY USERNAME,o,url)r
FROM (
	SELECT USERNAME,3 as o,'PUT' method
	    ,'/login/service/v4/UserSchema/USERNAME:'+ USERNAME + '/INDIVIDUAL-ACTIVITIES-Business' as url
		,CAST(
		 (SELECT '2018-2019' AC_YEAR		
		,(
			--EMPTYPE was implemented as Checkboxes, not DSA, no need to hav XM PATH, instead add the alias EMPTYPE to be a <EMPTYPE> tag later
			SELECT  EMPTYPE 						
			FROM EMPTYPE1 d WHERE d.username = c.username
			FOR XML PATH(''),TYPE
		 ) 
		 FROM existdept_current_employees c2 WHERE c.username=c2.username
		 FOR XML PATH('ADMIN'),ROOT('INDIVIDUAL-ACTIVITIES-Business'),TYPE) as varchar(MAX)) 
		 as xml
	FROM existdept_current_employees c
	) x;

IF @submit=1 BEGIN
	
	DELETE FROM #requests
	
	INSERT INTO webservices_requests(method,url,post,process)
	OUTPUT inserted.id,inserted.method,inserted.url,inserted.process INTO #requests
	SELECT m,u,CAST(post AS VARCHAR(MAX)),r FROM #updates WHERE post IS NOT NULL

	UPDATE webservices_requests SET process=NULL,dependsOn=(
		SELECT TOP 1 id FROM #requests r2 JOIN #updates u2 ON u2.r=r2.r
		WHERE u2.o<u1.o AND u2.USERNAME=u1.USERNAME ORDER BY u2.o DESC)
	FROM webservices_requests
	JOIN #requests r1 ON r1.id=webservices_requests.id
	JOIN #updates u1 ON u1.r=r1.r
	
	-- shadow the ADMIN screen to _DM_ADMIN table
	--EXEC dbo.webservices_initiate @screen='ADMIN'

END
ELSE SELECT * FROM #updates

IF @submit = 1
	EXEC dbo.webservices_initiate @screen='ADMIN'

DROP TABLE #updates
DROP TABLE #requests

GO
