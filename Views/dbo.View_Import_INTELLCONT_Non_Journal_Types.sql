SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[View_Import_INTELLCONT_Non_Journal_Types]
AS
SELECT        USERNAME, CLASSIFICATION, CONTYPE, CONTYPEOTHER, TITLE, TITLE_SECONDARY, STATUS, REFEREED, CONFERENCE, PUBLISHER, PUBCTYST, VOLUME, 
                         ISSUE, REVISED, PAGENUM, INVITED, EDITORS, [DESC], SCOPE_LOCALE, PUBLICAVAIL, PROCEEDING_TYPE, ABSTRACT, WEB_ADDRESS, SSRN, DOI, ISBNISSN, 
                         DTM_PREP, DTY_PREP, DTM_EXPSUB, DTD_EXPSUB, DTY_EXPSUB, DTM_SUB, DTD_SUB, DTY_SUB, DTM_ACC, DTY_ACC, DTM_PUB, DTY_PUB, DTD_PUB, 
                         INTELLCONT_AUTH_1_FACULTY_NAME, INTELLCONT_AUTH_1_FNAME, INTELLCONT_AUTH_1_MNAME, INTELLCONT_AUTH_1_LNAME, 
                         INTELLCONT_AUTH_1_INSTITUTION, INTELLCONT_AUTH_1_WEB_PROFILE, INTELLCONT_AUTH_2_FACULTY_NAME, INTELLCONT_AUTH_2_FNAME, 
                         INTELLCONT_AUTH_2_MNAME, INTELLCONT_AUTH_2_LNAME, INTELLCONT_AUTH_2_INSTITUTION, INTELLCONT_AUTH_2_WEB_PROFILE, 
                         INTELLCONT_AUTH_3_FACULTY_NAME, INTELLCONT_AUTH_3_MNAME, INTELLCONT_AUTH_3_LNAME, INTELLCONT_AUTH_3_FNAME, 
                         INTELLCONT_AUTH_3_INSTITUTION, INTELLCONT_AUTH_3_WEB_PROFILE, INTELLCONT_AUTH_4_INSTITUTION, INTELLCONT_AUTH_4_FNAME, 
                         INTELLCONT_AUTH_4_MNAME, INTELLCONT_AUTH_4_LNAME, INTELLCONT_AUTH_4_FACULTY_NAME, INTELLCONT_AUTH_4_WEB_PROFILE, 
                         INTELLCONT_AUTH_5_FACULTY_NAME, INTELLCONT_AUTH_5_FNAME, INTELLCONT_AUTH_5_MNAME, INTELLCONT_AUTH_5_LNAME, 
                         INTELLCONT_AUTH_5_INSTITUTION, INTELLCONT_AUTH_5_WEB_PROFILE, INTELLCONT_AUTH_6_FACULTY_NAME, INTELLCONT_AUTH_6_FNAME, 
                         INTELLCONT_AUTH_6_MNAME, INTELLCONT_AUTH_6_LNAME, INTELLCONT_AUTH_6_INSTITUTION, INTELLCONT_AUTH_6_WEB_PROFILE, 
                         INTELLCONT_AUTH_7_FACULTY_NAME, INTELLCONT_AUTH_7_FNAME, INTELLCONT_AUTH_7_MNAME, INTELLCONT_AUTH_7_LNAME, 
                         INTELLCONT_AUTH_7_INSTITUTION, INTELLCONT_AUTH_7_WEB_PROFILE, INTELLCONT_AUTH_8_FACULTY_NAME, INTELLCONT_AUTH_8_FNAME, 
                         INTELLCONT_AUTH_8_MNAME, INTELLCONT_AUTH_8_LNAME, INTELLCONT_AUTH_8_INSTITUTION, INTELLCONT_AUTH_8_WEB_PROFILE, 
                         INTELLCONT_AUTH_9_FACULTY_NAME, INTELLCONT_AUTH_9_FNAME, INTELLCONT_AUTH_9_MNAME, INTELLCONT_AUTH_9_LNAME, 
                         INTELLCONT_AUTH_9_INSTITUTION, INTELLCONT_AUTH_9_WEB_PROFILE, INTELLCONT_AUTH_10_FACULTY_NAME, INTELLCONT_AUTH_10_FNAME, 
                         INTELLCONT_AUTH_10_MNAME, INTELLCONT_AUTH_10_LNAME, INTELLCONT_AUTH_10_INSTITUTION, INTELLCONT_AUTH_10_WEB_PROFILE, 
                         INTELLCONT_AUTH_11_FACULTY_NAME, INTELLCONT_AUTH_11_FNAME, INTELLCONT_AUTH_11_MNAME, INTELLCONT_AUTH_11_LNAME, 
                         INTELLCONT_AUTH_11_INSTITUTION, INTELLCONT_AUTH_11_WEB_PROFILE, INTELLCONT_AUTH_12_FACULTY_NAME, INTELLCONT_AUTH_12_FNAME, 
                         INTELLCONT_AUTH_12_MNAME, INTELLCONT_AUTH_12_LNAME, INTELLCONT_AUTH_12_INSTITUTION, INTELLCONT_AUTH_12_WEB_PROFILE
FROM            dbo._UPLOADED_DM_INTELLCONT
WHERE        (CONTYPE NOT IN ('Article in a Journal', 'Book Review', 'Working Paper'))
GO
EXEC sp_addextendedproperty N'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[15] 4[46] 2[20] 3) )"
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
         Begin Table = "_UPLOADED_DM_INTELLCONT"
            Begin Extent = 
               Top = 0
               Left = 12
               Bottom = 342
               Right = 408
            End
            DisplayFlags = 280
            TopColumn = 102
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
         Column = 3900
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
', 'SCHEMA', N'dbo', 'VIEW', N'View_Import_INTELLCONT_Non_Journal_Types', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'View_Import_INTELLCONT_Non_Journal_Types', NULL, NULL
GO
