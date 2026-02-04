SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

-- NS 12/2/2018 Rewritten for DM
-- NS: 9/3/2014 Added FSB.EMPEE_CLS_CD <> 'HG' as well as AND FSB.EMPEE_CLS_CD = 'HG'  related criteria
-- KA: Created: June 2014: Used in [dbo].[WP_sp_Fuzzy_Search_Some_ID] 

CREATE FUNCTION [dbo].[WP_fn_Get_Employee_type_code_2](@FSID INT)
	RETURNS VARCHAR(50)
	AS
BEGIN
	
	DECLARE @EmpCode VARCHAR(100)
					
	SELECT @EmpCode = CASE 
								WHEN DV.BUS_FACULTY = 'Yes' THEN '1'	--'Faculty'	
								WHEN FSB.EMPEE_GROUP_CD in('B','C') THEN '3'								--'Staff - AP, Civil'
								WHEN FSB.EMPEE_GROUP_CD in('E','H') AND FSB.EMPEE_CLS_CD <> 'HG' THEN '4'	--'Staff - Extra Help'
								WHEN DV.DOC_STATUS = 'Current PhD Student' THEN '5'											--'PHd'
								WHEN FSB.EMPEE_GROUP_CD = 'P' THEN '6'										--'Postdoc'
								WHEN FSB.EMPEE_GROUP_CD = 'T' THEN '7'										--'Retiree'
								WHEN DV.[Rank] LIKE '%Emeritus%' THEN '8'												--'Emeriti'
								WHEN FSB.EMPEE_GROUP_CD in ('G','H','S') THEN '9'
								ELSE '11'																	--'others'
					END
	  FROM			dbo._DM_PCI DV
					LEFT OUTER JOIN dbo._DM_BANNER FSB
						ON DV.FacstaffID = FSB.FacstaffID					
	WHERE			 DV.ACTIVE = 'Yes'
				AND DV.FacstaffID = @FSID

	IF @EmpCode is null 
		SET @EmpCode = '11'
	RETURN(@EmpCode)
END


/*
DECLARE @emp_type_code VARCHAR(25)
SET @emp_type_code = Faculty_staff_Holder.dbo.WP_fn_Get_Employee_type_code_2 (10916)
PRINT @emp_type_code


*/















GO
