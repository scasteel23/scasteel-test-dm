SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[Facstaff_AACSB_View]
AS
SELECT        fa.Facstaff_ID, fa.Full_Name, fa.AACSB_Department, fa.Discipline1, fa.Discipline2, fa.Specialty, fa.NPR_Administration, fa.NPR_Doctoral, fa.NPR_Executive, fa.NPR_Masters, fa.NPR_Research, fa.NPR_Undergrad, 
                         fa.NPR_Other, fa.Percent_Time, fa.Qualification, fa.Qualification_Description, fa.Sufficiency, fa.Joint_Appointment, fa.Highest_Degree, fa.Degree_Year, fa.First_Appointment_Date, fa.Exclude_Flag, fa.FTE, 
                         fa.First_Appt_Date_Orig, fa.Research_PhD_Flag, fa.Professional_Experience_Flag, fa.Professional_Certification_Flag, fa.Dept_Rank, fa.Qualification_Justification, fa.Notes1, fa.Notes2, fa.Last_Update_Datetime, 
                         fa.CUR_HIRE_DT, fa.EDW_PERS_ID, fa.Network_ID, fa.UIN, fa.FSDB_Facstaff_ID, fa.Academic_Year, ad1.Discipline AS Discipline1_Name, ad2.Discipline AS Discipline2_Name, sp.Specialty AS Specialty_Name
FROM            dbo.Facstaff_AACSB AS fa LEFT OUTER JOIN
                         dbo.AACSB_Disciplines AS ad1 ON ad1.Discipline_ID = fa.Discipline1 LEFT OUTER JOIN
                         dbo.AACSB_Disciplines AS ad2 ON ad2.Discipline_ID = fa.Discipline2 LEFT OUTER JOIN
                         dbo.AACSB_Specialties AS sp ON sp.Specialty_ID = fa.Specialty
WHERE        (fa.Academic_Year = '2021')
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
         Configuration = "(H (4[30] 2[40] 3) )"
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
         Begin Table = "fa"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 138
               Right = 291
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ad1"
            Begin Extent = 
               Top = 6
               Left = 326
               Bottom = 136
               Right = 532
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "ad2"
            Begin Extent = 
               Top = 6
               Left = 570
               Bottom = 136
               Right = 776
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "sp"
            Begin Extent = 
               Top = 6
               Left = 814
               Bottom = 136
               Right = 1020
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
', 'SCHEMA', N'dbo', 'VIEW', N'Facstaff_AACSB_View', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'Facstaff_AACSB_View', NULL, NULL
GO
