SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 4/15/2019:
--	Do not deactivate record whose KEEP_ACTIVE='Yes' 
-- NS 8/11/2017: Worked
--	Disable users when he/she is no longer in Bus employment with the exception of KEEP_ACTIVE='Yes'

CREATE PROC [dbo].[produce_XML_USERS_deactivate] ( @submit BIT=0 )
AS

/*

	 Test the results
	 EXEC dbo.[produce_XML_USERS_deactivate] @submit = 0

	 Manual run to upload USERS FROM FSDB

	 DECLARE @Result varchar(1000)
	 EXEC dbo._1PHASE2_sp_DM_Upload_Update_or_Add_Users_From_Facstaff_Basic
	 EXEC dbo.[produce_XML_USERS_deactivate] @submit = 1
	 EXEC dbo.webservices2_run @Result = @Result OUTPUT 

*/
/*

	PUT
	https://www.digitalmeasures.com/login/service/v4/User/USERNAME:{networkid}
	<User enabled="true"></User>

	PUT
	https://www.digitalmeasures.com/login/service/v4/User/USERNAME:{networkid}
	<User enabled="false"></User>



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

print 'start produce_XML_USERS_deactivate';

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
				-- DEBUG: to disable a particular current academics
				-- AND Network_ID <> 'cxchen'
		--ORDER BY Network_id			
					
),
-- FIND status of KEEP_ACTIVE of the latest AC_YEAR, and from them just geet where KEEP_ACTIVE='Yes'
--	DO NOT deactivate those username even though BANNER does not include them as GiesBusiness emps
Latest_Keep_Active AS (
	SELECT m1.username, ISNULL(m1.KEEP_ACTIVE,'') as KEEP_ACTIVE, m1.AC_YEAR
	FROM DM_Shadow_Staging.dbo._DM_ADMIN m1
			LEFT JOIN DM_Shadow_Staging.dbo._DM_ADMIN m2
			ON m1.USERNAME = m2.USERNAME  AND m1.AC_YEAR < m2.AC_YEAR
				AND m1.USERNAME is not NULL		
	WHERE m2.AC_YEAR is NULL AND m1.KEEP_ACTIVE='YES' AND m1.USERNAME is not NULL
)

/*
	>>>> See list of new users to upload to DM:

			
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


SELECT method m,url u,xml post, NETID,o,ROW_NUMBER()OVER(ORDER BY NETID,o,url)r, EDWPERSID
INTO #deactivates
FROM (

	---- Deactivate users
	SELECT b.username as NETID,1 o,'PUT'method,'/login/service/v4/User/USERNAME:'+b.username url,
		'<User enabled="false"></User>' xml, b.EDWPERSID
	FROM _DM_USERS b
	WHERE b.username NOT IN (SELECT NETID FROM current_employees)
			and (B.Service_Account_Indicator IS null or B.Service_Account_Indicator <> 1)
			and b.Enabled_Indicator=1
			and b.username not IN ('mpainter','nhadi','scasteel','jonker')
			and b.username not in (SELECT username FROM Latest_Keep_Active)

)x
ORDER BY NETID,o

DECLARE @cc as INT
SELECT @cc = count(*)
FROM #deactivates

DECLARE @edwpersid_table as FSDB_DM_Upload_EDWPERSID_activity

IF @submit=1 BEGIN
	--	DO NOT deactivate any users when there are 50 or more deactivated.
	--	This is to guard unexpected datavase corruption or errors
	--	Batch deactivation for stident workers will be done separately

	IF @cc < 50  BEGIN	
--	IF @cc < 150  BEGIN	

		CREATE TABLE #requests(id INT NOT NULL,method VARCHAR(10),url VARCHAR(255),r INT)
	
		INSERT INTO webservices_requests(method,url,post,process)
		OUTPUT inserted.id,inserted.method,inserted.url,inserted.process INTO #requests
		SELECT m,u,CAST(post AS VARCHAR(MAX)),r 
		FROM #deactivates 
		WHERE post IS NOT NULL

		UPDATE webservices_requests SET process=NULL,dependsOn=(
			SELECT TOP 1 id FROM #requests r2 JOIN #deactivates u2 ON u2.r=r2.r
			WHERE u2.o<u1.o AND u2.NETID=u1.NETID ORDER BY u2.o DESC)
		FROM webservices_requests
		JOIN #requests r1 ON r1.id=webservices_requests.id
		JOIN #deactivates u1 ON u1.r=r1.r

		INSERT INTO @edwpersid_table (EDWPERSID)
		SELECT EDWPERSID FROM #deactivates
		EXEC dbo.FSDB_DM_Upload_Logs_record_Log @edwpersid_table, 'Deactivated'

		DROP TABLE #requests
	END
	
END
ELSE 
	BEGIN
		SELECT * FROM #deactivates

		INSERT INTO @edwpersid_table (EDWPERSID)
		SELECT EDWPERSID FROM #deactivates
		EXEC dbo.FSDB_DM_Upload_Logs_record_Log @edwpersid_table, 'Deactivated'

		--SELECT * FROM @edwpersid_table

	END



DROP TABLE #deactivates

-- EXEC dbo.produce_XML_USERS_deactivate @submit = 0
-- EXEC dbo.produce_XML_USERS_deactivate @submit = 1
END


GO
