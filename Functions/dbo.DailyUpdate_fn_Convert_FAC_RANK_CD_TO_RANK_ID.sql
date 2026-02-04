SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO
CREATE FUNCTION [dbo].[DailyUpdate_fn_Convert_FAC_RANK_CD_TO_RANK_ID](@FAC_RANK_CD varchar(2))
RETURNS int AS  
BEGIN 
	-- @FAC_RANK_CD = 1,2,3  is Professor, Associate Professor, Assistant Professor (EDW ranks)
	-- @res = 1,2,3 is Assistant Professor, Associate Professor, Professor (FSDB Rank_Code)
	DECLARE @res INT
	SET @res = NULL
	IF @FAC_RANK_CD is NOT NULL
	    BEGIN
	       	IF  rtrim(@FAC_RANK_CD) = '1'
			SET @res = 3
		ELSE IF  rtrim(@FAC_RANK_CD) = '2'
			SET @res = 2
		ELSE IF  rtrim(@FAC_RANK_CD) = '3'
			SET @res = 1
	     END
		
	
	RETURN @res

END

GO
