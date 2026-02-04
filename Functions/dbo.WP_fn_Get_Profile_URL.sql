SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


-- NS 1/8/2019: Fixed potentially problem with SET, where the subquery may return more than 1 records
-- NS 11/15/2017: Migrated
--NS: 9/19/2014: Use Adhoc_fn_Get_Website_Prefix() to get the url base from the centra repository FSDB_Websites table
--KA: Created: JuLY 2014
CREATE FUNCTION [dbo].[WP_fn_Get_Profile_URL]
(
	@SiteID VARCHAR(50),
	@Facstaff_ID VARCHAR(10),
	@Network_ID VARCHAR(50)
)
RETURNS VARCHAR(800)
AS
	BEGIN
	
		DECLARE @WebsiteURL varchar(200)
				
		DECLARE @webid VARCHAR(100)

		-- NS 1/8/2019: Fixed potentially problem with SET, where the subquery may return more than 1 records
		--SET @webid = (SELECT LOWER(Value) collate SQL_Latin1_General_Cp1251_CS_AS AS Value
		--FROM [dbo].[FSDB_Web_IDs]
		--WHERE FacstaffID = @Facstaff_ID and Preferred_Attribute_Indicator = 1)
		
		-- Get the latest preferred name
		SELECT @webid = LOWER(Value) collate SQL_Latin1_General_Cp1251_CS_AS
		FROM [dbo].[FSDB_Web_IDs]
		WHERE FacstaffID = @Facstaff_ID and Preferred_Attribute_Indicator = 1
		ORDER BY Create_Datetime ASC
		
				  
		IF @webid = "" OR  @webid IS NULL
		SET @webid = @Network_ID
			
		DECLARE @profileURL VARCHAR(800)

		IF 	 @SiteID = 'accountancy' 
			BEGIN
				-- Get the url base from the central repository FSDB_Websites table
				SET @WebsiteURL = dbo.WP_fn_Get_Website_Prefix('Accountancy Profile')
				--print @WebsiteURL
				--[will print] https://business.illinois.edu/accountancy/profile
				SET @profileURL = @WebsiteURL + '/'	+ @webid   

				--SET @profileURL = 'https://business.illinois.edu/accountancy/profile/'	+ @webid   
			END
		ELSE IF @SiteID = 'business-administration' 
			BEGIN
				-- Get the url base from the central repository FSDB_Websites table
				SET @WebsiteURL = dbo.WP_fn_Get_Website_Prefix('BA Profile')
				--print @WebsiteURL
				--[will print] https://business.illinois.edu/ba/profile
				SET @profileURL = @WebsiteURL + '/'	+ @webid   
				--SET @profileURL = 'https://business.illinois.edu/ba/profile/'	+ @webid
			END
		ELSE IF @SiteID = 'Finance' 
			BEGIN
				-- Get the url base from the central repository FSDB_Websites table
				SET @WebsiteURL = dbo.WP_fn_Get_Website_Prefix('Finance Profile')
				--print @WebsiteURL
				--[will print] https://business.illinois.edu/finance/profile
				SET @profileURL = @WebsiteURL + '/'	+ @webid   
				--SET @profileURL = 'https://business.illinois.edu/finance/profile/'		+ @webid
			END
		ELSE
			BEGIN
				-- Get the url base from the central repository FSDB_Websites table
				SET @WebsiteURL = dbo.WP_fn_Get_Website_Prefix('College Profile')
				--print @WebsiteURL
				--[will print] https://business.illinois.edu/profile
				SET @profileURL = @WebsiteURL + '/'	+ @webid   
				SET @profileURL = 'https://business.illinois.edu/profile/'		+ @webid
			END
		

		RETURN(@profileURL)
	
	END

/*
DECLARE @profileURL VARCHAR(800)
SET @profileURL = Faculty_staff_Holder.dbo.WP_fn_Get_Profile_URL ('ba',14497, 'cbferna2')
PRINT @profileURL

DECLARE @profileURL VARCHAR(800)
SET @profileURL = Faculty_staff_Holder.dbo.WP_fn_Get_Profile_URL ('ba',11957, 'anupam')
PRINT @profileURL

DECLARE @profileURL VARCHAR(800)
SET @profileURL = Faculty_staff_Holder.dbo.WP_fn_Get_Profile_URL ('Finance',239, 'brownjr')
PRINT @profileURL

DECLARE @profileURL VARCHAR(800)
SET @profileURL = Faculty_staff_Holder.dbo.WP_fn_Get_Profile_URL ('Accountancy',26, 'chandlej')
PRINT @profileURL

DECLARE @profileURL VARCHAR(800)
SET @profileURL = Faculty_staff_Holder.dbo.WP_fn_Get_Profile_URL ('',187, 'pmagelli')
PRINT @profileURL

*/















GO
