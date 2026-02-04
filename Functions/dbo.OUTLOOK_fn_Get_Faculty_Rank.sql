SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


CREATE FUNCTION [dbo].[OUTLOOK_fn_Get_Faculty_Rank](@Rank_ID int)
RETURNS varchar(30) AS  
BEGIN 
	DECLARE @name varchar(30)

	SET @name = ''
	SELECT @name= Rank_Description
	FROM dbo.Rank_Codes
	WHERE  Rank_ID = @Rank_ID

	RETURN @name
END
GO
