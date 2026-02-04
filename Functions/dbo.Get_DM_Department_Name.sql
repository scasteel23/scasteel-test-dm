SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


-- NS 4/21/2017
CREATE FUNCTION [dbo].[Get_DM_Department_Name](@Department_ID int)
RETURNS varchar(100) AS  
BEGIN 
	DECLARE @name varchar(100)

	SET @name = ''
	SELECT @name= DM_Department_Name
	FROM dbo.FSDB_Departments
	WHERE  Department_ID = @Department_ID

	RETURN @name
END




GO
