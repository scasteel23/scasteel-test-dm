SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO



-- NS 11/15/2017
CREATE FUNCTION [dbo].[WP_fn_Get_Experience_End_Year]
(
	@DTY_START varchar(4),
	@DTY_END varchar(4)
)
RETURNS varchar(10)
AS
	BEGIN
		DECLARE @end_year varchar(10)
		IF @DTY_END IS NULL OR RTRIM(@DTY_END) = '' 
			IF @DTY_START IS NULL OR RTRIM(@DTY_START)=''
				SET @end_year=''
			ELSE
				BEGIN
					SET @end_year= YEAR(getdate())
				END
		ELSE
			SET @end_year = @DTY_END
	RETURN @end_year
	/*
		PRINT dbo.WP_fn_Get_Experience_End_Year('','')
		PRINT dbo.WP_fn_Get_Experience_End_Year('2010','')
		PRINT dbo.WP_fn_Get_Experience_End_Year('2010','2016')
		PRINT dbo.WP_fn_Get_Experience_End_Year('','2016')
	*/
	END





GO
