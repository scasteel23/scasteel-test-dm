SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


--KA: Created: SEP 2014
CREATE FUNCTION [dbo].[WWP_fn_get_journal_ID_from_short_name]
			(
				@journal_name_short VARCHAR(20)
			)
	RETURNS VARCHAR(50)
	AS
BEGIN
	
	
	DECLARE @journal_id int
	
	SET	@journal_id = (	SELECT journal_id
						FROM	[Faculty_Staff_Holder].[dbo].[Journals]
						WHERE	journal_name_short = @journal_name_short
							AND Active_indicator = 1)
	
	RETURN(@journal_id)
END


/*
DECLARE @journal_id int
SET @journal_id = Faculty_staff_Holder.dbo.WP_fn_get_journal_ID_from_short_name ('enethi')
PRINT @journal_id


*/

















GO
