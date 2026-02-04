SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


-- NS 12/3/2018: rewritten for DM
--KA: Created: September 2014
--Used for People Profile
CREATE FUNCTION [dbo].[WP_fn_Get_SomeID_from_FSID]
			(
				@FSID INT
			)
	RETURNS VARCHAR(50)
	AS
BEGIN
	
	DECLARE @SomeID VARCHAR(500)
	
	SET @SomeID =  (SELECT value 
					FROM   DM_Shadow_Staging.[dbo].[FSDB_Web_IDs]						
					WHERE	FacstaffID = @FSID and
							Preferred_Attribute_Indicator = 1)
		


	RETURN(@SomeID)
END


/*
DECLARE @SomeID VARCHAR(500)
SET @SomeID = Faculty_staff_Holder.dbo.WP_fn_Get_SomeID_from_FSID ('1')
PRINT @SomeID


*/















GO
