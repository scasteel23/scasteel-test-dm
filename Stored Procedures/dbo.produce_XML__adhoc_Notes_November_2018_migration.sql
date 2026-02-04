SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 11/7/2018
CREATE PROC [dbo].[produce_XML__adhoc_Notes_November_2018_migration] 
AS

	-- NS 11/7/2018 
	--		_DM_USERS has 2095 records
	--		_UPLOAD_DM_USERS has 43 records, among them 34 new USER records, 9 current USER records with updated info
	--		_UPLOAD_DM_PCI has 47 records, among them 36 new PCI records, 11 current employees with updated info
	--		==> expected that _DM_USERS will be 2129 record after running dbo.produce_XML_USERS_add_update
	--		==> found that _DM_USERS has 2122 records, 7 failed?
	--	NS 11/8/2018
	--		Fixed, see below note on 11/8/2018
	--		Redo
	--
	--		_DM_ADMIN has 2085 records, _DM_ADMIN_DEP 2118 records
	--		after running dbo.produce_XML_ADMIN_Update_All
	--		==> _DM_ADMIN has 2094 records, DM_ADMIN_DEP 2124 records
	/*

	select username, FacstaffID, edwpersid,uin,First_Name, last_name  from _UPLOAD_DM_USERS 
	select * from _UPLOAD_DM_USERS 
	where username not in (select username from _DM_Users where username is not null)
	select * from _dm_users

	username	FacstaffID	edwpersid	uin			First_Name	last_name
	bailelu		103112		4723592		671835077	Baile		Lu
	hhw2		103123		4532146		653281963	Hsin-Hung	Wang
	ilalee		103145		4735561		675364276	Ilalee		Harrison
	kelseyr2	103078		4317953		670497683	Kelsey		Rademacher
	kwagho2		102599		4525489		656837630	Kedar		Wagholikar
	pandita2	102489		4468276		660113442	Vineet		Pandita
	sa15		102647		4559283		679057407	Sushmita	Amarnath
	*/

	-- must do the following order to prepare REST to update ADMIN
	EXEC dbo.produce_XML_USERS_add_update @submit=1
	EXEC dbo.produce_XML_USERS_deactivate @submit=1
	EXEC dbo.webservices_initiate @screen='USERS'
	EXEC dbo.webservices_run_DTSX

	EXEC dbo.produce_XML_PCI @submit=1
	EXEC dbo.webservices_initiate @screen='PCI'
	EXEC dbo.webservices_run_DTSX

	EXEC dbo.webservices_initiate @screen='ADMIN'
	EXEC dbo.webservices_run_DTSX

	EXEC dbo.produce_XML_ADMIN_Update_ADMIN_Update_All @submit=1
	EXEC dbo.webservices_run_DTSX
	
	-- NS 2/15/2019
	-- Rerun this procedures, but we have already sync'ed DM_Shadow_Staging.dbo.FSDB_Facstaff_Basic 
	--		with Faculty_Staff_Holder.dbo.Facstaff_Basic in case
	
	-- NS 11/8/2018
	-- problem of uploading data to DM after 9/17/2018
	-- we upload to USER based on _UPLOAD_DM_USERS table which is sourced from DM_Shadow_Staging db instead of Faculty_Staff_Holder db
	-- this data in turn has different FACSTAFF_ID !!
	-- must delete the following 27 data at DM to undo

	select network_id from Faculty_Staff_Holder.dbo.Facstaff_Basic where create_datetime > '9/18/2018'
	select * from _DM_USERS where Update_Datetime >'9/18/2018' 
    select * from _DM_USERS where Update_Datetime >'9/18/2018' and username in (select network_id from Faculty_Staff_Holder.dbo.Facstaff_Basic)
	select * from _DM_ADMIN

	/*
DELETE /login/service/v4/User/USERNAME:{Username} 

abrow27
adityar2
akinnebr
avinash8
dili5
dkelly6
dsbhatt2
grozdan2
gunalan2
ha30
hching
jvara2
kadiri2
kritis2
kyeazel
linz7
lpodila2
marianao
mengjie4
nkumari3
shyamv2
sj17
skoon
sujiny2
sukanya3
thhsieh2
zionh2

	*/
GO
