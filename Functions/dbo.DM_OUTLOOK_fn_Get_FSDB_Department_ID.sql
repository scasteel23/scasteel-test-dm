SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

-- NS 11/22/2018 : reverse lookup Department_ID from employee's department name
CREATE    FUNCTION [dbo].[DM_OUTLOOK_fn_Get_FSDB_Department_ID](@facstaffid INT)
	RETURNS INT
AS
BEGIN
	
	DECLARE @dep as varchar(100), @department_id INT

	SELECT @dep = DEP
	FROm dbo._DM_ADMIN_DEP
	WHERE FACSTAFFID=@facstaffid
	ORDER BY AC_YEAR ASC

	SELECT @department_id=department_id
	FROM dbo.FSDB_Departments
	WHERE DM_Department_Name=@dep
	ORDER BY Department_ID ASC		-- get the larger ID if we got multiple rows

	RETURN @department_id

END




GO
