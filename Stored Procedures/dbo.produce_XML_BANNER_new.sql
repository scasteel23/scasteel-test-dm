SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 1/22/2019 Split produce_XML_BANNER into produce_XML_BANNER_current and produce_XML_BANNER_new
CREATE PROC [dbo].[produce_XML_BANNER_new] ( @submit BIT=0 )
AS


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
	Test the results
	 EXEC dbo.[produce_XML_BANNER] @submit = 0

	 Manual run to upload USERS FROM FSDB
	 EXEC dbo.[produce_XML_BANNER] @submit = 1
	 EXEC dbo.webservices_run_DTSX
	*/

	WITH new_banner AS (
	SELECT  USERNAME
      ,ISNULL(FACSTAFFID,'') AS FACSTAFFID
	  ,ISNULL(EDWPERSID,'') AS EDWPERSID
      ,banner.UIN
      ,PERS_PREFERRED_FNAME
      ,PERS_FNAME
      ,PERS_MNAME
      ,PERS_LNAME
      ,BIRTH_DT
	  ,CASE WHEN SEX_CD='M' THEN 'Male' ELSE 'Female' END as SEX_CD 
      ,RACE_ETH_DESC
      ,PERS_CITZN_TYPE_DESC
      ,EMPEE_CAMPUS_CD
      ,EMPEE_CAMPUS_NAME
      ,EMPEE_COLL_CD
      ,EMPEE_COLL_NAME
      ,EMPEE_DEPT_CD
      ,EMPEE_DEPT_NAME
      ,JOB_DETL_TITLE
      ,JOB_DETL_FTE
      ,JOB_CNTRCT_TYPE_DESC
      ,JOB_DETL_COLL_CD
      ,JOB_DETL_COLL_NAME
      ,JOB_DETL_DEPT_CD
      ,JOB_DETL_DEPT_NAME
      ,COA_CD
      ,ORG_CD
      ,EMPEE_ORG_TITLE
      ,EMPEE_CLS_CD
      ,EMPEE_CLS_LONG_DESC
      ,EMPEE_GROUP_CD
      ,EMPEE_GROUP_DESC
	  ,CASE WHEN EMPEE_RET_IND='Y' THEN 'Yes' ELSE 'No' END as EMPEE_RET_IND 
      ,EMPEE_LEAVE_CATGRY_CD
      ,EMPEE_LEAVE_CATGRY_DESC
      ,BNFT_CATGRY_CD
      ,BNFT_CATGRY_DESC
      ,HR_CAMPUS_CD
      ,HR_CAMPUS_NAME
      ,EMPEE_STATUS_CD
      ,EMPEE_STATUS_DESC
      ,CAMPUS_JOB_DETL_FTE
      ,COLLEGE_JOB_DETL_FTE
      ,FAC_RANK_CD
      ,FAC_RANK_DESC
      ,FAC_RANK_ACT_DT
      ,FAC_RANK_DECN_DT
      ,FAC_RANK_ACAD_TITLE
	  ,CASE WHEN FAC_RANK_EMRTS_STATUS_IND='Y' THEN 'Yes' ELSE 'No' END as FAC_RANK_EMRTS_STATUS_IND 
      ,FIRST_HIRE_DT
      ,CUR_HIRE_DT
      ,FIRST_WORK_DT
      ,LAST_WORK_DT
      ,EMPEE_TERMN_DT
      ,Network_ID
	FROM dbo._Upload_DM_BANNER banner
	WHERE USERNAME NOT IN (SELECT USERNAME FROM _DM_BANNER WHERE USERNAME is not NULL)	
			AND USERNAME IN (SELECT USERNAME FROM _DM_USERS WHERE USERNAME is not NULL)	
	)
				--Inner JOIN dbo._DM_USERS u
				--ON banner.username=u.username
				--	AND banner.Record_Status IN ('NEW')
				--)

	--select * from new_banner

	SELECT method m,url u,xml post, username, o,ROW_NUMBER()OVER(ORDER BY username,o,url)r
	INTO #updates
	FROM (
		 -- INSERT a new BANNER record
		 SELECT username,3 o,'POST' method,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:'+username+'/BANNER' url,		 
			CAST((
				--SELECT NETID "@username",(SELECT
				--	FirstName FNAME,
				--	LastName LNAME
				--	FOR XML PATH('banner'),TYPE
				--)FOR XML PATH('Record'),ROOT('Data')

				SELECT username "@username", (SELECT
							 FACSTAFFID
						  ,EDWPERSID
						  ,UIN
						  ,PERS_PREFERRED_FNAME
						  ,PERS_FNAME
						  ,PERS_MNAME
						  ,PERS_LNAME
						  ,BIRTH_DT
						  ,SEX_CD 
						  ,RACE_ETH_DESC
						  ,PERS_CITZN_TYPE_DESC
						  ,EMPEE_CAMPUS_CD
						  ,EMPEE_CAMPUS_NAME
						  ,EMPEE_COLL_CD
						  ,EMPEE_COLL_NAME
						  ,EMPEE_DEPT_CD
						  ,EMPEE_DEPT_NAME
						  ,JOB_DETL_TITLE
						  ,JOB_DETL_FTE
						  ,JOB_CNTRCT_TYPE_DESC
						  ,JOB_DETL_COLL_CD
						  ,JOB_DETL_COLL_NAME
						  ,JOB_DETL_DEPT_CD
						  ,JOB_DETL_DEPT_NAME
						  ,COA_CD
						  ,ORG_CD
						  ,EMPEE_ORG_TITLE
						  ,EMPEE_CLS_CD
						  ,EMPEE_CLS_LONG_DESC
						  ,EMPEE_GROUP_CD
						  ,EMPEE_GROUP_DESC
						  ,EMPEE_RET_IND 
						  ,EMPEE_LEAVE_CATGRY_CD
						  ,EMPEE_LEAVE_CATGRY_DESC
						  ,BNFT_CATGRY_CD
						  ,BNFT_CATGRY_DESC
						  ,HR_CAMPUS_CD
						  ,HR_CAMPUS_NAME
						  ,EMPEE_STATUS_CD
						  ,EMPEE_STATUS_DESC
						  ,CAMPUS_JOB_DETL_FTE
						  ,COLLEGE_JOB_DETL_FTE
						  ,FAC_RANK_CD
						  ,FAC_RANK_DESC
						  ,FAC_RANK_ACT_DT
						  ,FAC_RANK_DECN_DT
						  ,FAC_RANK_ACAD_TITLE
						  ,FAC_RANK_EMRTS_STATUS_IND 
						  ,FIRST_HIRE_DT
						  ,CUR_HIRE_DT
						  ,FIRST_WORK_DT
						  ,LAST_WORK_DT
						  ,EMPEE_TERMN_DT
						  ,Network_ID
					  FOR XML PATH('BANNER'),TYPE
				)FOR XML PATH('Record'),ROOT('Data')

			)AS VARCHAR(MAX)) xml
		FROM new_banner
	)x
	ORDER BY username,o

	IF @submit=1 BEGIN
	
		CREATE TABLE #requests(id INT NOT NULL,method VARCHAR(10),url VARCHAR(255),r INT)
	
		INSERT INTO webservices_requests(method,url,post,process)
		OUTPUT inserted.id,inserted.method,inserted.url,inserted.process INTO #requests
		SELECT m,u,CAST(post AS VARCHAR(MAX)),r FROM #updates WHERE post IS NOT NULL

		UPDATE webservices_requests SET process=NULL,dependsOn=(
			SELECT TOP 1 id FROM #requests r2 JOIN #updates u2 ON u2.r=r2.r
			WHERE u2.o<u1.o AND u2.username=u1.username ORDER BY u2.o DESC)
		FROM webservices_requests
		JOIN #requests r1 ON r1.id=webservices_requests.id
		JOIN #updates u1 ON u1.r=r1.r
	
		DROP TABLE #requests
	END
	ELSE 
		SELECT * FROM #updates

	DROP TABLE #updates

/*
<Data>
<Record username="aa311096">

<BANNER>
<FACSTAFFID>101605</FACSTAFFID>
<EDWPERSID>2224543</EDWPERSID><UIN>667782578</UIN>
<PERS_PREFERRED_FNAME>&#x20;</PERS_PREFERRED_FNAME>
<PERS_FNAME>Mary Frances</PERS_FNAME>
<PERS_MNAME>&#x20;</PERS_MNAME>
<PERS_LNAME>Fagan</PERS_LNAME>
<BIRTH_DT>1954-10-09T00:00:00</BIRTH_DT>
<SEX_CD>Female</SEX_CD>
<RACE_ETH_DESC>White, Non-Hispanic</RACE_ETH_DESC>
<PERS_CITZN_TYPE_DESC>Citizen</PERS_CITZN_TYPE_DESC>

<EMPEE_CAMPUS_CD>1</EMPEE_CAMPUS_CD>
<EMPEE_CAMPUS_NAME>Urbana-Champaign Campus</EMPEE_CAMPUS_NAME>
<EMPEE_COLL_CD>KM</EMPEE_COLL_CD>
<EMPEE_COLL_NAME>Gies College of Business</EMPEE_COLL_NAME>
<EMPEE_DEPT_CD>747</EMPEE_DEPT_CD>
<EMPEE_DEPT_NAME>Gies Mktg &amp; Communications</EMPEE_DEPT_NAME>

<JOB_DETL_TITLE>ACADEMIC HRLY ADMIN</JOB_DETL_TITLE>
<JOB_DETL_FTE>0.000</JOB_DETL_FTE>
<JOB_CNTRCT_TYPE_DESC>Primary</JOB_CNTRCT_TYPE_DESC>
<JOB_DETL_COLL_CD>KM</JOB_DETL_COLL_CD>
<JOB_DETL_COLL_NAME>Gies College of Business</JOB_DETL_COLL_NAME>
<JOB_DETL_DEPT_CD>747</JOB_DETL_DEPT_CD>
<JOB_DETL_DEPT_NAME>Gies Mktg &amp; Communications</JOB_DETL_DEPT_NAME>

<COA_CD>1</COA_CD>
<ORG_CD>747000</ORG_CD>
<EMPEE_ORG_TITLE>Gies Mktg &amp; Communications</EMPEE_ORG_TITLE>
<EMPEE_CLS_CD>HA</EMPEE_CLS_CD>
<EMPEE_CLS_LONG_DESC>Hrly Faculty/Clinical/Research</EMPEE_CLS_LONG_DESC>
<EMPEE_GROUP_CD>H</EMPEE_GROUP_CD>
<EMPEE_GROUP_DESC>Academic Hourly &amp; Grad Hourly</EMPEE_GROUP_DESC>
<EMPEE_RET_IND>No</EMPEE_RET_IND>
<EMPEE_LEAVE_CATGRY_CD>IN</EMPEE_LEAVE_CATGRY_CD>
<EMPEE_LEAVE_CATGRY_DESC>Ineligible</EMPEE_LEAVE_CATGRY_DESC>
<BNFT_CATGRY_CD>B4</BNFT_CATGRY_CD>
<BNFT_CATGRY_DESC>Bi-Weekly Statutory Only</BNFT_CATGRY_DESC>
<HR_CAMPUS_CD>U</HR_CAMPUS_CD>
<HR_CAMPUS_NAME>UIUC Urbana / Champaign</HR_CAMPUS_NAME>
<EMPEE_STATUS_CD>A</EMPEE_STATUS_CD>
<EMPEE_STATUS_DESC>Active</EMPEE_STATUS_DESC>

<CAMPUS_JOB_DETL_FTE>0.000</CAMPUS_JOB_DETL_FTE>
<COLLEGE_JOB_DETL_FTE>0.000</COLLEGE_JOB_DETL_FTE>
<FAC_RANK_EMRTS_STATUS_IND>No</FAC_RANK_EMRTS_STATUS_IND>
<FIRST_HIRE_DT>2016-12-05T00:00:00</FIRST_HIRE_DT>
<CUR_HIRE_DT>2016-12-05T00:00:00</CUR_HIRE_DT>
<FIRST_WORK_DT>2016-12-05T00:00:00</FIRST_WORK_DT>

<Network_ID>aa311096</Network_ID>

</BANNER>

</Record>
</Data>

*/
END


GO
