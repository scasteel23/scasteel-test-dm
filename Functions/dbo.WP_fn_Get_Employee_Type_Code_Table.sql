SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

-- NS 12/5/2018: rewritten for DM, leave unused @EmpeeTypeCode paramater for compatibility with the caller

-- STC 4/27/17 - Faculty with Rank_ID = 8 or 15 should both be considered emeriti (added 15)
--
-- STC 4/27/15 - Do not classify emeriti as faculty if emeriti category is not selected
--
-- NS: 9/3/2014 Added FSB.EMPEE_CLS_CD <> 'HG' as well as AND FSB.EMPEE_CLS_CD = 'HG'  related criteria
--
-- NS: 8/29/2014: 
--		Just replaced dbo.DIRECTORY_Employee_View  with  Faculty_Staff_MIIS.dbo.Facstaff_Directory2
--		Must improve performance later
--		by putting Rank_ID, EMPEE_GROUP_CD, Doctoral_Flag, and Vita_Indicator in Faculty_Staff_MIIS.dbo.Facstaff_Directory2 
--		therefore there is no wasting a lot of time by joining Faculty_Staff_Basic
--		Without taking into consideration of Facstaff_Vitas table
--		ONE faculty lookup =  500 (Facstaff_Directory2 size) x 4000 (Facstaff_Basic) search
--		compare to ONE faculty lookup = 500 (Facstaff_Directory2 size) 

-- KA: Created: June 2014: Used in WP_XML_People_Directory
CREATE FUNCTION [dbo].[WP_fn_Get_Employee_Type_Code_Table]
			(
				@FSID INT,
				@EmpeeTypeCode VARCHAR(300)
			)
	RETURNS VARCHAR(50)
	AS
BEGIN
	
	DECLARE @EmpCode VARCHAR(100)

	SELECT @EmpCode = CASE 
					WHEN ((DV.Faculty_Staff_Indicator = 1)  and (DV.Rank_ID NOT IN (8, 15))) THEN '1'	--'Faculty'	
					WHEN ((DV.EMPEE_GROUP_CD in('B','C')) AND (DV.Rank_ID NOT IN (8, 15))) THEN '3'	--'Staff - AP, Civil'   (Charles Linke is the emeriti with emp group=b)
					WHEN DV.EMPEE_GROUP_CD in('E','H') AND DV.EMPEE_CLS_CD <> 'HG' THEN '4'		--'Staff - Extra Help'
					WHEN DV.Titles like '%PhD%' THEN '5'												--'PhD'
					WHEN DV.EMPEE_GROUP_CD = 'P' THEN '6'											--'Postdoc'
					WHEN ((DV.EMPEE_GROUP_CD = 'T') and (DV.Rank_ID NOT IN (8, 15))) THEN '7'		--'Retiree'
					WHEN ((DV.Faculty_Staff_Indicator = 1) and (DV.Rank_ID IN (8, 15))) THEN '8'	--'Emeriti'
					WHEN DV.EMPEE_GROUP_CD in ('G','S') OR DV.EMPEE_CLS_CD = 'HG' THEN '9'		--'Student worker'
					ELSE '11'																		--'others'
				END
	FROM			Faculty_Staff_MIIS.dbo.Facstaff_Directory2 DV
										
	WHERE DV.Facstaff_ID = @FSID
	IF @EmpCode IS NULL
		SET @EmpCode = '11'
	RETURN(@EmpCode)
END

/*
-- STC 4/27/15 -- Original code, which cosnidered emeriti as faculty if emeriti category was not selected

	--KA: Check to see if employee type 'Emeriti' is selected  (code = 8). If yes, then show them under Emeriti. Else, show them as Faculty.
	DECLARE @emeriti_ind VARCHAR(5)
	SET @emeriti_ind = (select COUNT(*) from Faculty_staff_Holder.dbo.WP_Parse_String_To_Table(@EmpeeTypeCode) 
						where code in (8))

IF @emeriti_ind	= 0
BEGIN				
	SELECT @EmpCode = CASE 
						WHEN DV.Faculty_Staff_Indicator = 1 THEN '1'	--'Faculty'	
						WHEN FSB.EMPEE_GROUP_CD in('B','C') THEN '3'								--'Staff - AP, Civil'
						WHEN FSB.EMPEE_GROUP_CD in('E','H') AND FSB.EMPEE_CLS_CD <> 'HG' THEN '4'	--'Staff - Extra Help'
						WHEN FSB.Doctoral_Flag = 1 THEN '5'											--'PhD'
						WHEN FSB.EMPEE_GROUP_CD = 'P' THEN '6'										--'Postdoc'
						WHEN FSB.EMPEE_GROUP_CD = 'T' THEN '7'										--'Retiree'
						WHEN FSB.Rank_ID = 8 THEN '8'												--'Emeriti'
						WHEN FSB.EMPEE_GROUP_CD in ('G','S') OR FSB.EMPEE_CLS_CD = 'HG' THEN '9'	--'Student worker'
						ELSE '11'																	--'others'
					END
	FROM			Faculty_Staff_MIIS.dbo.Facstaff_Directory2 DV
					INNER JOIN Faculty_Staff_Holder.dbo.Facstaff_Basic FSB
						ON DV.Facstaff_ID = FSB.Facstaff_ID
					
	WHERE		 FSB.BUS_Person_Indicator = 1 
				AND FSB.Active_Indicator = 1
				AND DV.Facstaff_ID = @FSID
		
END
ELSE
		SELECT @EmpCode = CASE 
						WHEN ((DV.Faculty_Staff_Indicator = 1)  and (FSB.Rank_ID NOT IN (8))) THEN '1'	--'Faculty'	
						WHEN ((FSB.EMPEE_GROUP_CD in('B','C')) AND (FSB.Rank_ID NOT IN (8))) THEN '3'	--'Staff - AP, Civil'   (Charles Linke is the emeriti with emp group=b)
						WHEN FSB.EMPEE_GROUP_CD in('E','H') AND FSB.EMPEE_CLS_CD <> 'HG' THEN '4'		--'Staff - Extra Help'
						WHEN FSB.Doctoral_Flag = 1 THEN '5'												--'PhD'
						WHEN FSB.EMPEE_GROUP_CD = 'P' THEN '6'											--'Postdoc'
						WHEN ((FSB.EMPEE_GROUP_CD = 'T') and (FSB.Rank_ID NOT IN (8))) THEN '7'			--'Retiree'
						WHEN ((DV.Faculty_Staff_Indicator = 1) and (FSB.Rank_ID = 8)) THEN '8'			--'Emeriti'
						WHEN FSB.EMPEE_GROUP_CD in ('G','S') OR FSB.EMPEE_CLS_CD = 'HG' THEN '9'		--'Student worker'
						ELSE '11'																		--'others'
					END
		FROM			Faculty_Staff_MIIS.dbo.Facstaff_Directory2 DV
						INNER JOIN Faculty_Staff_Holder.dbo.Facstaff_Basic FSB
							ON DV.Facstaff_ID = FSB.Facstaff_ID
						
		WHERE		 FSB.BUS_Person_Indicator = 1
					AND FSB.Active_Indicator = 1
					AND DV.Facstaff_ID = @FSID

	RETURN(@EmpCode)
*/

/*
DECLARE @emp_type_code VARCHAR(25)
SET @emp_type_code = Faculty_staff_Holder.dbo.WP_fn_Get_Employee_type_code_Table (1, '')
PRINT @emp_type_code


*/















GO
