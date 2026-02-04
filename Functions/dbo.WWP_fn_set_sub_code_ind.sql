SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


--KA: June 2014
CREATE FUNCTION [dbo].[WWP_fn_set_sub_code_ind]
		(
			@DeptSubCode varchar(2000), 
			@dept_code_single varchar(20)
		)
RETURNS int
	AS
BEGIN
	
	DECLARE @DeptSubIND INT
					
	SET @DeptSubIND = (SELECT COUNT(*) from Faculty_staff_Holder.dbo.WP_Parse_String_To_Table(@DeptSubCode) AA
							INNER JOIN [Faculty_Staff_Holder].[dbo].[Subunit_Codes] SC
							ON AA.code = SC.SUBUNIT_ID
							where SC.Department_ID = @dept_code_single AND SC.Active_Indicator = 1)		
	IF @DeptSubIND = 0
		SET @DeptSubIND = 0
	ELSE
		SET @DeptSubIND = 1	
		
	

	RETURN(@DeptSubIND)
END


/*
DECLARE @DeptSubIND VARCHAR(25)
DECLARE @DeptSubCode varchar(2000)
DECLARE @dept_code_single varchar(20)

SET @DeptSubCode = '1013,1009'
SET @dept_code_single = '1'
			
SET @DeptSubIND = Faculty_staff_Holder.dbo.WP_fn_set_sub_code_ind (@DeptSubCode,@dept_code_single)
PRINT @DeptSubIND


*/















GO
