SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


-- NS 12/5/2018: not sure what to do wince DM has no subunit holder yet
--KA: Sep 2014

CREATE FUNCTION [dbo].[WWP_fn_Get_Joint_Area_ind_from_FacstaffID]
(
	@FacstaffID varchar(9)
)
RETURNS varchar(200)
AS
	BEGIN
		DECLARE @joint_area_ind varchar(200)
		Declare @i int


		SELECT		@i = COUNT(*)
		FROM		Faculty_Staff_Holder.dbo.Facstaff_SubUnits FSSU 					
		WHERE		FSSU.Active_Indicator = 1 
					AND FSSU.Facstaff_ID = @FacstaffID 

			If @i > 1
				BEGIN
					SET @joint_area_ind = 1
				END
				ELSE
					SET @joint_area_ind = 0
	
	RETURN @joint_area_ind
END


/*


SELECT dbo.WP_fn_Get_Joint_Area_ind_from_FacstaffID ('81')
SELECT dbo.WP_fn_Get_Joint_Area_ind_from_FacstaffID ('111')
SELECT dbo.WP_fn_Get_Joint_Area_ind_from_FacstaffID ('98')
SELECT dbo.WP_fn_Get_Joint_Area_ind_from_FacstaffID ('3000')
*/



GO
