SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

CREATE    FUNCTION [dbo].[OUTLOOK_fn_Show_Email_Address](@Network_ID varchar(30), @Email_Address varchar(100))
	RETURNS VARCHAR(100)
AS
BEGIN
	DECLARE @email varchar(150)
	IF @Network_ID is NOT NULL
		SET @email = @network_id + '@illinois.edu'
	ELSE
		SET @email = ''
	--IF @Email_Address IS NULL AND @Network_ID IS NOT NULL  	
	--	SET @email = @network_id + '@uiuc.edu'
	--ELSE IF @Email_Address IS NOT NULL
	--	SET @email = @Email_Address
	--ELSE
	--	SET @email =''

	RETURN @email

END




GO
