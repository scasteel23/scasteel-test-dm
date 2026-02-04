SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


-- NS 12/5/2018: Rewritten for DM
--NS: 3/17/2015
CREATE FUNCTION [dbo].[WP_fn_Get_Course_Group_Name_By_Course_Group_Identity]
(
	@CRS_Subject VARCHAR(6),
	@Course_Group_Identity INT,
	@Course_Group_Digit_Position INT
)
RETURNS varchar(100)
AS

	BEGIN
		-- http://catalog.illinois.edu/search/?P=ACCY%20592
		DECLARE @Course_Group_Name varchar(100)

		SELECT  @Course_Group_Name=Course_Group_Name
        FROM dbo.FSDB_Course_Group_Codes
		WHERE Course_Group_Identity = @Course_Group_Identity
				AND Course_Group_Digit_Position = @Course_Group_Digit_Position
				AND Course_Subject_Code = @CRS_Subject 

	
		RETURN @Course_Group_Name
	END


--SELECT [dbo].[WP_fn_Get_Course_Group_Name_By_Course_Group_Identity] ('badm', 1, 2)




GO
