SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 6/15/2016: Worked!
-- NS 5/28/2016
-- This procedure is used by the SSIS package that fulfills requests
-- It marks a single ai.webservices_requests row as in-process and returns that row to the SSIS package
CREATE PROCEDURE [dbo].[webservices_reserve_pending] AS BEGIN
	-- SELECT 1 FROM abc;
	SET NOCOUNT ON

	DECLARE @time DATETIME = GETDATE();
	DECLARE @id TABLE(id INT);
	
	-- Choose the next request to process, prioritizing user-specific requests
	WITH requests AS (
		SELECT TOP(1) * FROM dbo.webservices_requests r WHERE process IS NULL AND (dependsOn IS NULL OR (SELECT processed FROM dbo.webservices_requests WHERE id=r.dependsOn) IS NOT NULL)
		ORDER BY CASE WHEN url LIKE '%USERNAME:%' THEN 0 ELSE 1 END,created ASC
	)
	UPDATE TOP(1) requests SET process=@@SPID, initiated=GETDATE()
	OUTPUT inserted.id INTO @id
	
	SELECT id,method,url,ISNULL(CAST(post AS VARCHAR(MAX)),'')post FROM dbo.webservices_requests WHERE id=(SELECT * FROM @id)
	-- Returning no rows causes an error in the SSIS package, so we return a row with an id of 0 instead
	UNION SELECT 0,'','','' WHERE (SELECT TOP 1 1 FROM @id) IS NULL
END



GO
