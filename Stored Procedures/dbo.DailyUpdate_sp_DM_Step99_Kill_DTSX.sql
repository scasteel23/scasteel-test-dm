SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- 12/13/2017: 
CREATE PROCEDURE [dbo].[DailyUpdate_sp_DM_Step99_Kill_DTSX]
AS

	-- To Kill this process, do remote login to busdbsrv
	--	in Task Manager's Details tab (or click "all user process") find and kill DTSExec process
	-- OR
	-- Run this in SQL
	EXEC xp_cmdshell '"TaskKill /F /IM DTExec.exe"'
GO
