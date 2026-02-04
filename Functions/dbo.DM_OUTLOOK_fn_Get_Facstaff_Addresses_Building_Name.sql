SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

-- NS 11/22/2018 Rewritten for DM
CREATE FUNCTION [dbo].[DM_OUTLOOK_fn_Get_Facstaff_Addresses_Building_Name](@FSID INT, @ACode INT)
	RETURNS VARCHAR(20)
	AS
BEGIN
	
DECLARE @AddressString VARCHAR(8000) 
DECLARE @Office_Location VARCHAR(500) 

	
SET @AddressString = '' 
SET @Office_Location = ''   


SELECT DISTINCT @Office_Location = ISNULL(BUILDING, '') 
FROM  dbo._DM_CONTACT  		
WHERE   FacstaffID = @FSID 
		--AND (Address_Display = 'YES' OR Address_Display = '')


IF  @Office_Location IS NOT NULL AND Len(LTrim(RTrim(@Office_Location))) <> 0
	SET 	@AddressString = @Office_Location 
	

IF @Office_Location LIKE '%Wohlers%' OR @Office_Location LIKE '%WH%' 
	SET @AddressString = 'WH'
ELSE 
IF @Office_Location LIKE '%David Kinley%' OR @Office_Location LIKE '%DKH%' 
	SET @AddressString = 'DKH'
ELSE
IF @Office_Location LIKE '%Illini Center%'  
	SET @AddressString = 'ILLINI-C'
ELSE
IF @Office_Location LIKE '%Survey%' OR @Office_Location LIKE '%Doctoral%' OR @Office_Location LIKE '%Irwin%'
	SET @AddressString = 'SURVEY'
ELSE
IF @Office_Location LIKE '%Z2%' 
	SET @AddressString = 'Z2'
ELSE
IF @Office_Location LIKE '%Armory%' 
	SET @AddressString = 'ARM' 
ELSE 
IF @Office_Location LIKE '%BIF%'  OR @Office_Location LIKE '%Business Instructional Fac%'  OR @Office_Location LIKE '%Gies%' 
	SET @AddressString = 'BIF'
ELSE
IF @Office_Location LIKE '%Library%' 
	SET @AddressString = 'LIB' 
ELSE
IF @Office_Location LIKE '%Education%' 
	SET @AddressString = 'EDU' 
ELSE
     	SET @AddressString = ''
	
      RETURN(@AddressString)
END











GO
