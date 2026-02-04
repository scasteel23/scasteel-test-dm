SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


-- NS 11/20/2017: rewritten, create dbo.WP_rndView view in DM_Shadow_Staging database
-- KA: Created: SEP 2014: USed in People Profile: For Journals in Profile
CREATE FUNCTION [dbo].[WP_fn_Random_String]()
RETURNS varchar(3)
AS
BEGIN
	DECLARE @rndValue varchar(3)

	SELECT @rndValue = WP_rndResult
	FROM dbo.WP_rndView
	RETURN LOWER(@rndValue)
END

/*
--SELECT dbo.WP_fn_Random_string()

DECLARE @Random_string VARCHAR(25)			
SET @Random_string = Faculty_staff_Holder.dbo.[WP_fn_Random_string]()
PRINT @Random_string


*/

GO
