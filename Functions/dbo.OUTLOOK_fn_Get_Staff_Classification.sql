SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO



CREATE FUNCTION [dbo].[OUTLOOK_fn_Get_Staff_Classification](@SC_ID int)
RETURNS varchar(60) AS  
BEGIN 
	DECLARE @name varchar(60)

	SET @name = ''
	SELECT @name= Staff_Classification_Description
	FROM dbo.Staff_Classification_Codes
	WHERE  Staff_Classification_ID = @SC_ID

	RETURN @name
END



GO
