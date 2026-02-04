SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

-- NS 12/18/2018
CREATE FUNCTION [dbo].[WP_fn_Get_Building_Addresses_Street]
(
	@Office_Location VARCHAR(500)
)
	RETURNS VARCHAR(200)
	AS
BEGIN
	
	DECLARE @AddressString VARCHAR(200) 
	
	SET @AddressString = '' 		

	--IF  @Office_Location IS NOT NULL AND Len(LTrim(RTrim(@Office_Location))) <> 0
	--	SET 	@AddressString = @Office_Location 
	
	IF @Office_Location LIKE '%Wohlers%' 
		SET @AddressString = '1206 South Sixth Street'
	ELSE 
	IF @Office_Location LIKE '%David Kinley%' OR @Office_Location LIKE '%DKH%' 
		SET @AddressString = '1407 W. Gregory Drive'
	ELSE
	IF @Office_Location LIKE '%Illini Center%'  
		SET @AddressString = '200 South Wacker Drive'
	ELSE
	IF @Office_Location LIKE '%Survey%' OR @Office_Location LIKE '%Doctoral%' OR @Office_Location LIKE '%Irwin%'
		SET @AddressString = '607 East Gregory Drive'
	ELSE
	IF @Office_Location LIKE '%Z2%' 
		SET @AddressString = '2001 South First Street'
	ELSE
	IF @Office_Location LIKE '%Armory%' 
		SET @AddressString = '505 East Armory Avenue' 
	ELSE 
	IF @Office_Location LIKE '%BIF%'  OR @Office_Location LIKE '%Business Instructional Fac%'  OR @Office_Location LIKE '%Gies%' 
		SET @AddressString = '515 E Gregory Drive'
	ELSE
	IF @Office_Location LIKE '%Library%' 
		SET @AddressString = '1408 W Gregory Dr' 
	ELSE
	IF @Office_Location LIKE '%Education%' 
		SET @AddressString = '1310 S 6th St' 
	ELSE
     	SET @AddressString = ''


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


	---- ADDITIONAL Office Address
	--SET @Office_Location = @Office_Location2  
	--DECLARE @and varchar(6)

	--IF  @Office_Location IS NOT NULL AND Len(LTrim(RTrim(@Office_Location))) <> 0
	--	SET @and = ' and '
	--ELSE
	--	SET @and = ''

	--SET @AddressString = @AddressString + @and + @Office_Location 
	
	--SET @AddressString = REPLACE(@AddressString, 'David Kinley Hall', ' DKH')
	--SET @AddressString = REPLACE(@AddressString, 'Business Instructional Facility', ' BIF')
	--SET @AddressString = REPLACE(@AddressString, 'Wohlers Hall', ' WH')
	--SET @AddressString = REPLACE(@AddressString, 'Wohlers', ' WH')
	--SET @AddressString = REPLACE(@AddressString, 'Survey Building', ' Survey')
	--SET @AddressString = REPLACE(@AddressString, 'Armory', ' ARM')
	--SET @AddressString = REPLACE(@AddressString, 'Illini Center', 'ILLC')
	--SET @AddressString = REPLACE(@AddressString, 'Education Building', 'Ed Bldg')
	--SET @AddressString = REPLACE(@AddressString, 'Education Bldg', 'Ed Bldg')
	--SET @AddressString = REPLACE(@AddressString, 'Irwin Center', 'Irwin')
	--SET @AddressString = REPLACE(@AddressString, 'Irwin Hall', 'Irwin')
	--SET @AddressString = REPLACE(@AddressString, 'Irwin Doctoral Study Hall', 'Irwin')
 

 --   SET @AddressString = REPLACE(@AddressString, '&', 'and')


    RETURN(@AddressString)
END


GO
