SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 9/16/2016 - this SP may not be needed
CREATE PROC [dbo].[Adhoc_sp__Transition_06Compare_Fasctaff_Basic_Between_FSDB_and_DM] 
AS

BEGIN

		-- COMPARE 
		--		Faculty_Staff_Holder.dbo.Facstaff_Basic
		--		DM_Shadow_Staging.dbo.FSDB_Facstaff_Basic

		SELECT distinct Network_ID,UIN, Faculty_Staff_Holder.dbo.FSD_fn_Get_Department_Name(Department_ID) d,
			First_name f, ISNULL(middle_Name,'') m,last_name l,
			0 as lastNameChangedInTheLastWeek
		FROM Faculty_Staff_Holder.dbo.Facstaff_Basic
		WHERE Active_Indicator = 1 AND Bus_Person_Indicator = 1 AND Network_ID is not null
			-- DEBUG:
			--AND Network_ID Not in (Select username FROM DM_Shadow_Production.dbo._DM_USERS)

		SELECT distinct Network_ID,UIN, Faculty_Staff_Holder.dbo.FSD_fn_Get_Department_Name(Department_ID) d,
			First_name f, ISNULL(middle_Name,'') m,last_name l,
			0 as lastNameChangedInTheLastWeek
		FROM Faculty_Staff_Holder.dbo.Facstaff_Basic
		WHERE Active_Indicator = 1 AND Bus_Person_Indicator = 1 AND Network_ID is not null
			AND NOT EXISTS (SELECT Network_ID FROM  DM_Shadow_Staging.dbo.FSDB_Facstaff_Basic
					WHERE Facstaff_Basic.Network_ID = Network_ID AND Active_Indicator = 1 AND Bus_Person_Indicator = 1 AND Network_ID is not null)

		SELECT  distinct Network_ID NETID,UIN, Faculty_Staff_Holder.dbo.FSD_fn_Get_Department_Name(Department_ID) d,
			First_name f, ISNULL(middle_Name,'') m,last_name l,
			0 as lastNameChangedInTheLastWeek
		FROM DM_Shadow_Staging.dbo.FSDB_Facstaff_Basic
		WHERE Active_Indicator = 1 AND Bus_Person_Indicator = 1 AND Network_ID is not null

		SELECT  distinct Network_ID NETID,UIN, Faculty_Staff_Holder.dbo.FSD_fn_Get_Department_Name(Department_ID) d,
			First_name f, ISNULL(middle_Name,'') m,last_name l,
			0 as lastNameChangedInTheLastWeek
		FROM DM_Shadow_Staging.dbo.FSDB_Facstaff_Basic
		WHERE Active_Indicator = 1 AND Bus_Person_Indicator = 1 AND Network_ID is not null
			AND NOT EXISTS (SELECT Network_ID FROM Faculty_Staff_Holder.dbo.Facstaff_Basic
				WHERE FSDB_Facstaff_Basic.Network_ID = Network_ID AND Active_Indicator = 1 AND Bus_Person_Indicator = 1 AND Network_ID is not null)
			


END


GO
