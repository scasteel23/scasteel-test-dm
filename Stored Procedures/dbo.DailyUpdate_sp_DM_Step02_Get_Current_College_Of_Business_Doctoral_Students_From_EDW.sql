SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

-- NS 9/27/2017: Start to run Step 1,2, and 3 side by side with FSDB version, 
--	new records at FSDB_Facstaff_ID starts from Facstaff_ID=102394
-- NS 4/11/2017: Revisited, ok, running time 24 seconds
-- NS 3/30/2017: Revisited. Created FSDB_EDW_Current_Employees table at DM_Shadow_Staging database functioning
--		as EDW_Current_Employees table in Faculty_Staff_Holder database
--
-- NS 3/28/2017: Moved related SP and tables (for downloadinging from EDW) to DM_Shadow_Staging database
--			These are on SP DailyUpdate_sp_DM_Step06_Update_UPLOAD_DM_BANNER_From_FSDB_EDW_Current_Employees
--				CREATE RECORDS in _UPLOAD_DM_PCI when there are new emps; changes in emp termination, names, UIN
--				CREATE RECORDS in _UPLOAD_DM_USERS when there are new emps; changes in emp termination, names, UIN
--	
-- NS 11/16/2016 
--		Rewrites from dbo.DailyUpdate_sp_Get_Current_College_Of_Business_Doctorals_From_EDW
--		Added DM_Upload_Done_Indicator column, new download will set DM_Upload_Done_Indicator=0
--			When DM upload is done set DM_Upload_Done_Indicator=1
-- STC 12/10/13
-- Exclude PRR students who have earned their degrees

-- NS 3/4/2009
-- Need to add JOB_CNTRCT_TYPE_DESC='Primary'  in order to be able to update  EDW fields in Facstaff_Basic 
--	in DailyUpdate_sp_Update_Non_Faculty_Facstaff_Basic_From_FSDB_EDW_Current_Employees SP

-- NS 2/29/2009
-- Use T_STUDENT_TERM instead of T_STUDENT_HIST

-- NS 2/22/2007:
-- Change field EMPEE_DEPT_CD to varchar(6) at FSDB_EDW_Current_Employees table

-- NS 10/18/2005
-- Get all current doctorals from Decision_Support into FSDB temporary table: FSDB_EDW_Current_Employees
-- Another process will move or update new doctorals
-- Each download will set old data to have new_download_indicator = 0, and new data to have new_download_indicator = 1
--	Create_Datetime is also set for each download

-- EDW_T_STUDENT_HIST
-- EDW_V_PERS_HIST_PRR_FULL_LTD
-- EDW_V_PERS_HIST_RTA_LTD_RSTR
-- EDW_T_STUDENT_AH_DEG_HIST






CREATE PROC [dbo].[DailyUpdate_sp_DM_Step02_Get_Current_College_Of_Business_Doctoral_Students_From_EDW]

AS
	
	BEGIN TRY

		DECLARE @jobdate datetime
		SET @jobdate = getdate()

		DECLARE @email_body varchar(4000), @from varchar(500),@to_admin varchar(500) ,@reply_to varchar(500)
			,@email_subject varchar(500), @Header varchar(500)

		SET @from = 'appsmonitor@business.illinois.edu'
		SET @to_admin = 'appsmonitor@business.illinois.edu, nhadi@illinois.edu'
		SET @reply_to = 'appsmonitor@business.illinois.edu'
		SET @email_subject = '[DM] Step-by-Step Activity step 2 as of ' + cast(getdate() as varchar) 

		SET @header = '<HTML><B>[DM] Step By step Process Activity as of ' + cast(getdate() as varchar) + '</B><BR><R>'
					+ 'DailyUpdate_sp_DM_Step02_Get_Current_College_Of_Business_Doctoral_Students_From_EDW' + '</B><BR><BR>'

		INSERT INTO Database_Maintenance.dbo.Download_Process_Monitor_Logs
					(Table_Name, Copy_Datetime, [Status]) 
		VALUES('FSDB_EDW_Current_Employees 2', @jobdate, 0)

		-- Mark obsolete all previous downloads
		UPDATE  DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees
		SET new_download_indicator=0
			,DM_Upload_Done_Indicator = 1
		WHERE EDW_Database in ('PRRDOC','RTADOC')

		-- Get the  current term and prior term
		DECLARE @term_cd varchar(6)
		DECLARE @prior_term_cd varchar(6)
		DECLARE @i integer


		SET @term_cd = dbo.DailyUpdate_fn_Get_Current_Term(getdate())

		SET @i = cast(LEFT(@term_cd,5) as INT) - 1
		SET @prior_term_cd = cast(@i as varchar(5)) + RIGHT(@term_cd,1)


		INSERT INTO DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees (
				EDW_PERS_ID,
				UIN,
				EDW_Database,
				PERS_FNAME,
				PERS_LNAME,
				PERS_MNAME,
				JOB_DETL_COLL_CD,
				JOB_CNTRCT_TYPE_DESC,
				EMPEE_DEPT_CD,
				EMPEE_DEPT_NAME,
				SEX_CD,
				BIRTH_DT,
				RACE_ETH_CD,
				NATION_CD,
				Network_id,
				Create_Datetime,
				new_download_indicator,
				DM_Upload_Done_Indicator
				)

		-- Get from PRR database all current doctorals
		-- This query basically is useful to get first year PHD students, where there has not been data in RTA database

		select distinct hist.EDW_PERS_ID, 
			prr.UIN,
			'PRRDOC',
			ISNULL(prr.PERS_FNAME, '') as PERS_FNAME,
			ISNULL(prr.PERS_LNAME, '') as PERS_LNAME,
			ISNULL(prr.PERS_MNAME, '') as PERS_MNAME,
			hist.COLL_CD,
			'Primary', --- NS 3/4/2009 Need to add this in order to be able to update  EDW fields in Facstaff_Basic in DailyUpdate_sp_Update_Non_Faculty_Facstaff_Basic_From_FSDB_EDW_Current_Employees SP
			hist.DEPT_CD, 
			hist.STUDENT_DEPT_NAME,
			prr.SEX_CD,
			prr.BIRTH_DT,
			Decision_Support.dbo.FSD_fn_Get_Ethnicity_From_PRR_EDW_PERS_ID(hist.edw_pers_id) as RACE_ETH_CD,
			Decision_Support.dbo.FSD_fn_Get_Citizenship_From_PRR_EDW_PERS_ID (hist.edw_pers_id, prr.PERS_CITZN_TYPE_CD) as NATION_CD,
			Decision_Support.dbo.FSD_fn_Get_NetID_From_PRR_EDW_PERS_ID  (hist.edw_pers_id) as Network_ID,
			getdate(),
			1,
			0

		from 	Decision_Support.dbo.EDW_T_STUDENT_TERM hist
			inner join Decision_Support.dbo.EDW_V_PERS_HIST_PRR_FULL_LTD prr
			on prr.edw_pers_id = hist.edw_pers_id 
				AND prr.PERS_CUR_INFO_IND = 'Y' 
				-- AND hist.STUDENT_CUR_INFO_IND = 'Y' 
		where 	hist.student_level_cd = '1G'
			and hist.student_curr_1_deg_cd = 'PHD'
			and hist.admin_coll_cd = 'ks' 
			and hist.coll_cd='km'
			and not ( STUDENT_ACAD_PGM_name like '%econ%' ) 
			and hist.term_cd > @prior_term_cd
			and hist.edw_pers_id not in
				( SELECT dh.EDW_PERS_ID 
					FROM Decision_Support.dbo.EDW_T_STUDENT_AH_DEG_HIST dh
					WHERE Deg_Status_CD = 'AW' AND GRAD_TERM_CD >= '120118'
							AND DEG_CD = 'PHD'
							AND COLL_CD ='KM'
							AND dh.EDW_PERS_ID = hist.EDW_PERS_ID
				)
		
	
		INSERT INTO DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees (
			EDW_PERS_ID,
			UIN,
			EDW_Database,
			PERS_FNAME,
			PERS_LNAME,
			PERS_MNAME,
			JOB_DETL_COLL_CD,
			JOB_CNTRCT_TYPE_DESC,
			EMPEE_DEPT_CD,
			EMPEE_DEPT_NAME,
			SEX_CD,
			BIRTH_DT,
			RACE_ETH_CD,
			NATION_CD,
			Network_id,
			Create_Datetime,
			new_download_indicator,
			DM_Upload_Done_Indicator
			)

		-- Get from RTA database all current doctorals that has not been awarded PHD degree
		-- This query basically is useful to get PHD students that do not register due to 0 credits but they do not want to do defense on those semesters

		select distinct rta.EDW_PERS_ID, 
			rta.UIN,
			'RTADOC',
			ISNULL(rta.PERS_FNAME, '') as PERS_FNAME,
			ISNULL(rta.PERS_LNAME,'') as PERS_LNAME,
			ISNULL(rta.PERS_MNAME,'') as PERS_MNAME,
				deg.COLL_CD,
			'Primary',
			deg.DEPT_CD,
			deg.DEG_DEPT_NAME,
			rta.SEX_CD,
			rta.BIRTH_DT,
			Decision_Support.dbo.FSD_fn_Get_Ethnicity_From_RTA_EDW_PERS_ID(rta.edw_pers_id) as RACE_ETH_CD,
			Decision_Support.dbo.FSD_fn_Get_Citizenship_From_PRR_EDW_PERS_ID (rta.edw_pers_id, rta.PERS_CITZN_TYPE_GROUP) as NATION_CD,
			Decision_Support.dbo.FSD_fn_Get_NetID_From_RTA_EDW_PERS_ID  (rta.edw_pers_id) as Network_ID,
				getdate(),
				1,
				0	
		FROM 	Decision_Support.dbo.EDW_V_PERS_HIST_RTA_LTD_RSTR rta 
			INNER JOIN Decision_Support.dbo.EDW_T_STUDENT_AH_DEG_HIST deg
			ON rta.edw_pers_id = deg.edw_pers_id  and 
				rta.pers_cur_info_ind = 'y'
		WHERE 	deg.deg_level_cd = '1G'
			and deg.deg_cd = 'PHD'
			and deg.admin_coll_cd = 'ks' 
			and deg.coll_cd='km'
			--and deg.deg_status_cd = 'so'  -- this 'SO' code is apparently no longer available this year
			and deg.deg_status_cd not in ('rs','aw')   -- not awarded, but rescinded
			and not ( deg.deg_ACAD_PGM_name like '%econ%' )
			and rta.edw_pers_id not in (
				select rta.edw_pers_id		
				FROM Decision_Support.dbo.edw_v_pers_hist_rta_dir rta 
				INNER JOIN Decision_Support.dbo.edw_t_student_ah_deg_hist deg
					ON rta.edw_pers_id = deg.edw_pers_id  and 
				rta.pers_cur_info_ind = 'y'
				WHERE deg.deg_level_cd = '1G'
					and deg.deg_cd = 'PHD'
					and deg.admin_coll_cd = 'ks' 
					and deg.coll_cd='km'
					and deg.deg_status_cd = 'aw' 
					and not ( deg.deg_ACAD_PGM_name like '%econ%' )
			)
			and rta.edw_pers_id NOT IN
				( SELECT EDW_PERS_ID
					FROM DM_Shadow_Staging.dbo.FSDB_EDW_Current_Employees 
					WHERE New_Download_Indicator = 1
				)

		UPDATE	Database_Maintenance.dbo.Download_Process_Monitor_Logs
		SET		Status = 2
		WHERE	Table_Name = 'FSDB_EDW_Current_Employees 2'
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
GO
