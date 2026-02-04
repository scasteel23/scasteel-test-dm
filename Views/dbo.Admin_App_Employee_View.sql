SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE VIEW [dbo].[Admin_App_Employee_View]
AS
with org_chart_emps as (
	-- Employees with appointment in past year
	SELECT	DISTINCT EDW_PERS_ID, 'appointment' as Emp_Status
	FROM	dbo.FSDB_EDW_Current_Employees
	WHERE	EDW_Database = 'HR'   
			AND Create_Datetime > DATEADD(D, - 365, CURRENT_TIMESTAMP)
	
	union

	-- Emeriti faculty
	select EDWPERSID, 'emeritus' as Emp_Status
	from DM_Employee_Admin_View v
	where Enabled_Indicator = 1
		and [rank] like '%emerit%'
		and SHOW_COLLEGE = 'Yes'
)

SELECT DISTINCT 
        fsb.Facstaff_ID, fsb.EDW_PERS_ID, fsb.UIN, fsb.Network_ID, 
		ISNULL(edw.PERS_FNAME, fsb.First_Name) AS Banner_First_Name, ISNULL(edw.PERS_PREFERRED_FNAME, fsb.PERS_PREFERRED_FNAME) AS Banner_Preferred_First_Name, 
		ISNULL(edw.PERS_MNAME, fsb.PERS_MNAME) AS Banner_Middle_Name, ISNULL(edw.PERS_LNAME, fsb.Last_Name) AS Banner_Last_Name, 
		ISNULL(ISNULL(u.First_Name, edw.PERS_FNAME), '') AS Display_First_Name, ISNULL(ISNULL(u.Middle_Name, edw.PERS_MNAME), '') AS Display_Middle_Name, 
		ISNULL(ISNULL(u.Last_Name, edw.PERS_LNAME), '') AS Display_Last_Name, 
        ISNULL(fsb.EMPEE_CLS_CD, edw.EMPEE_CLS_CD) AS Employee_Class_Code, ISNULL(u.TITLE, '') AS Titles
FROM    dbo.FSDB_Facstaff_Basic fsb
INNER JOIN org_chart_emps o 
	ON fsb.EDW_PERS_ID = o.EDW_PERS_ID 
		AND fsb.Active_Indicator = 1 
LEFT OUTER JOIN dbo.EDW_Current_Employees_View edw 
	ON fsb.EDW_PERS_ID = edw.EDW_PERS_ID
LEFT OUTER JOIN dbo.DM_Employee_Title_List_View u 
	ON u.EDWPERSID = fsb.EDW_PERS_ID 
		AND u.Enabled_Indicator = 1 
		AND u.SEQ = 1
WHERE	edw.EDW_Database = 'HR'
		OR (fsb.Bus_Person_Manual_Entry_Indicator = 1
				AND o.Emp_Status = 'appointment')
		OR o.Emp_Status= 'emeritus'

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
         Configuration = "(H (2[66] 3) )"
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
      ActivePaneConfig = 5
   End
   Begin DiagramPane = 
      PaneHidden = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "fsb"
            Begin Extent = 
               Top = 13
               Left = 86
               Bottom = 293
               Right = 777
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "p"
            Begin Extent = 
               Top = 13
               Left = 1992
               Bottom = 176
               Right = 2290
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "edw"
            Begin Extent = 
               Top = 13
               Left = 863
               Bottom = 293
               Right = 1392
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "u"
            Begin Extent = 
               Top = 13
               Left = 1478
               Bottom = 293
               Right = 1812
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
      Begin ColumnWidths = 14
         Width = 284
         Width = 660
         Width = 660
         Width = 660
         Width = 660
         Width = 660
         Width = 660
         Width = 660
         Width = 660
         Width = 660
         Width = 660
         Width = 660
         Width = 660
         Width = 660
      End
   End
   Begin CriteriaPane = 
      PaneHidden = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder ', 'SCHEMA', N'dbo', 'VIEW', N'Admin_App_Employee_View', NULL, NULL
GO
EXEC sp_addextendedproperty N'MS_DiagramPane2', N'= 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', N'dbo', 'VIEW', N'Admin_App_Employee_View', NULL, NULL
GO
DECLARE @xp int
SELECT @xp=2
EXEC sp_addextendedproperty N'MS_DiagramPaneCount', @xp, 'SCHEMA', N'dbo', 'VIEW', N'Admin_App_Employee_View', NULL, NULL
GO
