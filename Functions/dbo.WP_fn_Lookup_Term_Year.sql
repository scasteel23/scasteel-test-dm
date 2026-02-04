SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 12/4/2017 
CREATE  FUNCTION [dbo].[WP_fn_Lookup_Term_Year] 
(
	@TERM_CD AS VARCHAR(6)
)
RETURNS VARCHAR(4)
AS
BEGIN
	DECLARE @term_year varchar(4)

	IF LEN(@TERM_CD) <> 6
		SET @term_year= ''
	ELSE
		SET @term_year = LEFT (RIGHT(@TERM_CD,5),4)

	RETURN @term_year
END
GO
