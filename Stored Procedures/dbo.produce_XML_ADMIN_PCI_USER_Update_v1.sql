SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 5/8/2019: 
--		UNDER CONSTRUCTION: Need to update ADMIN_DEP, ADMIN_EMPTYPE, ADMIN_EMPGROUP when DM is empty resp.f
-- NS 4/25/2019

CREATE PROC [dbo].[produce_XML_ADMIN_PCI_USER_Update_v1] ( @submit BIT=0 )
AS


/*
	
	 1) UPDATE USER screen
	 2) UPDATE ADMIN screen related to AC_YEAR='2018-2019'; ADMIN, ADMIN_DEP, ADMIN_EMPTYPE, ADMIN_EMPGROUP
	 3) UPDATE PCI screen
	  
	 Test
	 EXEC dbo.produce_XML_ADMIN_PCI_USER_Update_v1 @submit = 0

	 Manual run to upload USERS FROM FSDB  -- 6 minutes for 600 records
	 DECLARE @Result varchar(2000)
	 EXEC dbo.produce_XML_ADMIN_PCI_USER_Update @submit = 1
	 EXEC dbo.webservices2_run @Result = @Result OUTPUT 
 
 
*/

/*
<INDIVIDUAL-ACTIVITIES-Business>
<ADMIN>
<AC_YEAR>2017-2018</AC_YEAR>
<ADMIN_DEP><DEP>Business IT Services</DEP></ADMIN_DEP>
</ADMIN>
<ADMIN>
<AC_YEAR>2017-2018</AC_YEAR>
<ADMIN_DEP><DEP>iMBA</DEP></ADMIN_DEP>
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

-- PUT to update existing ADMIN_DEP
-- POST to create new ADMIN_DEP -- based on _DM_USERS as users to compare with _DM_ADMINS

CREATE TABLE [dbo].#Updates(
	m varchar(10) NOT NULL,
	u varchar(100) NULL,
	post [varchar](MAX) NULL,
	o  int,
	username varchar(60),
	r int
) ;

DECLARE @AC_YEAR varchar(11)
SET @AC_YEAR= '2018-2019'

---- >>>>>>>>>>>>>>>>>> "PUT" to update existing ADMIN_DEP, ADMIN_PROG, ADMIN_NPRESP, ADMIN_EMPTYPE, ADMIN_EMPGROUP, ADMIN_TITLE
----			Update to ADMIN (PUT): This DM update relies on the most recent _DM_ADMIN and FSDB_Facstaff_Basic
----			Any record in _DM_ADMIN will get updates if the user exist in _DM_BANNER

--WITH existdept_current_employees AS (
--		-- Existing user records at DM on  _DM_USERS table
--		SELECT  DISTINCT DMU.USERNAME,DMU.UIN, CAST(DMU.FACSTAFFID as varchar) as FACSTAFFID, CAST(DMU.EDWPERSID as varchar) as EDWPERSID 
--			,ISNULL(D.Department_Name,'') as Department_Name  
--		FROM DM_Shadow_Staging.dbo._DM_USERS DMU
--				INNER JOIN dbo.FSDB_Facstaff_Basic FB
--				ON DMU.FacstaffID = FB.Facstaff_ID
--				LEFT OUTER JOIN dbo.FSDB_Departments D 
--				ON FB.Department_ID = D.Department_ID
--		WHERE  username in (SELECT [USERNAME]FROM [DM_Shadow_Staging].[dbo].[_DM_ADMIN] WHERE AC_YEAR='2018-2019')
--),
--departments1 as (
--		-- users vs departments in FSDB Facstaff_Basic
--		SELECT DMU.USERNAME,CAST(DMU.FACSTAFFID as varchar) as FACSTAFFID, CAST(DMU.EDWPERSID as varchar) as EDWPERSID 
--			,FSJD.Department_ID as Department_ID
--			,REPLACE(D.Department_Name,'IT Partners','Business IT Services') as Department_Name       
--		FROM Faculty_Staff_Holder.dbo.Facstaff_Joint_Departments FSJD
--				INNER JOIN DM_Shadow_Staging.dbo._DM_USERS DMU 
--				ON DMU.FacstaffID = FSJD.Facstaff_ID
--				INNER JOIN Faculty_Staff_Holder.dbo.Departments D 
--				ON FSJD.Department_ID = D.Department_ID 

--		UNION
--		SELECT DMU.USERNAME,CAST(DMU.FACSTAFFID as varchar) as FACSTAFFID, CAST(DMU.EDWPERSID as varchar) as EDWPERSID 
--			,FSB.Department_ID as Department_ID
--			,REPLACE(D.Department_Name,'IT Partners','Business IT Services') as Department_Name     
--		FROM Faculty_Staff_Holder.dbo.Facstaff_Basic FSB
--				INNER JOIN DM_Shadow_Staging.dbo._DM_USERS DMU 
--				ON DMU.FacstaffID = FSB.Facstaff_ID
--				INNER JOIN Faculty_Staff_Holder.dbo.Departments D 
--				ON FSB.Department_ID = D.Department_ID 
--)
---- select * from departments1

--INSERT INTO #Updates (m,u,post,username,o,r)
--SELECT method m,url u,xml post, USERNAME,o,ROW_NUMBER()OVER(ORDER BY USERNAME,o,url)r
--FROM (
--	SELECT USERNAME,3 as o,'PUT' method
--	    ,'/login/service/v4/UserSchema/USERNAME:'+ USERNAME + '/INDIVIDUAL-ACTIVITIES-Business' as url
--		,CAST((SELECT '2018-2019' AC_YEAR		
--		,(
--			SELECT Department_Name as DEP				
--			FROM departments1 d WHERE d.username = c.username
--			FOR XML PATH('ADMIN_DEP'),TYPE
--		 ) 
--		 FROM existdept_current_employees c2 WHERE c.username=c2.username
--		 FOR XML PATH('ADMIN'),ROOT('INDIVIDUAL-ACTIVITIES-Business'),TYPE) as varchar(MAX)) 
--		 as xml
--	FROM existdept_current_employees c
--	) x;


DECLARE @TempTemp as TABLE
	(		username	varchar(60),
		    edw_pers_id bigint,
			facstaff_id bigint,
			UIN varchar(9) NULL,

			EMPEE_DEPT_CD varchar(6) NULL,
			EMPEE_DEPT_NAME varchar(35) NULL,
			EMPEE_CLS_CD varchar(2) NULL,
			EMPEE_CLS_LONG_DESC varchar(30) NULL,
			POSN_EMPEE_CLS_CD varchar(2) NULL,
			POSN_EMPEE_CLS_LONG_DESC varchar(30) NULL,
			EMPEE_GROUP_CD varchar(4) NULL,
			EMPEE_GROUP_DESC varchar(30) NULL,
			POSN_NBR varchar(6) NULL,
			JOB_DETL_DEPT_CD varchar(4) NULL,
			JOB_DETL_DEPT_NAME varchar(35) NULL,
			JOB_DETL_TITLE varchar(30) NULL,
			JOB_DETL_FTE decimal(9, 0) NULL,
			JOB_CNTRCT_TYPE_DESC varchar(20) NULL,
			JOB_SUFFIX varchar(2) NULL,
			EMPTYPE varchar(30) NULL,
			EMPGROUP varchar(50) NULL,

			FAC_RANK_CD varchar(2) NULL,
			FAC_RANK_DESC varchar(35) NULL,	-- do not account 'Research*','Administrative', and 'Unreported'
			FAC_RANK_ACT_DT datetime NULL,
			FAC_RANK_DECN_DT datetime NULL,
			FAC_RANK_ACAD_TITLE varchar(200) NULL,
			FAC_RANK_EMRTS_STATUS_IND varchar(1) NULL,
			Email_Address varchar(100) NULL,
			College_Sum_FTE int NULL,
			Univ_Sum_FTE int NULL,
			Extern_Sum_FTE int NULL,
			DM_Department_Name varchar(100) NULL,

			Last_Name varchar(30) NOT NULL,
			PERS_MNAME varchar(30) NULL,
			Middle_Name varchar(30) NULL,
			First_Name varchar(30) NULL,
			PERS_PREFERRED_FNAME varchar(15) NULL,

			Campus_Wide_Appointment_Percent int NULL,
			Appointment_Percent int NULL,
			Tenure varchar(100) NULL,

			[Rank] varchar(100) NULL,
			Ethnicity varchar(50) NULL,
			Citizenship varchar(50) NULL,
			Gender varchar(10) NULL,
			Birth_Date datetime NULL,

			Update_PCI bit NULL,
			Update_ADMIN bit NULL,
			Update_USER bit NULL,
			Update_ADMIN_DEP bit NULL,
			Update_ADMIN_EMPTYPE bit NULL,
			Update_ADMIN_EMPGROUP bit NULL
	)

INSERT INTO @TempTemp (
	  username
	  ,edw_pers_id
	  ,facstaff_id
	  ,UIN

	  ,EMPEE_DEPT_CD
      ,EMPEE_DEPT_NAME
      ,EMPEE_CLS_CD
      ,EMPEE_CLS_LONG_DESC
      ,POSN_EMPEE_CLS_CD
      ,POSN_EMPEE_CLS_LONG_DESC
      ,EMPEE_GROUP_CD
      ,EMPEE_GROUP_DESC
      ,POSN_NBR
      ,JOB_DETL_DEPT_CD
      ,JOB_DETL_DEPT_NAME
      ,JOB_DETL_TITLE
      ,JOB_DETL_FTE
      ,JOB_CNTRCT_TYPE_DESC
      ,JOB_SUFFIX
	  ,EMPTYPE
	  ,EMPGROUP

      ,FAC_RANK_CD
      ,FAC_RANK_DESC
      ,FAC_RANK_ACT_DT
      ,FAC_RANK_DECN_DT
      ,FAC_RANK_ACAD_TITLE
      ,FAC_RANK_EMRTS_STATUS_IND
      ,Email_Address
      ,College_Sum_FTE
      ,Univ_Sum_FTE
	  ,DM_Department_Name

	  ,Last_Name
      ,PERS_MNAME
      ,Middle_Name
      ,First_Name
      ,PERS_PREFERRED_FNAME

	  ,Campus_Wide_Appointment_Percent
      ,Appointment_Percent
	  ,[Tenure]
	  ,[Rank]

	  ,Ethnicity
      ,Citizenship
      ,Gender
      ,Birth_Date

	  ,Update_PCI, Update_ADMIN, Update_USER, Update_ADMIN_DEP, Update_ADMIN_EMPTYPE, Update_ADMIN_EMPGROUP
)
SELECT Network_ID
	  ,edw_pers_id
	  ,facstaff_id
	  ,UIN

	  ,EMPEE_DEPT_CD
      ,EMPEE_DEPT_NAME
      ,EMPEE_CLS_CD
      ,EMPEE_CLS_LONG_DESC
      ,POSN_EMPEE_CLS_CD
      ,POSN_EMPEE_CLS_LONG_DESC
      ,EMPEE_GROUP_CD
      ,EMPEE_GROUP_DESC
      ,POSN_NBR
      ,JOB_DETL_DEPT_CD
      ,JOB_DETL_DEPT_NAME
      ,JOB_DETL_TITLE
      ,JOB_DETL_FTE
      ,JOB_CNTRCT_TYPE_DESC
      ,JOB_SUFFIX
	  ,CASE WHEN Faculty_Staff_Indicator=1 THEN 'Faculty' 
				WHEN Doctoral_Flag =1 THEN 'PhD Student'
				ELSE 'Staff'
			END as EMPTYPE	
	  ,dbo.DMUPLOAD_fn_Get_ADMIN_EMPGROUP(DM_Department_Name, FB.Faculty_Staff_Indicator, FB.Doctoral_Flag) as EMPGROUP

      ,FAC_RANK_CD
      ,FAC_RANK_DESC
      ,FAC_RANK_ACT_DT
      ,FAC_RANK_DECN_DT
      ,FAC_RANK_ACAD_TITLE
      ,FAC_RANK_EMRTS_STATUS_IND
      ,CASE WHEN Network_ID IS NULL THEN ''
			WHEN Network_ID = '' THEN ''
			ELSE Network_ID + '@illinois.edu' END as Email_Address
      ,College_Sum_FTE
      ,Univ_Sum_FTE
	  ,DM_Department_Name

	  ,Last_Name 
      ,PERS_MNAME
      ,Middle_Name
      ,First_Name
      ,PERS_PREFERRED_FNAME

	  ,Campus_Wide_Appointment_Percent
      ,Appointment_Percent
	  ,CASE WHEN Tenure_Status_Indicator is NULL THEN '' 
			WHEN Tenure_Status_Indicator = 1 THEN 'Tenure-Track'  
			ELSE 'Non-Tenure Track' END AS Tenure
	  --,FAC_RANK_DESC
	  ,CASE WHEN FAC_RANK_DESC NOT LIKE 'Research%' AND FAC_RANK_DESC NOT IN ('Administrative','Unreported')
				THEN FAC_RANK_DESC
			ELSE '' END as [Rank]
	  ,dbo.DailyUpdate_fn_Get_DM_Ethnicity(Ethnicity_ID) as ETHNICITY 
      ,PERS_CITZN_TYPE_DESC
      ,CASE WHEN Gender='M' THEN 'Male'
			WHEN Gender = 'F' THEN 'Female'
			ELSE '' END as Gender
      ,Birth_Date

	  ,0,0,0,0,0,0

FROM DM_Shadow_Staging.dbo.FSDB_Facstaff_Basic FB 
		INNER JOIN  DM_Shadow_Staging.dbo._DM_ADMIN DMA
		ON FB.EDW_PERS_ID = DMA.EDWPERSID AND DMA.AC_YEAR=@AC_YEAR;

-- Adjust some fsdb data
UPDATE @TempTemp
SET Extern_Sum_FTE=UNIV_sum_fte-College_sum_fte
WHERE UNIV_sum_fte is not NULL and College_sum_fte is not null and UNIV_sum_fte >= College_sum_fte

UPDATE @TempTemp
SET Extern_Sum_FTE=0
WHERE UNIV_sum_fte is not NULL and College_sum_fte is not null and UNIV_sum_fte < College_sum_fte

UPDATE dbo._DM_ADMIN
SET [RANK] = ISNULL([RANK],'')	
		,Tenure = ISNULL(Tenure,'')
WHERE AC_YEAR=@AC_YEAR

-- Make the source of update the same with DM for the following conditions

-- Set fsdb fte = dm fte if fsdb fte is null
UPDATE @TempTemp
SET College_Sum_FTE = dma.FTE
FROM @TempTemp T INNER JOIN DM_Shadow_Staging.dbo._DM_ADMIN dma
			ON T.username = dma.username AND DMA.AC_YEAR=@AC_YEAR
WHERE T.College_Sum_FTE is NULL AND dma.FTE is not NULL

UPDATE @TempTemp
SET Extern_Sum_FTE = dma.FTE_EXTERN
FROM @TempTemp T INNER JOIN DM_Shadow_Staging.dbo._DM_ADMIN dma
			ON T.username = dma.username AND DMA.AC_YEAR=@AC_YEAR
WHERE T.Extern_Sum_FTE is NULL AND dma.FTE_EXTERN is not NULL

-- Set to NULL when fsdb fte is 0 but the dm fts is NULL
UPDATE @TempTemp
SET College_Sum_FTE = dma.FTE
FROM @TempTemp T INNER JOIN DM_Shadow_Staging.dbo._DM_ADMIN dma
			ON T.username = dma.username AND DMA.AC_YEAR=@AC_YEAR
WHERE T.College_Sum_FTE =0 AND dma.FTE is NULL

UPDATE @TempTemp
SET Extern_Sum_FTE = dma.FTE_EXTERN
FROM @TempTemp T INNER JOIN DM_Shadow_Staging.dbo._DM_ADMIN dma
			ON T.username = dma.username AND DMA.AC_YEAR=@AC_YEAR
WHERE T.Extern_Sum_FTE =0 AND dma.FTE_EXTERN is NULL AND T.College_Sum_FTE is null

-- Set fsdb rank or tenure = dm rank or tenure if fsdb rank or tenure has a value
UPDATE @TempTemp
SET [Rank] = dma.[RANK]
FROM @TempTemp T INNER JOIN DM_Shadow_Staging.dbo._DM_ADMIN dma
			ON T.username = dma.username AND DMA.AC_YEAR=@AC_YEAR
WHERE T.[RANK] = '' AND dma.[RANK] <> ''

UPDATE @TempTemp
SET Tenure = dma.Tenure
FROM @TempTemp T INNER JOIN DM_Shadow_Staging.dbo._DM_ADMIN dma
			ON T.username = dma.username AND DMA.AC_YEAR=@AC_YEAR
WHERE (T.Tenure is NULL OR T.Tenure = '') AND dma.Tenure <> ''

UPDATE dbo._DM_USERS
SET UIN = ISNULL(UIN,'')
		,Email_Address = ISNULL(Email_Address,'')

UPDATE @TempTemp
SET Update_USER=1
WHERE username in 
	( SELECT T.username
	  FROM @TempTemp T INNER JOIN DM_Shadow_Staging.dbo._DM_USERS usr
			ON T.username = usr.username 
	  WHERE (ISNULL(T.UIN,'')  <> '' AND T.UIN<> usr.UIN)
			OR (ISNULL(T.Email_Address,'')  <> '' AND T.Email_Address <> usr.Email_Address)
	)

UPDATE dbo._DM_PCI
SET GENDER = ISNULL(GENDER,'')
		,ETHNICITY = ISNULL(ETHNICITY,'')
		,CITIZEN = ISNULL(CITIZEN,'')

UPDATE @TempTemp
SET Update_PCI=1
WHERE username in 
	( SELECT T.username
	  FROM @TempTemp T INNER JOIN DM_Shadow_Staging.dbo._DM_PCI pci
			ON T.username = pci.username 
	  WHERE (ISNULL(T.GENDER,'') <> '' AND T.GENDER<> pci.GENDER)
			OR (ISNULL(T.Last_Name,'') <> '' AND T.Last_Name <> pci.BANNER_LNAME)
			OR (ISNULL(T.PERS_MNAME,'') <> '' AND T.PERS_MNAME <> pci.BANNER_MNAME)
			OR (ISNULL(T.First_Name,'')  <> '' AND T.First_Name <> pci.BANNER_FNAME)
			OR (ISNULL(T.ETHNICITY,'')  <> '' AND T.ETHNICITY <> pci.ETHNICITY)
			OR (ISNULL(T.Citizenship,'')  <> '' AND T.Citizenship <> pci.CITIZEN)	
			OR (T.Birth_Date IS NOT NULL AND CONVERT(varchar,T.Birth_Date,111) <> CONVERT(varchar,(CONVERT(date, DOB_START)), 111) )
			--OR (ISNULL(T.Birth_Date,'')  <> '' AND T.Birth_Date<> pci.DOB_START)		
	)


UPDATE dbo._DM_ADMIN
SET [RANK] = ISNULL([RANK],'')	
		,Tenure = ISNULL(Tenure,'')
WHERE AC_YEAR=@AC_YEAR

-- Mark to update ADMIN general tags
UPDATE @TempTemp
SET Update_ADMIN=1
WHERE username in 
	( SELECT T.username
	  FROM @TempTemp T INNER JOIN DM_Shadow_Staging.dbo._DM_ADMIN dma
			ON T.username = dma.username AND DMA.AC_YEAR=@AC_YEAR
	  WHERE (T.[RANK] <> '' AND T.[RANK]<> dma.[RANK])
			OR (T.College_Sum_FTE is not null AND T.College_Sum_FTE <> dma.FTE)
			OR (T.College_Sum_FTE is not null AND dma.FTE is null)
			OR (T.Extern_Sum_FTE is not null AND T.Extern_Sum_FTE <> dma.FTE_EXTERN)
			OR (T.Extern_Sum_FTE is not null AND dma.FTE_EXTERN is null)
			OR (T.Tenure is not null AND T.Tenure <> dma.Tenure)		
	)

-- NS 5/8/2019 Mark to update ADMIN_DEP, ADMIN_EMPTYPE, ADMIN_EMPGROUP 
UPDATE @TempTemp
SET Update_ADMIN_DEP=1
WHERE DM_Department_Name IS NOT NULL AND DM_Department_Name <> ''
	AND username NOT IN (SELECT username FROM dbo._DM_ADMIN_DEP WHERE username is not null)

UPDATE @TempTemp
SET Update_ADMIN_EMPGROUP=1
WHERE EMPGROUP IS NOT NULL AND EMPGROUP <> ''
	AND username NOT IN (SELECT username FROM dbo._DM_ADMIN_EMPGROUP WHERE username is not null)

UPDATE @TempTemp
SET Update_ADMIN_EMPTYPE=1
WHERE EMPTYPE IS NOT NULL AND EMPTYPE <> ''
	AND username NOT IN (SELECT username FROM dbo._DM_ADMIN_EMPTYPE WHERE  username is not null)



		--SELECT * FROM @TempTemp where Update_PCI=1
/*

	--DEBUG
	SELECT T.*
	FROM @TempTemp T INNER JOIN DM_Shadow_Staging.dbo._DM_ADMIN dma
		ON T.username = dma.username AND DMA.AC_YEAR='2018-2019'
	WHERE (T.[RANK] <> '' AND T.[RANK]<> dma.[RANK])
		OR (T.College_Sum_FTE <> '' AND T.College_Sum_FTE <> dma.FTE)
		OR (T.Univ_Sum_FTE <> '' AND T.Univ_Sum_FTE <> dma.FTE_EXTERN)
		OR (T.Tenure <> '' AND T.Tenure <> dma.Tenure)

	SELECT * FROM @TempTemp

	SELECT * FROM @TempTemp
	WHERE Update_ADMIN=1 OR Update_USER=1 OR Update_PCI=1

	SELECT * FROM _DM_ADMIN WHERE AC_YEAR='2018-2019'
	SELECT FB.*
	FROM DM_Shadow_Staging.dbo.FSDB_Facstaff_Basic FB 
			INNER JOIN  DM_Shadow_Staging.dbo._DM_ADMIN DMA
			ON FB.EDW_PERS_ID = DMA.EDWPERSID AND DMA.AC_YEAR='2018-2019';

*/


-- >>>>>>>>>>>>>>>>>> 1) UPDATE USER screen

INSERT INTO #Updates (m,u,post,username,o,r)
SELECT 'PUT'as m, '/login/service/v4/User/USERNAME:'+b.username u
	,'<User UIN="' + CAST(b.UIN as varchar) + '" FacstaffID="' +  CAST(b.FACSTAFF_ID as varchar)  + '" EDWPERSID="' +  CAST(b.EDW_PERS_ID as varchar)  + '">' +
	'<Email>'+ b.email_address + '</Email>' +
	'</User>' as post
	, b.USERNAME,1 o, ROW_NUMBER()OVER(ORDER BY USERNAME) as r		
FROM @TempTemp b WHERE Update_USER=1



-- >>>>>>>>>>>>>>>>>  2) UPDATE ADMIN screen related to AC_YEAR='2018-2019'; ADMIN, ADMIN_DEP, ADMIN_EMPTYPE, ADMIN_EMPGROUP
--				Any record on _DM_USERS that are in _DM_ADMIN

-- <ADMIN> flat tags
INSERT INTO #Updates (m,u,post,username,o,r)
SELECT method m,url u,xml post, USERNAME,o,ROW_NUMBER()OVER(ORDER BY USERNAME,o,url)r
FROM (
SELECT USERNAME,3 as o,'PUT' method
	,'/login/service/v4/UserSchema/USERNAME:'+ USERNAME + '/INDIVIDUAL-ACTIVITIES-Business' as url
	,CAST((SELECT @AC_YEAR AC_YEAR		
	,[RANK]
	,CASE WHEN College_Sum_FTE IS NULL THEN ''
			ELSE CAST(College_Sum_FTE as varchar)
		END AS FTE
	,CASE WHEN Extern_Sum_FTE IS NULL THEN ''
			ELSE CAST(Extern_Sum_FTE as varchar)
		END AS FTE_EXTERN
	--,ISNULL(College_Sum_FTE,'') as FTE
	--,isnull(Extern_Sum_FTE,'') as FTE_EXTERN
	,TENURE
	 
	FOR XML PATH('ADMIN'),ROOT('INDIVIDUAL-ACTIVITIES-Business'),TYPE) as varchar(MAX)) as xml
FROM @TempTemp c WHERE Update_ADMIN=1
) x
ORDER BY USERNAME,o

-- <ADMIN_DEP>
INSERT INTO #Updates (m,u,post,username,o,r)
SELECT method m,url u,xml post, USERNAME,o,ROW_NUMBER()OVER(ORDER BY USERNAME,o,url)r
FROM (
	SELECT USERNAME,3 as o,'PUT' method
	    ,'/login/service/v4/UserSchema/USERNAME:'+ USERNAME + '/INDIVIDUAL-ACTIVITIES-Business' as url
		,CAST((SELECT @AC_YEAR AC_YEAR		
		,(
			SELECT DM_Department_Name as DEP				
			FROM @TempTemp d WHERE d.username = c.username
			FOR XML PATH('ADMIN_DEP'),TYPE
		 ) 
		 FROM @TempTemp c2 WHERE c.username=c2.username
		 FOR XML PATH('ADMIN'),ROOT('INDIVIDUAL-ACTIVITIES-Business'),TYPE) as varchar(MAX)) 
		 as xml
	FROM @TempTemp c WHERE Update_ADMIN_DEP=1 
	) x;

-- <ADMIN_EMPTYPE>
INSERT INTO #Updates (m,u,post,username,o,r)
SELECT method m,url u,xml post, USERNAME,o,ROW_NUMBER()OVER(ORDER BY USERNAME,o,url)r
FROM (
	SELECT USERNAME,3 as o,'PUT' method
	    ,'/login/service/v4/UserSchema/USERNAME:'+ USERNAME + '/INDIVIDUAL-ACTIVITIES-Business' as url
		,CAST(
		 (SELECT @AC_YEAR AC_YEAR		
		,(
			--EMPTYPE was implemented as Checkboxes, not DSA, no need to hav XM PATH, instead add the alias EMPTYPE to be a <EMPTYPE> tag later
			SELECT  EMPTYPE 						
			FROM @TempTemp d WHERE d.username = c.username
			FOR XML PATH(''),TYPE
		 ) 
		 FROM @TempTemp c2 WHERE c.username=c2.username
		 FOR XML PATH('ADMIN'),ROOT('INDIVIDUAL-ACTIVITIES-Business'),TYPE) as varchar(MAX)) 
		 as xml
	FROM @TempTemp c WHERE Update_ADMIN_EMPTYPE=1 
	) x;


-- <ADMIN_EMPGROUP>
INSERT INTO #Updates (m,u,post,username,o,r)
SELECT method m,url u,xml post, USERNAME,o,ROW_NUMBER()OVER(ORDER BY USERNAME,o,url)r
FROM (
	SELECT USERNAME,3 as o,'PUT' method
	    ,'/login/service/v4/UserSchema/USERNAME:'+ USERNAME + '/INDIVIDUAL-ACTIVITIES-Business' as url
		,CAST(
		 (SELECT @AC_YEAR AC_YEAR		
		,(
			--EMPGROUP was implemented as Checkboxes, not DSA, no need to hav XM PATH, instead add the alias EMPTYPE to be a <EMPGROUP> tag later
			SELECT  EMPGROUP 									
			FROM @TempTemp d WHERE Update_ADMIN_EMPGROUP=1 AND d.username = c.username
			FOR XML PATH(''),TYPE
		 ) 
		 FROM @TempTemp c2 WHERE c.username=c2.username
		 FOR XML PATH('ADMIN'),ROOT('INDIVIDUAL-ACTIVITIES-Business'),TYPE) as varchar(MAX)) 
		 as xml
	FROM @TempTemp c WHERE Update_ADMIN_EMPGROUP=1 
	) x;



-- >>>>>>>>>>>>>>>> 3) UPDATE PCI screen

INSERT INTO #Updates (m,u,post,username,o,r)
SELECT method m,url u,xml post, USERNAME,o,ROW_NUMBER()OVER(ORDER BY USERNAME,o,url)r
FROM (
SELECT USERNAME,3 as o,'PUT' method
	,'/login/service/v4/UserSchema/USERNAME:'+ USERNAME + '/INDIVIDUAL-ACTIVITIES-Business' as url
	,CAST((SELECT GENDER,Last_Name as BANNER_LNAME, PERS_MNAME as BANNER_MNAME, First_Name as BANNER_FNAME
			,Ethnicity as ETHNICITY, Citizenship as CITIZEN
			,DATENAME(mm, Birth_Date) as DTM_DOB
			,YEAR(Birth_Date) as DTY_DOB	
			,datepart(d,Birth_Date) as DTD_DOB
			--,CONVERT(varchar,Birth_Date,111) as DOB_START
	FOR XML PATH('PCI'),ROOT('INDIVIDUAL-ACTIVITIES-Business'),TYPE) as varchar(MAX)) as xml
FROM @TempTemp c WHERE Update_PCI=1
) x
ORDER BY USERNAME,o


--SELECT * FROM #Updates

/*
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
,departments2 as (
		SELECT DMU.USERNAME,CAST(DMU.FACSTAFFID as varchar) as FACSTAFFID, CAST(DMU.EDWPERSID as varchar) as EDWPERSID 
			,FSJD.Department_ID as Department_ID
			,REPLACE(D.Department_Name,'IT Partners','Business IT Services') as Department_Name       
		FROM Faculty_Staff_Holder.dbo.Facstaff_Joint_Departments FSJD
				INNER JOIN DM_Shadow_Staging.dbo._DM_USERS DMU 
				ON DMU.FacstaffID = FSJD.Facstaff_ID
				INNER JOIN Faculty_Staff_Holder.dbo.Departments D 
				ON FSJD.Department_ID = D.Department_ID 
		UNION
		SELECT DMU.USERNAME,CAST(DMU.FACSTAFFID as varchar) as FACSTAFFID, CAST(DMU.EDWPERSID as varchar) as EDWPERSID 
			,FSB.Department_ID as Department_ID
			,REPLACE(D.Department_Name,'IT Partners','Business IT Services') as Department_Name     
		FROM Faculty_Staff_Holder.dbo.Facstaff_Basic FSB
				INNER JOIN DM_Shadow_Staging.dbo._DM_USERS DMU 
				ON DMU.FacstaffID = FSB.Facstaff_ID
				INNER JOIN Faculty_Staff_Holder.dbo.Departments D 
				ON FSB.Department_ID = D.Department_ID 

)

*/


/*
-- works!
SELECT method m,url u,xml post, USERNAME,o,ROW_NUMBER()OVER(ORDER BY USERNAME,o,url)r
INTO #updates
FROM (
	SELECT USERNAME,3 as o,'PUT' method
	    ,'login/service/v4/UserSchema/USERNAME:'+ USERNAME + '/INDIVIDUAL-ACTIVITIES-Business' as url
		,CAST((SELECT '2017-2018' AC_YEAR		
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
		CAST((SELECT '2017-2018' AC_YEAR,
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
		
	--EXEC dbo.webservices_initiate @screen='ADMIN'

END
ELSE SELECT * FROM #updates

DROP TABLE #updates



--EXEC dbo.webservices_initiate @screen='USERS'	

/*
	  OR  T.EMPEE_DEPT_CD <> 
		  OR  T.EMPEE_DEPT_NAME
		  OR  T.EMPEE_CLS_CD
		  OR  T.EMPEE_CLS_LONG_DESC
		  OR  T.POSN_EMPEE_CLS_CD
		  OR  T.POSN_EMPEE_CLS_LONG_DESC
		  OR  T.EMPEE_GROUP_CD
		  OR  T.EMPEE_GROUP_DESC
		  OR  T.POSN_NBR
		  OR  T.JOB_DETL_DEPT_CD
		  OR  T.JOB_DETL_DEPT_NAME
		  OR  T.JOB_DETL_TITLE
		  OR  T.JOB_DETL_FTE
		  OR  T.JOB_CNTRCT_TYPE_DESC
		  OR  T.JOB_SUFFIX

		  OR  T.FAC_RANK_CD
		  OR  T.FAC_RANK_DESC
		  OR  T.FAC_RANK_ACT_DT
		  OR  T.FAC_RANK_DECN_DT
		  OR  T.FAC_RANK_ACAD_TITLE
		  OR  T.FAC_RANK_EMRTS_STATUS_IND
		  OR  T.Network_ID
		  OR  T.College_Sum_FTE
		  OR  T.Univ_Sum_FTE
		  OR  T.DM_Department_Name

		  OR  T.Last_Name 
		  OR  T.PERS_MNAME
		  OR  T.Middle_Name
		  OR  T.First_Name
		  OR  T.PERS_PREFERRED_FNAME

		  OR  T.Campus_Wide_Appointment_Percent
		  OR  T.Appointment_Percent
		  OR  T.Tenure_Status_Indicator
		  OR  T.Tenure_Track_Status_Indicator
		  OR  T.Rank_ID
		  OR  T.Ethnicity_ID
		  OR  T.Citizenship_ID
		  OR  T.Gender
		  OR  T.Birth_Date
*/

END


GO
