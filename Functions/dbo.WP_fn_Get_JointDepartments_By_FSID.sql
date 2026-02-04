SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

-- NS 12/5/2018
-- SAME with DM_OUTLOOK_fn_Get_Departments_String_By_FSID
CREATE    FUNCTION [dbo].[WP_fn_Get_JointDepartments_By_FSID](@FSID INT)
	RETURNS VARCHAR(8000)
	AS
BEGIN
	
	/*
		print dbo.DM_OUTLOOK_fn_Get_Departments_String_By_FSID(282)
		print dbo.DM_OUTLOOK_fn_Get_Departments_String_By_FSID(1155)
		print dbo.DM_OUTLOOK_fn_Get_Departments_String_By_FSID(10980)

	*/
		DECLARE @DepartmentString VARCHAR(8000) 
		DECLARE @DepartmentID VARCHAR(200) 
		DECLARE @DepartmentName VARCHAR(200) 
		
		
		SET @DepartmentString = '' 
		SET @DepartmentID = ''
		SET @DepartmentName = '' 
		
		DECLARE  @ac_year varchar(10), @cdate datetime, @threhold_date varchar(12), @current_ac_year varchar(10)

	
		-- >>>> GET THE proper AC_YEAR
		SET @cdate = GETDATE()
		SET @threhold_date = '8/16/' + CAST(YEAR(GETDATE())AS VARCHAR)
		IF @cdate >= @threhold_date
			SET @current_ac_year = CAST(YEAR(GETDATE())AS VARCHAR) + '-' + CAST(YEAR(GETDATE())+1 AS VARCHAR)
		ELSE
			SET @current_ac_year = CAST(YEAR(GETDATE())-1AS VARCHAR) + '-' + CAST(YEAR(GETDATE()) AS VARCHAR)
		--print @current_ac_year

		-- Get the earliest year between current year and the farthest future year
		SELECT @ac_year=min(ac_year)
		FROM dbo._DM_ADMIN_DEP
		WHERE facstaffid = @FSID 
				AND ac_year >= @current_ac_year
		
		IF @ac_year is NULL
			SELECT @ac_year=max(ac_year)
			FROM dbo._DM_ADMIN_DEP
			WHERE facstaffid = @FSID 
					AND ac_year < @current_ac_year
		
		IF @ac_year is NULL
			RETURN @DepartmentString

	
		DECLARE FS_Departments  CURSOR SCROLL FOR 

		SELECT D.DEP as Department_Name     
		FROM dbo._DM_ADMIN_DEP d
		WHERE  DEP is not null and DEP <> '' and d.facstaffid = @FSID 
		ORDER BY SEQ ASC
				
		OPEN FS_Departments
		FETCH FS_Departments INTO @DepartmentName 
		
		WHILE @@FETCH_STATUS = 0 
		BEGIN -- Start of FS_Departments Cursor
		IF @DepartmentName IS NOT NULL -- Start of @DepartmentName NOT NULL 
			BEGIN 
				IF @DepartmentString = '' -- Cursor is at the First Record 
				BEGIN
					SET @DepartmentString = @DepartmentName  					
				END
				ELSE -- Cursor is not at the First Record 
				BEGIN
					
					SET @DepartmentString = @DepartmentString + ' and ' + @DepartmentName
								
				END
											
				/* get the next record from FS_Departments */
				FETCH FS_Departments INTO @DepartmentName 

							
			END -- End of @DepartmentName NOT NULL 
		END -- End of FS_Departments Cursor
		
		
	
		/* Close FS_Departments */
		CLOSE FS_Departments
		DEALLOCATE FS_Departments	



		RETURN(@DepartmentString)
	END























GO
