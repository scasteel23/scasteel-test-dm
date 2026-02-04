SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 12/4/2017 
CREATE  FUNCTION [dbo].[WP_fn_Lookup_Term_Name] 
(
	@TERM_CD AS VARCHAR(6)
)
RETURNS VARCHAR(10)
AS
BEGIN
	DECLARE @term_name varchar(10)

	IF LEN(@TERM_CD) <> 6
		SET @term_name=''
	ELSE IF RIGHT(@TERM_CD,1) = '8'
		SET @term_name='Fall'
	ELSE IF RIGHT(@TERM_CD,1) = '1'
		SET @term_name='Spring'
	ELSE IF RIGHT(@TERM_CD,1) = '5'
		SET @term_name='Summer'
	ELSE IF RIGHT(@TERM_CD,1) = '0'
		SET @term_name='Winter'

	RETURN @term_name
END
GO
