SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[AACSB_15_2_Step1_Courses_View]
AS
SELECT        Log_ID, Courses_BUS_ID, Facstaff_ID, AACSB_Instructor, AACSB_Section, EDW_PERS_ID, TERM_CD, TERM_DESC, CRS_ID, CRS_TITLE, CRS_SUBJ_CD, CRS_NBR, CRS_DESC_TXT, CRN, SECT_NBR, SECT_LINK_ID, 
                         LINKED_SECT_ID, SCHED_TYPE_CD, SCHED_TYPE_DESC, PERS_FNAME, PERS_MNAME, PERS_LNAME, PERS_NAME_SUFFIX, PERS_PREFERRED_FNAME, CRS_LEVEL, CRS_REPEAT_STATUS_CD, CENSUS_ENROLL, 
                         ENROLL, CHOURS, DMI_HOURS, FAC_ASSIGN_RESP_PCT, CHOURS_TXT, DMI_HOURS_TXT, CENSUS_TWO_ENRL, SECT_CENSUS_ENRL_NBR, CRS_CONTACT_HOUR_IND, CRS_MIN_CONTACT_HOUR, 
                         CRS_MAX_CONTACT_HOUR, CREDIT_HOUR, CRS_VAR_CREDIT_HOUR_IND, CRS_MIN_CREDIT_HOUR_NBR, CRS_MAX_CREDIT_HOUR_NBR, PART_OF_TERM_CD, Num_Instructors, Num_AACSB_Instructors, 
                         Num_Course_Instructors, Num_Course_AACSB_Instructors, Course_Load_Weight, CRN_Enroll, CRS_Enroll, CRN_SCH, CRS_SCH, Num_Resp_Instructors, AACSB_Resp_Instructors, CRN_Resp_Total, AACSB_Resp_Total, 
                         Resp_Share, AACSB_Resp_Share, Qualification, SCH_Share, Ignore_Flag
FROM            dbo.AACSB_15_2_Step1_Courses
WHERE        (Log_ID IN
                             (SELECT        MAX(Log_ID) AS Expr1
                               FROM            dbo.AACSB_15_2_Step1_Courses AS AACSB_15_2_Step1_Courses_1))
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
         Begin Table = "AACSB_15_2_Step1_Courses"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 299
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
', 'SCHEMA', N'dbo', 'VIEW', N'AACSB_15_2_Step1_Courses_View', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'AACSB_15_2_Step1_Courses_View', NULL, NULL
GO
