SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


--KA: Created: June 2014
CREATE FUNCTION [dbo].[WWP_fn_Get_Primary_Department]
			(
				@FSID INT,
				@EmpeeTypeCode VARCHAR(300)
			)
	RETURNS VARCHAR(50)
	AS
BEGIN
	
	DECLARE @Primary_Dept VARCHAR(100)
	
--KA: Check to see if employee type 'PHD' is selected (code = 5). 
--If yes, then use Doctoral_Department_ID as the primary department
--Else use Department_ID (or Primary Department from Directory_employee_view)	

	DECLARE @emp_type_PHD VARCHAR(5)
	SET @emp_type_PHD = (select COUNT(*) from Faculty_staff_Holder.dbo.WP_Parse_String_To_Table(@EmpeeTypeCode) 
						where code in (5))
						

IF @emp_type_PHD	= 0
BEGIN
	SELECT			@Primary_Dept = Primary_Department
	FROM			Faculty_Staff_MIIS.dbo.Facstaff_Directory2 DV
						INNER JOIN Faculty_Staff_Holder.dbo.Facstaff_Basic FSB
							ON DV.Facstaff_ID = FSB.Facstaff_ID						
	WHERE			DV.Facstaff_ID = @FSID 
					AND FSB.BUS_Person_Indicator = 1
					
		
END

ELSE
		SELECT			@Primary_Dept = dbo.FSD_fn_Get_Department_Name(FSB.Doctoral_Department_ID)
		FROM		Faculty_Staff_MIIS.dbo.Facstaff_Directory2 DV
							INNER JOIN Faculty_Staff_Holder.dbo.Facstaff_Basic FSB
								ON DV.Facstaff_ID = FSB.Facstaff_ID						
		WHERE			DV.Facstaff_ID = @FSID  
						AND FSB.BUS_Person_Indicator = 1
						
		


	RETURN(@Primary_Dept)
END


/*
DECLARE @emp_type_desc VARCHAR(25)
SET @emp_type_desc = Faculty_staff_Holder.dbo.WP_fn_Get_Primary_Department (11214, '2,3,4,8')
PRINT @emp_type_desc


*/















GO
