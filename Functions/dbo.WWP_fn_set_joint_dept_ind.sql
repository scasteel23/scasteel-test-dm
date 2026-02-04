SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


--KA: June 2014
CREATE FUNCTION [dbo].[WWP_fn_set_joint_dept_ind]
		(
			@DeptCode varchar(2000), 
			@facstaff_id varchar(20),
			@DeptSubCode varchar(2000)
		)
RETURNS VARCHAR(5)
	AS
BEGIN
	
	DECLARE @JointDeptIND VARCHAR(5)
					
			SET @JointDeptIND = (SELECT COUNT(*) FROM Faculty_Staff_Holder.dbo.Facstaff_Joint_Departments 
							WHERE Department_ID in (SELECT * FROM Faculty_Staff_Holder.dbo.[WP_Parse_String_To_Table] (@DeptCode))	
							AND Facstaff_id = @facstaff_id
							AND Department_ID not in (SELECT DV.Department_ID	
														FROM			Faculty_Staff_MIIS.dbo.Facstaff_Directory2 DV
																					INNER JOIN Faculty_Staff_Holder.dbo.Facstaff_Basic FSB
																						ON DV.Facstaff_ID = FSB.Facstaff_ID																					
																					LEFT OUTER JOIN dbo.Facstaff_Subunits FSU
																						ON FSB.Facstaff_ID = FSU.Facstaff_ID
																					LEFT OUTER JOIN dbo.Subunit_Codes SC
																						ON FSU.Subunit_ID = SC.Subunit_ID
																WHERE		  (	DV.Department_ID in (SELECT * FROM Faculty_Staff_Holder.dbo.[WP_Parse_String_To_Table] (@DeptCode))  OR 
																				DV.Facstaff_ID IN ((SELECT Facstaff_ID FROM Faculty_Staff_Holder.dbo.Facstaff_Joint_Departments 
																										 WHERE Department_ID in (SELECT * FROM Faculty_Staff_Holder.dbo.[WP_Parse_String_To_Table] (@DeptCode))
																																)))					  
																			AND DV.Facstaff_ID IN ((select fsu.FACstaff_id
																									from [Faculty_Staff_Holder].[dbo].[Facstaff_Basic] fsb
																											inner join [Faculty_Staff_Holder].[dbo].[Facstaff_subunits] fsu
																												on fsb.facstaff_id = fsu.facstaff_id 
																										 WHERE FSU.subunit_id in (SELECT * FROM Faculty_Staff_Holder.dbo.[WP_Parse_String_To_Table] (@DeptSubCode))
																																))	
												))
							
	IF @JointDeptIND = 0
		BEGIN
			DECLARE @count AS INT
			SET @count = (SELECT count(*)  FROM Faculty_Staff_Holder.dbo.Facstaff_Joint_Departments where facstaff_id = @facstaff_id)
			IF @COUNT >= 1
					SET @JointDeptIND = 0
			ELSE 
					SET @JointDeptIND = 'N/A'					
		END
	
	ELSE 
		SET @JointDeptIND = 1	
		
	

	RETURN(@JointDeptIND)
END


/*
DECLARE @JointDeptIND VARCHAR(25)
DECLARE @DeptCode varchar(2000)
DECLARE @facstaff_id varchar(20)			
DECLARE @DeptSubCode varchar(2000)

SET @DeptCode = '1,14'
SET @facstaff_id = '15141'
SET @DeptSubCode = ''
			
SET @JointDeptIND = Faculty_staff_Holder.dbo.WP_fn_set_joint_dept_ind (@DeptCode, @facstaff_id, @DeptSubCode)
PRINT @JointDeptIND


*/


--select * FROM Facstaff_Joint_Departments 
----where facstaff_id = 1155   --PETRY
--where facstaff_id = 155		--AVIJITH
--12869  --RAJ











GO
