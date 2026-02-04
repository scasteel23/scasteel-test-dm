SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 12/18/2018
--	Prepare DM's FSDB related tables from FSDB
--	1. Run this SP Adhoc_sp__Transition_FSDB_to_DM
--	2. Start the daily job, from this time on FSDB'Facstaff_Basic and 
--		DM's FSDB_Facstaff_basuc may have different Facstaff_ID on their new records

CREATE PROC [dbo].[Adhoc_sp__Transition_00FSDB_to_DM]
AS

	EXEC Adhoc_sp_Add_DM_With_New_Users_From_Facstaff_Basic
	EXEC DailyUpdate_sp_DM_Step04_New_Employees_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees
	EXEC Adhoc_sp_Initialize_DM_BANNER
	EXEC Adhoc_sp_Initialize_Facstaff_Basic_From_FSDB
	EXEC Adhoc_sp_Initialize_FSDB_Course_Details
	EXEC Adhoc_sp_Initialize_Journal_Short_Names
GO
