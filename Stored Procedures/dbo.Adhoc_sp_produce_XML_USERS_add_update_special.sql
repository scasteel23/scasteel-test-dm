SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 3/12/2019 added 2018-2019
-- NS 11/20/2018
--	to catch up data, special add (missing records in DM) and update (missing FACSTAFFID, UIN, EDWPERSID)
/*

55 users to update FACSTAFFID, UIN, EDWPERSID
77 users to delete
118 total users to add, but 18 are in FSDB_EDW_Current_Employees and we want to make sure daily process would identify and add them.  (Maybe we would add manually once we know the daily process is putting them all in _UPLOAD_DM_USERS.)
	-	jplarson – already in _UPLOAD_DM_USERS
	-	2 T&M faculty with no KM jobs (from Eng, FAA) – need to update daily process to add these to _UPLOAD_DM_USERS
	-	15 TAs – need to update daily process to add these (more important to make sure we add instructors, but process would be almost the same for TAs; difference is that instructors would be enabled, TAs would be disabled)
	100 users not in Current_Employees, to be added manually (see the new_employees query)
	

*/
/*
 Manual run to upload select USERS (depending on queries to select those users) FROM FSDB
	 EXEC dbo.[produce_XML_USERS_add_update_special] @submit = 0

	 EXEC dbo.[produce_XML_USERS_add_update_special] @submit = 1
	 EXEC dbo.webservices_run_DTSX
*/

CREATE PROC [dbo].[Adhoc_sp_produce_XML_USERS_add_update_special] ( @submit BIT=0 )
AS

BEGIN

WITH updated_current_employees AS (
	-- NS 11/20/2018  (query codes from SC) 55 records updated
	select du.username
	   , du.FacstaffID, du.UIN,  du.EDWPERSID
       , dv.last_name, dv.first_name
	   , dv.facstaff_id as FB_FACSTAFFID, dv.uin as FB_UIN, dv.edw_pers_id as FB_EDWPERSID
	from DM_Shadow_Staging.dbo._DM_USERS du
	left outer join faculty_staff_holder.dbo.dm_users_view dv
		   on dv.network_id = du.username
	where du.username is not null
		   and (dv.facstaff_id <> du.facstaffid
				  or dv.uin <> du.uin
				  or dv.edw_pers_id <> du.EDWPERSID)
),

deleted_employees AS (
	-- NS 11/20/2018  (query codes from SC) 77 records deleted
	select username
	from DM_Shadow_Staging.dbo._DM_USERS du
	left outer join faculty_staff_holder.dbo.dm_users_view dv
		   on dv.network_id = du.username
	where dv.network_id is null
		   and (du.Service_Account_Indicator = 0
				  or du.Service_Account_Indicator is null)

),

--	SELECT FB.network_ID as USERNAME
--		,FB.UIN
--		,CAST(FB.Facstaff_ID as varchar) as FACSTAFFID
--		,CAST(FB.EDW_PERS_ID as varchar) EDWPERSID
--		,FB.First_Name, FB.Middle_Name, FB.Last_Name
----		,ISNULL(REPLACE(D.Department_Name,'IT Partners','Business IT Services'),'') as DEP      
--		,ISNULL(D.Department_Name,'') as DEP      
--		,'true' as [Enabled]
--	FROM Faculty_Staff_Holder.dbo.Facstaff_Basic FB
--			LEFT OUTER JOIN Faculty_Staff_Holder.dbo.Departments D 
--			ON FB.Department_ID = D.Department_ID 
--	WHERE FB.Active_Indicator=1 and FB.BUS_Person_Indicator=1
--		AND Network_ID in (select username from dbo._UPLOAD_DM_USERS) -- can use dbo._UPLOAD_DM_USERS to confirm network ID of legit current emps that can be uploaded to DM

new_employees as (
	-- NS 11/21/2018  (query codes from SC) 118 records
	select dv.UIN, dv.Network_ID as USERNAME, dv.Facstaff_ID as FACSTAFFID, dv.EDW_PERS_ID as EDWPERSID
		,ISNULL(D.Department_Name,'') as DEP     
		,dv.First_Name as FIRST_NAME, dv.Middle_Name as MIDDLE_NAME, dv.Last_Name as LAST_NAME
		,[Enabled]
	from faculty_staff_holder.dbo.dm_users_view dv
		left outer join DM_Shadow_Staging.dbo._DM_USERS du
		   on dv.network_id = du.username
		LEFT OUTER JOIN Faculty_Staff_Holder.dbo.Departments D 
			ON dv.Department_ID = D.Department_ID 
	where du.username is null
		   and edw_pers_id not in (
				  select edw_pers_id from faculty_Staff_Holder.dbo.EDW_Current_Employees
				  where New_Download_Indicator = 1
		   )


),
new_employees_for_pci as (
	-- NS 11/21/2018 (query codes done by NS) 99 PCI records could not be created after new user uploads
	select top 99 dv.UIN, dv.Network_ID as USERNAME, dv.Facstaff_ID as FACSTAFFID, dv.EDW_PERS_ID as EDWPERSID
		,ISNULL(D.Department_Name,'') as DEP     
		,dv.First_Name as FIRST_NAME, dv.Middle_Name as MIDDLE_NAME, dv.Last_Name as LAST_NAME
		,[Enabled]
		,Update_Datetime
	from faculty_staff_holder.dbo.dm_users_view dv
		left outer join DM_Shadow_Staging.dbo._DM_USERS du
		   on dv.network_id = du.username
		LEFT OUTER JOIN Faculty_Staff_Holder.dbo.Departments D 
			ON dv.Department_ID = D.Department_ID 
	order by  Update_Datetime desc


),
employeees_to_enable as (
	-- NS 11/22/2018  (query codes from SC) 65 users to enable (58 current employees, mostly HA + some probably recent re-entry, and 7 with Manual = 1) 
	select dv.UIN, dv.Network_ID as USERNAME, dv.Facstaff_ID as FACSTAFFID, dv.EDW_PERS_ID as EDWPERSID		
		,dv.First_Name as FIRST_NAME, dv.Middle_Name as MIDDLE_NAME, dv.Last_Name as LAST_NAME
		,[Enabled]
	from faculty_staff_holder.dbo.dm_users_view dv
	inner join DM_Shadow_Staging.dbo._DM_USERS du
		   on dv.network_id = du.username
	where dv.[Enabled] = 1 and du.Enabled_Indicator = 0

),
employeees_to_disable as (
	-- NS 11/22/2018  (query codes from SC) 93 users to disabled, includes 90 not in Current Employees, 2 current TAs, and 1 Manual Law faculty dissociated from COB for bad behavior.
	select dv.UIN, dv.Network_ID as USERNAME, dv.Facstaff_ID as FACSTAFFID, dv.EDW_PERS_ID as EDWPERSID  
		,dv.First_Name as FIRST_NAME, dv.Middle_Name as MIDDLE_NAME, dv.Last_Name as LAST_NAME
		,[Enabled]
		from faculty_staff_holder.dbo.dm_users_view dv
	inner join DM_Shadow_Staging.dbo._DM_USERS du
		   on dv.network_id = du.username
	where dv.[Enabled] = 0 and du.Enabled_Indicator = 1

)
,
employees_2018_2019 as (
	-- NS 3/12/2019 : 597 are both enabled in dm_users_view and _DM_USERS, 607 are enabled in dm_users_view
	select dv.UIN, dv.Network_ID as USERNAME, dv.Facstaff_ID as FACSTAFFID, dv.EDW_PERS_ID as EDWPERSID  
		,dv.First_Name as FIRST_NAME, dv.Middle_Name as MIDDLE_NAME, dv.Last_Name as LAST_NAME
		,[Enabled]
		,ISNULL(d.Department_Name,'') as DEP      
	from faculty_staff_holder.dbo.dm_users_view dv
			INNER JOIN DM_Shadow_Staging.dbo._DM_USERS du
				on dv.network_id = du.username
			LEFT OUTER JOIN DM_Shadow_Staging.dbo.FSDB_Departments D 
			ON dv.Department_ID = D.Department_ID 
	where dv.[Enabled] = 1 and du.Enabled_Indicator = 1		
		

),
redo_employees_2018_2019 as (
	-- NS 3/12/2019 : 254 from 597 uploaded, the rest are failed?
	select dv.UIN, dv.Network_ID as USERNAME, dv.Facstaff_ID as FACSTAFFID, dv.EDW_PERS_ID as EDWPERSID  
		,dv.First_Name as FIRST_NAME, dv.Middle_Name as MIDDLE_NAME, dv.Last_Name as LAST_NAME
		,[Enabled]
		,ISNULL(d.Department_Name,'') as DEP      
	from faculty_staff_holder.dbo.dm_users_view dv
			INNER JOIN DM_Shadow_Staging.dbo._DM_USERS du
				on dv.network_id = du.username
			LEFT OUTER JOIN Faculty_Staff_Holder.dbo.Departments D 
			ON dv.Department_ID = D.Department_ID 
	where dv.[Enabled] = 1 and du.Enabled_Indicator = 1
			and dv.Network_ID  NOT IN (select username from dbo._DM_ADMIN where AC_YEAR='2018-2019')

)

-- UPDATE <ADMIN>
SELECT method m,url u,xml post, USERNAME,o,ROW_NUMBER()OVER(ORDER BY USERNAME,o,url)r
INTO #updates
FROM (

	SELECT USERNAME,3 o,'PUT' method,'/login/service/v4/UserSchema/USERNAME:'+ USERNAME + '/INDIVIDUAL-ACTIVITIES-Business' as url,
		CAST((SELECT 
			--CAST(YEAR(GETDATE())AS VARCHAR)+'-'+CAST(YEAR(GETDATE())+1 AS VARCHAR)AC_YEAR,
			'2018-2019' AC_YEAR	,
			(
				SELECT DEP
				-- NS 3/7/2017: <COLLEGE> is no longer working
				--SELECT 'Business' COLLEGE,'ED:  '+dept DEP
				---- DEBUG
				--SELECT 'ED: (external) Human & Community Development' DEP
				FOR XML PATH('ADMIN_DEP'),TYPE
			)
		FOR XML PATH('ADMIN'),ROOT('INDIVIDUAL-ACTIVITIES-Business'),TYPE)AS VARCHAR(MAX)) xml
		/* '<INDIVIDUAL-ACTIVITIES-University><ADMIN>'+
			'<AC_YEAR>'+CAST(YEAR(GETDATE())AS VARCHAR)+'-'+CAST(YEAR(GETDATE())+1 AS VARCHAR)+'</AC_YEAR><ADMIN_DEP>'+
				'<COLLEGE>Education</COLLEGE>'+
				'<DEP>ED:  '+d+'</DEP>'+
			'</ADMIN_DEP>'+
		'</ADMIN></INDIVIDUAL-ACTIVITIES-University>' */
	FROM employees_2018_2019

-- Add <ADMIN>
--SELECT method m,url u,xml post, USERNAME,o,ROW_NUMBER()OVER(ORDER BY USERNAME,o,url)r
--INTO #updates
--FROM (

--	SELECT USERNAME,3 o,'POST' method,'/login/service/v4/UserSchema/USERNAME:'+ USERNAME + '/INDIVIDUAL-ACTIVITIES-Business' as url,
--		CAST((SELECT 
--			--CAST(YEAR(GETDATE())AS VARCHAR)+'-'+CAST(YEAR(GETDATE())+1 AS VARCHAR)AC_YEAR,
--			'2018-2019' AC_YEAR	,
--			(
--				SELECT DEP
--				-- NS 3/7/2017: <COLLEGE> is no longer working
--				--SELECT 'Business' COLLEGE,'ED:  '+dept DEP
--				---- DEBUG
--				--SELECT 'ED: (external) Human & Community Development' DEP
--				FOR XML PATH('ADMIN_DEP'),TYPE
--			)
--		FOR XML PATH('ADMIN'),ROOT('INDIVIDUAL-ACTIVITIES-Business'),TYPE)AS VARCHAR(MAX)) xml
--		/* '<INDIVIDUAL-ACTIVITIES-University><ADMIN>'+
--			'<AC_YEAR>'+CAST(YEAR(GETDATE())AS VARCHAR)+'-'+CAST(YEAR(GETDATE())+1 AS VARCHAR)+'</AC_YEAR><ADMIN_DEP>'+
--				'<COLLEGE>Education</COLLEGE>'+
--				'<DEP>ED:  '+d+'</DEP>'+
--			'</ADMIN_DEP>'+
--		'</ADMIN></INDIVIDUAL-ACTIVITIES-University>' */
--	FROM employees_2018_2019


	-- >>>>>>>>>>>>>>>>>> UPDATE  UINs, FACSTAFFID, and EDWPERSIDs
	-- NS 11/20/2018  55 records updated
	--SELECT b.USERNAME,1 o,'PUT'method,'/login/service/v4/User/USERNAME:'+a.username url,
	--	'<User UIN="' + CAST(b.FB_UIN as varchar) + '" FacstaffID="' +  CAST(b.FB_FACSTAFFID as varchar)  + '" EDWPERSID="' +  CAST(b.FB_EDWPERSID as varchar)  + '"></User>' xml
	--FROM _DM_USERS a
	--	JOIN updated_current_employees b ON b.USERNAME=a.username



	----NS 11/21/2018
	---->>>>>>>>>>>>>>>>>>> DELETE users  
	---- NS 11/20/2018 77 records deleted
	--SELECT b.username as NETID,1 o,'DELETE' method,'/login/service/v4/User/USERNAME:'+b.username url,
	--	'' xml
	--FROM _DM_USERS b
	--WHERE b.username IN (SELECT username FROM deleted_employees)
	--		and (B.Service_Account_Indicator IS null or B.Service_Account_Indicator <> 1)



	-- NS 11/21/2018
	-- >>>>>>>>>>>>>>>>>>>> NEW EMPLOYEES
	-- Assign new users to their department

	-- Create new users
	--SELECT USERNAME,2 o,'POST' method,'/login/service/v4/User/' url, 
	--	(SELECT USERNAME "@username", UIN "@UIN", [Enabled] "@enabled" , FacstaffID "@FacstaffID", EDWPERSID "@EDWPERSID",
	--		First_Name FirstName,Middle_Name MiddleName,Last_Name LastName,
	--		USERNAME+'@illinois.edu' Email,
	--		''ShibbolethAuthentication
	--	FOR XML PATH('User')) xml
	--FROM new_employees

	--UNION

	---- Add department and YEAR
	--SELECT USERNAME,3 o,'POST' method,'/login/service/v4/UserSchema/USERNAME:'+ USERNAME + '/INDIVIDUAL-ACTIVITIES-Business' as url,
	--	CAST((SELECT 
	--		--CAST(YEAR(GETDATE())AS VARCHAR)+'-'+CAST(YEAR(GETDATE())+1 AS VARCHAR)AC_YEAR,
	--		'2017-2018' AC_YEAR	,
	--		(
	--			SELECT DEP
	--			-- NS 3/7/2017: <COLLEGE> is no longer working
	--			--SELECT 'Business' COLLEGE,'ED:  '+dept DEP
	--			---- DEBUG
	--			--SELECT 'ED: (external) Human & Community Development' DEP
	--			FOR XML PATH('ADMIN_DEP'),TYPE
	--		)
	--	FOR XML PATH('ADMIN'),ROOT('INDIVIDUAL-ACTIVITIES-Business'),TYPE)AS VARCHAR(MAX)) xml
	--	/* '<INDIVIDUAL-ACTIVITIES-University><ADMIN>'+
	--		'<AC_YEAR>'+CAST(YEAR(GETDATE())AS VARCHAR)+'-'+CAST(YEAR(GETDATE())+1 AS VARCHAR)+'</AC_YEAR><ADMIN_DEP>'+
	--			'<COLLEGE>Education</COLLEGE>'+
	--			'<DEP>ED:  '+d+'</DEP>'+
	--		'</ADMIN_DEP>'+
	--	'</ADMIN></INDIVIDUAL-ACTIVITIES-University>' */
	--FROM new_employees


	--UNION

	---- Give them the "Faculty" security role
	--SELECT USERNAME,3 o,'POST' method,'/login/service/v4/UserRole/USERNAME:'+USERNAME,
	--	'<INDIVIDUAL-ACTIVITIES-Business-Faculty />'
	--FROM new_employees
	
	--UNION

	---- Fill in their Personal Information
	----UNION SELECT NETID,3,'POST','/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:'+NETID+'/PCI',
	--SELECT USERNAME,3 o,'POST' method,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:'+USERNAME+'/PCI' url,
	--	CAST((
	--		SELECT USERNAME "@username",(SELECT
	--			First_Name FNAME,
	--			Middle_Name MNAME,
	--			Last_Name LNAME,
	--			USERNAME+'@illinois.edu' EMAIL
	--			FOR XML PATH('PCI'),TYPE
	--		)FOR XML PATH('Record'),ROOT('Data')
	--	)AS VARCHAR(MAX)) xml
	--FROM new_employees



	----NS 11/21/2018 
	---- >>>>>>>>>>>>>>>>>>>>> SPECIAL UPLOAD FOR PCI
	--SELECT USERNAME,3 o,'POST' method,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:'+USERNAME+'/PCI' url,
	--	CAST((
	--		SELECT USERNAME "@username",(SELECT
	--			First_Name FNAME,
	--			Middle_Name MNAME,
	--			Last_Name LNAME,
	--			USERNAME+'@illinois.edu' EMAIL
	--			FOR XML PATH('PCI'),TYPE
	--		)FOR XML PATH('Record'),ROOT('Data')
	--	)AS VARCHAR(MAX)) xml
	--FROM new_employees_for_pci


	---- NS 11/22/2018
	---- >>>>>>>>>>>>>>>>>>>>>>> Disable and Enable users
	--SELECT b.username,1 o,'PUT'method,'/login/service/v4/User/USERNAME:'+b.username url,
	--	'<User enabled="false"></User>' xml
	--FROM _DM_USERS b
	--WHERE b.username  IN (SELECT username FROM employeees_to_disable)

	--UNION

	--SELECT b.username,1 o,'PUT'method,'/login/service/v4/User/USERNAME:'+b.username url,
	--	'<User enabled="true"></User>' xml
	--FROM _DM_USERS b
	--WHERE b.username  IN (SELECT username FROM employeees_to_enable)

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
		
	-- DOWNLOAD USERS INTO _DM_USERS
	EXEC dbo.webservices_initiate @screen='USERS'

END
ELSE SELECT * FROM #updates

DROP TABLE #updates


--EXEC dbo.webservices_initiate @screen='USERS'	



END


GO
