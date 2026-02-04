SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 12/3/2018 - rank_Id and addresses fields
-- NS 11/16 - 11/20/2018 Rewritten for DM
-- Without the ORDER BY line, this is the codes that are run in DIRECTORY_Employee_View view
CREATE PROC [dbo].[_DM_DIRECTORY_Employee_View]
--ALTER VIEW [dbo].[DIRECTORY_Employee_View]
AS
	SELECT B.FacstaffID as Facstaff_ID
				  ,B.EDWPERSID as EDW_PERS_ID
				  ,ISNULL(B.Username, '') AS Network_ID
				  ,EMPEE_CLS_CD
				  ,dbo.DM_OUTLOOK_fn_Get_Fullname_Official_By_FSID(B.FacstaffID) AS Fullname
                  ,dbo.DM_OUTLOOK_fn_Get_Display_Name_With_Middle_Initial_By_FSID(B.FacstaffID) AS Display_Name
				  ,pci.lname as  Last_Name
				  ,pci.fname as First_Name
				  ,pci.mname AS Middle_Name
				  ,CASE WHEN b.username IS NULL THEN '' 
						 ELSE b.username + '@illinois.edu' END AS Email_Address
				  --,dbo.DM_OUTLOOK_fn_Get_Department_Name(B.Facstaffid) AS Primary_Department
				  ,CASE WHEN pci.DOC_STATUS='Current PhD Student' THEN DOC_DEPT
						ELSE dbo.DM_OUTLOOK_fn_Get_Department_Name(B.Facstaffid)
						END as Primary_Department
				  ,dbo.DM_OUTLOOK_fn_Get_Department_Name(B.Facstaffid) AS Departments
				  ,dbo.DM_OUTLOOK_fn_Get_Facstaff_Self_Titles_String(B.FacstaffID, banner.EMPEE_GROUP_CD) AS Titles 
                  ,dbo.DM_OUTLOOK_fn_Get_Facstaff_Addresses_Complete_Format1(B.FacstaffID, 2) AS Address_Complete
				  ,dbo.DM_OUTLOOK_fn_Get_Facstaff_Addresses_Complete_Format1(B.FacstaffID, 2) AS Address_Complete_Original
                  ,dbo.DM_OUTLOOK_fn_Get_Facstaff_Addresses_Building_Name(B.FacstaffID, 2) AS Building_Name
				  ,dbo.DM_OUTLOOK_fn_Get_Facstaff_Addresses_Street(B.FacstaffID, 2) AS Address_Street
                  ,dbo.DM_OUTLOOK_fn_Get_Facstaff_Addresses_City(B.FacstaffID, 2) AS Address_City 
				  ,'IL' as Address_State_Code
				  ,dbo.DM_OUTLOOK_fn_Get_Facstaff_Addresses_PostalCode(B.FacstaffID, 2) AS Address_Postal_Code
				  ,'USA' as Address_Country
				  --,dbo.OUTLOOK_fn_Get_Facstaff_Addresses_StateCode(B.FacstaffID, 2) AS Address_State_Code          
				  --,dbo.OUTLOOK_fn_Get_Facstaff_Addresses_Country(B.FacstaffID, 2) AS Address_Country
                  ,dbo.DM_OUTLOOK_fn_Get_Facstaff_Office_Location(B.FacstaffID) AS Address_Office
				  ,dbo.DM_OUTLOOK_fn_Get_Facstaff_Addresses_Complete(B.FacstaffID, 7) AS Campus_Mailbox
                  ,dbo.DM_OUTLOOK_fn_Get_Work_Phone_String_By_FSID(B.FacstaffID) AS Address_Phone
				  ,pci.lastmodified as Last_Update_Datetime
				  ,CASE WHEN PFNAME IS NULL 
					THEN FNAME WHEN ltrim(rtrim(PFNAME)) = '' THEN FNAME ELSE PFNAME END AS Preferred_First_Name
				  , CASE WHEN PLNAME IS NULL 
					THEN LNAME WHEN ltrim(rtrim(PLNAME)) = '' THEN last_name ELSE PLNAME END AS Professional_Last_Name
				  ,pci.Create_Datetime
				  ,CASE WHEN BUS_FACULTY ='YES' THEN 1 ELSE 0 END as Faculty_Staff_Indicator
				  --,CASE WHEN BUS_PERSON ='YES' THEN 1 ELSE 0 END as BUS_Person_Indicator
				  ,1 as BUS_Person_Indicator
				  ,CASE WHEN ACTIVE ='YES' THEN 1 ELSE 0 END as Active_Indicator
				  ,CASE WHEN SHOW_COLLEGE ='YES' THEN 1 ELSE 0 END as College_Directory_Indicator
				  ,EMPEE_CLS_CD
                  ,CASE WHEN [Rank] IS NULL OR [Rank]='' THEN 'Rank Unknown' ELSE [RANK] end AS [RANK]
				  ,dbo.DM_OUTLOOK_fn_Get_Rank_ID ([RANK]) as Rank_ID
				  
				  ,CAST (CAST (COLLEGE_JOB_DETL_FTE as INTEGER) as varchar) as Appointment_Percent
				  ,dbo.DM_OUTLOOK_fn_Get_FSDB_Department_ID(B.Facstaffid) as Department_ID
				  ,b.UIN, JOB_DETL_TITLE, EMPEE_CLS_LONG_DESC, EMPEE_GROUP_CD, EMPEE_GROUP_DESC
				  --, Rank_ID, 
                  ,CASE WHEN DOC_STATUS = 'Current PhD Student' then 1 ELSE 0 END as Doctoral_Flag
				  
FROM     dbo._DM_USERS B 
			INNER JOIN dbo._DM_PCI pci	
				LEFT OUTER JOIN dbo._DM_BANNER banner 
				ON pci.username = banner.username
			ON B.username = pci.username	
				AND pci.ACTIVE='YES'
				AND pci.SHOW_COLLEGE='YES'
				AND B.Service_Account_Indicator <> 1

WHERE  --(BUS_PERSON='Yes') 
		(ACTIVE='Yes') AND (SHOW_COLLEGE='Yes')
		AND Service_Account_Indicator <> 1

		--AND (EMPEE_CLS_CD IS NOT NULL) AND (EMPEE_CLS_CD LIKE 'A%' OR
  --                EMPEE_CLS_CD LIKE 'B%' OR
  --                EMPEE_CLS_CD LIKE 'C%' OR
  --                EMPEE_CLS_CD LIKE 'E%' OR
  --                EMPEE_CLS_CD LIKE 'G%' OR
  --                EMPEE_CLS_CD LIKE 'H%' OR
  --                EMPEE_CLS_CD LIKE 'P%' OR
  --                EMPEE_CLS_CD LIKE 'S%' OR
  --                EMPEE_CLS_CD LIKE 'T%' OR
  --                EMPEE_CLS_CD LIKE 'U%') 
		

ORDER BY B.FacstaffID asc
GO
