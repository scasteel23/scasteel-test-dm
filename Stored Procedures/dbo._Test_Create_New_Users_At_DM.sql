SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- NS 8/11/2017
-- NS 3/7/2017

CREATE PROC [dbo].[_Test_Create_New_Users_At_DM]
AS
	/*
		1. Edit Test_Create_New_Users_At_DM SP
				This SP populates USERS table with new users to add to DM, indicate the records with Load_Scope = 'Y'
				(all other records must have Load_Scope = 'N')
		2. Run produce_XML_USERS SP
				This SP convert those records into XML, and put the POST records into web_services_requests table
				leave web_services_requests.completed to NULL
				Once done check web_services_requests table whether related new records are actually created
		3. Run SSIS package FSDB_Post_Users
				This module connects to DM webservices and submit each records (marked by ) from web_services_requests table
				whose web_services_requests.completed is NULL
		

	*/

	--NS 8/11/2017 no longer need USERS table, in order to test add/update users, Network ID is directly put in produce_XML_USERS

	--UPDATE USERS SET Load_Scope='N'

	--INSERT INTO USERS (
	--	username, Facstaff_ID, EDW_PERS_ID, UIN, First_Name, Middle_Name, Last_Name, Email_Address, Enabled_Indicator, Load_Scope
	--				 ,Update_Datetime
	--)
	--select network_id, Facstaff_ID, EDW_PERS_ID, UIN, First_Name, Middle_Name, Last_Name, network_id + '@illinois.edu', 1, 'Y'
	--				, getdate()
	--from faculty_Staff_Holder.dbo.facstaff_basic
	--where network_id in ('ckwood','sougiani')


	EXEC dbo.[produce_XML_USERS] 1


	--where facstaff_id in (264, 101564, 15923, 11937, 17047, 59, 16336, 101396)		-- 3/14/2017
	--where facstaff_id in (13853, 13703, 78, 129, 15905)	-- 3/7/2017

	--SELECT * FROM USERS

	




GO
