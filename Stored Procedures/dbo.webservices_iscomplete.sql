SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



-- NS 5/28/2016
CREATE PROCEDURE [dbo].[webservices_iscomplete] @requestid INT AS
	SELECT CASE WHEN processed IS NOT NULL THEN 1 ELSE 0 END FROM dbo.webservices_requests WHERE id=@requestid




GO
