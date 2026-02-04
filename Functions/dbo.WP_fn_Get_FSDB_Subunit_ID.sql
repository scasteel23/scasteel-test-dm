SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

-- NS 12/8/2018 : reverse lookup Department_ID from employee's subunit name
CREATE    FUNCTION [dbo].[WP_fn_Get_FSDB_Subunit_ID](@area varchar(100))
	RETURNS INT
AS
BEGIN
	
	DECLARE  @Subunit_ID INT

	SELECT @Subunit_ID=Subunit_ID
	FROM dbo.FSDB_Subunit_Codes
	WHERE Subunit_Name=@Area

	RETURN @Subunit_ID

END




GO
