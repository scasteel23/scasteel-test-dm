SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

-- NS 11/22/2018 Rewritten for DM (a day b4 Thansgiving Day)
CREATE    FUNCTION [dbo].[DM_OUTLOOK_fn_Get_Facstaff_Office_Location](@FSID INT)
	RETURNS VARCHAR(400)
	AS
BEGIN
	
		DECLARE @OfficeLocation VARCHAR(400)
		DECLARE @f as datetime
		SET @OfficeLocation = '' 
	

		SELECT DISTINCT @OfficeLocation = LTRIM(ISNULL(ROOM,'') + ' ') + ISNULL(BUILDING, '') 
		FROM  dbo._DM_CONTACT  		
		WHERE   FacstaffID = @FSID 
				AND (Address_Display = 'YES' OR Address_Display = '')
	
		RETURN(@OfficeLocation)
	END

GO
