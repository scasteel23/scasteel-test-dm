SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


--KA: Aug 2014
CREATE FUNCTION [dbo].[WWP_fn_split_string]
			(
				@webID VARCHAR(300)
			)
	RETURNS VARCHAR(50)
	AS
BEGIN
	
	DECLARE @EmpCode VARCHAR(100)
	DECLARE @PartialName VARCHAR(100)
	
	
	WHILE LEN(@webID) > 0
	BEGIN
		IF PATINDEX('%-%',@webID) > 0
			BEGIN
				SET @PartialName = SUBSTRING(@webID, 0, PATINDEX('%-%',@webID))
				--SELECT @PartialName

				SET @webID = SUBSTRING(@webID, LEN(@PartialName + '-') + 1,
															 LEN(@webID))	
				SET @PartialName = @webID
					
			END
		ELSE
		BEGIN
			SET @PartialName = @webID
			SET @webID = NULL
		--	SELECT @PartialName
		END
	END	

	RETURN(@PartialName)
END


/*
DECLARE @emp_type_code VARCHAR(25)
SET @emp_type_code = Faculty_staff_Holder.dbo.WP_fn_split_string ('ram-subbrama')
PRINT @emp_type_code


*/















GO
