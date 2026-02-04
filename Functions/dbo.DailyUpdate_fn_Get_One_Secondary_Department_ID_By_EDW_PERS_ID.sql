SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

-- NS 10/18/2005

-- STC 10/31/11 - Need to make the deptartment code returned belongs to a Business appointment

CREATE FUNCTION [dbo].[DailyUpdate_fn_Get_One_Secondary_Department_ID_By_EDW_PERS_ID] (@EDW_PERS_ID varchar(10)) 

RETURNS int  AS  
BEGIN 
	-- AMong many  JOB_DETL_DEPT_CD of secondary job contracts, pick one JOB_DETL_DEPT_CD
	DECLARE @department_id int
	DECLARE @dept_cd varchar(3)

	SELECT @dept_cd = JOB_DETL_DEPT_CD
	FROM  dbo.EDW_Current_Employees
	WHERE edw_pers_id = @EDW_PERS_ID 	
		AND JOB_CNTRCT_TYPE_DESC <> 'Primary'
		AND JOB_DETL_COLL_CD = 'KM'
	ORDER BY JOB_DETL_DEPT_CD DESC
		
	SELECT @department_id= department_id
	FROM dbo.Departments_Banner_Code
	WHERE  Banner_Dept_CD = @Dept_CD

	RETURN @department_id
END






GO
