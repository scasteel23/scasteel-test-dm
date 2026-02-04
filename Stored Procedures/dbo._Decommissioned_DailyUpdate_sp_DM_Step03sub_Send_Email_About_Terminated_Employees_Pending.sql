SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- NS 5/11/2016 - copied from and adjusted table names
--				from Facstaff_Basic to FSDB_Facstaff_Basic
--				from EDW_Current_Employees to FSDB_EDW_Current_Employees
-- STC 9/15/15 - Create new SP to send email during automatic delay period for terminations,
--				 to help distinguish from message send when # of terminations exceeds the limit

-- NS 6/19/2013 - Created from [DailyUpdate_sp_Send_Email_About_Terminated_Employees]
--				  The purpose is to know who are those > x employees that are supposed to terminate
--				  but not terminated since the threshold x = 30
-- STC 5/24/10 - Modified to send in unlimited groups of 50 (instead of 4 groups of 60)
-- STC 6/28/16 - Do not exclude staff retirees from termination emails

-- NS - The reason for sending multiple emails is due to the size limitation. Each email body
-- is limited to only 8000 characters and usually the length of the actual email body is 
-- really long (for.e.g.if there are more then 50 terminated employees at a time). With 
-- multiple email bodies we can now send details of just 50 terminated employees at a time.

CREATE Procedure [dbo].[_Decommissioned_DailyUpdate_sp_DM_Step03sub_Send_Email_About_Terminated_Employees_Pending]
(
	@delay_end_date datetime
)

AS

DECLARE @header varchar(200)	
DECLARE @footer varchar(200)	
DECLARE @Email_Body1 varchar(8000)   
DECLARE @Email_Subject varchar(200)

DECLARE @last_name varchar(20)
DECLARE @first_name varchar(10)
DECLARE @empee_dept_name varchar(50)
DECLARE @network_id varchar(20)
DECLARE @network_id_str varchar(50)
DECLARE @empee_group_desc varchar(50) 
DECLARE @empee_group_cd varchar(10) 
DECLARE @last_update_datetime datetime
DECLARE @leaving_date datetime
DECLARE @leaving_date_str as varchar(30)
DECLARE @count int
DECLARE @I int
DECLARE @J int
DECLARE @CRLF varchar(2)

SET @CRLF = char(10) + char(13)


SET @email_body1 = ''

-- STC 6/28/16 - Do not exclude staff retirees from termination emails
SELECT	@count = count(*)
FROM	dbo.fsdb_facstaff_basic
WHERE	bus_person_indicator = 1  
	AND active_indicator =1 
	AND bus_person_manual_entry_indicator <> 1  
	--AND empee_cls_cd not in ('TR','GA','GB') 
	AND empee_cls_cd not in ('GA','GB') 
	AND (empee_cls_cd <> 'TR' or faculty_staff_indicator = 0)
	AND edw_pers_id not in
	(
		SELECT     edw_pers_id
		FROM         dbo.FSDB_EDW_Current_Employees
		WHERE     (New_Download_Indicator = 1)
	)

SET @header = '<HTML><B>[FSDB-HR] Found ' + CAST(@count as varchar) + ' employees to be terminated as of ' + cast(getdate() as varchar) + '<BR><BR>'
SET @header = @header + '>>>  Procedure: Faculty_Staff_Holder.dbo.DailyUpdate_sp_Send_Email_About_Terminated_Employees_Pending <BR><BR>' + @CRLF
SET @header = @header + 'The following employees are marked for termination after the current delay period expires on '
SET @header = @header + convert(varchar(10), @delay_end_date, 101) + ':<BR><BR>' + @CRLF
SET @footer = '<BR></HTML>'

DECLARE email CURSOR FOR 

-- Find terminated employees which are not Grad Assistant/Pre Doc and Retiree
SELECT	isnull(last_name,''), isnull(first_name,''), isnull(empee_dept_name,'No Dept'),isnull(network_id, ''), isnull(empee_group_cd,''),  isnull(empee_group_desc,'No Emp Group'), last_update_datetime, leaving_date
FROM	dbo.FSDB_facstaff_basic
WHERE	bus_person_indicator = 1  
	and active_indicator = 1 
	and bus_person_manual_entry_indicator <> 1 
	--and empee_cls_cd not in ('TR','GA','GB') 
	and empee_cls_cd not in ('GA','GB') 
	and (empee_cls_cd <> 'TR' or faculty_staff_indicator = 0)
	and edw_pers_id not in
	(
		SELECT     edw_pers_id
		FROM         dbo.FSDB_EDW_Current_Employees
		WHERE     (New_Download_Indicator = 1)
	)
ORDER BY empee_group_cd ASC, LAST_NAME

SET @i = 0
SET @j = 1

OPEN email
FETCH FROM email
INTO @last_name, @first_name, @empee_dept_name, @network_id, @empee_group_cd, @empee_group_desc, @last_update_datetime, @leaving_date

WHILE @@FETCH_STATUS = 0 

BEGIN
	SET @i = @i + 1

	IF @leaving_date is NOT NULL
		SET @leaving_date_str = convert(varchar(30), @leaving_date,101)
	ELSE
		SET @leaving_date_str  = 'No date recorded'

	IF @network_id = ''
		SET @network_id_str = 'No email address'
	ELSE
		SET @network_id_str = @network_id + '@illinois.edu'

	SET	@Email_Body1 = @email_body1 +    
   		@last_name + ',  ' + 
		@first_name + ', ' + 
		@empee_dept_name + ',  '+ 
		@network_id_str +', ' +
		'Leaving: ' + @leaving_date_str + ', ' + 
		'Group: '  + @empee_group_desc + ' ' + '<BR>' + @CRLF

	-- Send email including details for next 50 employees to be terminated
	IF @i = 50
	BEGIN
		SET @Email_Body1 = @header + @Email_Body1 + @footer
		IF @count > 50
			SET @email_subject = 'Employee Terminations pending - LIST part ' + cast(@j as varchar)
		ELSE
			SET @email_subject = 'Employee Terminations pending - LIST'
		--Print 'Send Termination Email Part' + cast(@j as varchar)
		--print @email_subject
		--print @email_body1
--				EXEC dbo.DailyUpdate_sp_Send_Email 'research@business.illinois.edu','research@business.illinois.edu, novianto@illinois.edu, meaganh@illinois.edu','research@business.illinois.edu',@email_subject, @email_body1
		EXEC dbo.DailyUpdate_sp_Send_Email 'research@business.illinois.edu','research@business.illinois.edu','research@business.illinois.edu',@email_subject, @email_body1

		SET @email_body1 = ''
		SET @j = @j + 1
		SET @i = 0
	END

	FETCH NEXT FROM email
	INTO @last_name, @first_name, @empee_dept_name, @network_id, @empee_group_cd, @empee_group_desc, @last_update_datetime, @leaving_date

END
CLOSE email
DEALLOCATE email

-- Send email including details for any remaining employees to be terminated
IF @i > 0
BEGIN
	SET @Email_Body1 = @header + @Email_Body1 + @footer
	IF @j > 1
		SET @email_subject = 'Employee Terminations pending - LIST part ' + cast(@j as varchar)
	ELSE
		SET @email_subject = 'Employee Terminations pending - LIST'
	--Print 'Send Termination Email Part' + cast(@j as varchar)
	--print @email_subject
	--print @email_body1
	EXEC dbo.DailyUpdate_sp_Send_Email 'research@business.illinois.edu','research@business.illinois.edu','research@business.illinois.edu',@email_subject, @email_body1
END
GO
