SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- 10/2/2017: Created based on [DailyUpdate_sp_DM_Step10_Run_DTSX]
-- 8/28/2017: test
CREATE PROCEDURE [dbo].[webservices_run_DTSX]
AS

	DECLARE @emsg varchar(1000)
	DECLARE @user varchar(100)

	SET @emsg = ''
	SET @user = suser_name()
	
	BEGIN TRY
		EXEC dbo.Log_Insert @Screen_Name='Daily'
			  ,@Activity='"C:\Program Files (x86)\Microsoft SQL Server\110\DTS\Binn\DTExec.exe" /F E:\\ActivityInsight\FSDB_Downloads_Parallel_2012.dtsx'
			  ,@Tag='start'
			  ,@Create_Network_ID=@user
			    
		EXEC xp_cmdshell '"C:\Program Files (x86)\Microsoft SQL Server\110\DTS\Binn\DTExec.exe" /F E:\\ActivityInsight\FSDB_Downloads_Parallel_2012.dtsx'
	END TRY  

	BEGIN CATCH   
		SET @emsg = LEFT(ERROR_MESSAGE(), 449)
		
	END CATCH  ;
	 
	IF @emsg = ''
		BEGIN
			EXEC dbo.Log_Insert @Screen_Name='Daily'
			  ,@Activity='"C:\Program Files (x86)\Microsoft SQL Server\110\DTS\Binn\DTExec.exe" /F E:\\ActivityInsight\FSDB_Downloads_Parallel_2012.dtsx'
			  ,@Tag='success'
			  ,@Create_Network_ID=@user
		END

	ELSE
		BEGIN
			EXEC dbo.Log_Insert @Screen_Name='Daily'
			  ,@Activity='"C:\Program Files (x86)\Microsoft SQL Server\110\DTS\Binn\DTExec.exe" /F E:\\ActivityInsight\FSDB_Downloads_Parallel_2012.dtsx'
			  ,@Tag='failed'
			  ,@Create_Network_ID=@user
			RAISERROR(@emsg,16,1)
		END
GO
