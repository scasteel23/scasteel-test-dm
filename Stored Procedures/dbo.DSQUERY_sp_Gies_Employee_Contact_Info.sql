SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
-- STC 3/23/20
CREATE PROCEDURE [dbo].[DSQUERY_sp_Gies_Employee_Contact_Info]
(
	@Department	varchar(100) = 'ZZZZ'
)
AS

with emps as (
  SELECT *
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
	,dbo.DM_OUTLOOK_fn_Get_Department_Name(Facstaff_ID) as [DM Department]
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
				and u2.EDWPERSID = fsb.EDW_PERS_ID
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
  FROM [DM_Shadow_Staging].[dbo].[FSDB_Facstaff_Basic] fsb
  where Active_Indicator=1 
--	AND EMPEE_CLS_CD is null
),

contact as (
	SELECT distinct 
		e.[UIN]
	--	,[EDW_PERS_ID]
		,e.[Network_ID]
		,e.[Full Name]

		,[Employee Type]
		,CASE WHEN [DM Department] > '' THEN [DM Department]
				WHEN [JOB_DETL_DEPT_NAME] is not null THEN [JOB_DETL_DEPT_NAME] 
				else ISNULL([EMPEE_DEPT_NAME],'')
				end [Department]

		  ,[Contact_Type] as [Contact Type]
	--      ,[Sub_Types]
		  ,CASE WHEN Contact_Type = 'Emergency' THEN ''
				WHEN Contact_Type = 'Email' THEN Email_Type
				WHEN Contact_Type = 'Address' THEN Address_Type
				WHEN Contact_Type = 'Phone' THEN Phone_Type
				END as [Sub Type]
	--      ,[Email_Code]
	--      ,[Email_Type] as [Email Type]
		  ,[Email]
		  ,[Priority]
		  ,[Contact_Last] as [Contact Last]
		  ,[Contact_First] as [Contact First]
		  ,[Contact_Middle] as [Contact Middle]
		  ,[Relationship]
	--      ,[Address_Code]
	--      ,[Address_Type] as [Address Type]
		  ,[Address1] as [Address 1]
		  ,[Address2] as [Address 2]
		  ,[Address3] as [Address 3]
		  ,[City]
		  ,[State]
		  ,[Zip]
		  ,[Country]
		  ,isnull(convert(varchar(10),[Until_Date],120),'') as [Until Date]
	--      ,[Phone_Code]
	--      ,[Phone_Type] as [Phone Type]
		  ,[Area_Code] as [Area Code]
		  ,[Phone_Number] as [Number]
		  ,[Phone_Ext] as [Extension]
		  ,[Intl_Access] as [International]
		  ,isnull(convert(varchar(20),ec.[Last_Updated],120),'') as [Last Updated]
	--      ,convert(varchar(20),ec.[Create_Datetime],120) as [Date Added]

		,[DM Titles]
		,isnull([JOB_DETL_TITLE],'') as [Banner Title (Primary Job)]

		,[DM Department]
		,isnull([EMPEE_DEPT_NAME],'') as [Banner Department (Primary)]
		,isnull([JOB_DETL_DEPT_NAME],'') as [Banner Job Department]

		,e.[Last_Name] as [Last Name]
		,ISNULL([PERS_MNAME],'') as [Middle Name]
		,e.[First_Name] as [First Name]
     
		,Network_ID + '@illinois.edu' as [UI Email]

	FROM emps e
	INNER JOIN [dbo].[Employee_Contact_Info_Staging] ec
		on e.EDW_PERS_ID = ec.EDW_PERS_ID
	WHERE Current_Indicator = 1
)

select *
from contact
where @Department = 'ZZZZ'
	or Department LIKE '%' + @Department + '%'

 order by 
	[Full Name]
	, [Contact Type], [priority], [Sub Type]
--	, [Email Type], [Address Type], [Phone Type]
--	, [Employee Type]
GO
