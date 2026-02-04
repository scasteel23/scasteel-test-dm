SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
-- NS 5/22/2019
-- STC 6/19/19 - Get Dept from DM instead of FSB
-- STC 3/23/20 - Created for Dean's Office report, derived from v1
CREATE PROC [dbo].[DSQUERY_sp_All_GiesBusiness_Employees_v2]
AS
with emps as (
  SELECT *, 
	dbo.DM_OUTLOOK_fn_Get_Department_Name(Facstaff_ID) as [DM Department]
  FROM [DM_Shadow_Staging].[dbo].[FSDB_Facstaff_Basic] fsb
  where Active_Indicator=1 
--	AND EMPEE_CLS_CD is null
)

SELECT distinct 
	[UIN]
--	,[EDW_PERS_ID]
	,[Network_ID]

	,case when [First_Name] is not null
		then case when [PERS_MNAME] is not null 
					then [Last_Name] + ', ' + [First_Name] + ' ' + [PERS_MNAME]
					else [Last_Name] + ', ' + [First_Name]
					end
		else [Last_Name] end as [Full Name]
     
-- STC need to do: temporary fix until FSDB_Facstaff_Basic is updated daily from DM data
--	,CASE WHEN Doctoral_Flag = 1 THEN 'Doctoral Student' ELSE '' END as Doctoral_Indicator
	,CASE WHEN Doctoral_Flag = 1 THEN 'PhD Student'
		WHEN EMPEE_GROUP_CD = 'A' THEN 'Faculty'
		WHEN EMPEE_GROUP_CD = 'B' THEN 'AP'
		WHEN EMPEE_GROUP_CD = 'C' THEN 'CS'
		WHEN EMPEE_GROUP_CD = 'E' THEN 'Extra Help'
		WHEN EMPEE_GROUP_CD = 'G' THEN 'Grad Student'
		WHEN EMPEE_GROUP_CD = 'H' THEN 'Hourly'
		WHEN EMPEE_GROUP_CD = 'P' THEN 'Postdoc'
		WHEN EMPEE_GROUP_CD = 'S' THEN 'Undergrad'
		WHEN EMPEE_GROUP_CD = 'U' THEN 'Unpaid'
		WHEN EMPEE_GROUP_CD = 'T' THEN 'Retiree/Emeritus'
		-- For PhD students not marked in FSDB for some reason
		ELSE 'PhD Student' END as [Employee Type]

	,CASE WHEN [DM Department] > '' THEN [DM Department]
			WHEN [JOB_DETL_DEPT_NAME] is not null THEN [JOB_DETL_DEPT_NAME] 
			else ISNULL([EMPEE_DEPT_NAME],'')
			end [Department]

	,isnull((
		select stuff((
			select ' AND ' + t.TITLE
			from _dm_users u2
			inner join _DM_ADMIN a
				on u2.userid = a.userid
			inner join _DM_ADMIN_TITLE t
				on t.AC_YEAR = a.AC_YEAR
					and t.userid = a.userid
			where t.TITLE_CURRENT = 'Yes'
				and u2.EDWPERSID = emps.EDW_PERS_ID
				and u2.Enabled_Indicator = 1
				and not exists (
					SELECT *
					FROM _DM_ADMIN a2
					WHERE a2.userid = a.userid
						AND a2.AC_YEAR > a.AC_YEAR
					)
			order by t.SEQ
			FOR XML PATH(''),TYPE
		).value('.','varchar(max)'), 1, 5, '')
	),'') as [DM Titles]
	,isnull([JOB_DETL_TITLE],'') as [Banner Title (Primary Job)]

	,[DM Department]
	,isnull([EMPEE_DEPT_NAME],'') as [Banner Department (Primary)]

-- STC these FSB fields should be populated with type of KM job when KM is not primary (currently populated with 'Primary')
--		(we already have primary job dept in empee dept name, don't need to duplipcate here,
--		 and don't really need primary title for non KM job?)

	,isnull([JOB_DETL_DEPT_NAME],'') as [Banner Job Department]
--	,isnull([JOB_CNTRCT_TYPE_DESC],'') as [Job Type]

	,isnull([EMPEE_GROUP_CD],'') as [Employee Group]
	,isnull([EMPEE_GROUP_DESC],'') as [Group Name]
	,isnull([EMPEE_CLS_CD],'') as [Employee Class]
	,isnull([EMPEE_CLS_LONG_DESC],'') as [Class Name]
	,isnull([POSN_EMPEE_CLS_CD],'') as [Job Class]
	,isnull([POSN_EMPEE_CLS_LONG_DESC],'') as [Job Class Name]

	,[Last_Name] as [Last Name]
	,ISNULL([PERS_MNAME],'') as [Middle Name]
	--,[Middle_Name] 
	,[First_Name] as [First Name]
	--,fsb.Professional_Last_Name
	--,fsb.Middle_Name
	--,ISNULL([PERS_PREFERRED_FNAME],'') as [PERS_PREFERRED_FNAME]

	,Network_ID + '@illinois.edu' as [UI Email]

--	,[Hired_Date]
	,[Create_Datetime] as [Date Created]

--	,isnull([FAC_RANK_DESC],'') as [Banner Rank]
--	,ISNULL([FAC_RANK_ACAD_TITLE],'') as [FAC_RANK_ACAD_TITLE]
--	,isnull([FAC_RANK_EMRTS_STATUS_IND],'') as [Emeritus?]

      --,CASE WHEN [College_Sum_FTE] Is NULL THEN ISNULL([Univ_Sum_FTE],0) else ISNULL([College_Sum_FTE],0) END as [College_Sum_FTE]
      --,CASE WHEN [Univ_Sum_FTE] Is NULL THEN ISNULL([College_Sum_FTE],0) else ISNULL([Univ_Sum_FTE],0) END as [Univ_Sum_FTE] 
   
-- STC temporary fix until FSDB_Facstaff_Basic is updated daily from DM data
      --,[DM_Department_Name]

	  --,Create_Datetime

  FROM emps

  order by 
	[Full Name]
	, [Employee Type]
	, [Employee Group]
	, [Employee Class]


  --select UIN
  -- FROM [DM_Shadow_Staging].[dbo].[FSDB_Facstaff_Basic]
  --where Active_Indicator=1 and BUS_Person_Indicator=1  
  --group by UIN
  --having count(*) > 1
  --order by uin
GO
