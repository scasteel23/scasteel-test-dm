SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[FSDB_Facstaff_Basic_View]
AS
SELECT        FSB.Facstaff_ID, FSB.UIN, FSB.EDW_PERS_ID, FSB.EMPEE_DEPT_CD, FSB.EMPEE_DEPT_NAME, FSB.EMPEE_CLS_CD, FSB.EMPEE_CLS_LONG_DESC, FSB.POSN_EMPEE_CLS_CD, FSB.POSN_EMPEE_CLS_LONG_DESC, 
                         FSB.EMPEE_GROUP_CD, FSB.EMPEE_GROUP_DESC, FSB.POSN_NBR, FSB.JOB_DETL_DEPT_CD, FSB.JOB_DETL_DEPT_NAME, FSB.JOB_DETL_TITLE, FSB.JOB_DETL_FTE, FSB.JOB_CNTRCT_TYPE_DESC, 
                         FSB.JOB_SUFFIX, FSB.FAC_RANK_CD, FSB.FAC_RANK_DESC, FSB.FAC_RANK_ACT_DT, FSB.FAC_RANK_DECN_DT, FSB.FAC_RANK_EMRTS_STATUS_IND, FSB.Network_ID, FSB.Non_BUS_Person_Institution, 
                         FSB.BUS_Person_Indicator, FSB.SSRN_ID, FSB.ORCID, FSB.Google_Scholar_ID, FSB.Department_ID, FSB.Department_Subgroup_ID, FSB.Last_Name, FSB.PERS_MNAME, FSB.Middle_Name, FSB.First_Name, 
                         FSB.PERS_PREFERRED_FNAME, FSB.Professional_Last_Name, FSB.Faculty_Staff_Indicator, FSB.Graduate_Assistant_Indicator, FSB.Staff_Classification_ID, FSB.Campus_Wide_Appointment_Percent, 
                         FSB.Appointment_Percent, FSB.Appointment_Type_Indicator, FSB.Current_Status_Indicator, FSB.Tenure_Status_Indicator, FSB.Tenure_Track_Status_Indicator, FSB.Third_Year_Review_Status, FSB.Rank_ID, FSB.Title_ID, 
                         FSB.Email_Address, FSB.Home_Page, FSB.Teaching_Interests, FSB.Research_Interests, FSB.Ethnicity_ID, FSB.Citizenship_ID, FSB.Gender, FSB.Birth_Date, FSB.Hired_Date, FSB.Leaving_Date, FSB.Teaching_MBA_Indicator, 
                         FSB.Emergency_Contact_Name, FSB.Emergency_Contact_Type, FSB.Emergency_Contact_Phone_International_Access, FSB.Emergency_Contact_Phone_Area_Code, FSB.Emergency_Contact_Phone_Number, 
                         FSB.Emergency_Contact_Phone_Extension, FSB.College_List_Indicator, FSB.Department_List_Indicator, FSB.Biographical_Sketch, FSB.Create_Datetime, FSB.Last_Update_Datetime, FSB.Active_Indicator, 
                         FSB.Bus_Person_Manual_Entry_Indicator, FSB.College_Directory_Indicator, FSB.Doctoral_Flag, FSB.Doctoral_Department_ID, FSB.Doctoral_Award_Term_CD, FSB.Last_EDW_Update_Datetime, D.DM_Department_Name
FROM            Faculty_Staff_Holder.dbo.Facstaff_Basic AS FSB LEFT OUTER JOIN
                         dbo.FSDB_Departments AS D ON FSB.Department_ID = D.Department_ID
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
         Begin Table = "FSB"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 385
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "D"
            Begin Extent = 
               Top = 6
               Left = 423
               Bottom = 136
               Right = 709
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
', 'SCHEMA', N'dbo', 'VIEW', N'FSDB_Facstaff_Basic_View', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=1
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'FSDB_Facstaff_Basic_View', NULL, NULL
GO
