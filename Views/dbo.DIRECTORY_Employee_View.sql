SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[DIRECTORY_Employee_View]
AS

WITH ranks AS (
	SELECT a.FACSTAFFID, a.RANK
	FROM dbo._DM_ADMIN a
				INNER JOIN 
					(
						SELECT FACSTAFFID, MAX(AC_YEAR) AS AC_YEAR
						FROM dbo._DM_ADMIN
						GROUP BY FACSTAFFID, AC_YEAR
					)amax
				ON a.FACSTAFFID=amax.FACSTAFFID
					AND a.AC_YEAR = amax.AC_YEAR
)
SELECT B.FacstaffID AS Facstaff_ID, B.EDWPERSID AS EDW_PERS_ID, ISNULL(B.username, '') AS Network_ID, banner.EMPEE_CLS_CD, dbo.DM_OUTLOOK_fn_Get_Fullname_Official_By_FSID(B.FacstaffID) AS Fullname, dbo.DM_OUTLOOK_fn_Get_Display_Name_With_Middle_Initial_By_FSID(B.FacstaffID) AS Display_Name, pci.LNAME AS Last_Name, pci.FNAME AS First_Name, 
         pci.MNAME AS Middle_Name, CASE WHEN b.username IS NULL THEN '' ELSE b.username + '@illinois.edu' END AS Email_Address, dbo.DM_OUTLOOK_fn_Get_Department_Name(B.FacstaffID) AS Primary_Department, dbo.DM_OUTLOOK_fn_Get_Department_Name(B.FacstaffID) AS Departments, dbo.DM_OUTLOOK_fn_Get_Facstaff_Self_Titles_String(B.FacstaffID, 
         banner.EMPEE_GROUP_CD) AS Titles, dbo.DM_OUTLOOK_fn_Get_Facstaff_Addresses_Complete_Format1(B.FacstaffID, 2) AS Address_Complete, dbo.DM_OUTLOOK_fn_Get_Facstaff_Addresses_Complete_Format1(B.FacstaffID, 2) AS Address_Complete_Original, dbo.DM_OUTLOOK_fn_Get_Facstaff_Addresses_Building_Name(B.FacstaffID, 2) AS Building_Name, 
         dbo.DM_OUTLOOK_fn_Get_Facstaff_Addresses_Street(B.FacstaffID, 2) AS Address_Street, dbo.DM_OUTLOOK_fn_Get_Facstaff_Addresses_City(B.FacstaffID, 2) AS Address_City, 'IL' AS Address_State_Code, dbo.DM_OUTLOOK_fn_Get_Facstaff_Addresses_PostalCode(B.FacstaffID, 2) AS Address_Postal_Code, 'USA' AS Address_Country, 
         dbo.DM_OUTLOOK_fn_Get_Facstaff_Office_Location(B.FacstaffID) AS Address_Office, dbo.DM_OUTLOOK_fn_Get_Facstaff_Addresses_Complete(B.FacstaffID, 7) AS Campus_Mailbox, dbo.DM_OUTLOOK_fn_Get_Work_Phone_String_By_FSID(B.FacstaffID) AS Address_Phone, pci.lastModified AS Last_Update_Datetime, CASE WHEN PFNAME IS NULL 
         THEN FNAME WHEN ltrim(rtrim(PFNAME)) = '' THEN FNAME ELSE PFNAME END AS Preferred_First_Name, CASE WHEN PLNAME IS NULL THEN LNAME WHEN ltrim(rtrim(PLNAME)) = '' THEN last_name ELSE PLNAME END AS Professional_Last_Name, pci.Create_datetime, CASE WHEN BUS_FACULTY = 'YES' THEN 1 ELSE 0 END AS Faculty_Staff_Indicator, 
         1 AS BUS_Person_Indicator, CASE WHEN ACTIVE = 'YES' THEN 1 ELSE 0 END AS Active_Indicator, CASE WHEN SHOW_COLLEGE = 'YES' THEN 1 ELSE 0 END AS College_Directory_Indicator, banner.EMPEE_CLS_CD AS Expr1, CASE WHEN r.[Rank] IS NULL OR
         R.[Rank] = '' THEN 'Rank Unknown' ELSE r.[RANK] END AS [RANK], dbo.DM_OUTLOOK_fn_Get_Rank_ID(r.[RANK]) AS Rank_ID, CAST(CAST(banner.COLLEGE_JOB_DETL_FTE AS INTEGER) AS varchar) AS Appointment_Percent, dbo.DM_OUTLOOK_fn_Get_FSDB_Department_ID(B.FacstaffID) AS Department_ID, B.UIN, banner.JOB_DETL_TITLE, banner.EMPEE_CLS_LONG_DESC, 
         banner.EMPEE_GROUP_CD, banner.EMPEE_GROUP_DESC, CASE WHEN DOC_STATUS = 'YES' THEN 1 ELSE 0 END AS Doctoral_Flag
FROM  dbo._DM_USERS AS B 
			INNER JOIN    dbo._DM_PCI AS pci 
				LEFT OUTER JOIN   dbo._DM_BANNER AS banner 
				ON pci.USERNAME = banner.USERNAME 
			ON B.username = pci.USERNAME AND (pci.ACTIVE = 'YES' OR
				pci.ACTIVE = '') AND B.Service_Account_Indicator <> 1

			LEFT OUTER JOIN Ranks R
			ON r.FACSTAFFID = B.FacstaffID
WHERE (pci.ACTIVE = 'Yes' OR
         pci.ACTIVE = '') AND (B.Service_Account_Indicator <> 1) AND (B.Enabled_Indicator = 1)
GO
