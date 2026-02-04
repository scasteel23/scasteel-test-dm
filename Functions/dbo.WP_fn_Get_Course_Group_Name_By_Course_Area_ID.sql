SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


-- NS 12/5/2018: rewritten for DM
--NS: 3/17/2015
CREATE FUNCTION [dbo].[WP_fn_Get_Course_Group_Name_By_Course_Area_ID]
(
	@CRS_Subject VARCHAR(6),
	@Course_Area_ID INT 
)
RETURNS varchar(100)
AS

	BEGIN
		-- http://catalog.illinois.edu/search/?P=ACCY%20592
		DECLARE @Course_Group_Name varchar(100)

		SELECT  @Course_Group_Name=Course_Group_Name
        FROM dbo.FSDB_Course_Group_Codes
		WHERE Course_Area_ID = @Course_Area_ID
				AND Course_Subject_Code = @CRS_Subject 

	
		RETURN @Course_Group_Name
	END


--SELECT [dbo].[WP_fn_Get_Course_Group_Name_By_Course_Area_ID] ('badm', 1)




GO
