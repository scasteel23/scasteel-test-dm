SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

-- NS 11/16/2018 rewritten for DM
-- STC 6/19/19 updated to use SHOW_DIRECTORY

CREATE FUNCTION [dbo].[DM_OUTLOOK_fn_Get_Department_Name](@FacstaffID int)
RETURNS varchar(100) AS  
BEGIN 
	DECLARE @name varchar(50)
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
	WHERE facstaffid = @FacstaffID 
			AND ac_year >= @current_ac_year

	IF @ac_year is NULL
		SELECT @ac_year=max(ac_year)
		FROM dbo._DM_ADMIN_DEP
		WHERE facstaffid = @FacstaffID 
				AND ac_year < @current_ac_year

	SET @name = ''

	IF @ac_year is NULL
		RETURN @name


	-- STC 6/19/19 - Get 1st department in sequence that is marked for display 
	SELECT @name = d.DEP
	FROM dbo._DM_ADMIN_DEP d
	WHERE  AC_YEAR = @ac_year
		-- STC temporarily include NULL until data has been corrected
		and (SHOW_DIRECTORY = 'Yes' OR SHOW_DIRECTORY IS NULL)
		--and SHOW_DIRECTORY = 'Yes'
		and not exists (
			select *
			from _DM_ADMIN_DEP d2
			where AC_YEAR = @ac_year
				and d.FACSTAFFID = d2.FACSTAFFID
				-- STC temporarily include NULL until data has been corrected
				and (d2.SHOW_DIRECTORY = 'Yes' OR D2.SHOW_DIRECTORY IS NULL)
				--and d2.SHOW_DIRECTORY = 'Yes'
				and d2.SEQ < d.SEQ
			)
		and FACSTAFFID = @FacstaffID

		--SELECT @name=DEP
		--FROM dbo._DM_ADMIN_DEP
		--WHERE  FACSTAFFID=@FacstaffID AND SEQ=1 AND AC_YEAR = @AC_year

	RETURN @name
END




GO
