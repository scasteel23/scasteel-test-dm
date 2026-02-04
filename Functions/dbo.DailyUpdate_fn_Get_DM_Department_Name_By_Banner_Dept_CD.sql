SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


-- NS 4/29/2019: added EDW_Dept_CD2. Interestingly teh same departments in PRR is coded differently in BIO/EMPS EDW
--		For example Accountancy 1346 vs 346, Business Administration 1902 vs 902, Finance 1260 vs 260
-- NS 4/21/2017
CREATE FUNCTION [dbo].[DailyUpdate_fn_Get_DM_Department_Name_By_Banner_Dept_CD](@Dept_CD varchar(6))
RETURNS varchar(100)  AS  
BEGIN 
	DECLARE @DM_Department_Name varchar(100)

	SET @DM_Department_Name = ''

	IF @Dept_CD='952' 
		SET @DM_Department_Name = 'Gies Business'
	ELSE
		BEGIN
			SELECT @DM_Department_Name = DM_Department_Name
			FROM dbo.FSDB_Departments
			WHERE  EDW_Dept_CD = @Dept_CD AND EDW_Dept_CD IS NOT NULL

			IF @DM_Department_Name IS NULL OR @DM_Department_Name = ''
				BEGIN
					SELECT @DM_Department_Name = DM_Department_Name
					FROM dbo.FSDB_Departments
					WHERE  EDW_Dept_CD2 = @Dept_CD AND EDW_Dept_CD2 IS NOT NULL

					IF @DM_Department_Name IS NULL OR @DM_Department_Name = ''
							SET @DM_Department_Name = 'Unspecified Department'
				END

				
	END
	RETURN @DM_Department_Name
END








GO
