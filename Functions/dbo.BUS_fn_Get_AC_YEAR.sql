SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
-- STC 3/30/20
-- Copied from chiedsql1.DW
CREATE FUNCTION [dbo].[BUS_fn_Get_AC_YEAR]
(
	@date datetime
)
RETURNS varchar(30)
AS
	BEGIN
		DECLARE @ay_start datetime
		DECLARE @ay_start_str varchar(10)
		DECLARE @ac_year varchar(9)

		SET @ay_start = cast('8/16/' + CAST(DATEPART(yy,@date) as varchar) as datetime)

		IF @ay_start > @date
			SET @ay_start = DATEADD(yy,-1,@ay_start)

		SET @ay_start_str = convert(varchar, @ay_start, 101)

		SET @ac_year = RIGHT(@ay_start_str, 4) + '-' + CAST((CAST(RIGHT(@ay_start_str,4) as INT) + 1) as varchar)

--		PRINT @ac_year
		
		RETURN @ac_year
	/*
		PRINT dbo.[BUS_fn_Get_AC_YEAR](CURRENT_TIMESTAMP)
		PRINT dbo.[BUS_fn_Get_AC_YEAR]('8/15/19')
		PRINT dbo.[BUS_fn_Get_AC_YEAR]('8/16/19')
		PRINT dbo.[BUS_fn_Get_AC_YEAR]('8/15/20')
		PRINT dbo.[BUS_fn_Get_AC_YEAR]('8/16/20')
	*/
	END





GO
