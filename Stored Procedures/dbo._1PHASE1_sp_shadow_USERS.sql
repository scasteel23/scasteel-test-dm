SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 4/3/2018
CREATE PROC [dbo].[_1PHASE1_sp_shadow_USERS] 
AS

	EXEC dbo.webservices_initiate @screen='USERS'
	EXEC dbo.webservices_run_DTSX

	


GO
