SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


-- NS 12/3/2018  since to actual addresses screen yet @DM... use the office location to determine city
-- NS 2/16/2007


CREATE FUNCTION [dbo].[DM_OUTLOOK_fn_Get_Facstaff_Addresses_City](@FSID INT, @ACode INT)
	RETURNS VARCHAR(100)
	AS
BEGIN
	
DECLARE @City VARCHAR(100) 
DECLARE @Office_Location VARCHAR(500) 

	 
SET @Office_Location = ''   


SELECT DISTINCT @Office_Location = ISNULL(BUILDING, '') 
FROM  dbo._DM_CONTACT  		
WHERE   FacstaffID = @FSID 
		AND (Address_Display = 'YES' OR Address_Display = '')

SET @City = ''   

IF @Office_Location LIKE '%Wohlers%' 
	SET @CITY = 'Champaign'
ELSE 
IF @Office_Location LIKE '%David Kinley%' OR @Office_Location LIKE '%DKH%' 
	SET @CITY = 'Urbana'
ELSE
IF @Office_Location LIKE '%Illini Center%'  
	SET @CITY = 'Chicago'
ELSE
IF @Office_Location LIKE '%Survey%' OR @Office_Location LIKE '%Doctoral%' OR @Office_Location LIKE '%Irwin%'
	SET @CITY = 'Champaign'
ELSE
IF @Office_Location LIKE '%Z2%' 
	SET @CITY = 'Champaign'
ELSE
IF @Office_Location LIKE '%Armory%' 
	SET @CITY = 'Champaign' 
ELSE 
IF @Office_Location LIKE '%BIF%'  OR @Office_Location LIKE '%Business Instructional Fac%' OR @Office_Location LIKE '%Gies%' 
	SET @CITY = 'Champaign'
ELSE
IF @Office_Location LIKE '%Library%' 
	SET @CITY = 'Urbana' 
ELSE
IF @Office_Location LIKE '%Education%' 
	SET @CITY = 'Champaign'
ELSE
     	SET @CITY = ''


--SELECT DISTINCT @City = FSA.City
--FROM  dbo.Facstaff_Addresses FSA  		
--WHERE   FSA.Facstaff_ID = @FSID AND 
--	FSA.Address_Type_Code = @ACode AND
--	FSA.Active_Indicator = 1

IF  @City IS NULL
	SET  @City = ''
	
RETURN(@City)
END


GO
