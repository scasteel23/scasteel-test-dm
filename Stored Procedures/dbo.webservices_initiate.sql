SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 3/14/2017 worked too!
--	SOP:
--		1) Run [webservices_initiate] to register screens to download
--			For example EXEC dbo.webservices_initiate @screen='PRESENT' --> register an individual screen to dwonload
--			EXEC dbo.webservices_initiate --> register all available screens
--		2) Run DMFEED : SSIS FSDB_Downloads_Parallel.dtsx module
--		3) See dbo._Test_03142017 SP overall !!
--
-- NS 6/15/2016: Worked!
-- NS 5/28/2016 (modified from Michael Paine's codes)
-- Michael's Notes:
-- This procedure should be called by someone with access to msdb.dbo.sp_start_job and access to the "ActivityInsight Process Requests" job, like UOFI\shadowmaker
-- nevermind: The caller of this procedure must be able to impersonate uofi\shadowmaker in order to start the SQL Server Agent Job: USE master; GRANT IMPERSONATE ON LOGIN::[UOFI\shadowmaker] TO [calling_user_here]
CREATE PROCEDURE [dbo].[webservices_initiate] 
	(
		@username VARCHAR(30)=NULL
		,@screen AS VARCHAR(30)=NULL 
	)

AS
	IF @username IS NOT NULL AND @screen IS NOT NULL RAISERROR('Only one of the parameters (@username or @screen) can be specified for dbo.webservices_initiate',18,1)
	
	print 'start webservices_initiate ' + @screen

	-- Enqueue the appropriate request
	IF @username IS NOT NULL BEGIN
		-- only run refreshes for users who haven't refreshed in the last 10 seconds
		DECLARE @recent INT = (SELECT TOP 1 id FROM dbo.webservices_requests WHERE url='/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:'+@username AND (processed IS NULL AND created < GETDATE() - '00:12:00' OR created > GETDATE()-'00:00:10'));
		IF @recent IS NOT NULL SELECT @recent;
		ELSE IF NOT EXISTS (SELECT TOP 1 1 FROM dbo._DM_USERS WHERE username=@username) SELECT NULL;
		ELSE BEGIN
			INSERT INTO dbo.webservices_requests(method,url)VALUES('GET','/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/USERNAME:'+@username);
			SELECT SCOPE_IDENTITY();
		END
	END ELSE BEGIN
		IF @screen = 'USERS'
			INSERT INTO dbo.webservices_requests(method,url)VALUES('GET','/login/service/v4/User/INDIVIDUAL-ACTIVITIES-Business');
		ELSE IF @screen IN ('PCI','CONTACT','PROFILE','ADMIN_PERM','ADMIN','PASTHIST','AWARDHONOR','EDUCATION','FACDEV', 'LICCERT','MEMBER'
								,'DSL','DEG_COMMITTEE','SCHTEACH','CURRICULUM','CONGRANT','INTELLCONT','PRESENT', 'RESPROG'
								,'SERVICE_ACADEMIC','SERVICE_COMMITTEE','SERVICE_PROFESSIONAL','SERVICE_PUBLIC','NCTEACH','MEDCONT')
								
			INSERT INTO dbo.webservices_requests(method,url)VALUES('GET','/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/'+@screen);
		--ELSE IF @screen IN ('DEG_COMMITTEE') BEGIN
		--	SELECT NULL
		--	-- INSERT INTO dbo.webservices_requests(method,url)VALUES('GET','/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/'+@screen+'?end=2014-01-01');
		--	-- INSERT INTO dbo.webservices_requests(method,url,dependsOn)VALUES('GET','/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/'+@screen+'?=2014-01-01',SCOPE_IDENTITY());
		--END
		ELSE IF @screen IS NULL
			-- 22 screens as of 9/19/2017
			INSERT INTO dbo.webservices_requests (method,url)
				SELECT 'GET'm,'/login/service/v4/User/INDIVIDUAL-ACTIVITIES-Business'u
				UNION SELECT 'GET'm,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/PCI'u

				UNION SELECT 'GET'm,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/CONTACT'u	
				UNION SELECT 'GET'm,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/PROFILE'u
				--UNION SELECT 'GET'm,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/ADMIN_PERM'u
				UNION SELECT 'GET'm,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/ADMIN'u				-- 1/2/2019

				UNION SELECT 'GET'm,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/PASTHIST'u
				UNION SELECT 'GET'm,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/AWARDHONOR'u							
				UNION SELECT 'GET'm,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/EDUCATION'u
				UNION SELECT 'GET'm,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/FACDEV'u				
				UNION SELECT 'GET'm,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/LICCERT'u
				UNION SELECT 'GET'm,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/MEMBER'u
			
				UNION SELECT 'GET'm,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/DSL'u				
				UNION SELECT 'GET'm,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/DEG_COMMITTEE'u	
				UNION SELECT 'GET'm,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/SCHTEACH'u

				UNION SELECT 'GET'm,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/CURRICULUM'u
				UNION SELECT 'GET'm,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/CONGRANT'u
				UNION SELECT 'GET'm,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/INTELLCONT'u
				UNION SELECT 'GET'm,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/PRESENT'u					
				UNION SELECT 'GET'm,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/RESPROG'u

				UNION SELECT 'GET'm,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/SERVICE_ACADEMIC'u
				UNION SELECT 'GET'm,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/SERVICE_COMMITTEE'u
				UNION SELECT 'GET'm,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/SERVICE_PROFESSIONAL'u													

				UNION SELECT 'GET'm,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/SERVICE_PUBLIC'u			-- 7/3/2018
				UNION SELECT 'GET'm,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/NCTEACH'u					-- 7/3/2018

				UNION SELECT 'GET'm,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/MEDCONT'u

				--NOT YET as of 9/19/2017, 7/3/2018, 1/18/2019
				--UNION SELECT 'GET'm,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/BANNER'u
				--UNION SELECT 'GET'm,'/login/service/v4/SchemaData/INDIVIDUAL-ACTIVITIES-Business/DSL'u										


		ELSE RAISERROR('@screen specified in dbo.webservices_initiate is not valid',18,1);

		SELECT SCOPE_IDENTITY();
	END
	
	-- Run the SSIS package using the "ActivityInsight Process Requests" SQL Server Agent Job

	
	--DECLARE @locked INTEGER;
	--EXEC @locked = sp_getapplock 'shadowmaker-initiate','Exclusive','Session',1;
	--IF @locked >= 0 BEGIN
	--	CREATE TABLE #temp (session_id int,job_id uniqueidentifier,job_name sysname,run_requested_date datetime null,run_requested_source sysname null,queued_date datetime,start_execution_date datetime,last_executed_step_id int,last_exectued_step_date datetime,stop_execution_date datetime,next_scheduled_run_date datetime,job_history_id int,message nvarchar(1024),run_status int,operator_id_emailed int,operator_id_netsent int,operator_id_paged int);
	--	INSERT INTO #temp EXEC('msdb.dbo.sp_help_jobactivity @job_name=''ActivityInsight Process Requests''') AS LOGIN='UOFI\nhadi'
	--	IF (SELECT stop_execution_date FROM #temp) IS NOT NULL OR (SELECT run_requested_date FROM #temp) IS NULL BEGIN
	--		EXEC('msdb.dbo.sp_start_job ''ActivityInsight Process Requests''') AS LOGIN='UOFI\nhadi'
	--	END
	--	DROP TABLE #temp;
	--	EXEC sp_releaseapplock 'shadowmaker-initiate','Session';
	--END


	/*
	
	 

	 NS 6/15/2016, 9/9/2016
	 EXEC dbo.webservices_initiate @screen='USERS'	
	 	
	 NS 6/21/2016, 9/9/2016
	 EXEC dbo.webservices_initiate @screen='PCI'

	 NS 9/9/2016
	 EXEC dbo.webservices_initiate @screen='AWARDHONOR'

	 NS 9/10/2016
	 EXEC dbo.webservices_initiate @screen='EDUCATION'
	 EXEC dbo.webservices_initiate @screen='FACDEV'
	 EXEC dbo.webservices_initiate @screen='MEMBER'
	 EXEC dbo.webservices_initiate @screen='LICCERT'
	 EXEC dbo.webservices_initiate @screen='CURRICULUM'

	  NS 10/19/2016
	 EXEC dbo.webservices_initiate @username='rashad'

	 NS 3/14/2017
	 EXEC dbo.webservices_initiate @screen='SERVICE_ACADEMIC'		-- 1:20 PM
	 EXEC dbo.webservices_initiate @screen='SERVICE_COMMITTEE'		-- 1.27 PM
	 EXEC dbo.webservices_initiate @screen='SERVICE_PROFESSIONAL'	-- 1.34 PM
	 EXEC dbo.webservices_initiate @screen='EDUCATION'				-- 2.08 PM 
	 EXEC dbo.webservices_initiate @screen='FACDEV'					-- 2.08 PM
	 EXEC dbo.webservices_initiate @screen='MEMBER'					-- 2.08 PM
	 EXEC dbo.webservices_initiate @screen='LICCERT'				-- 2.08 PM
	 EXEC dbo.webservices_initiate @screen='CURRICULUM'			-- 2.10 PM
	 EXEC dbo.webservices_initiate @screen='USERS'					-- 6.30 PM

	 NS 3/15/2017 
	 EXEC dbo.webservices_initiate @screen='AWARDHONOR'				-- 2:40 PM	
	 EXEC dbo.webservices_initiate @screen='PCI'					-- 2:40 PM	
	 EXEC dbo.webservices_initiate @screen='PRESENT'				-- 4:40 PM 
	 EXEC dbo.webservices_initiate @screen='CONGRANT'				-- 4:40 PM 
	 EXEC dbo.webservices_initiate @screen='INTELLCONT'				-- 4:40 PM

	 NS 4/26/2017 
	 EXEC dbo.webservices_initiate @screen='RESPROG
	 EXEC dbo.webservices_initiate @screen='SCHTEACH'
	 EXEC dbo.webservices_initiate @screen='DEG_COMMITTEE'

	 NS 9/19/2017
	 EXEC dbo.webservices_initiate @screen='PROFILE'

	 NS 10/2/2017
	 EXEC dbo.webservices_initiate @username='rashad'  -- PCI, bio, consulting, honor, pub, edu, facdev, member
														-- service ACO, service pro, svc committee
	 EXEC dbo.webservices_initiate @username='busfac1'
	 EXEC dbo.webservices_initiate @username='brownjr' -- PCI, bio, consulting, honor, pub, edu, facdev, member
														-- service ACO, service pro, svc committee, presentation
	 EXEC dbo.webservices_initiate @username='nhadi'	-- especially: Work in progress, deg committee, grants, CURRICULUM
														-- certifications

	 NS 3/14/2017 See more in [dbo].[_Test_2017]
	 NS 7/3/2018 See more in [dbo].[_Test_2018]

	 */



GO
