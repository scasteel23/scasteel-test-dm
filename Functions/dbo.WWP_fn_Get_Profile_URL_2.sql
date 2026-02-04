SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


--NS: 9/19/2014: Use Adhoc_fn_Get_Website_Prefix() to get the url base from the centra repository FSDB_Websites table
--KA: JuLY 2014
CREATE FUNCTION [dbo].[WWP_fn_Get_Profile_URL_2]
			(
				@primaryDept VARCHAR(80),
				--@SiteID VARCHAR(30),
				@Facstaff_ID VARCHAR(10),
				@Network_ID VARCHAR(50)
			)
RETURNS VARCHAR(800)
AS
	BEGIN
	
	DECLARE @webid VARCHAR(100)
	SET @webid = (SELECT LOWER(Value) collate SQL_Latin1_General_Cp1251_CS_AS AS Value
	--SET @webid = (SELECT LOWER(Value)
				  FROM [Faculty_Staff_Holder].[dbo].[Facstaff_Web_IDs]
				  where Facstaff_ID = @Facstaff_ID and Pereferred_Attribute_Indicator = 1)
				  
	IF @webid = "" OR  @webid IS NULL
	SET @webid = @Network_ID
	
		DECLARE @WebsiteURL varchar(200)
		DECLARE @profileURL VARCHAR(800)

		--IF 	 @SiteID = 'accountancy' 
		--	SET @profileURL = 'https://business.illinois.edu/accountancy/profile/'	+ @webid   
		--ELSE IF @SiteID = 'ba' 
		--		SET @profileURL = 'https://business.illinois.edu/ba/profile/'	+ @webid
		--ELSE IF @SiteID = 'Finance' 
		--		SET @profileURL = 'https://business.illinois.edu/finance/profile/'		+ @webid
		--ELSE
		--	SET @profileURL = 'https://business.illinois.edu/profile/'		+ @webid
		
		-- Get the url base from the central repository FSDB_Websites table
		SET @WebsiteURL = Faculty_Staff_Holder.dbo.Adhoc_fn_Get_Website_Prefix('College Profile')
		--print @WebsiteURL
		--[will print] https://business.illinois.edu/profile
		SET @profileURL = @WebsiteURL + '/'	+ @webid   

		--SET @profileURL = 'https://business.illinois.edu/profile/'		+ @webid
		
		RETURN(@profileURL)
	
END

/*
DECLARE @profileURL VARCHAR(800)
SET @profileURL = Faculty_staff_Holder.dbo.WP_fn_Get_Profile_URL_2 ('ba',14497, 'cbferna2')
PRINT @profileURL


DECLARE @profileURL VARCHAR(800)
SET @profileURL = Faculty_staff_Holder.dbo.WP_fn_Get_Profile_URL_2 ('Finance',239, 'brownjr')
PRINT @profileURL


DECLARE @profileURL VARCHAR(800)
SET @profileURL = Faculty_staff_Holder.dbo.WP_fn_Get_Profile_URL_2 ('Accountancy',26, 'chandlej')
PRINT @profileURL

DECLARE @profileURL VARCHAR(800)
SET @profileURL = Faculty_staff_Holder.dbo.WP_fn_Get_Profile_URL_2 ('',187, 'pmagelli')
PRINT @profileURL

*/















GO
