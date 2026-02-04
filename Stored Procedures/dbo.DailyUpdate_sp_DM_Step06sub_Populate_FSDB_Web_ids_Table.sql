SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 11/3/2017 Added new records to FSDB_UPLOADS_IDS
-- NS 3/30/2017: Revisited. Created _UPLOAD_EDW_Current_Employees table at DM_Shadow_Staging database functioning
--		as EDW_Current_Employees table in Facukty_Staff_Holder database
--		Renamed _UPLOADED_DM_USERS, _UPLOADED_DM_PCI,  _UPLOADED_DM_BANNER, and WEB_IDS to
--		_UPLOAD_DM_USERS, _UPLOAD_DM_PCI, _UPLOAD_DM_BANNER and _UPLOAD_WEB_IDS  tables
--
-- NS 3/28/2017: Moved related SP and tables (for downloadinging from EDW) to DM_Shadow_Staging database
-- NS 11/29/2016
--		Copy from [DailyUpdate_sp_Populate_Facstaff_Web_IDs_Table]
--
-- NS 9/3/2014
--	Rewritten for daily process, add new emps, and update
--	More: 
--		(0) Send automatic email to new employee about the website
--		(1) Update first name and last name. If it happens then trigger emails
--		(2) Archive inactive users, remove inactive user, trigger emails
--		(3) Trigger emails when found duplicates due to new employee(s) being added

-- NS 6/30/2014: Experimenting different ID to access College Profile
--	There may be some duplicates among those 5 Full_Name_# fields
--  Take a look the way we look up the key (fullname_1, fullname_2, network_id, etc.) 
--		in Web_FSD_sp_Get_Facstaff_ID_By_Some_ID SP
--
-- NS 8/6/2014: 
--	Reduced the values in Attribute field to two values of "Network_ID" and "Fullname_ID"
--  Added a new column "sequence"
--
CREATE PROC [dbo].[DailyUpdate_sp_DM_Step06sub_Populate_FSDB_Web_ids_Table]
AS
	

-- DEBUG to reset 
-- truncate table dbo._UPLOAD_web_ids
-- truncate table FSDB_Web_IDs
	BEGIN TRY
		SET NOCOUNT ON
	 
	 	DECLARE @jobdate datetime
		SET @jobdate = getdate()

		DECLARE @email_body varchar(4000), @from varchar(500),@to_admin varchar(500) ,@reply_to varchar(500)
			,@email_subject varchar(500), @Header varchar(500)

		SET @from = 'appsmonitor@business.illinois.edu'
		SET @to_admin = 'appsmonitor@business.illinois.edu, nhadi@illinois.edu'
		SET @reply_to = 'appsmonitor@business.illinois.edu'
		SET @email_subject = '[DM] Step-by-Step Activity step 6A as of ' + cast(getdate() as varchar) 

		SET @header = '<HTML><B>[DM] Step By step Process Activity as of ' + cast(getdate() as varchar) + '</B><BR><R>'
					+ 'DailyUpdate_sp_DM_Step06sub_Populate_FSDB_Web_ids_Table' + '</B><BR><BR>'

		INSERT INTO Database_Maintenance.dbo.Download_Process_Monitor_Logs
					(Table_Name, Copy_Datetime, [Status]) 
		VALUES('FSDB_EDW_Current_Employees 6A', @jobdate, 0)

		CREATE TABLE #new_web_ids (
			[USERNAME] [varchar](60) NULL,
			[FACSTAFFID] [int] NULL,
			[Attribute] [varchar](60) NOT NULL,
			[Sequence] [int] NOT NULL,
			[Value] [varchar](120) NULL,
			[Preferred_Attribute_Indicator] [bit] NULL,
			[Create_Datetime] [datetime] NULL,
		) ON [PRIMARY] 


		-- >>>>> Set pair of USERNAME and First_Name
	
		insert into #new_web_ids (
			   USERNAME
			  ,FACSTAFFID
			  ,Attribute
			  ,sequence
			  ,Preferred_Attribute_Indicator
			  ,Value 
			  ,Create_Datetime     
		)
	
		SELECT DISTINCT USERNAME, FACSTAFFID, 'First_Name', 1, 0
				 , case when PERS_PREFERRED_FNAME is not null and LTRIM(RTRIM(PERS_PREFERRED_FNAME)) <> '' then LTRIM(RTRIM(PERS_PREFERRED_FNAME)) 
				 else ISNULL(PERS_FNAME,'') end as First_Name
				 , getdate()
		FROM dbo._UPLOAD_DM_BANNER
		WHERE Record_Status='NEW' 
				AND USERNAME NOT IN (SELECT USERNAME FROM dbo._UPLOAD_Web_Ids)
				AND USERNAME IS NOT NULL
		ORDER BY USERNAME ASC

		--DEBUG to reset FSDB_Web_ids
		--SELECT DISTINCT USERNAME, FACSTAFFID, 'First_Name', 1, 0
		--		 , case when PFNAME is not null and LTRIM(RTRIM(PFNAME)) <> '' then LTRIM(RTRIM(PFNAME)) 
		--		 else ISNULL(FNAME,'') end as First_Name
		--		 , getdate()
		--FROM dbo._DM_PCI
		--WHERE Facstaffid <> 0
		--ORDER BY USERNAME ASC



		-- >>>>> Set pair of USERNAME and Network_ID
		insert into #new_web_ids (
			   USERNAME
			  ,FACSTAFFID
			  ,Attribute
			  ,sequence
			  ,Preferred_Attribute_Indicator
			  ,Value 		  
			  ,Create_Datetime     
		)
		SELECT DISTINCT FB.USERNAME, FB.FACSTAFFID, 'Network_ID', 1, 0, FB.USERNAME		, getdate()
		FROM dbo._UPLOAD_DM_BANNER FB
					INNER JOIN #new_web_ids FW
					ON FB.USERNAME = FW.USERNAME
						AND FW.Attribute = 'First_Name'

		-- DEBUG TO RESET FSDB_Web_ids table
		--SELECT DISTINCT FB.USERNAME, FB.FACSTAFFID, 'Network_ID', 1, 0, FB.USERNAME		, getdate()
		--FROM dbo._DM_PCI FB
		--			INNER JOIN #new_web_ids FW
		--			ON FB.USERNAME = FW.USERNAME
		--				AND FW.Attribute = 'First_Name'

		-- >>>>> DEBUG TEST
		/*
		INSERT INTO #new_web_ids (Facstaff_ID, Attribute, sequence ,Preferred_Attribute_Indicator ,Value, Create_Datetime)
		VALUES (1111, 'Fullname_ID', 1, 1, 'nursalim-hadi', getdate())
		INSERT INTO #new_web_ids (Facstaff_ID, Attribute, sequence ,Preferred_Attribute_Indicator ,Value, Create_Datetime)
		VALUES (1112, 'Fullname_ID', 1, 1, 'nursalim-hadi', getdate())
		INSERT INTO #new_web_ids (Facstaff_ID, Attribute, sequence ,Preferred_Attribute_Indicator ,Value, Create_Datetime)
		VALUES (1113, 'Fullname_ID', 1, 1, 'nursalim-hadi', getdate())
		*/

		-- >>>>> Last_Name
		insert into #new_web_ids (
			   USERNAME
			  ,FACSTAFFID
			  ,Attribute
			  ,sequence
			  ,Preferred_Attribute_Indicator
			  ,Value 
			  ,Create_Datetime     
		)	
		SELECT DISTINCT FB.USERNAME, FB.FACSTAFFID, 'Last_Name'	,1, 0
			,case when FB.PERS_LNAME is not null and LTRIM(RTRIM(FB.PERS_LNAME)) <> '' then LTRIM(RTRIM(FB.PERS_LNAME))
				 else '' end as Last_Name
			,getdate()
		FROM dbo._UPLOAD_DM_BANNER FB
					INNER JOIN #new_web_ids FW
					ON FB.USERNAME = FW.USERNAME
						AND FW.Attribute = 'First_Name'

		-- DEBUG TO RESET FSDB_Web_ids table
		--SELECT DISTINCT FB.USERNAME, FB.FACSTAFFID, 'Last_Name', 1, 0
		--		 , case when PLNAME is not null and LTRIM(RTRIM(PLNAME)) <> '' then LTRIM(RTRIM(PLNAME)) 
		--		 else ISNULL(LNAME,'') end as First_Name
		--		 , getdate()
		--FROM dbo._DM_PCI FB
		--			INNER JOIN #new_web_ids FW
		--			ON FB.USERNAME = FW.USERNAME
		--				AND FW.Attribute = 'First_Name'

		-- >>>> Fullname version 1: Brian-Whitlock
		insert into #new_web_ids (
			   USERNAME
			  ,FACSTAFFID
			  ,Attribute
			  ,sequence
			  ,Preferred_Attribute_Indicator
			  ,Value 
			  ,Create_Datetime     
		)
		SELECT DISTINCT fw1.USERNAME, fw1.FACSTAFFID, 'Fullname_ID', 1, 1
			, replace(replace((LTRIM(RTRIM(fw1.value)) + '-' + LTRIM(RTRIM(fw2.value))),' ', '-'), '.','-')
			, getdate()
		FROM #new_web_ids fw1
				INNER JOIN #new_web_ids fw2
				ON fw1.USERNAME = fw2.USERNAME
					AND fw1.attribute='First_Name'
					AND fw2.Attribute = 'Last_Name'
	
		-- Cleaning up all unnecessary characters

		-- drop apostrophe (')
		UPDATE #new_web_ids
		SET value = REPLACE(value,'''','')
		WHERE attribute = 'Fullname_ID' 

		-- Replace duplicate '(' with '-'
		UPDATE #new_web_ids
		SET value = replace (value,'(','-')
		WHERE attribute = 'Fullname_ID' 

		-- Replace duplicate ')' with '-'
		UPDATE #new_web_ids
		SET value = replace (value,')','-')
		WHERE attribute = 'Fullname_ID' 

		-- Replace  '.' with '-'
		UPDATE #new_web_ids
		SET value = replace (value,'.','-')
		WHERE attribute = 'Fullname_ID' 

		-- Replace duplicate '--' with '-'
		UPDATE #new_web_ids
		SET value = replace (value,'--','-')
		WHERE attribute = 'Fullname_ID' 

		-- Replace duplicate '..' with '.'
		UPDATE #new_web_ids
		SET value = replace (value,'..','-')
		WHERE attribute = 'Fullname_ID' 

		-- Remove ending '-'
		UPDATE #new_web_ids
		SET value = LEFT(value,len(value)-1)
		WHERE attribute = 'Fullname_ID' 
				and substring(value,len(value),1) = '-'

		-- Relace all accent charcters with nearest alphabet
		UPDATE #new_web_ids
		SET value = value Collate SQL_Latin1_General_CP1253_CI_AI
		WHERE attribute = 'Fullname_ID' 



			
		-- Set preferred profile-id
		UPDATE #new_web_ids
		SET Preferred_Attribute_Indicator=1
		WHERE attribute = 'Fullname_ID' 


		-- Find whether fullname in #new_web_ids table are all unique wrt to fullnames in facstaff_web_ids table
		-- Fullname(s) in #new_web_ids that are found to be duplicates must be replaced by additional suffix

		DECLARE @str_fullname1 varchar(120), @str_fullname2 varchar(120), @seq integer, @USERNAME varchar(60)
	
		DECLARE fullname  CURSOR READ_ONLY FOR
			SELECT value, USERNAME
			FROM #new_web_ids
			WHERE attribute='Fullname_ID'
	
		OPEN fullname		
		FETCH fullname INTO @str_fullname1, @USERNAME
		WHILE @@FETCH_STATUS = 0
	
		BEGIN
	-- DEBUG
	-- print @str_fullname1
	-- print @username

			SET @str_fullname2 = @str_fullname1
			SET @seq = 2
			WHILE (SELECT count(*) FROM dbo._UPLOAD_Web_IDs WHERE Attribute='Fullname_ID' AND value=@str_fullname2) >= 1 OR
					(SELECT count(*) FROM #new_web_ids WHERE Attribute='Fullname_ID' AND value=@str_fullname2) > 1
				BEGIN
					print 'duplicate'
					SET @str_fullname2 = @str_fullname1 + cast(@seq as varchar)	
					SET @seq = @seq + 1
				END
		
			-- A fullname in #new_web_ids table found a duplicate in web_ids table
			-- The duplicate fullname in #new_web_ids is replaced by a new name which si the original anem + suffix

			IF @str_fullname2 <> @str_fullname1
				UPDATE #new_web_ids
				SET value = @str_fullname2
				WHERE USERNAME = @USERNAME 
						AND Attribute = 'Fullname_ID'

			FETCH fullname INTO @str_fullname1, @USERNAME
		END
		CLOSE fullname
		DEALLOCATE fullname

	-- DEBUG
	-- SELECT * FROM #new_web_ids where username = 'bigdog'
	-- SELECT * FROM _UPLOAD_WEB_IDS where username = 'bigdog'

		SET NOCOUNT OFF

		INSERT INTO	dbo._UPLOAD_Web_ids
			  (USERNAME
			  ,FACSTAFFID
			  ,Attribute
			  ,sequence
			  ,Value 
			  ,Preferred_Attribute_Indicator
			  ,Create_Datetime )		  
		SELECT USERNAME
			  ,FACSTAFFID
			  ,Attribute
			  ,sequence
			  ,Value 
			  ,Preferred_Attribute_Indicator
			  ,Create_Datetime     
		FROM #new_web_ids 

		
		INSERT INTO	dbo.FSDB_Web_ids
			  (USERNAME
			  ,FACSTAFFID
			  ,Attribute
			  ,sequence
			  ,Value 
			  ,Preferred_Attribute_Indicator
			  ,Create_Datetime )	
		SELECT USERNAME
			  ,FACSTAFFID
			  ,Attribute
			  ,sequence
			  ,Value 
			  ,Preferred_Attribute_Indicator
			  ,Create_Datetime    
		FROM 	dbo._UPLOAD_Web_ids  
		WHERE USERNAME NOT IN

		(
			SELECT USERNAME FROM dbo.FSDB_Web_ids
		)

		UPDATE	Database_Maintenance.dbo.Download_Process_Monitor_Logs
		SET		Status = 2
		WHERE	Table_Name = 'FSDB_EDW_Current_Employees 6A'
			AND	Copy_Datetime = @jobdate

		SET @email_subject =  @email_subject + ' - Success'
		SET @email_body = @header + 'Success<BR><BR>'
		EXEC dbo.DailyUpdate_sp_Send_Email @from,@to_admin,@reply_to,@email_subject, @email_body

	END TRY

	BEGIN CATCH
			SET @email_subject =  @email_subject + ' - Error'
			SET @email_body = @header + ERROR_Message() + '<BR><BR>'
			EXEC dbo.DailyUpdate_sp_Send_Email @from,@to_admin,@reply_to,@email_subject, @email_body
	END CATCH

	-- DEBUG
	-- select * from #new_web_ids order by attribute, value

	--select attribute, value, count(*)
	--		from #new_web_ids FW
	--			INNER JOIN dbo.Facstaff_Basic FB
	--			ON FW.facstaff_ID = FB.facstaff_ID			
	--			where attribute = 'fullname_id'
	--			and bus_person_indicator =1 
	--		group by attribute, value
	--		having count(*) > 1
	 
/*

		SELECT *
		from dbo.web_ids

		--FIND duplicates in a certain group

			-- no duplicates in faculty (ideally could sustain for a long time) for all IDs (fullname_id, fullname_id2, et al)
			select attribute, value, count(*)
			from Facstaff_Web_IDs FW
				INNER JOIN dbo.Facstaff_Basic FB
				ON FW.facstaff_ID = FB.facstaff_ID
			where attribute <> 'first_name' and attribute <> 'last_name' and attribute <> 'network_id'
				and bus_person_indicator =1 and faculty_staff_indicator =1
			group by attribute, value
			having count(*) > 1

			-- no duplicates in doctorals (ideally could sustain for a long time)
			select attribute, value, count(*)
			from Facstaff_Web_IDs FW
				INNER JOIN dbo.Facstaff_Basic FB
				ON FW.facstaff_ID = FB.facstaff_ID
			where attribute <> 'first_name' and attribute <> 'last_name' and attribute <> 'network_id'
				and bus_person_indicator =1 and doctoral_flag =1
			group by attribute, value
			having count(*) > 1

			-- no duplicates: faculty, AP, and Civil Services (ideally could sustain for a long time)
			select attribute, value, count(*)
			from Facstaff_Web_IDs FW
				INNER JOIN dbo.Facstaff_Basic FB
				ON FW.facstaff_ID = FB.facstaff_ID
			where attribute <> 'first_name' and attribute <> 'last_name' and attribute <> 'network_id'
				and bus_person_indicator =1 and empee_group_cd in ('A', 'B', 'C')
			group by attribute, value
			having count(*) > 1

			-- a lot of duplicates in the entire Business academics (obviously)
			select attribute, value, count(*)
			from Facstaff_Web_IDs FW
				INNER JOIN dbo.Facstaff_Basic FB
				ON FW.facstaff_ID = FB.facstaff_ID
			where attribute <> 'first_name' and attribute <> 'last_name' and attribute <> 'network_id'
				and bus_person_indicator =1
			group by attribute, value
			having count(*) > 1

*/

	--INSERT INTO	dbo.facstaff_web_ids_archived
	--	  (Facstaff_ID
	--	  ,Attribute
	--	  ,sequence
	--	  ,Value 
	--	  ,Create_Datetime )
		  
	--SELECT Facstaff_ID
	--	  ,Attribute
	--	  ,sequence
	--	  ,Value 
	--	  ,Create_Datetime     
	--FROM dbo.facstaff_web_ids 
	--
	--update dbo.facstaff_web_ids_archived
	--set delete_datetime = getdate()
	--
GO
