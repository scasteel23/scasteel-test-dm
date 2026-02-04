SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO


-- NS 12/18/2018
CREATE FUNCTION [dbo].[WP_fn_Get_Building_Addresses_City]
(
	@Office_Location VARCHAR(500)
)
	RETURNS VARCHAR(200)
	AS
BEGIN
	
	DECLARE @AddressString VARCHAR(200) 
	
	SET @AddressString = '' 	
	
DECLARE @City VARCHAR(100) 

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
