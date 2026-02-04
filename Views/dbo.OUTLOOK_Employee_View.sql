SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[OUTLOOK_Employee_View]
AS
SELECT        B.FacstaffID AS Facstaff_ID, B.EDWPERSID AS EDW_PERS_ID, ISNULL(B.username, '') AS Network_ID, banner.EMPEE_CLS_CD, dbo.DM_OUTLOOK_fn_Get_Fullname_Official_By_FSID(B.FacstaffID) AS Fullname, 
                         dbo.DM_OUTLOOK_fn_Get_Display_Name_With_Middle_Initial_By_FSID(B.FacstaffID) AS Display_Name, pci.LNAME AS Last_Name, pci.FNAME AS First_Name, pci.MNAME AS Middle_Name, CASE WHEN b.username IS NULL 
                         THEN '' ELSE b.username + '@illinois.edu' END AS Email_Address, dbo.DM_OUTLOOK_fn_Get_Department_Name(B.FacstaffID) AS Primary_Department, dbo.DM_OUTLOOK_fn_Get_Department_Name(B.FacstaffID) 
                         AS Departments, dbo.DM_OUTLOOK_fn_Get_Facstaff_Self_Titles_String(B.FacstaffID, banner.EMPEE_GROUP_CD) AS Titles, dbo.DM_OUTLOOK_fn_Get_Facstaff_Addresses_Complete_Format1(B.FacstaffID, 2) 
                         AS Address_Complete, dbo.DM_OUTLOOK_fn_Get_Facstaff_Addresses_Complete_Format1(B.FacstaffID, 2) AS Address_Complete_Original, dbo.DM_OUTLOOK_fn_Get_Facstaff_Addresses_Building_Name(B.FacstaffID, 2) 
                         AS Building_Name, dbo.DM_OUTLOOK_fn_Get_Facstaff_Addresses_Street(B.FacstaffID, 2) AS Address_Street, dbo.DM_OUTLOOK_fn_Get_Facstaff_Addresses_City(B.FacstaffID, 2) AS Address_City, 'IL' AS Address_State_Code, 
                         dbo.DM_OUTLOOK_fn_Get_Facstaff_Addresses_PostalCode(B.FacstaffID, 2) AS Address_Postal_Code, 'USA' AS Address_Country, dbo.DM_OUTLOOK_fn_Get_Facstaff_Office_Location(B.FacstaffID) AS Address_Office, 
                         dbo.DM_OUTLOOK_fn_Get_Facstaff_Addresses_Complete(B.FacstaffID, 7) AS Campus_Mailbox, dbo.DM_OUTLOOK_fn_Get_Work_Phone_String_By_FSID(B.FacstaffID) AS Address_Phone, 
                         pci.lastModified AS Last_Update_Datetime, CASE WHEN PFNAME IS NULL THEN FNAME WHEN ltrim(rtrim(PFNAME)) = '' THEN FNAME ELSE PFNAME END AS Preferred_First_Name, CASE WHEN PLNAME IS NULL 
                         THEN LNAME WHEN ltrim(rtrim(PLNAME)) = '' THEN last_name ELSE PLNAME END AS Professional_Last_Name, pci.Create_datetime, CASE WHEN BUS_FACULTY = 'YES' THEN 1 ELSE 0 END AS Faculty_Staff_Indicator, 
                         1 as BUS_Person_Indicator, CASE WHEN ACTIVE = 'YES' THEN 1 ELSE 0 END AS Active_Indicator, 
                         CASE WHEN SHOW_COLLEGE = 'YES' THEN 1 ELSE 0 END AS College_Directory_Indicator, banner.EMPEE_CLS_CD AS Expr1, CASE WHEN [Rank] IS NULL OR
                         [Rank] = '' THEN 'Rank Unknown' ELSE [RANK] END AS RANK, dbo.DM_OUTLOOK_fn_Get_Rank_ID(pci.RANK) AS Rank_ID, CAST(CAST(banner.COLLEGE_JOB_DETL_FTE AS INTEGER) AS varchar) AS Appointment_Percent, 
                         dbo.DM_OUTLOOK_fn_Get_FSDB_Department_ID(B.FacstaffID) AS Department_ID, B.UIN, banner.JOB_DETL_TITLE, banner.EMPEE_CLS_LONG_DESC, banner.EMPEE_GROUP_CD, banner.EMPEE_GROUP_DESC, 
                         CASE WHEN DOC_STATUS = 'YES' THEN 1 ELSE 0 END AS Doctoral_Flag
FROM            dbo._DM_USERS AS B INNER JOIN
                         dbo._DM_PCI AS pci LEFT OUTER JOIN
                         dbo._DM_BANNER AS banner ON pci.USERNAME = banner.USERNAME ON B.username = pci.USERNAME AND pci.ACTIVE = 'YES' AND pci.SHOW_COLLEGE = 'YES' AND B.Service_Account_Indicator <> 1
WHERE        (pci.ACTIVE = 'Yes') AND (pci.SHOW_COLLEGE = 'Yes') AND (B.Service_Account_Indicator <> 1)


GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[34] 4[3] 2[13] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "B"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 266
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "pci"
            Begin Extent = 
               Top = 6
               Left = 304
               Bottom = 136
               Right = 513
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "banner"
            Begin Extent = 
               Top = 6
               Left = 551
               Bottom = 136
               Right = 812
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 9
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'OUTLOOK_Employee_View', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'OUTLOOK_Employee_View', NULL, NULL
GO
