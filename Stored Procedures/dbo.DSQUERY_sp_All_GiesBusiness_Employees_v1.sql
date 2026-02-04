SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/****** Script for SelectTopNRows command from SSMS  ******/
-- NS 5/22/2019
-- STC 6/19/19 - Get Dept from DM instead of FSB
CREATE PROC [dbo].[DSQUERY_sp_All_GiesBusiness_Employees_v1]
AS
SELECT distinct [UIN]
      ,[EDW_PERS_ID]
	  ,[Network_ID]

	   ,[Last_Name] as PERS_LNAME
      ,ISNULL([PERS_MNAME],'') as PERS_MNAME
      --,[Middle_Name] 
      ,[First_Name] as PERS_FNAME
      ,ISNULL([PERS_PREFERRED_FNAME],'') as [PERS_PREFERRED_FNAME]
     
	  ,[EMPEE_GROUP_CD]
      ,[EMPEE_GROUP_DESC]
      ,[EMPEE_DEPT_NAME]
      ,[EMPEE_CLS_CD]
      ,[EMPEE_CLS_LONG_DESC]
      ,[POSN_EMPEE_CLS_CD]
      ,[POSN_EMPEE_CLS_LONG_DESC]


-- STC these FSB fields should be populated with type of KM job when KM is not primary (currently populated with 'Primary')
--		(we already have primary job dept in empee dept name, don't need to duplipcate here,
--		 and don't really need primary title for non KM job?)

      ,[JOB_DETL_DEPT_NAME]
      ,[JOB_DETL_TITLE]
      ,[JOB_CNTRCT_TYPE_DESC]

      ,ISNULL([FAC_RANK_DESC],'') as [FAC_RANK_DESC]
      ,ISNULL([FAC_RANK_ACAD_TITLE],'') as [FAC_RANK_ACAD_TITLE]
      ,ISNULL([FAC_RANK_EMRTS_STATUS_IND],'') as [Emeritus?]

-- STC need to do: temporary fix until FSDB_Facstaff_Basic is updated daily from DM data
	  ,CASE WHEN Doctoral_Flag = 1 THEN 'Doctoral Student' ELSE '' END as Doctoral_Indicator
      
      
      --,CASE WHEN [College_Sum_FTE] Is NULL THEN ISNULL([Univ_Sum_FTE],0) else ISNULL([College_Sum_FTE],0) END as [College_Sum_FTE]
      --,CASE WHEN [Univ_Sum_FTE] Is NULL THEN ISNULL([College_Sum_FTE],0) else ISNULL([Univ_Sum_FTE],0) END as [Univ_Sum_FTE] 
   
-- STC temporary fix until FSDB_Facstaff_Basic is updated daily from DM data
		,dbo.DM_OUTLOOK_fn_Get_Department_Name(Facstaff_ID) as DM_Department_Name
      --,[DM_Department_Name]

	  --,Create_Datetime

  FROM [DM_Shadow_Staging].[dbo].[FSDB_Facstaff_Basic]
  where Active_Indicator=1 and BUS_Person_Indicator=1  AND EMPEE_CLS_CD is not null
		
  order by [EMPEE_GROUP_CD], PERS_LNAME, PERS_FNAME



  --select UIN
  -- FROM [DM_Shadow_Staging].[dbo].[FSDB_Facstaff_Basic]
  --where Active_Indicator=1 and BUS_Person_Indicator=1  
  --group by UIN
  --having count(*) > 1
  --order by uin
GO
