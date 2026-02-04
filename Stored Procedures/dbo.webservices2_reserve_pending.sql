SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 4/3/2019
-- It marks a single ai.webservices_requests row as in-process and returns that row to the WS_RUNNER
CREATE PROC [dbo].[webservices2_reserve_pending]
(
		  @id BIGINT OUTPUT
			,@method varchar(50) OUTPUT
			,@url varchar(200) OUTPUT
			,@post varchar(MAX) OUTPUT
)
AS

	/*
	DECLARE @id BIGINT, @method varchar(50), @url varchar(200), @post varchar(MAX)
	EXEC dbo.[webservices2_reserve_pending] @id=@ID OUTPUT, @method=@method OUTPUT, @url=@url OUTPUT, @post=@post OUTPUT
	print convert(varchar,getdate(),108)
	print @id
	print @method
	print @complete_url
	print @post
	*/


	DECLARE @time DATETIME = GETDATE();
	DECLARE @theID INT

	-- Choose the next request to process, prioritizing user-specific 

	SELECT @theID = id	-- will get the earliest request
	FROM dbo.webservices_requests r 
	WHERE process IS NULL 
		AND (dependsOn IS NULL OR (SELECT processed FROM dbo.webservices_requests WHERE id=r.dependsOn) IS NOT NULL)
	ORDER BY CASE WHEN url LIKE '%USERNAME:%' THEN 0 ELSE 1 END,created DESC

	UPDATE dbo.webservices_requests
	SET process=@@SPID,initiated=GETDATE() 
	WHERE id=@theID

	SELECT @id=id, @method=method, @url=url, @post = ISNULL(CAST(post AS VARCHAR(MAX)),'') 
	FROM dbo.webservices_requests WHERE id=@theID



GO
