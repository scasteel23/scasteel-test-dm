SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[EDW_Current_Employees_View]
AS
SELECT EDW_PERS_ID, UIN, Network_ID, EDW_Database, PERS_PREFERRED_FNAME, PERS_FNAME, PERS_MNAME, PERS_LNAME, BIRTH_DT, SEX_CD, RACE_ETH_CD, RACE_ETH_DESC, PERS_CITZN_TYPE_DESC, EMPEE_CAMPUS_CD, EMPEE_CAMPUS_NAME, EMPEE_COLL_CD, EMPEE_COLL_NAME, EMPEE_DEPT_CD, EMPEE_DEPT_NAME, JOB_DETL_TITLE, JOB_DETL_FTE, JOB_CNTRCT_TYPE_DESC, 
          JOB_DETL_DATA_STATUS_DESC, JOB_DETL_COLL_CD, JOB_DETL_COLL_NAME, JOB_DETL_DEPT_CD, JOB_DETL_DEPT_NAME, COA_CD, ORG_CD, EMPEE_ORG_TITLE, EMPEE_CLS_CD, EMPEE_CLS_LONG_DESC, EMPEE_GROUP_CD, EMPEE_GROUP_DESC, EMPEE_RET_IND, EMPEE_LEAVE_CATGRY_CD, EMPEE_LEAVE_CATGRY_DESC, BNFT_CATGRY_CD, BNFT_CATGRY_DESC, HR_CAMPUS_CD, 
          HR_CAMPUS_NAME, EMPEE_STATUS_CD, EMPEE_STATUS_DESC, CAMPUS_JOB_DETL_FTE, COLLEGE_JOB_DETL_FTE, Univ_Sum_FTE, Sum_FTE, FAC_RANK_CD, FAC_RANK_DESC, FAC_RANK_ACT_DT, FAC_RANK_DECN_DT, FAC_RANK_ACAD_TITLE, FAC_RANK_EMRTS_STATUS_IND, TENURE_INDICATOR, FIRST_HIRE_DT, CUR_HIRE_DT, FIRST_WORK_DT, LAST_WORK_DT, EMPEE_TERMN_DT, JOB_SUFFIX, 
          POSN_NBR, JOB_DETL_EEO_SKILL_CD, JOB_DETL_EEO_SKILL_DESC, JOB_DETL_EFF_DT, POSN_EMPEE_CLS_CD, POSN_EMPEE_CLS_LONG_DESC, EMPEE_SUB_DEPT_LEVEL_6_CD, EMPEE_SUB_DEPT_LEVEL_6_NAME, EMPEE_SUB_DEPT_LEVEL_7_CD, EMPEE_SUB_DEPT_LEVEL_7_NAME, NATION_CD, Update_Employee_Indicator, New_Download_Indicator, DM_Upload_Done_Indicator, Create_Datetime
FROM   dbo.FSDB_EDW_Current_Employees AS e
WHERE  (New_Download_Indicator = 1)
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
         Begin Table = "e"
            Begin Extent = 
               Top = 13
               Left = 86
               Bottom = 293
               Right = 615
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
         Width = 667
         Width = 667
         Width = 667
         Width = 667
         Width = 667
         Width = 667
         Width = 667
         Width = 667
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1173
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1353
         SortOrder = 1413
         GroupBy = 1350
         Filter = 1353
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'EDW_Current_Employees_View', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'EDW_Current_Employees_View', NULL, NULL
GO
