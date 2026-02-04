SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 4/3/2018
CREATE PROC [dbo].[_1PHASE4_sp_shadow_PCI] 
AS

	EXEC dbo.webservices_initiate @screen='PCI'
	EXEC dbo.webservices_run_DTSX

	


GO
