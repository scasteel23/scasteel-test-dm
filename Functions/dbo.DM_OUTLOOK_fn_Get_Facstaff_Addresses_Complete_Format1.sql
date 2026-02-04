SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

-- NS 11/16/2018 Rewritten for DM

CREATE FUNCTION [dbo].[DM_OUTLOOK_fn_Get_Facstaff_Addresses_Complete_Format1](@FSID INT, @ACode INT)
	RETURNS VARCHAR(8000)
	AS
BEGIN
	
	DECLARE @AddressString VARCHAR(8000) 

	DECLARE @Office_Location VARCHAR(500), @Office_Hours VARCHAR(500), @and varchar(10)
	
	SET @AddressString = '' 		
 
	-- MAIN Office Address
	SET @Office_Location = ''   
	SET @Office_Hours = ''   

	SELECT DISTINCT @Office_Location = LTRIM(ISNULL(ROOM,'') + ' ') + ISNULL(BUILDING, '') 
		,@Office_Hours = Office_Hours
	FROM  dbo._DM_CONTACT  		
	WHERE   FacstaffID = @FSID 
			AND (Address_Display = 'YES' OR Address_Display = '')

	IF  @Office_Location IS NOT NULL AND Len(LTrim(RTrim(@Office_Location))) <> 0
		SET 	@AddressString = @Office_Location 
	

-- STC 10/22/08 - Added replacement of full name for BIF with abbreviation
-- NS 9/10/2014 - Added wohler, Survey, Illini Center, and Armory abbreviations 
--				  David Kinley Building is no longer spelled out, abbreviate it
-- STC 2/15/17 - Replace both 'Wohlers Hall' and 'Wohlers'
--				 Do not build full address if Office ends with WH or DCL or ZIP = 61820
	--IF @Office_Location LIKE '%Wohlers%' OR @Office_Location LIKE '%David Kinley%' OR
	--@Office_Location LIKE '%DKH%' OR @Office_Location LIKE '%Illini Center%' OR 
	--@Office_Location LIKE '%Survey%'  OR @Office_Location LIKE '%Z2%' OR
	--@Office_Location LIKE '%Armory%' OR  @Office_Location LIKE '%BIF%' OR
	--@Office_Location LIKE '%Business Instructional Facility%' OR
	--@Office_Location LIKE '% WH'  OR @Office_Location LIKE '% DCL' OR
	--@Office_Location LIKE '%Education%' OR @Office_Location LIKE '%Irwin%' 

	--	BEGIN
	--	SET @AddressString = REPLACE(@AddressString, 'David Kinley Hall', ' DKH')
	--	SET @AddressString = REPLACE(@AddressString, 'Business Instructional Facility', ' BIF')
	--	SET @AddressString = REPLACE(@AddressString, 'Wohlers Hall', ' WH')
	--	SET @AddressString = REPLACE(@AddressString, 'Wohlers', ' WH')
	--	SET @AddressString = REPLACE(@AddressString, 'Survey Building', ' Survey')
	--	SET @AddressString = REPLACE(@AddressString, 'Armory', ' ARM')
	--	SET @AddressString = REPLACE(@AddressString, 'Illini Center', 'ILLC')
	--	SET @AddressString = REPLACE(@AddressString, 'Education Building', 'Ed Bldg')
	--	SET @AddressString = REPLACE(@AddressString, 'Education Bldg', 'Ed Bldg')
	--	SET @AddressString = REPLACE(@AddressString, 'Irwin Center', 'Irwin')
	--	SET @AddressString = REPLACE(@AddressString, 'Irwin Hall', 'Irwin')
	--	SET @AddressString = REPLACE(@AddressString, 'Irwin Doctoral Study Hall', 'Irwin')
	--	END


	-- ADDITIONAL Office Address
	SET @Office_Location = ''   
	SET @Office_Hours = ''   

	SELECT DISTINCT @Office_Location = LTRIM(ISNULL(ADDL_ROOM,'') + ' ') + ISNULL(ADDL_BUILDING, '') 
	FROM  dbo._DM_CONTACT  		
	WHERE   FacstaffID = @FSID 
			AND Address_Display = 'YES'

	IF  @Office_Location IS NOT NULL AND Len(LTrim(RTrim(@Office_Location))) <> 0
		SET @and = ' and '
	ELSE
		SET @and = ''

	SET @AddressString = @AddressString + @and + @Office_Location 
	
	SET @AddressString = REPLACE(@AddressString, 'David Kinley Hall', ' DKH')
	SET @AddressString = REPLACE(@AddressString, 'Business Instructional Facility', ' BIF')
	SET @AddressString = REPLACE(@AddressString, 'Wohlers Hall', ' WH')
	SET @AddressString = REPLACE(@AddressString, 'Wohlers', ' WH')
	SET @AddressString = REPLACE(@AddressString, 'Survey Building', ' Survey')
	SET @AddressString = REPLACE(@AddressString, 'Armory', ' ARM')
	SET @AddressString = REPLACE(@AddressString, 'Illini Center', 'ILLC')
	SET @AddressString = REPLACE(@AddressString, 'Education Building', 'Ed Bldg')
	SET @AddressString = REPLACE(@AddressString, 'Education Bldg', 'Ed Bldg')
	SET @AddressString = REPLACE(@AddressString, 'Education', 'Ed Bldg')
	SET @AddressString = REPLACE(@AddressString, 'Irwin Center', 'Irwin')
	SET @AddressString = REPLACE(@AddressString, 'Irwin Hall', 'Irwin')
	SET @AddressString = REPLACE(@AddressString, 'Irwin Doctoral Study Hall', 'Irwin')
 

    SET @AddressString = REPLACE(@AddressString, '&', 'and')


    RETURN(@AddressString)
END

GO
