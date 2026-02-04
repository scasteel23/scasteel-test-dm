SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO



--CREATE FUNCTION [dbo].[WWP_fn_Get_Facstaff_Office_Building_Name_short](@FSID INT, @ACode INT)
CREATE FUNCTION [dbo].[WWP_fn_Get_Facstaff_Office_Building_Name_short](@FSID INT)
	RETURNS VARCHAR(20)
	AS
BEGIN
	
DECLARE @AddressString VARCHAR(8000) 
DECLARE @Office_Location VARCHAR(500) 

	
SET @AddressString = '' 
SET @Office_Location = ''   


SELECT @Office_Location = FSA.Office_Location
FROM  Faculty_Staff_Holder.dbo.Facstaff_Addresses FSA  
WHERE   FSA.Facstaff_ID = @FSID AND 
	--FSA.Address_Type_Code = @ACode AND
	FSA.Active_Indicator = 1


IF  @Office_Location IS NOT NULL AND Len(LTrim(RTrim(@Office_Location))) <> 0
	SET 	@AddressString = @Office_Location 
	

IF @Office_Location LIKE '%Wohlers%' 
	SET @AddressString = 'WH'
ELSE 
IF @Office_Location LIKE '%David Kinley%' OR @Office_Location LIKE '%DKH%' 
	SET @AddressString = 'DKH'
ELSE
IF @Office_Location LIKE '%Illini Center%'  
	SET @AddressString = 'ILLINI-C'
ELSE
IF @Office_Location LIKE '%Survey%' 
	SET @AddressString = 'SURVEY'
ELSE
IF @Office_Location LIKE '%Z2%' 
	SET @AddressString = 'Z2'
ELSE
IF @Office_Location LIKE '%Armory%' 
	SET @AddressString = 'ARM' 
ELSE 
IF @Office_Location LIKE '%BIF%'  OR @Office_Location LIKE '%Business Instructional Facility%' 
	SET @AddressString = 'BIF'
ELSE
IF @Office_Location LIKE '%Library%' 
	SET @AddressString = 'LIB' 
ELSE
     	SET @AddressString = ''
	
      RETURN(@AddressString)
END












GO
