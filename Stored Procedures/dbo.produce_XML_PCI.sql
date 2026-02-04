SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 8/28/2017: 
--		Call both produce_XML_PCI_new and produce_XML_PCI_current
CREATE PROC [dbo].[produce_XML_PCI] ( @submit BIT=0 )
AS

BEGIN

	EXEC dbo.produce_XML_PCI_new @submit=@submit
	--EXEC dbo.produce_XML_PCI_current @submit=@submit

	--IF @submit=1
	--	EXEC dbo.webservices_initiate @screen='PCI'

	-- EXEC dbo.produce_XML_PCI @submit = 0

	-- Run this to update PCI
	-- EXEC dbo.produce_XML_PCI @submit = 1
	-- EXEC dbo.webservices_run_DTSX
END
GO
