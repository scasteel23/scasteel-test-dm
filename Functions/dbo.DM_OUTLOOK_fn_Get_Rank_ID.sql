SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

-- NS 12/3/2018 : reverse lookup Rank_ID from employee's Rank
CREATE    FUNCTION [dbo].[DM_OUTLOOK_fn_Get_Rank_ID](@Rank varchar(100))
	RETURNS INT
AS
BEGIN
	
	DECLARE @rank_id INT

	SELECT @rank_id = Rank_id
	FROm dbo.FSDB_Rank_Codes
	WHERE Rank_Description = @Rank

	RETURN @Rank_id

END




GO
