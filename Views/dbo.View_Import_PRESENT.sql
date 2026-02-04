SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[View_Import_PRESENT]
AS
SELECT        USERNAME, TITLE, CLASSIFICATION, MEETING_TYPE, NAME, SCOPE_LOCALE, REFEREED, ORG, [DESC], STATUS, CITY, STATE, COUNTRY, DTM_DATE, 
                         DTY_DATE, SSRN_ID, DOI, PERENNIAL, PRESENT_AUTH_1_FACULTY_NAME, PRESENT_AUTH_1_FNAME, PRESENT_AUTH_1_MNAME, 
                         PRESENT_AUTH_1_LNAME, PRESENT_AUTH_1_WEB_PROFILE, PRESENT_AUTH_2_FACULTY_NAME, PRESENT_AUTH_2_FNAME, PRESENT_AUTH_2_MNAME, 
                         PRESENT_AUTH_2_LNAME, PRESENT_AUTH_2_WEB_PROFILE, PRESENT_AUTH_3_FACULTY_NAME, PRESENT_AUTH_3_FNAME, PRESENT_AUTH_3_MNAME, 
                         PRESENT_AUTH_3_LNAME, PRESENT_AUTH_3_ROLE, PRESENT_AUTH_3_WEB_PROFILE, PRESENT_AUTH_4_FACULTY_NAME, PRESENT_AUTH_4_FNAME, 
                         PRESENT_AUTH_4_MNAME, PRESENT_AUTH_4_LNAME, PRESENT_AUTH_4_ROLE, PRESENT_AUTH_4_WEB_PROFILE, PRESENT_AUTH_5_FACULTY_NAME, 
                         PRESENT_AUTH_5_FNAME, PRESENT_AUTH_5_MNAME, PRESENT_AUTH_5_LNAME, PRESENT_AUTH_5_ROLE, PRESENT_AUTH_5_WEB_PROFILE, 
                         PRESENT_AUTH_6_FACULTY_NAME, PRESENT_AUTH_6_FNAME, PRESENT_AUTH_6_MNAME, PRESENT_AUTH_6_LNAME, PRESENT_AUTH_6_ROLE, 
                         PRESENT_AUTH_6_WEB_PROFILE, PRESENT_AUTH_7_FACULTY_NAME, PRESENT_AUTH_7_FNAME, PRESENT_AUTH_7_MNAME, PRESENT_AUTH_7_LNAME, 
                         PRESENT_AUTH_7_ROLE, PRESENT_AUTH_7_WEB_PROFILE, PRESENT_AUTH_8_FACULTY_NAME, PRESENT_AUTH_8_FNAME, PRESENT_AUTH_8_MNAME, 
                         PRESENT_AUTH_8_LNAME, PRESENT_AUTH_8_ROLE, PRESENT_AUTH_8_WEB_PROFILE, PRESENT_AUTH_9_FACULTY_NAME, PRESENT_AUTH_9_FNAME, 
                         PRESENT_AUTH_9_MNAME, PRESENT_AUTH_9_LNAME, PRESENT_AUTH_9_ROLE, PRESENT_AUTH_9_WEB_PROFILE, PRESENT_AUTH_10_FACULTY_NAME, 
                         PRESENT_AUTH_10_FNAME, PRESENT_AUTH_10_MNAME, PRESENT_AUTH_10_LNAME, PRESENT_AUTH_10_ROLE, PRESENT_AUTH_10_WEB_PROFILE, 
                         PRESENT_AUTH_11_FACULTY_NAME, PRESENT_AUTH_11_FNAME, PRESENT_AUTH_11_MNAME, PRESENT_AUTH_11_LNAME, PRESENT_AUTH_11_ROLE, 
                         PRESENT_AUTH_11_WEB_PROFILE, PRESENT_AUTH_12_FACULTY_NAME, PRESENT_AUTH_12_FNAME, PRESENT_AUTH_12_MNAME, 
                         PRESENT_AUTH_12_LNAME, PRESENT_AUTH_12_ROLE, PRESENT_AUTH_12_WEB_PROFILE
FROM            dbo._UPLOADED_DM_PRESENT
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
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
         Begin Table = "_UPLOADED_DM_PRESENT"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 352
               Right = 366
            End
            DisplayFlags = 280
            TopColumn = 86
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
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
', 'SCHEMA', N'dbo', 'VIEW', N'View_Import_PRESENT', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'View_Import_PRESENT', NULL, NULL
GO
