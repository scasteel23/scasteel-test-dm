SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO



-- NS 11/15/2017
CREATE FUNCTION [dbo].[WP_fn_Get_Experience_Year_String]
(
	@DTY_START varchar(4),
	@DTY_END varchar(4)
)
RETURNS varchar(30)
AS
	BEGIN
		DECLARE @years varchar(30)
		IF @DTY_END IS NULL OR RTRIM(@DTY_END) = '' 
			IF @DTY_START IS NULL OR RTRIM(@DTY_START)=''
				SET @years=''
			ELSE
				BEGIN
					SET @years= @DTY_START +' to present'
				END
		ELSE
			IF @DTY_START IS NULL OR RTRIM(@DTY_START)=''
				SET @years = @DTY_END
			ELSE
				SET @years = @DTY_START +'-' + @DTY_END

		RETURN @years
	/*
		PRINT dbo.WP_fn_Get_Experience_Year_String('','')
		PRINT dbo.WP_fn_Get_Experience_Year_String('2010','')
		PRINT dbo.WP_fn_Get_Experience_Year_String('2010','2016')
		PRINT dbo.WP_fn_Get_Experience_Year_String('','2016')
	*/
	END





GO
