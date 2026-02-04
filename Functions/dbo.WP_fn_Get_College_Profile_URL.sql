SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

-- NS 12/2/2018 Rewritten for DM
-- NS 9/4/2014
--		Modified from [WP_fn_Get_Profile_URL] function
CREATE FUNCTION  [dbo].[WP_fn_Get_College_Profile_URL]
			(
				@Facstaff_ID INT				
			)
RETURNS varchar(800)
AS
	BEGIN
		
		DECLARE @webid VARCHAR(100), @profileURL varchar(800) 
		SET @webid = (SELECT LOWER(Value)
					  FROM DM_Shadow_Staging.[dbo].[FSDB_Web_IDs]
					  where FacstaffID = @Facstaff_ID and Preferred_Attribute_Indicator = 1)
		IF @webid is NULL OR RTRIM(@webid) = ''
			SET @profileURL = 'https://business.illinois.edu/profile/all-depts-emp/'
		ELSE
			SET @profileURL = 'https://business.illinois.edu/profile/'	+ @webid	

	RETURN @profileURL
END

/*
DECLARE @facstaff_id int, @profileURL VARCHAR(800)
SET @facstaff_id = 15892
EXEC dbo.[WP_sp_Get_Profile_URL] @facstaff_id=@facstaff_id, @profileURL= @profileURL OUTPUT
PRINT @profileURL

DECLARE @facstaff_id int, @profileURL VARCHAR(800)
SET @facstaff_id = 239
EXEC dbo.[WP_sp_Get_Profile_URL] @facstaff_id=@facstaff_id, @profileURL= @profileURL OUTPUT
PRINT @profileURL

DECLARE @facstaff_id int, @profileURL VARCHAR(800)
SET @facstaff_id = 26
EXEC dbo.[WP_sp_Get_Profile_URL] @facstaff_id=@facstaff_id, @profileURL= @profileURL OUTPUT
PRINT @profileURL

DECLARE @facstaff_id int, @profileURL VARCHAR(800)
SET @facstaff_id = 210000
EXEC dbo.[WP_sp_Get_Profile_URL] @facstaff_id=@facstaff_id, @profileURL= @profileURL OUTPUT
PRINT @profileURL



*/















GO
