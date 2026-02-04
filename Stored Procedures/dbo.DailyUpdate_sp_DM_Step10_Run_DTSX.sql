SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- 8/28/2017: test
CREATE PROCEDURE [dbo].[DailyUpdate_sp_DM_Step10_Run_DTSX]
AS

	-- To Kill this process, do remote login to busdbsrv
	--	in Task Manager's Details tab (or click "all user process") find and kill DTSExec process
	-- OR
	-- Run this in SQL
	-- EXEC xp_cmdshell '"TaskKill /F /IM DTExec.exe"'

	DECLARE @emsg varchar(1000)
	DECLARE @user varchar(100)

	DECLARE @jobdate as datetime
	SET @jobdate = getdate()

	INSERT INTO Database_Maintenance.dbo.Download_Process_Monitor_Logs
			(Table_Name, Copy_Datetime, [Status]) 
	VALUES('webservices_requests', @jobdate, 0)

	SET @emsg = ''
	SET @user = suser_name()
	
	BEGIN TRY
		EXEC dbo.Log_Insert @Screen_Name='Daily'
			  ,@Activity='"C:\Program Files (x86)\Microsoft SQL Server\110\DTS\Binn\DTExec.exe" /F E:\\ActivityInsight\FSDB_Downloads_Parallel_2012webservices.dtsx'
			  ,@Tag='start'
			  ,@Create_Network_ID=@user
			    
		EXEC xp_cmdshell '"C:\Program Files (x86)\Microsoft SQL Server\110\DTS\Binn\DTExec.exe" /F E:\\ActivityInsight\FSDB_Downloads_Parallel_2012webservices.dtsx'
	END TRY  

	BEGIN CATCH   
		SET @emsg = LEFT(ERROR_MESSAGE(), 449)
		
	END CATCH  ;
	 
	IF @emsg = ''
		BEGIN
			EXEC dbo.Log_Insert @Screen_Name='Daily'
			  ,@Activity='"C:\Program Files (x86)\Microsoft SQL Server\110\DTS\Binn\DTExec.exe" /F E:\\ActivityInsight\FSDB_Downloads_Parallel_2012webservices.dtsx'
			  ,@Tag='success'
			  ,@Create_Network_ID=@user
		END

	ELSE
		BEGIN
			EXEC dbo.Log_Insert @Screen_Name='Daily'
			  ,@Activity='"C:\Program Files (x86)\Microsoft SQL Server\110\DTS\Binn\DTExec.exe" /F E:\\ActivityInsight\FSDB_Downloads_Parallel_2012webservices.dtsx'
			  ,@Tag='failed'
			  ,@Create_Network_ID=@user
			RAISERROR(@emsg,16,1)
		END


UPDATE  Database_Maintenance.dbo.Download_Process_Monitor_Logs
SET		Status = 2
WHERE	Table_Name = 'webservices_requests'
	AND	Copy_Datetime = @jobdate
GO
