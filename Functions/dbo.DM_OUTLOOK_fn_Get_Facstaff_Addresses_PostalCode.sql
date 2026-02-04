SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


-- NS 2/16/2007


CREATE FUNCTION [dbo].[DM_OUTLOOK_fn_Get_Facstaff_Addresses_PostalCode](@FSID INT, @ACode INT)
	RETURNS VARCHAR(100)
	AS
BEGIN
 


--SELECT DISTINCT @Postal_Code = FSA.Postal_Code  
--FROM  dbo.Facstaff_Addresses FSA  		
--WHERE   FSA.Facstaff_ID = @FSID AND 
--	FSA.Address_Type_Code = @ACode  AND
--	FSA.Active_Indicator = 1

DECLARE @Postal_Code VARCHAR(100) 
DECLARE @Office_Location VARCHAR(500) 

	 
SET @Office_Location = ''   


SELECT DISTINCT @Office_Location = ISNULL(BUILDING, '') 
FROM  dbo._DM_CONTACT  		
WHERE   FacstaffID = @FSID 
		AND (Address_Display = 'YES' OR Address_Display = '')

SET @Postal_Code = ''   

IF @Office_Location LIKE '%Wohlers%' 
	SET @Postal_Code = '61820'
ELSE
IF @Office_Location LIKE '%David Kinley%' OR @Office_Location LIKE '%DKH%' 
	SET @Postal_Code = '61801'
ELSE
IF @Office_Location LIKE '%Illini Center%'  
	SET @Postal_Code = '60606'
ELSE
IF @Office_Location LIKE '%Survey%' OR @Office_Location LIKE '%Doctoral%' OR @Office_Location LIKE '%Irwin%'
	SET @Postal_Code = '61820'
ELSE
IF @Office_Location LIKE '%Z2%' 
	SET @Postal_Code = '61820'
ELSE
IF @Office_Location LIKE '%Armory%' 
	SET @Postal_Code = '61820' 
ELSE 
IF @Office_Location LIKE '%BIF%'  OR @Office_Location LIKE '%Business Instructional Fac%' OR @Office_Location LIKE '%Gies%' 
	SET @Postal_Code = '61820'
ELSE
IF @Office_Location LIKE '%Library%' 
	SET @Postal_Code = '61801' 
ELSE
IF @Office_Location LIKE '%Education%' 
	SET @Postal_Code = '61820' 
ELSE
     	SET @Postal_Code = ''


--SELECT DISTINCT @Postal_Code = FSA.City
--FROM  dbo.Facstaff_Addresses FSA  		
--WHERE   FSA.Facstaff_ID = @FSID AND 
--	FSA.Address_Type_Code = @ACode AND
--	FSA.Active_Indicator = 1

IF  @Postal_Code IS NULL
	SET  @Postal_Code = ''
	
RETURN(@Postal_Code)

	
RETURN(@Postal_Code)
END


GO
