SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

CREATE FUNCTION [dbo].[OUTLOOK_fn_Get_Fullname_By_FSID] (@facstaff_id int)

RETURNS varchar(60) AS  
BEGIN 
	DECLARE @fullname varchar(60)
	
	SELECT @fullname = rtrim(last_name) + ', ' + rtrim(first_name)
	FROM dbo.Facstaff_Basic
	WHERE @Facstaff_ID = Facstaff_ID

	RETURN @fullname
END

GO
