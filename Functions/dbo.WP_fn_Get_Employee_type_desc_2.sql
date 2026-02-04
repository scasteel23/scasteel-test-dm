SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


--KA: Created: June 2014(Used for people profile page): 
--Used in [dbo].[WP_sp_Fuzzy_Search_Some_ID] 

CREATE FUNCTION [dbo].[WP_fn_Get_Employee_type_desc_2]
			(
				@FSID INT,
				@EmpeeTypeCode VARCHAR(300)
			)
	RETURNS VARCHAR(50)
	AS
BEGIN
	
	 DECLARE @EmpDesc VARCHAR(100)

	 SELECT @EmpDesc = CASE 
						WHEN DV.BUS_FACULTY = 1  THEN 'Faculty'	
						WHEN FSB.EMPEE_GROUP_CD in('B','C', 'E','H') AND FSB.EMPEE_CLS_CD <> 'HG' THEN 'Staff'	
						WHEN DV.DOC_STATUS = 'Current PhD Student' THEN 'PHD'
						WHEN FSB.EMPEE_GROUP_CD = 'P' THEN 'Postdoc'
						WHEN FSB.EMPEE_GROUP_CD = 'T' THEN 'Retiree'
						WHEN DV.[Rank] LIKE '%Emeritus%' THEN 'Emeriti'
						WHEN FSB.EMPEE_GROUP_CD in ('G','H','S') THEN 'Student Worker'
						ELSE 'Others' 
					END
	 FROM			dbo._DM_PCI DV
					LEFT OUTER JOIN dbo._DM_BANNER FSB
						ON DV.FacstaffID = FSB.FacstaffID					
	 WHERE	 DV.ACTIVE = 'Yes'
				AND DV.FacstaffID = @FSID
		

	RETURN(@EmpDesc)
END


/*
DECLARE @emp_type_desc VARCHAR(25)
SET @emp_type_desc = Faculty_staff_Holder.dbo.WP_fn_Get_Employee_type_desc_2 (11360, '3')
PRINT @emp_type_desc
*/
/*
	DECLARE @EmpDesc VARCHAR(100)
	
--KA: Check to see if employee type 'Emeriti' is selected (code = 8). If yes, then show them under Emeriti. Else, show them as Faculty.	
	DECLARE @emeriti_ind VARCHAR(5)
	SET @emeriti_ind = (select COUNT(*) from Faculty_staff_Holder.dbo.WP_Parse_String_To_Table(@EmpeeTypeCode) 
						where code in (8))
						

IF @emeriti_ind	= 0
BEGIN
	SELECT @EmpDesc = CASE 
						WHEN DV.Faculty_Staff_Indicator = 1  THEN 'Faculty'	
						WHEN FSB.EMPEE_GROUP_CD in('B','C', 'E','H') AND FSB.EMPEE_CLS_CD <> 'HG' THEN 'Staff'	
						WHEN FSB.Doctoral_Flag = 1 THEN 'PHD'
						WHEN FSB.EMPEE_GROUP_CD = 'P' THEN 'Postdoc'
						WHEN FSB.EMPEE_GROUP_CD = 'T' THEN 'Retiree'
						WHEN FSB.Rank_ID = 8 THEN 'Emeriti'
						WHEN ((DV.Faculty_Staff_Indicator = 1) and (FSB.Rank_ID = 8)) THEN 'Emeriti'
						WHEN FSB.EMPEE_GROUP_CD in ('G','S') THEN 'Student Worker'
						ELSE 'Others' 
					END
	FROM			Faculty_Staff_MIIS.dbo.Facstaff_Directory2 DV
					INNER JOIN Faculty_Staff_Holder.dbo.Facstaff_Basic FSB
						ON DV.Facstaff_ID = FSB.Facstaff_ID
					
	WHERE		 FSB.BUS_Person_Indicator = 1 
				AND FSB.Active_Indicator = 1
				AND DV.Facstaff_ID = @FSID
		
END

ELSE
		SELECT @EmpDesc = CASE 
						WHEN ((DV.Faculty_Staff_Indicator = 1)  and (FSB.Rank_ID NOT IN (8))) THEN 'Faculty'	
						WHEN ((FSB.EMPEE_GROUP_CD in('B','C','E','H')) AND FSB.EMPEE_CLS_CD <> 'HG' AND (FSB.Rank_ID NOT IN (8))) THEN 'Staff'	
						WHEN FSB.Doctoral_Flag = 1 THEN 'PHD'
						WHEN FSB.EMPEE_GROUP_CD = 'P' THEN 'Postdoc'
						WHEN ((FSB.EMPEE_GROUP_CD = 'T') and (FSB.Rank_ID NOT IN (8))) THEN 'Retiree'
						WHEN ((DV.Faculty_Staff_Indicator = 1) and (FSB.Rank_ID = 8)) THEN 'Emeriti'
						WHEN FSB.EMPEE_GROUP_CD in ('G','S') THEN 'Student Worker'
						ELSE 'Others' 
					END
		FROM		Faculty_Staff_MIIS.dbo.Facstaff_Directory2 DV
						INNER JOIN Faculty_Staff_Holder.dbo.Facstaff_Basic FSB
							ON DV.Facstaff_ID = FSB.Facstaff_ID
						
		WHERE		 FSB.BUS_Person_Indicator = 1 
					AND FSB.Active_Indicator = 1
					AND DV.Facstaff_ID = @FSID


	RETURN(@EmpDesc)
*/















GO
