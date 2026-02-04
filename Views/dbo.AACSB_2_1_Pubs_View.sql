SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[AACSB_2_1_Pubs_View]
AS
SELECT        Log_ID, Facstaff_ID, AACSB_Department, Author_Share, Author_Name, Authors, IC_Type, Gies_IC_Type, Refereed, [AJ Confirmed], Classified, AACSB_Class, Journal_Name, Pub_Type, Range_Boundary, RP_Year, Month_Name, 
                         Research_Publication_ID, Research_Publication_Type, Research_Publication_Title, Sub_Title, Research_Publication_Contribution_Type, Research_Publication_Sub_Type, Book_Role_ID, Scope_ID, 
                         Research_Publication_Refereed_Indicator, Editorial_Indicator, Journal_ID, Conference_ID, Research_Publication_Pages, Publication_Issue_ID, Publisher_ID, Year, Accepted_Year, Published_Year, Volume, Number, 
                         Research_Publication_Description, Research_Publication_Status_Indicator, Invited_Indicator, Conference_Name, Conference_City, Conference_State, Conference_Country, Conference_Month, Full_Paper_Indicator, Editor, 
                         Revision_Indicator, Under_Review_Indicator, SSRN_ID, DOI, Perennial_Display_Indicator, Active_Indicator, Create_Datetime, Last_Update_Datetime, Last_Update_Network_ID, Pub_Status, Pub_Title, Book_Title, 
                         Month_Num
FROM            dbo.AACSB_2_1_Pubs
WHERE        (Log_ID IN
                             (SELECT        MAX(Log_ID) AS Expr1
                               FROM            dbo.AACSB_2_1_Pubs AS AACSB_2_1_Pubs_1))
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
         Begin Table = "AACSB_2_1_Pubs"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 343
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
', 'SCHEMA', N'dbo', 'VIEW', N'AACSB_2_1_Pubs_View', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'AACSB_2_1_Pubs_View', NULL, NULL
GO
