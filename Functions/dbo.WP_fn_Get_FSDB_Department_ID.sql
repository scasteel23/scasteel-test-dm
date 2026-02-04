SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

-- NS 12/5/2018 : reverse lookup Department_ID from employee's department name
CREATE    FUNCTION [dbo].[WP_fn_Get_FSDB_Department_ID](@Dep varchar(100))
	RETURNS INT
AS
BEGIN
	
	DECLARE  @department_id INT

	SELECT @department_id=department_id
	FROM dbo.FSDB_Departments
	WHERE DM_Department_Name=@dep
	ORDER BY Department_ID ASC		-- get the larger ID if we got multiple rows

	RETURN @department_id

END




GO
