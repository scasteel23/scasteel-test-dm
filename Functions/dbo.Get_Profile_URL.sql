SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

-- STC 11/18/19 - return profile URL using Net ID (username)
-- NS 11/30/2016
CREATE FUNCTION [dbo].[Get_Profile_URL]
	(
		@USERNAME varchar(60)
	)
	RETURNS VARCHAR(500)
	AS
BEGIN
	
	DECLARE @SomeID VARCHAR(500)
	

	--SET @SomeID = NULL

	--SELECT @SomeID = value 
	--FROM   [dbo].[_UPLOAD_Web_IDs]						
	--WHERE	USERNAME  = @USERNAME
	--		AND	Preferred_Attribute_Indicator = 1
					
	
	--IF @SomeID is not NULL and LTRIM(RTRIM(@SomeID)) <> ''
	--	SET @SomeID = 'https://business.illinois.edu/profile/'+ @SomeID
	SET @SomeID = 'https://giesbusiness.illinois.edu/profile/'+ @USERNAME

	RETURN(@SomeID)
END


/*
DECLARE @SomeID VARCHAR(500)
SET @SomeID = dbo.Get_Profile_URL ('nhadi')
PRINT @SomeID


*/













GO
