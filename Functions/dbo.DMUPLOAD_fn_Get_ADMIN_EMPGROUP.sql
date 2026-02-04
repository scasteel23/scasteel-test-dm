SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS OFF
GO

-- NS 12/22/2018
CREATE FUNCTION [dbo].[DMUPLOAD_fn_Get_ADMIN_EMPGROUP](
		@Department_Name varchar(100)
		,@Faculty_Staff_Indicator INT
		,@Doctoral_Flag INT)
	
	RETURNS VARCHAR(200)
	AS
BEGIN
	DECLARE @empgroup varchar(200)
	
	SET @empgroup = CASE WHEN @Faculty_Staff_Indicator=1 THEN 'Faculty' 
			WHEN @Doctoral_Flag =1 THEN 'PhD Students'
			ELSE 'Staff'
			END
	
	IF @Department_Name IS NOT NULL
		AND @Department_Name IN ('iMBA', 'iMSA')
		AND @empgroup = 'Faculty'
			SET @empgroup = @Department_Name + ' ' + @empgroup
	ELSE
	IF @Department_Name IS NOT NULL
		AND @Department_Name IN ('Accountancy', 'Business Administration', 'Finance')
			SET @empgroup = @Department_Name + ' ' + @empgroup
	ELSE
			SET @empgroup = 'Other College Staff'

	RETURN @empgroup

	/*
		Accountancy Faculty
		Accountancy Staff
		Accountancy PhD Students
		Business Administration Faculty
		Business Administration Staff
		Business Administration PhD Students
		Finance Faculty
		Finance Staff
		Finance PhD Students
		iMBA Faculty
		iMSA Faculty
		Other College Staff
	*/

END
GO
