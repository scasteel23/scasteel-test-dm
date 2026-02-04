SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 3/12/2019 revisited
-- NS 12/21/2018

CREATE PROC [dbo].[produce_XML_ADMIN_Update_ADMIN_Update_All] ( @submit BIT=0 )
AS


/*
	On DM_Shadow_Production, _DM_USERS table is all Users in DM site. 
	On DM_Shadow_Staging, _DM_USERS table is all Users in DM site + new users 
			new users are users that exist on dbo.FSDB_Facstaff_Basic but not in DM_Shadow_Production.dbo._DM_USERS
	There is a daily upload of new users to DM_Shadow_Staging.dbo._DM_USERS table

	 Get Facstaff_Basic into _UPLOAD_DM_USERS table
	 _1PHASE2_sp_DM_Upload_Update_or_Add_Users_From_Facstaff_Basic

	 Manual run to upload USERS FROM FSDB  -- 6 minutes for 600 records
	 EXEC dbo.[produce_XML_ADMIN_Update_ADMIN_Update_All] @submit = 0		-- request to upload to DM
	 EXEC dbo.webservices_initiate @screen='ADMIN'							-- request to shadow
	 EXEC dbo.webservices_run_DTSX											-- execute the requests
*/

	--NS 3/12/2019 ADMIN_DEP already added at PROC dbo.produce_XML_USERS_add_update
	--EXEC dbo.produce_XML_ADMIN_Update_ADMIN_DEP @submit = @submit			-- done 3/20/2019

	EXEC dbo.produce_XML_ADMIN_Update_ADMIN_EMPGROUP @submit =  @submit		-- done 3/20/2019
	EXEC dbo.produce_XML_ADMIN_Update_ADMIN_EMPTYPE @submit  =  @submit     -- done 3/20/2019
	EXEC dbo.produce_XML_ADMIN_Update_ADMIN_NPRESP	@submit  =  @submit     -- done 3/20/2019

	--NS 3/12/2019 delay ADMIN_PROG on production per Scott's request
	--EXEC dbo.produce_XML_ADMIN_Update_ADMIN_PROG @submit = @submit

	EXEC dbo.produce_XML_ADMIN_Update_ADMIN_TITLE @submit = @submit			-- done 3/20/2019
GO
