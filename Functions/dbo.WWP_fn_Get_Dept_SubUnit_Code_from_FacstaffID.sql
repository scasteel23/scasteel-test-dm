SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO



--KA: Sep 2014

CREATE FUNCTION [dbo].[WWP_fn_Get_Dept_SubUnit_Code_from_FacstaffID]
(
	@FacstaffID varchar(9)
)
RETURNS varchar(200)
AS
	BEGIN
		DECLARE @Subunit_Code varchar(200)
		Declare @i int


		SELECT		@i = COUNT(*)
		FROM		Faculty_Staff_Holder.dbo.Facstaff_SubUnits FSSU 
					INNER JOIN Faculty_Staff_Holder.dbo.Subunit_Codes SC 
						ON FSSU.Subunit_ID = SC.Subunit_ID 
		WHERE		FSSU.Active_Indicator = 1 
					AND FSSU.Facstaff_ID = @FacstaffID 

			If @i > 0
				BEGIN
					SELECT		@Subunit_Code = Subunit_ID
					FROM		Faculty_Staff_Holder.dbo.Facstaff_SubUnits  								
					WHERE		Active_Indicator = 1 
								AND Facstaff_ID = @FacstaffID 
				END
				ELSE
					SET @Subunit_Code = "NONE"
	
	RETURN @Subunit_Code
END


/*


SELECT dbo.WP_fn_Get_Dept_SubUnit_Code_from_FacstaffID ('120')



*/



GO
