SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


-- NS 11/15/2017 migrated
-- STC created 3/1/07

CREATE FUNCTION [dbo].[WP_fn_Get_Website_Prefix](@WebsiteName VARCHAR(50))
	RETURNS VARCHAR(100)
	AS
	BEGIN

	DECLARE @WebsitePrefix AS VARCHAR(100)

	SELECT @WebsitePrefix = Website_Prefix_URL
	FROM FSDB_Websites
	WHERE Website_Name = @WebsiteName
	
	RETURN @WebsitePrefix
END

GO
