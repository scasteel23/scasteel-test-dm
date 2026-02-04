SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- NS 6/11/2019
CREATE FUNCTION [dbo].[FSDB_DM_Upload_Logs_get_department_names]
(
	@EDWPERSID varchar(10)
)
RETURNS VARCHAR(300)
BEGIN

	DECLARE @deptname varchar(300)
	SET @deptname = NULL
	SELECT @deptname=COALESCE(@deptname +',','') + m1.DEP
	FROM DM_Shadow_Staging.dbo._DM_ADMIN_DEP m1
			LEFT JOIN DM_Shadow_Staging.dbo._DM_ADMIN_DEP m2
			ON m1.USERNAME = m2.USERNAME  AND m1.AC_YEAR < m2.AC_YEAR
				AND m1.USERNAME is not NULL		
	WHERE m2.AC_YEAR is NULL AND m1.EDWPERSID = @EDWPERSID

	RETURN @deptname

END
GO
