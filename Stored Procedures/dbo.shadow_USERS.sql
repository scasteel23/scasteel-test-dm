SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 8/11/2017 : revisited, fixed insertion ini DM_Shadow_Production.dbo._DM_USERS table, worked
-- NS 9/9/2016: revisited, worked.
-- NS 6/21/2016: Worked! Need to add Facstaff_ID, UIN, EDW_PERS_ID
-- NS 5/28/2016: Modified from Michael Painter's codes)
--				 Get XML data from the downloader (SSIS package) insert into _DM_USERS table

/*
	Manual run to shadow individual USERS screen
	EXEC dbo.webservices_initiate @screen='USERS'
	EXEC dbo.webservices_run_DTSX
*/
CREATE PROCEDURE [dbo].[shadow_USERS] (@webservices_requests_id INT, @xml XML,@resync BIT=NULL) AS 


/*
	Manual run to shadow individual screen
	EXEC dbo.webservices_initiate @screen='USERS'
	DECLARE @Result varchar(500)
	EXEC dbo.webservices2_run @Result = @Result OUTPUT
*/
	-- Get all logins from this URL
	-- https://beta.digitalmeasures.com/login/service/v4/User/INDIVIDUAL-ACTIVITIES-Business
	-- https://www.digitalmeasures.com/login/service/v4/User/INDIVIDUAL-ACTIVITIES-Business

	WITH XMLNAMESPACES('http://www.w3.org/1999/xlink' AS xlink,
		'http://www.digitalmeasures.com/schema/user-metadata' AS dmu)

	--WITH XMLNAMESPACES('http://www.w3.org/1999/xlink' AS xlink,
	--	'http://beta.digitalmeasures.com/schema/user-metadata' AS dmu)

	SELECT ISNULL(U.value('@username','varchar(50)'),'') username,
		U.value('@dmu:userId','bigint') userid,
		ISNULL(U.value('@UIN','bigint'),'') uin,
		ISNULL(U.value('@FacstaffID','int'),'') facstaffid,
		ISNULL(U.value('@EDWPERSID','bigint'),'') edwpersid,
		CASE WHEN U.value('@enabled','varchar(5)')='false' THEN 0 ELSE 1 END Enabled_Indicator,
		ISNULL(U.value('(FirstName/text())[1]','varchar(100)'),'')First_Name,
		ISNULL(U.value('(MiddleName/text())[1]','varchar(100)'),'')Middle_Name,
		ISNULL(U.value('(LastName/text())[1]','varchar(100)'),'')Last_Name,
		ISNULL(U.value('(Email/text())[1]','varchar(100)'),'')Email_Address
	INTO #Incoming_DM_USERS
	FROM @xml.nodes('/Users/User')Users(U)
	IF (SELECT COUNT(*) FROM #Incoming_DM_USERS)<=10 
		BEGIN
			UPDATE dbo.webservices_requests SET SP_Error='USERS has no data' WHERE [ID]=@webservices_requests_id			
			RAISERROR('USERS has no Data',18,1)
		END
	ELSE 
		BEGIN -- start, has some data
			DECLARE @Error_Message varchar(1000);
			DECLARE @locked INTEGER;
			EXEC @locked = sp_getapplock 'shadowmaker-USERS','Exclusive','Session',20000; -- 20 second wait
			IF @locked < 0 

				BEGIN
						PRINT 'shadowmaker-USERS Import Locked'
						UPDATE dbo.webservices_requests SET SP_Error='shadowmaker-USERS Import Locked' WHERE [ID]=@webservices_requests_id			
				END
			
			ELSE 
			
				BEGIN

				-- Create table to hold changes
					SELECT TOP 0 CAST('A' AS CHAR(1))action,
						--userid,
						COALESCE(userid,NULL)userid,
						COALESCE(username,NULL)username,
						COALESCE(uin,NULL)uin,
						COALESCE(facstaffid,NULL)facstaffid,
						COALESCE(edwpersid,NULL)edwpersid,
						COALESCE(First_Name,NULL)First_Name,
						COALESCE(Middle_Name,NULL)Middle_Name,
						COALESCE(Last_Name,NULL)Last_Name,
						COALESCE(Email_Address,NULL)Email_Address,
						COALESCE(Enabled_Indicator,NULL)Enabled_Indicator
					INTO #current_USERS 
					FROM dbo._DM_USERS inserted;

				TryAgain:
				-- The changes are assessed on Staging.  So Production & Staging tables need to start out identical.
				-- If @resync, then we pull the Production table to Staging to make sure they are identical before importing.
					IF @resync=1 
						MERGE INTO dbo._DM_USERS a USING DM_Shadow_Production.dbo._DM_USERS b ON (a.username=b.username)
						WHEN MATCHED AND (
							a.username<>b.username
							OR CASE WHEN a.uin IS NULL THEN 1 ELSE 0 END<>CASE WHEN b.uin IS NULL THEN 1 ELSE 0 END OR a.uin<>b.uin
							OR a.Enabled_Indicator<>b.Enabled_Indicator
							OR a.First_Name<>b.First_Name
							OR a.Middle_Name<>b.Middle_Name
							OR a.Last_Name<>b.Last_Name
							OR a.Email_Address<>b.Email_Address
							OR a.edwpersid <> b.edwpersid
							OR a.facstaffid <> b.facstaffid
						) THEN UPDATE SET
							username=b.username
							,userID=b.userID
							,uin=b.uin
							,facstaffid=b.facstaffid
							,edwpersid=b.edwpersid
							,Enabled_Indicator=b.Enabled_Indicator
							,First_Name=b.First_Name
							,Middle_Name=b.Middle_Name
							,Last_Name=b.Last_Name
							,Email_Address=b.Email_Address
						WHEN NOT MATCHED BY TARGET THEN
							INSERT (username,userid,uin,facstaffid,edwpersid,First_Name,Middle_Name,Last_Name,Email_Address,Enabled_Indicator)
							VALUES (username,userid,uin,facstaffid,edwpersid,First_Name,Middle_Name,Last_Name,Email_Address,Enabled_Indicator)
						WHEN NOT MATCHED BY SOURCE THEN DELETE;
			
					-- Merge and output changes
					MERGE INTO dbo._DM_USERS a USING #Incoming_DM_USERS b ON (a.username=b.username)
					WHEN MATCHED AND (
						a.username<>b.username
						OR CASE WHEN a.uin IS NULL THEN 1 ELSE 0 END<>CASE WHEN b.uin IS NULL THEN 1 ELSE 0 END 
						OR a.uin<>b.uin
						OR a.Enabled_Indicator<>b.Enabled_Indicator
						OR a.First_Name<>b.First_Name
						OR a.Middle_Name<>b.Middle_Name
						OR a.Last_Name<>b.Last_Name
						OR a.Email_Address<>b.Email_Address
						OR CASE WHEN a.edwpersid IS NULL THEN 1 ELSE 0 END<>CASE WHEN b.edwpersid IS NULL THEN 1 ELSE 0 END 
						OR a.edwpersid <> b.edwpersid
						OR CASE WHEN a.facstaffid IS NULL THEN 1 ELSE 0 END<>CASE WHEN b.facstaffid IS NULL THEN 1 ELSE 0 END 
						OR a.facstaffid <> b.facstaffid
					) THEN UPDATE SET
						username=b.username
						,userID=b.userID
						,uin=b.uin
						,facstaffid=b.facstaffid
						,edwpersid=b.edwpersid
						,Enabled_Indicator=b.Enabled_Indicator
						--,Service_Account_Indicator=b.Service_Account_Indicator
						,First_Name=b.First_Name
						,Middle_Name=b.Middle_Name
						,Last_Name=b.Last_Name
						,Email_Address=b.Email_Address
					WHEN NOT MATCHED BY TARGET THEN
						INSERT (username,userid,uin,facstaffid,edwpersid,First_Name,Middle_Name,Last_Name,Email_Address,Enabled_Indicator)
						VALUES (username,userid,uin,facstaffid,edwpersid,First_Name,Middle_Name,Last_Name,Email_Address,Enabled_Indicator)
					WHEN NOT MATCHED BY SOURCE THEN DELETE
					OUTPUT LEFT($action,1)action
							,ISNULL(inserted.userid,deleted.userid)userid
							,inserted.username,inserted.uin
							,inserted.facstaffid,inserted.edwpersid,inserted.First_Name,inserted.Middle_Name,inserted.Last_Name
							,inserted.Email_Address,inserted.Enabled_Indicator
					INTO #current_USERS;

					--select * from #current_USERS;
			
					-- Push to Production; if there is an error, try a full sync
					BEGIN TRY
						-- NS 5/20/2017 commented out
						--INSERT INTO DM_Shadow_Production.dbo._DM_USERS
						--		(username,userid,uin,facstaffid,edwpersid,First_Name,Middle_Name,Last_Name,Email_Address,Enabled_Indicator)
						--SELECT username,userid,uin,facstaffid,edwpersid,First_Name,Middle_Name,Last_Name,Email_Address,Enabled_Indicator
						--FROM #current_USERS 
						--WHERE action='I'
						--		AND username NOT IN (SELECT username FROM DM_Shadow_Production.dbo._DM_USERS)
				
						--UPDATE DM_Shadow_Production.dbo._DM_USERS SET 
						--	username=b.username
						--	,userID=b.userID
						--	,uin=b.uin
						--	,facstaffid=b.facstaffid
						--	,edwpersid=b.edwpersid
						--	,Enabled_Indicator=b.Enabled_Indicator
						--	,First_Name=b.First_Name
						--	,Middle_Name=b.Middle_Name
						--	,Last_Name=b.Last_Name
						--	,Email_Address=b.Email_Address
						--FROM DM_Shadow_Staging.dbo._DM_USERS a
						--JOIN #current_USERS b ON a.username=b.username
						--WHERE b.action='U';

						-- NS 8/11/2017 replacement codes
						MERGE INTO DM_Shadow_Production.dbo._DM_USERS a USING dbo._DM_USERS b ON (a.username=b.username)
						WHEN MATCHED AND (
							a.username<>b.username
							OR CASE WHEN a.uin IS NULL THEN 1 ELSE 0 END<>CASE WHEN b.uin IS NULL THEN 1 ELSE 0 END OR a.uin<>b.uin
							OR a.Enabled_Indicator<>b.Enabled_Indicator
							OR a.First_Name<>b.First_Name
							OR a.Middle_Name<>b.Middle_Name
							OR a.Last_Name<>b.Last_Name
							OR a.Email_Address<>b.Email_Address
							OR a.edwpersid <> b.edwpersid
							OR a.facstaffid <> b.facstaffid
						) THEN UPDATE SET
							username=b.username
							,userID=b.userID
							,uin=b.uin
							,facstaffid=b.facstaffid
							,edwpersid=b.edwpersid
							,Enabled_Indicator=b.Enabled_Indicator
							--,Service_Account_Indicator=b.Service_Account_Indicator
							,First_Name=b.First_Name
							,Middle_Name=b.Middle_Name
							,Last_Name=b.Last_Name
							,Email_Address=b.Email_Address
						WHEN NOT MATCHED BY TARGET THEN
							INSERT (username,userid,uin,facstaffid,edwpersid,First_Name,Middle_Name,Last_Name,Email_Address,Enabled_Indicator)
							VALUES (username,userid,uin,facstaffid,edwpersid,First_Name,Middle_Name,Last_Name,Email_Address,Enabled_Indicator)
						WHEN NOT MATCHED BY SOURCE THEN DELETE;

			
						DELETE FROM DM_Shadow_Staging.dbo._DM_USERS WHERE username IN (SELECT username FROM #current_USERS WHERE action='D');
						DELETE FROM DM_Shadow_Production.dbo._DM_USERS WHERE username IN (SELECT username FROM #current_USERS WHERE action='D');

					END TRY
					BEGIN CATCH

						SELECT @Error_Message = ERROR_MESSAGE()  
						RAISERROR(@Error_Message,18,0)

						IF @resync=1 RAISERROR('Fail with @Resync=1',18,0)
						ELSE BEGIN
							SET @resync=1;
							DELETE FROM #current_USERS;
							GOTO TryAgain;
						END
					END CATCH

					UPDATE DM_Shadow_Staging.dbo._DM_USERS SET Download_Datetime=getdate()
					UPDATE DM_Shadow_Production.dbo._DM_USERS SET Download_Datetime=getdate()

					DROP TABLE #current_USERS
					EXEC sp_releaseapplock 'shadowmaker-USERS','Session';
					
					UPDATE DM_Shadow_Staging.dbo._DM_USERS
					SET Service_Account_Indicator=0
					WHERE Service_Account_Indicator IS NULL

					UPDATE DM_Shadow_Production.dbo._DM_USERS
					SET Service_Account_Indicator=0
					WHERE Service_Account_Indicator IS NULL

				
				END

		END -- end, has some data
	DROP TABLE #Incoming_DM_USERS;




GO
